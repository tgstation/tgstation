// What beams can reuse instead of remaking. A beam only uses a flag that both /datum/beam/var/allowed_reuse_flags and its segment type's /obj/effect/ebeam/var/allowed_reuse_flags have

/// Segments share one glow overlay per look (icon, icon state, alpha and z-level) instead of each building their own. It's built the same way, so it looks the same.
/// Leave it out if nothing draws your beam with a glow, since there's nothing to share. /obj/effect/ebeam/goliath leaves it out because goliath tentacles never glow
#define BEAM_REUSE_SHARED_GLOWS (1<<0)
/// On a redraw, a segment that would land on the same turf is reused instead of deleted and remade. Reused segments don't run Initialize() again, don't move, and can lose overlays they added themselves.
/// Leave it out if your segments do something when they're made or placed. /obj/effect/ebeam/launchpad leaves it out because each segment fades out from Initialize(), which a reused segment would skip
#define BEAM_REUSE_OLD_SEGMENTS (1<<1)
/// A finished beam's visuals go to the next beam with the same look and segment type instead of being deleted. Visuals that were changed, or that anything still holds a reference to, get deleted as usual.
/// Leave it out if something keeps track of a beam's visuals some other way, like by REF() text. /obj/effect/ebeam/reacting leaves it out because connect_loc holds on to its visuals, so they'd never be passed on anyway
#define BEAM_REUSE_SPARE_VISUALS (1<<2)
/// All of the above
#define BEAM_REUSE_ALL (BEAM_REUSE_SHARED_GLOWS | BEAM_REUSE_OLD_SEGMENTS | BEAM_REUSE_SPARE_VISUALS)
