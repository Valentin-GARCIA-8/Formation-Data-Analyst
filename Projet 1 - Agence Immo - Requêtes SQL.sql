-- -----------------------------------------------------
-- Creation BDD nommee DATAIMMO
-- -----------------------------------------------------
CREATE database `DATAIMMO` ;
USE `DATAIMMO` ;


-- -----------------------------------------------------
-- Creation Table Recensement
-- -----------------------------------------------------
CREATE TABLE `Recensement` (
  `id_Population` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `nombre_Population` INT NULL,
  `annee_Recensement` INT NULL) ;


-- -----------------------------------------------------
-- Creation Table Region
-- -----------------------------------------------------
CREATE TABLE `Region` (
  `id_Region` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `nom_Region` VARCHAR(50) NULL) ;


-- -----------------------------------------------------
-- Creation Table Departement
-- -----------------------------------------------------
CREATE TABLE `Departement` (
  `id_Departement` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `code_Departement` VARCHAR(50) NULL,
  `Region_id` INT NULL,
  FOREIGN KEY (`Region_id`) REFERENCES `Region` (`id_Region`) ON DELETE SET NULL ON UPDATE SET NULL) ;


-- -----------------------------------------------------
-- Creation Table Commune
-- -----------------------------------------------------
CREATE TABLE `Commune` (
  `id_Commune` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `nom_Commune` VARCHAR(50) NULL,
  `Population_id` INT NULL,
  FOREIGN KEY (`Population_id`) REFERENCES `Recensement` (`id_Population`) ON DELETE SET NULL ON UPDATE SET NULL,
  `Departement_id` INT NULL,
  FOREIGN KEY (`Departement_id`) REFERENCES `Departement` (`id_Departement`) ON DELETE SET NULL ON UPDATE SET NULL) ;



-- -----------------------------------------------------
-- Creation Table Bien
-- -----------------------------------------------------
CREATE TABLE `Bien` (
  `id_Bien` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `type_Local` VARCHAR(50) NULL,
  `surface_Carrez` FLOAT NULL,
  `surface_Local` FLOAT NULL,
  `total_Piece` INT NULL,
  `numero_Voie` INT NULL,
  `type_Voie` VARCHAR(50) NULL,
  `nom_Voie` VARCHAR(50) NULL,
  `Commune_id` INT NULL,
  FOREIGN KEY (`Commune_id`) REFERENCES `Commune` (`id_Commune`) ON DELETE SET NULL ON UPDATE SET NULL) ;

-- -----------------------------------------------------
--   Creation Table Vente
-- -----------------------------------------------------
CREATE TABLE `Vente` (
  `id_Vente` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `date_Vente` DATE NULL,
  `valeur_Vente` FLOAT NULL,
  `Bien_id` INT NULL,
  FOREIGN KEY (`Bien_id`) REFERENCES `Bien` (`id_Bien`) ON DELETE SET NULL ON UPDATE SET NULL) ;






-- -----------------------------------------------------
-- -----------------------------------------------------
-- EXERCICE REQUETES
-- -----------------------------------------------------
-- -----------------------------------------------------


-- -----------------------------------------------------
-- 1.Nombre total d’appartements vendus au 1er semestre 2020
-- -----------------------------------------------------
SELECT COUNT(`id_Vente`) AS 'Nb appartement vendu' 
FROM `Vente` 
JOIN `Bien` ON `Vente`.`Bien_id` = `Bien`.`id_Bien`
WHERE `Bien`.`type_Local` = 'Appartement'
AND `Vente`.`date_Vente` BETWEEN '2020-01-01' AND '2020-06-30';


-- -----------------------------------------------------
-- 2.Le nombre de ventes d’appartement par région pour le 1er semestre 2020
-- -----------------------------------------------------
SELECT `Region`.`nom_Region` AS 'Région', 
	COUNT(`id_Vente`) AS 'Nb appartement vendu'
FROM `Vente` 
JOIN `Bien` ON `Vente`.`Bien_id` = `Bien`.`id_Bien`
JOIN `Commune` ON `Bien`.`Commune_id` = `Commune`.`id_Commune`
JOIN `Departement` ON `Commune`.`Departement_id` = `Departement`.`id_Departement`
JOIN `Region` ON `Departement`.`Region_id` = `Region`.`id_Region`
WHERE `Bien`.`type_Local` = 'Appartement'
AND `Vente`.`date_Vente` BETWEEN '2020-01-01' AND '2020-06-30'
GROUP BY `Region`.`nom_Region`;


