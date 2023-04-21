(function(){
  var mypal, save, pals, ret, ldpe1, ldpe2, ldcvPicker, ldcvEditor, image, down;
  mypal = new ldpage({
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
  ldpp.register("default2", palettes);
  pals = ldpp.get("default2");
  ret = ldpp.init({
    pals: pals,
    'void': void 8,
    mypal: mypal,
    save: save,
    useVscroll: true
  });
  ret[0].on('use', function(it){
    return console.log(it);
  });
  ret[1].on('use', function(it){
    return console.log(it);
  });
  ldpe1 = new ldpe({
    root: '#ldcv-editor .ldpe'
  });
  ldpe2 = new ldpe({
    root: '#ldpe-ex1'
  });
  window.ldcvPicker = ldcvPicker = new ldcover({
    root: document.querySelector('#ldcv-picker')
  });
  window.ldcvEditor = ldcvEditor = new ldcover({
    root: document.querySelector('#ldcv-editor')
  });
  window.image = image = function(type){
    type == null && (type = 'png');
    return ldpalette.convert(ldpe1.getPal(), type).then(function(ret){
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
    return ldpalette.download(ldpe1.getPal(), type);
  };
})();
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}