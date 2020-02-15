require "cadmium_tokenizer"

module Linguist
  class NGramsTokenizer < Cadmium::Tokenizer::Base
    SYMBOL_RANGES = [0..64, 91..96]

    property max_size : Int32

    def initialize(@max_size = 3)
    end

    def tokenize(string : String) : Array(String)
      groupings = [] of String
      reader = Char::Reader.new(string)

        token = [] of Char
        loop do
          current_char = reader.current_char
          # Check if the next character is not a number or symbol
          if symbol?(current_char)
            unless token.empty?
              grouping = token.join
              grouping = grouping.downcase unless downcase?(grouping)
              groupings << grouping
            end
            token.clear
          else
            if token.size == @max_size
              grouping = token.join
              grouping = grouping.downcase unless downcase?(grouping)
              groupings << grouping
              token.shift
            end

            token << current_char
          end

          break unless reader.has_next?
          reader.next_char
        end

      groupings
    end

    def symbol?(char)
      SYMBOL_RANGES.any?(&.includes?(char.ord))
    end

    def downcase?(string)
      string.each_char do |char|
        return false unless char.downcase == char
      end
      true
    end
  end
end
