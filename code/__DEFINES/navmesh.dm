/*
 * Navmesh: cached per-turf directional passability.
 *
 * Experimental, additive-only alternative to querying LinkBlockedWithAccess() per step during
 * pathfinding. Each turf caches, per cardinal direction, whether a baseline GROUND / FLYING mover
 * can leave that turf in that direction, plus a "conditional" bit meaning "there are blockers on
 * this edge that must be evaluated per-mover" (access doors, pass-flag gated statics like tables).
 *
 * Deliberate divergences from JPS, documented here and enforced in the bake:
 * - Mobs are never baked into the mesh (they move constantly and would thrash invalidation). The
 *   mover resolves live mobs at execution time (bump / wait / repath).
 * - Single-z, exactly like JPS.
 */

// --- nav_pass bit layout ------------------------------------------------------------------------
// nav_pass is a packed int on /turf. null means "unbaked / dirty". Cardinal dir values (1/2/4/8)
// are used directly as bit groups so we can index by dir with no lookup.

/// bits 0-3: a baseline GROUND mover can traverse the outgoing edge in this dir
#define NAV_GROUND(dir)  (dir)
/// bits 4-7: a baseline FLYING mover can traverse the outgoing edge in this dir
#define NAV_FLIGHT(dir)  ((dir) << 4)
/// bits 8-11: this outgoing edge has per-mover conditional blockers (walk nav_blockers["[dir]"])
#define NAV_COND(dir)    ((dir) << 8)
/// set once a turf has been baked, so "baked but every edge blocked" (value could be 0) is
/// distinguishable from null (unbaked). Always OR'd in by nav_bake().
#define NAV_BAKED        (1 << 12)

/// pass_flags bits that are NOT passability grants and must be stripped when we build a blocker mask
#define NAV_NON_PASS_FLAGS (LETPASSTHROW | LETPASSCLICKS)

/// TRUE if this movable can affect the navmesh. Mobs are excluded by design. An atom matters if it
/// is dense, has pass_flags_self (border/gated statics), or forces the CanAStarPass proc to run.
#define NAV_RELEVANT(AM) (!ismob(AM) && ((AM).density || (AM).pass_flags_self || (AM).can_astar_pass != CANASTARPASS_DENSITY))

/// Movement class selector for a baked bit given a can_pass_info's movement_type.
#define NAV_CLASS_BIT(pass_info, dir) (((pass_info).movement_type & MOVETYPES_NOT_TOUCHING_GROUND) ? NAV_FLIGHT(dir) : NAV_GROUND(dir))
