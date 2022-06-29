############# フォーム・アイテム #############
use strict;
#use warnings;
use utf8;
use open ":utf8";

my $LOGIN_ID = $::LOGIN_ID;

### 読込前処理 #######################################################################################
### 各種データライブラリ読み込み --------------------------------------------------
require $set::data_class;
my @magic_classes;
foreach(@data::class_caster){
  if($_ eq 'フェアリーテイマー'){
    push(@magic_classes, '基本妖精魔法', '属性妖精魔法(土)', '属性妖精魔法(水・氷)', '属性妖精魔法(炎)', '属性妖精魔法(風)', '属性妖精魔法(光)', '属性妖精魔法(闇)', '特殊妖精魔法');
  }
  else { push(@magic_classes, $data::class{$_}{'magic'}{'jName'}); }
}
### データ読み込み ###################################################################################
my ($data, $mode, $file, $message) = pcDataGet($::in{'mode'});
our %pc = %{ $data };

my $mode_make = ($mode =~ /^(blanksheet|copy|convert)$/) ? 1 : 0;

### 出力準備 #########################################################################################
if($message){
  my $name = tag_unescape($pc{'category'} eq 'magic' ? $pc{'magicName'} : $pc{'category'} eq 'god' ? $pc{'godAka'}.$pc{'godName'} : '無題');
  $message =~ s/<!NAME>/$name/;
}
### 製作者名 --------------------------------------------------
if($mode_make && !$::make_error){
  $pc{'author'} = (getplayername($LOGIN_ID))[0];
}
### 初期設定 --------------------------------------------------
if($mode_make){ $pc{'protect'} = $LOGIN_ID ? 'account' : 'password'; }

if($mode eq 'blanksheet' && !$::make_error){
  $pc{"magicCost"} = 'MP';
  foreach my $lv (2,4,7,10,13){ $pc{"godMagic${lv}Cost"} = 'MP' }
}
### 改行処理 --------------------------------------------------
foreach (
  'magicEffect',
  'magicDescription',
  'godSymbol',
  'godDeity',
  'godNote',
  'godMagic2Effect',
  'godMagic4Effect',
  'godMagic7Effect',
  'godMagic10Effect',
  'godMagic13Effect',
){
  $pc{$_} =~ s/&lt;br&gt;/\n/g;
}

### 画像 --------------------------------------------------
my $imgurl = shift;
my $image_maxsize = $set::image_maxsize / 4;
  my $image_maxsize_view = $image_maxsize >= 1048576 ? sprintf("%.3g",$image_maxsize/1048576).'MB' : sprintf("%.3g",$image_maxsize/1024).'KB';

### フォーム表示 #####################################################################################
print <<"HTML";
Content-type: text/html\n
<!DOCTYPE html>
<html lang="ja">

<head>
  <meta charset="UTF-8">
  <title>@{[$mode eq 'edit'?"編集：$pc{'itemName'}":'新規作成']} - $set::title</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" media="all" href="${main::core_dir}/skin/_common/css/base.css?${main::ver}">
  <link rel="stylesheet" media="all" href="${main::core_dir}/skin/_common/css/sheet.css?${main::ver}">
  <link rel="stylesheet" media="all" href="${main::core_dir}/skin/sw2/css/item.css?{main::ver}">
  <link rel="stylesheet" media="all" href="${main::core_dir}/skin/_common/css/edit.css?${main::ver}">
  <link rel="stylesheet" media="all" href="${main::core_dir}/skin/sw2/css/edit.css?{main::ver}">
  <script src="${main::core_dir}/skin/_common/js/lib/compressor.min.js"></script>
  <script src="${main::core_dir}/lib/edit.js?${main::ver}" defer></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" integrity="sha512-1ycn6IcaQQ40/MKBW2W4Rhis/DbILU74C1vSrLJxCq57o941Ym01SwNsOMqvEBFlcgUa6xLiPY/NS5R+E6ztJQ==" crossorigin="anonymous" referrerpolicy="no-referrer">
  <script>
    window.onload = function() { checkCategory(); checkMagicClass(); }
    // 送信前チェック ----------------------------------------
    function formCheck(){
      if(form.category.value === ''){
        alert('カテゴリを選択してください。');
        form.category.focus();
        return false;
      }
      else if(form.category.value === 'magic' && form.magicName.value === ''){
        alert('名称を入力してください。');
        form.magicName.focus();
        return false;
      }
      else if(form.category.value === 'god' && form.godName.value === ''){
        alert('名称を入力してください。');
        form.godName.focus();
        return false;
      }
      if(form.protect.value === 'password' && form.pass.value === ''){
        alert('パスワードが入力されていません。');
        form.pass.focus();
        return false;
      }
    }
    
    function checkCategory(){
      const category = form.category.value;
      document.querySelectorAll('article > form .data-area').forEach( obj => {
        obj.style.display = 'none';
      });
      if(category){ document.getElementById('data-'+category).style.display = 'block'; nameSet(category+'Name'); }
      else { document.getElementById('data-none').style.display = 'block'; }
    }
    function checkMagicClass(){
      const magic = form.magicClass.value;
      document.querySelector(`#data-magic .sphere`).style.display = magic == '魔動機術' ? '' : 'none';
    }
  </script>
  <style>
    #image {
      background-image: url("${set::arts_dir}${file}/image.$pc{'image'}?$pc{'imageUpdate'}");
    }
  </style>
