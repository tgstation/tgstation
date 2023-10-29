/obj/structure/artifact_forcefield
	name = "forcefield"
	desc = "A glowing barrier, completely impenetratable to your means. Possibly made by some nearby object."
	icon = 'icons/effects/effects.dmi'
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	anchored = TRUE
	pass_flags_self = PASSGLASS
	density = TRUE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	resistance_flags = INDESTRUCTIBLE
	can_atmos_pass = ATMOS_PASS_DENSITY

/obj/structure/artifact_forcefield/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(loc, 'sound/weapons/egloves.ogg', 80, TRUE)

/datum/component/artifact/forcegen
	associated_object = /obj/structure/artifact/forcegen
	weight = ARTIFACT_UNCOMMON
	type_name = "Forcefield Generator"
	activation_message = "springs to life and starts emitting a forcefield!"
	deactivation_message = "shuts down, its forcefields shutting down with it."
	valid_activators = list(
		/datum/artifact_activator/touch/carbon,
		/datum/artifact_activator/touch/silicon,
		/datum/artifact_activator/range/force
	)
	var/cooldown_time //cooldown AFTER the shield lowers
	var/shield_iconstate
	var/list/projected_forcefields = list()
	var/radius
	var/shield_time
	COOLDOWN_DECLARE(cooldown)

/datum/component/artifact/forcegen/setup()
	shield_iconstate = pick("shieldsparkles","empdisable","shield2","shield-old","shield-red","shield-green","shield-yellow")
	activation_sound = pick('sound/mecha/mech_shield_drop.ogg')
	deactivation_sound = pick('sound/mecha/mech_shield_raise.ogg','sound/magic/forcewall.ogg')
	shield_time = rand(10,40) SECONDS
	radius = rand(1,3)
	cooldown_time = shield_time / 3
	potency += radius * 3 + shield_time / 30

/datum/component/artifact/forcegen/effect_activate()
	if(!COOLDOWN_FINISHED(src,cooldown))
		holder.visible_message(span_notice("[holder] wheezes, shutting down."))
		artifact_deactivate(TRUE)
		return
	holder.anchored = TRUE
	var/turf/our_turf = get_turf(holder)
	var/list/bad_turfs
	if(radius > 1)
		bad_turfs = range(radius - 1, holder)
	for(var/turf/open/floor in range(radius,holder))
		if(floor in bad_turfs)
			continue
		if(floor == our_turf)
			continue
		var/obj/field = new /obj/structure/artifact_forcefield(floor)
		field.icon_state = shield_iconstate
		projected_forcefields += field
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/component/artifact, artifact_deactivate)), shield_time)
	COOLDOWN_START(src,cooldown,shield_time + cooldown_time)

/datum/component/artifact/forcegen/effect_deactivate()
	holder.anchored = FALSE
	for(var/obj/field in projected_forcefields)
		projected_forcefields -= field
		qdel(field)
