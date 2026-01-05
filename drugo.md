# GitHub Organization za šolo - Setup

Odlično vprašanje! GitHub Organization je IDEALEN za šolski projekt.

---

## **1. GitHub Organization - Zakaj in Kako**

### **Zakaj Organization (ne personal account)?**

**Prednosti:**

```
✅ Professional (github.com/os-toneta-cufarja namesto github.com/vasUsername)
✅ Team access (več adminov lahko upravlja)
✅ Repository ownership (repo belongs to šola, ne vam osebno)
✅ Better permissions (RBAC - role-based access control)
✅ Audit log (kdo je kaj spremenil)
✅ Continuity (če zapustite šolo, repo ostane)
```

**Use case:**
```
Scenarij: Čez 2 leti greste iz šole
→ Personal account: Repo gre z vami (šola izgubi dostop)
→ Organization: Repo ostane v šoli (naslednik prevzame)
```

---

### **Cena: BREZPLAČNO za javne repoje**

**GitHub pricing za Organizations:**

```
FREE plan:
✅ Unlimited public repositories
✅ Unlimited collaborators
✅ GitHub Actions (2,000 minutes/month)
✅ GitHub Packages (500MB storage)
✅ Community support

Plačljivo (Team plan - $4/user/month):
- Private repositories z naprednimi funkcijami
- Advanced security features
- Protected branches
- Code owners

Za vas: FREE plan je POPOLNOMA DOVOLJ!
```

---

## **2. Kako narediti GitHub Organization - Step by Step**

### **Korak 1: Create Organization**

```
1. Pojdite na: https://github.com/

2. Kliknite na ikono profila (zgoraj desno) → Your organizations

3. Kliknite: "New organization"

4. Izberite plan: "Create a free organization" (0€)

5. Izpolnite:
   Organization account name: os-toneta-cufarja
   (ali: oscufar, ostcufar, os-tc-jesenice)
   
   Contact email: it@oscufar.si (ali vaš šolski e-mail)
   
   This organization belongs to: My school or educational institution
   
6. Kliknite: "Next"

7. Add organization members (optional zdaj, lahko later):
   - Dodajte računalničarko (če ima GitHub)
   - Dodajte ravnatelja (če vodi)
   - Lahko skip za zdaj

8. Kliknite: "Complete setup"
```

**✅ Done! Organization created.**

---

### **Korak 2: Verify Organization (za benefits)**

**GitHub Education benefits (optional ampak priporočeno):**

```
Educational institutions lahko dobijo:
- GitHub Team features (brezplačno)
- GitHub Copilot za učence/učitelje
- Advanced security

Apply:
1. https://education.github.com/schools
2. Verify institution: OŠ Toneta Čufarja
3. Upload dokument (potrdilo šole, letter)
4. Wait approval (few days)

NE nujno za začetek - lahko later!
```

---

### **Korak 3: Create Repository v Organization**

```
1. Pojdite na: https://github.com/os-toneta-cufarja

2. Repositories tab → "New repository"

3. Izpolnite:
   Repository name: intune-device-management
   
   Description: Infrastructure as Code for school device management (Microsoft Intune + Terraform)
   
   Visibility: 
   - Public ✅ (priporočeno, če YAML ni sensitive)
   - Private (če želite zasebno)
   
   Initialize repository:
   ☑ Add a README file
   ☑ Add .gitignore → Terraform template
   ☐ Choose a license (MIT ali odločite later)

4. Create repository
```

---

### **Korak 4: Clone & Push vaš existing work**

**Če ste že naredili local repo:**

```bash
# Add organization remote
cd ~/terraform-intune

# Remove old remote (if any)
git remote remove origin

# Add organization remote
git remote add origin git@github.com:os-toneta-cufarja/intune-device-management.git

# Push
git branch -M main
git push -u origin main
```

**Če začenjate fresh:**

```bash
# Clone organization repo
git clone git@github.com:os-toneta-cufarja/intune-device-management.git
cd intune-device-management

# Add your files
# ... work ...

git add .
git commit -m "Initial commit"
git push origin main
```

---

## **3. Organization Settings - Best Practices**

### **A) Member Permissions**

```
Organization Settings → Member privileges

Recommended:
- Base permissions: Read
  (Members lahko vidijo vse, ampak ne morejo push direktno)

- Repository creation: Admins only
  (Samo admins lahko create new repos)

- Repository forking: Enabled
  (Members lahko fork za testing)
```

