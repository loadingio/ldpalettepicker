(->
  mypal = new ldPage do
    fetch: -> 
      ld$.fetch \assets/sample-palettes.json, {}, {type: \json}
        .then -> it.map ->
          it.payload.colors = it.payload.colors.map -> it.value
          it <<< it.payload
  save = (data) -> new Promise (res, rej) -> console.log data; res!

  ldPalettePicker.register("default2", palettes)
  pals = ldPalettePicker.get("default2")
  ret = ldPalettePicker.init({pals: pals, useClusterizejs: true, mypal: mypal, save: save})

  # bring up default palette
  # ldcv.on \toggle.on, -> ret.1.edit {name: "blah", colors: <[#f00 #0f0 #00f]>}, false

  ldpe = new ldPaletteEditor root: '#ldcv-editor .ldpe'
  ldpe1 = new ldPaletteEditor root: \#ldpe-ex1
  #ldpp1 = new ldPalettePicker root: \#ldpp-ex1, palettes: ldPalettePicker.get("default")
  #ldpeeditor = new ldPaletteEditor root: \#ldcv-editor
  #window.ldcv-editor = ldcv-editor = new ldPaletteEditor root: \#ldcv-editor
  window.ldcv-picker = ldcv-picker = new ldCover({root: document.querySelector('#ldcv-picker')})
  window.ldcv-editor = ldcv-editor = new ldCover({root: document.querySelector('#ldcv-editor')})

  window.image = image = (type = \png) -> ldPalette.convert ldpe.get-pal!, type .then (ret) ->
    out = document.querySelector(\#image-output)
    if type in <[png svg]> => out.innerHTML = """<img src="#{ret.url}" class="w-100"/>"""
    else 
      fr = new FileReader!
      fr.onload = -> out.innerHTML = fr.result
      fr.readAsText ret.blob
  window.down = down = (type = \png) -> ldPalette.download ldpe.get-pal!, type
)!
