
web アプリを casperjs で自動操作する例：
========================================

これは、<input type='file'> を使ったファイルアップロード機能を持つ web 画面を  
casperjs を使って自動操作する例である。  
  
* ファイルアップロード機能の web アプリは sinatra でサクッと実装してある。  
* アップロードするファイルは ファイル名、ファイル内容が異なるものを  runtime 時に生成している。  
　(ファイル内容は erb を使って生成している)  

準備：
-----

 ruby (1.9.3), node.js (0.10.25) が必要です。  
 $ bundle install で必要となる gem をインストールします。  
 $ npm casperjs で casperjs をインストールします。

走らせ方：  
--------

 1. web アプリを走らせる。  
　　$ bundle exec app.js  
　　( http://localhost:4567 にアクセスすれば画面が表示される)  
　　  
 2. 自動運転を走らせる。  
　　$ cd test  
　　$ casperjs test test_001.coffee  
　　  
　　files/*.txt にアップロードするファイルが生成されます。  
　　screenshots/*.png に操作経過のスクリーンショットが生成されます。  
　　../public/files/* にアップロードされたファイルが保存されます。  

 