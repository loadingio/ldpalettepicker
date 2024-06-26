# merge.ls: merge all palettes in compact into one string
fs = require "fs-extra"
files = fs.readdir-sync \compact .filter(->/\.txt$/.exec(it)).map (f) -> "compact/#f"
ret = files
  .map (f) -> fs.read-file-sync f .toString!split(\\n)
  .reduce(((a,b) -> a ++ b), [])

hash = {}
ret.map ->
  n = it.split(',').0
  if !hash[n] or hash[n].length < it.length => hash[n] = it

ret = [v for k,v of hash].filter -> it
ret.sort!
#ret = Array.from(new Set(ret))
ret1 = ret.join('\\n')
retm = ret.join(\\n)
fs.write-file-sync 'output-one-line.txt', "\"#ret1\""
fs.write-file-sync 'output-multi-line.txt', "#retm"
