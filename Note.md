## Initialize  a foundry project

` ~forge init`

## Installing chainlink-brownie
`~forge install smartcontractkit/chainlink-brownie-contracts --no-commit`

## Test In Forge

`Test functions must have either external or public visibility. Functions declared as `internal` or `private` won’t be picked up by Forge, even if they are prefixed with test.`

## Testing with specific funciton
`~forge test --mt testPriceFeedVersionIsAccurate -vvv`
Here , testPriceFeedVersionIsAccurate()

## Forked Test
`forge test --mt testPriceFeedVersionIsAccurate --fork-url $URL`

## Gas Snapshot
`~forge snapshot --mt testName`

## Storage layout
`~forge inspect fundMe  storageLayout`
