mypal = new ldPage do
  fetch: -> 
    ld$.fetch \sample-palettes.json, {}, {type: \json}
      .then -> it.map ->
        it.payload.colors = it.payload.colors.map -> it.value
        it <<< it.payload

ldPalettePicker.register("default2", palettes)
pals = ldPalettePicker.get("default2")
ldPalettePicker.init({pals: pals, useClusterizejs: true, mypal: mypal})
#ldPalettePicker.init({useClusterizejs: true, mypal: mypal})
ldcv = new ldCover({root: document.querySelector('.ldcv')})

