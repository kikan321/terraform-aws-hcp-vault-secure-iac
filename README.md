# AWS Secure Infrastructure Deployment with Terraform & HCP Vault

This project demonstrates a professional, production-ready workflow for deploying secure cloud infrastructure on AWS using **Terraform** and dynamic credentials managed by **HashiCorp Cloud Platform (HCP) Vault**.

The primary objective is to implement a **Zero Trust** architecture by completely eliminating long-lived static AWS credentials (Access/Secret Keys) from local environments or CI/CD pipelines, replacing them with short-lived, **ephemeral credentials**.

---

## 🛠️ Infrastructure Architecture

The project deploys a basic yet highly secure web architecture in AWS:
*   **Modular VPC:** A custom network containing a public subnet and a route table attached to an Internet Gateway.
*   **EC2 Web Server:** An Ubuntu 22.04 instance automatically provisioned with an Nginx web server via `user_data`.
*   **Network Security:** A tightly coupled Security Group restricting inbound traffic exclusively to HTTP (Port 80).

```text
[ Terraform CLI ] 
       │
       │ 1. Authenticate via RoleID / SecretID (AppRole)
       ▼
  [ HCP Vault ] ─── 2. Evaluate local policy ───► [ Validate path: aws/creds/* ]
       │                                                      │
       │ 3. Request temporary keys from AWS                   │ (Authorized)
       ▼                                                      ▼
  [ AWS Cloud ] ─── 4. Create dynamic user (TTL: 30m) ────────┘
       │
       ▼
[ Deploy Resources (VPC, EC2, Nginx) ]
```

---

## 📦 Project Structure & Design Patterns

The codebase adheres to the **DRY (Don't Repeat Yourself)** principle by decoupling configuration from implementation:

```text
├── legacy_code/           # Monolithic, hardcoded baseline before refactoring
│   └── main.tf
├── modules/               # Pure, parameterized, and reusable building blocks
│   ├── vpc/               # Networking layer (VPC, Subnets, Gateways)
│   │   ├── main.tf, variables.tf, outputs.tf
│   └── ec2/               # Compute layer (EC2, Security Groups)
│       ├── main.tf, variables.tf, outputs.tf
└── environments/          # Environment-specific orchestration
    └── dev/
        ├── main.tf        # Module instantiating and dependency chaining
        ├── providers.tf   # HCP Vault and AWS connectivity logic
        └── variables.tf   # Sensitive variable declarations
```

---

## 🔄 Refactoring & Evolution (From Legacy to Clean Code)

To simulate a real-world enterprise migration, this repository contains a baseline in the `legacy_code/` directory.

### The Legacy Baseline (`legacy_code/main.tf`)
The original project was a **monolithic "spaghetti code" file** where networking and compute resources were tightly coupled. It suffered from critical anti-patterns:
*   **Hardcoded Values:** IPs, CIDR blocks, and AMI IDs were written in plain text, making it impossible to reuse the code for other environments (e.g., Staging or Production).
*   **Security Vulnerabilities:** AWS credentials had to be injected manually or stored in unencrypted `.tfvars` files on disk, posing an accidental leak risk.

### Architectural Benefits of the Refactored Code
1.  **De-coupling & Separation of Concerns:** Split infrastructure into isolated modules (`vpc` and `ec2`). The environment config (`environments/dev/`) now orchestrates them seamlessly.
2.  **Dynamic Dependency Chaining:** Instead of hardcoding resource IDs, the EC2 module dynamically consumes the network configuration through Terraform `outputs` (`module.vpc_development.vpc_id`).
3.  **Dynamic Data Sources:** Replaced the hardcoded, region-specific Ubuntu AMI string with an `aws_ami` data block that automatically queries the latest official canonical image.

---

## 🔒 Advanced Security & Cloud Secret Management

This architecture implements a strict **Zero Trust** security model by leveraging **HashiCorp Cloud Platform (HCP) Vault** in the cloud to completely decouple sensitive access keys from the deployment cycle.

### 1. Cloud-Based Machine Authentication (AppRole)
Instead of relying on human admin tokens with short-lived expiration windows (such as the default 6-hour root token), this project configures an **AppRole Authentication Method** in HCP Vault. 
*   Terraform acts as a secure "machine identity" using a static `RoleID` and `SecretID`.
*   These credentials are injected into the Linux terminal memory at runtime using native `TF_VAR_` environment variables (`TF_VAR_vault_role_id` and `TF_VAR_vault_secret_id`).
*   No hardcoded files, tokens, or plaintext secrets ever touch the disk or the Git repository.

### 2. Ephemeral Dynamic Access via AWS Secrets Engine
The Terraform AWS provider is initialized with zero static access keys. The workflow operates as follows:
*   **The Broker:** Before performing a plan, the configuration queries the `aws/creds/terraform-dev-role` path managed by Vault's **AWS Secrets Engine**.
*   **On-the-Fly Creation:** Vault uses its root-level integration to programmatically call AWS and generate a brand-new, isolated IAM user specifically for this execution window.
*   **Automated Lifecycle (TTL):** The temporary user is assigned a strict **30-minute Time to Live (TTL)** and a tightly scoped policy (`iam:GetUser`, `ec2:*`). 
*   **Self-Destruction:** Once the `terraform plan` or lifecycle window closes, AWS naturally destroys the identity, mitigating the risk of credential leaks or lateral movements.

---

## 🚀 Technical Concepts Demonstrated

*   **Principle DRY (Don't Repeat Yourself):** Parameterized modules that allow replication of infrastructure across `Staging` or `Production` environments by simply changing variables.
*   **Implicit Dependencies:** Dynamic resource chaining by passing networking module `outputs` as input `variables` into the compute module.
*   **Secure Variable Injection:** Using the native Terraform `TF_VAR_` prefix to prevent writing physical `.tfvars` files containing secrets on the local hard drive.
*   **Clean Code:** Strict separation of concerns between provider configurations (`providers.tf`) and resource declarations (`main.tf`).
