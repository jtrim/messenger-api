# Messenger API

[![jtrim](https://circleci.com/gh/jtrim/messenger-api.svg?style=shield)](https://circleci.com/gh/jtrim/messenger-api)

This application is a simple messenger API that allows logging messages between two users of the system.

[You can find this application deployed to Heroku](https://jtrim-messenger-api.herokuapp.com/api/docs) if you would prefer to interact with a web-accessible version of the application.

See below for setup instructions.

# Notes

This application is housed within a standard Rails application. You'll see some config files around that might not make sense
since this is an API application (i.e. yarn.lock, babel.config.js, node_modules, etc), but I left them in place just in
case there's a need to build some kind of UI on top of this project later.

All notable code files are under `app`, and everything else is configuration or Rails boilerplate. Significant code files are **bolded**.

- app/controllers
  - **api/v1/messages_controller.rb**
    - The handler for the /api/v1/messages endpoint
- app/models
  - **message.rb**
    - Query methods, validations, and relation configuration for the Message model
  - user.rb
    - Validations and relation configuration for the User model
- app/serializers
  - **base_serializer.rb**
    - The base class for serialization. Defines a small API for declaring attributes and overriding methods. There are
      some features in this file that are currently unused, but are features that I've found very helpful in building
      APIs (notably, the `:include` option, which can help with performance by reducing payload size).

      As an aside, I think this file has the most room for improvement. It's doing some clever things, isn't the most
      readable, and it has no unit tests.
  - **message_serializer.rb**
    - The serializer responsible for building the JSON payload for the messages API.
  - user_serializer.rb
    - Serializes user records embedded in a message response
  - unprocessable_entity_serializer.rb
    - In cases where the API renders a 422, this serializer is used to render error messages in a predictable format
- app/services
  - **message_service/create.rb**
    - Responsible for creating messages, and will also create the sender and recipient by username if they don't already
      exist in the system.

      As an aside, I'm a big fan of service objects (aka use-case objects, domain objects, actors, interactors,
      etc) when an atomic operation has more than one step.

Not used (but left in place just in case):
- app/assets
- app/channels
- app/helpers
- app/javascript
- app/jobs
- app/mailers
- app/views

# Setup

These setup instructions assume that you have Ruby installed, and that it does not require `sudo` to install
dependencies. If you need to install Ruby, my personal favorite ruby management utilities are
https://github.com/postmodern/chruby and https://github.com/postmodern/ruby-install.

This application assumes Ruby version 2.5.3. You'll also need to have a PostgreSQL database server running. The database
configuration assumes a postgres user with the same name as your system username (`$ whoami`) and no password, but you can tweak
config/database.yml if you need different settings.

The following command should install all dependencies, create your development and test databases and seed the dev
database.

```shell
$ bin/setup
```

You should see some output that looks something like:

```text
== Installing dependencies ==
The Gemfile's dependencies are satisfied

== Preparing database ==
Created database 'messenger_api_development'
Created database 'messenger_api_test'
Seeding users
Seeding messages

== Running specs ==

Messages
  GET /api/v1/messages
    Listing messages for all users
    - Limits messages to 100
    - Limits messages to those created in the last 30 days
    When requesting messages for a specific sender
      Listing messages for a specific sender
    When requesting messages for a specific recipient
      Listing messages for a specific recipient
    When requesting messages for a specific conversation
      Listing messages for a specific conversation
      - Limits messages to 100
      - Limits messages to the last 30 days
  POST /api/v1/messages
    When the user ids are known
      Creating a message in a conversation between two users
    When the user ids are not known
      Creating a message between two usernames
      When users already exist by the given usernames
        - It finds existing users
    With invalid attributes
      Attempting to create a message with invalid attributes
  PUT /api/v1/messages/:id
    When marking a message as read
      Updating a message's "read" status

Finished in 1.79 seconds (files took 4.33 seconds to load)
13 examples, 0 failures


Now, to start an application server on port 3000:

    $ bundle exec rails s

Here's an example cURL command to get you started:

    $ curl --header 'Accept: application/json' http://localhost:3000/api/v1/messages

API Documentation can be accessed at http://localhost:3000/api/docs
If you would like to run the tests again:

    $ bundle exec rspec spec --format=doc

If you need to regenerate the api documentation for any reason:

    $ bundle exec rake docs:generate

Enjoy! ❀
```
