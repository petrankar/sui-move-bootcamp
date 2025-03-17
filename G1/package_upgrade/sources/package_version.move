module package_upgrade::version;

public struct Version has key {
    id: UID,
    version: u64
}

const EInvalidPackageVersion: u64 = 0;

const VERSION: u64 = 2;

public fun check_is_valid(self: &Version) {
    assert!(self.version == VERSION, EInvalidPackageVersion);
}

public fun migrate(self: &mut Version) {
    self.version = VERSION;
}
