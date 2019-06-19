function aptsLoad() {
  readFile('2019old/master1.html','master1');
  readFile('2019old/master0.html','master0');
  alert('ok');
}

function readFile(fileName,divID) {
  var txtFile=new XMLHttpRequest();
  txtFile.open('GET',fileName,true);
  txtFile.onreadystatechange = function() {
    if (txtFile.readyState === 4) {
      if (txtFile.status === 200) {
        var customTextElement = document.getElementById(divID);
        customTextElement.innerHTML = txtFile.responseText;
      }
    }
  }
}
