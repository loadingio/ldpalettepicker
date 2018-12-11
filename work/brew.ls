require! <[fs]>
ldColor = require "./ldColor"

data = JSON.parse(fs.read-file-sync 'colorbrewer.json' .toString!)
for name,v of data =>
  type = {div: "diverging", seq: "gradient", qual: "qualitative"}[v.type]
  for count,list of v =>
    if !Array.isArray(list) => continue
    ret = do
      name: "#name / #count"
      colors: list.map(-> ldColor.hex(it))
      tag: [type,"colorbrew"]
    console.log "#name / #count,#{ret.colors.map(->it.substring(1)).join(' ')},#{ret.tag.join(',')}"
