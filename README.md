# dropsuite-test
repository for dropsuite-test


### dependencies:
* [ruby](https://www.ruby-lang.org/en/)
* [rethinkdb](https://www.rethinkdb.com/)


### Getting Started
* make sure you already have ruby installed (tested on ruby 2.5.0)
* install & run [rethinkdb](https://www.rethinkdb.com/docs/install/)
* install rethinkdb gem
```
gem install rethinkdb
```
* clone the app
```
git clone git@github.com:metalkoholic/dropsuite-test.git
```
* point to root app folder
```
cd dropsuite-test
```
* modify config/database.yml to suit your rethinkdb configuration
* run the app
```
ruby file_match.rb your_target_directory
```
