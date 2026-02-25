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
``
