clazz = SearchableProperty

Mongoid.purge!

clazz.delete_all

puts "Seeding data for #{clazz}"

number = 100

Mongoid.logger.level = Logger::DEBUG
Moped.logger.level = Logger::DEBUG

number.times do
  # create :valid_searchable_room
  create :valid_searchable_property
end


puts "Creating indexes"
Mongoid::Indexing.create_indexes

first_property = clazz.all.to_a.first

puts "=" * 20
puts first_property
puts "-" * 20

puts "Show for url: #{first_property.url} "

# clazz.all.to_a.map(&:to_s).join("\n\n")

puts "\n#{clazz} COUNT: #{clazz.all.to_a.size}"