</head>
<body>
  <script src="${main::core_dir}/skin/_common/js/common.js?${main::ver}"></script>
  <header>
    <h1>$set::title</h1>
  </header>

  <main>
    <article>
      <form id="arts" name="sheet" method="post" action="./" enctype="multipart/form-data" onsubmit="return formCheck();">
      <input type="hidden" name="ver" value="${main::ver}">
      <input type="hidden" name="type" value="a">
HTML
if($mode_make){
  print '<input type="hidden" name="_token" value="'.token_make().'">'."\n";
}
print <<"HTML";
      <input type="hidden" name="mode" value="@{[ $mode eq 'edit' ? 'save' : 'make' ]}">
            
      <div id="header-menu">
        <h2><span></span></h2>
        <ul>
          <li onclick="view('text-rule')" class="help-button"></li>
          <li class="button">
HTML
if($mode eq 'edit'){
print <<"HTML";
            <input type="button" value="複製" onclick="window.open('./?mode=copy&type=a&id=$::in{'id'}@{[  $::in{'log'}?"&log=$::in{'log'}":'' ]}');">
HTML
}
print <<"HTML";
            <input type="submit" value="保存">
          </li>
        </ul>
      </div>

      <aside class="message">$message</aside>
      
      <section id="section-common">
HTML
if($set::user_reqd){
  print <<"HTML";
    <input type="hidden" name="protect" value="account">
    <input type="hidden" name="protectOld" value="$pc{'protect'}">
    <input type="hidden" name="pass" value="$::in{'pass'}">
HTML
}
else {
  if($set::registerkey && $mode_make){
    print '登録キー：<input type="text" name="registerkey" required>'."\n";
  }
  print <<"HTML";
      <details class="box" id="edit-protect" @{[$mode eq 'edit' ? '':'open']}>
      <summary>編集保護設定</summary>
      <p id="edit-protect-view"><input type="hidden" name="protectOld" value="$pc{'protect'}">
HTML
  if($LOGIN_ID){
    print '<input type="radio" name="protect" value="account"'.($pc{'protect'} eq 'account'?' checked':'').'> アカウントに紐付ける（ログイン中のみ編集可能になります）<br>';
  }
    print '<input type="radio" name="protect" value="password"'.($pc{'protect'} eq 'password'?' checked':'').'> パスワードで保護 ';
  if ($mode eq 'edit' && $pc{'protect'} eq 'password') {
    print '<input type="hidden" name="pass" value="'.$::in{'pass'}.'"><br>';
  } else {
    print '<input type="password" name="pass"><br>';
  }
  print <<"HTML";
<input type="radio" name="protect" value="none"@{[ $pc{'protect'} eq 'none'?' checked':'' ]}> 保護しない（誰でも編集できるようになります）
      </p>
      </details>
HTML
}
  print <<"HTML";
      <dl class="box" id="hide-options">
        <dt>閲覧可否設定</dt>
        <dd id="forbidden-checkbox">
          <select name="forbidden">
            <option value="">内容を全て開示
            <option value="battle" @{[ $pc{'forbidden'} eq 'battle' ? 'selected' : '' ]}>データ・数値のみ秘匿
            <option value="all"    @{[ $pc{'forbidden'} eq 'all'    ? 'selected' : '' ]}>内容を全て秘匿
          </select>
        </dd>
        <dd id="hide-checkbox">
          <select name="hide">
            <option value="">一覧に表示
            <option value="1" @{[ $pc{'hide'} ? 'selected' : '' ]}>一覧には非表示
          </select>
        </dd>
        <dd>
          ※一覧に非表示でもタグ検索結果・マイリストには表示されます
        </dd>
      </dl>
      <div class="box" id="group">
        <dl>
          <dt>タグ</dt><dd>@{[ input 'tags' ]}</dd>
        </dl>
      </div>

      <div class="box" id="name-form">
        <div>
          <dl id="category">
            <dt>カテゴリ</dt>
            <dd><select name="category" oninput="checkCategory();">@{[ option 'category','magic|<魔法>','god|<神格＋特殊神聖魔法>' ]}</select></dd>
          </dl>
        </div>
        <dl id="player-name">
          <dt>製作者</dt>
          <dd>@{[input('author')]}</dd>
        </dl>
      </div>
      <div class="data-area box" id="data-none">
        <p>カテゴリを選択してください。</p>
      </div>
      <!-- 魔法 -->
      <div class="data-area" id="data-magic">
        <div class="box input-data">
          <dl class="name    "><dt>名称      </dt><dd>【@{[ input 'magicName','',"nameSet('magicName')" ]}】<br>@{[ input 'magicActionTypeMinor','checkbox' ]}補助動作　@{[ input 'magicActionTypeSetup','checkbox' ]}戦闘準備</dd></dl>
          <dl class="class   "><dt>系統      </dt><dd><select name="magicClass" oninput="checkMagicClass()">@{[ option 'magicClass',@magic_classes ]}</select> @{[ input 'magicMinor','checkbox' ]}小魔法</dd></dl>
          <dl class="sphere  "><dt>マギスフィア</dt><dd>@{[ input 'magicMagisphere','','','list="list-sphere"' ]}</dd></dl>
          <dl class="level   "><dt>習得レベル</dt><dd>@{[ input 'magicLevel' ]}</dd></dl>
          <dl class="cost    "><dt>消費      </dt><dd>@{[ input 'magicCost' ]}</dd></dl>
          <dl class="target  "><dt>対象      </dt><dd>@{[ input 'magicTarget','','','list="list-target"' ]}</dd></dl>
          <dl class="range   "><dt>射程／形状</dt><dd>@{[ input 'magicRange','','','list="list-range"' ]}／@{[ input 'magicForm','','','list="list-form"' ]}</dd></dl>
          <dl class="duration"><dt>時間      </dt><dd>@{[ input 'magicDuration','','','list="list-duration"' ]}</dd></dl>
          <dl class="resist  "><dt>抵抗      </dt><dd>@{[ input 'magicResist','','','list="list-resist"' ]}</dd></dl>
          <dl class="element "><dt>属性      </dt><dd>@{[ input 'magicElement','','','list="list-element"' ]}</dd></dl>
          <dl class="summary "><dt>概要      </dt><dd>@{[ input 'magicSummary' ]}</dd></dl>
          <dl class="effect  "><dt>効果      </dt><dd><textarea name="magicEffect">$pc{'magicEffect'}</textarea></dd></dl>
          
        </div>
        <div class="box">
          <h2>由来・逸話など</h2>
          <textarea name="magicDescription">$pc{'magicDescription'}</textarea>
        </div>
      </div>
      <!-- 神格 -->
      <div class="data-area" id="data-god">
        <div class="box input-data">
          <div id="image" style="">
            <h2>聖印の画像</h2>
            <p>
              プレビューエリアに画像ファイルをドロップ、または
              <input type="file" accept="image/*" name="imageFile" onchange="imagePreView(this.files[0], $image_maxsize || 0)"><br>
              ※ ファイルサイズ @{[ $image_maxsize_view ]} までの JPG/PNG/GIF/WebP
              <small>（サイズを超過する場合、自動的にWebP形式に変換し、その上でまだ超過している場合は縮小処理が行われます）</small>
              <input type="hidden" name="imageCompressed">
              <input type="hidden" name="imageCompressedType">
            </p>
            <p>
              <input type="checkbox" name="imageDelete" value="1"> 画像を削除する
              @{[input('image','hidden')]}
            </p>
          <script>
            const imageType = 'symbol';
            let imgURL = "${imgurl}";
          </script>
          </div>
          <dl class="name  "><dt>名称      </dt><dd>@{[ input 'godName','',"nameSet('godName')" ]}</dd></dl>
          <dl class="aka   "><dt>異名      </dt><dd>“@{[ input 'godAka','',"nameSet('godName')" ]}”</dd></dl>
          <dl class="class "><dt>系統      </dt><dd><select name="godClass">@{[ option 'godClass','第一の剣','第二の剣','第三の剣','不明' ]}</select>／<select name="godRank">@{[ option 'godRank','古代神','大神','小神' ]}</select></dd></dl>
          <dl class="area  "><dt>地域      </dt><dd>@{[ input 'godArea','','','placeholder="大陸・地方など"' ]}<small>※主に小神向けの項目です</small></dd></dl>
          <dl class="symbol"><dt>聖印と神像</dt><dd><textarea name="godSymbol">$pc{'godSymbol'}</textarea></dd></dl>
          <dl class="deity "><dt>神格と教義</dt><dd><textarea name="godDeity">$pc{'godDeity'}</textarea></dd></dl>
          <dl class="maxim "><dt>格言      </dt><dd>「@{[ input "godMaxim1" ]}」<br>「@{[ input "godMaxim2" ]}」<br>「@{[ input "godMaxim3" ]}」</dd></dl>
          <dl class="deity "><dt>備考      </dt><dd><textarea name="godNote" placeholder="他神との関係やその他逸話、データの諸注意などなんでも">$pc{'godNote'}</textarea></dd></dl>
        </div>
        <div class="box input-data">
