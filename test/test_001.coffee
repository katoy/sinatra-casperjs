
# See 
#   http://blog.codeship.io/2013/03/07/smoke-testing-with-casperjs.html

# prepare:
#  $ brew install phantomjs
#  $ npm install casperjs
# 
#  $ bundle install
#  $ rm -f ../public/files/*
#  $ bundle exec ruby app.rb
#
# run_test:
#  $ rm -f screenshots/*.png files/*
#  $ casperjs test test_001.coffee
#  $ diff -r ../public/file ./files  # ダウンロード元、ダウンロード先のファイル内容をすべて比較する・

spawn = require('child_process').spawn
exec = require('child_process').exec
sprintf = require('sprintf').sprintf

STORY_NAME = 'test_001'

[VIEWPORT_W, VIEWPORT_H] = [400, 400]
URL = 'http://localhost:4567'

pwd = require('system').env['PWD']

repeat_count = 4      # 繰り返し回数
start_seq = 1000      # シーケンス番号の初期値

capture_seq = 0       # 画面スクリーンショットの添字数字の初期値
capture_flag = true  # true: キャプチャを撮る、 false: 撮らない

count_up = -> sprintf("#{STORY_NAME}_%04d", capture_seq++)

run_command = (casper, command, opts) ->
  cmd = spawn command, opts
  cmd.stdout.on "data", (data) -> console.log "stdout: " + data
  cmd.stderr.on "data", (data) -> console.log "stderr: " + data
  cmd.on "exit",        (code) -> console.log "exit code: " + code

do_upload_file = (casper, seq) ->
  # ===== URL 指定でページを開く
  casper.thenOpen "#{URL}"
  casper.then ->
    @.waitForText 'アップロードするファイルを指定してください。'
    @.test.assertTitle 'Uploader'
    @.capture "screenshots/#{count_up()}_before_upload.png" if capture_flag
  # ===== input type=file の処理
  casper.then ->
    @.fillSelectors('form', {
      "input[name='file']": "#{pwd}/files/#{seq}_gen.txt"
      }, false)
    @.capture "screenshots/#{count_up()}_before_submit.png" if capture_flag
  casper.then ->
    # ==== submit する
    @.fillSelectors('form', {}, true)
  casper.then ->
    @.waitForText 'アップロードしました'
    @.test.assertTitle 'Uploader'
    @.capture "screenshots/#{count_up()}_after_submit.png"  if capture_flag

# ../public/files, scrennshot/,  files/ を空にする
run_command casper, 'rm',    ['-fr', '../public/files', './screenshots', './files']
run_command casper, 'mkdir', [       '../public/files', './screenshots', './files']

casper.start URL, ->
  @.viewport VIEWPORT_W, VIEWPORT_H

  # =====  アップロードの繰り返し
  current_step = 0
  @.repeat repeat_count, -> 
    @.echo "----- #{current_step + 1} / #{repeat_count}" 
    @.then -> run_command @, 'ruby', ['./gen_file.rb', current_step + start_seq] # アップロードするフィアルを生成
    @.then -> do_upload_file @, current_step + start_seq
    @.then -> current_step += 1

  # 結果を比較する
  @.then ->
    run_command @, 'diff', ['-r', '../public/files', './files']

casper.run ->
  @.test.done()

