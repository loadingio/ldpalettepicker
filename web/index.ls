mypal = new ldPage do
  fetch: -> 
    ld$.fetch \sample-palettes.json, {}, {type: \json}
      .then -> it.map ->
        it.payload.colors = it.payload.colors.map -> it.value
        it <<< it.payload
save = (data) -> new Promise (res, rej) -> console.log data; res!

ldPalettePicker.register("default2", palettes)
pals = ldPalettePicker.get("default2")
ret = ldPalettePicker.init({pals: pals, useClusterizejs: true, mypal: mypal, save: save})
ldcv = new ldCover({root: document.querySelector('.ldcv')})

# bring up default palette
# ldcv.on \toggle.on, -> ret.1.edit {name: "blah", colors: <[#f00 #0f0 #00f]>}, false

ldpe = new ldPaletteEditor root: \#editor
new ldPaletteEditor root: \#ldcv-editor
ldcv-editor = new ldCover({root: \#ldcv-editor})

image = (type = \png) -> ldPalette.convert ldpe.get-pal!, type .then (ret) ->
  out = document.querySelector(\#image-output)
  if type in <[png svg]> => out.innerHTML = """<img src="#{ret.url}"/>"""
  else 
    fr = new FileReader!
    fr.onload = -> out.innerHTML = fr.result
    fr.readAsText ret.blob
down = (type = \png) -> ldPalette.download ldpe.get-pal!, type
