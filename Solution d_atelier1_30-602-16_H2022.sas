
*****************************************************************************************************;
*****************************************************************************************************;
*                             Math30602 Logiciels statistiques en gestion                           *;
*                             Atelier 1  SQL                                                        *;

*****************************************************************************************************;
*****************************************************************************************************;


*****************************************************************************************************;
*                              Creation de librairi et des tables                                    *
*                                                                                                    *
*****************************************************************************************************;
libname TP_1 "C:\Users\gita\Desktop\HEC_COURS\LOGICIEL_STATISTIQUE\ZCH21\ATLH2022\BD";


/*Importer des données EXCEL dans SAS et les stocker dans la librairie TP_1*/
PROC IMPORT OUT= TP_1.data_maisons_vendre
DATAFILE= "C:\Users\gita\Desktop\HEC_COURS\LOGICIEL_STATISTIQUE\ZCH21\ATLH2022\BD\data_maisons_vendre.xlsx"
DBMS=EXCEL REPLACE;
RANGE="Feuil1$";
GETNAMES=YES;
RUN;

PROC IMPORT OUT= TP_1.data_maisons_vendus_excel
DATAFILE= "C:\Users\gita\Desktop\HEC_COURS\LOGICIEL_STATISTIQUE\ZCH21\ATLH2022\BD\data_maisons_vendus.xlsx"
DBMS=EXCEL REPLACE;
RANGE="Feuil1$";
GETNAMES=YES;
RUN;
/*Importer des données csv dans SAS et les stocker dans la librairie TP_1*/


PROC IMPORT OUT= TP_1.data_maisons_vendus_csv
DATAFILE= "C:\Users\gita\Desktop\HEC_COURS\LOGICIEL_STATISTIQUE\ZCH21\ATLH2022\BD\data_maisons_vendus.csv"
DBMS=csv REPLACE;
RANGE="data_maisons_vendus$";
GETNAMES=YES;
RUN;



/*CREATIONN DES TABLES DANS work                       */
DATA data_maisons_vendre;
SET TP_1.data_maisons_vendre;
RUN;


DATA data_maisons_vendus;
SET TP_1.data_maisons_vendus_excel;
RUN;
*****************************************************************************************************;
*                                       Question 1	                                                 *
*Veuillez créer une table qui contient toutes les propriétés qui ne possèdent pas de jardin.         *
*Veuillez extraire les colonnes "numero_id", "prix", "date_poste" et "code_postal". Elle se nommera  *
*« data_sub_jard0 ».                                                                                 *
*****************************************************************************************************;

proc sql;
create table data_sub_jard0 as 
select numero_id,prix, date_poste, code_postal
from data_maisons_vendre
where  jardin=0
;
quit;

*****************************************************************************************************;
*                                       Question 2													 ;
* En prenant la table de données « data_sub_jard0 », veuillez créer une table de données qui         ; 
* comprendra toutes les propriétés répondant à un des critères suivants :                            ;
* o	Soit les 3 derniers caractères du code postal sont le 4B1.                                       ;
* o	Soit les 3 premiers caractères du code postal sont le H1M.                                       ;
* De plus, la maison doit coûter entre 600 000 $ et 850 000 $.                                       ;
* Veuillez ordonner cette table en ordre croissant par prix.                                         ;
*****************************************************************************************************;
proc sql;
create table data_jard0_h1m_4b1_600K_850K as 
select *
from data_sub_jard0
where (substr(code_postal,1,3)="H1M" or substr(code_postal,4,3)="4B1")
/*OU BIEN  where (code_postal LIKE "H1M%" OR code_postal LIKE "%4B1") */ 
and prix>=600000 and  prix<=850000    /* ou bien and prix between 600000 and 850000*/
order by prix /* ASC*/;
quit;

proc sql;
create table des_data_jard0_h1m_4b1_600K_850K as 
select *
from data_sub_jard0
/*where (substr(code_postal,1,3)="H1M" or substr(code_postal,4,3)="4B1")*/ 
  where (code_postal LIKE "H1M%" OR code_postal LIKE "%4B1") 
/* ou bie and prix>=600000 and  prix<=850000*/     and prix between 600000 and 850000
order by 2 ASC;
quit;

*****************************************************************************************************;
*                                       Question 3													 ;
*Nous vous demandons maintenant de créer une nouvelle variable qui se nommera "satisfaction" dans    ;
*notre table de données « data_maisons_vendre ».                                                     ;
*Cette variable sera une variable catégorielle à 3 modalités :     									 ;
*Elle prendra la valeur "OUI" lorsque :                                                              ;
* o	La propriété est un duplex ou un triplex et que le montant est inférieur à 500 000 $.            ;
* o	La propriété est une maison, qu’elle possède un jardin, qu'elle est dans le H2E, H3E OU H3T,    ;
*   et qu'elle coûte au plus 450 000 $.                                                              ;     
* o	La propriété est une maison en dessous de 300 000 $, qu’elle ne se trouve pas dans le H3X ou le  ;
*   H2Z et qu'elle possède un jardin.                                                                ;
*Elle prendra la valeur de "NON" si :                                                                ;
* o	La propriété coûte plus de 650 000 $.                                                            ;
* o	La propriété se trouve dans le H1Y ou le H1P.                                                    ;
*Dans tous les autres cas, la variable prendra la valeur de "NA".                                    ;
*De plus, nous nous intéresserons seulement aux maisons qui ont au minimum 3 pièces.   

