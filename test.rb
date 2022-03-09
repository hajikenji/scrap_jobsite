job_list = []
## 職種コメントアウト
# ITエンジニア全部(他職種項目との併用は不可。理由はバグるから)
# job_list << 'o16'

# 以下は他職種項目と併用可(コンサルと社内システムの複数条件にする時はシンプルに2箇所コメントアウト外せばOK)
# コンサルタント・アナリスト・プリセールス
# job_list << 'o161'
# システム開発（WEB・オープン・モバイル系）
job_list << 'o162'
# システム開発（汎用機系）
# job_list << 'o163'
# システム開発（組み込み・ファームウェア・制御系） 
# job_list << 'o164'
# パッケージソフト・ミドルウェア開発
# job_list << 'o165'
# ネットワーク・通信インフラ・サーバー設計・構築
# job_list << 'o166'
# テクニカルサポート・監視・運用・保守 
# job_list << 'o167'
# 社内システム
# job_list << 'o168'
# 研究開発・特許・品質管理・その他 
# job_list << 'o169'

## 勤務地(複数選択OK)
prefectures_list = []
# 北海道
# prefectures_list << 'p01'
# 茨城
# prefectures_list << 'p08'
# 栃木
# prefectures_list << 'p09'
# 群馬
# prefectures_list << 'p10'
# 埼玉
# prefectures_list << 'p11'
# 千葉
# prefectures_list << 'p12'
# 東京
# prefectures_list << 'p13'
# 神奈川
# prefectures_list << 'p14'
# 静岡
# prefectures_list << 'p22'
# 愛知
# prefectures_list << 'p23'
# 京都
prefectures_list << 'p26'
# 大阪
prefectures_list << 'p27'
# 兵庫
prefectures_list << 'p28'
# 広島
# prefectures_list << 'p34'
# 福岡
# prefectures_list << 'p40'

## 雇用形態集(複数選択OK)
employment_status_list = []
# 正社員
employment_status_list << 'e01'
# 契約社員
# employment_status_list << 'e02'
# 業務委託
# employment_status_list << 'e03'
# 人材バンク登録
# employment_status_list << 'e05'
# パート・アルバイト
# employment_status_list << 'e06'

## こだわり選択(複数選択OK)
special_list = []
# 職種未経験OK
# special_list << 'pa1'
# 業種未経験OK
# special_list << 'pa2'
# 上場企業
# special_list << 'pa3'
# マネジャー採用
# special_list << 'pa4'

## キーワード検索
keyword_list =[]
# keyword_list << 'kw' + 'ここに検索したい文言を入れた後コメントアウトを外してね'
keyword_list << 'kw' + 'aaa'

## 詳しい条件(複数選択OK)
detailed_list = []
# 学歴不問
# detailed_list << 'f120'
# 第二新卒歓迎
detailed_list << 'f210'
# 業界経験者優遇
# detailed_list << 'f006'

## 従業員数(以上と以下の組み合わせなら複数選択OK 以下アンド以下はバグる)
employ_above_list =[]
# 10名以上
# employ_above_list << 'emin0010'
# 50名以上
# employ_above_list << 'emin0050'
# 100名以上
# employ_above_list << 'emin0100'
# 300名以上
# employ_above_list << 'emin0300'
# 1000名以上
# employ_above_list << 'emin1000'
# 5000名以上
# employ_above_list << 'emin5000'
employ_below_list =[]
# 10名以下
# employ_below_list << 'emax0010'
# 50名以下
# employ_below_list << 'emax0050'
# 100名以下
# employ_below_list << 'emax0100'
# 300名以下
# employ_below_list << 'emax0300'
# 1000名以下
# employ_below_list << 'emax1000'
# 5000名以下
employ_below_list << 'emax5000'

## 売上高(以上と以下の組み合わせなら複数選択OK 以下アンド以下はバグる)
sales_above_list = []
# 100万以上
# sales_above_list << 'smin001mi'
# 500万以上
# sales_above_list << 'smin005mi'
# 1000万以上
# sales_above_list << 'smin010mi'
# 5000万以上
# sales_above_list << 'smin050mi'
# 1億以上
# sales_above_list << 'smin100mi'
# 10億以上
# sales_above_list << 'smin001bi'
# 100億以上
# sales_above_list << 'smin010bi'
# 1000億以上
# sales_above_list << 'smin100bi'
# 5000億以上
# sales_above_list << 'smin500bi'
sales_below_list =[]
# 100万以下
# sales_below_list << 'smax001mi'
# 500万以下
# sales_below_list << 'smax005mi'
# 1000万以下
# sales_below_list << 'smax010mi'
# 5000万以下
# sales_below_list << 'smax050mi'
# 1億以下
# sales_below_list << 'smax100mi'
# 10億以下
# sales_below_list << 'smax001bi'
# 100億以下
# sales_below_list << 'smax010bi'
# 1000億以下
# sales_below_list << 'smax100bi'
# 5000億以下
# sales_below_list << 'smax500bi'

# 他条件は作成者に要相談か自力でお願いします
lojic_list = []
lojic_list.push(
                prefectures_list,
                job_list,
                detailed_list,
                employment_status_list,
                special_list,
                employ_above_list,
                employ_below_list,
                keyword_list,
                sales_above_list,
                sales_below_list
)
@logic_url = 'https://tenshoku.mynavi.jp/engineer/list/'
lojic_list.each_with_index do |list, index|
  p list
  if list.empty?
    list.delete_at(index)
    next
  end
  if index == 0 || index == 1 || index == 3
    @logic_url += list.join('+') + '/'
  elsif index == 2 || index == 4
    @logic_url += list.join('_') + '/'
  else
    @logic_url += list[0] + '/'
  end
end
@logic_url + '?soff=1&ags=0'