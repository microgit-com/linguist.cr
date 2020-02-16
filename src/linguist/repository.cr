require "git"
require "./detector"
require "./language"

module Linguist
  # A Repository is an abstraction of a Grit::Repo or a basic file
  # system tree. It holds a list of paths pointing to Blobish objects.
  #
  # Its primary purpose is for gathering language statistics across
  # the entire project.
  class Repository

    @repository : Git::Repository
    @commit_oid : Git::Oid | String
    @old_commit_oid : Git::Oid | String
    @old_stats : Hash(String, Array(Int32 | Int64 | Language | Nil)) | Nil
    @cache : Hash(String, Array(Int32 | Int64 | Language | Nil)) | Nil
    @tree : Git::Tree | Nil
    @size : Int32 | Nil
    @detector : Detector | Nil

    # Public: Create a new Repository based on the stats of
    # an existing one
    def self.incremental(repo, commit_oid, old_commit_oid, old_stats)
      repo = self.new(repo, commit_oid)
      repo.load_existing_stats(old_commit_oid, old_stats)
      repo
    end

    # Public: Initialize a new Repository to be analyzed for language
    # data
    #
    # repo - a Rugged::Repository object
    # commit_oid - the sha1 of the commit that will be analyzed;
    #              this is usually the master branch
    #
    # Returns a Repository
    def initialize(repo, commit_oid)
      @repository = repo
      @commit_oid = commit_oid
      first_commit = get_first_commit
      @old_commit_oid = first_commit.oid
    end

    def get_first_commit
      walker = Git::RevWalk.new(@repository)
      walker.sorting(Git::Sort::Reverse)
      walker.push_head
      walker.first
    end

    # Public: Load the results of a previous analysis on this repository
    # to speed up the new scan.
    #
    # The new analysis will be performed incrementally as to only take
    # into account the file changes since the last time the repository
    # was scanned
    #
    # old_commit_oid - the sha1 of the commit that was previously analyzed
    # old_stats - the result of the previous analysis, obtained by calling
    #             Repository#cache on the old repository
    #
    # Returns nothing
    def load_existing_stats(old_commit_oid, old_stats)
      @old_commit_oid = old_commit_oid
      @old_stats = old_stats
      nil
    end

    # Public: Returns a breakdown of language stats.
    #
    # Examples
    #
    #   # => { 'Ruby' => 46319,
    #          'JavaScript' => 258 }
    #
    # Returns a Hash of language names and Integer size values.
    def languages
      cache
    end

    # Public: Get primary Language of repository.
    #
    # Returns a language name
    def language
      return @language if @language
      primary = languages.max_by { |(_, size)| size }
      return primary[0] if primary && primary[0]
    end

    # Public: Get the total size of the repository.
    #
    # Returns a byte size Integer
    def size : Int32
      @size ||= languages.try { |l| l.reduce(0) { |s, line | s + line[1].to_i } } || 0
    end

    # Public: Return the language breakdown of this repository by file
    #
    # Returns a map of language names => [filenames...]
    def breakdown_by_file
      @file_breakdown ||= begin
        breakdown = Hash.new { |h, k| h[k] = Array.new }
        cache.try { |c| c.each do |filename, (language, _)|
          breakdown[language] << filename.dup.force_encoding("UTF-8").scrub
        end }
        breakdown
      end
    end

    # Public: Return the cached results of the analysis
    #
    # This is a per-file breakdown that can be passed to other instances
    # of Linguist::Repository to perform incremental scans
    #
    # Returns a map of filename => [language, size]
    def cache
      return @cache if @cache
      @cache = compute_stats(@old_commit_oid, @old_stats)
      @cache
    end

    def detector(blob, name)
      if @detector
        @detector.try {|d| d.set_blob(blob, name) }
        return @detector
      else
        @detector = Detector.new(@repository)
        @detector.try {|d| d.set_blob(blob, name) }
        return @detector
      end
    end

    def current_tree
      @tree ||= Git::Commit.lookup(@repository, @commit_oid).tree
    end

    MAX_TREE_SIZE = 100_000

    def compute_stats(old_commit_oid, cache = nil)
      old_tree = Git::Commit.lookup(@repository, @old_commit_oid).tree
      diff = Git::Diff.tree_to_tree(old_tree, current_tree)

      # Clear file map and fetch full diff if any .gitattributes files are changed
      #if @cache && diff.each_delta.any? { |delta| File.basename(delta.new_file[:path]) == ".gitattributes" }
      #  diff = Git::Diff.tree_to_tree(old_tree = nil, current_tree)
      #  file_map = {} of String => String
      #else
        file_map = cache ? cache.dup : {} of String => Array(Int32 | Int64 | Language | Nil)
      #end

      diff.each_delta do |delta|
        old = delta.old_file.path
        new = delta.new_file.path

        #file_map.delete(old)
        #next if delta.binary

        if delta.added? || delta.modified?
          # Skip submodules and symlinks
          #mode = delta.new_file[:mode]
          #mode_format = (mode & 0170000)
          #next if mode_format == 0120000 || mode_format == 040000 || mode_format == 0160000

          blob = detector(delta.new_file.id, delta.new_file.path.split("/").last)

          if blob.try { |b| b.include_in_language_stats? }
            file_map[new] = [blob.try { |b| b.language }, blob.try { |b| b.size } || 0]
          end

          blob.try {|b| b.finalize }
        end
      end

      file_map
    end
  end
end