*****************************************************************************************************;
proc sql;
create table Q3_data_maisons_vendre_3P as 
select *,
case 
when 
    (substr(numero_id,1,2) in ("tr","du") and prix<500000) or 

     (substr(numero_id,1,2)="ma" and jardin=1 and substr(code_postal,1,3) in ("H2E","H3E","H3T") and prix<=450000) or 

     (substr(numero_id,1,2)="ma" and prix <300000 and substr(code_postal,1,3) not in ("H3X","H2Z") and jardin=1)
     then "OUI"

when 
                (prix>650000) or 
                (substr(code_postal,1,3)  in ("H1Y","H1P"))
                then "NON"
     else "NA" 
end as satisfaction

from data_maisons_vendre
where nbr_pieces>=3
/*order by nbr_pieces*/
;
quit;

/*total de 649 maisons qui ont au minimum 3 pièces*/
*Validation;
PROC SQL;
SELECT DISTINCT (satisfaction)
FROM Q3_data_maisons_vendre_3P;
QUIT;
*Validation;
PROC SQL;
SELECT satisfaction, count( satisfaction)
FROM Q3_data_maisons_vendre_3P

group by satisfaction;
QUIT;

PROC SQL;
SELECT *
FROM Q3_data_maisons_vendre_3P
where satisfaction like "OUI"
;
QUIT;

*****************************************************************************************************;
*                                       Question 4													 ;
*Veuillez créer une table qui contient toutes les maisons à vendre qui ont été réellement vendues.   ;
*Référez-vous aux tables « data_maisons_vendre » et « data_maisons_vendues ». De plus, on vous       ;
*demande dans cette nouvelle table de créer une variable « FSA » qui contient les 3 premières lettres;
* du code postal.                                                                                    ;
*****************************************************************************************************;




proc sql;
create table Maison as
select 
		a.*,
		substr(a.code_postal,1,3) as FSA,
		b.prix as Prix_vendus,
		b.date_vendu
from 
		data_maisons_vendre as a
inner join
		data_maisons_vendus as b
on a.numero_id=b.numero_id;
quit;


*****************************************************************************************************;
*                                       Question 5													 ;
*Veuillez calculer le prix minimal, maximal et moyen de vente par FSA. Nous ne nous voulons pas      ;
*inclure les maisons qui ont un jardin ni celles avec un prix moyen supérieur à 600 000 $.           ;
*****************************************************************************************************;




proc sql;
CREATE TABLE Maison_Mean_plus_600K AS
 select 
 		FSA,
		min(prix) as prix_minimal_vendre,
		max(prix) as prix_maximal_vendre,
		mean(prix)as prix_moyen_vendre
		
from maison
where jardin=0
group by 	FSA 
having 	prix_moyen_vendre<=600000;
quit;

*VALIDATION ;

PROC SQL;
create table validation_h1j_j0 as 
SELECT * FROM maison WHERE FSA="H1J"  AND jardin=0
order by prix;
QUIT;

PROC SQL;
create table validation as 
SELECT mean(prix) FROM validation_h1j_j0 
;
QUIT;


*****************************************************************************************************;
*                                       Question 6													 ;
*Veuillez écrire une requête qui retourne uniquement la FSA ayant le prix de vente le plus élevé.    ;
*Référez-vous à la table de question 4.  outobs = 1                                                        ;
*****************************************************************************************************;
proc sql number outobs=1;
select FSA,Max(prix_vendus) as Prix_vendus_Maximal
from maison
group by FSA
order by 2 desc;
quit;

proc sql number outobs=1;
select FSA,Max(prix) as Prix_vendre_Maximal
from maison
group by FSA
order by 2 desc;
quit;





/*Ou bien  */
PROC SQL;
select 
		FSA,
		Max(prix_vendus) as Prix_vendus_Maximal
from
	maison
group by 
	FSA
having
	Prix_vendus_Maximal >= all (
								select Max(prix_vendus) 
								from maison
								);
QUIT;



*Validation all;
PROC SQL; 
select Max(prix_vendus) as Prix_vendus_Maximal	
from maison

;
QUIT;

*****************************************************************************************************;
*                                       Question 7													 ;
*Veuillez écrire une requête qui retourne uniquement les FSA ayant le prix maximum de vente plus élevé;
*que la moyenne de toutes les maisons . Référez-vous à la table de question 4.                              ;
*****************************************************************************************************;




PROC SQL number;
select 
		FSA,
		mean(prix_vendus) as Prix_vendus_moyen
from
	maison
group by 
	FSA
having
	Prix_vendus_moyen >= all (
								select mean(prix_vendus) 
								from maison
 
								)
order by 2 desc;
QUIT;

/*reference ALL: https://www.w3schools.com/sql/sql_any_all.asp*/
*Validation 551280$;
PROC SQL ;

select mean(prix_vendus) as Prix_vendus_moyenne
from maison 
;							
QUIT;

*****************************************************************************************************;
*                                       Question 8													 ;
*Veuillez écrire une requête qui retourne le nombre de maisons vendues chaque mois.                  ;
*Référez-vous à la table maison.                                                                     ;
*****************************************************************************************************;

proc sql number;
SELECT mois_vendu,count(numero_id) as vente_par_mois
from (SELECT *,month(date_vendu)as mois_vendu
                 from maison)
group by mois_vendu
;
quit;




proc sql number;
SELECT *,month(date_vendu)as mois_vendu
from maison
;
quit;

