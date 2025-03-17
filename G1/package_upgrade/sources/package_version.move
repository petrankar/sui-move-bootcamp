module package_upgrade::version;

/// Shared object with `version` which updates on every upgrade.
/// Used as input to force the end-user to use the latest contract version.
public struct Version has key {
    id: UID,
    version: u64
}

const EInvalidPackageVersion: u64 = 0;

const VERSION: u64 = 2;

fun init(ctx: &mut TxContext) {
    transfer::share_object(Version { id: object::new(ctx), version: VERSION })
}

/// Function checking that the package-version matches the `Version` object.
public fun check_is_valid(self: &Version) {
    assert!(self.version == VERSION, EInvalidPackageVersion);
}

/// After upgrade, `migrate` function bumbs the `Version`'s object version, to
/// match the latest `VERSION` constant.
public fun migrate(self: &mut Version) {
    self.version = VERSION;
}
