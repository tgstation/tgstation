/datum/action/cooldown/mob_cooldown/blood_worm/worm_beam

	name = "Blood beam"
	desc = "Unleash a barrage of hot acid blood energies in the targeted direction."

/obj/effect/bloodbeam

	name = "brimbeam"
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "brimbeam_mid"
	layer = ABOVE_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	light_power = 3
	light_range = 2
	/// Who made us?
	var/datum/weakref/creator

/obj/effect/bloodbeam/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/effect/bloodbeam/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/effect/bloodbeam/process()
	var/ignore = creator?.resolve()
	for(var/mob/living/hit_mob in get_turf(src))
		if(hit_mob != ignore)
			hit_mob.apply_damage(7, BURN, blocked = hit_mob.run_armor_check(null, LASER, silent = TRUE), wound_bonus = CANT_WOUND)

/// Ignore damage dealt to this mob
/obj/effect/bloodbeam/proc/assign_creator(mob/living/maker)
	creator = WEAKREF(maker)

/// Disappear
/obj/effect/bloodbeam/proc/disperse()
	animate(src, time = 0.5 SECONDS, alpha = 0)
	QDEL_IN(src, 0.5 SECONDS)
