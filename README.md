# ldPalettePicker

HTML Widget for Palette Picker.


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
 * mypal: should be ldPage object. list user custom palettes. MyPal tab will disappear if omitted.
 * item-per-line: how many palettes per line.
 * className: additional class names to be added on ldpp root.
 * use-clusterizejs: true or false. whether to use clusterizejs or not.



## Custom Palettes


example:
```
    ldPalettePicker.register("default2", palettes);
    var pals = ldPalettePicker.get("default2");
    ldPalettePicker.init(pals);
```


## Spec

Palette is defined as following format:

    {
      name: "Palette Name",
      tag: ["tag", "list", ...],
      # either one of below
      colors: [ldColor, ldColor, ...]               # type agnoistic color. we should internally use this
      colors: [{hex: "#999", tag: [...]}, ...]      # hex. color follows ldColor format.
      colors: ["#999", ...]                         # compact but losing color tags
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
