require 'open-uri'
require 'readability'
require 'sanitize'
require 'kconv'
require 'uri'
require 'pry'

# 記号は削除
def clean_text str
  str = str.gsub(/[\r\n\t]/, ' ')
  str = str.gsub(/[【】]/, ' ')
  str = str.gsub(/[（）\(\)]/, ' ')
  str = str.gsub(/[［］\[\]]/, ' ')
  str = str.gsub(/[「」]/, ' ')
  str = str.gsub(/[『』]/, ' ')
  str = str.gsub(/[〈〉』]/, ' ')
  str = str.gsub(/[《》』]/, ' ')
  str = str.gsub(/[｛｝]/, ' ')
  str = str.gsub(/[\!！]/, ' ')
  str = str.gsub(/[\?？]/, ' ')
  str = str.gsub(/[\#＃]/, ' ')
  str = str.gsub(/[\$＄]/, ' ')
  str = str.gsub(/[￥]/, ' ')
  str = str.gsub(/[%％]/, ' ')
  str = str.gsub(/[\^＾]/, ' ')
  str = str.gsub(/[\&＆]/, ' ')
  str = str.gsub(/[\*＊]/, ' ')
  str = str.gsub(/[\-_]/, ' ')
  str = str.gsub(/[\+=]/, ' ')
  str = str.gsub(/[\\]/, ' ')
  str = str.gsub(/[`]/, ' ')
  str = str.gsub(/["'”’“‘]/, ' ')
  str = str.gsub(/[\.\,\/\/]/, ' ')
  str = str.gsub(/[;:]/, ' ')
  str = str.gsub(/[。、，：；・…／※\~]/, ' ')
  str = str.gsub(/[＋×÷]/, ' ')
  str = str.gsub(/[〜−―＿]/, ' ')
  str = str.gsub(/[↓↑←→]/, ' ')
  str = str.gsub(/[①②③④⑤⑥⑦⑧⑨⑩]/, ' ')
  str = str.gsub(/[★☆◯◎●■□◆◇○]/, ' ')
end

# 有名所の HTML エンティティは削除
def remove_html_entities str
  str = str.gsub('&quot;', '')
  str = str.gsub('&amp;', '')
  str = str.gsub('&lt;', '')
  str = str.gsub('&gt;', '')
  str = str.gsub('&nbsp;', '')
  str = str.gsub('&copy;', '')
  str = str.gsub('amp;', '')
end

# URL は邪魔なので削除
def remove_url str
  reg = URI.regexp %w[http https]
  str.gsub(reg, ' ')
end

# すべて半角で統一
def full_to_half str
  str.tr('０-９ａ-ｚＡ-Ｚ', '0-9a-zA-Z')
end

# 数値情報は今回役に立たないため全部 0 へ変換し語彙量を減らす
def to_zero str
  str.tr('0-9', '0')
end

# すべて小文字で統一
def to_downcase str
  str.downcase
end

# ドメインごとに抜き出したくない CSS セレクタヒントを提供
def black_css_list url
  list = {
    'liginc.co.jp' => '.special-wrapper'
  }
  list[domain(url)]
end

def domain url
  u = URI.parse url
  u.host
end

def convert_utf8 str
  # if str.encoding.to_s == 'ASCII-8BIT'
  #   str.encode('utf-8', 'cp932').scrub('?')
  # else
  #   str.force_encoding('UTF-8').scrub('?')
  # end
  str.toutf8.scrub('?')
end

open('./url_list.txt').read.each_line.each do |url|
  begin
    url = url.chomp
    source = convert_utf8 open(url).read
    text = Readability::Document.new(source, {blacklist: black_css_list(url), do_not_guess_encoding: true}).content
    text = Sanitize.clean text
    text = remove_html_entities text
    text = remove_url text
    text = full_to_half text
    # 3c分析などの単語が 0 になるのでだめ…
    # text = to_zero text
    text = clean_text text
    text = to_downcase text
    puts url + "\t" + text
  rescue => e
    puts url + "\terror\t" + e.to_s
  end
end
