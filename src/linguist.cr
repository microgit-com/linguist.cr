require "./linguist/repository"
require "./linguist/strategy/extension"
require "./linguist/strategy/filename"
require "./linguist/strategy/manpage"
require "git"

module Linguist
  STRATEGIES = [
    Strategy::Filename,
    Strategy::Extension,
    Strategy::Manpage,
    Classifier,
  ]
  class Linguist
    property :repository

    def with_repo(repo : Git::Repository, commit_oid : Git::Oid | String)
      @repository = Repository.new(repo, commit_oid)
    end

    def language
      @repository.language? || ""
    end

    def languages
      @repository.try {|r| r.languages } || ""
    end

    def find

    end
  end
end
