module Linguist
  class LanguageContainer
    @languages : Array(Language)
    @extension_index : Hash(String, Array(Language))
    @filename_index : Hash(String, Array(Language))
    @index : Hash(String, Language)
    @alias_index : Hash(String, Language)
    @popular : Array(Language) | Nil

    def initialize
      languages_yaml = YAML.parse(File.read("./src/linguist/languages.yml"))
      @languages = [] of Language
      @extension_index = {} of String => Array(Language)
      @filename_index = {} of String => Array(Language)
      @index = {} of String => Language
      @alias_index = {} of String => Language
      @interpreter_index = {} of String => Array(Language)
      setup_variables(languages_yaml)
    end

    def find_by_extension(filename : String) : Array(Language)
      extname = File.extname(filename)
      return @extension_index[extname].to_a if @extension_index[extname]?
      [] of Language
    end

    def find_by_filename(filename : String) : Array(Language)
      basename = File.basename(filename)
      return @filename_index[basename].to_a if @filename_index[basename]?
      [] of Language
    end

    def self.find_by_interpreter(interpreter)
      @interpreter_index[interpreter]
      return @interpreter_index[basename].to_a if @interpreter_index[basename]?
      [] of Language
    end

    def size
      @languages.size
    end

    def [](key)
      @index[key.downcase]
    end

    def popular
      @popular ||= @languages.select(&.popular?).sort_by { |lang| lang.name.downcase }
    end

    private def setup_variables(languages)
      languages.as_h.each do |lang|
        language = Language.new(lang[0]?, lang[1]["color"]?,
          lang[1]["type"]?, lang[1]["aliases"]?, lang[1]["extensions"]?, lang[1]["extname"]?, lang[1]["ace_mode"]?)

        @languages << language
        @index[language.name.downcase] = language

        if extnames = language.extensions
          extnames.each do |extname|
            @extension_index[extname.as_s] = [] of Language unless @extension_index[extname.as_s]?
            @extension_index[extname.as_s] << language
          end
        end

        if lang[1]["aliases"]?
          lang[1]["aliases"].as_a.each do |name|
            # All Language aliases should be unique. Raise if there is a duplicate.
            next if @index[name.as_s.downcase]?
            @index[name.as_s.downcase] = @alias_index[name.as_s.downcase] = language
          end
        end

        if lang[1]["filenames"]?
          lang[1]["filenames"].as_a.each do |filename|
            @filename_index[filename.as_s] = [] of Language unless @filename_index[filename.as_s]?
            @filename_index[filename.as_s] << language
          end
        end

        if lang[1]["interpreters"]?
          lang[1]["interpreters"].as_a.each do |interpreter|
            @interpreter_index[interpreter.as_s] = [] of Language unless @interpreter_index[interpreter.as_s]?
            @interpreter_index[interpreter.as_s] << language unless @interpreter_index[interpreter.as_s].includes?(language)
          end
        end
      end
    end
  end
end
