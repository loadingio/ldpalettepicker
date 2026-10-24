require! <[fs fs-extra]>
files = fs.readdir-sync \compact

all-pals = []
fs-extra.ensure-dir-sync \js
# 跟 merge.ls 同樣的比對方式: 轉成網址的名字後不分大小寫
key = (line) -> line.split(',').0.replace(/ /g, '').replace(/\//g, '-').toLowerCase!
hash = {}
fs.read-file-sync \compact/loadingio.txt
  .toString!
  .split \\n
  .map -> hash[key it] = true

map = {}
for file in files =>
  # 去掉空行: 各檔結尾有沒有換行不一, 接成 all 時才不會兩筆黏在一起
  data = filtered = fs.read-file-sync "compact/#file" .toString!split \\n .filter -> it
  if file != 'loadingio.txt' => filtered = data.filter(-> !hash[key it])
  data = data.join('\\n')
  filtered = filtered.join('\\n')
  all-pals.push filtered
  name = file.replace(/.txt$/,'')
  fs.write-file-sync "js/#name.palettes.js", """ldpp.register("#name","#data");"""
  map[name] = {data, filtered}

all-code = "(function(){"

names = [k for k of map].filter -> !/cartocolors/.exec(it)

# 各來源照原樣註冊; all 用過濾後的 ( 去掉跟 loadingio.txt 重複的 ), 內容一樣就共用變數
for i from 0 til names.length =>
  name = names[i]
  {data, filtered} = map[name]
  all-code += """
  var d#{i} = "#data";
  ldpp.register("#name",d#i);\n
  """
  all-code += if filtered == data => "var f#{i} = d#{i};\n" else "var f#{i} = \"#filtered\";\n"

all-code += """
ldpp.register("all",[#{[0 til names.length].map(-> \f + it).join(\,)}].join("\\n"));
}());
"""
fs.write-file-sync "js/all.palettes.js", all-code
