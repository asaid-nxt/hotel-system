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
- [Contributing](#contributing)
- [License](#license)

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
   git clone https://github.com/username/hotel-reservation-api.git
   cd hotel-reservation-api

2. Install dependencies:
   ```bash
   bundle install

3. Set up the database:
   ```bash
   rails db:create
   rails db:migrate

4. Set up environment variables (see #Environment Variables)

5. Start the server:
   ```bash
   rails s


## Environment Variables
The following environment variables should be set:

- **JWT_SECRET_KEY**: Secret key for encoding and decoding JWT tokens.
- **AWS_ACCESS_KEY_ID (Optional)**: AWS access key for image storage.
- **AWS_SECRET_ACCESS_KEY (Optional)**: AWS secret key.
- **AWS_BUCKET (Optional)**: AWS S3 bucket name for storing images.


## Usage

### Authentication

This API uses JWT for authentication. You'll need to authenticate and receive a token to access protected endpoints.