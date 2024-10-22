// living_flags
/// Simple mob trait, indicating it may follow continuous move actions controlled by code instead of by user input.
#define MOVES_ON_ITS_OWN (1<<0)
/// Always does *deathgasp when they die
/// If unset mobs will only deathgasp if supplied a death sound or custom death message
#define ALWAYS_DEATHGASP (1<<1)
/**
 * For carbons, this stops bodypart overlays being added to bodyparts from calling mob.update_body_parts().
 * This is useful for situations like initialization or species changes, where
 * update_body_parts() is going to be called ONE time once everything is done.
 */
#define STOP_OVERLAY_UPDATE_BODY_PARTS (1<<2)

/// Getter for a mob/living's lying angle, otherwise protected
#define GET_LYING_ANGLE(mob) (UNLINT(mob.lying_angle))

//  || pixelshifting ||
///from base of living/set_pull_offset(): (mob/living/pull_target, grab_state)
#define COMSIG_LIVING_SET_PULL_OFFSET "living_set_pull_offset"
///from base of living/reset_pull_offsets(): (mob/living/pull_target, override)
#define COMSIG_LIVING_RESET_PULL_OFFSETS "living_reset_pull_offsets"
///from base of living/CanAllowThrough(): (atom/movable/mover, border_dir)
#define COMSIG_LIVING_CAN_ALLOW_THROUGH "living_can_allow_through"
/// Allow to movable atoms to pass through this living mob
#define COMPONENT_LIVING_PASSABLE (1<<0)
