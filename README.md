# JMH Solutions — Projet Bac+3 Administrateur Systèmes DevOps

Projet fil rouge couvrant les trois activités : automatisation d'infrastructure, déploiement continu de Nextcloud et supervision Zabbix.

## Architecture

```text
Git/GitHub -> GitHub Actions -> Docker/Test -> Kubernetes/AKS -> Production
                    |                 |                 |
                 Ansible          Nextcloud         MariaDB
                    |
                 LAMP

Zabbix -> agents Linux/Windows + SNMP -> Dashboard/alertes
```

## Prérequis
- Ubuntu Server 24.04 LTS ou Debian 12 recommandé
- Git, Docker + Compose plugin, Ansible
- Azure CLI, Terraform et kubectl pour AKS
- Compte GitHub

## Démarrage Nextcloud
```bash
cp .env.example .env
cd docker/nextcloud
# placer le .env à la racine ou adapter le chemin
sudo docker compose --env-file ../../.env up -d
sudo docker compose ps
```
Nextcloud : `http://localhost:8080`

## Zabbix
```bash
cd docker/zabbix
sudo docker compose up -d
```
Frontend : `http://localhost:8081` — identifiants initiaux courants : Admin / zabbix. Changez immédiatement le mot de passe.

## TestLink
```bash
cd docker/testlink
sudo docker compose up -d
```
Frontend : `http://localhost:8082`

## Ansible
```bash
cd ansible
cp inventory.example.ini inventory.ini
# modifier les IP
ansible-playbook -i inventory.ini lamp.yml
ansible-playbook -i inventory.ini monitoring.yml
```

## Docker
```bash
cd docker/custom-app
docker build -t jmh/php-composer-mysql:1.0 .
docker network create jmh-net
docker run -d --name jmh-app --network jmh-net --cpus=2 --memory=510m jmh/php-composer-mysql:1.0
```
La limitation de stockage `--storage-opt size=50G` dépend du storage driver Docker.

## Azure AKS
```bash
cd terraform/azure-aks
terraform init
terraform plan
terraform apply
az aks get-credentials --resource-group jmh-devops-rg --name jmh-aks
kubectl apply -f ../../k8s/
kubectl get pods -n jmh-prod
kubectl get svc -n jmh-prod
```

## CI/CD
`.github/workflows/ci.yml` construit l'image et réalise un smoke test. Le pipeline est volontairement simple et peut être relié à une registry privée puis à AKS.

## Documentation
- `docs/rapport.md` : réponses et procédures pour les 28 questions.
- `docs/soutenance.md` : déroulé de démonstration.
- `docs/captures/README.md` : liste des captures à réaliser.

**Important :** les secrets fournis sont fictifs. Ne jamais committer de vrais mots de passe, tokens ou clés Azure.
