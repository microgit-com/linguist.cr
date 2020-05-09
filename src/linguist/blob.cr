module Linguist
  class Blob
    @blob : Git::Blob
    @repository : Repository
    @name : String | Nil

    def self.from_git(repository : Repository, delta, name)
      new(repository, Git::Blob.lookup(repository.repository, delta), name)
    end

    def self.from_git_blob(repository : Repository, blob, name)
      new(repository, blob, name)
    end

    def initialize(@repository, @blob : Git::Blob | File, @name)
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

    def data
      @blob.text
    end

    def finalize
      true
    end
  end
end
