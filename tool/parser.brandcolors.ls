require! <[fs fs-extra]>
ldColor = require "./ldColor"

fs-extra.ensure-dir-sync \compact

lines = (fs.read-file-sync \data/brandcolors.styl .toString!)split \\n
hash = {}
for line in lines =>
  line = line.split ' = '
  attr = line.0.split \-
  if attr.2 => hash[][attr.1].push line.1

palettes = [{name: k, colors: v, tag: ["brand"]} for k,v of hash]

output = []
for pal in palettes =>
  output.push "#{pal.name},#{pal.colors.map(-> ldColor.hex(it,true).replace('#','')).join(' ')},#{pal.tag.join(',')}"

fs.write-file-sync 'compact/brandcolors.txt', output.join('\n')
