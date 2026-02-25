# Thesis SnortML Lab

This repository is a unified development workspace for extending **Snort 3 + SnortML** (via LibML) to support machine-learning-based detection on non-HTTP protocols (starting with DNS).

The main goal is to have **one single git repository** containing:
- the three core components (`snort3`, `libdaq`, `libml`) as subtrees from your personal forks,
- all development scripts,
- documentation,
- experiment folders,
- and a clean, reproducible build & test environment.

### Why this structure?

- **Single repo** → everything in one place → easy for Codex/AI assistants, search, navigation, and backups  
- **git subtree** instead of submodule → full history in one repo, no detached HEAD pain, easy to push changes back to your forks  
- **master branch** → your personal forks (`iRootTsar/snort3`, `iRootTsar/libdaq`, `iRootTsar/libml`) use `master` as default branch  
- **No unit tests during build** → avoids CppUTest dependency (optional later)  
- **Scripts** → automate repetitive tasks (build, sync, commit, test)  

### Repository Layout

```
thesis-snort-ml-lab/
├── repos/                           # git subtrees of the three core projects (master branch)
│   ├── snort3/                      # main Snort 3 engine + inspectors + SnortML
│   ├── libdaq/                      # Data Acquisition library (packet I/O abstraction)
│   └── libml/                       # TensorFlow Lite inference wrapper used by SnortML
├── scripts/                         # automation helpers
│   ├── bootstrap.sh                 # placeholder / future setup helper
│   ├── build_all.sh                 # builds libdaq → libml → snort3 in correct order
│   ├── test_smoke.sh                # quick validation: snort -V + DAQ list
│   ├── sync_upstream.sh             # pulls latest master from your three forks (rerun anytime)
│   └── commit_feature.sh            # safe commit helper for feature branches
├── docs/                            # theory & planning documents
│   ├── ARCHITECTURE.md
│   ├── BUILD.md
│   ├── UPSTREAM_SYNC.md
│   ├── EXPERIMENTS.md
│   └── EXTENSION_ROADMAP.md
├── patches/                         # optional .patch files for quick experiments
├── experiments/                     # notebooks, PCAP analysis scripts, training code
├── pcaps/                           # captured or downloaded PCAP files (gitignore)
├── models/                          # trained .model / .tflite files (gitignore or LFS)
├── build/                           # cmake build artifacts (gitignore)
├── logs/                            # runtime logs (gitignore)
├── README.md                        # this file
├── Makefile                         # optional make shortcuts
├── .gitignore
└── .gitmodules                      # only appears if you switch to submodules later
```

---

## How to Reproduce This Workspace From Scratch

### 1. Pre-install system dependencies (Ubuntu 24.04 / Kali rolling)

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential cmake ninja-build git curl wget \
    libpcap-dev libpcre3-dev libpcre2-dev libdumbnet-dev zlib1g-dev liblzma-dev \
    libssl-dev pkg-config libhwloc-dev luajit libluajit-5.1-dev \
    flex bison autoconf libtool libunwind-dev libmnl-dev \
    libnfnetlink-dev libnetfilter-queue-dev libgoogle-perftools-dev \
    python3 python3-pip python3-venv python3-scapy \
    tcpdump tcpreplay hping3 vim nano htop iotop net-tools ethtool
sudo snap install code --classic
```

### 2. Create Python virtual environment (for ML training / notebooks)

```bash
python3 -m venv ~/snortml-venv
source ~/snortml-venv/bin/activate
pip install --upgrade pip numpy pandas scikit-learn tensorflow jupyter notebook matplotlib scapy
```

---

## SSH Key Setup (Ubuntu → GitHub)

If you are using SSH-based GitHub access (`git@github.com:...`), you must register your SSH key once.

### 1. Check for existing key

```bash
ls -al ~/.ssh
```

If you see `id_ed25519` and `id_ed25519.pub`, you can reuse them.

### 2. Generate a new SSH key (recommended: ed25519)

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Press Enter to accept the default path.  
Optionally set a passphrase.

### 3. Start SSH agent and add key

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### 4. Copy public key

```bash
cat ~/.ssh/id_ed25519.pub
```

Copy the entire output.

### 5. Add key to GitHub

- Go to: https://github.com/settings/keys  
- Click **New SSH key**  
- Paste your public key  
- Save  

### 6. Test connection

```bash
ssh -T git@github.com
```

You should see a message confirming authentication.

---

### 3. Clone or initialize the repo (if starting fresh)

```bash
git clone git@github.com:iRootTsar/thesis-snort-ml-lab.git
cd thesis-snort-ml-lab
# or if creating new:
# mkdir thesis-snort-ml-lab && cd thesis-snort-ml-lab && git init -b main
```

### 4. Add initial commit if repo is empty

```bash
echo "# Thesis SnortML Lab" > README.md
git add README.md
git commit -m "Initial commit"
```

### 5. Add remotes (if not already present)

```bash
git remote add origin          git@github.com:iRootTsar/thesis-snort-ml-lab.git
git remote add fork-snort3     git@github.com:iRootTsar/snort3.git
git remote add fork-libdaq     git@github.com:iRootTsar/libdaq.git
git remote add fork-libml      git@github.com:iRootTsar/libml.git
git remote add upstream-snort3 git@github.com:snort3/snort3.git
git remote add upstream-libdaq git@github.com:snort3/libdaq.git
git remote add upstream-libml  git@github.com:snort3/libml.git
```

### 6. Add subtrees (only needed once)

```bash
git subtree add --prefix=repos/snort3  --squash fork-snort3 master
git subtree add --prefix=repos/libdaq  --squash fork-libdaq master
git subtree add --prefix=repos/libml   --squash fork-libml  master
```

### 7. Build everything

```bash
./scripts/build_all.sh
```

### 8. Quick test

```bash
./scripts/test_smoke.sh
```

---

## Daily Workflow Summary

- **Update forks** (get latest from your forks' master branches)  

  ```bash
  ./scripts/sync_upstream.sh
  ./scripts/build_all.sh   # only if code changed
  ```

- **Start new feature**  

  ```bash
  git checkout -b feature/my-cool-idea
  ```

- **Commit changes safely**  

  ```bash
  ./scripts/commit_feature.sh "short description of what you did"
  ```

- **Push feature branch to your fork** (example for snort3 changes)  

  ```bash
  git subtree push --prefix=repos/snort3 fork-snort3 feature/my-cool-idea
  ```

---

## System Dependencies Summary (requirements-system.txt style)

Copy this block into a file called `INSTALL_DEPENDENCIES.md` or `requirements-system.txt`:

```text
# Core build tools
build-essential cmake ninja-build git curl wget

# Snort 3 required development libraries
libpcap-dev libpcre3-dev libpcre2-dev libdumbnet-dev zlib1g-dev liblzma-dev
libssl-dev pkg-config libhwloc-dev luajit libluajit-5.1-dev
flex bison autoconf libtool libunwind-dev libmnl-dev
libnfnetlink-dev libnetfilter-queue-dev libgoogle-perftools-dev

# Python + ML environment
python3 python3-pip python3-venv python3-scapy

# Traffic generation & analysis
tcpdump tcpreplay hping3

# Editors & monitoring
vim nano htop iotop net-tools ethtool

# IDE
code (via snap install code --classic)

# Optional: for later CppUTest unit tests
# git clone https://github.com/cpputest/cpputest.git && cd cpputest && mkdir build && cd build && cmake .. && make && sudo make install
```