-- -----------------------------------------------------
-- 3. Proportion des ventes d’appartements par le nombre de pièces
-- -----------------------------------------------------
SELECT `total_Piece` AS 'Nb pièces',
  COUNT(`Vente`.`id_Vente`) AS 'Nb Vente',
  ROUND(COUNT(`Vente`.`id_Vente`) / 
		(SELECT COUNT(`id_Vente`) 
		FROM `Vente` 
        JOIN `Bien` ON `Vente`.`Bien_id` = `Bien`.`id_Bien` 
        WHERE `Bien`.`type_Local` = 'Appartement')
        *100,2) AS 'Pourcentage'
FROM `Vente` 
JOIN `Bien` ON `Vente`.`Bien_id` = `Bien`.`id_Bien`
WHERE `Bien`.`type_Local` = 'Appartement'
GROUP BY `total_Piece`
ORDER BY `total_Piece` ASC;



-- -----------------------------------------------------
-- 4.Liste des 10 départements où le prix du mètre carré est le plus élevé
-- -----------------------------------------------------
SELECT `Departement`.`code_Departement`AS 'Département', 
  ROUND(SUM(`Vente`.`valeur_Vente`) / SUM(`Bien`.`surface_Carrez`)) AS 'euros/m2'
FROM `Vente`
JOIN `Bien` ON `Vente`.`Bien_id` = `Bien`.`id_Bien`
JOIN `Commune` ON `Bien`.`Commune_id` = `Commune`.`id_Commune`
JOIN `Departement` ON `Commune`.`Departement_id` = `Departement`.`id_Departement`
GROUP BY `Departement`.`code_Departement`
ORDER BY SUM(`Vente`.`valeur_Vente`) / SUM(`Bien`.`surface_Carrez`) DESC 
LIMIT 10 ;


-- -----------------------------------------------------
-- 5. Prix moyen du mètre carré d’une maison en Île-de-France
-- -----------------------------------------------------
SELECT ROUND(SUM(`Vente`.`valeur_Vente`) / SUM(`Bien`.`surface_Carrez`)) AS 'euros/m2 en moyenne'
FROM `Vente` 
JOIN `Bien` ON `Vente`.`Bien_id` = `Bien`.`id_Bien`
JOIN `Commune` ON `Bien`.`Commune_id` = `Commune`.`id_Commune`
JOIN `Departement` ON `Commune`.`Departement_id` = `Departement`.`id_Departement`
JOIN `Region` ON `Departement`.`Region_id` = `Region`.`id_Region`
WHERE `type_Local` = 'Maison'
AND `nom_Region` = 'Île-de-France';


-- -----------------------------------------------------
-- 6. Liste des 10 appartements les plus chers avec la région et le nombre de mètres carrés
-- -----------------------------------------------------
SELECT MAX(`Vente`.`valeur_Vente`) AS 'euros', 
  `Bien`.`surface_Carrez` AS 'm2', 
  `Region`.`nom_Region` AS 'Région',
  `Departement`.`code_Departement` AS 'Département',
  `Bien`.`id_Bien` AS 'Identifiant du logement dans la BDD'
FROM `Vente`
JOIN `Bien` ON `Vente`.`Bien_id` = `Bien`.`id_Bien`
JOIN `Commune` ON `Bien`.`Commune_id` = `Commune`.`id_Commune`
JOIN `Departement` ON `Commune`.`Departement_id` = `Departement`.`id_Departement`
JOIN `Region` ON `Departement`.`Region_id` = `Region`.`id_Region`
WHERE `type_Local` = 'Appartement'
GROUP BY `Vente`.`valeur_Vente`
ORDER BY `Vente`.`valeur_Vente` DESC 
LIMIT 10;


-- -----------------------------------------------------
-- 7. Taux d’évolution du nombre de ventes entre le premier et le second trimestre de 2020
-- -----------------------------------------------------
WITH 
`Trim1` AS ( 
SELECT COUNT(`id_Vente`) AS NB1 
FROM `Vente` 
WHERE `date_Vente` BETWEEN '2020-01-01' AND '2020-03-31') , 
`Trim2` AS ( 
SELECT COUNT(`id_Vente`)  AS NB2 
FROM `Vente` 
WHERE `date_Vente` BETWEEN '2020-04-01' AND '2020-06-30') 
SELECT 	NB1 AS 'NB Vente 1er trimestre', 
		NB2 AS 'NB Vente 2e trimestre', 
        ROUND(( ( (NB2 - NB1) / NB1) )*100,2) AS 'Taux évolution en %' 
FROM `Trim1`, `Trim2` ;


-- -----------------------------------------------------
-- 8. Le classement des régions par rapport au prix au mètre carré des appartement de plus de 4 pièces
-- -----------------------------------------------------
SELECT `Region`.`nom_Region` AS 'Région', 
  ROUND(SUM(`Vente`.`valeur_Vente`) / SUM(`Bien`.`surface_Carrez`)) AS 'euros/m2'
