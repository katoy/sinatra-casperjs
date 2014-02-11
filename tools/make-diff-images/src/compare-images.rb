# -*- coding: utf-8 -*-

# 2012-05-31 katoy
#  Imagemagic  の compare コマンドとほぼ同様な機能 (Imagemagic をしらべていて compare に気がついた orz..)
#   convert とは差分画像の形式が異なる。
#   日本語ファイル名も扱える。
#

require 'rubygems'
require 'rmagick'
require 'fileutils'
require 'pp'
require 'kconv'
require 'pathname'
require 'tmpdir'

def check_exists(files)
  files.each do|f|
    unless File.exists?(f)
      STDERR.puts("ERROR: ファイルが存在していません。ファイル名：'#{f}'")
      return false
    end
  end
  true
end

def copy_files(file_0, file_1, file_diff, work_0, work_1, work_diff)
  FileUtils.cp(file_0, work_0)
  FileUtils.cp(file_1, work_1)
  # エラーがおこった時は、file_0 を差分画像とする。
  # TODO: file_0 がエラーの原因だったときのことを考慮すること。
  FileUtils.cp(file_0, work_diff) if file_diff
end

def compare_images(file_0, file_1, file_diff = nil)

  ans = 'false'
  # ファイルの存在をチェック
  return ans unless check_exists([file_0, file_1])

  begin
    # imagemagic が日本語ファイル名をあつかえない ? ようなので、一時ファイルに copy して作業する。
    work_0 = work_1 = work_diff = nil

    tmp_dir = Dir.tmpdir
    work_0 = File.join(tmp_dir, 'work-0')
    work_1 = File.join(tmp_dir, 'work-1')
    ext = '.png'
    ext = Pathname.new(file_diff).extname if file_diff
    work_diff = File.join(tmp_dir, "work-diff#{ext}")
    copy_files(file_0, file_1, file_diff, work_0, work_1, work_diff)

    # data_0 = Magick::Image.read(work_0).first
    # data_1 = Magick::Image.read(work_1).first
    # diff = data_0.composite(data_1, 0, 0, Magick::DifferenceCompositeOp)
    # diff = diff.threshold(0.0)
    # diff = diff.opaque('white', 'red')
    # diff = diff.opaque('black', 'blue')

    system "compare #{file_0} #{file_1} -compose src #{work_diff}"
    diff = Magick::Image.read(work_diff).first

    ans = 'true' if diff.total_colors == 1
    if file_diff
      toDir = Pathname(file_diff).parent
      FileUtils.mkdir_p(toDir) unless File.exists?(toDir)
      diff.write(work_diff)
      FileUtils.cp(work_diff, file_diff)
    end
  rescue => e
    STDERR.puts "#{e.backtrace}\n#{e}"
  ensure
    # 一時ファイルを削除する
    FileUtils.rm([work_0, work_1], force: true)
  end
  ans
end

# ------------------------------------------------
if __FILE__ == $PROGRAM_NAME
  def show_usage
    STDERR.puts('usage: ruby compare-images.rb image_0 image_1 [image_diff]')
    STDERR.puts(' output:')
    STDERR.puts('      "true": 画像は一致')
    STDERR.puts('      "false": 画像は不一致')
    STDERR.puts(' iamge_0, image_1: 比較する画像ファイル。両者の画像データ形式が異なっていても OK。')
    STDERR.puts('      "image_diff: 画像の差分。指定した拡張子に従ったデータ形式で出力される。')
  end

  if ARGV.size < 2
    show_usage
    exit(1)
  end

  file_0 = ARGV[0]
  file_1 = ARGV[1]
  file_diff = nil
  file_diff = ARGV[2]  if ARGV.size > 2

  puts  compare_images(file_0, file_1, file_diff)
  exit(0)
end
# --- End of File ---
