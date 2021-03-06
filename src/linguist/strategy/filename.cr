module Linguist
  module Strategy
    # Detects language based on filename
    class Filename
      # Public: Use the filename to detect the blob's language.
      #
      # blob               - An object that quacks like a blob.
      # candidates         - A list of candidate languages.
      #
      # Examples
      #
      #   Filename.call(FileBlob.new("path/to/file"))
      #
      # Returns an array of languages with a associated blob's filename.
      # Selected languages must be in the candidate list, except if it's empty,
      # in which case any language is a valid candidate.
      def self.call(blob, candidates, real_languages) : Array(Language) | Array(Tuple(Language, Float64))
        return [] of Language if blob.nil?
        name = blob.name.to_s
        languages = real_languages.find_by_filename(name)
        candidates.any? ? candidates & languages : languages
      end
    end
  end
end
