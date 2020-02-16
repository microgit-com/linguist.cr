require "../spec_helper"

describe Linguist::LanguageContainer do
  # TODO: Write tests

  it "save languages" do
    languages = Linguist::LanguageContainer.new
    languages.size.should be > 0
  end

  it "get an language" do
    languages = Linguist::LanguageContainer.new
    lang = languages["Ruby"]
    lang.name.should eq("Ruby")
  end

  it "find an language by extension" do
    languages = Linguist::LanguageContainer.new
    lang = languages.find_by_extension("language.cr")
    lang.size.should be > 0
    lang.first.name.should eq("Crystal")
  end

  it "find an language by filename" do
    languages = Linguist::LanguageContainer.new
    lang = languages.find_by_filename("Dockerfile")
    lang.size.should be > 0
    lang.first.name.should eq("Dockerfile")
  end
end
