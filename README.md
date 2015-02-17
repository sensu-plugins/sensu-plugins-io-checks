## Sensu-Plugins-io-checks

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-io-checks.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-io-checks)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-io-checks.svg)](http://badge.fury.io/rb/sensu-plugins-io-checks)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-io-checks/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-io-checks)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-io-checks/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-io-checks)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-io-checks.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-io-checks)

## Functionality

## Files
 * bin/metrics-ioping
 * bin/metrics-iostat-extended

## Usage

## Installation

Add the public key (if you haven’t already) as a trusted certificate

```
gem cert --add <(curl -Ls https://raw.githubusercontent.com/sensu-plugins/sensu-plugins.github.io/master/certs/sensu-plugins.pem)
gem install sensu-plugins-io-checks -P MediumSecurity
```

You can also download the key from /certs/ within each repository.

#### Rubygems

`gem install sensu-plugins-io-checks`

#### Bundler

Add *sensu-plugins-disk-checks* to your Gemfile and run `bundle install` or `bundle update`

#### Chef

Using the Sensu **sensu_gem** LWRP
```
sensu_gem 'sensu-plugins-io-checks' do
  options('--prerelease')
  version '0.0.1'
end
```

Using the Chef **gem_package** resource
```
gem_package 'sensu-plugins-io-checks' do
  options('--prerelease')
  version '0.0.1'
end
```

## Notes
