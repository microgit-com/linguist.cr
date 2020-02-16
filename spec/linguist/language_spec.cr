require "../spec_helper"

describe Linguist::LanguageContainer do
  # TODO: Write tests

  it "save language" do
    language = Linguist::Language.create_from_file.first
    language.name.should eq("1C Enterprise")
  end
end
