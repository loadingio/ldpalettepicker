require! <[fs]>
ldColor = require "./ldColor"

lines = (fs.read-file-sync \data/brandcolors.styl .toString!)split \\n
hash = {}
for line in lines =>
  line = line.split ' = '
  attr = line.0.split \-
  if attr.2 => hash[][attr.1].push line.1

palettes = [{name: k, colors: v, tag: ["brand"]} for k,v of hash]

for pal in palettes =>
  console.log "#{pal.name},#{pal.colors.map(-> ldColor.hex(it).replace('#','')).join(' ')},#{pal.tag.join(',')}"

