require "./linguist/repository"
require "./linguist/strategy/extension"
require "./linguist/strategy/filename"
require "./linguist/strategy/manpage"
require "./linguist/strategy/classifier"
require "git"
require "habitat"

module Linguist
  STRATEGIES = [
    Strategy::Filename,
    Strategy::Extension,
    Strategy::Manpage,
    Strategy::Classifier,
  ]

  Habitat.create do
    setting path : String = [__DIR__, "linguist/languages.yml"].join("/")
  end

  class Linguist
    property :repository

    def with_repo(repo : Git::Repository, commit_oid : Git::Oid | String)
      @repository = Repository.new(repo, commit_oid)
    end

    def language
      @repository.try {|r| r.language } || ""
    end

    def languages
      @repository.try {|r| r.languages } || ""
    end
  end
end
