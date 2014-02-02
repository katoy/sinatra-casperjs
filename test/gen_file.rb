# -*- coding: utf-8 -*-
seqno = 1000
seqno = ARGV[0].to_i  if ARGV.size  > 0

ENV['SEQNO'] = "#{seqno}"   # erb 中で参照する。

command = "erb data/01_template.txt > files/#{seqno}_gen.txt"
system(command)
# puts ENV['SEQNO']

exit 0
