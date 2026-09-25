# Rapport professionnel — JMH Solutions

## Introduction
Le projet met en œuvre une démarche DevOps complète pour une entreprise de services informatiques : automatisation, conteneurisation, CI/CD, orchestration et supervision. Le cas client est Nextcloud, avec une infrastructure évolutive et une chaîne de déploiement reproductible.

# Activité 1 — Automatisation du déploiement

## 1. Bash et serveur de monitoring
Bash (Bourne Again SHell) est un shell et langage de script Unix/Linux permettant d'automatiser les opérations d'administration. Le script `scripts/monitoring-server.sh` prépare Docker et lance la stack Zabbix. Une approche de production ajouterait la gestion des secrets, TLS, sauvegardes et règles firewall.

## 2. Serveur LAMP
LAMP signifie Linux + Apache + MariaDB/MySQL + PHP. Linux héberge le système, Apache sert les requêtes HTTP, MariaDB/MySQL stocke les données et PHP exécute la logique serveur.

## 3. Création LAMP
Le playbook `ansible/lamp.yml` installe Apache, MariaDB, PHP et extensions, active les services et crée une page de validation. Vérifications : `systemctl status apache2`, `systemctl status mariadb`, `curl http://IP_SERVEUR`.

## 4. Automatisation et contrôle
Étapes : définir l'état cible, versionner la configuration, paramétrer les variables, automatiser avec Ansible, déployer, effectuer des smoke tests, collecter les logs et documenter le rollback. La validation doit combiner état des services, ports, HTTP, logs et tests fonctionnels.

## 5. Outil de gestion d'infrastructure
Choix : Ansible pour la configuration et l'orchestration de tâches, Docker pour les workloads applicatifs et Terraform pour l'infrastructure Azure. Ce découpage sépare provisioning, configuration et exécution.

## 6. TestLink
TestLink est un outil open source de gestion des tests et des exigences. La stack `docker/testlink` fournit un environnement de laboratoire. Projet à créer : `JMH Nextcloud`, version `1.0`, suite `Authentification`, cas de test `Connexion avec identifiants valides`, résultat attendu : accès au tableau de bord.

## 7. Préproduction
La préproduction est un environnement séparé qui reproduit autant que possible la production afin de valider une version avant son déploiement. Flux recommandé : Développement → CI → TEST → PRÉPROD → validation → PROD. Elle doit isoler les données, secrets et accès ; les données personnelles de production ne doivent pas être recopiées sans protections adaptées.

## 8. Cloud computing
Le cloud fournit à la demande des ressources informatiques (calcul, réseau, stockage, bases et services) avec élasticité et facturation selon le modèle choisi. Étapes : analyse, choix IaaS/PaaS/SaaS, architecture réseau/IAM, sécurité, IaC, déploiement, supervision, sauvegardes, tests et optimisation des coûts.

# Activité 2 — Déployer en continu

## 1. Git/GitHub
```bash
git init
git add .
git commit -m "Initialisation projet JMH DevOps"
git branch -M main
git remote add origin git@github.com:VOTRE_COMPTE/jmh-devops-bac3.git
git push -u origin main
```

## 2. Environnement de test
Docker Compose fournit Nextcloud + MariaDB avec des volumes persistants. L'environnement est reproductible sur une VM Linux ou un poste Docker.

## 3. Base de données
MariaDB est utilisée par Nextcloud. Les données sont persistées par le volume Docker `db_data`.

## 4. phpMyAdmin
Le fichier `docker/nextcloud/docker-compose-with-phpmyadmin.yml` ajoute phpMyAdmin sur le port 8083. Il permet de consulter les schémas, tables et requêtes du SGBD de laboratoire.

## 5. Nextcloud
Le conteneur Nextcloud dépend de MariaDB et utilise le réseau Docker Compose. Les variables d'environnement initialisent la connexion DB et le compte administrateur.

## 6. Tests
Vérifier : disponibilité HTTP, connexion, création d'utilisateur, création/partage de fichier, redémarrage des conteneurs, persistance et logs. Commandes : `docker compose ps`, `docker compose logs --tail=100`, `docker compose exec nextcloud php occ status`.

