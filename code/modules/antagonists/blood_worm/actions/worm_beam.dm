/datum/action/cooldown/mob_cooldown/blood_worm/blood_beam

	name = "Blood beam"
	esc = "Unleash a barrage of hot acid blood energies in the targeted direction."

	// name = "Brimstone Blast"
	// desc = "Unleash a barrage of infernal energies in the targeted direction."
	button_icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	button_icon_state = "brimdemon_firing"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"
	click_to_activate = TRUE
	cooldown_time = 5 SECONDS
	melee_cooldown_time = 0
	/// How far does our beam go?
	var/beam_range = 10
	/// How long does our beam last?
	var/beam_duration = 2 SECONDS
	/// How long do we wind up before firing?
	var/charge_duration = 1 SECONDS
	/// Have we been hit and have to abort the blast?
	var/abort_blast = FALSE
	/// A list of all the beam parts.
	var/list/beam_parts = list()

/datum/action/cooldown/mob_cooldown/brimbeam/Grant(mob/granted_to)
	. = ..()
	if(owner)
		owner.AddElement(/datum/element/relay_attackers)

/datum/action/cooldown/mob_cooldown/brimbeam/Destroy()
	extinguish_laser()
	return ..()

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
