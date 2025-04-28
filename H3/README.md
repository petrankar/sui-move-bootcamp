## Admin Authorization and Referent IDs

This exercise demonstrates different approaches to authorization and referent IDs in Move smart contracts. You'll implement three different authorization mechanisms and fix referent ID issues in a shared object system.

### Tasks Overview

#### 1. Access Control List (ACL) Authorization
In `admin_action/move/sources/acl.move`:
- Implement authorization in the `mint` function using the `AccessControlList`

#### 2. Capability-Based Authorization
In `admin_action/move/sources/admin_cap.move`:
- Implement authorization in the `mint` function using the `AdminCap`

#### 3. Signature-Based Authorization
In `admin_action/move/sources/signature.move`:
- Replace the `BE_PUBLIC_KEY` constant with your own public key,
and `sig` in the test with your signature generated with _create-signature/sign.ts_.
Running `sui move test` should fail with `EExpectedFailure`.
- Modify the `mint` function to include the `Counter` in the signed message
- Inside _sign.ts_, set `WITH_COUNTER` to `true` to generate signatures that include the counter
  - Use this signature in the `test_replay` test

#### 5. Referent ID Fixes in Satchel
In `satchel/sources/satchel.move`:
- Link the `SatchelCap` with the `SharedSatchel` it controls
- Implement proper authorization in `add_scroll` and `remove_scroll` functions
- Make the `Borrow` hot-potato specific to a particular `SharedSatchel`
