# Project: <NAME>

## Overview

<!-- One or two sentences describing what this project builds and for what target. -->

## Yocto release

- Release: <!-- e.g. Scarthgap (5.0), Kirkstone (4.0) -->
- Poky/OE-core version: <!-- e.g. commit hash or tag if pinned -->

## Repository structure

```
<project-root>/
├── <path-to-poky>/          # OE-core / poky
├── <meta-layer-1>/
├── <meta-layer-2>/
└── <build-dir>/             # build directory (gitignored or not?)
```

<!-- Describe how layers are organized: flat, subdirectories, fetched via repo manifest, submodules, etc. -->

## Environment setup

```bash
# How to initialize the build environment:
source <path>/oe-init-build-env <build-dir>
```

<!-- Note any wrapper scripts or custom setup steps. -->

## Key configuration

- Machine(s): <!-- e.g. raspberrypi4-64, imx8mmevk -->
- Distro: <!-- e.g. poky, mydistro -->
- `local.conf` location: `<build-dir>/conf/local.conf`
- `bblayers.conf` location: `<build-dir>/conf/bblayers.conf`
- Is `local.conf` committed? <!-- yes / no / template only -->

## Common build commands

```bash
# Build main image:
bitbake <image-name>

# Build a specific recipe:
bitbake <recipe>

# Clean a recipe:
bitbake <recipe> -c cleansstate

# Open a devshell:
bitbake <recipe> -c devshell
```

## Layer notes

<!-- Describe any non-standard or locally-modified layers, known issues, patches, etc. -->

## Git remotes

- Origin: <!-- git remote URL -->
- Other remotes: <!-- if any -->

## Things to never do in this project

<!-- e.g. "do not modify meta-vendor/ — it is a vendor-supplied submodule" -->

## Claude Code trace mode

<!-- VISIBLE or STEALTH — set during onboarding, but always re-confirmed at session start -->
