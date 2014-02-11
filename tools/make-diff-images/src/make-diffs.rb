# -*- coding: utf-8 -*-

require 'rubygems'
require 'rmagick'
require 'fileutils'
require 'benchmark'
require 'pp'
require 'pathname'
require 'progressbar'  # gem install progressbar

DIR_PREV = '../../results/capture-prev'
DIR_CUR  = '../../results/capture'
DIR_DIFF = '../../results/diff'

def make_diff(dir_prev, dir_cur, dir_diff)

  return "ERROR: フォルダが存在していません。#{dir_prev}"  unless File.exists?(dir_prev)
  return "ERROR: フォルダが存在していません。#{dir_cur}"  unless File.exists?(dir_cur)

  total = 0
  # 画像総数を得る。
  # TODO: リファクタリング
  Dir.glob("#{dir_prev}/**/*").each do |f|
    total += 1 if f.end_with?('.png')
  end

  sames = 0
  diffs = 0
  diffs_name = []

  puts "ファイル総数： #{total}\n #{dir_prev} と #{dir_cur} の比較結果\n   -> #{dir_diff}"
  pbar = ProgressBar.new('diff', total, $stderr)

  Dir.glob("#{dir_prev}/**/*.png").each do |f0|
    begin
      f1 = f0.gsub("#{dir_prev}/", "#{dir_cur}/")
      f2 = f0.gsub("#{dir_prev}/", "#{dir_diff}/")

      FileUtils.cp(f0, 'work-prev.png')
      FileUtils.cp(f1, 'work-current.png')
      # エラーがおこったら capture-prev の画像を diff 画像 として保存する。
      toDir = Pathname(f2).parent
      FileUtils.mkdir_p(toDir) unless File.exists?(toDir)
      FileUtils.cp(f0, f2)

      system "compare work-current.png work-prev.png -compose src #{f2}"
      diff = Magick::Image.read(f2).first
      if diff.total_colors == 1
        sames += 1
        FileUtils.rm_f(f2)
      else
        diffs += 1
        diffs_name << f2
        diff.write('work-diff.png')
        FileUtils.cp('work-diff.png', f2)
      end
    rescue => e
      puts e
      diffs += 1
      diffs_name << f2
      FileUtils.cp('work-prev.png', f2)
    end
    pbar.inc
  end

  pbar.finish

  ans = ''
  ans += diffs_name.join("\n") + "\n\n"
  ans += "変化あり: #{diffs} file(s)\n"
  ans += "変化なし: #{sames} file(s)\n"
  ans
end

# ------------------------------------------------
if __FILE__ == $PROGRAM_NAME
  puts Benchmark::CAPTION
  puts Benchmark.measure {
    # ans = make_diff(DIR_PREV, DIR_CUR, DIR_DIFF)
    ans = make_diff(ARGV[0], ARGV[1], ARGV[2])
    puts ans
  }
end
