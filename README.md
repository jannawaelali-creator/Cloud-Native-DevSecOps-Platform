
# ☁️ Cloud-Native DevSecOps Platform

**A production-grade, security-first CI/CD platform built on AWS EKS — featuring GitOps delivery via ArgoCD, automated infrastructure with Terraform & Ansible, and full-stack observability with Prometheus & Grafana.**

[![AWS](https://img.shields.io/badge/AWS-EKS%20%7C%20IAM%20%7C%20ALB-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-EKS-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Jenkins](https://img.shields.io/badge/Jenkins-CI%20Pipeline-D24939?style=for-the-badge&logo=jenkins&logoColor=white)](https://www.jenkins.io/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-GitOps%20CD-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)](https://argo-cd.readthedocs.io/)
[![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Ansible](https://img.shields.io/badge/Ansible-Provisioning-EE0000?style=for-the-badge&logo=ansible&logoColor=white)](https://www.ansible.com/)
[![Prometheus](https://img.shields.io/badge/Prometheus-Monitoring-E6522C?style=for-the-badge&logo=prometheus&logoColor=white)](https://prometheus.io/)
[![Grafana](https://img.shields.io/badge/Grafana-Observability-F46800?style=for-the-badge&logo=grafana&logoColor=white)](https://grafana.com/)
[![Trivy](https://img.shields.io/badge/Trivy-Security%20Scanning-1904DA?style=for-the-badge&logo=aqua&logoColor=white)](https://trivy.dev/)
[![Docker](https://img.shields.io/badge/Docker-Containers-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Node.js](https://img.shields.io/badge/Node.js-Backend-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/)

</div>

---

## 📌 Project Overview

This project implements an **end-to-end DevSecOps platform** for a full-stack web application, following industry best practices for cloud-native workloads on AWS.

It covers the complete software delivery lifecycle:

- **Infrastructure** — VPC, EKS cluster, and IAM roles provisioned with Terraform; Jenkins EC2 slave configured with Ansible
- **CI** — Jenkins pipeline builds Docker images, scans for vulnerabilities with Trivy, and pushes to the registry
- **CD** — ArgoCD watches the Git repository and syncs Kubernetes manifests to EKS automatically (GitOps)
- **Observability** — Prometheus + Grafana + Alertmanager deployed via `kube-prometheus-stack`, accessible through host-based Ingress routing

The platform was designed with a **security-first philosophy**: no static AWS keys in the cluster (IRSA), no hardcoded secrets, container images gated by CVE scanning before any push, and every deployment traceable as a Git commit.

> **Stack:** AWS EKS · Terraform · Ansible · Jenkins · ArgoCD · Docker · Kubernetes · Helm · Prometheus · Grafana · Trivy · Node.js

---

## 📸 Platform in Action

### Application — `http://app.local`

The frontend serves a **Cloud-Native Dashboard** that calls a secure Node.js backend, which in turn queries the database and returns a live timestamp — proving full end-to-end connectivity across all three tiers running inside the cluster.

> *Frontend → Node.js Backend → PostgreSQL/MySQL StatefulSet → response rendered in browser*

!<img width="1175" height="394" alt="image" src="https://github.com/user-attachments/assets/225d5280-827c-4d1b-9b22-b79f47453d69" />


---

### Observability — `http://grafana.local`

Grafana is live and accessible via host-based Ingress routing. Prometheus scrapes cluster metrics (node CPU/memory, pod states, container resource usage) and feeds them into pre-built dashboards.

!<img width="1512" height="791" alt="image" src="https://github.com/user-attachments/assets/1a567cea-e5f2-47b5-90e6-ecd526567bc0" />


---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                       Developer pushes code                          │
└───────────────────────────────┬──────────────────────────────────────┘
                                │
                                ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    CONTINUOUS INTEGRATION                            │
│                   Jenkins (EC2 Slave Agent)                          │
│                                                                      │
│  Pull Code → Build Images → Trivy Scan → Push → Update k8s tags     │
└───────────────────────────────┬──────────────────────────────────────┘
                                │  git commit (image tag bump)
                                ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    CONTINUOUS DELIVERY                               │
│                   ArgoCD (GitOps Operator)                           │
│                                                                      │
│  Watches repo → Detects drift → Auto-syncs to EKS cluster           │
└───────────────────────────────┬──────────────────────────────────────┘
                                │
                                ▼
┌──────────────────────────────────────────────────────────────────────┐
│                   AWS EKS CLUSTER (us-east-1)                        │
│                                                                      │
│  ┌───────────────────────────────────────────────────────────────┐   │
│  │              default namespace  (application)                 │   │
│  │                                                               │   │
│  │  ┌─────────────┐   ┌──────────────┐   ┌──────────────────┐   │   │
│  │  │  Frontend   │   │  Node.js     │   │  StatefulSet DB  │   │   │
│  │  │  HTML/JS    │──▶│  Backend API │──▶│  (EBS PVC)       │   │   │
│  │  │  :80        │   │  (secure)    │   │  headless svc    │   │   │
│  │  └──────┬──────┘   └──────────────┘   └──────────────────┘   │   │
│  │         │  frontend-service                                   │   │
│  └─────────┼─────────────────────────────────────────────────────┘   │
│            │                                                          │
│  ┌─────────▼─────────────────────────────────────────────────────┐   │
│  │               Kubernetes Ingress Controller                   │   │
│  │  Host: app.local     ──▶  frontend-service (:80)              │   │
│  │  Host: grafana.local ──▶  grafana-service  (devops-project)   │   │
│  └───────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  ┌───────────────────────────────────────────────────────────────┐   │
│  │           devops-project namespace  (monitoring)              │   │
│  │                                                               │   │
│  │  Prometheus (StatefulSet) · Grafana · Alertmanager            │   │
│  │  Node Exporter (DaemonSet) · kube-state-metrics               │   │
│  └───────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  ┌───────────────────────────────────────────────────────────────┐   │
│  │           kube-system namespace  (cluster add-ons)            │   │
│  │                                                               │   │
│  │  AWS Load Balancer Controller · EBS CSI Driver · ArgoCD       │   │
│  └───────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────┘
                                │
               ┌────────────────┴────────────────┐
               ▼                                 ▼
      Terraform (IaC)                   Ansible (Configuration)
      VPC · EKS · IAM roles             Jenkins EC2 slave setup
```

---

## 🌐 Application & Ingress Routing

### The Application

The platform hosts a **custom full-stack web application** composed of three tiers:

| Tier | Stack | Workload Type | Details |
|---|---|---|---|
| **Frontend** | HTML + JavaScript | `Deployment` | Serves the Cloud-Native Dashboard UI on port 80 |
| **Backend** | Node.js | `Deployment` | Secure REST API; queries the database and returns live data (e.g. DB timestamp) |
| **Database** | StatefulSet | `StatefulSet` | Persistent storage backed by an AWS EBS volume via the EBS CSI driver; stable DNS via headless service |

When you open `http://app.local`, the browser loads the frontend, which calls the Node.js backend, which queries the database — the response (`Database time is: Fri Jun 19 2026 14:34:09 GMT+0000`) confirms the entire stack is connected and healthy inside the cluster.

### Host-Based Ingress Routing

A single Ingress resource routes traffic to the correct service based on the `Host` HTTP header — no path prefixes needed:

```
Browser sends request
        │
        │  GET / HTTP/1.1
        │  Host: app.local          ← set by /etc/hosts
        ▼
┌───────────────────────────────┐
│   Kubernetes Ingress          │
│   (NGINX Ingress Controller)  │
└──────────┬────────────────────┘
           │
    ┌──────┴────────────────────────┐
    │                               │
    ▼                               ▼
Host: app.local               Host: grafana.local
    │                               │
frontend-service              grafana-service
(default ns, port 80)         (devops-project ns)
    │
frontend pods
    │
  calls backend API
    │
  backend queries DB
    │
  DB timestamp returned ✓
```

### `/etc/hosts` Configuration

Because the cluster uses local DNS names (not real public DNS), you must map them manually:

```bash
# Linux / macOS
sudo nano /etc/hosts

# Windows
notepad C:\Windows\System32\drivers\etc\hosts
```

Add the following lines (replace `<INGRESS-IP>` with your actual Ingress external IP):

```
<INGRESS-IP>   app.local
<INGRESS-IP>   grafana.local
```

Get the IP with:

```bash
# On EKS / with ALB:
kubectl get ingress -A

# On Minikube:
minikube ip
```

Then open:
- **`http://app.local`** → Cloud-Native Dashboard (frontend + backend + DB)
- **`http://grafana.local`** → Grafana monitoring dashboards

---

## 📁 Repository Structure

```
Cloud-Native-DevSecOps-Platform/
│
├── Jenkinsfile              # CI pipeline: build → scan → push → update manifests
├── Jenkinsfile.cluster      # Cluster bootstrap: OIDC, ALB, EBS CSI, ArgoCD
│
├── app/                     # Node.js backend source code + Dockerfile
├── frontend/                # HTML/JS frontend source code + Dockerfile
│
├── k8s/                     # Kubernetes manifests (GitOps source of truth for ArgoCD)
│   ├── backend_deployment.yml
│   ├── frontend_deployment.yml
│   ├── backend_service.yml
│   ├── frontend_service.yml
│   ├── backend_configmap.yml
│   ├── backend_secret.yml
│   ├── stateful_db.yml          # StatefulSet for the database
│   ├── headless_service.yml     # Headless service for stable DB pod DNS
│   ├── storageclass.yml         # EBS-backed StorageClass for persistent volumes
│   └── ingress.yml              # Host-based routing: app.local / grafana.local
│
├── argocd/                  # ArgoCD Application CRDs
├── terraform/               # IaC: VPC, EKS cluster, IAM roles
├── ansible/                 # Playbooks: Jenkins EC2 slave provisioning
└── monitoring/              # kube-prometheus-stack Helm values + Ingress config
```

---

## 🛠️ Infrastructure as Code — Terraform

The `terraform/` directory provisions the **entire AWS foundation** from scratch — no manual console clicks in the critical path.

### Networking — VPC

```
├── Custom VPC
│     ├── Public subnets  (2 AZs) → NAT Gateway egress, Load Balancer nodes
│     ├── Private subnets (2 AZs) → EKS worker nodes (not internet-exposed)
│     ├── Internet Gateway         → public subnet outbound traffic
│     ├── Route tables             → public ↔ IGW, private ↔ NAT
│     └── NAT Gateway              → allows private nodes to pull images / reach AWS APIs
```

### Compute — EKS Cluster

```
├── EKS Control Plane (AWS-managed, multi-AZ, no EC2 to manage)
└── Managed Node Group
      ├── EC2 worker nodes deployed into private subnets
      └── Node IAM role with required managed policies:
            ├── AmazonEKSWorkerNodePolicy
            ├── AmazonEKS_CNI_Policy
            └── AmazonEC2ContainerRegistryReadOnly
```

### IAM Roles & Policies

| Resource | Purpose |
|---|---|
| EKS cluster IAM role | Allows the EKS control plane to make AWS API calls |
| Node group IAM role | Allows worker nodes to join the cluster and pull images |
| `AWSLoadBalancerControllerIAMPolicy` | Scoped policy for the ALB controller to create/manage ALB resources |
| `AmazonEBSCSIDriverPolicy` | Allows the EBS CSI driver to create and attach EBS volumes for PVCs |

> These IAM policy ARNs are referenced by `Jenkinsfile.cluster` when setting up IRSA — **Terraform must run before the cluster bootstrap pipeline.**

### Usage

```bash
cd terraform/
terraform init      # download providers
terraform plan      # preview what will be created
terraform apply     # provision VPC + EKS + IAM (~10-15 min)
```

---

## ⚙️ CI Pipeline — `Jenkinsfile`

Runs on the **dedicated EC2 Jenkins slave** provisioned by Ansible. Each push to `main` triggers:

| Stage | What happens |
|---|---|
| **Pull Code** | `checkout scm` — fetches latest from `main` |
| **Build Images** | Builds `backend-app:$BUILD_NUMBER` and `frontend-app:$BUILD_NUMBER` with Docker |
| **Security Scan (Trivy)** | Scans both images for `HIGH` and `CRITICAL` CVEs before any push |
| **Push to Registry** | Pushes both verified images to the container registry |
| **Update Git for ArgoCD** | Clones repo, patches `image:` tags in `k8s/` manifests with `sed`, commits and pushes to `main` |

> The `Deploy` stage is **intentionally disabled**. Once Jenkins pushes the manifest update, ArgoCD takes over — Jenkins never runs `kubectl apply`.

---

## 🚀 Cluster Bootstrap — `Jenkinsfile.cluster`

A **separate parameterized pipeline** for one-time EKS add-on setup. Accepts `CLUSTER_NAME`, `REGION`, and `VPC_ID` as parameters.

| Stage | What it does |
|---|---|
| **Configure AWS & Kubeconfig** | Authenticates via AWS STS, fetches EKS kubeconfig |
| **Associate OIDC Provider** | Links EKS OIDC endpoint to AWS IAM — required for IRSA |
| **Create IAM SA for ALB** | Deletes any stale SA, recreates it with `eksctl` linked to the ALB IAM policy |
| **Install ALB Controller** | Installs via local Helm `.tgz` (no network dependency in CI); idempotent |
| **Install EBS CSI Driver** | Full lifecycle: check status → delete stale addon/SA → create SA with IRSA → create addon with `--resolve-conflicts OVERWRITE` → wait for `ACTIVE` |
| **Install ArgoCD** | Installs `argo/argo-cd` chart in its own namespace; idempotent |

---

## 🔄 GitOps with ArgoCD

```
Git repo  k8s/*.yml   ◀── Jenkins pushes image tag update
      │
      │  ArgoCD polls every ~3 min
      ▼
ArgoCD detects diff: desired state (Git) ≠ live state (EKS cluster)
      │
      ▼
ArgoCD syncs → rolling update → new pods running on EKS ✓
```

| Benefit | How it's achieved |
|---|---|
| **Auditability** | Every deployment = a Git commit with author, timestamp, and exact diff |
| **Self-healing** | If someone manually edits a cluster resource, ArgoCD reverts it to match Git |
| **Separation of concerns** | Jenkins holds no `kubectl` credentials — it only writes to Git |
| **Rollback** | Reverting a deployment = `git revert` on the image tag commit |

<img width="1332" height="622" alt="image" src="https://github.com/user-attachments/assets/3b7e50ad-9c2a-49ba-b07f-f4831fd64980" />


---

## 📊 Observability Stack

Deployed via `kube-prometheus-stack` Helm chart — release name `tracking-stack`, namespace `devops-project`:

| Component | Workload Type | Role |
|---|---|---|
| **Prometheus** | `StatefulSet` | Scrapes cluster + pod metrics; EBS-backed persistent storage |
| **Grafana** | `Deployment` | Dashboards for node health, pod resources, cluster overview; accessible at `grafana.local` |
| **Alertmanager** | `Deployment` | Alert routing; Gmail OAuth2 credentials injected via `busybox` init container pattern |
| **Node Exporter** | `DaemonSet` | System-level metrics from every node (CPU, memory, disk, network) |
| **kube-state-metrics** | `Deployment` | Kubernetes object metrics (pod states, deployment replicas, etc.) |

**Prometheus scraping of `kube-controller-manager` and `kube-scheduler` is disabled** — these components are AWS-managed in EKS and not reachable; disabling eliminates permanent false-positive `target down` alerts.

---

## 🔐 Security-First Design

| Control | Implementation |
|---|---|
| **No static AWS keys in cluster** | IRSA — pods assume scoped IAM roles via OIDC federation |
| **Container CVE gating** | Trivy scans every image for HIGH/CRITICAL vulnerabilities before any registry push |
| **No hardcoded secrets** | Jenkins Credentials + Kubernetes Secrets; `.gitignore` covers all sensitive files |
| **Namespace isolation** | App, monitoring, and system add-ons in fully separate namespaces |
| **GitOps audit trail** | Every deployment is a traceable Git commit — no ad-hoc `kubectl apply` from pipelines |
| **Least-privilege IAM** | Separate IAM roles scoped precisely to ALB controller and EBS CSI driver |

---

## 🔧 Ansible — Jenkins Slave Provisioning

The `ansible/` playbook provisions a fresh EC2 instance with everything the Jenkins agent needs:

| Tool | Purpose |
|---|---|
| Docker | Building and pushing container images |
| Java (JDK) | Jenkins agent runtime |
| AWS CLI v2 | EKS authentication (`aws eks update-kubeconfig`) |
| kubectl | Used in the cluster bootstrap pipeline |
| eksctl | Creates/deletes IRSA-linked IAM service accounts |
| Helm | Deploys charts during cluster bootstrap |
| Trivy | Container image vulnerability scanning in CI |

---

## 🧱 Key Engineering Decisions

| Decision | Rationale |
|---|---|
| **Separate `Jenkinsfile` + `Jenkinsfile.cluster`** | App CI and cluster bootstrap have different change frequencies and audiences — mixing them makes both harder to reason about and maintain |
| **ArgoCD for CD, not Jenkins** | GitOps gives auditability, drift detection, and self-healing; removes `kubectl` credentials from Jenkins entirely |
| **Always delete/recreate IAM service accounts** | Prevents CloudFormation stack drift between `eksctl` runs — updating an out-of-sync SA is unreliable |
| **Commit Helm `.tgz` files locally** | Eliminates flaky chart downloads in a restricted CI network; guarantees reproducible installs |
| **`#!/bin/bash` shebang + `environment {}` block** | Jenkins defaults to `dash` which silently breaks `${params.X}` interpolation — explicit bash shebang and `environment` block fixes it |
| **`--resolve-conflicts OVERWRITE` on EBS CSI** | Required to resolve `ConfigurationConflict` errors when the addon exists with conflicting settings |
| **ROLE_ARN validation before addon creation** | Fail-fast guard: exits immediately if the IRSA annotation is missing after SA creation, preventing a broken addon install |
| **Headless service for DB StatefulSet** | Provides stable, predictable DNS (`db-0.db-headless`) for each DB pod instead of relying on a ClusterIP that could change |
| **Prometheus control plane scraping disabled** | EKS doesn't expose `kube-controller-manager` / `kube-scheduler` endpoints — disabling prevents permanent false-positive alerts |
| **`busybox` init container for Alertmanager** | Alertmanager has no native env var substitution — the init container writes Gmail OAuth2 credentials from a Secret into the config file before the main container starts |

---

## 🚀 Getting Started

### Prerequisites

```bash
aws --version        # AWS CLI v2
terraform --version  # >= 1.0
ansible --version    # >= 2.12
kubectl version      # compatible with your EKS K8s version
helm version         # >= 3.0
eksctl version       # latest
```

You also need:
- An AWS account with sufficient IAM permissions (for initial setup)
- AWS credentials configured locally: `aws configure`
- A GitHub Personal Access Token (for Jenkins to push manifest updates)

---

### Step 1 — Provision AWS Infrastructure

```bash
cd terraform/
terraform init
terraform plan
terraform apply        # creates VPC + EKS cluster + IAM roles (~10-15 min)
```

Note the output values — you'll need the **VPC ID** for Step 4.

---

### Step 2 — Provision the Jenkins EC2 Slave

Spin up an EC2 instance (Ubuntu 22.04 recommended), update `ansible/inventory`, then run:

```bash
cd ansible/
ansible-playbook -i inventory playbook.yml
```

This installs Docker, Java, AWS CLI v2, kubectl, eksctl, Helm, and Trivy on the slave.

---

### Step 3 — Configure Jenkins

1. Add the EC2 instance as a Jenkins agent with label `jenkins_slave`
2. Create the following credentials in **Manage Jenkins → Credentials**:

| Credential ID | Type | Used for |
|---|---|---|
| `dockerhub` | Username/Password | Pushing images to Docker Hub |
| `aws-credentials` | AWS Access Key | EKS auth in bootstrap pipeline |
| *(GitHub PAT)* | Username/Password | Git push in `Update Git for ArgoCD` stage |

3. Create two pipeline jobs pointing to this repo:
   - **App CI** → `Jenkinsfile`
   - **Cluster Bootstrap** → `Jenkinsfile.cluster`

---

### Step 4 — Bootstrap the EKS Cluster

Run the **Cluster Bootstrap** pipeline with your parameters:

```
CLUSTER_NAME = my-eks-cluster
REGION       = us-east-1
VPC_ID       = <vpc-id from terraform output>
```

This installs the AWS Load Balancer Controller, EBS CSI Driver, and ArgoCD onto the cluster.

---

### Step 5 — Configure ArgoCD

```bash
# Get the initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

# Access the UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open `https://localhost:8080` and create an Application pointing to:

| Field | Value |
|---|---|
| Repository URL | `https://github.com/jannawaelali-creator/Cloud-Native-DevSecOps-Platform` |
| Path | `k8s/` |
| Cluster | in-cluster (your EKS cluster) |
| Namespace | `default` |

---

### Step 6 — Deploy the Monitoring Stack

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install tracking-stack prometheus-community/kube-prometheus-stack \
  -n devops-project --create-namespace \
  -f monitoring/values.yaml
```

Apply the monitoring Ingress:

```bash
kubectl apply -f monitoring/ingress.yml
```

---

### Step 7 — Configure Local DNS

```bash
# Find the Ingress external IP/hostname
kubectl get ingress -A
```

Add to `/etc/hosts` (Linux/Mac) or `C:\Windows\System32\drivers\etc\hosts` (Windows):

```
<EXTERNAL-IP>   app.local
<EXTERNAL-IP>   grafana.local
```

Then visit:
- **`http://app.local`** → Cloud-Native Dashboard (frontend → Node.js backend → DB)
- **`http://grafana.local`** → Grafana monitoring dashboards

---

### Step 8 — Trigger the CI Pipeline

Push a change or manually trigger the **App CI** pipeline. It will:

1. Build `frontend-app` and `backend-app` Docker images
2. Scan both with Trivy for HIGH/CRITICAL CVEs
3. Push images to the registry
4. Patch image tags in `k8s/*.yml` and push to Git
5. ArgoCD detects the commit → rolls out the new version to EKS automatically ✅

---

## 🚧 Roadmap

- [ ] **ECR migration** — replace Docker Hub with AWS ECR for private, IAM-authenticated image storage
- [ ] **Helm-ify the application** — convert `k8s/` manifests into a parameterized Helm chart for multi-environment support
- [ ] **Secrets Manager integration** — inject runtime secrets from AWS Secrets Manager via External Secrets Operator
- [ ] **Multi-environment promotion** — `staging` and `production` ArgoCD `ApplicationSets` with promotion gates
- [ ] **DORA metrics dashboard** — Grafana panel tracking deployment frequency, lead time, and change failure rate

---

## 🧰 Tech Stack Summary

| Category | Tools |
|---|---|
| **Cloud** | AWS (EKS, EC2, VPC, IAM, EBS, ALB) |
| **Container Orchestration** | Kubernetes, Helm |
| **CI** | Jenkins (declarative pipeline, EC2 agent) |
| **CD / GitOps** | ArgoCD |
| **Infrastructure as Code** | Terraform (HCL) |
| **Configuration Management** | Ansible |
| **Security Scanning** | Trivy |
| **Observability** | Prometheus, Grafana, Alertmanager, Node Exporter |
| **Containerization** | Docker |
| **Application** | Node.js (backend), HTML/JS (frontend) |
| **Languages** | HCL · JavaScript · HTML · Dockerfile · Bash |

---

<div align="center">

*Built by [Janna Waelali](https://github.com/jannawaelali-creator) · DevOps Engineer · AWS Certified · ITI Cloud Platform Development Diploma*

</div>
