# User Guide

[![Project Version][version-image]][version-url]

## Introduction

This guide is intended to be a user-friendly introduction to the rules protocol. It will provide a walkthrough of how to get started with the protocol, as well as provide a reference for the available rules and how to create custom rules.

## Installation and Tooling
##### This is designed to be tested and deployed with Foundry. All that should be required is to install Python 3.11, Homebrew, and then install [foundry](https://book.getfoundry.sh/getting-started/installation), pull the code, and then run in the root of the project's directory:

`foundryup --commit $(awk '$1~/^[^#]/' foundry.lock)` 

_Note: `awk` in the above command is used to ignore comments in `foundry.lock`_

`pip3 install -r requirements.txt`

` brew install jq`

Now that you have the dependencies installed, you are ready to build the project. Do:

`forge build` in the project directory to install the submodules and create the artifacts.

And you are done!


<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/pacman