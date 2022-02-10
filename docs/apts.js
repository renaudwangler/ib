courses = {
  //'m20411d':'Administrer Windows Server 2012 R2',
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


const unsortedObjArr = [...Object.entries(courses)];
const sortedObjArr = unsortedObjArr.sort(([key1, value1], [key2, value2]) => key2.localeCompare(key1));
const sortedObject = {}
sortedObjArr.forEach(([key, value]) => (sortedObject[key] = value));
courses=sortedObject;

function links() {
  courseTable=courseTable=document.getElementsByTagName('table')[0];
  Object.entries(courses).forEach(([courseId,courseTitle]) => {
    var newCourse=courseTable.insertRow(0);
    newCourse.id=courseId;
    newCourse.onclick=function(){window.location=(courseId+'.html')};
    var cell1=newCourse.insertCell(0);
    var cell2=newCourse.insertCell(1);
    cell1.innerHTML=courseId;
    cell2.innerHTML=courseTitle;});}

function aptsLoad() {
  var pageName = window.location.pathname.split('/').pop().split('.')[0];
  h1='<h1>'+pageName;
  if (courses[pageName]==undefined) h1+=' - Accompagnement Pédagogique et Technique de stage';
  else h1+=' - '+courses[pageName];
  document.body.innerHTML=h1+'<a href=https://github.com/renaudwangler/ib/edit/master/docs/'+pageName+'.html">\
  <span>\
  <svg viewBox="0 0 16 16"><path fill="#828282" d="M7.999,0.431c-4.285,0-7.76,3.474-7.76,7.761 c0,3.428,2.223,6.337,5.307,7.363c0.388,0.071,0.53-0.168,0.53-0.374c0-0.184-0.007-0.672-0.01-1.32 c-2.159,0.469-2.614-1.04-2.614-1.04c-0.3\
53-0.896-0.862-1.135-0.862-1.135c-0.705-0.481,0.053-0.472,0.053-0.472 c0.779,0.055,1.189,0.8,1.189,0.8c0.692,1.186,1.816,0.843,2.258,0.645c0.071-0.502,0.271-0.843,0.493-1.037 C4.86,11.425,3.049,10.76,3.049,7\
.786c0-0.847,0.302-1.54,0.799-2.082C3.768,5.507,3.501,4.718,3.924,3.65 c0,0,0.652-0.209,2.134,0.796C6.677,4.273,7.34,4.187,8,4.184c0.659,0.003,1.323,0.089,1.943,0.261 c1.482-1.004,2.132-0.796,2.132-0.796c0.4\
23,1.068,0.157,1.857,0.077,2.054c0.497,0.542,0.798,1.235,0.798,2.082 c0,2.981-1.814,3.637-3.543,3.829c0.279,0.24,0.527,0.713,0.527,1.437c0,1.037-0.01,1.874-0.01,2.129 c0,0.208,0.14,0.449,0.534,0.373c3.081-1.\
028,5.302-3.935,5.302-7.362C15.76,3.906,12.285,0.431,7.999,0.431z"/></svg></a>\
<a href="index.html" title="Retour à la liste." id="back"><img src="logo_ib.png" alt="Retour"></a></h1>'+document.body.innerHTML+'<div id="outro"></div>';
  
  if (document.getElementById('conseils')) {document.getElementById('conseils').innerHTML='<h2>Accompagnement Pédagogique et Technique pour le stage '+pageName+'</h2>'+document.getElementById('conseils').innerHTML;}
  if (document.getElementById('goDeploy')) {readFile('goDeploy.html','goDeploy');}
  if (document.getElementById('o365')) {readFile('o365.html','o365');}
  if (document.getElementById('Azure')) {readFile('Azure.html','Azure');}
  readFile('outro.html','outro');
  document.title=pageName+' - APTS';
  var iconRef=document.createElement('link');
  var cssRef = document.createElement('link');
  iconRef.setAttribute('rel','icon');
  iconRef.setAttribute('href','favicon.ico'); 
  cssRef.setAttribute('rel','stylesheet');
  cssRef.setAttribute('type','text/css');
  cssRef.setAttribute('href','ib-apts.css');
  document.getElementsByTagName('head')[0].appendChild(cssRef);
  document.getElementsByTagName('head')[0].appendChild(iconRef);}

function readFile(fileName,divID) {
  var txtFile=new XMLHttpRequest();
  txtFile.open('GET',fileName,true);
  txtFile.onreadystatechange = function() {
    if (txtFile.readyState === 4) {if (txtFile.status === 200) {
      div=document.getElementById(divID);
      div.innerHTML=txtFile.responseText;
      if (divID!='outro') {
        div.className='grey';
        h3=document.querySelector('#'+divID+'> h3');
        subDiv=document.querySelector('#'+divID+' h3::after');
        h3.parentElement.removeChild(h3);
        h3.onclick=switchDiv.bind(h3,divID+'-sub',h3);
        h3.className='moins';
        var newDiv=document.createElement('div');
        newDiv.id=divID+'-sub';
        newDiv.style.display='none';
        newDiv.innerHTML=div.innerHTML;
        div.innerHTML='';
        div.appendChild(h3);
        div.appendChild(newDiv);}}}}
txtFile.send(null);}

function switchDiv(divId,titre) {
  div=document.getElementById(divId);
  if (div.style.display=='none') {
    titre.className='plus';
    div.style.display='block'}
  else {
    div.style.display='none'
    titre.className='moins';}}