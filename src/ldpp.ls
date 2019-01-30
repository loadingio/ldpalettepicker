ldPalettePicker = (node, opt = {}) ->
  opt = {palettes: [], item-per-line: 2} <<< opt
  @pals = view: opt.palettes
  # Prepare DOM
  @root = root = if typeof(node) == typeof('') => node = document.querySelector(node) else node
  @el = el = {}
  el.nv = do
    root: ld$.find(root, '.navbar', 0)
    search: ld$.find(root, 'input[data-tag=search]',0)
  el.pn = do
    view: ld$.find(root, '.panel[data-panel=view]',0)
    mypal: ld$.find(root, '.panel[data-panel=mypal]',0)
    edit: ld$.find(root, '.panel[data-panel=edit]',0)
  el.pnin = do
    view: ld$.find(el.pn.view, '.inner', 0)
    mypal: ld$.find(el.pn.mypal, '.inner', 0)
  el.ed = do
    picker: ld$.find(el.pn.edit,'.ldColorPicker',0)
    pal: ld$.find(el.pn.edit,'.palette',0)
    colors: ld$.find(el.pn.edit,'.palette .colors',0)
    hex: ld$.find(el.pn.edit,'input[data-tag=hex]',0)
    sel: ld$.find(el.pn.edit,'select',0)
    cfgs: ld$.find(el.pn.edit,'.config')

  # Prepare content
  content = do
    pals: {}
    add: (tab=\view, p) ->
      if !@pals[tab] => @pals[tab] = []
      @pals[tab] ++= (p.map ~> {html: @html(it), obj: it})
    build: (p = [], tgt='view') ->
      rows = p.map -> it.html
      if rows.length == 0 => return el.pnin[tgt]innerHTML = "no result..."
      if opt.use-clusterizejs  =>
        lines = []
        for i from 0 til rows.length by opt.item-per-line => 
          line = []
          for j from 0 til opt.item-per-line => line.push rows[i + j]
          lines.push """<div>#{line.join('')}</div>"""
        new Clusterize do
          rows: lines
          contentElem: el.pnin[tgt]
          scrollElem: el.pn[tgt]
      else el.pnin[tgt]innerHTML = rows.join('')
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

  #Custom Palette List
  if opt.mypal? => # mypal should be a ldPage instance
    mypal = do
      page: Object.create(opt.mypal)
      fetch: -> 
        @page.fetch!then (ret) ->
          content.add \mypal, ret
          content.build content.pals.mypal, 'mypal'
    mypal.page
      ..set-host el.pn.mypal
      ..on \scroll.fetch, ->
        content.add \mypal, it
        content.build content.pals.mypal, 'mypal'

  # Undo System
  log = do
    stack: []
    cur: null
    handle: null
    undo: ~>
      html = log.stack.pop!
      if !html => return
      el.ed.pal.innerHTML = html
      el.ed.colors = ld$.find(el.ed.pal,'.colors',0)
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
      ld$.find(root,".value[data-tag=#{t}]",0).addEventListener \change, (e) ->
        c = ldcp.get-color v.0
        c[v.1] = e.target.value
        ldcp.set-color c
      # Drag in input.ion-slider: set ldcp
      $(ld$.find(root,".ion-slider[data-tag=#{t}]",0)).ionRangeSlider irs-opt[t] <<< onChange: (e) ~>
        ldcp._slider = t
        c = ldcp.get-color v.0
        c[v.1] = e.from
        ldcp.set-color c
    ) it
  el.ed.hex.addEventListener \change, (e) -> ldcp.set-color e.target.value   # Hex Input
  el.ed.sel.addEventListener \change, (e) ~> el.ed.cfgs.map ~>               # Select Box
    it.classList[if it.attr(\data-tag) == e.target.value => \add else \remove] \active

  # Drag to re-order Dynamics
  get-idx = (e) ->
    box = el.ed.colors.getBoundingClientRect!
    idx = (ld$.find(el.ed.colors,'.color').length * (e.clientX - box.x)) / box.width
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
  el.ed.pal.addEventListener \mousedown, (e) ~>
    if !ld$.parent(e.target,'.colors',el.ed.pal) => return
    dragger.srcidx = Math.floor(get-idx(e))
    document.removeEventListener \mousemove, dragger
    document.addEventListener \mousemove, dragger
  el.ed.pal.addEventListener \mouseup,(e)  ~>
    if !ld$.parent(e.target,'.colors',el.ed.pal) => return
    document.removeEventListener \mousemove, dragger
  document.addEventListener \mouseup, -> document.removeEventListener \mousemove, dragger

  pal-from-node = (n) ->
    name = if ld$.find(n,'.palette',0) or ld$.parent(n,'.palette', root) =>
      ld$.find(that,'.name',0).innerText
    else 'untitled'
    hexs = if ld$.find(n,'.colors',0) or ld$.parent(n, '.colors', root) =>
      ld$.find(that,'.color').map -> ldColor.hex(it.style.background)
    else []
    return {name, hexs}
  # Use Dynamic
  use-pal = (n) ~>
    {name, hexs} = pal-from-node n
    @fire \use, {name, colors: hexs.map -> ldColor.rgb(it)}

  # Search Dynamics
  search = (v = "") ~>
    n = ld$.find(el.nv.root,'.active',0)
    pal = if n => ld$.attr(n, \data-panel) else \view
    if !v => return content.build (content.pals[pal] or []), pal
    v = v.toLowerCase!trim!
    content.build(
      (content.pals[pal] or []).filter(->
        it.obj.name.indexOf(v) >= 0 or (it.obj.tag or []).filter(->it.indexOf(v) >= 0).length),
      pal)
    @tab pal
  el.nv.search.addEventListener \keyup, (e) -> search (e.target.value or "")

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
    ld$.find(el.ed.colors.parentNode,'.name',0).innerHTML = name
    edit-update hexs.0
    ldcp.set-color hexs.0
  edit-update = (c) ->
    hcl = ldColor.hcl(c)
    node = ld$.find(root,'.color.active',0)
    node.style.background = ldColor.rgbaStr c
    node.classList[if hcl.l < 50 => "add" else "remove"] \dark
    el.ed.hex.value = ldColor.hex c
    c = {rgb: ldColor.rgb(c), hsl: ldColor.hsl(c), hcl: hcl }
    <[rgb-r rgb-g rgb-b hsl-h hsl-s hsl-l hcl-h hcl-c hcl-l]>.map (t) ~>
      p = t.split \-
      v = c[p.0][p.1]
      if !(t == \hsl-s or t == \hsl-l) => v = Math.round(v)
      ld$.find(root,".value[data-tag=#{t}]",0).value = v
      if ldcp._slider == t => return ldcp._slider = null
      $(ld$.find(root,".ion-slider[data-tag=#{t}]",0)).data("ionRangeSlider").update from: v


  # General Action
  evts = do
    use: (tgt) ~>
      if !ld$.parent(tgt,'[data-action=use]',root) => return false
      if (n = ld$.parent(tgt,".palette .btn", root)) => return use-pal(n) or true
      if n = ld$.parent(tgt,".panel[data-panel=edit]", root) =>
        n = ld$.find n, \.palette, 0
        if n => return use-pal(n) or true
    mypal: (tgt) ~>
      if !(p = ld$.parent(tgt,".navbar",root)) => return
      if(n = ld$.parent(tgt,"*[data-panel=mypal]", p)) =>
        if !(mypal?) => return @tab \view
        mypal.fetch!
        return @tab \mypal
    view: (tgt) ~>
      if !(p = ld$.parent(tgt,".navbar",root)) => return
      if(n = ld$.parent(tgt,"*[data-panel=view]", p)) => return @tab \view
      if !(n = ld$.parent(tgt,"*[data-cat]",p)) => return
      search el.nv.search.value = (ld$.attr(n,"data-cat") or "")
      return @tab \view
    edit: (tgt) ->
      if !(n = ld$.parent(tgt,".palette .btn", root)) => return
      if ld$.attr(n,\data-action) == \edit => return edit-init(n) or true
    undo: (tgt) ->
      if (n = ld$.parent(tgt,"*[data-action=undo]", root)) => return log.undo! or true
    nav: (tgt) ~>
      if ld$.attr(tgt, \data-panel) and ld$.parent(tgt,'.navbar',root) => return @tab ld$.attr(tgt,\data-panel)
    edit-color: (tgt) ->
      btn = ld$.parent(tgt,'.fa', el.ed.pal)
      color = ld$.parent(tgt,".color", el.ed.pal)
      if btn and !btn.classList.contains(\fa-bars) and color.classList.contains \active =>
        if btn.classList.contains \fa-close =>
          log.push!
          if color.classList.contains \active
            sibling = (color.parentNode.childNodes[ld$.index(color) + 1] 
              or color.parentNode.childNodes[ld$.index(color) - 1])
            if sibling => sibling.classList.add \active
          color.remove!
          return true
        if btn.classList.contains \fa-clone =>
          node = color.cloneNode(true)
          ld$.child(color.parentNode).map -> it.classList.remove \active
          node.classList.add \active
          ld$.insertAfter(color.parentNode, node, color)
          return true
      if color =>
        ld$.child(color.parentNode).map -> it.classList[if it == color => \add else \remove] \active
        ldcp.set-color color.style.background
        return true
  root.addEventListener \click, (e) ~>
    tgt = e.target
    if evts.use(tgt) => return
    if evts.mypal(tgt) => return
    if evts.view(tgt) => return
    if evts.edit(tgt) => return
    if evts.undo(tgt) => return
    if evts.nav(tgt) => return
    if evts.edit-color(tgt) => return

  # Final Preparation
  @evt-handler = {}
  content.add \view, opt.palettes
  content.build content.pals.view
  edit-init null, {colors: <[#b34e19 #d78c51 #f3e7c9]>, toggle: false}

  @

ldPalettePicker.prototype = Object.create(Object.prototype) <<< do
  on: (n, cb) -> @evt-handler.[][n].push cb
  fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v
  tab: (n) -> 
    if !n => return
    idx = if ld$.find(@root,".panel[data-panel=#n]",0) => ld$.index(that) else -1
    if idx < 0 => return
    ld$.find(@root,\.panels,0).style.transform = "translate(#{idx * -100}%,0)"
    ld$.find(@root,".nav-link").map -> it.classList[if ld$.attr(it,\data-panel) == n => \add else \remove] \active
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

  init: (opt = {}) ->
    pals = if !opt.pals => @get \default else opt.pals
    Array.from(document.querySelectorAll '*[ldPalettePicker]').map ->
      new ldPalettePicker(it, {palettes: pals} <<< opt)

# Default Color Palette
ldPalettePicker.register "default", """
  flourish,b22 e55 f87 fb6 ab8 898,qualitative
  gray,000 333 666 ddd fff,gradient
  young,fec fe6 cd9 acd 7ab aac,concept
  plotDB,ed1e79 c69c6d 8cc63f 29abe2,brand
  French,37a 9ab eee f98 c10,diverging
  Afghan Girl,010 253 ffd da8 b53,artwork
"""

