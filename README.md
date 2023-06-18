# ldPalettePicker

Palette related tools including:

 - `ldpalette`: palette class.
 - `ldpe`: palette editor
 - `ldpp`: palette picker + editor


## Palette Definition

In ldPalettePicker, a palette is defined in following format:

    {
      name: "Palette Name",
      tag: ["tag", "list", ...],
      # either one of below
      colors: [ldColor, ldColor, ...]                 # type agnoistic color. we should internally use this
      colors: [{hex: "#999", tag: [...]}, ...]        # hex. color follows ldColor format.
      colors: ["#999", ...]                           # compact but losing color tags
      # deprecated and we should use ldColor directly instead of  a indirect object with value member.
      colors: [{value: ldColor,...}, {value: ldColor, ...}]
      key: "somekey"                                  # optional key for identifying this palette
    }


## ldpalette

`ldpalette` - defined in `ldp.js` - is expected to be a JS object for palette, but currently it only provide 2 class methods:

 - `convert(pal, type)`: convert given pal into specific type
   - return promise which resolves an object with following fields:
     - `blob`: blob for the specified format.
     - `url`: object url of the above blob.
     - `filename`: file named after the palette.
   - `pal`: palette defined as in the palette definition.
   - `type`: either `json`, `svg`, `png` or `scss`. default `png`.
 - `download(pal, type)`: convert given palette into specific type, and trigger download of the result file.
   - `return`: promise resolved when download triggered.
   - `pal`, `type`: the same with `convert`.

Sample usage:

    ldpalette.convert({colors:["#f00","#0f0"]},"svg").then(function(blob) { ... })

Object methods are left to implement in the future.


## ldpe

`ldpe` - defined in `ldpe.js` - provides palette editing functionality. usage:

    editor = new ldpe({ ... });

where constructor options:

 - `root`: root node of a ldpe widget. use `ldpe` mixin in ldpp.pug for a default widget DOM.

### API

 - `syncUi`: update slider in ui when out of sync ( need review )
 - `getPal`: get current palette
 - `init(opt)`: (re)init editor with given option, including:
   - `pal`: palette object for initing this editor.
 - `undo`: undo last action
 - `clearLog`: clear undo history


## ldpp

`ldpp` - defined in `ldpp.js` - provides a simple way to pick / customize palettes. Usage:

    picker = new ldpp({ ... });

HTML counterpart: ( in Pug )

    include ldpp.pug
    div(id="...",class="...", ...)
      +ldpp

or, when using along with `ldCover`:

    include ldpp.pug
    .ldcv(id="...",class="...", ...): .base: .inner
      +ldpp

where constructor options:

 - `palettes`: default palette.
 - `i18n`: object for i18n. if provided, should at least support following API:
   - `addResourceBundles(resObj)`: add resource bundles for multiple languages in `resObj`.
   - `t(text)`: translate text 
 - `itemPerLine`: how many palette per line in editor. default 2
 - `root`: root node of a ldpp widget. use `ldpp` mixin in ldpp.pug for a default widget DOM.
 - `className`: additional class names ( in space separated string ) to add in root. default ''
 - `useClusterizejs`: enable `clusterize.js` if true and `Clusterize` is available.
   - default false
   - Can enormously reduce dom element counts.
   - require dual licensed `clusterize.js` library
 - `useVscroll`: enable `@loadingio/vscroll` if true and `vscroll` is available.
   - default false
   - Can enormously reduce dom element counts.
   - based on `@loadingio/vscroll`, MIT Licensed.
 - `ldcv`: default false. if provided and ldCover is available, a ldcv object will be created automatically with this object as constructor options.
 - `random`: if provided, serve as random palette. (TBD)
 - `mypal`: optional ldPage object for loading customized palette on scrolling.
 - `save`: optional function for saving a palette.
    - return a promise which resolves to the saved palette.
    - accepting object with following options:
      - thumb: thumbnail of the given palette.
      - key: key of the given palette, if applicable.
      - data:
        - name: palette name.
        - type: "palette"
        - payload: a palette object.

### API

 - `on(name, cb)`: listen to `name` event with `cb` callback function.
 - `fire(name, ...params)`: fire an event named `name` with parameters `params`.
 - `get()`: prompt ( or simply wait ) users to pick a palette. return a promise resolving a palette picked.
 - `tab(n)`: switch to the tab named `n`.
 - `edit(pal, toggle)`: edit palette `pal`. 
   - `pal`: palette to edit.
   - `toggle`: default true. if true, toggle the edit panel.
 - `random()`: a function or palette list that decide a subset of palette to return when user calling ldpp.random();


## Class Method

ldPaletePicker also provided following helper functions:

 - `register(name, palettes)`: register provided palette list with the specified name.
 - `get(name)`: get palette list with the given name.
 - `init(opt)`: init all palette picker by querying `[ldpp]` selector.
   - return a list of `ldpp` object.
   - `pals`: optional. Array of palettes. when provided, all pickers will be initialized with palettes given here.
     - when omitted, pickers will be inited with the palette list named `default` ( builtin palettes ).

After `ldpp.js` loaded, you can optional load following palette list with given name:

 - `all` - defined in `all.palettes.js`
 - `brandcolors` - defined in `brandcolors.palettes.js`
 - `colorbrewer` - defined in `colorbrewer.palettes.js`
 - `loadingio` - defined in `loadingio.palettes.js`

### Sample Usage

Use `get` to prompt user for a picked palette:

    script.
      ldpp.get!
        .then (pal) ->
        .catch ->


## Custom Palettes

example:

    ldpp.register("default2", palettes);
    var pals = ldpp.get("default2");
    ldpp.init({pals});


ldPalettePicker ships with following prebuilt palette sets, which you can find under `dist` folder:

 * `brandcolors`
    - src: brandcolors.palettes.js
    - palettes from [brandcolors](http://brandcolors.net/).
 * `colorbrewer`
    - src: colorbrewer.palettes.js
    - palettes from [colorbrewer](https://colorbrewer2.org/).
    - license: Apache license Version 2.0
 * `cartocolors`
    - cartocolors.palettes.js
    - palettes from [CARTOColors](https://github.com/CartoDB/cartocolor)
    - license: CC-BY 3.0 License.
 * `loadingio`
    - loadingio.palettes.js
    - palettes used in [loading.io](https://loading.io/color/feature/).
 * `all`
    - all.palettes.js
    - palettes from `brandcolors` + `colorbrewer` + `loadingio`.


## License Consideration

For better performance with large amount of palettes, you can enable [Clusterize.js](https://clusterize.js.org/) by setting useClusterizejs to true:

    ldpp.init({useClusterizejs: true});


( To make it work you also have to include js and css files of [Clusterize.js](https://clusterize.js.org/). )

Yet Clusterize.js is released under dual license - free for personal use and charge for commercial license. So it's up to your discretion to whether use it or not - and you should acquire necessary license when you use it.

When enabling, Clusterize.js requires another option "itemPerLine", which controls how many palettes are in a line in the list view. Its default value is 2.

Alternatively you can use `@loadingio/vscroll` which is released under MIT license.


## TODO

 * better ordering for default palettes; make it more eye-pleasuring.


## License

MIT License.
