require "./src/linguist.cr"
require "git"
require "logger"

repo = Git::Repository.open("../microgit.cr")
linguist = Linguist::Linguist.new
linguist.with_repo(repo, repo.head.target_id)

logger = Logger.new(STDOUT)

langs = linguist.languages

logger.info langs
