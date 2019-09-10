ldPaletteEditor = (opt = {}) ->
  @opt = opt = {palettes: [], item-per-line: 2} <<< opt
  @root = root = if typeof(opt.root) == typeof('') => document.querySelector(opt.root) else opt.root
  @el = el = {}

  el.ed = do
    picker: ld$.find(root,'.ldColorPicker',0)
    pal: ld$.find(root,'.ldpal',0)
    colors: ld$.find(root,'.ldpal .colors',0)
    hex: ld$.find(root,'input[data-tag=hex]',0)
    sel: ld$.find(root,'select',0)
    cfgs: ld$.find(root,'.config')

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
    push: (forced = false) ->
      if @handle => clearTimeout that
      if !@cur => @cur = el.ed.pal.innerHTML
      _ = ~>
        if @stack[* - 1] != @cur => @stack.push @cur
        @ <<< handle: null, cur: null
      if forced => _!
      else @handle = setTimeout (~> _! ), 200
    clear: ->
      @stack.splice 0
      if @handle => clearTimeout @handle
      @ <<< handle: null, cur: null
  @undo = -> log.undo!
  @clear-log = -> log.clear!


  # Color Picker Initialization
  @ldcp = ldcp = new ldColorPicker el.ed.picker, {inline: true}
  ldcp.on \change, ~> log.push!; edit-update it

  # Input ( Slider, Inputbox ) Initialization
  ldrs = {}
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
      # Drag in input.ldrs: set ldcp
      ldrs[t] = new ldSlider {root: ld$.find(root,".ldrs[data-tag=#{t}]",0)} <<< irs-opt[t]
      ((t) ->
        ldrs[t].on \change, (val) ->
          ldcp._slider = t
          c = ldcp.get-color v.0
          c[v.1] = val
          ldcp.set-color c
      )(t)
    ) it
  el.ed.hex.addEventListener \change, (e) -> ldcp.set-color e.target.value   # Hex Input
  el.ed.sel.addEventListener \change, (e) ~> el.ed.cfgs.map ~>               # Select Box
    it.classList[if ld$.attr(it,\data-tag) == e.target.value => \add else \remove] \active
    for k,v of ldrs => v.update!

  # Drag to re-order Dynamics
  get-idx = (e) ->
    box = dragger.data.box
    idx = (dragger.data.colors.length * ((e.clientX - box.x) >? 0 <? box.width)) / box.width
  dragger = (e) ~>
    {box,srcidx,initx,colors,span} = dragger.data
    desidx = Math.round(get-idx(e))
    src = el.ed.colors.childNodes[srcidx]
    offset = (e.clientX - initx) >? -srcidx * span  <? (colors.length - srcidx - 1) * span
    src.style.transform = "translate(#{offset}px,0)"
    if srcidx == desidx or srcidx + 1 == desidx => return
    src.style.transform = "translate(0,0)"
    dragger.data.initx = e.clientX
    log.push!
    src = el.ed.colors.childNodes[srcidx]
    des = el.ed.colors.childNodes[desidx]
    src.remove!
    el.ed.colors.insertBefore src, des
    dragger.data.srcidx = if desidx < srcidx => desidx else desidx - 1
  el.ed.pal.addEventListener \mousedown, (e) ~>
    if !ld$.parent(e.target,'.colors',el.ed.pal) => return
    dragger.data = do
      initx: e.clientX
      colors: ld$.find(el.ed.colors, '.color')
      box: el.ed.colors.getBoundingClientRect!
    dragger.data.srcidx = Math.floor(get-idx(e))
    dragger.data.span = dragger.data.box.width / dragger.data.colors.length
    document.removeEventListener \mousemove, dragger
    document.addEventListener \mousemove, dragger
  el.ed.pal.addEventListener \mouseup,(e)  ~>
    if !ld$.parent(e.target,'.colors',el.ed.pal) => return
    ld$.find(el.ed.colors, '.color').map -> it.style.transform = ""
    document.removeEventListener \mousemove, dragger
  document.addEventListener \mouseup, -> document.removeEventListener \mousemove, dragger

  # Edit Dynamics
  @init = edit-init = (opt={}) ~>
    opt = {pal: {}} <<< opt
    [hexs, key, name]= [opt.pal.hexs or opt.pal.colors.map(-> ldColor.hex it), opt.pal.key, opt.pal.name or \Custom]
    elp = el.ed.colors.parentNode
    if key => elp.setAttribute \data-key, key else elp.removeAttribute \data-key
    el.ed.colors.innerHTML = hexs
      .map (d,i) ->
        hcl = ldColor.hcl(d)
        """
        <div class="color#{if i => '' else ' active'}#{if hcl.l < 50 => ' dark' else ''}"
        style="background:#d;color:#d">
          <div class="btns">
            <i class="i-clone"></i>
            <i class="i-bars"></i>
            <i class="i-close"></i>
          </div>
        </div>
        """
      .join('')
    ld$.find(elp,'.name',0).innerHTML = name or 'untitled'
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
      ldrs[t].set v

  # General Action
  evts = do
    edit-color: (tgt) ->
      btn = ld$.parent(tgt,'i', el.ed.pal)
      color = ld$.parent(tgt,".color", el.ed.pal)
      if btn and !btn.classList.contains(\i-bars) and color.classList.contains \active =>
        if btn.classList.contains \i-close =>
          if color.parentNode.childNodes.length <= 1 => return true
          log.push!
          if color.classList.contains \active
            sibling = (color.parentNode.childNodes[ld$.index(color) + 1]
              or color.parentNode.childNodes[ld$.index(color) - 1])
            if sibling => sibling.classList.add \active
          color.remove!
          return true
        if btn.classList.contains \i-clone =>
          node = color.cloneNode(true)
          ld$.child(color.parentNode).map -> it.classList.remove \active
          node.classList.add \active
          ld$.insertAfter(color.parentNode, node, color)
          return true
      if color =>
        ld$.child(color.parentNode).map -> it.classList[if it == color => \add else \remove] \active
        ldcp.set-color color.style.backgroundColor
        return true

  root.addEventListener \click, (e) ~>
    tgt = e.target
    if evts.edit-color(tgt) => return

  @get-pal = ->
    elp = el.ed.colors.parentNode
    key = ld$.attr(elp, 'data-key')
    name = ld$.find(elp, '.name', 0).textContent or "untitled"
    colors = ld$.find el.ed.colors, '.color' .map -> {value: ldColor.rgbaStr it.style.backgroundColor}
    return {colors, name, key}

  edit-init {pal: {colors: <[#E8614C #F4A358 #E8DA8D #2DA88B #294B59]>}}
  return @
