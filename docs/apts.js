courses = {
  'm20411d':'Administrer Windows Server 2012 R2',
  'm20740c':'Installation de Windows Server 2016, gestion du stockage et de la virtualisation',
  'm20741b':'Les services réseaux Windows Server 2016',
  'm20742b':'Gestion des identités avec Windows Server 2016',
  'msws011':'Windows Server 2019 Administration',
  'msws012':'Windows Server 2019 hybride et Azure IaaS',
  'msaz104':'Microsoft Azure - Administration',
  'msaz303':'Microsoft Azure - Technologies pour les architectes',
  'msaz305':'Microsoft Azure - Conception d\'architectures',
  'msaz500':'Microsoft Azure - Technologies de sécurité',
  'msaz900':'Microsoft Azure - Notions fondamentales',
  'msms030':'Microsoft 365 - Administration',
  'm10997':'Microsoft 365 - Administration courante et dépannage',
  'msms100':'Microsoft 365 - Gestion des identités et des services',
  'msms101':'Microsoft 365 - Gestion de la sécurité et de la mobilité',
  'msms200':'Microsoft 365 - Planification et configuration d’une plate-forme de messagerie',
  'msms300':'Microsoft 365 - Déploiement de Teamwork',
  'msms500':' 365 - Security Administration',
  'msms700':'Administration de Microsoft Teams'

        };
//courses=sortObj(courses);

var sortKeys=(courses)=>{return Object.assign(...Object.entries(courses).sort().map(([key,value])=>{return{[key]:value}}));};
console.log(courses);
courses=sortKeys;

function sortObj(obj) {
  return Object.keys(obj).sort().reduce(function(result,key){result[key]=obj[key];return result;},{});}

function links() {
  courseTable=courseTable=document.getElementsByTagName('table')[0];
  Object.entries(courses).forEach(([courseId,courseTitle]) => {
    var newCourse=courseTable.insertRow(0);
    newCourse.id=courseId;
    newCourse.onclick=function(){window.location=(courseId+'.html')};
    var cell1=newCourse.insertCell(0);
    var cell2=newCourse.insertCell(1);
    cell1.innerHTML=courseId;
    cell2.innerHTML=courseTitle;
  });
}

function linksOld() {
  var rows=document.getElementsByTagName('tr');
  for (i=0;i<rows.length;i++) {
    var currentRow=rows[i];
    var createClickHandler=function(row){return function(){window.location=(row.id+'.html');};};
    currentRow.onclick=createClickHandler(currentRow);}}

function aptsLoad() {
  var pageName = window.location.pathname.split('/').pop().split('.')[0];
  document.body.innerHTML='<h1>'+pageName+' - Accompagnement Pédagogique et Technique de stage<a href="index.html" title="Retour à la liste." id="back"></a></h1>'+document.body.innerHTML+'<div id="outro"></div>';
  if (document.getElementById('conseils')) {document.getElementById('conseils').innerHTML='<h2>Conseils d\'animation pour le stage '+pageName+'</h2>'+document.getElementById('conseils').innerHTML;}
  if (document.getElementById('goDeploy')) {readFile('goDeploy.html','goDeploy',false);}
  if (document.getElementById('o365')) {readFile('o365.html','o365',false);}
  if (document.getElementById('Azure')) {readFile('Azure.html','Azure',false);}
  readFile('outro.html','outro');
  document.title=pageName+' - APTS';

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
