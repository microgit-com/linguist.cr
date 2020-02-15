require "cadmium_classifier"
require "./language"
require "./blob"
require "./language_container"
require "./tokenizer"
module Linguist
  class Classifier < Cadmium::Classifier::Bayes
    @languages : LanguageContainer

    def initialize(languages)
      tokenizer = NGramsTokenizer.new
      super(tokenizer)
      @languages = languages
    end

    def self.call(blob, languages, real_languages) : Array(Language)
      classifier = Classifier.new(real_languages)
      classifier.load("./data")

      return [] of Language if blob.nil?
      classifier.simple_categorize(blob.text)
    end

    def train_on(dir, overwrite = false)
      train_texts = {} of String => Array(String)
      logger = Logger.new(STDOUT)
      if Dir.open(dir).children.empty?
        raise "Didn't find the samples"
      end

      subdirs = [] of String
      subdirs = Dir.open(dir) do |d|
        d.children
      end

      subdirs.each_cons(30) do |dirs|
        dirs.each do |subdir|
          if !overwrite && @categories.includes?(subdir)
            puts "Data for '#{subdir}' already exists. Skipping."
            next
          end

          files = [] of String
          files = Dir.open(File.join(dir, subdir)) do |d|
            d.children
          end
          language = @languages[subdir]?
          next if language.nil?

          files.each do |file|
            next if File.directory?(File.join(dir, subdir, file))
            text = File.read_lines(File.join(dir, subdir, file))
            next if text.empty?
            if train_texts[subdir]?
              train_texts[subdir] = train_texts[subdir] + text
            else
              train_texts[subdir] = text
            end
          end
          files.clear
        end
        dirs.clear
      end

      subdirs.clear

      logger.info "GETTING STUFF"
      logger.info "languages: #{@languages.size}"
      logger.info "languages with samples: #{train_texts.size}"
      train_texts.each do |name, texts|
        puts "Training '#{name}' - #{texts.size}"

        texts.each do |line|
          train(line, name)
        end
        save("./data")
        puts
      end
    end

    def categorize(text : String, results = 3)
      tokens = tokenizer.tokenize(text)
      freq_table = frequency_table(tokens)

      # Iterate through our categories to find the one with
      # the maximum probability for this text.
      chance_hash = @categories.reduce({} of String => Float64) do |hash, category|
        # Start out by calculating the overall probability of
        # this category. (out of all the documents we've
        # looked at, how many were mapped to this category)
        category_probability = @doc_count[category].to_f64 / @total_documents.to_f64

        # Take the log to avoid underflow
        log_probability = Math.log(category_probability)

        # Now determine P( w | c ) for each word `w` in the text.
        freq_table.each do |token, frequency_in_text|
          token_prob = token_probability(token, category)

          # Determine the log of the P( w | c ) for this word.
          log_probability += frequency_in_text * Math.log(token_prob)
        end

        hash[category] = log_probability
        hash
      end

      sorted = chance_hash.to_a.sort_by { |a| -a[1] }
      selected = sorted.first(results)
      selected.map! { |a| {a[0], normalize(a[1], sorted.last[1], sorted.first[1])} }
      selected
    end

    def simple_categorize(text : String)
      categories = categorize(text)
      categories.map { |c| @languages[c[0]] }
    end

    def save(dir)
      unless Dir.exists?(dir)
        Dir.mkdir_p(dir)
      end

      meta = {
        total_documents: total_documents,
        categories: categories,
        word_count: word_count,
        doc_count: doc_count,
        vocabulary: vocabulary
      }

      File.write(File.join(dir, "meta.json"), meta.to_json)

      categories.each do |lang|
        data = {
          vocabulary_size: vocabulary_size,
          word_count: word_count[lang],
          word_frequency_count: word_frequency_count[lang]
        }

        File.write(File.join(dir, "#{lang}.json"), data.to_json)
      end

      self
    end

    def load(dir)
      Dir.open(dir).each_child do |file|
        filename = File.basename(file, File.extname(file))
        data = File.read(File.join(dir, file))
        if filename == "meta"
          meta = JSON.parse(data)
          @total_documents = meta["total_documents"].as_i
          @categories = meta["categories"].as_a.map(&.as_s)
          @word_count = meta["word_count"].as_h.transform_values(&.as_i)
          @doc_count = meta["doc_count"].as_h.transform_values(&.as_i)
          @vocabulary = meta["vocabulary"].as_a.map(&.as_s)
          @vocabulary_size = @vocabulary.size
        else
          lang = JSON.parse(data)
          initialize_category(filename)
          @word_count[filename] = lang["word_count"].as_i
          @word_frequency_count[filename] = lang["word_frequency_count"].as_h.transform_values(&.as_i)
          @vocabulary_size = lang["vocabulary_size"].as_i unless @vocabulary_size > 0
        end
      end

      self
    end

    private def normalize(num, min, max)
      return 1.0 if max - min == 0
      return (num - min) / (max - min)
    end
  end
end
