// Generated by LiveScript 1.3.1
var ldPalette;
ldPalette = function(){};
ldPalette.download = function(pal, type){
  var promise;
  type == null && (type = 'png');
  promise = new Promise(function(res, rej){
    var name, len, rects, i$, i, payload, ref$, iw, ih, dw, dh, canvas, ctx, data, this$ = this;
    name = pal.name || 'palette';
    len = pal.colors.length;
    if (type === 'json') {
      return res({
        url: URL.createObjectURL(new Blob([JSON.stringify(pal)], {
          type: "application/json"
        })),
        filename: name + ".json"
      });
    } else if (type === 'svg') {
      rects = [];
      for (i$ = 0; i$ < len; ++i$) {
        i = i$;
        rects.push("<rect x=\"" + 500 * i / len + "\" y=\"0\" width=\"" + 500 / len + "\" height=\"100\" fill=\"" + ldColor.web(pal.colors[i]) + "\"/>");
      }
      payload = (["<?xml version=\"1.0\" encoding=\"utf-8\"?>", "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"500\" height=\"100\" viewbox=\"0 0 500 100\">"].concat(rects, ["</svg>"])).join('\n');
      return res({
        url: URL.createObjectURL(new Blob([payload], {
          type: "image/svg+xml"
        })),
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
        ctx.fillStyle = ldColor.web(pal.colors[i]);
        ctx.fillRect((iw - dw) * 0.5 + dw * (i / len), (ih - dh) * 0.5, dw / len, dh);
      }
      return canvas.toBlob(function(blob){
        document.body.removeChild(canvas);
        return res({
          url: URL.createObjectURL(blob),
          filename: name + ".png"
        });
      });
    } else if (type === 'scss') {
      data = ["$palette-name: '" + name + "'"];
      for (i$ = 0; i$ < len; ++i$) {
        i = i$;
        data.push("$palette-color" + (i + 1) + ": " + ldColor.web(pal.colors[i]) + ";");
      }
      return res({
        url: URL.createObjectURL(new Blob([data.join('\n')], {
          type: "text/plain"
        })),
        filename: name + ".scss"
      });
    }
  });
  return promise.then(function(ret){
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