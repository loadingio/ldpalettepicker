(function(){
  var ldpp;
  ldpp = function(opt){
    var root, el, content, mypal, ret, palFromNode, usePal, search, saver, evts, n, this$ = this;
    opt == null && (opt = {});
    this.opt = opt = import$({
      palettes: [],
      itemPerLine: 2
    }, opt);
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
      root: ld$.find(root, '.navbar', 0),
      search: ld$.find(root, 'input[data-tag=search]', 0)
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
        var rows, lines, i$, step$, to$, i, line, j$, to1$, j;
        p == null && (p = []);
        tgt == null && (tgt = 'view');
        if (tgt === 'edit') {
          tgt = 'view';
        }
        rows = p.map(function(it){
          return it.html;
        });
        if (rows.length === 0) {
          return el.pnin[tgt].innerHTML = "no result...";
        }
        if (opt.useClusterizejs && (typeof Clusterize != 'undefined' && Clusterize !== null)) {
          lines = [];
          for (i$ = 0, to$ = rows.length, step$ = opt.itemPerLine; step$ < 0 ? i$ > to$ : i$ < to$; i$ += step$) {
            i = i$;
            line = [];
            for (j$ = 0, to1$ = opt.itemPerLine; j$ < to1$; ++j$) {
              j = j$;
              line.push(rows[i + j]);
            }
            lines.push("<div>" + line.join('') + "</div>");
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
        } else {
          return el.pnin[tgt].innerHTML = rows.join('');
        }
      },
      html: function(c){
        var cs;
        cs = c.colors.map(function(it){
          return "<div class=\"color\" style=\"background:" + ldcolor.rgbaStr(it) + "\"></div>";
        }).join("");
        return "<div class=\"ldp\"" + (c.key ? " data-key=\"" + c.key + "\"" : "") + ">\n  <div class=\"colors\">\n  <div class=\"ctrl\">\n  <div data-action=\"use\"><i class=\"i-check\"></i>USE</div>\n  <div data-action=\"edit\"><i class=\"i-gear\"></i>EDIT</div>\n  </div>\n  " + cs + "\n  </div>\n  <div class=\"name\">" + (c.name || 'untitled') + "</div>\n</div>";
      }
    };
    if (opt.mypal != null) {
      mypal = {
        loader: new ldLoader({
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
      ret = ld$.parent(ld$.find(el.nv.root, 'a[data-panel=mypal]', 0), '.nav-item', el.nv.root);
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
    if (opt.save != null) {
      saver = {
        loader: new ldLoader({
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
        if (!(p = ld$.parent(tgt, ".navbar", root))) {
          return;
        }
        if (n = ld$.parent(tgt, "*[data-panel=mypal]", p)) {
          if (!(mypal != null)) {
            return this$.tab('view');
          }
          mypal.fetch();
          return this$.tab('mypal');
        }
      },
      view: function(tgt){
        var p, n;
        if (!(p = ld$.parent(tgt, ".navbar", root))) {
          return;
        }
        if (n = ld$.parent(tgt, "*[data-panel=view]", p)) {
          return this$.tab('view');
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
        if (ld$.attr(tgt, 'data-panel') && ld$.parent(tgt, '.navbar', root)) {
          return this$.tab(ld$.attr(tgt, 'data-panel'));
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
    content.add('view', opt.palettes);
    content.build(content.pals.view);
    this.ldpe = new ldpe({
      root: el.pn.edit
    });
    this.edit = function(pal, toggle){
      toggle == null && (toggle = true);
      this$.ldpe.init({
        pal: pal
      });
      if (toggle) {
        return this$.tab('edit');
      }
    };
    if ((typeof ldcover != 'undefined' && ldcover !== null) && opt.ldcv) {
      if (n = ld$.parent(this.root, '.ldcv')) {
        this.ldcv = new ldcover(import$({
          root: n
        }, typeof opt.ldcv === 'object'
          ? opt.ldcv
          : {}));
      }
    }
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
      ld$.find(this.root, ".nav-link").map(function(it){
        return it.classList.toggle('active', ld$.attr(it, 'data-panel') === n);
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
    }
  });
  ldpp.register("default", "flourish,b22 e55 f87 fb6 ab8 898,qualitative\ngray,000 333 666 ddd fff,gradient\nyoung,fec fe6 cd9 acd 7ab aac,concept\nplotDB,ed1e79 c69c6d 8cc63f 29abe2,brand\nFrench,37a 9ab eee f98 c10,diverging\nAfghan Girl,010 253 ffd da8 b53,artwork");
  if (typeof window != 'undefined' && window !== null) {
    window.ldpp = window.ldPalettePicker = ldpp;
  }
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
(function(){
  var ldpe;
  ldpe = function(opt){
    var root, el, log, ldcp, ldrs, irsOpt, ref$, getIdx, dragger, editInit, editUpdate, evts;
    opt == null && (opt = {});
    this.opt = opt = import$({}, opt);
    this.root = root = typeof opt.root === typeof ''
      ? document.querySelector(opt.root)
      : opt.root;
    this.el = el = {};
    el.ed = {
      picker: ld$.find(root, '.ldcolorpicker', 0),
      pal: ld$.find(root, '.ldp', 0),
      colors: ld$.find(root, '.ldp .colors', 0),
      hex: ld$.find(root, 'input[data-tag=hex]', 0),
      sel: ld$.find(root, 'select', 0),
      cfgs: ld$.find(root, '.config')
    };
    log = {
      stack: [],
      cur: null,
      handle: null,
      undo: function(){
        var html;
        html = log.stack.pop();
        if (!html) {
          return;
        }
        el.ed.pal.innerHTML = html;
        return el.ed.colors = ld$.find(el.ed.pal, '.colors', 0);
      },
      push: function(forced){
        var that, _, this$ = this;
        forced == null && (forced = false);
        if (that = this.handle) {
          clearTimeout(that);
        }
        if (!this.cur) {
          this.cur = el.ed.pal.innerHTML;
        }
        _ = function(){
          var ref$;
          if ((ref$ = this$.stack)[ref$.length - 1] !== this$.cur) {
            this$.stack.push(this$.cur);
          }
          return this$.handle = null, this$.cur = null, this$;
        };
        if (forced) {
          return _();
        } else {
          return this.handle = setTimeout(function(){
            return _();
          }, 200);
        }
      },
      clear: function(){
        this.stack.splice(0);
        if (this.handle) {
          clearTimeout(this.handle);
        }
        return this.handle = null, this.cur = null, this;
      }
    };
    this.undo = function(){
      return log.undo();
    };
    this.clearLog = function(){
      return log.clear();
    };
    this.ldcp = ldcp = new ldcolorpicker(el.ed.picker, {
      inline: true
    });
    ldcp.on('change', function(it){
      log.push();
      return editUpdate(it);
    });
    this.ldrs = ldrs = {};
    irsOpt = {
      base: {
        min: 0,
        max: 255,
        step: 1,
        hide_min_max: true,
        hide_from_to: true,
        grid: false
      }
    };
    import$(irsOpt, {
      "hsl-h": (ref$ = import$({}, irsOpt.base), ref$.max = 360, ref$),
      "hsl-s": (ref$ = import$({}, irsOpt.base), ref$.max = 1, ref$.step = 0.01, ref$),
      "hsl-l": (ref$ = import$({}, irsOpt.base), ref$.max = 1, ref$.step = 0.01, ref$),
      "hcl-h": (ref$ = import$({}, irsOpt.base), ref$.max = 360, ref$),
      "hcl-c": (ref$ = import$({}, irsOpt.base), ref$.max = 230, ref$),
      "hcl-l": (ref$ = import$({}, irsOpt.base), ref$.max = 100, ref$)
    });
    irsOpt["rgb-r"] = irsOpt["rgb-g"] = irsOpt["rgb-b"] = irsOpt.base;
    ['rgb-r', 'rgb-g', 'rgb-b', 'hsl-h', 'hsl-s', 'hsl-l', 'hcl-h', 'hcl-c', 'hcl-l'].map(function(it){
      return function(t){
        var v, handle, deb, x$;
        v = t.split('-');
        handle = function(e){
          var c;
          c = ldcp.getColor(v[0]);
          c[v[1]] = e.target.value;
          return ldcp.setColor(c);
        };
        deb = debounce(500, handle);
        x$ = ld$.find(root, ".value[data-tag=" + t + "]", 0);
        x$.addEventListener('change', handle);
        x$.addEventListener('input', deb);
        ldrs[t] = new ldslider(import$({
          root: ld$.find(root, ".ldrs[data-tag=" + t + "]", 0)
        }, irsOpt[t]));
        return function(t){
          return ldrs[t].on('change', function(val){
            var c;
            ldcp._slider = t;
            c = ldcp.getColor(v[0]);
            c[v[1]] = val;
            return ldcp.setColor(c);
          });
        }(t);
      }(it);
    });
    el.ed.hex.addEventListener('change', function(e){
      return ldcp.setColor(e.target.value);
    });
    el.ed.hex.addEventListener('input', debounce(500, function(e){
      return ldcp.setColor(e.target.value);
    }));
    el.ed.sel.addEventListener('change', function(e){
      var k, ref$, v, results$ = [];
      el.ed.cfgs.map(function(it){
        return it.classList[ld$.attr(it, 'data-tag') === e.target.value ? 'add' : 'remove']('active');
      });
      for (k in ref$ = ldrs) {
        v = ref$[k];
        results$.push(v.update());
      }
      return results$;
    });
    getIdx = function(e){
      var box, idx, ref$, ref1$, ref2$;
      box = dragger.data.box;
      return idx = (dragger.data.colors.length * ((ref$ = (ref2$ = e.clientX - box.x) > 0 ? ref2$ : 0) < (ref1$ = box.width) ? ref$ : ref1$)) / box.width;
    };
    dragger = function(e){
      var ref$, box, srcidx, initx, colors, span, desidx, src, offset, ref1$, ref2$, ref3$, des;
      ref$ = dragger.data, box = ref$.box, srcidx = ref$.srcidx, initx = ref$.initx, colors = ref$.colors, span = ref$.span;
      desidx = Math.round(getIdx(e));
      src = el.ed.colors.childNodes[srcidx];
      offset = (ref$ = (ref2$ = e.clientX - initx) > (ref3$ = -srcidx * span) ? ref2$ : ref3$) < (ref1$ = (colors.length - srcidx - 1) * span) ? ref$ : ref1$;
      src.style.transform = "translate(" + offset + "px,0)";
      if (srcidx === desidx || srcidx + 1 === desidx) {
        return;
      }
      src.style.transform = "translate(0,0)";
      dragger.data.initx = e.clientX;
      log.push();
      src = el.ed.colors.childNodes[srcidx];
      des = el.ed.colors.childNodes[desidx];
      src.remove();
      el.ed.colors.insertBefore(src, des);
      return dragger.data.srcidx = desidx < srcidx
        ? desidx
        : desidx - 1;
    };
    el.ed.pal.addEventListener('mousedown', function(e){
      if (!ld$.parent(e.target, '.colors', el.ed.pal)) {
        return;
      }
      dragger.data = {
        initx: e.clientX,
        colors: ld$.find(el.ed.colors, '.color'),
        box: el.ed.colors.getBoundingClientRect()
      };
      dragger.data.srcidx = Math.floor(getIdx(e));
      dragger.data.span = dragger.data.box.width / dragger.data.colors.length;
      document.removeEventListener('mousemove', dragger);
      return document.addEventListener('mousemove', dragger);
    });
    el.ed.pal.addEventListener('mouseup', function(e){
      if (!ld$.parent(e.target, '.colors', el.ed.pal)) {
        return;
      }
      ld$.find(el.ed.colors, '.color').map(function(it){
        return it.style.transform = "";
      });
      return document.removeEventListener('mousemove', dragger);
    });
    document.addEventListener('mouseup', function(){
      return document.removeEventListener('mousemove', dragger);
    });
    this.init = editInit = function(opt){
      var ref$, hexs, key, name, elp;
      opt == null && (opt = {});
      opt = import$({
        pal: {}
      }, opt);
      ref$ = [
        opt.pal.hexs || opt.pal.colors.map(function(it){
          return ldcolor.hex(it);
        }), opt.pal.key, opt.pal.name || 'Custom'
      ], hexs = ref$[0], key = ref$[1], name = ref$[2];
      elp = el.ed.colors.parentNode;
      if (key) {
        elp.setAttribute('data-key', key);
      } else {
        elp.removeAttribute('data-key');
      }
      el.ed.colors.innerHTML = hexs.map(function(d, i){
        var hcl;
        hcl = ldcolor.hcl(d);
        return "<div class=\"color" + (i ? '' : ' active') + (hcl.l < 50 ? ' dark' : '') + "\"\nstyle=\"background:" + d + ";color:" + d + "\">\n  <div data-action>\n    <i class=\"i-clone\"></i>\n    <i class=\"i-bars\"></i>\n    <i class=\"i-close\"></i>\n  </div>\n</div>";
      }).join('');
      ld$.find(elp, '.name', 0).innerHTML = name || 'untitled';
      editUpdate(hexs[0]);
      return ldcp.setColor(hexs[0]);
    };
    editUpdate = function(c){
      var hcl, node;
      hcl = ldcolor.hcl(c);
      node = ld$.find(root, '.color.active', 0);
      node.style.background = ldcolor.rgbaStr(c);
      node.classList[hcl.l < 50 ? "add" : "remove"]('dark');
      el.ed.hex.value = ldcolor.hex(c);
      c = {
        rgb: ldcolor.rgb(c),
        hsl: ldcolor.hsl(c),
        hcl: hcl
      };
      return ['rgb-r', 'rgb-g', 'rgb-b', 'hsl-h', 'hsl-s', 'hsl-l', 'hcl-h', 'hcl-c', 'hcl-l'].map(function(t){
        var p, v;
        p = t.split('-');
        v = c[p[0]][p[1]];
        if (!(t === 'hsl-s' || t === 'hsl-l')) {
          v = Math.round(v);
        }
        ld$.find(root, ".value[data-tag=" + t + "]", 0).value = v;
        if (ldcp._slider === t) {
          return ldcp._slider = null;
        }
        return ldrs[t].set(v);
      });
    };
    evts = {
      editColor: function(tgt){
        var btn, color, sibling, node;
        btn = ld$.parent(tgt, 'i', el.ed.pal);
        color = ld$.parent(tgt, ".color", el.ed.pal);
        if (btn && !btn.classList.contains('i-bars') && color.classList.contains('active')) {
          if (btn.classList.contains('i-close')) {
            if (color.parentNode.childNodes.length <= 1) {
              return true;
            }
            log.push();
            if (color.classList.contains('active')) {
              sibling = color.parentNode.childNodes[ld$.index(color) + 1] || color.parentNode.childNodes[ld$.index(color) - 1];
              if (sibling) {
                sibling.classList.add('active');
              }
            }
            color.remove();
            return true;
          }
          if (btn.classList.contains('i-clone')) {
            node = color.cloneNode(true);
            ld$.child(color.parentNode).map(function(it){
              return it.classList.remove('active');
            });
            node.classList.add('active');
            ld$.insertAfter(color.parentNode, node, color);
            return true;
          }
        }
        if (color) {
          ld$.child(color.parentNode).map(function(it){
            return it.classList[it === color ? 'add' : 'remove']('active');
          });
          ldcp.setColor(color.style.backgroundColor);
          return true;
        }
      }
    };
    root.addEventListener('click', function(e){
      var tgt;
      tgt = e.target;
      if (evts.editColor(tgt)) {}
    });
    this.getPal = function(){
      var elp, key, name, colors;
      elp = el.ed.colors.parentNode;
      key = ld$.attr(elp, 'data-key');
      name = ld$.find(elp, '.name', 0).textContent || "untitled";
      colors = ld$.find(el.ed.colors, '.color').map(function(it){
        return {
          value: ldcolor.rgbaStr(it.style.backgroundColor)
        };
      });
      return {
        colors: colors,
        name: name,
        key: key
      };
    };
    editInit({
      pal: {
        colors: ['#E8614C', '#F4A358', '#E8DA8D', '#2DA88B', '#294B59']
      }
    });
    return this;
  };
  ldpe.prototype = import$(Object.create(Object.prototype), {
    syncUi: function(){
      var k, ref$, v, results$ = [];
      for (k in ref$ = this.ldrs) {
        v = ref$[k];
        results$.push(v.update());
      }
      return results$;
    }
  });
  if (typeof window != 'undefined' && window !== null) {
    window.ldpe = window.ldPaletteEditor = ldpe;
  }
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
(function(){
  var ldpalette;
  ldpalette = function(){};
  ldpalette.convert = function(pal, type){
    var promise;
    type == null && (type = 'png');
    return promise = new Promise(function(res, rej){
      var name, len, blob, rects, i$, i, payload, ref$, iw, ih, dw, dh, canvas, ctx, data;
      name = pal.name || 'palette';
      len = pal.colors.length;
      if (type === 'json') {
        blob = new Blob([JSON.stringify(pal)], {
          type: "application/json"
        });
        return res({
          blob: blob,
          url: URL.createObjectURL(blob),
          filename: name + ".json"
        });
      } else if (type === 'svg') {
        rects = [];
        for (i$ = 0; i$ < len; ++i$) {
          i = i$;
          rects.push("<rect x=\"" + 500 * i / len + "\" y=\"0\" width=\"" + 500 / len + "\" height=\"100\" fill=\"" + ldcolor.web(pal.colors[i]) + "\"/>");
        }
        payload = (["<?xml version=\"1.0\" encoding=\"utf-8\"?>", "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"500\" height=\"100\" viewbox=\"0 0 500 100\">"].concat(rects, ["</svg>"])).join('\n');
        blob = new Blob([payload], {
          type: "image/svg+xml"
        });
        return res({
          blob: blob,
          url: URL.createObjectURL(blob),
          filename: name + ".svg"
        });
      } else if (type === 'png') {
        ref$ = [500, 100, 500, 100], iw = ref$[0], ih = ref$[1], dw = ref$[2], dh = ref$[3];
        canvas = document.createElement('canvas');
        document.body.appendChild(canvas);
        ref$ = canvas.style;
        ref$.display = 'block';
        ref$.opacity = 0.01;
        ref$.position = 'absolute';
        ref$.zIndex = -1;
        canvas.width = iw;
        canvas.height = ih;
        ctx = canvas.getContext('2d');
        ctx.fillStyle = '#ffffff';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        for (i$ = 0; i$ < len; ++i$) {
          i = i$;
          ctx.fillStyle = ldcolor.web(pal.colors[i]);
          ctx.fillRect((iw - dw) * 0.5 + dw * (i / len), (ih - dh) * 0.5, dw / len, dh);
        }
        return canvas.toBlob(function(blob){
          document.body.removeChild(canvas);
          return res({
            blob: blob,
            url: URL.createObjectURL(blob),
            filename: name + ".png"
          });
        });
      } else if (type === 'scss') {
        data = ["$palette-name: '" + name + "'"];
        for (i$ = 0; i$ < len; ++i$) {
          i = i$;
          data.push("$palette-color" + (i + 1) + ": " + ldcolor.web(pal.colors[i]) + ";");
        }
        blob = new Blob([data.join('\n')], {
          type: "text/plain"
        });
        return res({
          blob: blob,
          url: URL.createObjectURL(blob),
          filename: name + ".scss"
        });
      }
    });
  };
  ldpalette.download = function(pal, type){
    type == null && (type = 'png');
    return ldpalette.convert(pal, type).then(function(ret){
      var a;
      a = ld$.create({
        name: 'a',
        attr: {
          download: ret.filename,
          href: ret.url
        },
        style: {
          display: 'none'
        }
      });
      document.body.appendChild(a);
      a.click();
      return document.body.removeChild(a);
    });
  };
  if (typeof window != 'undefined' && window !== null) {
    window.ldpalette = window.ldPalette = ldpalette;
  }
}).call(this);
