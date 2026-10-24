# merge.ls: merge all palettes in compact into one string
fs = require "fs-extra"
files = fs.readdir-sync \compact .filter(->/\.txt$/.exec(it)).map (f) -> "compact/#f"

# 名字轉成 feature 頁網址的樣子 ( 去空白, `/` 換 `-` ) 後再轉小寫比對:
# 網址保留大小寫, 但只差大小寫的兩筆在不分大小寫的檔案系統 ( macOS ) 上會寫進同一個目錄互相蓋掉
key = (line) -> line.split(',').0.replace(/ /g, '').replace(/\//g, '-').toLowerCase!
# 撞名時 loadingio.txt ( 手動整理 ) 優先, 同來源則留較長的一行
rank = (f) -> if /loadingio\.txt$/.exec(f) => 1 else 0

hash = {}
for f in files =>
  for line in fs.read-file-sync(f).toString!split(\\n) =>
    if !line => continue
    k = key line
    item = {line, f}
    if !(o = hash[k]) => hash[k] = item; continue
    if o.line == line => continue
    better = if rank(f) != rank(o.f) => rank(f) > rank(o.f) else line.length > o.line.length
    [keep, drop] = if better => [item, o] else [o, item]
    hash[k] = keep
    console.log "[dup] keep #{keep.line} (#{keep.f})\n      drop #{drop.line} (#{drop.f})"

ret = [v.line for k,v of hash]
ret.sort!
ret1 = ret.join('\\n')
retm = ret.join(\\n)
fs.write-file-sync 'output-one-line.txt', "\"#ret1\""
fs.write-file-sync 'output-multi-line.txt', "#retm"
