
composite -compose difference -colors 2 $1 $2 diff.png
echo diff.png: `identify -format "%[mean]" diff.png`

# =================================================================================
# 差分がなかった場合（ diff.ong は黒一色の画像）, 0 と表示される
# See http://d.hatena.ne.jp/mirakui/20110326/1301111196
#       2枚の画像のdiff（差分）を超簡単に調べる方法
#
# 実行例
# -----------
# $ ./diffimage.sh work-0.png work-0.gray.png
# diff.png に差分が出力される。(0以外の数字が表示される)
#
# 同一ファイルを指定した場合、
# $ ./diffimage2.sh  work-0.png work-0.png
# diff.png に全面 黒の画像が出力される。( 0 と数字も表示される)
