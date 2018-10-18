# Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed at [Keep A Changelog](http://keepachangelog.com/)

## [Unreleased]
### Added
- ruby 2.4 testing (@majormoses)
### Fixed
- [iostat] Changes ouput in device session from 'Device:' to 'Device'. Fix issue  #12 (@dmichelotto)

## [1.0.1] - 2017-0702
### Fixed
- [ioping](https://github.com/koct9i/ioping) is switching to nanosecond precision - added 'ns' to metrics-ioping.rb (@MattMencel)

## [1.0.0] - 2016-06-20
### Added
- rspec test cases for metrics-iostat-extended
- add proper device node handling for exclude-disk filtering

### Fixed
- fix an ordering issue on exclude-disk filtering
- fix locale bug when calling iostat on non en_us systems

### Changed
- use open3 instead of backticks for proper call to iostat
- filter exclude-disk in ruby code instead of shell grepping
- do not pass any environment vars from sensu to iostat call
- Update to Rubocop 0.40, apply auto-correct
- Remove Ruby 1.9.3 support; add Ruby 2.3.0 support to test matrix

## [0.0.3] - 2015-10-15
### Changed
- add shift to the output to make it more readable

## [0.0.2] - 2015-07-14
### Changed
- updated sensu-plugin gem to 1.2.0

## 0.0.1 - 2015-06-04
### Added
- initial release

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-io-checks/compare/1.0.1...HEAD
[1.0.1]: https://github.com/sensu-plugins/sensu-plugins-io-checks/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/sensu-plugins/sensu-plugins-io-checks/compare/0.0.3...1.0.0
[0.0.3]: https://github.com/sensu-plugins/sensu-plugins-io-checks/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/sensu-plugins/sensu-plugins-io-checks/compare/0.0.1...0.0.2
