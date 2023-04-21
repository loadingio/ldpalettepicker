(->
  mypal = new ldpage do
    fetch: -> 
      ld$.fetch \assets/sample-palettes.json, {}, {type: \json}
        .then -> it.map ->
          it.payload.colors = it.payload.colors.map -> it.value
          it <<< it.payload
  save = (data) -> new Promise (res, rej) -> console.log data; res!

  # from /assets/ldpp.palettes.js
  ldpp.register("default2", palettes)
  pals = ldpp.get("default2")

  # use default all palettes
  pals = ldpp.get("all")
  ret = ldpp.init({pals: pals, /*useClusterizejs: true*/, mypal: mypal, save: save, use-vscroll: true})
  #console.log pals
  #console.log ret
  ret.0.on \use, -> console.log it
  ret.1.on \use, -> console.log it

  # bring up default palette
  # ldcv.on \toggle.on, -> ret.1.edit {name: "blah", colors: <[#f00 #0f0 #00f]>}, false

  ldpe1 = new ldpe root: '#ldcv-editor .ldpe'
  ldpe2 = new ldpe root: \#ldpe-ex1
  #ldpp1 = new ldpp root: \#ldpp-ex1, palettes: ldpp.get("default")
  #ldpeeditor = new ldpe root: \#ldcv-editor
  #window.ldcv-editor = ldcv-editor = new ldpe root: \#ldcv-editor
  window.ldcv-picker = ldcv-picker = new ldcover({root: document.querySelector('#ldcv-picker')})
  window.ldcv-editor = ldcv-editor = new ldcover({root: document.querySelector('#ldcv-editor')})

  window.image = image = (type = \png) -> ldpalette.convert ldpe1.get-pal!, type .then (ret) ->
    out = document.querySelector(\#image-output)
    if type in <[png svg]> => out.innerHTML = """<img src="#{ret.url}" class="w-100"/>"""
    else 
      fr = new FileReader!
      fr.onload = -> out.innerHTML = fr.result
      fr.readAsText ret.blob
  window.down = down = (type = \png) -> ldpalette.download ldpe1.get-pal!, type
)!
