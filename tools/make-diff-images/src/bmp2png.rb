# -*- coding: utf-8 -*-

require 'rubygems'
require 'rmagick'
require 'fileutils'
require 'benchmark'
require 'pp'
require 'progressbar'  # gem install progressbar

def bmp2png(src)
  return "ERROR: フォルダが存在していません。#{src}" unless File.exists?(src)

  total = 0
  # 対象ファイルをカウントする
  # TODO: リファクタリング
  Dir.glob(src + '/**/*.bmp').each { |f| total += 1 }

  pbar = ProgressBar.new('bmp2png', total, $stderr)

  count = 0
  Dir.glob(src + '/**/*.bmp').each do |f|
    begin
      FileUtils.cp(f, 'work.bmp')
      image = Magick::Image.read('work.bmp').first
      image.write('work.png')

      toName = f.sub(/\.bmp$/, '.png')
      FileUtils.cp('work.png', toName)
      FileUtils.rm(f)
      # puts f
      count += 1
    rescue => e
      puts e
    end
    pbar.inc
  end
  pbar.finish
  " #{count}ファイルを PNG に変換しました。"
end

if __FILE__ == $PROGRAM_NAME
  puts Benchmark::CAPTION
  puts Benchmark.measure {
    if ARGV.size == 0
      puts bmp2png('フォルダーを指定してください。')
    else
      puts bmp2png(ARGV[0])
    end
  }
end