---

### **B) Add Team Members**

```
Organization → People → Invite member

Roles:
- Owner: Vi + ravnatelj (full admin access)
- Member: Računalničarka, nasledniki (lahko commit, ne delete repos)

Teams (optional):
- Create team: "IT Administrators"
- Add members to team
- Grant team access to specific repos
```

---

### **C) Repository Settings**

```
Repository → Settings

Branch protection (important!):
- Branches → Add rule
- Branch name pattern: main
- Protection rules:
  ☑ Require a pull request before merging
  ☑ Require approvals (1 approval)
  ☐ Require status checks (optional, za CI/CD)
  ☑ Include administrators (tudi vi ne morete direktno push)

→ Forces code review process (professional!)
```

**Workflow s protected main:**

```
Dev workflow:
1. Create branch: feature/add-new-device
2. Make changes
3. Push branch
4. Create Pull Request
5. Review code (lahko vi sami approve)
6. Merge → main

Professional git workflow! ✅
```

---

## **4. README za Organization Profile**

**Create organization README (public face):**

```
Organization → Overview → Edit README

# OŠ Toneta Čufarja - IT Infrastructure

> Infrastructure as Code repositories za šolsko IT infrastrukturo

## 📦 Repositories

- **[intune-device-management](intune-device-management/)** - Microsoft Intune + Terraform za upravljanje naprav
- *More repos coming soon...*

## 🤝 Contributing

Internal team only. Za vprašanja kontaktirajte IT administratorja.

## 📧 Contact

- IT Support: it@oscufar.si
- Website: https://www.os-toneta-cufarja.si/
```

---

## **5. Public vs Private Repository - Odločitev**

### **YAML data - je sensitive?**

**NI sensitive (public OK):**

```yaml
devices:
  pc01:
    serial_number: "5CD0123ABC"  # Written on device label
    hostname: "PC-UC-01"          # Visible to everyone
    model: "HP EliteDesk 800 G5"  # Public info
```

**JE sensitive (private MUST):**

```yaml
devices:
  pc01:
    admin_password: "Secret123!"  # ❌ SENSITIVE!
    wifi_password: "SchoolWiFi2024" # ❌ SENSITIVE!
```

---

### **Moje priporočilo: PUBLIC repo**

**Razlogi:**

```
✅ Transparency (open-source approach)
✅ Portfolio showcase (vaš CV)
✅ Community help (če imate issue, lahko ask stackoverflow)
✅ Easier collaboration (ne potrebujete invite za view)
✅ GitHub pages (lahko publish docs)
✅ GitHub Stars (recognition)

AMPAK:
- terraform.tfvars → .gitignore (credentials NOT in Git)
- Sensitive data → Git-crypt ALI separate private repo
```

**Struktura:**

```
Public repo:
├── Infrastructure code (Terraform .tf files)
├── Device inventory (YAML files)
├── Scripts (Python/PowerShell)
└── Documentation (README, guides)

Private repo (separate) ALI Git-crypt:
├── terraform.tfvars (Azure credentials)
├── secrets/ (passwords, keys)
```

---

**Alternative - Hybrid:**

```
Main repo: Public (infrastructure code, non-sensitive YAML)
Secrets repo: Private (credentials only)

Terraform reads both:
terraform apply -var-file=../secrets/terraform.tfvars
```

---

## **6. .gitignore - Production Ready**

```gitignore
# .gitignore

# Terraform
.terraform/
.terraform.lock.hcl
*.tfstate
*.tfstate.backup
*.tfstate.*.backup
*.tfplan
crash.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Credentials (CRITICAL!)
terraform.tfvars
*.auto.tfvars
secrets/
*.key
*.pem
*.p12
*.pfx

# Azure
.azure/
azure.json

# Python
__pycache__/
*.py[cod]
*$py.class
.venv/
venv/
ENV/
env/
*.egg-info/
.pytest_cache/

# OS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
*.swp
*.swo
*~

# IDE
.vscode/
.idea/
*.iml
*.sublime-project
*.sublime-workspace

# Logs
*.log
logs/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Temporary
tmp/
temp/
*.tmp
.cache/

# Collected data (optional - exclude if sensitive)
usb-collected-data/
data/discovered/*.yaml  # Auto-generated, can regenerate

# Backup files
*.bak
*.backup
*.old

# macOS
.AppleDouble
.LSOverride

# Windows
desktop.ini
$RECYCLE.BIN/
```

