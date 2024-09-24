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
User.create!([
               { username: 'admin', password: 'password', role: 1, first_name: 'admin' },
               { username: 'test', password: 'password', role: 0, first_name: 'John', last_name: 'Wick',
                 preferences: 'Gym, Pool' },
               { username: 'test1', password: 'password', role: 0, first_name: 'Harry', last_name: 'Potter',
                 preferences: 'Tennis Court' }
             ])

# Create hotels
hotels = Hotel.create!([
                         { name: 'The Grand Hotel', location: 'New York', amenities: 'Pool, Gym, Free Wi-Fi' },
                         { name: 'Ocean Breeze Resort', location: 'Miami', amenities: 'Beach access, Spa, Pool' }
                       ])

# Create rooms
Room.create!([
               { number: '101', capacity: 2, amenities: 'Air Conditioning, TV', hotel_id: hotels[0].id },
               { number: '102', capacity: 4, amenities: 'Mini-bar, Ocean View', hotel_id: hotels[0].id },
               { number: '201', capacity: 3, amenities: 'Balcony, Free Breakfast', hotel_id: hotels[1].id },
               { number: '202', capacity: 2, amenities: 'Private Pool, King Bed', hotel_id: hotels[1].id }
             ])

puts 'Database seeded successfully!'
