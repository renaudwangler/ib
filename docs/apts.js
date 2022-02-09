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
    cell2.innerHTML=courseTitle;
  });
}

function aptsLoad() {
  var pageName = window.location.pathname.split('/').pop().split('.')[0];
  h1='<h1>'+pageName;
  if (courses[pageName]==undefined) h1+=' - Accompagnement Pédagogique et Technique de stage';
  else h1+=' - '+courses[pageName];
  document.body.innerHTML=h1+'<a href="index.html" title="Retour à la liste." id="back"><img src="logo_ib.png" alt="Retour"></a></h1>'+document.body.innerHTML+'<div id="outro"></div>';
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
  document.getElementsByTagName('head')[0].appendChild(iconRef);
}

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
        var newDiv=document.createElement('div');
        newDiv.id=divID+'-sub';
        newDiv.style.display='none';
        newDiv.innerHTML=div.innerHTML;
        div.innerHTML='';
        div.appendChild(h3);
        div.appendChild(newDiv);}}}}
txtFile.send(null);}

function switchDiv(divId,param2) {
  console.log(param2);
  div=document.getElementById(divId);
  if (div.style.display=='none') {
    div.style.display='block'}
  else {
    div.style.display='none'};
}