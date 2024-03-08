/// Checks if the given target is either a client or a mock client
#define IS_CLIENT_OR_MOCK(target) (istype(target, /client) || istype(target, /datum/client_interface))

/// Checks to see if a /client has fully gone through New() as a safeguard against certain operations.
/// Should return the boolean value of the fully_created var, which should be TRUE if New() has finished running. FALSE otherwise.
#define VALIDATE_CLIENT_INITIALIZATION(target) (target.fully_created)
