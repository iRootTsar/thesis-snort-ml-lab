# Thesis SnortML Lab
## Project tree
thesis-snort-ml-lab/ # your master thesis repo (public or private)
├── repos/
│ ├── snort3/ # subtree of iRootTsar/snort3 (or upstream)
│ ├── libdaq/ # subtree of iRootTsar/libdaq
│ └── libml/ # subtree of iRootTsar/libml
├── scripts/
│ ├── bootstrap.sh # clone + subtree setup
│ ├── build_all.sh # build order: libdaq → libml → snort3
│ ├── test_smoke.sh # quick validation
│ └── sync_upstream.sh # pull latest from official + your forks
├── docs/
│ ├── ARCHITECTURE.md
│ ├── BUILD.md
│ ├── UPSTREAM_SYNC.md
│ ├── EXPERIMENTS.md
│ └── EXTENSION_ROADMAP.md
├── patches/ # optional .patch files for quick experiments
├── experiments/ # PCAP analysis scripts, model training notebooks
├── pcaps/ # .gitignore
├── models/ # .gitignore or LFS for trained .model files
├── build/ # .gitignore (cmake out-of-source)
├── logs/ # .gitignore
├── README.md
├── Makefile # top-level targets
├── .gitignore
└── .gitmodules # only if you switch to submodules later