FROM `Vente`  
JOIN `Bien` ON `Vente`.`Bien_id` = `Bien`.`id_Bien` 
JOIN `Commune` ON `Bien`.`Commune_id` = `Commune`.`id_Commune` 
JOIN `Departement` ON `Commune`.`Departement_id` = `Departement`.`id_Departement` 
JOIN `Region` ON `Departement`.`Region_id` = `Region`.`id_Region` 
WHERE `total_Piece` > 4 
AND `Bien`.`type_Local` = 'Appartement' 
GROUP BY `Region`.`nom_Region` 
ORDER BY SUM(`Vente`.`valeur_Vente`) / SUM(`Bien`.`surface_Carrez`) DESC ;




-- -----------------------------------------------------
-- 9. Liste des communes ayant eu au moins 50 ventes au 1er trimestre
-- -----------------------------------------------------
SELECT `Commune`.`nom_Commune` AS 'Commune',
  COUNT(`Vente`.`id_Vente`) AS 'Nb Vente'
FROM `Vente`  
JOIN `Bien` ON `Vente`.`Bien_id` = `Bien`.`id_Bien` 
JOIN `Commune` ON `Bien`.`Commune_id` = `Commune`.`id_Commune` 
WHERE `Vente`.`date_Vente` BETWEEN '2020-01-01' AND '2020-06-30'
GROUP BY `Commune`.`nom_Commune` 
HAVING COUNT(`Vente`.`id_Vente`) >= 50 
ORDER BY COUNT(`Vente`.`id_Vente`) DESC ;


-- -----------------------------------------------------
-- 10. Différence en pourcentage du prix au mètre carré entre un appartement de 2 pièces et un appartement de 3 pièces
-- -----------------------------------------------------
SELECT ROUND(SUM(`Vente`.`valeur_Vente`)/SUM(`Bien`.`surface_Carrez`))  AS 'Prix moyen / m2 appartement 2 pièces',
(SELECT ROUND(SUM(`Vente`.`valeur_Vente`)/SUM(`Bien`.`surface_Carrez`))  
FROM `Vente` 
JOIN `Bien` ON `Vente`.`Bien_id` = `Bien`.`id_Bien` 
WHERE `Bien`.`type_Local` = 'Appartement'  
AND `Bien`.`total_Piece` = 3) AS 'Prix moyen / m2 appartement 3 pièces',
ROUND( 100 * ( 1 - (
(SELECT ROUND(SUM(`Vente`.`valeur_Vente`)/SUM(`Bien`.`surface_Carrez`))  
FROM `Vente` 
JOIN `Bien` ON `Vente`.`Bien_id` = `Bien`.`id_Bien` 
WHERE `Bien`.`type_Local` = 'Appartement'   
AND `Bien`.`total_Piece` = 3) 
/ 
( SUM(`Vente`.`valeur_Vente`)/SUM(`Bien`.`surface_Carrez`))
)),2) AS "Différence en %"
FROM `Vente` 
JOIN `Bien` ON `Vente`.`Bien_id` = `Bien`.`id_Bien` 
WHERE `Bien`.`type_Local` = 'Appartement' 
AND `Bien`.`total_Piece` = 2 ; 





WITH 
`Appart2` AS ( 
SELECT ROUND(SUM(`Vente`.`valeur_Vente`)/SUM(`Bien`.`surface_Carrez`)) AS VA1 
FROM `Vente`
JOIN `Bien` ON `Vente`.`Bien_id` = `Bien`.`id_Bien`  
WHERE `Bien`.`type_Local` = 'Appartement'  
AND `Bien`.`total_Piece` = 2) , 
`Appart3` AS ( 
SELECT ROUND(SUM(`Vente`.`valeur_Vente`)/SUM(`Bien`.`surface_Carrez`)) AS VA2 
FROM `Vente` 
JOIN `Bien` ON `Vente`.`Bien_id` = `Bien`.`id_Bien`  
WHERE `Bien`.`type_Local` = 'Appartement'  
AND `Bien`.`total_Piece` = 3) 
SELECT 	VA1 AS 'Prix moyen / m2 appartement 2 pièces', 
		VA2 AS 'Prix moyen / m2 appartement 3 pièces',
        ROUND( ABS((VA2-VA1)/VA1) * 100 ,2) AS 'Différence en %' 
FROM `Appart2`, `Appart3`;






-- -----------------------------------------------------
-- 11. Les moyennes de valeurs foncières pour le top 3 des communes des départements 6, 13, 33, 59 et 69
-- -----------------------------------------------------

