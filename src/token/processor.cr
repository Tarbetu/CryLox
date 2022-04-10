module Token
  class Processor
    def initialize(
      @type    : Type,
      @lexeme  : String,
      @line    : Integer,
      @literal : String | Nil
    ); end
  end

  def to_s
    "#{type} #{lexeme} #{literal}"
  end
end
