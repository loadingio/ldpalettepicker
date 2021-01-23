(function(){
  var mypal, save, pals, ret, ldpe, ldpe1, ldcvPicker, ldcvEditor, image, down;
  mypal = new ldPage({
    fetch: function(){
      return ld$.fetch('assets/sample-palettes.json', {}, {
        type: 'json'
      }).then(function(it){
        return it.map(function(it){
          it.payload.colors = it.payload.colors.map(function(it){
            return it.value;
          });
          return import$(it, it.payload);
        });
      });
    }
  });
  save = function(data){
    return new Promise(function(res, rej){
      console.log(data);
      return res();
    });
  };
  ldPalettePicker.register("default2", palettes);
  pals = ldPalettePicker.get("default2");
  ret = ldPalettePicker.init({
    pals: pals,
    useClusterizejs: true,
    mypal: mypal,
    save: save
  });
  ldpe = new ldPaletteEditor({
    root: '#ldcv-editor .ldpe'
  });
  ldpe1 = new ldPaletteEditor({
    root: '#ldpe-ex1'
  });
  window.ldcvPicker = ldcvPicker = new ldCover({
    root: document.querySelector('#ldcv-picker')
  });
  window.ldcvEditor = ldcvEditor = new ldCover({
    root: document.querySelector('#ldcv-editor')
  });
  window.image = image = function(type){
    type == null && (type = 'png');
    return ldPalette.convert(ldpe.getPal(), type).then(function(ret){
      var out, fr;
      out = document.querySelector('#image-output');
      if (type === 'png' || type === 'svg') {
        return out.innerHTML = "<img src=\"" + ret.url + "\" class=\"w-100\"/>";
      } else {
        fr = new FileReader();
        fr.onload = function(){
          return out.innerHTML = fr.result;
        };
        return fr.readAsText(ret.blob);
      }
    });
  };
  return window.down = down = function(type){
    type == null && (type = 'png');
    return ldPalette.download(ldpe.getPal(), type);
  };
})();
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}