// check_pierce() return values
/// Default behavior: hit and delete self
#define PROJECTILE_PIERCE_NONE		0
/// Hit the thing but go through without deleting. Causes on_hit to be called with pierced = TRUE
#define PROJECTILE_PIERCE_HIT		1
/// Entirely phase through the thing without ever hitting.
#define PROJECTILE_PIERCE_PHASE		2
// Delete self without hitting
#define PROJECTILE_DELETE_WITHOUT_HITTING		3
