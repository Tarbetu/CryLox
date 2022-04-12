module Token
  alias LiteralType = String | Nil | Float64

  class Processor
    def initialize(
      @type    : Type,
      @lexeme  : String,
      @line    : Int32,
      @literal : LiteralType
    ); end

    def to_s(io : IO)
      io << "#{@type} #{@lexeme} #{@literal}"
    end
  end
end
