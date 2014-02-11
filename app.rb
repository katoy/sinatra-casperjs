# -*- coding: utf-8 -*-

# See
#   http://kingyo-bachi.blogspot.jp/2012/02/sinatra.html
#   http://yusukezzz.net/blog/archives/1388

require 'rubygems'
require 'sinatra'
require 'haml'

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
  @mes = 'アップロードするファイルを指定してください。'
  haml :index
end
get '/upload' do
  redirect '/'
end

# アップロードされたファイルを保存する。
put '/upload' do
  @f = nil
  @mes = ''
  if params[:file]
    # puts params
    new_filename = "#{params[:file][:filename]}"
    save_file = "./public/files/#{new_filename}"
    File.open(save_file, 'wb') { |f| f.write(params[:file][:tempfile].read) }
    @mes = "アップロードしました： #{new_filename}"
  end
  haml :index
end
__END__
@@index
!!!
%html
  %head
    %title Uploader
  %body
    %form{:action => '/upload', :method => 'POST', :enctype => 'multipart/form-data'}
      %input{:type => 'file',   :name => 'file'}
      %input{:type => 'submit', :value => 'upload'}
      %input{:type => 'hidden', :name => '_method', :value => 'put'}

    = "#{@mes}"
    - f_ary = []
    - Dir::glob('./public/files/*.*').each {|f| f_ary << f }
    - cnt = 0
    - if f_ary.size > 0
      %table{:border => "1"}
        %tbody
          - f_ary.each do |f|
            - cnt += 1
            %tr
            %td{:align => 'right'}= cnt
            %td
              %a{:href =>"#{f[9..-1]}"}= h f[14..-1]

      %div{:style =>'padding-top: 20px;'}= "(c) 2014 katoy"
