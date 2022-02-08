function links() {
  var rows=document.getElementsByTagName('tr');
  for (i=0;i<rows.length;i++) {
    var currentRow=rows[i];
    var createClickHandler=function(row){return function(){window.location=(row.id+'.html');};};
    currentRow.onclick=createClickHandler(currentRow);}}

function aptsLoad(courseId) {
  var path = window.location.pathname;
  var page = path.split('/').pop();
  console.log( page );
  courseId=document.title;
  if (courseId==undefined) {courseId=ibCourse;}
  document.body.innerHTML='<a href="index.html" title="Retour à la liste." id="back">Retour</a><h1>'+courseId+' - Accompagnement Pédagogique et Technique de stage</h1>'+document.body.innerHTML+'<div id="outro"></div>';
  if (document.getElementById('conseils')) {document.getElementById('conseils').innerHTML='<h2>Conseils d\'animation pour le stage '+courseId+'</h2>'+document.getElementById('conseils').innerHTML;}
  if (document.getElementById('goDeploy')) {readFile('goDeploy.html','goDeploy',false);}
  if (document.getElementById('o365')) {readFile('o365.html','o365',false);}
  if (document.getElementById('Azure')) {readFile('Azure.html','Azure',false);}
  readFile('outro.html','outro');
  document.title=courseId+' - APTS';

  var iconRef=document.createElement('link');
  var cssRef = document.createElement('link');
  iconRef.setAttribute('rel','icon');
  iconRef.setAttribute('href','favicon.ico'); 
  cssRef.setAttribute('rel','stylesheet');
  cssRef.setAttribute('type','text/css');
  cssRef.setAttribute('href','ib-apts.css');
  document.getElementsByTagName("head")[0].appendChild(cssRef);
  document.getElementsByTagName('head')[0].appendChild(iconRef);
}

function readFile(fileName,divID,noHr=false) {
  var txtFile=new XMLHttpRequest();
  txtFile.open('GET',fileName,true);
  txtFile.onreadystatechange = function() {
    if (txtFile.readyState === 4) {
      if (txtFile.status === 200) {
        var customTextElement = document.getElementById(divID);
        if (noHr) {customTextElement.innerHTML = txtFile.responseText;} 
        else {customTextElement.innerHTML = '<hr/>'+txtFile.responseText;}}}}
txtFile.send(null);}
