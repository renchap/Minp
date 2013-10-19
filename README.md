Minp
====

Web-based shared mind mapping app, powered by Rails/Redis/Websockets.

This app is a work in progress and not yet in a usable state.

GitHub project: https://github.com/renchap/Minp

Dependancies
====

To run Mimp, you need : 
- A recent Ruby version (1.9.3 at least)
- The bundler gem installed

Install
====
```
# Clone the source code
$ git clone https://github.com/renchap/Minp.git
$ cd Minp
# Install gem dependancies
$ bundle
# Create and initialize the database
$ rake db:migrate
# Generate your secret token
$ echo "Minp::Application.config.secret_key_base = '`rake secret`'" > config/initializers/secret_token.rb
# Start a local server
$ rails server
```

Contribute
====
To send patches, fork this project on GitHub and send a pull request.
