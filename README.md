# Maintenance Log

The Maintenance Log is a web application built with Sinatra, designed to help you manage maintenance requests and service records for equipment assemblies and individual equipment pieces (entities). It allows users to log in, create maintenance requests, and record service information.

## Features

- User authentication for secure login.
- Management of assemblies, entities, maintenance requests, and service records.
- Categorization of maintenance requests and service records with types.
- Easily deployed on Heroku using bundle and Rake.

## Table Structure

The app contains the following database tables:

- `users`: Stores user information for authentication. Each user can have multiple logs and multiple access keys.
- `logs`: Created by a user to track services on a particular group of equipment. Can be shared by `keys`.
- `keys`: Required to gain access to a log, if you are not the log owner.
- `assemblies`: Belongs to a log and stores general equipment descriptions, including manufacturer, model, and equipment description.
- `entities`: Representes each invidual piece of equipment from an assembly. Stores serial numbers and descriptions related to the use of that equipment within the process.
- `request_records`: Contains maintenance request information and belongs to an `entity`.
- `request_types`: Categorizes maintenance requests.
- `service_records`: Contains service record information and belongs to a `request_record`.
- `service_types`: Categorizes service records.

## Development Setup

To run this app locally, follow these steps:

1. Clone the repository: `git clone https://github.com/your-username/maintenance-log.git`
2. Change into the project directory: `cd maintenance-log`
3. Install dependencies: `bundle install`
4. Set up your database and tables: `rake db:create` (create the database)
5. Run database migrations: `rake db:migrate`
6. Start the app: `bundle exec rackup`

## Usage

1. Sign up for an account or log in if you already have one.
2. Create assemblies and entities to represent the equipment you want to track.
3. Log maintenance requests specifying the type of request.
4. Record service information and closing date when maintenance is completed.

