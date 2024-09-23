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
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Set up the database:
   ```bash
   rails db:create
   rails db:migrate
   ```

4. Set up environment variables (see [Environment Variables](#environment-variables)).

5. Start the server:
   ```bash
   rails s
   ```


## Environment Variables
The following environment variables should be set:

- `JWT_SECRET_KEY`: Secret key for encoding and decoding JWT tokens.
- `AWS_ACCESS_KEY_ID (Optional)`: AWS access key for image storage.
- `AWS_SECRET_ACCESS_KEY (Optional)`: AWS secret key.
- `AWS_BUCKET (Optional)`: AWS S3 bucket name for storing images.


## Usage

### Authentication

This API uses JWT for authentication. You'll need to authenticate and receive a token to access protected endpoints.

- **Register a new user**:
  - Endpoint: `POST /api/v1/signup`
  - Example request body:
    ```json
    {
      "username": "example_user",
      "password": "password123"
    }
    ```

- **Login**:
  - Endpoint: `POST /api/v1/login`
  - Example response:
    ```json
    {
      "token": "your_jwt_token"
    }
    ```

- **Use JWT Token**:
  - Include the token in the `Authorization` header for protected routes:
    ```bash
    Authorization: Bearer your_jwt_token
    ```

## Endpoints

### User Endpoints

1. **Register a new user**:
   - **Endpoint**: `POST /api/v1/signup`
   - **Description**: Creates a new user account.

2. **Login**:
   - **Endpoint**: `POST /api/v1/login`
   - **Description**: Authenticates a user and returns a JWT token.

3. **View User's Reservations**:
   - **Endpoint**: `GET /api/v1/reservations/all`
   - **Description**: Retrieves all reservations for the authenticated user.

---

### Hotel Endpoints

1. **Create a Hotel**:
   - **Endpoint**: `POST /api/v1/hotels`
   - **Description**: Creates a new hotel.

2. **Update a Hotel**:
   - **Endpoint**: `PUT /api/v1/hotels/:id`
   - **Description**: Updates the details of an existing hotel.

3. **Delete a Hotel**:
   - **Endpoint**: `DELETE /api/v1/hotels/:id`
   - **Description**: Deletes a specified hotel.

---

### Room Endpoints

1. **Create a Room**:
   - **Endpoint**: `POST /api/v1/hotels/:hotel_id/rooms`
   - **Description**: Creates a new room in a specified hotel.

2. **Update a Room**:
   - **Endpoint**: `PUT /api/v1/hotels/:hotel_id/rooms/:id`
   - **Description**: Updates the details of an existing room.

3. **Delete a Room**:
   - **Endpoint**: `DELETE /api/v1/hotels/:hotel_id/rooms/:id`
   - **Description**: Deletes a specified room.

4. **View Available Rooms**:
   - **Endpoint**: `GET /api/v1/hotels/:hotel_id/rooms/available`
   - **Description**: Retrieves available rooms for a specified date range.

---

### Reservation Endpoints

1. **Create a Reservation**:
   - **Endpoint**: `POST /api/v1/hotels/:hotel_id/rooms/:room_id/reservations`
   - **Description**: Creates a reservation for a specified room.

## Testing

To run the test suite:
```bash
rspec
```
