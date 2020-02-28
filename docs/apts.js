function links() {
  var rows=document.getElementsByTagName('tr');
  for (i=0;i<rows.length;i++) {
    var currentRow=rows[i];
    var createClickHandler=function(row){return function(){window.location=(row.id+'.html');};};
    currentRow.onclick=createClickHandler(currentRow);}}

function aptsLoad() {
  modDate=new Date(document.lastModified);
  document.body.innerHTML='<a href="index.html" title="Retour à la liste." id="back">Retour</a><h1>'+ibCourse+' - Accompagnement Pédagogique et Technique de stage</h1><div class="edition">(Dernière édition le '+modDate.getDate()+'/'+(modDate.getMonth()+1)+'/'+modDate.getFullYear()+')</div>'+document.body.innerHTML+'<div id="master1"></div><div id="master0"></div><div id="outro"></div>';
  if (document.getElementById('custo')) {document.getElementById('custo').innerHTML='<h2>Customisation spécifique du stage '+ibCourse+'</h2>'+document.getElementById('custo').innerHTML+'<hr/>';}
  if (document.getElementById('conseils')) {document.getElementById('conseils').innerHTML='<h2>Conseils d\'animation pour le stage '+ibCourse+'</h2>'+document.getElementById('conseils').innerHTML+'<div id="conseilsGeneriques">Prendre connaissance du fichier readme posé sur le bureau et suggérer aux stagiaires de faire de même.<br/>En cas de soucis sur un poste, il est possible de (re)lancer la commande <code>ibSetup '+ibCourse+' -force</code> pour mettre en place ou corriger les éléments de customisation décrits précédemment.<br/>(y ajouter l\'option "<code>-trainer</code>" sur le poste du formateur).</div>';}
  readFile(ibMaster1+'/master1.html','master1');
  readFile(ibMaster0+'/master0.html','master0');
  if (document.getElementById('goDeploy')) {readFile('goDeploy.html','goDeploy',true);}
  if (document.getElementById('o365')) {readFile('o365.html','o365',true);}
  if (document.getElementById('Azure')) {readFile('Azure.html','Azure',true);}
  readFile('outro.html','outro');
  document.title=ibCourse+' - APTS';}

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
