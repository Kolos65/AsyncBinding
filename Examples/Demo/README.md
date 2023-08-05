# AsyncBindingDemo
## Setting up development environment
- Install rbenv `https://github.com/rbenv/rbenv#installation`
- Use ruby 2.6.2 with rbenv
- Install bundler `gem install bundler:2.2.4`
- Install homebrew  `/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`
- Run `bundle install`
- Run `brew bundle`
- Edit `.env.defaults` (or create a .env file) under the `fastlane` folder and set a unique bundle id and valid development team id
- Run `bundle exec fastlane generate_project`
- Open the workspace in Xcode and build it