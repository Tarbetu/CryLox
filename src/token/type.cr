module Token
  enum Type
    # Single-character tokens
    LeftParenthesis
    RightParenthesis
    LeftBrace
    RightBrace
    Comma
    Dot
    Minus
    Plus
    Semicolon
    Slash
    Star

    # One or two character tokens
    Equal
    EqualEqual
    Bang
    BangEqual
    Greater
    GreaterEqual
    Less
    LessEqual

    # Literals
    Identifier
    String
    Number

    # Keywords
    And
    Class
    Else
    False
    Fun
    For
    If
    Nil
    Or
    Print
    Return
    Super
    This
    True
    Var
    While

    Eof
  end
end
