# User Guide

[![Project Version][version-image]][version-url]

## Introduction

This guide is intended to be a user-friendly introduction to [Wave token](./wave/README.md). It provides a walkthrough of how to get started with the token.

## Installation and Tooling

##### This is designed to be tested and deployed with Foundry. Install Python 3.11, Homebrew, and then install [foundry using Thrackle's `foundryup`](https://github.com/thrackle-io/foundry). This applies numbered versions to upstream Foundry releases.

```
pip3 install -r requirements.txt
brew install jq
```

```
curl -sSL https://raw.githubusercontent.com/thrackle-io/foundry/refs/heads/master/foundryup/foundryup | bash
foundryup --version $(awk '$1~/^[^#]/' foundry.lock)
```

_Note: `awk` in the above command is used to ignore comments in `foundry.lock`_


Now that you have the dependencies installed, you are ready to build the project. Do:

`forge build` in the project directory to install the submodules and create the artifacts.

And you are done!

## Wave Token Information
[Wave Token](./wave/WAVE.md)    
[Deploying Wave Token](./wave/README.md)        
[Testing Methodologies](./wave/ERC20_UPGRADEABLE_TESTING_METHODOLOGY.md)    
[Fork Testing Information](./wave/ERC20_UPGRADEABLE_TESTING_METHODOLOGY.md#fork-tests)  
[Invariant Tests](./invariants/ERC20_UPGRADEABLE_INVARIANTS.md)


<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/wave
