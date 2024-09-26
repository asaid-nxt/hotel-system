# frozen_string_literal: true

# Clear existing data
User.destroy_all
Hotel.destroy_all
Room.destroy_all
Reservation.destroy_all

# Reset primary keys (SQLite)
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='users';")
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='rooms';")
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='hotels';")
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='reservations';")

# Create users
users = User.create!(
  [
    { username: 'admin', password: 'password', role: 1, first_name: 'admin' },
    { username: 'test', password: 'password', role: 0, first_name: 'John', last_name: 'Wick',
      preferences: 'Gym, Pool' },
    { username: 'test1', password: 'password', role: 0, first_name: 'Harry', last_name: 'Potter',
      preferences: 'Tennis Court' }
  ]
)

# Attach images to users
users[1].image.attach(io: File.open('/mnt/c/Users/a_sae/OneDrive/Pictures/john-wick.jpg'), filename: 'john-wick.jpg',
                      content_type: 'image/jpeg')
users[2].image.attach(io: File.open('/mnt/c/Users/a_sae/OneDrive/Pictures/harry-potter.jpg'),
                      filename: 'harry-potter.jpg', content_type: 'image/jpeg')

# Create hotels
hotels = Hotel.create!(
  [
    { name: 'The Grand Hotel', location: 'New York', amenities: 'Pool, Gym, Free Wi-Fi' },
    { name: 'Ocean Breeze Resort', location: 'Miami', amenities: 'Beach access, Spa, Pool' }
  ]
)

# Create rooms
rooms = Room.create!(
  [
    { number: '101', capacity: 2, amenities: 'Air Conditioning, TV', hotel_id: hotels[0].id },
    { number: '102', capacity: 4, amenities: 'Mini-bar, Ocean View', hotel_id: hotels[0].id },
    { number: '201', capacity: 3, amenities: 'Balcony, Free Breakfast', hotel_id: hotels[1].id },
    { number: '202', capacity: 2, amenities: 'Private Pool, King Bed', hotel_id: hotels[1].id }
  ]
)

# Create reservations for users
Reservation.create!(
  [
    { user_id: users[1].id, room_id: rooms[0].id, check_in: Date.today, check_out: Date.today + 3 },
    { user_id: users[2].id, room_id: rooms[2].id, check_in: Date.today + 1, check_out: Date.today + 4 }
  ]
)

puts 'Database seeded successfully!'
