/**
 * # Magicarp Bolt
 * Holder ability simply for "firing a projectile with a cooldown".
 * Probably won't do anything if assigned via VV unless you also VV in a projectile for it.
 */
/datum/action/cooldown/mob_cooldown/projectile_attack/magicarp_bolt
	name = "Magicarp Blast"
	desc = "Unleash a bolt of magical force at a target you click on."
	button_icon = 'icons/obj/weapons/guns/projectiles.dmi'
	button_icon_state = "arcane_barrage"
	cooldown_time = 5 SECONDS
	projectile_sound = 'sound/weapons/emitter.ogg'
	melee_cooldown_time = 0 SECONDS // Without this they become extremely hesitant to bite anyone ever
	shared_cooldown = MOB_SHARED_COOLDOWN_2

/datum/action/cooldown/mob_cooldown/projectile_attack/magicarp_bolt/chaos/attack_sequence(mob/living/firer, atom/target)
	playsound(get_turf(firer), projectile_sound, 100, vary = TRUE)
	return ..()

/// Chaos variant picks one from a list
/datum/action/cooldown/mob_cooldown/projectile_attack/magicarp_bolt/chaos
	/// List of things we can cast
	var/list/permitted_projectiles = list()

/datum/action/cooldown/mob_cooldown/projectile_attack/magicarp_bolt/chaos/attack_sequence(mob/living/firer, atom/target)
	if (!length(permitted_projectiles))
		return
	projectile_type = pick(permitted_projectiles)
	return ..()