HTML
foreach my $lv (2,4,7,10,13){
print <<"HTML";
          <h2>特殊神聖魔法 ${lv}レベル</h2>
          <dl class="name    "><dt>名称      </dt><dd>【@{[ input "godMagic${lv}Name",'' ]}】<br>@{[ input "godMagic${lv}ActionTypeMinor",'checkbox' ]}補助動作　@{[ input "godMagic${lv}ActionTypeSetup",'checkbox' ]}戦闘準備</dd></dl>
          <dl class="cost    "><dt>消費      </dt><dd>@{[ input "godMagic${lv}Cost" ]}</dd></dl>
          <dl class="target  "><dt>対象      </dt><dd>@{[ input "godMagic${lv}Target",'','','list="list-target"' ]}</dd></dl>
          <dl class="range   "><dt>射程／形状</dt><dd>@{[ input "godMagic${lv}Range",'','','list="list-range"' ]}／@{[ input "godMagic${lv}Form",'','','list="list-form"' ]}</dd></dl>
          <dl class="duration"><dt>時間      </dt><dd>@{[ input "godMagic${lv}Duration",'','','list="list-duration"' ]}</dd></dl>
          <dl class="resist  "><dt>抵抗      </dt><dd>@{[ input "godMagic${lv}Resist",'','','list="list-resist"' ]}</dd></dl>
          <dl class="element "><dt>属性      </dt><dd>@{[ input "godMagic${lv}Element",'','','list="list-element"' ]}</dd></dl>
          <dl class="summary "><dt>概要      </dt><dd>@{[ input "godMagic${lv}Summary" ]}</dd></dl>
          <dl class="effect  "><dt>効果      </dt><dd><textarea name="godMagic${lv}Effect">$pc{"godMagic${lv}Effect"}</textarea></dd></dl>
HTML
}
print <<"HTML";
        </div>
      </div>
    </section>
    
      @{[ input 'birthTime','hidden' ]}
      <input type="hidden" name="id" value="$::in{'id'}">
    </form>
