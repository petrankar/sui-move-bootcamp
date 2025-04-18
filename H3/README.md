## Common Limitations and Vulnerability Patterns

### 1. Admin Actions

In admin_actions module, `mint_hero` is called without any authentication.
1. Implement authentication via `AdminCap` in _admin_cap.move_.
2. Implement authentication via `AccessControlList` in _acl.move_.
