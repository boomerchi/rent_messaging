clazz = LocatableProperty

Mongoid.purge!

clazz.delete_all

puts "Seeding data..."

number = 5

Mongoid.logger.level = Logger::DEBUG
Moped.logger.level = Logger::DEBUG

number.times do
  create :valid_locatable_property
  # create :valid_searchable_room
  # create :valid_searchable_property
end

puts "Creating indexes"
Mongoid::Indexing.create_indexes

puts clazz.all.to_a.first.to_s
puts clazz.all.to_a.last.to_s

clazz.all.to_a.map(&:to_s).join("\n\n")

puts "\n#{clazz} COUNT: #{clazz.all.to_a.size}"