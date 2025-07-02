# User Guide

[![Project Version][version-image]][version-url]

## Introduction

This guide is intended to be a user-friendly introduction to [Forte token](./token/README.md). It provides a walkthrough of how to get started with the token.

## Installation and Tooling

##### This is designed to be tested and deployed with Foundry. Install Python 3.11, Homebrew, and then install [foundry](https://github.com/foundry-rs/foundry) v1.2.1.

```
pip3 install -r requirements.txt
brew install jq
```

```
curl -L https://foundry.paradigm.xyz | bash
foundryup --install v1.2.1
```



Now that you have the dependencies installed, you are ready to build the project. Do:

`forge build` in the project directory to install the submodules and create the artifacts.

And you are done!

## Token Information
[Token](./token/token.md)    
[Deploying the Token](./token/README.md)        
[Testing Methodologies](./token/ERC20_UPGRADEABLE_TESTING_METHODOLOGY.md)    
[Fork Testing Information](./token/ERC20_UPGRADEABLE_TESTING_METHODOLOGY.md#fork-tests)  
[Invariant Tests](./Invariants/ERC20_UPGRADEABLE_INVARIANTS.md)


<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/Forte-Service-Company-Ltd/forte-token
