source :rubygems

if ENV['RAILS_SOURCE']
  rails_source = path ENV['RAILS_SOURCE']
else
  rails_source = git "git://github.com/rails/rails.git"
end

gem "actionpack", :source => rails_source
gem "rspec"