HTML
if($mode eq 'edit'){
print <<"HTML";
    <form name="del" method="post" action="./" id="deleteform">
      <p style="font-size: 80%;">
      <input type="hidden" name="mode" value="delete">
      <input type="hidden" name="type" value="a">
      <input type="hidden" name="id" value="$::in{'id'}">
      <input type="hidden" name="pass" value="$::in{'pass'}">
      <input type="checkbox" name="check1" value="1" required>
      <input type="checkbox" name="check2" value="1" required>
      <input type="checkbox" name="check3" value="1" required>
      <input type="submit" value="シート削除"><br>
      ※チェックを全て入れてください
      </p>
    </form>
HTML
}
print <<"HTML";
    </article>
HTML
# ヘルプ
my $text_rule = <<"HTML";
        アイコン<br>
        　魔法のアイテム：<code>[魔]</code>：<img class="i-icon" src="${set::icon_dir}wp_magic.png"><br>
        　刃武器　　　　：<code>[刃]</code>：<img class="i-icon" src="${set::icon_dir}wp_edge.png"><br>
        　打撃武器　　　：<code>[打]</code>：<img class="i-icon" src="${set::icon_dir}wp_blow.png"><br>
HTML
print textRuleArea( $text_rule,'「効果」「備考」「由来・逸話など」' );

