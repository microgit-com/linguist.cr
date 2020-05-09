# linguist.cr

Github's linguist but in crystal.

Linguist will use different ways to find what type of programming language every file is, which can be used for stats or for highlights.

We only have classifier mapping now but support languages.yml-format and samples format from Github's linguist. Hopefully soon we will add the rest, like Heuristics and shebang filtering support.

We can not promise that the loaded data in `./data` is up to date. So if you want to be sure, let's train it again with overwrite set to `true`.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     linguist.cr:
       github: microgit-com/linguist.cr
   ```

2. Run `shards install`

## Usage

```crystal
require "linguist"
```

Set path to the languages.yml if it is not working like this:
```crystal
Linguist.configure do |settings|
  settings.path = "./config/linguist/languages.yml"
end
```

The languages.yml can be found in the git repo of this or a more up to date one on github's linguist repo at https://github.com/github/linguist

### Using repository

```crystal
repo = Git::Repository.open("./")
linguist = Linguist::Linguist.new
linguist.with_repo(repo, repo.head.target_id)

logger = Logger.new(STDOUT)

langs = linguist.languages

logger.info langs
```

## Development

We have this todo:
- [x] Repository blob support
- [x] Classifier
- [ ] Heuristics support
- [ ] Shebang filter support
- [ ] simple file checkup.

## Contributing

1. Fork it (<https://github.com/microgit-com/linguist.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Håkan Nylén](https://github.com/confact) - creator and maintainer
