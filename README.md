# Sleep Tracker API

A Rails API application for tracking sleep patterns and seeing sleep records from followed users.

## Features

- Clock in when going to bed and clock out when waking up
- Follow/unfollow other users
- View sleep records of followed users from the previous week, sorted by sleep duration
- Auto-completion of sleep records after 12 hours if users forget to clock out, the clock out time will be set based on the average of the previous 30 days of completed sleep records
- Pagination for all list endpoints
- API versioning

## Technology Stack

- Ruby 3.2.2
- Ruby on Rails 7.0 (API only)
- PostgreSQL
- Redis
- Sidekiq for background processing
- RSpec for testing

## Setup

1. Clone the repository, and enter the directory
2. Make sure you have Ruby 3.2.2 and Rails 7.0 installed
3. Set environment variables (`.env`)
3. Run the following commands:

```bash
bundle install
rails db:create db:migrate
rails s
```

The API will be available at `http://localhost:3000`

Sidekiq dashboard will be available at `http://localhost:3000/sidekiq`

## API Endpoints

### Sleep Records

- `POST /api/v1/users/:user_id/sleep_records/clock_in` - Clock in when going to bed
- `PATCH /api/v1/users/:user_id/sleep_records/:id/clock_out` - Clock out when waking up
- `GET /api/v1/users/:user_id/sleep_records` - Get all sleep records for a user
- `GET /api/v1/users/:user_id/following_sleep_records` - Get sleep records from followed users

### Following

- `POST /api/v1/users/:user_id/follow` - Follow another user
- `DELETE /api/v1/users/:user_id/unfollow` - Unfollow a user
- `GET /api/v1/users/:user_id/following` - Get list of users being followed
- `GET /api/v1/users/:user_id/followers` - Get list of followers

## Design Decisions

### Database Design

- **Users**: Simple model with just id and name
- **SleepRecords**: Tracks clock_in, clock_out, duration, and status
- **Followings**: Self-referential join table for user following relationships

### Edge Cases Handled

- Preventing multiple active sleep records per user
- Validating clock_out time is after clock_in time
- Auto-completing sleep records if users forget to clock out
- Preventing duplicate following relationships

### Scalability Considerations

- **Indexes**: Added on frequently queried columns
- **Pagination**: Implemented on all list endpoints
- **Background Processing**: Used for auto-completion of sleep records
- **API Versioning**: Allows for future API changes without breaking existing clients

## Running Tests

```bash
bin/rspec spec/
```
