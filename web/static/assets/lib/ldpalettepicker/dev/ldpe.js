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
      pal: opt.palette || JSON.parse(JSON.stringify(ldpe.defaultPalette))
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
  ldpe.defaultPalette = {
    name: 'sample',
    colors: ['#E8614C', '#F4A358', '#E8DA8D', '#2DA88B', '#294B59']
  };
  if (typeof module != 'undefined' && module !== null) {
    module.exports = ldpe;
  } else if (typeof window != 'undefined' && window !== null) {
    window.ldpe = ldpe;
  }
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
