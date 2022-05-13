# Change Log

## v4.0.1

 - fix bug: vscroll causes incorrect palette list when re-open after switching between tabs.
 - always rebuild list if switching to view tab
 - tweak menu bar for responsive design


## v4.0.0

 - upgrade modules
 - release with compact directory structure
 - add `style`, `main` and `browser` field in `package.json`.
 - further minimie generated js file with mangling and compression
 - patch test code to make it work with upgraded modules


## v3.1.8

 - fix bug: vscroll should re-update after ldcv popuped to update dimensional information correctly.
 - fix bug: ldcv should be initialized but content building ( which may use ldcv )


## v3.1.7

 - fix bug: make vscroll probe length longer


## v3.1.6

 - skip clusterizejs only if vscroll is available when `use-vscroll` is set.
 - upgrade modules
 - relocate scroll position for vscroll after ldcv becomes visible.
 - partial update vscroll with a small enought number to increase performance
 - add `default-palette`


## v3.1.5

 - support `@loadingio/vscroll` for optimize palette list browsing.


## v3.1.4

 - fix bug: when clusterize.js enabled, palette list layout is broken due to additional div inserted.


## v3.1.3

 - in all palettes, also provide brandcolor and colorbrewer palettes


## v3.1.2

 - force font size to `1rem` in panel root for sizing consistency


## v3.1.1

 - fix bug: selector for hiding mypal button incorrect
 - tweak ldpp's ldpe layout with flexbox


## v3.1.0

 - tweak ui: use flexbox to layout for more precise result.
 - some changes in CSS may lead to broken ui


## v3.0.4

 - support i18n
 - tweak ui


## v3.0.3

 - update dropdown menu style


## v3.0.2

 - auto init dropdown menu
 - add shadow to dropdown menu


## v3.0.1

 - rename `ldpp.css` to `index.css` for aligning module naming


## v3.0.0

 - reorg dist files - standalone modules with default `index.js` for all-in-one


## v2.0.1

 - bug fix: palettes js files should use lowercase module name.
 - remove local `ldColor` file and use versioned `ldcolor` from npm in `tool` folder
 - check `module` and `window` before initialization
 - support `palette` option for default palette in ldpe and thus ldpp


## v2.0.0

 - adopt newer version of 'ldcover'


## v1.0.2

 - fix bug: ldcover doesn't work if DOM is isolated while initializing


## v1.0.1

 - fix bug: ldrs now use `sm` instead of `ldrs-sm` to control size.


## v1.0.0

 - upgrade modules
 - adopt newer version of `ldcolor`, `ldcolorpicker` and `ldslider`.
 - update all ldp, ldpe, ldpp variables with all lowercase and shorten names.
 - debounce ldpe input box event.
 - prevent unnecessary update of ldslider


## v0.0.6

 - set display to none of tabs after they are hidden to increase performance.


## v0.0.5

 - upgrade ldcolor, tweak package dependencies rule


## v0.0.4

 - upgrade modules


## v0.0.3

 - upgrade modules
 - use deploy module
 - tweak README format
 - add peerDependencies as dependencies too
 - fix bug: get / set should still work even if no ldcv configured.
 - better documentation.
 - reomve useless code ( ldpe opt default values are not used. )


## v0.0.2

 - upgrade modules
 - update builder
   - remove livescript header
   - wrap automatically bu livescript.
