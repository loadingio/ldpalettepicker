require! <[fs]>
files = fs.readdir-sync 'compact' .map -> "compact/#it"
lines = []
for file in files =>
  lines ++= (fs.read-file-sync file .toString!).split \\n .filter -> it

pals = []
for line in lines =>
  cells = line.split \,
  ret = cells.1.split ' ' .map -> 
    if it.0 == it.1 and it.2 == it.3 and it.4 == it.5 => return it.0 + it.2 + it.4 else return it
  cells.1 = ret.join(' ')
  pals.push cells

console.log 'var palettes="' + pals.map(->it.join(',')).join('\\n') + '";'
