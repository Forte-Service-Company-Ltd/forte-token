# ERC20 Upgradeable Invariants
[![Project Version][version-image]][version-url]

## [ERC20 Upgradeable Invariants](../../../test/token/invariants/ERC20UBasic.t.i.sol)
- User balance must not exceed total supply
- Sum of users balance must not exceed total supply
- Address zero should have zero balance
- Transfers to zero address should not be allowed.
- transferFroms to zero address should not be allowed.
- Self transfers should not break accounting.
- Self transferFroms should not break accounting.
- Transfers for more than available balance should not be allowed
- TransferFroms for more than available balance should not be allowed
- Zero amount transfers should not break accounting
- Zero amount transferFroms should not break accounting
- Transfers should update accounting correctly
- TransferFroms should update accounting correctly
- Approve should set correct allowances
- Allowances should be updated correctly when approve is called twice.
- TransferFrom should decrease allowance

## [Mintable and Burnable ERC20 Invariants](../../../test/token/invariants/ERC20UMintBurn.t.i.sol)
- Burn should update user balance and total supply
- Burn should update user balance and total supply when burnFrom is called twice
- burnFrom should update allowance
- User balance and total supply should be updated correctly after minting.


<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/wave