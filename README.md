# ldPalettePicker

HTML Widget for Palette Picker. Provide following ( should we split them into standalone projects? ):

 * ldPalette - Palette Wrapper. Currently only provide convert / download to png / svg / json / scss functionality.
 * ldPaletteEditor - For editing palette.
 * ldPalettePicker - Picker + Editor


## Usage

Prepare HTML structure with our Pug mixin:

```
    include ldpp.pug
    div(id="...",class="...", ...)
      +ldPalettePicker
```

By default ldPalettePicker doesn't provide styling of the panel / dialog so you can do it in the wrap div.


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


## Configuration

Manually initialize Palette Picker with:

````
    new ldPalettePicker(root, opts);
````

available options:
 * save: (data, key), function for saving palette. save btn will disappear if omitted.
   - expect this to return the saved palette, including its name, key and colors as an object.
 * random: a function or palette list that decide a subset of palette to return when user calling ldpp.random();
 * mypal: should be ldPage object. list user custom palettes. MyPal tab will disappear if omitted.
 * item-per-line: how many palettes per line.
 * className: additional class names to be added on ldpp root.
 * use-clusterizejs: true or false. whether to use clusterizejs or not.
 * ldcv: object, default null.
   if not null, ldPalettePicker will find an ancestor with `ldcv` class, and make itself a ldCover widget.
   user then can invoke ldpp.get! to trigger a ldCover, and wait for the result directly.


## Custom Palettes


example:
```
    ldPalettePicker.register("default2", palettes);
    var pals = ldPalettePicker.get("default2");
    ldPalettePicker.init({pals});
```

ldPalettePicker ships with following prebuilt palette sets, which you can find under `dist` folder:

 * `brandcolors`
    - src: brandcolors.palettes.js
    - palettes from [brandcolors](http://brandcolors.net/).
 * `colorbrewer`
    - src: colorbrewer.palettes.js
    - palettes from [colorbrewer](https://colorbrewer2.org/).
 * `loadingio`
    - loadingio.palettes.js
    - palettes used in [loading.io](https://loading.io/color/feature/).
 * `all`
    - all.palettes.js
    - all palettes above.


## API

ldPalettePicker class function:
 * register(name, palettes) - register a palette list with specific name.
   - name: string for representing this palette list
   - palettes: Array of palette. palette could be in {name, colors} format, or in compact text format.
 * get(name) - get palette list with specific name.
   - name: palette list name registered with register function.
   - return palette in {name, colors} format.
 * init(opt) - init all ldPalettePickers by searching get with `ldPalettePicker` attribute.
   - opt - optional configs to overwrite default settings

ldPalettePicker object function:
 * random(): return a random palette from palette list of this picker.
 * get(): only callable if ldcv is true. return a promise that provide a palette object after user chooses a palette.

## Spec

Palette is defined as following format:

    {
      name: "Palette Name",
      tag: ["tag", "list", ...],
      # either one of below
      colors: [ldColor, ldColor, ...]                 # type agnoistic color. we should internally use this
      colors: [{hex: "#999", tag: [...]}, ...]        # hex. color follows ldColor format.
      colors: ["#999", ...]                           # compact but losing color tags
      # deprecated and we should use ldColor directly instead of  a indirect object with value member.
      colors: [{value: ldColor,...}, {value: ldColor, ...}] 
    }


## License Consideration

For better performance with large amount of palettes, you can enable [Clusterize.js](https://clusterize.js.org/) by setting useClusterizejs to true:

````
    ldPalettePicker.init({useClusterizejs: true});
````

( To make it work you also have to include js and css files of [Clusterize.js](https://clusterize.js.org/). )

Yet Clusterize.js is released under dual license - free for personal use and charge for commercial license. So it's up to your discretion to whether use it or not - and you should acquire necessary license when you use it.

When enabling, Clusterize.js requires another option "itemPerLine", which controls how many palettes are in a line in the list view. Its default value is 2.

## TODO

 * better ordering for default palettes; make it more eye-pleasuring.


## License

MIT License.
