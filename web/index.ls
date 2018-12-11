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

ldPalettePicker = (node, palette-list = []) ->
  @root = root = if typeof(node) == typeof('') => node = document.querySelector(node) else node
  @ldcp = new ldColorPicker @root.find('.panel[data-panel=custom] .ldColorPicker',0), {inline: true}
  palette = @root.find('.panel[data-panel=custom] .palette',0)
  colors = @root.find('.panel[data-panel=custom] .palette .colors',0)
  @ldcp.on \change, ~>
    hcl = ldColor.hcl(it)
    color-node = @root.find('.color.active',0)
    history.log!
    color-node.style.background = ldColor.rgbaStr it
    color-node.classList[if hcl.l < 50 => "add" else "remove"] \dark
    @root.find('input[data-tag=hex]',0).value = ldColor.hex it
    c = {rgb: ldColor.rgb(it), hsl: ldColor.hsl(it), hcl: ldColor.hcl(it)}
    <[rgb-r rgb-g rgb-b hsl-h hsl-s hsl-l hcl-h hcl-c hcl-l]>.map (t) ~>
      p = t.split \-
      v = c[p.0][p.1]
      if !(t == \hsl-s or t == \hsl-l) => v = Math.round(v)
      @root.find("input.value[data-tag=#{t}]",0).value = v
      if @ldcp.slider == t => return @ldcp.slider = null
      $(@root.find("input.ion-slider[data-tag=#{t}]",0)).data("ionRangeSlider").update from: v

  irs-opt = do
    base: min: 0, max: 255, step: 1, hide_min_max: true, hide_from_to: true, grid: false
  irs-opt  <<< do
    "hsl-h": {} <<< irs-opt.base <<< {max: 360, step: 1}
    "hsl-s": {} <<< irs-opt.base <<< {max: 1, step: 0.01}
    "hsl-l": {} <<< irs-opt.base <<< {max: 1, step: 0.01}
    "hcl-h": {} <<< irs-opt.base <<< {max: 360, step: 1}
    "hcl-c": {} <<< irs-opt.base <<< {max: 230, step: 1}
    "hcl-l": {} <<< irs-opt.base <<< {max: 100, step: 1}
  irs-opt["rgb-r"] = irs-opt["rgb-g"] = irs-opt["rgb-b"] = irs-opt.base
  <[rgb-r rgb-g rgb-b hsl-h hsl-s hsl-l hcl-h hcl-c hcl-l]>.map ~>
    ((t) ~>
      v = t.split \-
      @root.find("input.value[data-tag=#{t}]",0).on \change, (e) ~>
        c = @ldcp.get-color v.0
        c[v.1] = e.target.value
        @ldcp.set-color c
      $(@root.find("input.ion-slider[data-tag=#{t}]",0)).ionRangeSlider irs-opt[t] <<< onChange: (e) ~>
        @ldcp.slider = t
        c = @ldcp.get-color v.0
        c[v.1] = e.from
        @ldcp.set-color c
    ) it
  @root.find('input.value[data-tag=hex]',0).on \change, (e) ~> @ldcp.set-color e.target.value

  @root.find('.panel[data-panel=custom] select',0).on \change, (e) ~>
    value = e.target.value
    @root.find('.panel[data-panel=custom] .config').map ~>
      it.classList[if it.attr(\data-tag) == value => \add else \remove] \active
  history = do
    stack: []
    handler: null
    undo: ~>
      html = history.stack.pop!
      if !html => return
      @root.find('.panel[data-panel=custom] .palette',0).innerHTML = html
      colors := @root.find('.panel[data-panel=custom] .palette .colors',0)
    current: null
    log: ~>
      if history.handler => clearTimeout that
      if !history.current => history.current = @root.find('.panel[data-panel=custom] .palette',0).innerHTML
      history.handler = setTimeout (~> 
        latest = history.stack[* - 1]
        if latest != history.current => history.stack.push history.current
        history.handler = null
        history.current = null
      ), 200

  palette-html = (c) ->
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
  toggle-edit = (n,options ={}) ~>
    options = {colors: null, toggle: true, name: "Custom"} <<< options
    if options.toggle => @tab \custom
    if options.colors =>
      hexs = options.colors.map -> ldColor.hex(it)
      name = options.name
    else
      hexs = if n.parent('.colors', root) => that.find('.color').map -> ldColor.hex(it.style.background) else []
      name = (if n.parent('.palette', root) => that.find('.name',0).innerText else null) or 'untitled'
    colors.innerHTML = hexs
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
    colors.parentNode.find('.name',0).innerHTML = name

  get-idx = (e) ->
    box = colors.getBoundingClientRect!
    idx = (colors.find('.color').length * (e.clientX - box.x)) / box.width
  handler = (e) ~>
    srcidx = handler.srcidx
    desidx = Math.round(get-idx(e))
    if srcidx == desidx or srcidx + 1 == desidx => return
    history.log!
    src = colors.childNodes[srcidx]
    des = colors.childNodes[desidx]
    src.remove!
    colors.insertBefore src, des
    handler.srcidx = if desidx < srcidx => desidx else desidx - 1
  palette.on \mousedown, (e) ~>
    if !e.target.parent('.colors',palette) => return
    handler.srcidx = Math.floor(get-idx(e))
    document.removeEventListener \mousemove, handler
    document.addEventListener \mousemove, handler
  palette.on \mouseup,(e)  ~>
    if !e.target.parent('.colors',palette) => return
    document.removeEventListener \mousemove, handler

  document.addEventListener \mouseup, -> document.removeEventListener \mousemove, handler

  search = (value = "") ->
    if !value => return rebuild palette-list
    value = value.toLowerCase!
    remains = palette-list.filter ->
      it.name.indexOf(value) >= 0 or it.tag.filter(->it.indexOf(value) >= 0).length
    rebuild remains
  root.find('input[data-tag=search]',0).on \keyup, (e) -> search (e.target.value or "").toLowerCase!trim!
    
  root.addEventListener \click, (e) ~>
    n = e.target.parent("*[data-tag=menu]",root)
    if n =>
      m = e.target.parent("*[data-panel=all]", n)
      if m =>
        @tab \all
        #if root.find('input[data-tag=search]',0).value =>
        #  root.find('input[data-tag=search]',0).value = ""
        #  search ""
        return
      n = e.target.parent("*[data-cat]",n)
      if n =>
        tag = n.attr("data-cat")
        root.find('input[data-tag=search]',0).value = tag
        @tab \all
        return search n.attr("data-cat")
    n = e.target.parent(".palette .btn", root)
    if n => if n.attr(\data-action) == \edit => return toggle-edit(n)
    n = e.target.parent("*[data-action=undo]", root)
    if n => return history.undo!
    if e.target.attr \data-panel => return @tab that
    custom = @root.find(".panel[data-panel=custom] .palette", 0)
    btn = e.target.parent('.fa', custom)
    color = e.target.parent(".color", custom)
    if btn and !btn.classList.contains(\fa-bars) and color.classList.contains \active =>
      if btn.classList.contains \fa-close =>
        history.log!
        if color.classList.contains \active
          sibling = color.parentNode.childNodes[color.index! + 1] or color.parentNode.childNodes[color.index! - 1]
          if sibling => sibling.classList.add \active
        color.remove!
      if btn.classList.contains \fa-clone =>
        node = color.cloneNode(true)
        color.parentNode.child!map -> it.classList.remove \active
        node.classList.add \active
        color.parentNode.insertAfter node, color
      return
    if color =>
      color.parentNode.child!map -> it.classList[if it == color => \add else \remove] \active
      @ldcp.set-color color.style.background
 
  rebuild = (p = []) ->
    htmls = p
      .map -> palette-html it
      .join('')
    @root.find('.panel[data-panel=all]',0).innerHTML = htmls
  rebuild palette-list
  toggle-edit null, {colors: <[#b34e19 #d78c51 #f3e7c9]>, toggle: false}
  @

ldPalettePicker.prototype = Object.create(Object.prototype) <<< do
  tab: (name) -> 
    if !name => return
    idx = if @root.find(".panel[data-panel=#name]",0) => that.index! else -1
    if idx < 0 => return
    @root.find(\.panels,0).style.transform = "translate(#{idx * -100}%,0)"
    @root.find(".nav-link").map -> it.classList[if it.attr(\data-panel) == name => \add else \remove] \active

palettes = palettes.split(\\n)
  .filter -> it
  .map ->
    it = it.split ',' .map -> it.toLowerCase!
    return do
      name: it.0
      colors: it.1.split(' ').map -> "\##it"
      tag: it.slice(2)

ldPalettePicker.init = ->
  Array.from(document.querySelectorAll '*[ldPalettePicker]').map -> new ldPalettePicker it, palettes

ldPalettePicker.init!

