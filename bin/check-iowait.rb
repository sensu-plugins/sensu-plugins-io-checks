#!/usr/bin/env ruby
#
# check-iowait
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
#   N/A
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
  option :warning, long: '--warning WARNING', short: '-w WARNING', description: 'warning percentage', proc: proc(&:to_f), default: 50
  option :debug, long: '--debug', short: '-d', description: 'debug info', default: false, boolean: true
  option :critical, long: '--critical CRITICAL', short: '-c CRITICAL', description: 'Critical percentage threshold', proc: proc(&:to_f), default: 70
  option :sleep, long: '--sleep SECONDS', short: '-s SECONDS', description: 'Amount of seconds to sleep between IO benchmarks', proc: proc(&:to_i), default: 5

  # Determines whether the OS is crappy or not
  def special_os
    if File.exist?('/etc/redhat-release')
      return true if File.foreach('/etc/redhat-release').first.to_s.include? 'CentOS release 5'
    end
    if File.exist?('/etc/gentoo-release')
      return true if File.foreach('/etc/gentoo-release').first.to_s.include? 'Gentoo'
    end
    false
  end

  # Computes the IO Wait
  # BEWARE : Result in function of number of cores
  # E.G : 100% iowait on 8 cores <=> riwP = 800% || riw = 8;
  # Original bash commands are:
  # ut0 = `cat /proc/uptime| awk '{print $1}'`
  # iw0 = `head -n1 /proc/stat|awk '{print $6}'`
  # ut1 = `cat /proc/uptime| awk '{print $1}'`
  # iw1 = `head -n1 /proc/stat|awk '{print $6}'`
  def compute
    ticker = `getconf CLK_TCK`
    iv = config[:sleep] # number of sleep seconds
    ut0 = File.read('/proc/uptime').split(' ')[0]
    iw0 = File.foreach('/proc/stat').first.split(' ')[5]
    sleep(iv)
    ut1 = File.read('/proc/uptime').split(' ')[0]
    iw1 = File.foreach('/proc/stat').first.split(' ')[5]
    nbproc = if special_os 
      `grep -i "physical id" /proc/cpuinfo | sort -u | wc -l | sed -e 's/ //g'`.to_i + 1
    else
      `nproc`
    end

    iwt = iw1.to_f - iw0.to_f
    utt = ut1.to_f - ut0.to_f
    riw = (iwt.to_f / ticker.to_f) / utt.to_f
    riw_p = (riw * 100 / nbproc.to_f)
    puts riw.to_s if config[:debug]
    return riw_p.to_f
  rescue => e
    unknown "Could not fetch IOWAIT #{e.message}"
  end

  def run
    result = compute.round(2)
    critical "#{result}%" if result >= config[:critical]
    warning "#{result}%" if result >= config[:warning] && result < config[:critical]
    ok "IOWAIT: #{result}%"
  end
end
