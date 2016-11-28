#!/usr/bin/env ruby

#
#   check-iowait
#
# DESCRIPTION:
#   Measures the IO wait. This is somehow different from what is achieved by iostat
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#   check-iowait.rb -c 30 -w 20 -s 6
#
# NOTES:
#   
#
# LICENSE:
#   Hanine HAMZIOUI <hanynowsky@gmail.com> - Magic Online
#   November 2016
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'

#
# Check IO WAIT
#
class CheckIOWAIT < Sensu::Plugin::Check::CLI
  option :warning,
    long: '--warning WARNING',
    short: '-w WARNING',
    description: 'warning percentage',
    proc: proc(&:to_f),
    default: 50,
    required: false

  option :debug,
    long: '--debug',
    short: '-d',
    description: 'debug info',
    default: false,
    boolean: true,
    required: false

  option :critical,
    long: '--critical CRITICAL',
    short: '-c CRITICAL',
    description: 'Critical percentage threshold',
    proc: proc(&:to_f),
    default: 70,
    required: false

  option :sleep,
    long: '--sleep SECONDS',
    short: '-s SECONDS',
    description: 'Amount of seconds to sleep between IO benchmarks',
    proc: proc(&:to_i),
    default: 5,
    required: false

  # BEWARE : Result in function of number of cores
  # E.G : 100% iowait on 8 cores <=> riwP = 800% || riw = 8;
  def compute
    ticker = `getconf CLK_TCK`
    iv = config[:sleep] # number of sleep seconds
    ut0 = `cat /proc/uptime| awk '{print $1}'`
    iw0 = `head -n1 /proc/stat|awk '{print $6}'`

    sleep(iv) 

    ut1 = `cat /proc/uptime| awk '{print $1}'`
    iw1 = `head -n1 /proc/stat|awk '{print $6}'`
    if ! `cat /etc/redhat-release 2>/dev/null | grep 'CentOS release 5' `.to_s.empty?
      nbproc = `grep -i "physical id" /proc/cpuinfo | sort -u | wc -l | sed -e 's/ //g'`.to_i + 1
    else
      nbproc = `nproc`
    end

    iwt = iw1.to_f - iw0.to_f
    utt = ut1.to_f - ut0.to_f
    riw = (iwt.to_f / ticker.to_f ) / utt.to_f 
    riwP = riw * 100 / nbproc.to_f                                                                                                                                                                                               

    puts "#{riw}" if config[:debug]
    return riwP.to_f
  rescue
    unknown 'Could not fetch IOSTAT'
  end

  def run
    result = compute.round(2)
    critical "#{result}%"  if result >= config[:critical]
    warning "#{result}%"  if result >= config[:warning] && result < config[:critical]
    ok "IOWAIT: #{result}%"
  end

end
