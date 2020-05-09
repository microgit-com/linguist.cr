module Linguist
  class Language
    @name : String
    @color : String | Nil
    @type : String | Nil
    @aliases : Array(YAML::Any) | Nil
    @extensions : Array(YAML::Any) | Nil
    @ace_mode : String | Nil
    @extname : String | Nil

    property :name
    property :extname
    property :extensions
    property :aliases
    property :type
    property :ace_mode

    def self.create_from_file
      languages = YAML.parse(File.read(::Linguist.settings.path))
      returns = [] of Language
      languages.as_h.each do |lang|
        next if languages.nil?
        returns << Language.new(lang[0]?, lang[1]["color"]?,
          lang[1]["type"]?, lang[1]["aliases"]?, lang[1]["extensions"]?, lang[1]["extname"]?, lang[1]["ace_mode"]?)
      end
      returns
    end

    def initialize(name, color, type, aliases, extensions, extname, ace_mode)
      @name = name.try { |a| a.as_s }
      @type = type.try { |a| a.as_s }
      @color = color.try { |a| a.as_s }
      @aliases = aliases.try { |a| a.as_a }
      @extensions = extensions.try { |a| a.as_a }
      @extname = extname.try { |a| a.as_s }
      @ace_mode = ace_mode.try { |a| a.as_s }
    end
  end
end