---

## **7. Initial Repository Setup - Complete**

### **Full setup za DANES:**

```bash
# 1. Create Organization (web)
# Done via GitHub web interface ✅

# 2. Clone organization repo
git clone git@github.com:os-toneta-cufarja/intune-device-management.git
cd intune-device-management

# 3. Setup structure
mkdir -p data/racunalnica scripts docs modules/{devices,apps,policies}

# 4. Create files
cat > .gitignore << 'EOF'
# (paste .gitignore from above)
EOF

cat > README.md << 'EOF'
# OŠ Toneta Čufarja - Device Management Infrastructure

Infrastructure as Code for school device management using Microsoft Intune + Terraform.

## Quick Start

See [docs/getting-started.md](docs/getting-started.md)

## Documentation

- [Architecture](docs/architecture.md)
- [Device Inventory](docs/device-inventory.md)
- [Deployment Guide](docs/deployment-guide.md)

## Contact

IT Administrator: it@oscufar.si
EOF

# 5. Commit
git add .
git commit -m "Initial repository structure"
git push origin main

# 6. Protect main branch (via web)
# Settings → Branches → Add rule → main
# ☑ Require pull request before merging
```

---

## **8. Quick Reference - Git Workflow**

### **Daily workflow:**

```bash
# 1. Pull latest
git pull origin main

# 2. Create feature branch
git checkout -b feature/add-pc29

# 3. Make changes
vim data/racunalnica/devices.yaml
# ... add PC-29

# 4. Commit
git add data/racunalnica/devices.yaml
git commit -m "Add PC-29 to inventory"

# 5. Push branch
git push origin feature/add-pc29

# 6. Create Pull Request (web)
# GitHub → Pull requests → New pull request
# base: main ← compare: feature/add-pc29
# Create pull request

# 7. Review & Merge (web)
# Review changes → Approve → Merge pull request

# 8. Delete branch (cleanup)
git branch -d feature/add-pc29
git push origin --delete feature/add-pc29
```

---

## **9. Organization Name Ideas**

**Če "os-toneta-cufarja" je predolgo:**

```
Kratke alternative:
- ostc-jesenice
- os-tc-jes
- oscufar
- school-tc (če želite neutral)
- tc-school-it

Check availability:
https://github.com/[name]
```

**Moje priporočilo:** `os-toneta-cufarja` (full name, jasno, profesionalno)

---

## **10. Benefits of Public Repo**

### **Career/Portfolio:**

**Na LinkedIn/CV:**

```
GitHub: https://github.com/os-toneta-cufarja/intune-device-management

- Implemented Infrastructure as Code for 40+ educational devices
- Microsoft Intune + Terraform
- Zero-touch deployment (Autopilot)
- Full device lifecycle management

→ Recruiters lahko VIDIJO vaše delo (not just claims)
→ Code samples showcase skills
→ Contribution graph shows activity
```

---

### **Community:**

```
Public repo lahko:
- Stack Overflow vprašanja (link vaš kod)
- Reddit r/terraform help (link repo)
- GitHub Issues (če bugs)
- GitHub Discussions (za community feedback)

Private repo:
- Sam developer, sam troubleshooter
- No external help
```

---

## **TL;DR - Action Plan**

### **DANES (15 minut):**

```
☐ 1. Create GitHub Organization
   https://github.com/organizations/plan
   → Free plan
   → Name: os-toneta-cufarja

☐ 2. Create Repository
   → intune-device-management
   → Public (če YAML ni sensitive)
   → Initialize s README

☐ 3. Clone locally
   git clone git@github.com:os-toneta-cufarja/intune-device-management.git

☐ 4. Setup structure
   mkdir data/ scripts/ docs/ modules/
   
☐ 5. Add .gitignore (from above)

☐ 6. Initial commit
   git add .
   git commit -m "Initial structure"
   git push origin main

✅ Done! Repository ready za danes delo.
```

---

### **JUTRI (nice-to-have):**

```
☐ Branch protection (main)
☐ Add team members (računalničarka)
☐ GitHub Education verification (optional)
☐ Organization README
```

---

**Start z Organization creation ZDAJ (5 min) → Ready za danes data collection!** 🚀

**Organization name priporočam: `os-toneta-cufarja` (professional, clear)** ✅