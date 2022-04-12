module Token
  alias LiteralType = String | Nil | Float64

  class Processor
    def initialize(
      @type    : Type,
      @lexeme  : String,
      @line    : Int32,
      @literal : LiteralType
    ); end
  end

  def to_s
    "#{type} #{lexeme} #{literal}"
  end
end
