require! <[fs fs-extra]>
ldColor = require "./ldColor"

fs-extra.ensure-dir-sync \compact

lines = (fs.read-file-sync \data/brandcolors.styl .toString!)split \\n
hash = {}
for line in lines =>
  line = line.split ' = '
  attr = line.0.split \-
  v = +attr[* - 1]
  if isNaN(v) => continue
  n = attr.splice(1, attr.length - 2).join(' ')
  hash[][n].push line.1

for k,v of hash => if v.length > 11 => delete hash[k]
palettes = [{name: k, colors: v, tag: ["brand"]} for k,v of hash]

output = []
for pal in palettes =>
  output.push "#{pal.name},#{pal.colors.map(-> ldColor.hex(it,true).replace('#','')).join(' ')},#{pal.tag.join(',')}"

fs.write-file-sync 'compact/brandcolors.txt', output.join('\n')
