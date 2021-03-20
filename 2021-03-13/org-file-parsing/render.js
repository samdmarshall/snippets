
// var render = (function () {
//   var constants = {
//
//   }
//
//
// })();

document.addEventListener('readystatechange', (event) => {
  switch (event.target.readyState) {
    case "loading": {
      console.log("DOM: Loading...");
      break;
    }
    case "interactive": {
      console.log("DOM: Loaded!");
      break;
    }
    case "complete": {
      console.log("DOM+Resources: Loaded!");
      let document = event.target;
      let orgfile_contents = document.getElementsByTagName("noscript")[0].innerHTML;
      

      var parser = new Org.Parser();
      var org_document = parser.parse(orgfile_contents);
      var org_html_document = org_document.convert(Org.ConverterHTML, {
        
      });
      let parent_node = document.getElementsByTagName("main")[0];
      let rendered_orgfile = org_html_document.toString();
      parent_node.insertAdjacentHTML('afterbegin', rendered_orgfile);
      break;
    }
  }
});