WITH 
`Calcul_Ville` AS ( 
SELECT `code_departement`, `nom_commune`, ROUND(AVG(`valeur_Vente`)) AS Calcul 
FROM `Vente` 
JOIN `Bien` ON `Vente`.`Bien_id` = `Bien`.`id_Bien` 
JOIN `Commune` ON `Bien`.`Commune_id` = `Commune`.`id_Commune` 
JOIN `Departement` ON `Commune`.`Departement_id` = `Departement`.`id_Departement` 
WHERE `code_departement` IN (6, 13, 33, 59, 69) 
GROUP BY `code_departement`, `nom_commune`) 
SELECT 	`code_departement` AS 'Département', 
		`nom_commune` AS 'Commune',  
        Calcul AS 'Valeur foncière moyenne' 
FROM (  
SELECT `code_departement`, `nom_commune`, Calcul,  
RANK() OVER (PARTITION BY `code_departement` ORDER BY Calcul DESC ) AS rang 
FROM `Calcul_Ville`) AS inutil 
WHERE rang <= 3 ; 






(SELECT ROUND(AVG(`Vente`.`valeur_Vente`)) AS 'Valeur foncière moyenne', 
`Commune`.`nom_Commune` AS 'Commune', 
`Departement`.`code_Departement` AS 'DEPARTEMENT' 
FROM `Vente` 
JOIN `Bien` ON `Vente`.`Bien_id` = `Bien`.`id_Bien` 
JOIN `Commune` ON `Bien`.`Commune_id` = `Commune`.`id_Commune`  
JOIN `Departement` ON `Commune`.`Departement_id` = `Departement`.`id_Departement` 
WHERE `Departement`.`code_Departement` = 6 
GROUP BY `Commune`.`nom_Commune`
ORDER BY `valeur_Vente` DESC 
LIMIT 3)
UNION 
(SELECT ROUND(AVG(`Vente`.`valeur_Vente`)) AS 'Valeur foncière moyenne', 
`Commune`.`nom_Commune` AS 'Commune', 
`Departement`.`code_Departement` AS 'DEPARTEMENT' 
FROM `Vente` 
JOIN `Bien` ON `Vente`.`Bien_id` = `Bien`.`id_Bien` 
JOIN `Commune` ON `Bien`.`Commune_id` = `Commune`.`id_Commune`  
JOIN `Departement` ON `Commune`.`Departement_id` = `Departement`.`id_Departement` 
WHERE `Departement`.`code_Departement` = 13 
GROUP BY `Commune`.`nom_Commune` 
ORDER BY `valeur_Vente` DESC 
LIMIT 3) 
UNION 
(SELECT ROUND(AVG(`Vente`.`valeur_Vente`)) AS 'Valeur foncière moyenne', 
`Commune`.`nom_Commune` AS 'Commune', 
`Departement`.`code_Departement` AS 'DEPARTEMENT' 
FROM `Vente` 
JOIN `Bien` ON `Vente`.`Bien_id` = `Bien`.`id_Bien` 
JOIN `Commune` ON `Bien`.`Commune_id` = `Commune`.`id_Commune`  
JOIN `Departement` ON `Commune`.`Departement_id` = `Departement`.`id_Departement` 
WHERE `Departement`.`code_Departement` = 33 
GROUP BY `Commune`.`nom_Commune` 
ORDER BY `valeur_Vente` DESC 
LIMIT 3) 
UNION 
(SELECT ROUND(AVG(`Vente`.`valeur_Vente`)) AS 'Valeur foncière moyenne', 
`Commune`.`nom_Commune` AS 'Commune', 
`Departement`.`code_Departement` AS 'DEPARTEMENT' 
FROM `Vente` 
JOIN `Bien` ON `Vente`.`Bien_id` = `Bien`.`id_Bien` 
JOIN `Commune` ON `Bien`.`Commune_id` = `Commune`.`id_Commune`  
JOIN `Departement` ON `Commune`.`Departement_id` = `Departement`.`id_Departement` 
WHERE `Departement`.`code_Departement` = 59 
GROUP BY `Commune`.`nom_Commune` 
ORDER BY `valeur_Vente` DESC 
LIMIT 3) 
UNION 
(SELECT ROUND(AVG(`Vente`.`valeur_Vente`)) AS 'Valeur foncière moyenne', 
`Commune`.`nom_Commune` AS 'Commune', 
`Departement`.`code_Departement` AS 'DEPARTEMENT' 
FROM `Vente` 
JOIN `Bien` ON `Vente`.`Bien_id` = `Bien`.`id_Bien` 
JOIN `Commune` ON `Bien`.`Commune_id` = `Commune`.`id_Commune`  
JOIN `Departement` ON `Commune`.`Departement_id` = `Departement`.`id_Departement` 
WHERE `Departement`.`code_Departement` = 69 
GROUP BY `Commune`.`nom_Commune` 
ORDER BY `valeur_Vente` DESC 
LIMIT 3) ;



