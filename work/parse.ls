require! <[fs]>
lines = (fs.read-file-sync \min.txt .toString!).split \\n .filter -> it
lines2 = (fs.read-file-sync \brew.txt .toString!).split \\n .filter -> it
lines = lines ++ lines2
pals = []
for line in lines =>
  cells = line.split \,
  ret = cells.1.split ' ' .map -> 
    if it.0 == it.1 and it.2 == it.3 and it.4 == it.5 => return it.0 + it.2 + it.4 else return it
  cells.1 = ret.join(' ')
  pals.push cells

console.log 'var palettes="' + pals.map(->it.join(',')).join('\\n') + '";'
