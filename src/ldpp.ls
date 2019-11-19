(->
  ldPalettePicker = (opt = {}) ->
    @opt = opt = {palettes: [], item-per-line: 2} <<< opt
    @pals = view: opt.palettes
    # Prepare DOM
    @root = root = if typeof(opt.root) == typeof('') => document.querySelector(opt.root) else opt.root
    if opt.className => @root.classList.add.apply @root.classList, opt.className.split(' ').filter(->it).map(->it.trim!)
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
      save: ld$.find(el.pn.edit,'*[data-action=save]',0)

    el.mp = do
      load: ld$.find(el.pn.mypal,'.btn-load',0)

    # Prepare content
    content = do
      pals: {}
      add: (tab=\view, p) ->
        if !@pals[tab] => @pals[tab] = []
        @pals[tab] ++= (p.map ~> {html: @html(it), obj: it})
      build: (p = [], tgt='view') ->
        # build content for edit? it might be we searching while in edit panel.
        # just set tgt to view.
        if tgt == \edit => tgt = \view
        rows = p.map -> it.html
        if rows.length == 0 => return el.pnin[tgt]innerHTML = "no result..."
        if opt.use-clusterizejs and Clusterize? =>
          lines = []
          for i from 0 til rows.length by opt.item-per-line =>
            line = []
            for j from 0 til opt.item-per-line => line.push rows[i + j]
            lines.push """<div>#{line.join('')}</div>"""
          if content.cluster => content.cluster.update lines
          else content.cluster = new Clusterize do
            rows_in_block: 7
            rows: lines
            contentElem: el.pnin[tgt]
            scrollElem: el.pn[tgt]
        else el.pnin[tgt]innerHTML = rows.join('')
      html: (c) ->
        cs = c.colors.map(->"""<div class="color" style="background:#{ldColor.rgbaStr(it)}"></div>""").join("")
        """
        <div class="ldp"#{if c.key => " data-key=\"" + c.key + "\"" else ""}>
          <div class="colors">
          <div class="ctrl">
          <div data-action="use"><i class="i-check"></i>USE</div>
          <div data-action="edit"><i class="i-gear"></i>EDIT</div>
          </div>
          #{cs}
          </div>
          <div class="name">#{c.name or 'untitled'}</div>
        </div>
        """

    #Custom Palette List
    if opt.mypal? => # mypal should be a ldPage instance
      mypal = do
        loader: new ldLoader root: el.mp.load, auto-z: true
        page: Object.create(opt.mypal)
        fetch: ->
          @page.fetch!then (ret) ->
            content.add \mypal, ret
            content.build content.pals.mypal, 'mypal'
      mypal.page.set-host el.pn.mypal
      el.mp.load.addEventListener \click, ->
        mypal.loader.on!
          .then -> mypal.page.fetch!
          .then -> debounce 100; return it
          .then ->
            content.add \mypal, it
            content.build content.pals.mypal, 'mypal'
          .then -> mypal.loader.off 100
          .then -> if mypal.page.is-end! => el.mp.load.style.display = \none
    else
      ret = ld$.parent(ld$.find(el.nv.root, 'a[data-panel=mypal]', 0), '.nav-item', el.nv.root)
      ret.style.display = \none
      ld$.remove(el.pn.mypal)

    pal-from-node = (n) ->
      p = ld$.find(n,'.ldp',0) or ld$.parent(n,'.ldp',root)
      [key,name] = if p => [ld$.attr(p, 'data-key'), ld$.find(that,'.name',0).innerText]
      else [null, 'untitled']
      hexs = if ld$.find(n,'.colors',0) or ld$.parent(n, '.colors', root) =>
        ld$.find(that,'.color').map ->
          ldColor.hex(it.style.backgroundColor or it.style.background)
      else []
      return {name, hexs, key}
    # Use Dynamic
    use-pal = (n) ~>
      {name, hexs, key} = pal-from-node n
      @fire \use, ret = {name, key, colors: hexs.map -> ldColor.rgb(it)}
      if @ldcv => @ldcv.set ret

    # Search Dynamics
    search = (v = "") ~>
      n = ld$.find(el.nv.root,'.active',0)
      pal = if n => ld$.attr(n, \data-panel) else \view
      if !v => return content.build (content.pals[pal] or []), pal
      v = v.toLowerCase!trim!
      if pal == \edit => pal = \view # we dont search at edit panel. it must be for view panel.
      content.build(
        (content.pals[pal] or []).filter(->
          (it.obj.name or 'untitled').indexOf(v) >= 0 or (it.obj.tag or []).filter(->it.indexOf(v) >= 0).length),
        pal)
      @tab pal
    el.nv.search.addEventListener \keyup, (e) -> search (e.target.value or "")

    #Save
    if opt.save? =>
      saver = do
        loader: new ldLoader root: el.ed.save, auto-z: true
        save: opt.save

    # General Action
    evts = do
      save: (tgt) ~>
        if !ld$.parent(tgt, '[data-action=save]',root) => return false
        if !(saver?) => return true
        saver.loader.on!
        {colors, name, key} = @ldpe.get-pal!
        [width, height, len] = [800, 300, colors.length]
        canvas = document.createElement \canvas
        document.body.appendChild canvas
        canvas.style <<< display: \block, position: \absolute, zIndex: -1, opacity: 0, visibility: \hidden
        canvas.width = width
        canvas.height = height
        ctx = canvas.getContext \2d
        ctx.fillStyle = \#ffffff
        ctx.fillRect 0, 0, canvas.width, canvas.height
        for i from 0 til len =>
          ctx.fillStyle = colors[i].value
          ctx.fillRect(
            (width - 600)*0.5 + 600*(i/len),
            (height - 150) * 0.5,
            600/len,
            150
          )
        canvas.toBlob (thumb) ~>
          # we should use this after we deploy v2.
          #saver.save { thumb, name, type, payload: {colors: colors} }, key
          saver.save { thumb, data: { name, type: \palette, payload: {colors: colors} } }, key
            .finally ~> saver.loader.off 500
            .then (pal) ~> if pal => @ldpe.init({pal})

        return true

      use: (tgt) ~>
        if !ld$.parent(tgt,'[data-action=use]',root) => return false
        if (n = ld$.parent(tgt,".ldp *[data-action]", root)) => return use-pal(n) or true
        if n = ld$.parent(tgt,".panel[data-panel=edit]", root) =>
          n = ld$.find n, '.ldp', 0
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
        @tab \view # go to view first so search will execute in view panel
        search el.nv.search.value = (ld$.attr(n,"data-cat") or "")
      edit: (tgt) ~>
        if !(n = ld$.parent(tgt,".ldp *[data-action]", root)) => return
        if ld$.attr(n,\data-action) == \edit =>
          @tab \edit
          @ldpe.init({pal: pal-from-node(n)})
          return true
      undo: (tgt) ~>
        if (n = ld$.parent(tgt,"*[data-action=undo]", root)) => return @ldpe.undo! or true
      nav: (tgt) ~>
        if ld$.attr(tgt, \data-panel) and ld$.parent(tgt,'.navbar',root) => return @tab ld$.attr(tgt,\data-panel)

    root.addEventListener \click, (e) ~>
      tgt = e.target
      if evts.save(tgt) => return
      if evts.use(tgt) => return
      if evts.mypal(tgt) => return
      if evts.view(tgt) => return
      if evts.edit(tgt) => return
      if evts.undo(tgt) => return
      if evts.nav(tgt) => return

    # Final Preparation
    @evt-handler = {}
    content.add \view, opt.palettes
    content.build content.pals.view
    @ldpe = new ldPaletteEditor root: el.pn.edit
    @edit = (pal, toggle = true) ~> @ldpe.init {pal}; if toggle => @tab \edit
    if ldCover? and opt.ldcv => if (n = ld$.parent(@root, '.ldcv', document)) =>
      @ldcv = new ldCover {root: n} <<< (if typeof(opt.ldcv) == \object => opt.ldcv else {})

    @

  ldPalettePicker.prototype = Object.create(Object.prototype) <<< do
    on: (n, cb) -> @evt-handler.[][n].push cb
    fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v
    get: -> Promise.resolve!then ~> if @ldcv => @ldcv.get!
    tab: (n) ->
      if !n => return
      idx = if ld$.find(@root,".panel[data-panel=#n]",0) => ld$.index(that) else -1
      if idx < 0 => return
      ld$.find(@root,\.panels,0).style.transform = "translate(#{idx * -100}%,0)"
      ld$.find(@root,".nav-link").map -> it.classList.toggle \active, (ld$.attr(it,\data-panel) == n)
      @ldpe.sync-ui!
      true
    random: ->
      pals = @opt.palettes
      if !@opt.random => return pals[Math.floor(Math.random! * pals.length)]
      if Array.isArray(@opt.random) => return @opt.random[Math.floor(Math.random! * @opt.random.length)]
      return @opt.random!

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
        new ldPalettePicker({palettes: pals, root: it} <<< opt)

  # Default Color Palette
  ldPalettePicker.register "default", """
    flourish,b22 e55 f87 fb6 ab8 898,qualitative
    gray,000 333 666 ddd fff,gradient
    young,fec fe6 cd9 acd 7ab aac,concept
    plotDB,ed1e79 c69c6d 8cc63f 29abe2,brand
    French,37a 9ab eee f98 c10,diverging
    Afghan Girl,010 253 ffd da8 b53,artwork
  """
  if window? => window.ldPalettePicker = ldPalettePicker
)!
