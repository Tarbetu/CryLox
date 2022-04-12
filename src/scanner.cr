require "./token/*"
require "./crylox.cr"

class Scanner
  def initialize(@source : String)
    @tokens = [] of Tokens::Type
    @start = 0
    @current = 0
    @line = 1
    @keywords = {
      "and" => Tokens::Type::And,
      "class" => Tokens::Type::Class,
      "else" => Tokens::Type::Else,
      "false" => Tokens::Type::False,
      "for" => Tokens::Type::For,
      "fun" => Tokens::Type::Fun,
      "if" => Tokens::Type::If,
      "nil" => Tokens::Type::Nil,
      "or" => Tokens::Type::Or,
      "print" => Tokens::Type::Print,
      "return" => Tokens::Type::Return,
      "super" => Tokens::Type::Super,
      "this" => Tokens::Type::This,
      "true" => Tokens::Type::True,
      "var" => Tokens::Type::Var,
      "while" => Tokens::Type::While
    }
  end

  def scan_tokens
    until at_end?
      start = current
      scan_token
    end

    @tokens.push(Tokens::Processor.new(Tokens::Type::EOF, "", nil, line))
  end

  private def scan_token
    character = advance
    case character
    when '(' then add_token(Tokens::Type::LeftParen)
    when ')' then add_token(Tokens::Type::RightParen)
    when '{' then add_token(Tokens::Type::LeftBrace)
    when '}' then add_token(Tokens::Type::RightBrace)
    when ',' then add_token(Tokens::Type::Comma)
    when '.' then add_token(Tokens::Type::Dot)
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
      if number? character
        number
      elsif alpha? character
        identifier
      else
        Crylox::Executer.error(line, "Unexcepted character")
      end
    end
  end

  private def identifier()
    while alpha? peek || number? peek
      advance
    end

    text = source[start..current - 1]
    type = keywords[text] || Tokens::Type::Identifier
    add_token(Tokens::Type::Identifier)
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

    add_token(Tokens::Type::Number, BigFloat.new(@source[@start...@current]))
  end

  private def digit?(character : Char) : Boolean
    character >= '0' && character <= '9'
  end

  private def alpha?(character : Char) : Boolean
    character >= 'a' && character <= 'z' ||
    character >= 'A' && character <= 'Z' ||
    character == '_'
  end

  private def match(expected : Char) : Boolean
    return false if at_end?
    return false if @source[current] != expected

    @current += 1
    true
  end

  private def advance : Char
    @current += 1
    @source[current]
  end

  private def add_token(type : Token::Type)
    add_token(type, nil)
  end

  private def add_token(type : Token::Type, literal : String | Nil)
    text : String = @source[start..current]
    @tokens.push(Token::Processor.new(type, text, literal, @line))
  end

  private def at_end? : Boolean
    current >= @source.length
  end

  private def peek : Char
    return '\0' if at_end?
    source[current]
  end

  private def peek_next : Char
    return '\0' if at_end? || current + 1 >= source.length
    source[current + 1]
  end

  private def string : Nil
    until peek == '"' && at_end?
      @line += 1 if peek == '\n'
      advance
    end

    if at_end?
      return Crylox::Executer.error(line, "Unterminated string.")
    end

    advance

    value = source[(@start + 1)..(current - 1)]
    add_token(Token::Type::String, value)
  end
end
