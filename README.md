# Hotel System API

This is a Rails 7 API for managing hotels. It includes functionality for users to make reservations and view available rooms, as well as admin actions to manage hotels, rooms, and reservations. The API uses JWT-based authentication.

## Table of Contents

- [Features](#features)
- [Technologies Used](#technologies-used)
- [Installation](#installation)
- [Environment Variables](#environment-variables)
- [Usage](#usage)
  - [Authentication](#authentication)
  - [Endpoints](#endpoints)
    - [User Endpoints](#user-endpoints)
    - [Admin Endpoints](#admin-endpoints)
- [Testing](#testing)


## Features

- **User actions**:
  - View available rooms for a specified date range.
  - Create a new reservation for a room.
  - View user's own reservations.

- **Admin actions**:
  - Create, update, and delete hotels and rooms.
  - View all reservations in the system.
  
- **JWT Authentication**:
  - Secure login system for both users and admins using JSON Web Tokens (JWT).
  - Tokens are required for accessing protected resources.

## Technologies Used

- **Ruby on Rails 7** - The web framework used for developing the API.
- **SQLite** - The database management system.
- **JWT** - Used for securing user authentication.
- **ActiveModelSerializers** - For formatting the JSON responses.
- **AWS** (Optional) - For managing images of hotels and rooms.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/username/hotel-system.git
   cd hotel-system

2. Install dependencies:
   ```bash
   bundle install

3. Set up the database:
   ```bash
   rails db:create
   rails db:migrate

4. Set up environment variables (#environment-variables)

5. Start the server:
   ```bash
   rails s


## Environment Variables
The following environment variables should be set:

- `JWT_SECRET_KEY`: Secret key for encoding and decoding JWT tokens.
- `AWS_ACCESS_KEY_ID (Optional)`: AWS access key for image storage.
- `AWS_SECRET_ACCESS_KEY (Optional)`: AWS secret key.
- `AWS_BUCKET (Optional)`: AWS S3 bucket name for storing images.


## Usage

### Authentication

This API uses JWT for authentication. You'll need to authenticate and receive a token to access protected endpoints.

1. **Register a new user:**

- Endpoint: `POST /api/v1/users`
- Example request body:
  ```json
  {
  "username": "example_user",
  "password": "password123"
  }

2. **Login:**

- Endpoint: `POST /api/v1/login`
- Example response:
  ```json
  {
  "token": "your_jwt_token"
  }

3. **Use JWT Token:**

- Include the token in the `Authorization` header for protected routes:
  ```bash
  Authorization: Bearer your_jwt_token

## Endpoints

### User Endpoints

1. **View Available Rooms:**

- Endpoint: `GET /api/v1/rooms/available`
- Query Parameters: `check_in`, `check_out`
- Example:
  ```bash
  GET /api/v1/rooms/available?check_in=2024-09-30&check_out=2024-10-05

2. **Create Reservation:**

- Endpoint: `POST /api/v1/reservations`
- Example request body:
  ```json
  {
  "room_id": 1,
  "check_in": "2024-09-30",
  "check_out": "2024-10-05"
  }

3. **View User's Reservations:**

- Endpoint: GET /api/v1/reservations
- Example
  ```bash
  GET /api/v1/reservations

**Admin Endpoints**

1. **Create Hotel**:

- Endpoint: `POST /api/v1/admin/hotels`
- Example request body:
  ```json
  {
  "name": "Luxury Hotel",
  "location": "New York",
  "rating": 5
  }

2. **Update Room**:

- Endpoint: `PUT /api/v1/admin/rooms/:id`
- Example request body:
  ```json
  {
  "name": "Suite",
  "price": 200,
  "available": true
  }

3. **View All Reservations**:

- Endpoint: `GET /api/v1/admin/reservations`
- Example:
  ```bash
  GET /api/v1/admin/reservations

## Testing

To run the test suite:
```bash
rspec

  









  







  
