module package_upgrade::version;

public struct Version has key {
    id: UID,
    version: u64
}

const EInvalidPackageVersion: u64 = 0;

// DEMO: Bump version.
// DEMO: Change constant values.
const VERSION: u64 = 1;

public fun check_is_valid(self: &Version) {
    assert!(self.version == VERSION, EInvalidPackageVersion);
}

// DEMO: Migrate Version object.
// DEMO: Add new function.
