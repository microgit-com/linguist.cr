require "./language_container"
require "./classifier"
require "./blob"

module Linguist
  class Detector
    @repository : Git::Repository
    @blob : Blob | Nil
    @languages : LanguageContainer

    def initialize(repository)
      @repository = repository
      @languages = LanguageContainer.new
    end

    def set_blob(delta, name)
      @blob = ::Linguist::Blob.from_git(@repository, delta, name)
    end

    def load
      @classifier.load("./data")
    end

    def train
      load
      @classifier.train_on("./samples")
    end

    def language
      found = find
      return nil if found.empty?
      find.first
    end

    def languages
      find
    end

    def find
      langs = [] of Language
      STRATEGIES.each do |strategy|
        langs = strategy.call(@blob, langs, @languages)
      end
      langs
    end

    def size
      @blob.try { |b| b.size }
    end

    def finalize
      @blob.try { |b| b.finalize }
    end

    def include_in_language_stats?
      true
    end
  end
end
