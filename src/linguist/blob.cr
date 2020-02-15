module Linguist
  class Blob
    @blob : Git::Blob
    @name : String | Nil

    def self.from_git(repository, delta, name)
      new(Git::Blob.lookup(repository, delta), name)
    end

    def initialize(blob : Git::Blob | File, name)
      @blob = blob
      @name = name
    end

    def name
      @name
    end

    def size
      @blob.size
    end

    def text
      @blob.text
    end

    def finalize
      true
    end
  end
end
