#! /usr/bin/env ruby
#  encoding: UTF-8
#
#   metrics-iostat-extended
#
# DESCRIPTION:
#   This plugin collects iostat data for a specified disk or all disks.
#   Output is in Graphite format. See `man iostat` for detailed
#   explaination of each field.
#
# OUTPUT:
#   metric data
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: socket
#
# USAGE:
#   Collect metrics for all disks
#   metrics-iostat-extended.rb
#
#   Collect metrics for /dev/sda for 3 seconds
#   metrics-iostat-extended.rb -d /dev/sda -i 3
#
# NOTES:
#   The iostat command must be installed. On Debian/Redhat systems
#   iostat is part of the sysstat package.
#
# LICENSE:
#   Peter Fern <ruby@0xc0dedbad.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/metric/cli'
require 'open3'
require 'socket'

class IOStatExtended < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to .$parent.$child',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.iostat"

  option :disk,
         description: 'Disk to gather stats for',
         short: '-d DISK',
         long: '--disk DISK',
         required: false

  option :excludedisk,
         description: 'List of disks to exclude',
         short: '-x DISK[,DISK]',
         long: '--exclude-disk',
         proc: proc { |a| a.split(',') }

  option :interval,
         description: 'Period over which statistics are calculated (in seconds)',
         short: '-i SECONDS',
         long: '--interval SECONDS',
         default: 1

  option :mappernames,
         description: 'Display the registered device mapper names for any device mapper devices.  Useful for viewing LVM2 statistics',
         short: '-N',
         long: '--show-dm-names',
         boolean: true

  def parse_results(raw)
    stats = {}
    key = nil
    headers = nil
    stage = :initial
    raw.each_line do |line|
      line.chomp!
      next if line.empty?

      case line
      when /^(avg-cpu):/
        stage = :cpu
        key = Regexp.last_match[1]
        headers = line.gsub(/%/, 'pct_').split(/\s+/)
        headers.shift
        next
      when /^(Device).*/
        stage = :device
        headers = line.gsub(/%/, 'pct_').split(/\s+/).map { |h| h.gsub(/\//, '_per_') }
        headers.shift
        next
      end
      next if stage == :initial

      fields = line.split(/\s+/)

      key = fields.shift if stage == :device
      fields.shift if stage == :cpu
      stats[key] = Hash[headers.zip(fields.map(&:to_f))]
    end
    stats
  end

  def run
    cmd = 'iostat'
    args = ['-x', config[:interval].to_s, '2']
    args.push('-N') if config[:mappernames]
    args.push(File.basename(config[:disk])) if config[:disk]

    exclude_disk = if config[:excludedisk]
                     config[:excludedisk].map { |d| File.basename(d) }
                   else
                     []
                   end

    stdin, stdout, stderr = Open3.popen3(cmd, *args, unsetenv_others: true)
    stdin.close
    stderr.close
    stats = parse_results(stdout.gets(nil))
    stdout.close

    timestamp = Time.now.to_i

    stats.each do |disk, metrics|
      next if exclude_disk.include? disk
      metrics.each do |metric, value|
        output [config[:scheme], disk, metric].join('.'), value, timestamp
      end
    end
    ok
  end
end
