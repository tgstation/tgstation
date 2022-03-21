/datum/action/cooldown/mob_cooldown/direct_and_aoe
	name = "Direct And AoE Firing"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Allows you to shoot directly at a target while also firing around you."
	cooldown_time = 12 SECONDS
	/// Our hidden direct fire ability
	var/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/direct/direct_fire
	/// Our hidden aoe ability
	var/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/pattern/circular/complete/aoe_fire

/datum/action/cooldown/mob_cooldown/direct_and_aoe/New(Target)
	. = ..()
	direct_fire = new /datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/direct()
	aoe_fire = new /datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/pattern/circular/complete()

/datum/action/cooldown/mob_cooldown/direct_and_aoe/Destroy()
	. = ..()
	QDEL_NULL(direct_fire)
	QDEL_NULL(aoe_fire)

/datum/action/cooldown/mob_cooldown/direct_and_aoe/Grant(mob/M)
	. = ..()
	direct_fire.Grant(owner, FALSE)
	aoe_fire.Grant(owner, FALSE)

/datum/action/cooldown/mob_cooldown/direct_and_aoe/Remove(mob/M)
	. = ..()
	direct_fire.Remove(owner)
	aoe_fire.Remove(owner)

/datum/action/cooldown/mob_cooldown/direct_and_aoe/Activate(atom/target_atom)
	INVOKE_ASYNC(direct_fire, /datum/action/cooldown/proc/Activate, target_atom)
	INVOKE_ASYNC(aoe_fire, /datum/action/cooldown/proc/Activate, target_atom)
