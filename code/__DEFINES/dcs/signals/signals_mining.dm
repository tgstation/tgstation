/// Fired by a mob which has been grabbed by a goliath
#define COMSIG_GOLIATH_TENTACLED_GRABBED "comsig_goliath_tentacle_grabbed"
/// Fired by a goliath tentacle which is returning to the earth
#define COMSIG_GOLIATH_TENTACLE_RETRACTING 	"comsig_goliath_tentacle_retracting"
/// Fired by a mob which has triggered a brimdust explosion from itself (not the mobs that get hit)
#define COMSIG_BRIMDUST_EXPLOSION "comsig_brimdust_explosion"
/// Fired by a crusher trophy/trophy spawned effect before damage is applied to a target mob : (mob/living/target, mob/living/caster)
#define COMSIG_CRUSHER_SPELL_HIT "comsig_crusher_spell_hit"
/// Fired by /obj/item/kinetic_crusher/afterattack() on a living target : (mob/living/user)
#define COMSIG_CRUSHER_ATTACKED "comsig_crusher_attacked"
/// Fired by /obj/item/kinetic_crusher/proc/fire_kinetic_blast() on the crusher : (obj/projectile/destabilizer/marker, mob/living/user)
#define COMSIG_CRUSHER_PROJECTILE_FIRED "comsig_crusher_projectile_fired"
/// Fired by /obj/projectile/destabilizer/on_hit() on the crusher that it's been synced to, if any : (atom/target, datum/status_effect/crusher_mark/applied_mark, had_effect)
#define COMSIG_CRUSHER_MARK_APPLIED "comsig_crusher_mark_applied"
/// Fired by a crusher mark upon detonation on the synced crusher : (mob/living/target, mob/living/user)
#define COMSIG_CRUSHER_MARK_DETONATE "comsig_crusher_mark_detonate"
