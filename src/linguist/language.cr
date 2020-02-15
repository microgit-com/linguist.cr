module Linguist
  class Language
    @name : String | Nil
    @color : String | Nil
    @typed : String | Nil
    @aliases : Array(YAML::Any) | Nil
    @extensions : Array(YAML::Any) | Nil
    @extname : String | Nil
    @text : Array(String) | Nil

    property :name
    property :extname
    property :extensions
    property :aliases
    property :text
    property :typed

    def self.create_from_file
      languages = YAML.parse(File.read("./src/linguist/languages.yml"))
      returns = {} of String => Language
      languages.as_h.each do |lang|
        next if languages.nil?
        returns[lang[0].as_s] = Language.new(lang[0]?, lang[1]["color"]?,
          lang[1]["type"]?, lang[1]["aliases"]?, lang[1]["extensions"]?, lang[1]["extname"]?)
      end
      returns
    end

    def initialize(name, color, typed, aliases, extensions, extname)
      @name = name.try { |a| a.as_s }
      @typed = typed.try { |a| a.as_s }
      @color = color.try { |a| a.as_s }
      @aliases = aliases.try { |a| a.as_a }
      @extensions = extensions.try { |a| a.as_a }
      @extname = extname.try { |a| a.as_s }
    end

    def add_text(text : Array(String))
      if @text
        @text = text + text
      else
        @text = text
      end
    end
  end
end
