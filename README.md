# Children Race Heats

A Ruby on Rails application for managing children's race heats and tracking results.

## System Requirements

* Ruby version: 3.1.1
* Database: PostgreSQL
* Rails version: 7.2.2

## Setup

1. Clone the repository
2. Install dependencies:
```bash
bundle install
```

3. Setup the database:
```bash
bin/rails db:create db:migrate db:seed
```

4. Start the server:
```bash
bin/dev
```

## Features

- Create and manage race heats
- Assign students to race lanes
- Submit and track race results
- View race history and standings

## Testing

The application uses RSpec for testing. To run the test suite:

```bash
bundle exec rspec
```

Test coverage reports are generated using SimpleCov and can be found in the `coverage` directory after running the tests.

## Development Tools

- **Tailwind CSS**: For styling
- **RSpec**: Testing framework
- **Factory Bot**: Test data generation
- **SimpleCov**: Test coverage reporting