## 7. Réplication DB
`docker/backup/replicate-mysql.sh` réalise une copie logique par `mysqldump` puis import. Pour une vraie réplication de production, utiliser les mécanismes natifs MySQL/MariaDB (binlogs/GTID selon le SGBD et le besoin), avec sauvegardes et tests de restauration.

## 8. Image MySQL/PHP/Composer
Le Dockerfile installe PHP Apache, extensions `mysqli`, `pdo_mysql`, `zip`, client MySQL et Composer. Construction : `docker build -t jmh/php-composer-mysql:1.0 docker/custom-app`.

## 9. Réseau Docker
`docker/network/create-network.sh` crée `jmh-net` et démarre un conteneur Nginx dessus. `docker network inspect jmh-net` vérifie le raccordement.

## 10. Mise à jour
Pour une image mise à jour : `docker compose pull`, `docker compose build --pull`, puis `docker compose up -d --force-recreate`. En production, préférer des tags immuables, un registre et une stratégie de rollback.

## 11. Limites de ressources
CPU : `--cpus=2`. RAM : `--memory=510m`. Stockage : `--storage-opt size=50G`, sous réserve du storage driver. Vérifier avec `docker inspect` et `docker stats`.

## 12. Kubernetes + Azure
Terraform crée un cluster AKS. Puis :
```bash
terraform init
terraform plan
terraform apply
az aks get-credentials --resource-group jmh-devops-rg --name jmh-aks
kubectl apply -f k8s/
kubectl get pods -n jmh-prod
```

## 13. Déploiement, mise à jour et test
Déployer les manifests, contrôler les pods et le service LoadBalancer. Pour une mise à jour : `kubectl -n jmh-prod set image deployment/nextcloud nextcloud=nextcloud:31-apache`, puis `kubectl -n jmh-prod rollout status deployment/nextcloud`. Tester HTTP, connexion, création de fichiers et logs. Prévoir `rollout undo` pour le rollback.

# Activité 3 — Zabbix

## 1. Installation
`docker/zabbix/docker-compose.yml` déploie base MySQL, Zabbix Server et frontend. Contrôles : `docker compose ps`, logs du serveur et accès au frontend.

## 2. Agents Linux/Windows
Linux : installer Zabbix Agent/Agent 2, renseigner `Server`, `ServerActive`, `Hostname`, démarrer le service et vérifier les logs. Windows : installer le MSI, renseigner les mêmes paramètres puis contrôler le service Windows. Les captures sont à réaliser sur votre laboratoire.

## 3. Périphériques sans Windows/Linux
Utiliser principalement SNMP pour imprimantes, switches et équipements réseau ; selon le matériel, IPMI/JMX ou contrôles externes peuvent être pertinents. Sécurité : privilégier SNMPv3, ACL réseau, VLAN de management, comptes dédiés, filtrage des ports et désactivation des protocoles obsolètes.

## 4. Templates et métriques
Créer l'hôte, renseigner son interface, associer le template correspondant, attendre la collecte puis consulter `Latest data`. Les métriques demandées sont CPU, RAM totale/utilisée, disque et disponibilité.

## 5. Incident applicatif
Qualifier l'alerte, vérifier criticité/périmètre, corréler métriques et logs, ouvrir ou enrichir le ticket, transmettre des éléments reproductibles au pôle Application, suivre le changement, valider le retour au nominal et documenter l'incident/cause/actions préventives.

## 6. Import de templates
Dans Zabbix : `Data collection → Templates → Import`, choisir le YAML/XML compatible avec la version du serveur, vérifier macros/items/triggers et associer le template à l'hôte.

## 7. Correction d'un appareil
Identifier le symptôme, collecter les preuves, diagnostiquer, sauvegarder la configuration, appliquer une correction contrôlée, tester, surveiller, documenter et prévoir un rollback. Pour un équipement critique, réaliser le changement selon la procédure de gestion des changements.

# Livrables et preuves
Les captures doivent montrer les opérations réellement effectuées. Ne pas afficher de secrets. La checklist est dans `docs/captures/README.md`.
