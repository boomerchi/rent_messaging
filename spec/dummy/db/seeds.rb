require 'factory_girl'
require 'ffaker'

# load factories
Dir["#{File.dirname(__FILE__)}/../../support/**/*.rb"].each do |f| 
  # puts "path: #{f}"
  require f
end

include FactoryGirl::Syntax::Methods

$:.unshift File.dirname(__FILE__)

clazz = SearchableProperty
# clazz = Property

# require 'seeds/locatable_seeds'
require "seeds/#{clazz.to_s.underscore}_seeds"

User.create name: 'Alex'
User.create name: 'Scarlett'
User.create name: 'Kris'

# article = Article.create title: 'hello you'
# comment = Comment.create subject: 'nice one', article: article

# puts article.inspect
# puts comment.inspect
