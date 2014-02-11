# -*- coding: utf-8 -*-

require 'rubygems'
require 'rmagick'
require 'fileutils'
require 'benchmark'
require 'pp'
require 'progressbar'  # gem install progressbar

def make_thumbnail(src, dest)
  return "ERROR: フォルダが存在していません。#{src}"  unless File.exists?(src)

  total = 0
  # 出力フォルダーの階層を作る
  # TODO: リファクタリング
  Dir.glob("#{src}/**/*").each do |f|
    if File.ftype(f) == 'directory'
      toDir = f.gsub(src, dest)
      FileUtils.mkdir_p(toDir) unless File.exists?(toDir)
      # puts toDir
    end
    total += 1 if f.end_with?('.png')
  end

  puts " #{total}ファイル:  #{src} -> #{dest}"
  pbar = ProgressBar.new('thumbnail', total, $stderr)

  count = 0
  Dir.glob("#{src}/**/*.png").each do |f|
    begin
      FileUtils.cp(f, 'work.png')
      image = Magick::Image.read('work.png').first
      image.resize_to_fill(120).write('thumb.png')
      toName = f.gsub(src, dest)
      FileUtils.cp('thumb.png', toName)
      # puts toName
      count += 1
    rescue => e
      puts e
    end
    pbar.inc
  end
  pbar.finish
  " #{count}ファイルのサムネイルを作成しました。"
end

if __FILE__ == $PROGRAM_NAME
  puts Benchmark::CAPTION
  puts Benchmark.measure {
    # puts make_thumbnail('../data',      '../thumbnail')
    puts make_thumbnail(ARGV[0], ARGV[1])
  }
end
