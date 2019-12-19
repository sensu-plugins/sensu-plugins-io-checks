# frozen_string_literal: true

require_relative './plugin_stub.rb'
require_relative './fixtures.rb'
require_relative './spec_helper.rb'
require_relative '../bin/metrics-iostat-extended.rb'

def should_call_iostat
  it 'should call iostat' do
    io = IOStatExtended.new
    expect(Open3).to begin
      receive(:popen3)
        .with('iostat', '-x', '1', '2', unsetenv_others: true)
        .and_return iostat_result
    end
    expect(-> { io.run }).to raise_error SystemExit
  end

  it 'should call iostat -N if mappernames option set' do
    io = IOStatExtended.new
    io.config[:mappernames] = true
    expect(Open3).to begin
      receive(:popen3)
        .with('iostat', '-x', '1', '2', '-N', unsetenv_others: true)
        .and_return iostat_result
    end
    expect(-> { io.run }).to raise_error SystemExit
  end

  it 'should call iostat -d for given disk if disk option set' do
    io = IOStatExtended.new
    io.config[:disk] = '/dev/sda'
    expect(Open3).to begin
      receive(:popen3)
        .with('iostat', '-x', '1', '2', 'sda', unsetenv_others: true)
        .and_return iostat_result
    end
    expect(-> { io.run }).to raise_error SystemExit
  end
end

def should_handle_interval_option
  it 'should handle interval option' do
    io = IOStatExtended.new
    io.config[:interval] = 4
    expect(Open3).to begin
      receive(:popen3)
        .with('iostat', '-x', '4', '2', unsetenv_others: true)
        .and_return iostat_result
    end
    expect(-> { io.run }).to raise_error SystemExit
  end
end

def should_handle_exclude_disk
  it 'should handle exclude-disk and mappernames ordering' do
    io = IOStatExtended.new
    io.config[:excludedisk] = %w[sda]
    io.config[:mappernames] = true
    expect(Open3).to begin
      receive(:popen3)
        .with('iostat', '-x', '1', '2', '-N', unsetenv_others: true)
        .and_return iostat_result
    end
    expect(-> { io.run }).to raise_error SystemExit
  end
end

describe IOStatExtended, 'syscall' do
  should_call_iostat
  should_handle_interval_option
  should_handle_exclude_disk
end

def output_should_handle
  it 'should handle scheme' do
    io = IOStatExtended.new
    io.config[:scheme] = 'foo.bar'
    expect(io).to receive(:output).with(no_args)
    expect(io).to receive(:output).with(/^foo\.bar/, kind_of(Numeric), kind_of(Numeric)).exactly(32).times
    expect(-> { io.run }).to raise_error SystemExit
  end
  it 'should handle multiple disk for excludedisk' do
    io = IOStatExtended.new
    io.config[:excludedisk] = %w[sda md0]
    expect(io).to_not receive(:output).with(/^.*sda\.\w*$/, anything, anything)
    expect(io).to_not receive(:output).with(/^.*md0\.\w*$/, anything, anything)
    expect(-> { io.run }).to raise_error SystemExit
  end

  it 'should handle full dev node path for excludedisk' do
    io = IOStatExtended.new
    io.config[:excludedisk] = %w[/dev/sda]
    expect(io).to_not receive(:output).with(/^.*sda\.\w*$/, anything, anything)
    expect(-> { io.run }).to raise_error SystemExit
  end
end

describe IOStatExtended, 'output' do
  before(:example) do
    expect(Open3).to receive(:popen3).and_return iostat_result
  end

  output_should_handle

  it 'should print metrics' do
    io = IOStatExtended.new
    expect(io).to receive(:output).with(no_args)
    expect(io).to receive(:output).with(kind_of(String), kind_of(Numeric), kind_of(Numeric)).exactly(32).times
    expect(-> { io.run }).to raise_error SystemExit
  end

  it 'should exclude given disk if excludedisk option set' do
    io = IOStatExtended.new
    io.config[:excludedisk] = ['sda']
    expect(io).to_not receive(:output).with(/^.*sda\.\w*$/, anything, anything)
    expect(-> { io.run }).to raise_error SystemExit
  end
end
