# -*- coding: utf-8 -*-

# 再帰的に Directory 階層を wc していく。
# ただし、 wc するのは *.rb, *.txt *.md だけを対象とする。
#
#  2012-06-10 katoy

require 'rubygems'
require 'fileutils'
require 'pp'

# Utilities
class Utils
  # folder を再帰的に訪れて、 proc の処理を行う。
  def self.visit_r(src, &proc)
    Dir.entries(src).each do |fname|
      next if ('.' == fname) || ('..' == fname)
      s = File.join(src, fname)
      if FileTest.directory?(s)
        printf("%#10s\t%s\n", ' ', s)
        visit_r(s, &proc)
      else
        # copy_file(s, d)
        proc.call(s) if block_given?
      end
    end
  end
end

def wc_file(s)
  line_count = open(s).read.count("\n")
  printf("%#10d\t%s\n", line_count, File.basename(s, ''))
  line_count
end

if __FILE__ == $PROGRAM_NAME

  def usage
    puts "usage: #{$PROGRAM_NAME} src"
  end

  if ARGV.size < 1
    usage
    exit(-1)
  end

  line_count = 0
  file_count = 0
  Utils.visit_r(ARGV[0]) do |s|

    def target?(name)
      ans = false
      ans |= name.match(/.*\.rb$/i)
      ans |= name.match(/.*\.txt$/i)
      ans |= name.match(/.*\.md$/i)
      ans
    end

    if target?(s)
      line_count += wc_file(s)
      file_count += 1
    end
  end
  printf "%#10d\tTotal %d file(s)\n", line_count, file_count
  exit(0)
end
