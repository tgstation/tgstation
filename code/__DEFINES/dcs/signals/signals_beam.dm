/// Called before beam is redrawn
#define COMSIG_BEAM_BEFORE_DRAW "beam_before_draw"
	#define BEAM_CANCEL_DRAW (1 << 0)

/// Sent to a beam when an atom enters any turf the beam covers: (obj/effect/ebeam/hit_beam, atom/movable/entered)
#define COMSIG_BEAM_ENTERED "beam_entered"

/// Sent to a beam when an atom exits any turf the beam covers: (obj/effect/ebeam/hit_beam, atom/movable/exited)
#define COMSIG_BEAM_EXITED "beam_exited"

/// Sent to a beam when any turf the beam covers changes: (list/datum/callback/post_change_callbacks)
#define COMSIG_BEAM_TURFS_CHANGED "beam_turfs_changed"
