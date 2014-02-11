#!/bin/bash

# モノクロ画像をつくる
\cp $1 work-gray.png
mogrify -colorspace gray work-gray.png

# SVGをつくる
\cp $1 work.bmp
mogrify -format bmp work.bmp
potrace -s --blacklevel 0.7 work.bmp
\rm -f work.bmp

echo Generated work.svg, work-gray.png

# ------------------------------------------------------------------
# モノクロ画像と svg (ベクター)をつくる。
# See  http://potrace.sourceforge.net/#downloading
#      http://totoco.org/blog/2005/0827-0137.php
#           サルでも分かる(？)Potraceの使い方
# ------------------------------------------------------------------
