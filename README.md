Minp
====

[![Code Climate](https://codeclimate.com/github/renchap/Minp.png)](https://codeclimate.com/github/renchap/Minp)

Web-based shared mind mapping app, powered by Rails/Redis/Websockets/D3.js.

This app is a work in progress and not yet in a usable state.

GitHub project: https://github.com/renchap/Minp

## Dependancies

To run Mimp, you need : 
- A recent Ruby version (1.9.3 at least)
- The bundler gem installed

## Install

### Development
To install Minp on your workstation, in development mode
```
# Clone the source code
$ git clone https://github.com/renchap/Minp.git
$ cd Minp
# Install gem dependancies
$ bundle
# Create and initialize the database
$ rake db:migrate
# Generate your secret token
$ echo "Minp::Application.config.secret_key_base = '`bundle exec rake secret`'" > config/initializers/secret_token.rb
# Start a local server
$ rails server
```

You can now access http://localhost:3000/ and start browsing.


### Production

Not ready for production yet !

## Importing projects

### Subtask.com

First, export your project on subtask.com using the export button on the bottom of the window.
Choose JSON as the export format.

Copy the JSON file to the computer where you installed Minp, then import it
```
$ cd Minp
$ bundle exec rake "import:subtask[path/to/project.json]"
```

You should now see your project on the webpage.

## Contribute

To send patches, fork this project on GitHub and send a pull request.
