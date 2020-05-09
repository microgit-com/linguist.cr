require "./language_container"
require "./blob"
require "./repository"

module Linguist
  class Detector
    @repository : Repository
    @blob : Blob | Nil
    @languages : LanguageContainer

    def initialize(repository)
      @repository = repository
      @languages = LanguageContainer.new
    end

    def set_blob(delta, name)
      @blob = ::Linguist::Blob.from_git(@repository, delta, name)
    end

    def language
      found = find
      return nil if found.empty?
      found.first
    end

    def languages
      find
    end

    def find
      langs = [] of Language
      languages_arr = [] of Language
      STRATEGIES.each do |strategy|
        langs = strategy.call(@blob, languages_arr, @languages)
        if langs.size == 1
          languages_arr = langs
          break
        elsif langs.size > 1
          # More than one candidate was found, pass them to the next strategy.
          languages_arr = langs
        else
          # No candidates, try the next strategy
        end
      end
      languages_arr
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
