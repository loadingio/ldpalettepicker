/*
Palette Format
{
  name: "Palette Name",
  tag: ["tag", "list", ...],
  # either one of below
  colors: [ldColor, ldColor, ...]               # type agnoistic color. we should internally use this
  colors: [{hex: "#999", tag: [...]}, ...]      # hex. color follows ldColor format.
  colors: ["#999", ...]                         # compact but losing color tags
}
*/

# Shorthand tool. should be shared among libraries.
HTMLElement.prototype <<< do
  find: (s, n) ->
    if n == 0 => return @querySelector s
    ret = Array.from(@querySelectorAll s)
    if n => ret[n] else ret
  index: -> Array.from(@parentNode.childNodes).indexOf(@)
  child: -> Array.from(@childNodes)
  parent: (s, e = document) ->
    n = @; while n and n != e => n = n.parentNode # must under e
    if n != e => return null
    n = @; while n and n != e and !n.matches(s) => n = n.parentNode # must match s selector
    if n == e and !e.matches(s) => return null
    return n
  attr: (n,v) -> if !v? => @getAttribute(n) else @setAttribute n, v
  on: (n,cb) -> @addEventListener n, cb
  remove: -> @parentNode.removeChild @
  insertAfter: (n, s) -> s.parentNode.insertBefore n, s.nextSibling

