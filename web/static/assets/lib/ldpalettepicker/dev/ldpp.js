(function(){
  var i18nRes, ldpp;
  i18nRes = {
    "zh-TW": {
      "search": "搜尋",
      "USE": "套用",
      "EDIT": "編輯",
      "view": "檢視",
      "my pals": "我的色盤",
      "edit": "編輯",
      "filter": "過濾",
      "all": "全部",
      "artwork": "創作",
      "brand": "品牌",
      "concept": "概念",
      "gradient": "漸層",
      "qualitative": "定性",
      "diverging": "雙色",
      "colorbrew": "釀色",
      "load more": "更多",
      "use this palette": "使用此色盤",
      "save as asset": "儲存色盤",
      "undo": "undo",
      "no result...": "沒有可用的色盤..."
    }
  };
  ldpp = function(opt){
    var i18n, root, el, content, mypal, ret, palFromNode, usePal, search, saver, evts, n, ldpeOpt, this$ = this;
    opt == null && (opt = {});
    this.opt = opt;
    this.i18n = i18n = opt.i18n || {
      t: function(it){
        return it;
      }
    };
    if (this.i18n && this.i18n.addResourceBundles) {
      this.i18n.addResourceBundles(i18nRes);
    }
    if (!opt.palettes) {
      opt.palettes = [];
    }
    if (!opt.itemPerLine) {
      opt.itemPerLine = 2;
    }
    this.pals = {
      view: opt.palettes
    };
    this.root = root = typeof opt.root === typeof ''
      ? document.querySelector(opt.root)
      : opt.root;
    if (opt.className) {
      this.root.classList.add.apply(this.root.classList, opt.className.split(' ').filter(function(it){
        return it;
      }).map(function(it){
        return it.trim();
      }));
    }
    this.el = el = {};
    el.nv = {
      root: ld$.find(root, '.header', 0),
      search: ld$.find(root, 'input[data-tag=search]', 0),
      filter: ld$.find(root, '.input-group-append', 0)
    };
    el.pn = {
      view: ld$.find(root, '.panel[data-panel=view]', 0),
      mypal: ld$.find(root, '.panel[data-panel=mypal]', 0),
      edit: ld$.find(root, '.panel[data-panel=edit]', 0)
    };
    el.pnin = {
      view: ld$.find(el.pn.view, '.inner', 0),
      mypal: ld$.find(el.pn.mypal, '.inner', 0)
    };
    el.ed = {
      save: ld$.find(el.pn.edit, '*[data-action=save]', 0)
    };
    el.mp = {
      load: ld$.find(el.pn.mypal, '.btn-load', 0)
    };
    Array.from(this.root.querySelectorAll('[t]')).map(function(n){
      return n.textContent = this$.i18n.t(n.getAttribute('t'));
    });
    el.nv.search.setAttribute('placeholder', this.i18n.t("search") + "...");
    content = {
      pals: {},
      add: function(tab, p){
        var ref$, this$ = this;
        tab == null && (tab = 'view');
        if (!this.pals[tab]) {
          this.pals[tab] = [];
        }
        return (ref$ = this.pals)[tab] = ref$[tab].concat(p.map(function(it){
          return {
            html: this$.html(it),
            obj: it
          };
        }));
      },
      build: function(p, tgt){
        var rows, lines, i$, step$, to$, i, line, j$, to1$, j, x$;
        p == null && (p = []);
        tgt == null && (tgt = 'view');
        if (tgt === 'edit') {
          tgt = 'view';
        }
        rows = p.map(function(it){
          return it.html;
        });
        if (rows.length === 0) {
          return el.pnin[tgt].innerHTML = this$.i18n.t("no result...");
        }
        if (!(opt.useVscroll && (typeof vscroll != 'undefined' && vscroll !== null)) && opt.useClusterizejs && (typeof Clusterize != 'undefined' && Clusterize !== null)) {
          lines = [];
          for (i$ = 0, to$ = rows.length, step$ = opt.itemPerLine; step$ < 0 ? i$ > to$ : i$ < to$; i$ += step$) {
            i = i$;
            line = [];
            for (j$ = 0, to1$ = opt.itemPerLine; j$ < to1$; ++j$) {
              j = j$;
              line.push(rows[i + j]);
            }
            lines.push("<div class=\"clusterize-row\">" + line.join('') + "</div>");
          }
          if ((content.cluster || (content.cluster = {}))[tgt]) {
            return content.cluster[tgt].update(lines);
          } else {
            return (content.cluster || (content.cluster = {}))[tgt] = new Clusterize({
              rows_in_block: 7,
              rows: lines,
              contentElem: el.pnin[tgt],
              scrollElem: el.pn[tgt]
            });
          }
        } else if (opt.useVscroll && (typeof vscroll != 'undefined' && vscroll !== null)) {
          if (!(this$.vscroll || (this$.vscroll = {}))[tgt]) {
            x$ = el.pnin[tgt].style;
            x$.height = "100%";
            x$.overflowY = "scroll";
            this$.vscroll[tgt] = new vscroll.fixed({
              root: el.pnin[tgt]
            });
            if (this$.ldcv) {
              this$.ldcv.on('toggle.on', function(){
                this$.vscroll[tgt].setchild((this$._rows || rows).join(''));
                return this$.vscroll[tgt].update(40);
              });
            }
          }
          this$._rows = rows;
          this$.vscroll[tgt].setchild(rows.join(''));
          return this$.vscroll[tgt].update(40);
        } else {
          return el.pnin[tgt].innerHTML = rows.join('');
        }
      },
      html: function(c){
        var cs;
        cs = c.colors.map(function(it){
          return "<div class=\"color\" style=\"background:" + ldcolor.rgbaStr(it) + "\"></div>";
        }).join("");
        return "<div class=\"ldp\"" + (c.key ? " data-key=\"" + c.key + "\"" : "") + ">\n  <div class=\"colors\">\n  <div class=\"ctrl\">\n  <div data-action=\"use\"><i class=\"i-check\"></i>" + this$.i18n.t('USE') + "</div>\n  <div data-action=\"edit\"><i class=\"i-gear\"></i>" + this$.i18n.t('EDIT') + "</div>\n  </div>\n  " + cs + "\n  </div>\n  <div class=\"name\">" + (c.name || 'untitled') + "</div>\n</div>";
      }
    };
    if (opt.mypal != null) {
      mypal = {
        loader: new ldloader({
          root: el.mp.load,
          autoZ: true
        }),
        page: Object.create(opt.mypal),
        fetch: function(){
          return this.page.fetch().then(function(ret){
            content.add('mypal', ret);
            return content.build(content.pals.mypal, 'mypal');
          });
        }
      };
      mypal.page.setHost(el.pn.mypal);
      el.mp.load.addEventListener('click', function(){
        return mypal.loader.on().then(function(){
          return mypal.page.fetch();
        }).then(function(it){
          debounce(100);
          return it;
        }).then(function(it){
          content.add('mypal', it);
          return content.build(content.pals.mypal, 'mypal');
        }).then(function(){
          return mypal.loader.off(100);
        }).then(function(){
          if (mypal.page.isEnd()) {
            return el.mp.load.style.display = 'none';
          }
        });
      });
    } else {
      ret = ld$.find(el.nv.root, '.btn[data-panel=mypal]', 0);
      ret.style.display = 'none';
      ld$.remove(el.pn.mypal);
    }
    palFromNode = function(n){
      var p, that, ref$, key, name, hexs;
      p = ld$.find(n, '.ldp', 0) || ld$.parent(n, '.ldp', root);
      ref$ = (that = p)
        ? [ld$.attr(p, 'data-key'), ld$.find(that, '.name', 0).innerText]
        : [null, 'untitled'], key = ref$[0], name = ref$[1];
      hexs = (that = ld$.find(n, '.colors', 0) || ld$.parent(n, '.colors', root))
        ? ld$.find(that, '.color').map(function(it){
          return ldcolor.hex(it.style.backgroundColor || it.style.background);
        })
        : [];
      return {
        name: name,
        hexs: hexs,
        key: key
      };
    };
    usePal = function(n){
      var ref$, name, hexs, key, ret;
      ref$ = palFromNode(n), name = ref$.name, hexs = ref$.hexs, key = ref$.key;
      this$.fire('use', ret = {
        name: name,
        key: key,
        colors: hexs.map(function(it){
          return ldcolor.rgb(it);
        })
      });
      if (this$.ldcv) {
        return this$.ldcv.set(ret);
      } else {
        return this$._set(ret);
      }
    };
    search = function(v){
      var n, pal;
      v == null && (v = "");
      n = ld$.find(el.nv.root, '.active', 0);
      pal = n ? ld$.attr(n, 'data-panel') : 'view';
      if (!v) {
        return content.build(content.pals[pal] || [], pal);
      }
      v = v.toLowerCase().trim();
      if (pal === 'edit') {
        pal = 'view';
      }
      content.build((content.pals[pal] || []).filter(function(it){
        return (it.obj.name || 'untitled').indexOf(v) >= 0 || (it.obj.tag || []).filter(function(it){
          return it.indexOf(v) >= 0;
        }).length;
      }), pal);
      return this$.tab(pal);
    };
    el.nv.search.addEventListener('keyup', function(e){
      return search(e.target.value || "");
    });
    if (typeof BSN != 'undefined' && BSN !== null) {
      new BSN.Dropdown(el.nv.filter);
    }
    if (opt.save != null) {
      saver = {
        loader: new ldloader({
          root: el.ed.save,
          autoZ: true
        }),
        save: opt.save
      };
    }
    evts = {
      save: function(tgt){
        var ref$, colors, name, key, width, height, len, canvas, ctx, i$, i;
        if (!ld$.parent(tgt, '[data-action=save]', root)) {
          return false;
        }
        if (!(saver != null)) {
          return true;
        }
        saver.loader.on();
        ref$ = this$.ldpe.getPal(), colors = ref$.colors, name = ref$.name, key = ref$.key;
        ref$ = [800, 300, colors.length], width = ref$[0], height = ref$[1], len = ref$[2];
        canvas = document.createElement('canvas');
        document.body.appendChild(canvas);
        ref$ = canvas.style;
        ref$.display = 'block';
        ref$.position = 'absolute';
        ref$.zIndex = -1;
        ref$.opacity = 0;
        ref$.visibility = 'hidden';
        canvas.width = width;
        canvas.height = height;
        ctx = canvas.getContext('2d');
        ctx.fillStyle = '#ffffff';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        for (i$ = 0; i$ < len; ++i$) {
          i = i$;
          ctx.fillStyle = colors[i].value;
          ctx.fillRect((width - 600) * 0.5 + 600 * (i / len), (height - 150) * 0.5, 600 / len, 150);
        }
        canvas.toBlob(function(thumb){
          return saver.save({
            thumb: thumb,
            data: {
              name: name,
              type: 'palette',
              payload: {
                colors: colors
              }
            }
          }, key)['finally'](function(){
            return saver.loader.off(500);
          }).then(function(pal){
            if (pal) {
              return this$.ldpe.init({
                pal: pal
              });
            }
          });
        });
        return true;
      },
      use: function(tgt){
        var n;
        if (!ld$.parent(tgt, '[data-action=use]', root)) {
          return false;
        }
        if (n = ld$.parent(tgt, ".ldp *[data-action]", root)) {
          return usePal(n) || true;
        }
        if (n = ld$.parent(tgt, ".panel[data-panel=edit]", root)) {
          n = ld$.find(n, '.ldp', 0);
          if (n) {
            return usePal(n) || true;
          }
        }
      },
      mypal: function(tgt){
        var p, n;
        if (!(p = ld$.parent(tgt, ".header", root))) {
          return;
        }
        if (n = ld$.parent(tgt, "*[data-panel=mypal]", p)) {
          if (!(mypal != null)) {
            return this$.tab('view');
          }
          this$.tab('mypal');
          return mypal.fetch();
        }
      },
      view: function(tgt){
        var p, n;
        if (!(p = ld$.parent(tgt, ".header", root))) {
          return;
        }
        if (n = ld$.parent(tgt, "*[data-panel=view]", p)) {
          this$.tab('view');
          return search(el.nv.search.value || '');
        }
        if (!(n = ld$.parent(tgt, "*[data-cat]", p))) {
          return;
        }
        this$.tab('view');
        return search(el.nv.search.value = ld$.attr(n, "data-cat") || "");
      },
      edit: function(tgt){
        var n;
        if (!(n = ld$.parent(tgt, ".ldp *[data-action]", root))) {
          return;
        }
        if (ld$.attr(n, 'data-action') === 'edit') {
          this$.tab('edit');
          this$.ldpe.init({
            pal: palFromNode(n)
          });
          return true;
        }
      },
      undo: function(tgt){
        var n;
        if (n = ld$.parent(tgt, "*[data-action=undo]", root)) {
          return this$.ldpe.undo() || true;
        }
      },
      nav: function(tgt){
        var n;
        if (!(n = ld$.parent(tgt, '[data-panel]', root))) {
          return;
        }
        if (ld$.parent(n, '.header', root)) {
          return this$.tab(ld$.attr(n, 'data-panel'));
        }
      }
    };
    root.addEventListener('click', function(e){
      var tgt;
      tgt = e.target;
      if (evts.save(tgt)) {
        return;
      }
      if (evts.use(tgt)) {
        return;
      }
      if (evts.mypal(tgt)) {
        return;
      }
      if (evts.view(tgt)) {
        return;
      }
      if (evts.edit(tgt)) {
        return;
      }
      if (evts.undo(tgt)) {
        return;
      }
      if (evts.nav(tgt)) {}
    });
    this.access = {
      list: []
    };
    this.evtHandler = {};
    if ((typeof ldcover != 'undefined' && ldcover !== null) && opt.ldcv) {
      if (n = ld$.parent(this.root, '.ldcv')) {
        this.ldcv = new ldcover(import$({
          root: n
        }, typeof opt.ldcv === 'object'
          ? opt.ldcv
          : {}));
      }
    }
    content.add('view', opt.palettes);
    content.build(content.pals.view);
    ldpeOpt = {
      root: el.pn.edit
    };
    if (opt.palette) {
      ldpeOpt.palette = opt.palette;
    }
    this.ldpe = new ldpe(ldpeOpt);
    this.edit = function(pal, toggle){
      toggle == null && (toggle = true);
      this$.ldpe.init({
        pal: pal
      });
      if (toggle) {
        return this$.tab('edit');
      }
    };
    this.tabDisplay = debounce(1000, function(){
      var idx;
      idx = this$.tabIdx;
      return ld$.find(this$.root, '.panel').map(function(n, i){
        if (idx !== i) {
          return n.style.display = 'none';
        }
      });
    });
    return this;
  };
  ldpp.prototype = import$(Object.create(Object.prototype), {
    on: function(n, cb){
      var ref$;
      return ((ref$ = this.evtHandler)[n] || (ref$[n] = [])).push(cb);
    },
    fire: function(n){
      var v, res$, i$, to$, ref$, len$, cb, results$ = [];
      res$ = [];
      for (i$ = 1, to$ = arguments.length; i$ < to$; ++i$) {
        res$.push(arguments[i$]);
      }
      v = res$;
      for (i$ = 0, len$ = (ref$ = this.evtHandler[n] || []).length; i$ < len$; ++i$) {
        cb = ref$[i$];
        results$.push(cb.apply(this, v));
      }
      return results$;
    },
    _get: function(){
      var this$ = this;
      return new Promise(function(res, rej){
        return this$.access.list.push({
          res: res,
          rej: rej
        });
      });
    },
    _set: function(v){
      return this.access.list.splice(0).map(function(it){
        return it.res(v);
      });
    },
    get: function(){
      if (this.ldcv) {
        return this.ldcv.get();
      } else {
        return this._get();
      }
    },
    tab: function(n){
      var idx, that;
      if (!n) {
        return;
      }
      this.tabIdx = idx = (that = ld$.find(this.root, ".panel[data-panel=" + n + "]", 0))
        ? ld$.index(that)
        : -1;
      if (idx < 0) {
        return;
      }
      ld$.find(this.root, '.panels', 0).style.transform = "translate(" + idx * -100 + "%,0)";
      ld$.find(this.root, '.panel').map(function(n, i){
        if (idx === i) {
          return n.style.display = '';
        }
      });
      ld$.find(this.root, ".btn[data-panel]").map(function(it){
        it.classList.toggle('btn-text', ld$.attr(it, 'data-panel') !== n);
        return it.classList.toggle('btn-primary', ld$.attr(it, 'data-panel') === n);
      });
      this.tabDisplay();
      this.ldpe.syncUi();
      return true;
    },
    random: function(){
      var pals;
      pals = this.opt.palettes;
      if (!this.opt.random) {
        return pals[Math.floor(Math.random() * pals.length)];
      }
      if (Array.isArray(this.opt.random)) {
        return this.opt.random[Math.floor(Math.random() * this.opt.random.length)];
      }
      return this.opt.random();
    }
  });
  import$(ldpp, {
    palettes: [],
    parse: {
      text: function(txt){
        return txt.split('\n').filter(function(it){
          return it;
        }).map(function(v){
          v = v.split(',').map(function(it){
            return it.toLowerCase();
          });
          return {
            name: v[0],
            colors: v[1].split(' ').map(function(it){
              return "#" + it;
            }),
            tag: v.slice(2)
          };
        });
      }
    },
    register: function(name, palettes){
      if (typeof palettes === 'string') {
        palettes = this.parse.text(palettes);
      }
      return this.palettes.push([name, palettes]);
    },
    get: function(name){
      return (this.palettes.filter(function(it){
        return it[0] === name;
      })[0] || ['', []])[1];
    },
    init: function(opt){
      var pals;
      opt == null && (opt = {});
      pals = !opt.pals
        ? this.get('default')
        : opt.pals;
      return Array.from(document.querySelectorAll('*[ldpp]')).map(function(it){
        return new ldpp(import$({
          palettes: pals,
          root: it
        }, opt));
      });
    },
    defaultPalette: {
      name: 'sample',
      colors: ['#E8614C', '#F4A358', '#E8DA8D', '#2DA88B', '#294B59']
    }
  });
  ldpp.register("default", "flourish,b22 e55 f87 fb6 ab8 898,qualitative\ngray,000 333 666 ddd fff,gradient\nyoung,fec fe6 cd9 acd 7ab aac,concept\nplotDB,ed1e79 c69c6d 8cc63f 29abe2,brand\nFrench,37a 9ab eee f98 c10,diverging\nAfghan Girl,010 253 ffd da8 b53,artwork");
  if (typeof module != 'undefined' && module !== null) {
    module.exports = ldpp;
  } else if (typeof window != 'undefined' && window !== null) {
    window.ldpp = ldpp;
  }
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
