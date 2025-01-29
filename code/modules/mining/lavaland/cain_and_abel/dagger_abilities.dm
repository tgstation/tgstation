/datum/action/cooldown/dagger_swing
	name = "Dagger swing"
	desc = "Swing your daggers around."
	button_icon = 'icons/obj/mining_zones/artefacts.dmi'
	button_icon_state = "cain_and_abel"
	background_icon_state = "bg_default"
	overlay_icon_state = "bg_default_border"
	cooldown_time = 20 SECONDS

/datum/action/cooldown/dagger_swing/Activate(atom/target_atom)
	. = ..()
	var/mob/living/living_owner = owner
	living_owner.apply_status_effect(/datum/status_effect/dagger_swinging)
	for(var/index in 0 to 3)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), owner, 'sound/items/weapons/fwoosh.ogg', 75, TRUE), 0.15 SECONDS * index)


/datum/status_effect/dagger_swinging
	id = "dagger swinging"
	tick_interval = 0.25 SECONDS
	duration = 1.75 SECONDS
	alert_type = null

/datum/status_effect/dagger_swinging/on_apply()
	. = ..()
	if(!.)
		return
	var/obj/effect/temp_visual/dagger_slash/slash_effect = new
	owner.vis_contents += slash_effect
	RegisterSignal(owner, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(hit_by_projectile))
	RegisterSignal(owner, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(block_attack))

/datum/status_effect/dagger_swinging/tick(seconds_between_ticks)
	if(!isturf(owner.loc))
		return

	var/mob_hit = FALSE
	for(var/mob/living/target_mob in oview(owner, 1))
		if(target_mob.mob_size < MOB_SIZE_LARGE)
			continue
		target_mob.apply_damage(25, BRUTE)
		mob_hit = TRUE

	if(mob_hit)
		playsound(owner, 'sound/items/weapons/bladeslice.ogg', 75, FALSE) //just play it once

/datum/status_effect/dagger_swinging/proc/hit_by_projectile(mob/living/swinger, obj/projectile/projectile, hit_area)
	SIGNAL_HANDLER

	if(!isturf(owner.loc))
		return NONE

	playsound(swinger, 'sound/items/weapons/parry.ogg', 75, TRUE)

	var/obj/effect/temp_visual/guardian/phase/out/parry_effect = new
	parry_effect.pixel_x = rand(-4, 4)
	parry_effect.pixel_y = rand(-10, 10)
	owner.vis_contents += parry_effect

	projectile.firer = swinger
	projectile.set_angle(-projectile.angle)
	return COMPONENT_BULLET_PIERCED

/datum/status_effect/dagger_swinging/proc/block_attack(
	mob/living/source,
	atom/hitby,
	damage,
	attack_text,
	attack_type,
	armour_penetration,
	damage_type,
	attack_flag,
)
	SIGNAL_HANDLER

	if(attack_type == PROJECTILE_ATTACK || damage >= 75 || damage <= 0 || damage_type == STAMINA)
		return NONE

	playsound(owner, 'sound/items/weapons/parry.ogg', 75, TRUE)
	new /obj/effect/temp_visual/guardian/phase/out(get_turf(owner))
	return SUCCESSFUL_BLOCK
