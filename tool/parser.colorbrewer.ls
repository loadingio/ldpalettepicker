require! <[fs fs-extra]>
ldColor = require "./ldColor"

fs-extra.ensure-dir-sync "compact"
data = JSON.parse(fs.read-file-sync 'data/colorbrewer.json' .toString!)
output = []
for name,v of data =>
  type = {div: "diverging", seq: "gradient", qual: "qualitative"}[v.type]
  for count,list of v =>
    if !Array.isArray(list) => continue
    ret = do
      name: "#name / #count"
      colors: list
        .map(-> ldColor.hex(it,true))
        .map(-> it.substring 1)
      tag: [type,"colorbrew"]
    output.push "#name / #count,#{ret.colors.join(' ')},#{ret.tag.join(',')}"
fs.write-file-sync "compact/colorbrewer.txt", output.join('\n')
