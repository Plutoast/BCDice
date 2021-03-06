# frozen_string_literal: true

require "bcdice/game_system/BloodCrusade"

module BCDice
  module GameSystem
    class BloodMoon < Base
      # ゲームシステムの識別子
      ID = 'BloodMoon'

      # ゲームシステム名
      NAME = 'ブラッド・ムーン'

      # ゲームシステム名の読みがな
      SORT_KEY = 'ふらつとむうん'

      # ダイスボットの使い方
      HELP_MESSAGE = <<~INFO_MESSAGE_TEXT
        ・各種表
        　・関係属性表　RAT
        　・導入タイプ決定表(ノーマル)　IDT
        　・導入タイプ決定表(ハード込み)　ID2T
        　・シーン表           ST
        　・先制判定指定特技表 IST
        　・身体部位決定表　　 BRT
        　・自信幸福表　　　　 CHT
        　・地位幸福表　　　　 SHT
        　・日常幸福表　　　　 DHT
        　・人脈幸福表　　　　 LHT
        　・退路幸福表　　　　 EHT
        　・ランダム全特技表　 AST
        　・軽度狂気表　　　　 MIT
        　・重度狂気表　　　　 SIT
        ・D66ダイスあり
      INFO_MESSAGE_TEXT

      def initialize(command)
        super(command)

        @sort_add_dice = true
        @enabled_d66 = true
        @d66_sort_type = D66SortType::ASC
        @round_type = RoundType::CEIL # 端数切り上げに設定
      end

      # ゲーム別成功度判定(2D6)
      def check_2D6(total, dice_total, _dice_list, cmp_op, target)
        return '' if target == '?'
        return '' unless cmp_op == :>=

        if dice_total <= 2
          return " ＞ ファンブル(【余裕】が 0 に)"
        elsif dice_total >= 12
          return " ＞ スペシャル(【余裕】+3）"
        elsif total >= target
          return " ＞ 成功"
        else
          return " ＞ 失敗"
        end
      end

      def eval_game_system_specific_command(command)
        return roll_tables(command, TABLES)
      end

      TABLES = {
        "CHT" => DiceTable::Table.new(
          "自信幸福表",
          "1D6",
          [
            "【戦闘能力】あなたはハンターとしての自分の戦闘能力に自信を持っています。たとえ負けようとも、それは運か相手か仲間が悪かったので、あなたの戦闘能力が低いわけではありません。",
            "【美貌】あなたは自分が美しいことを知っています。他人もあなたを美しいと思っているはず。鏡を見るたびに、あなたは自分の美しさに惚れ惚れしてしまいます。",
            "【血筋】あなたは名家の血を引く者です。祖先の栄光を背負い、家門の名誉を更に増すために、偉業をなす運命にあります。または、普通にいい家族に恵まれているのかもしれません。",
            "【趣味の技量】あなたは趣味の分野では第一人者です。必ずしも名前が知れ渡っているわけではありませんが、どんな相手にも負けない自信があります。どんな趣味かは自由です。",
            "【仕事の技量】職場で最も有能なもの、それがあなたです。誰もあなたの仕事の量とクオリティを超えられません。どんな仕事をしているかは自由に決めて構いません。",
            "【長生き】あなたはハンターとしてかなりの年月を過ごしてきたが、まだ死んでいません。これは誇るべきことです。そこらの若造には、まだまだ負けていません。"
          ]
        ),
        "SHT" => DiceTable::Table.new(
          "地位幸福表",
          "1D6",
          [
            "【役職】あなたは職場、あるいはハンターの組織のなかで高い階級についています。そのため、下にいるものには命令でき、相応の敬意を払われます。",
            "【英雄】あなたはかつて偉業を成し遂げたことがあり、誰でもそれを知っています。少々くすぐったい気もしますが、英雄として扱われるのは悪くありません。",
            "【お金持ち】あなたには財産があります。それも生半可な財産ではなく、人が敬意を払うだけの財産です。あなたはお金に困ることはなく、その幸せを知っています",
            "【特権階級】あなたは国が定める特権階級の一員です。王族や貴族をイメージするとわかりやすいでしょう。あなたは、どこに行っても、それ相応の扱いを受けることになります。",
            "【人格者】誰もが認める人格者としての評判を持っているため、あなたのところには悩みを抱えた人々が引きも切らずに押しかけてきます。大変ですが、ちょっと楽しい",
            "【リーダー】あなたは所属している何らかの組織を率いる立場にあります。会社の社長や、部活動の部長などです。あなたは求められてその地位にあります"
          ]
        ),
        "DHT" => DiceTable::Table.new(
          "日常幸福表",
          "1D6",
          [
            "【家】あなたの家はとても快適な空間です。コストと時間をかけて作り上げられた、あなたが居住するための空間。それはあなたの幸せの源なのです。",
            "【職場】あなたは仕事が楽しくて仕方ありません。意義ある仕事で払いも悪くなく、チームの仲間はみんないい奴ばかりです。残業は……ちょっとあるかもしれません。",
            "【行きつけの店】あなたには休みの日や職場帰りに立ち寄る行きつけの店があり、そこにいる時間は安らぎを感じることができます。店員とも顔見知りです。",
            "【ベッド】あなたは動物を飼っています。よく懐いた可愛い、またはかっこいい動物です。一緒に過ごす時間はあなたに幸せを感じさせてくれます",
            "【親しい隣人】おとなりさんやお向かいさん。よくお土産を渡したり、小さな子供を預かったりするような仲です。風邪を引いたときには、家事を手伝ってくれることも。",
            "【思い出】あなたは昔の思い出を心の支えにしています。何らかの幸せな記憶……それがあれば、この先にどんなつらいことが待っていても大丈夫でしょう。"
          ]
        ),
        "LHT" => DiceTable::Table.new(
          "人脈幸福表",
          "1D6",
          [
            "【理解ある家族】あなたの家族は、あなたがハンターであることを知ったうえで協力してくれます。これがどれほど稀なことかは、仲間に聞けば分かるでしょう。",
            "【有能な友人】あなたの友人は、吸血鬼の存在とあなたの本当の仕事を知っています。そして、直接戦うだけの技量はないものの、あなたの探索をサポートしてくれます。",
            "【愛する恋人】あなたには愛する人がいます。見つめあうだけで、あなたの心は舞い上がり……帰ってきません。この恋人を失うなんて、考えるだけでも恐ろしいことです。",
            "【同志の権力者】あなたには吸血鬼の存在を知りながら、奴らに屈していない権力者との繋がりがあります。様々な違法行為をはたらく際に、役に立つでしょう。",
            "【得がたい師匠】あなたは使う武器を学んだ師匠がいて、それを通して兄弟弟子とも繋がりがあります。過酷な訓練を経て、彼らとあなたには強い絆ができています。",
            "【可愛い子供】あなたには子供がいます。聡明で魅力的、しかも健康な……将来を嘱望される子供です。子供が掴む幸せな未来を思う時、あなたの顔には笑みが広がります。"
          ]
        ),
        "EHT" => DiceTable::Table.new(
          "退路幸福表",
          "1D6",
          [
            "【故郷の町】あなたは生まれ育った街を離れてハンターとして活動しています。いつの日かあの町へ帰る……その思いがあなたを戦いのなかで支えています。",
            "【待っている人】あなたがハンターをやめて、普通の暮らしに戻ることを待ちわびている人がいます。そして、あなたはその思いに応えたいと思っています。",
            "【就職先】あなたは吸血鬼狩りの報酬がなくなっても、すぐに入ることができる就職先があるので安心です。有能なのか過疎地域なのかは分かりませんが。",
            "【配偶者】あなたはハンターをやめたあとに家庭に入ろうと考えています。暮らしの設計はすでに済み、あとは実行するだけなのですが、なかなかそうはいきません。",
            "【大志】あなたがハンターとして活動しているのは、やむにやまれぬ事情があるからです。あなたには「本当にやりたかったこと」があり、いつかその夢をかなえる気でいます。",
            "【空想の王国】あなたには辛いことがあると白昼夢にふける、あるいは物語に没入する癖があり、そのときには非常に幸せな気分になることができます。"
          ]
        ),
        "ID2T" => DiceTable::D66Table.new(
          "導入タイプ決定表(ハード込み)",
          D66SortType::ASC,
          {
            11 => "依頼\n《概要》 ハンターは任意のキャラクターに他のハンターの【幸福】を守るように依頼され、その依頼を受ける。\n《目的》 他のハンターの【幸福】のうち一つを結果フェイズまで破壊されないこと。この【幸福】は、ゲームマスターが指定する。\n《報酬》　経験値2",
            12 => "防衛\n《概要》 ハンターは今回の敵となるモンスターに【幸福】を狙われている。モンスターを倒さなければ【幸福】を守る事は出来ない。\n《目的》 自分の獲得している【幸福】のうち一つを結果フェイズで失わないこと。この【幸福】はゲームマスターが指定する。\n《報酬》 経験値2",
            13 => "復讐\n《概要》 ハンターは今回の敵となるモンスターに負けたことがある。戦闘に敗北したのか、それとも【幸福】を壊されたのか。いずれにせよ、復讐の時だ。\n《目的》 結果フェイズまでにモンスターを無力化すること。\n《報酬》 経験値２",
            14 => "関係\n《概要》 ハンターは、特定の人物が参加しているから、という理由で狩りに参加する。憧れているのかライバルなのか、単に仲がいいのかは自由。\n《目的》 結果フェイズの時点で他のハンターのうち一人との関係が、お互いに【深度】3以上になっていること。対象のハンターはシーンプレイヤーが決定する。\n《報酬》 経験値２",
            15 => "挑戦\n《概要》 ハンターは今回の敵となるモンスターのことをなんらかの理由で知り、自分から戦いに赴く。\n《目的》 結果フェイズまでハンター全員が生き残り、かつ、フォロワーやモンスターに変化していないこと。\n《報酬》 経験値２",
            16 => "救済\n《概要》 ハンターは今回の敵となるフォロワーのうち一人を救うために戦う。\n《目的》 結果フェイズまでに対象のフォロワーを「説得」で無力化する。このフォロワーはシーンプレイヤーが決定する。\n《報酬》 経験値2",
            22 => "復調\n 《概要》 ハンターは正気を取り戻し、【狂気】を癒すために戦う。\n《目的》 結果フェイズまでに自分の【狂気】を2減らす。\n《報酬》 経験値２",
            23 => "撃滅 \n《概要》 ハンターは狩りの対象であるモンスターを倒すために育成されていたり、モンスターに【幸福】を全て破壊された過去を持っている。\n《目的》 モンスターを自分で無力化する。\n《報酬》　経験値6",
            24 => "競争 \n《概要》 ハンターは自分で決めたライバルに勝つために狩りを行う。\n《目的》 他のプレイヤーのハンターからライバルを一人選ぶ。結果フェイズの段階で、ライバルよりも多くのモンスターとフォロワーを攻撃で倒している事。このライバルはシーンプレイヤーが選択する。\n《報酬》 経験値6",
            25 => "育成 \n《概要》 ハンターは仲間を成長させるために狩りに出る。\n《目的》 他の狩人すべてに導入タイプの目的を達成させる。\n《報酬》 達成した人数+2の経験値",
            26 => "窮乏 \n《概要》 ハンターは貧乏なので、金のために狩りをしなければならない。\n《目的》 自分が装備しているアイテムから一つを対象として選ぶ。対象は即座に破壊される。そのうえで、結果フェイズまで対象が書いてあったアイテム欄を使用しない。この対象はシーンプレイヤーが選択する。\n《報酬》 経験値6",
            33 => "泰然 \n《概要》 ハンターはクールでかっこいい自分のスタイルを守るために狩りをする。\n《目的》 結果フェイズまで【激情】を使用しない。\n《報酬》 経験値8",
            34 => "対話 \n《概要》 ハンターはモンスターと話をするために追いかけていく。\n《目的》 モンスターに対する関係【深度】が2以上になっている状態で決戦フェイズに入る。\n《報酬》 経験値8",
            35 => "完勝 \n《概要》 ハンターは今回の敵となるモンスターに勝ったことがある。今度こそ、とどめを刺すのだ。\n《目的》 部位ダメージを受けずにモンスターを無力化する。\n《報酬》 経験値4",
            36 => "依頼(ハード) \n《概要》 ハンターは任意のキャラクターに他のハンターの【幸福】を守るように依頼され、その依頼を受ける。\n《目的》 他のハンターの【幸福】を一つも結果フェイズまで破壊されないこと。対象となるハンターは、ゲームマスターが指定する。\n《報酬》 経験値4",
            44 => "防衛(ハード) \n《概要》 ハンターは今回の敵となるモンスターに自分の【幸福】を狙われている。モンスターを倒さなければ、【幸福】を守ることはできない。\n《目的》 自分の獲得している【幸福】を一つも結果フェイズで失わないこと。\n《報酬》 経験値4",
            45 => "復讐(ハード) \n《概要》 ハンターは今回の敵となるモンスターに負けたことがある。戦闘に敗北したのか、それとも、【幸福】を壊されたのか。いずれにせよ、復讐の時だ。\n《目的》 結果フェイズまでにモンスターとフォロワー全てを攻撃で倒すこと。自分の攻撃でなくてもかまわない。\n《報酬》 経験値6",
            46 => "関係(ハード) \n《概要》 ハンターは、特定の人物が参加しているから、という理由で狩りに参加する。憧れているのかライバルなのか、単に仲がいいのかは自由。\n《目的》 結果フェイズの時点で他のハンターのうち一人との関係が、お互いに【深度】５になっていること。対象のハンターはシーンプレイヤーが決定する。\n《報酬》 経験値4",
            55 => "挑戦(ハード) \n《概要》 ハンターは今回の敵となるモンスターのことをなんらかの理由で知り、自分から戦いに赴く。\n《目的》 結果フェイズまでハンター全員が一度も無力化されずに生き残り、かつ、フォロワーやモンスターに変化していないこと。\n《報酬》 経験値6",
            56 => "救済(ハード) \n《概要》 ハンターは今回の敵となるフォロワー全員を救うために戦う。\n《目的》 結果フェイズまでにフォロワー全員を「説得」で無力化する。\n《報酬》 経験値6",
            66 => "振り直し"
          }
        ),
        "IDT" => DiceTable::Table.new(
          "導入タイプ決定表(ノーマル)",
          "1D6",
          [
            "依頼\n《概要》 ハンターは任意のキャラクターに他のハンターの【幸福】を守るように依頼され、その依頼を受ける。\n《目的》 他のハンターの【幸福】のうち一つを結果フェイズまで破壊されないこと。この【幸福】は、ゲームマスターが指定する。\n《報酬》　経験値2",
            "防衛\n《概要》 ハンターは今回の敵となるモンスターに【幸福】を狙われている。モンスターを倒さなければ【幸福】を守る事は出来ない。\n《目的》 自分の獲得している【幸福】のうち一つを結果フェイズで失わないこと。この【幸福】はゲームマスターが指定する。\n《報酬》 経験値2",
            "復讐\n《概要》 ハンターは今回の敵となるモンスターに負けたことがある。戦闘に敗北したのか、それとも【幸福】を壊されたのか。いずれにせよ、復讐の時だ。\n《目的》 結果フェイズまでにモンスターを無力化すること。\n《報酬》 経験値２",
            "関係\n《概要》 ハンターは、特定の人物が参加しているから、という理由で狩りに参加する。憧れているのかライバルなのか、単に仲がいいのかは自由。\n《目的》 結果フェイズの時点で他のハンターのうち一人との関係が、お互いに【深度】3以上になっていること。対象のハンターはシーンプレイヤーが決定する。\n《報酬》 経験値２",
            "挑戦\n《概要》 ハンターは今回の敵となるモンスターのことをなんらかの理由で知り、自分から戦いに赴く。\n《目的》 結果フェイズまでハンター全員が生き残り、かつ、フォロワーやモンスターに変化していないこと。\n《報酬》 経験値２",
            "救済\n《概要》 ハンターは今回の敵となるフォロワーのうち一人を救うために戦う。\n《目的》 結果フェイズまでに対象のフォロワーを「説得」で無力化する。このフォロワーはシーンプレイヤーが決定する。\n《報酬》 経験値2"
          ]
        ),
        "RAT" => DiceTable::D66Table.new(
          "関係属性表",
          D66SortType::NO_SORT,
          {
            11 => "愛情",
            12 => "憧れ",
            13 => "怒り",
            14 => "悲しみ",
            15 => "感謝",
            16 => "期待",
            21 => "憧れ",
            22 => "共感",
            23 => "恐怖",
            24 => "嫌悪",
            25 => "困惑",
            26 => "罪悪感",
            31 => "怒り",
            32 => "恐怖",
            33 => "殺意",
            34 => "嫉妬",
            35 => "憎悪",
            36 => "忠義",
            41 => "悲しみ",
            42 => "嫌悪",
            43 => "嫉妬",
            44 => "不信感",
            45 => "侮蔑",
            46 => "保護欲",
            51 => "感謝",
            52 => "困惑",
            53 => "憎悪",
            54 => "侮蔑",
            55 => "満足感",
            56 => "友情",
            61 => "期待",
            62 => "罪悪感",
            63 => "忠義",
            64 => "保護欲",
            65 => "友情",
            66 => "喜び"
          }
        ),
      }.merge(BloodCrusade::TABLES_WITH_BLOOD_MOON).freeze

      register_prefix(TABLES.keys)
    end
  end
end
