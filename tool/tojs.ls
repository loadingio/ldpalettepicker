require! <[fs fs-extra]>
files = fs.readdir-sync \compact

all-pals = []
fs-extra.ensure-dir-sync \js
hash = {}
fs.read-file-sync \compact/loadingio.txt
  .toString!
  .split \\n
  .map -> hash[it.split(\,).0.replace(/ +/g,'').toLowerCase!] = true

map = {}
for file in files =>
  data = filtered = fs.read-file-sync "compact/#file" .toString!split \\n 
  if file != 'loadingio.txt' => filtered = data.filter(-> !hash[it.split(\,).0.replace(/ +/g,'').toLowerCase!])
  data = data.join('\\n')
  all-pals.push filtered.join('\\n')
  name = file.replace(/.txt$/,'')
  fs.write-file-sync "js/#name.palettes.js", """ldpp.register("#name","#data");"""
  map[name] = data

all-code = "(function(){"

names = [k for k of map].filter -> !/cartocolors/.exec(it)

for i from 0 til names.length =>
  name = names[i]
  data = map[name]
  all-code += """
  var d#{i} = "#data";
  ldpp.register("#name",d#i);\n
  """

all-code += """
ldpp.register("all",(#{[0 til names.length].map(-> \d + it).join(\+);}));
}());
"""
fs.write-file-sync "js/all.palettes.js", all-code
