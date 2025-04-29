# Transaction, Object Limits and Table rebate

The exercise starts with an `Armory` module that uses a `vector` to store `Sword` objects.

## Tasks

### Task 1: Batch Minting
The first test attempts to mint 6000 swords in a single transaction, which will fail due to the maximum number of new objects per transaction limit.

Modify the minting process to work in batches of 2048 swords per transaction.

### Task 2: Replace Vector with Table
After respecting max-new-objects limit, the test will still fail because storing 6000 swords in a vector will hit the maximum object size limit.

Replace the `vector` with a `Table` in the `Armory` struct.
In Sui, `Table` doesn't affect the "parent" object size as it stores its entries as new objects (dynamic-fields) linked to the parent.

### Task 3: Implement Proper Destruction with Storage Rebates
Now that we are using a `Table`, when we use `swords.drop()` we are actually only destroying the table fields, but not its actual entries.
This means that we are not getting a lot of storage-rebate from the storage space these entries take up.

To properly handle storage rebates with a `Table`, you need to:
   - Empty the table first by removing all entries
   - Do this in batches to respect the maximum dynamic field iteration limit
   - Only then destroy the table and the armory object