ldPalettePicker = (node, opt = {}) ->
  opt = {palettes: []} <<< opt
  # Prepare DOM
  @root = root = if typeof(node) == typeof('') => node = document.querySelector(node) else node
  @el = el = {}
  el.nv = do
    root: root.find('.navbar',0)
    search: root.find('input[data-tag=search]',0)
  el.pn = do
    vw: root.find('.panel[data-panel=view]',0)
    ed: root.find('.panel[data-panel=edit]',0)
  el.ed = do
    picker: el.pn.ed.find('.ldColorPicker',0)
    pal: el.pn.ed.find('.palette',0)
    colors: el.pn.ed.find('.palette .colors',0)
    hex: el.pn.ed.find('input[data-tag=hex]',0)
    sel: el.pn.ed.find('select',0)
    cfgs: el.pn.ed.find('.config')

  # Prepare content
  content = do
    build: (p = []) -> el.pn.vw.innerHTML = p.map(~> @html it).join ''
    html: (c) ->
      cs = c.colors.map(->"""<div class="color" style="background:#{ldColor.rgbaStr(it)}"></div>""").join("")
      """
      <div class="palette">
        <div class="colors">
        #{cs}
        <div class="ctrl">
        <div class="btn btn-sm" data-action="use"><div class="fa fa-check"></div><div class="desc">USE</div></div>
        <div class="btn btn-sm" data-action="edit"><div class="fa fa-cog"></div><div class="desc">EDIT</div></div>
        </div>
        </div>
        <div class="name">#{c.name}</div>
      </div>
      """


  # Undo System
  log = do
    stack: []
    cur: null
    handle: null
    undo: ~>
      html = log.stack.pop!
      if !html => return
      el.ed.pal.innerHTML = html
      el.ed.colors = el.ed.pal.find('.colors',0)
    push: ->
      if @handle => clearTimeout that
      if !@cur => @cur = el.ed.pal.innerHTML
      @handle = setTimeout (~> 
        if @stack[* - 1] != @cur => @stack.push @cur
        @ <<< handle: null, cur: null
      ), 200

  # Color Picker Initialization
  @ldcp = ldcp = new ldColorPicker el.ed.picker, {inline: true}
  ldcp.on \change, ~> log.push!; edit-update it

  # Input ( Slider, Inputbox ) Initialization
  irs-opt = base: min: 0, max: 255, step: 1, hide_min_max: true, hide_from_to: true, grid: false
  irs-opt  <<< do
    "hsl-h": {} <<< irs-opt.base <<< {max: 360}
    "hsl-s": {} <<< irs-opt.base <<< {max: 1, step: 0.01}
    "hsl-l": {} <<< irs-opt.base <<< {max: 1, step: 0.01}
    "hcl-h": {} <<< irs-opt.base <<< {max: 360}
    "hcl-c": {} <<< irs-opt.base <<< {max: 230}
    "hcl-l": {} <<< irs-opt.base <<< {max: 100}
  irs-opt["rgb-r"] = irs-opt["rgb-g"] = irs-opt["rgb-b"] = irs-opt.base
  <[rgb-r rgb-g rgb-b hsl-h hsl-s hsl-l hcl-h hcl-c hcl-l]>.map ->
    ((t) ->
      v = t.split \-
      # Type in input.value: set ldcp
      root.find(".value[data-tag=#{t}]",0).on \change, (e) ->
        c = ldcp.get-color v.0
        c[v.1] = e.target.value
        ldcp.set-color c
      # Drag in input.ion-slider: set ldcp
      $(root.find(".ion-slider[data-tag=#{t}]",0)).ionRangeSlider irs-opt[t] <<< onChange: (e) ~>
        ldcp._slider = t
        c = ldcp.get-color v.0
        c[v.1] = e.from
        ldcp.set-color c
    ) it
  el.ed.hex.on \change, (e) -> ldcp.set-color e.target.value   # Hex Input
  el.ed.sel.on \change, (e) ~> el.ed.cfgs.map ~>               # Select Box
    it.classList[if it.attr(\data-tag) == e.target.value => \add else \remove] \active

  # Drag to re-order Dynamics
  get-idx = (e) ->
    box = el.ed.colors.getBoundingClientRect!
    idx = (el.ed.colors.find('.color').length * (e.clientX - box.x)) / box.width
  dragger = (e) ~>
    srcidx = dragger.srcidx
    desidx = Math.round(get-idx(e))
    if srcidx == desidx or srcidx + 1 == desidx => return
    log.push!
    src = el.ed.colors.childNodes[srcidx]
    des = el.ed.colors.childNodes[desidx]
    src.remove!
    el.ed.colors.insertBefore src, des
    dragger.srcidx = if desidx < srcidx => desidx else desidx - 1
  el.ed.pal.on \mousedown, (e) ~>
    if !e.target.parent('.colors',el.ed.pal) => return
    dragger.srcidx = Math.floor(get-idx(e))
    document.removeEventListener \mousemove, dragger
    document.addEventListener \mousemove, dragger
  el.ed.pal.on \mouseup,(e)  ~>
    if !e.target.parent('.colors',el.ed.pal) => return
    document.removeEventListener \mousemove, dragger
  document.addEventListener \mouseup, -> document.removeEventListener \mousemove, dragger

  pal-from-node = (n) ->
    name = if n.find('.palette',0) or n.parent('.palette', root) => that.find('.name',0).innerText else 'untitled'
    hexs = if n.find('.colors',0) or n.parent('.colors', root) =>
      that.find('.color').map -> ldColor.hex(it.style.background)
    else []
    return {name, hexs}
  # Use Dynamic
  use-pal = (n) ~>
    {name, hexs} = pal-from-node n
    @fire \use, {name, colors: hexs.map -> ldColor.rgb(it)}

  # Search Dynamics
  search = (v = "") ~>
    if !v => return content.build opt.palettes
    v = v.toLowerCase!trim!
    content.build opt.palettes.filter ->
      it.name.indexOf(v) >= 0 or it.tag.filter(->it.indexOf(v) >= 0).length
    @tab \view
  el.nv.search.on \keyup, (e) -> search (e.target.value or "")

  # Edit Dynamics
  edit-init = (n,opt={}) ~>
    opt = {colors: null, toggle: true, name: \Custom} <<< opt
    if opt.toggle => @tab \edit
    if opt.colors => [hexs,name] = [opt.colors.map(-> ldColor.hex it), opt.name]
    else {name, hexs} = pal-from-node n
    el.ed.colors.innerHTML = hexs
      .map (d,i) ->
        hcl = ldColor.hcl(d)
        """
        <div class="color#{if i => '' else ' active'}#{if hcl.l < 50 => ' dark' else ''}"
        style="background:#d;color:#d">
          <div class="btns">
            <div class="fa fa-clone"></div>
            <div class="fa fa-bars"></div>
            <div class="fa fa-close"></div>
          </div>
        </div>
        """
      .join('')
    el.ed.colors.parentNode.find('.name',0).innerHTML = name
    edit-update hexs.0
    ldcp.set-color hexs.0
  edit-update = (c) ->
    hcl = ldColor.hcl(c)
    node = root.find('.color.active',0)
    node.style.background = ldColor.rgbaStr c
    node.classList[if hcl.l < 50 => "add" else "remove"] \dark
    el.ed.hex.value = ldColor.hex c
    c = {rgb: ldColor.rgb(c), hsl: ldColor.hsl(c), hcl: hcl }
    <[rgb-r rgb-g rgb-b hsl-h hsl-s hsl-l hcl-h hcl-c hcl-l]>.map (t) ~>
      p = t.split \-
      v = c[p.0][p.1]
      if !(t == \hsl-s or t == \hsl-l) => v = Math.round(v)
      root.find(".value[data-tag=#{t}]",0).value = v
      if ldcp._slider == t => return ldcp._slider = null
      $(root.find(".ion-slider[data-tag=#{t}]",0)).data("ionRangeSlider").update from: v


  # General Action
  evts = do
    use: (tgt) ~>
      if !tgt.parent('[data-action=use]',root) => return false
      if (n = tgt.parent(".palette .btn", root)) => return use-pal(n) or true
      if n = tgt.parent(".panel[data-panel=edit]", root) =>
        n = n.find \.palette, 0
        if n => return use-pal(n) or true
    view: (tgt) ~>
      if !(p = tgt.parent(".navbar",root)) => return
      if(n = tgt.parent("*[data-panel=view]", p)) => return @tab \view
      if !(n = tgt.parent("*[data-cat]",p)) => return
      search el.nv.search.value = (n.attr("data-cat") or "")
      return @tab \view
    edit: (tgt) ->
      if !(n = tgt.parent(".palette .btn", root)) => return
      if n.attr(\data-action) == \edit => return edit-init(n) or true
    undo: (tgt) ->
      if (n = tgt.parent("*[data-action=undo]", root)) => return log.undo! or true
    nav: (tgt) ~>
      if tgt.attr \data-panel and tgt.parent('.navbar',root) => return @tab tgt.attr(\data-panel)
    edit-color: (tgt) ->
      btn = tgt.parent('.fa', el.ed.pal)
      color = tgt.parent(".color", el.ed.pal)
      if btn and !btn.classList.contains(\fa-bars) and color.classList.contains \active =>
        if btn.classList.contains \fa-close =>
          log.push!
          if color.classList.contains \active
            sibling = color.parentNode.childNodes[color.index! + 1] or color.parentNode.childNodes[color.index! - 1]
            if sibling => sibling.classList.add \active
          color.remove!
          return true
        if btn.classList.contains \fa-clone =>
          node = color.cloneNode(true)
          color.parentNode.child!map -> it.classList.remove \active
          node.classList.add \active
          color.parentNode.insertAfter node, color
          return true
      if color =>
        color.parentNode.child!map -> it.classList[if it == color => \add else \remove] \active
        ldcp.set-color color.style.background
        return true
  root.addEventListener \click, (e) ~>
    tgt = e.target
    if evts.use(tgt) => return
    if evts.view(tgt) => return
    if evts.edit(tgt) => return
    if evts.undo(tgt) => return
    if evts.nav(tgt) => return
    if evts.edit-color(tgt) => return

  # Final Preparation
  @evt-handler = {}
  content.build opt.palettes
  edit-init null, {colors: <[#b34e19 #d78c51 #f3e7c9]>, toggle: false}

  @

ldPalettePicker.prototype = Object.create(Object.prototype) <<< do
  on: (n, cb) -> @evt-handler.[][n].push cb
  fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v
  tab: (n) -> 
    if !n => return
    idx = if @root.find(".panel[data-panel=#n]",0) => that.index! else -1
    if idx < 0 => return
    @root.find(\.panels,0).style.transform = "translate(#{idx * -100}%,0)"
    @root.find(".nav-link").map -> it.classList[if it.attr(\data-panel) == n => \add else \remove] \active
    true

# Class Methods
ldPalettePicker <<< do
  palettes: []
  parse: do
    text: (txt) ->
      txt.split(\\n).filter(-> it).map (v) ->
        v = v.split(',').map(-> it.toLowerCase!)
        return name: v.0, colors: v.1.split(' ').map(-> "\##it"), tag: v.slice(2)

  register: (name, palettes) ->
    if typeof(palettes) == \string => palettes = @parse.text palettes
    @palettes.push [name, palettes]

  get: (name) -> return (@palettes.filter(-> it.0 == name).0 or ['',[]]).1

  init: (pals = null) ->
    if !pals => pals = @get \default
    Array.from(document.querySelectorAll '*[ldPalettePicker]').map -> new ldPalettePicker it, {palettes: pals}

# Default Color Palette
ldPalettePicker.register "default", """
  flourish,b22 e55 f87 fb6 ab8 898,qualitative
  gray,000 333 666 ddd fff,gradient
  young,fec fe6 cd9 acd 7ab aac,concept
  plotDB,ed1e79 c69c6d 8cc63f 29abe2,brand
  French,37a 9ab eee f98 c10,diverging
  Afghan Girl,010 253 ffd da8 b53,artwork
"""

