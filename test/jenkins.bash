#!/bin/bash
cd test/rails_root
bundle install
bundle exec rake db:setup
bundle exec rake db:test:prepare

cd ../../
rake test