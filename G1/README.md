## Package Upgrades

In this section we have the published package `package_upgrade` which involves
the following modules.

##### blacksmith

Module `blacksmith` involves the `Blacksmith` capability object which can
create `Sword`s and `Shield`s.

##### hero

A `Hero` is a freely mintable NFT which can equip `Sword` and `Shield` under
the dynamic field keys `"sword"` and `"shield"`.

##### admin

Includes the `AdminCap` used to create `Blacksmith` capability objects.

##### package_version

Uses the [Versioned Shared Objects](https://docs.sui.io/concepts/sui-move-concepts/packages/upgrade#versioned-shared-objects)
pattern to enable deprecation of functions defined in previous package version.

### Task

We want to upgrade our package with the following changes:

1. We want to bump our `VERSION` constant and `Version` shared-object `version`
field to 2.
2. We want to have `Hero` NFTs be purchasable with a price of 5 SUI in order
instead of having it minted freely.
3. Instead of using simple `String`s as dynamic field keys, we want to be more
type-safe and used new structs for each item type that the hero can equip.
4. We want to add the `power` property to our `Hero` NFT. The power should be
increased every time the hero equips a sword or a shield with the attack or
defence stat respectively.

### Useful Links

- https://docs.sui.io/concepts/sui-move-concepts/packages/upgrade

### TODO

- Diagram depicting versioned shared object logic
- Where to use &version as input?
