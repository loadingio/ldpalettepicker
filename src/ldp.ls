ldPalette = ->
ldPalette.convert = (pal, type = \png) ->
  promise = new Promise (res, rej) ->
    name = pal.name or \palette
    len = pal.colors.length
    if type == \json
      blob = new Blob([JSON.stringify pal], {type: "application/json"})
      return res do
        blob: blob
        url: URL.createObjectURL blob
        filename: "#name.json"
    else if type == \svg =>
      rects = []
      for i from 0 til len =>
        rects.push """
        <rect x="#{500 * i/len}" y="0" width="#{500/len}" height="100" fill="#{ldcolor.web(pal.colors[i])}"/>
        """
      payload = ([
        """<?xml version="1.0" encoding="utf-8"?>"""
        """<svg xmlns="http://www.w3.org/2000/svg" width="500" height="100" viewbox="0 0 500 100">"""
      ] ++ rects ++ [
        """</svg>"""
      ]).join(\\n)
      blob = new Blob([payload], {type: "image/svg+xml"})
      return res do
        blob: blob
        url: URL.createObjectURL blob
        filename: "#name.svg"
    else if type == \png =>
      [iw,ih,dw,dh] = [500,100,500,100]
      canvas = document.createElement \canvas
      document.body.appendChild canvas
      canvas.style <<< display: \block, opacity: 0.01, position: \absolute, zIndex: -1
      canvas.width = iw
      canvas.height = ih
      ctx = canvas.getContext \2d
      ctx.fillStyle = \#ffffff
      ctx.fillRect 0, 0, canvas.width, canvas.height
      for i from 0 til len =>
        ctx.fillStyle = ldcolor.web(pal.colors[i])
        ctx.fillRect(
          (iw - dw)*0.5 + dw * (i/len),
          (ih - dh) * 0.5,
          dw/len,
          dh
        )
      return canvas.toBlob (blob) ~>
        document.body.removeChild canvas
        res { blob: blob, url: URL.createObjectURL(blob), filename: "#name.png" }
    else if type == \scss =>
      data = ["""$palette-name: '#name'"""]
      for i from 0 til len => data.push """$palette-color#{i + 1}: #{ldcolor.web(pal.colors[i])};"""
      blob = new Blob([data.join(\\n)], {type: "text/plain"})
      return res do
        blob: blob
        url: URL.createObjectURL blob
        filename: "#name.scss"
ldPalette.download = (pal, type = \png) ->
  ldPalette.convert pal, type .then (ret) ->
    a = ld$.create name: \a, attr: {download: ret.filename, href: ret.url}, style: display: \none
    document.body.appendChild a
    a.click!
    document.body.removeChild a

if window? => window.ldPalette = ldPalette
