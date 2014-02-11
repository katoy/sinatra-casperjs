# -*- coding: utf-8 -*-

# 再帰的に Directory 階層を copy していく。
# ただし、 copy するのは *.rb だけを対象とし、utf-8 に encoding 変換もする。
#
#  2012-06-10 katoy

require 'rubygems'
require 'fileutils'
require 'pp'
require 'kconv'

# utilitioes
class Utils
  def self.copy_r(src, dest, &proc)
    Dir.entries(src).each do |fname|
      next if ('.' == fname) || ('..' == fname)
      s = File.join(src, fname)
      d = File.join(dest, fname)
      if FileTest.directory?(s)
        FileUtils.mkdir_p(d)
        copy_r(s, d, &proc)
      else
        # copy_file(s, d)
        proc.call(s, d) if block_given?
      end
    end
  end
end

def copy_file(s, d)
  pp(s + ' -> ' + d)
end

if __FILE__ == $PROGRAM_NAME
  def usage
    puts "usage: #{$PROGRAM_NAME} src dest"
  end

  if ARGV.size < 2
    usage
    exit(-1)
  end

  Utils.copy_r(ARGV[0], ARGV[1]) do |s, d|
    def target?(name)
      name.match(/.*\.rb$/i)
    end

    if target?(s)
      open(s) do |source|
        open(d, 'w') do |dest|
          dest.write(source.read.toutf8)
        end
      end
    end
  end
  exit(0)
end
