require! <[fs fs-extra]>
files = fs.readdir-sync \compact

all-pals = []
fs-extra.ensure-dir-sync \js
for file in files =>
  data = fs.read-file-sync "compact/#file" .toString!split \\n .join('\\n')
  all-pals.push data
  name = file.replace(/.txt$/,'')
  fs.write-file-sync "js/#name.palettes.js", """ldPalettePicker.register("#name","#data");"""

fs.write-file-sync "js/all.palettes.js", """ldPalettePicker.register("all","#{all-pals.join('\\n')}");"""
