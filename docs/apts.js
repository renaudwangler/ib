function aptsLoad() {
  document.body.innerHTML='<h1>'+ibCourse+' - Accompagnement Pédagogique et Technique de stage</h1><div class="edition">Dernière édition le '+ibEdition+'</div>'+document.body.innerHTML
  document.getElementById('custo').innerHTML='<h2>Customisation spécifique du stage '+ibCourse+'</h2>'+document.getElementById('custo').innerHTML+'<hr/>';
  document.getElementById('conseils').innerHTML='<h2>Conseils d\'animation pour le stage '+ibCourse+'</h2>'+document.getElementById('conseils').innerHTML+'<br/>Prendre connaissance du fichier readme posé sur le bureau et suggérer aux stagiaires de faire de même.<br/>En cas de soucis sur un poste, il est possible de (re)lancer la commande <code>ibSetup '+ibCourse+' -force</code> pour mettre en place ou corriger les éléments de customisation décrits précédemment.<br/>(y ajouter l\'option "<code>-trainer</code>" sur le poste du formateur).<br/>';
  readFile('2019old/master1.html','master1');
  readFile('2019old/master0.html','master0');
  readFile('outro.html','outro');
  document.title=ibCourse+' - APTS';
  document.getElementsByTagName('h1')[0].innerHTML=ibCourse+' - Accompagnement Pédagogique et Technique de stage';}

function readFile(fileName,divID) {
  var txtFile=new XMLHttpRequest();
  txtFile.open('GET',fileName,true);
  txtFile.onreadystatechange = function() {
    if (txtFile.readyState === 4) {
      if (txtFile.status === 200) {
        var customTextElement = document.getElementById(divID);
        customTextElement.innerHTML = '<hr/>'+txtFile.responseText;}}}
txtFile.send(null);}
