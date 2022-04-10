require "./token/*"
require "./crylox.cr"

class Scanner
  def initialize(@source : String)
    @tokens = [] of Tokens::Type
    @start = 0
    @current = 0
    @line = 1
  end

  def scan_tokens
    until at_end?
      start = current
      scan_token
    end

    @tokens.push(Tokens::Processor.new(Tokens::Type::EOF, "", nil, line))
  end

  private def scan_token
    case advance
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
    else
      Crylox::Executer.error(line, "Unexcepted character")
    end
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
  end

  private def at_end? : Boolean
    current >= @source.length
  end
end
