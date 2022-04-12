require "./token/*"
require "./crylox.cr"

class Scanner
  def initialize(@source : String)
    @tokens = [] of Token::Processor
    @start = 0
    @current = 0
    @line = 1
    @keywords = {
      "and" => Token::Type::And,
      "class" => Token::Type::Class,
      "else" => Token::Type::Else,
      "false" => Token::Type::False,
      "for" => Token::Type::For,
      "fun" => Token::Type::Fun,
      "if" => Token::Type::If,
      "nil" => Token::Type::Nil,
      "or" => Token::Type::Or,
      "print" => Token::Type::Print,
      "return" => Token::Type::Return,
      "super" => Token::Type::Super,
      "this" => Token::Type::This,
      "true" => Token::Type::True,
      "var" => Token::Type::Var,
      "while" => Token::Type::While
    }
  end

  def scan_tokens : Array(Token::Processor)
    until at_end?
      start = @current
      scan_token
    end

    @tokens.push(Token::Processor.new(Token::Type::Eof, "", @line, nil))
    @tokens
  end

  private def scan_token
    character = advance
    case character
    when '(' then add_token(Token::Type::LeftParenthesis)
    when ')' then add_token(Token::Type::RightParenthesis)
    when '{' then add_token(Token::Type::LeftBrace)
    when '}' then add_token(Token::Type::RightBrace)
    when ',' then add_token(Token::Type::Comma)
    when '.' then add_token(Token::Type::Dot)
    when '-' then add_token(Token::Type::Minus)
    when '+' then add_token(Token::Type::Plus)
    when ';' then add_token(Token::Type::Semicolon)
    when '*' then add_token(Token::Type::Star)
      # Operators
    when '!'
      add_token(match('=') ? Token::Type::BangEqual : Token::Type::Bang)
    when '='
      add_token(match('=') ? Token::Type::EqualEqual : Token::Type::Equal)
    when '<'
      add_token(match('=') ? Token::Type::LessEqual : Token::Type::Less)
    when '>'
      add_token(match('=') ? Token::Type::GreaterEqual : Token::Type::Greater)
    when 'o'
      add_token(Token::Type::Or) if match('r')
    when '/'
      if match '/'
        until peek == '\n' && at_end?
          advance
        end
      else
        add_token(Token::Type::Slash)
      end
    when ' ', '\r', '\t'
      return
    when '\n'
      @line += 1
    when '"'
      string
    else
      if digit? character
        number
      elsif alpha? character
        identifier
      else
        Crylox::Executer.error(@line, "Unexcepted character")
      end
    end
  end

  private def identifier()
    while alpha?(peek) || digit?(peek)
      advance
    end

    text = @source[@start..@current - 1]
    type = @keywords[text] || Token::Type::Identifier
    add_token(Token::Type::Identifier)
  end

  private def number
    while digit? peek
      advance
    end

    if peek == '.' && digit? peek_next
      advance

      while digit? peek
        advance
      end
    end

    add_token(Token::Type::Number, Float64.new(@source[@start...@current]))
  end

  private def digit?(character : Char) : Bool
    character >= '0' && character <= '9'
  end

  private def alpha?(character : Char) : Bool
    character >= 'a' && character <= 'z' ||
    character >= 'A' && character <= 'Z' ||
    character == '_'
  end

  private def match(expected : Char) : Bool
    return false if at_end?
    return false if @source[@current] != expected

    @current += 1
    true
  end

  private def advance : Char
    @current += 1
    @source[@current]
  end

  private def add_token(type : Token::Type)
    add_token(type, nil)
  end

  private def add_token(type : Token::Type, literal : Token::LiteralType)
    text : String = @source[@start..@current]
    @tokens.push(Token::Processor.new(type, text, @line, literal))
  end

  private def at_end? : Bool
    @current >= @source.size
  end

  private def peek : Char
    return '\0' if at_end?
    @source[@current]
  end

  private def peek_next : Char
    return '\0' if at_end? || @current + 1 >= @source.size
    @source[@current + 1]
  end

  private def string : Nil
    until peek == '"' && at_end?
      @line += 1 if peek == '\n'
      advance
    end

    if at_end?
      return Crylox::Executer.error(@line, "Unterminated string.")
    end

    advance

    value = @source[(@start + 1)..(@current - 1)]
    add_token(Token::Type::String, value)
  end
end
