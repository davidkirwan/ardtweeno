killall java
bundle install --path vendor/bundle
mkdir -p tmp/puma
bundle exec puma --config resources/puma.rb