print <<"HTML";
  </main>
  <footer>
    『ソード・ワールド2.5』は、「グループSNE」及び「KADOKAWA」の著作物です。<br>
    　ゆとシートⅡ for SW2.5 ver.${main::ver} - ゆとらいず工房
  </footer>
  <datalist id="list-target">
    <option value="術者">
    <option value="1体">
    <option value="1体全">
    <option value="1体X">
    <option value="物体1つ">
    <option value="任意の地点">
    <option value="接触点">
    <option value="1エリア(半径3m)／5">
    <option value="1エリア(半径4m)／10">
    <option value="1エリア(半径5m)／15">
    <option value="1エリア(半径6m)／20">
    <option value="1エリア(半径6m)／すべて">
    <option value="2～3エリア(半径10m)／すべて">
    <option value="全エリア(半径20m)／すべて">
    <option value="全エリア(半径30m)／すべて">
    <option value="1エリア(半径2m)／空間">
    <option value="1エリア(半径3m)／空間">
    <option value="1エリア(半径4m)／空間">
    <option value="1エリア(半径5m)／空間">
    <option value="1エリア(半径6m)／空間">
    <option value="2～3エリア(半径10m)／空間">
    <option value="全エリア(半径20m)／空間">
    <option value="全エリア(半径30m)／空間">
  </datalist>
  <datalist id="list-range">
    <option value="術者">
    <option value="接触">
    <option value="1(10m)">
    <option value="2(20m)">
    <option value="2(30m)">
    <option value="2(50m)">
    <option value="2(無限)">
    <option value="2()">
  </datalist>
  <datalist id="list-form">
    <option value="―">
    <option value="射撃">
    <option value="起点指定">
    <option value="貫通">
    <option value="突破">
  </datalist>
  <datalist id="list-duration">
    <option value="一瞬">
    <option value="10秒(1ラウンド)">
    <option value="30秒(3ラウンド)">
    <option value="1分(6ラウンド)">
    <option value="3分(18ラウンド)">
    <option value="10分(60ラウンド)">
    <option value="1時間">
    <option value="3時間">
    <option value="6時間">
    <option value="1日">
    <option value="永続">
    <option value="特殊">
    <option value="さまざま">
    <option value="一瞬／10秒(1ラウンド)">
    <option value="一瞬／30秒(3ラウンド)">
    <option value="一瞬／1分(6ラウンド)">
    <option value="一瞬／3分(18ラウンド)">
    <option value="一瞬／10分(60ラウンド)">
    <option value="一瞬／1時間">
    <option value="一瞬／1日">
    <option value="一瞬／さまざま">
  </datalist>
  <datalist id="list-resist">
    <option value="なし">
    <option value="任意">
    <option value="消滅">
    <option value="半減">
    <option value="短縮">
    <option value="必中">
  </datalist>
  <datalist id="list-element">
    <option value="土">
    <option value="水・氷">
    <option value="炎">
    <option value="風">
    <option value="雷">
    <option value="純エネルギー">
    <option value="断空">
    <option value="衝撃">
    <option value="毒">
    <option value="病気">
    <option value="精神効果">
    <option value="精神効果（弱）">
    <option value="呪い">
    <option value="呪い＋精神効果">
  </datalist>
  <datalist id="list-sphere">
    <option value="小">
    <option value="中">
    <option value="大">
    <option value="大中小">
    <option value="大（＿個）">
  </datalist>
<script>
function view(viewId){
  let value = document.getElementById(viewId).style.display;
  document.getElementById(viewId).style.display = (value === 'none') ? '' : 'none';
}
</script>
</body>
</html>
HTML

1;