# ldPalettePicker

HTML Widget for Palette Picker.


## Usage

Prepare HTML structure with our Pug mixin:

```
    include ldpp.pug
    div(id="...",class="...", ...)
      +ldPalettePicker
```

Initialize the widget with JavaScript:

```
    script.
      var ldpp = ldPalettePicker.init();
```

Invoke it when you need a palette:

```
    script.
      ldpp
        .choose()
        .then(function(palette) {
          /* palette structure: 
             {
               name: "<palette-name>",  // name for this palette
               tag: [...],              // tag list for this palette
               colors: [                // color list for this palette
                 {hex: "#000000"},      // color, can be parsed with ldColor.
                 ...
               ]
        })
        .catch(function(err) {
        });
```

## Custom Palettes

example:
```
    ldPalettePicker.register("default2", palettes);
    var pals = ldPalettePicker.get("default2");
    ldPalettePicker.init(pals);
```


## TODO

 * better ordering for default palettes; make it more eye-pleasuring.


## License

MIT License.
