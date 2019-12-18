[![Sensu Bonsai Asset](https://img.shields.io/badge/Bonsai-Download%20Me-brightgreen.svg?colorB=89C967&logo=sensu)](https://bonsai.sensu.io/assets/sensu-plugins/sensu-plugins-io-checks)
[ ![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-io-checks.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-io-checks)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-io-checks.svg)](http://badge.fury.io/rb/sensu-plugins-io-checks)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-io-checks/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-io-checks)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-io-checks/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-io-checks)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-io-checks.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-io-checks)

## Sensu Plugins IO Checks Plugin

- [Overview](#overview)
- [Files](#files)
- [Usage examples](#usage-examples)
- [Configuration](#configuration)
  - [Sensu Go](#sensu-go)
    - [Asset registration](#asset-registration)
    - [Asset definition](#asset-definition)
    - [Check definition](#check-definition)
  - [Sensu Core](#sensu-core)
    - [Check definition](#check-definition)
- [Installation from source](#installation-from-source)
- [Additional notes](#additional-notes)
- [Contributing](#contributing)

### Overview

This plugin provides native system I/O instrumentation for metrics collection via the system `ioping` utility.

### Files
 * bin/metrics-ioping.rb
 * bin/metrics-iostat-extended.rb
 
**metrics-ioping**
Pushes `ioping` stats into Graphite.

**metrics-iostat-extended**
Collects iostat data for a specified disk or all disks. Output is in Graphite format. 

## Usage examples

### Help

**metrics-ioping.rb**
```
Usage: metrics-ioping.rb (options)
    -C                               Use cached I/O
    -c COUNT                         Stop after count requests
    -d DEVICE|FILE|DIRECTORY         Destination device, file or directory (required)
    -D                               Use direct I/O
    -i INTERVAL                      Interval between requests in seconds
    -n NAME                          Name of the series (required)
    -s, --scheme SCHEME              Metric naming scheme, text to prepend to metric
```

**metrics-iostat-extended.rb**
```
Usage: metrics-iostat-extended.rb (options)
    -d, --disk DISK                  Disk to gather stats for
    -x, --exclude-disk DISK[,DISK]   List of disks to exclude
    -i, --interval SECONDS           Period over which statistics are calculated (in seconds)
    -N, --show-dm-names              Display the registered device mapper names for any device mapper devices.  Useful for viewing LVM2 statistics
        --scheme SCHEME              Metric naming scheme, text to prepend to .$parent.$child
```

## Configuration
### Sensu Go
#### Asset registration

Assets are the best way to make use of this plugin. If you're not using an asset, please consider doing so! If you're using sensuctl 5.13 or later, you can use the following command to add the asset: 

`sensuctl asset add sensu-plugins/sensu-plugins-io-checks`

If you're using an earlier version of sensuctl, you can download the asset definition from [this project's Bonsai asset index page](https://bonsai.sensu.io/assets/sensu-plugins/sensu-plugins-io-checks).

#### Asset definition

```yaml
---
type: Asset
api_version: core/v2
metadata:
  name: sensu-plugins-io-checks
spec:
  url: https://assets.bonsai.sensu.io/60e1713ecd4f0d2e38aada33b15d41580e716048/sensu-plugins-io-checks_2.0.0_centos_linux_amd64.tar.gz
  sha512: de5f81305652edf93f459831a4a8d492207eb65120f28d249db7697c5dc1925e90d1483c6c46d70f3a48e530e62c1c3170d01c33b9e0d663081dffea52ff7bed
```

#### Check definition

```yaml
---
type: CheckConfig
api_version: core/v2
metadata:
  name: metrics-ioping
  namespace: default
spec:
  check_hooks: null
  command: metrics-ioping.rb -exporter-url http://localhost:8080/metrics
  output_metric_format: graphite
  output_metric_handlers:
  - graphite
  runtime_assets:
  - sensu/sensu-plugins-io-checks
  - sensu/sensu-ruby-runtime
  stdin: false
  subdue: null
  subscriptions:
  - linux
  timeout: 5
  ttl: 0
```

### Sensu Core

#### Check definition
```json
{
  "checks": {
    "metrics-ioping": {
      "type": "metric",
      "command": "metrics-ioping.rb -exporter-url http://localhost:8080/metrics",
      "subscribers": ["app_tier"],
      "interval": 10,
      "handler": "graphite"
    }
  }
}
```

## Installation from source

### Sensu Go

See the instructions above for [asset registration](#asset-registration).

### Sensu Core

Install and setup plugins on [Sensu Core](https://docs.sensu.io/sensu-core/latest/installation/installing-plugins/).

## Additional notes

### Sensu Go Ruby Runtime Assets

The Sensu assets packaged from this repository are built against the Sensu Ruby runtime environment. When using these assets as part of a Sensu Go resource (check, mutator, or handler), make sure to include the corresponding [Sensu Ruby Runtime Asset](https://bonsai.sensu.io/assets/sensu/sensu-ruby-runtime) in the list of assets needed by the resource.

## Contributing

See [CONTRIBUTING.md](https://github.com/sensu-plugins/sensu-plugins-io-checks/blob/master/CONTRIBUTING.md) for information about contributing to this plugin.
