module Linguist
  module Strategy
    # Detects man pages based on numeric file extensions with group suffixes.
    class Manpage

      # Public: RegExp for matching conventional manpage extensions
      #
      # This is the same expression as that used by `github/markup`
      MANPAGE_EXTS = /\.(?:[1-9](?![0-9])[a-z_0-9]*|0p|n|man|mdoc)(?:\.in)?$/i

      # Public: Use the file extension to match a possible man page,
      # only if no other candidates were previously identified.
      #
      # blob               - An object that quacks like a blob.
      # candidates         - A list of candidate languages.
      #
      # Examples
      #
      #   Manpage.call(FileBlob.new("path/to/file"))
      #
      # Returns:
      #   1. The list of candidates if it wasn't empty
      #   2. An array of ["Roff", "Roff Manpage"] if the file's
      #      extension matches a valid-looking man(1) section
      #   3. An empty Array for anything else
      #
      def self.call(blob, candidates = [] of Language, real_languages = LanguageContainer.new)
        return candidates if candidates.any?
        return [] of Language if blob.nil?
        if blob.name =~ MANPAGE_EXTS
          return [
                   real_languages["Roff Manpage"],
                   real_languages["Roff"],
                 # Language["Text"] TODO: Uncomment once #4258 gets merged
                 ]
        end

        [] of Language
      end
    end
  end
end
