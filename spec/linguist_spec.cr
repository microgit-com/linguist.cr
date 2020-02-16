require "./spec_helper"
require "./linguist/*"

describe Linguist::Linguist do
  it "get this repo's data" do
    repo = Git::Repository.open(".")
    linguist = Linguist::Linguist.new
    linguist.with_repo(repo, repo.head.target_id)
    langs = linguist.languages
    langs.size.should be > 0
  end
end
