/// Checks if the given target is either a client or a mock client
#define IS_CLIENT_OR_MOCK(target) (istype(target, /client) || istype(target, /datum/client_interface))

/// Checks to see if a /client has fully gone through New() as a safeguard against certain operations.
/// Should return the boolean value of the fully_created var, which should be TRUE if New() has finished running. FALSE otherwise.
#define VALIDATE_CLIENT_INITIALIZATION(target) (target.fully_created)

/// The minimum client BYOND build to disable screentip icons for.
#define MIN_BYOND_BUILD_DISABLE_SCREENTIP_ICONS 1657
/// The maximum client BYOND build to disable screentip icons for.
/// Update this whenever https://www.byond.com/forum/post/2967731 is fixed.
#define MAX_BYOND_BUILD_DISABLE_SCREENTIP_ICONS 1699
