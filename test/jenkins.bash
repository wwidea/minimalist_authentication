#!/bin/bash
bundle install

cd test/rails_root
bundle exec rake db:setup
bundle exec rake db:test:prepare

cd ../../
rake test