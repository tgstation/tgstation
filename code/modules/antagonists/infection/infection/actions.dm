/*
	Actions that the infection and their creatures can use
*/

/datum/action/cooldown/infection
	name = "Infection Power"
	desc = "New Infection Power"
	icon_icon = 'icons/mob/infection/action_icons.dmi'
	button_icon_state = ""
	cooldown_time = 0
	var/cost = 0 // cost to actually use

/datum/action/cooldown/infection/New()
	name = name + " ([cost])"
	. = ..()

/datum/action/cooldown/infection/Trigger()
	if(!..())
		return FALSE
	var/mob/I = owner
	var/turf/T = get_turf(I)
	if(T)
		fire(I, T)
		return TRUE
	return FALSE

/*
	Called when all basic requirements for the action to be used have been met
*/
/datum/action/cooldown/infection/proc/fire(mob/camera/commander/I, turf/T)
	return TRUE

/datum/action/cooldown/infection/coregrab
	name = "Core Grab"
	desc = "Causes a rift over an infection that a few seconds after creation, ruptures, sending everything on the turf to the core of the infection."
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "bluestream_fade"
	cost = 50
	cooldown_time = 450

/datum/action/cooldown/infection/coregrab/fire(mob/camera/commander/I, turf/T)
	var/obj/structure/infection/S = locate(/obj/structure/infection) in T.contents
	if(S)
		if(!I.can_buy(cost))
			return
		StartCooldown()
		playsound(T, 'sound/effects/seedling_chargeup.ogg', 100, FALSE, pressure_affected = FALSE)
		new /obj/effect/temp_visual/bluespace_fissure(T)
		sleep(9)
		new /obj/effect/temp_visual/bluespace_fissure(T)
		sleep(9)
		new /obj/effect/temp_visual/bluespace_fissure(T)
		sleep(9)
		if(I.infection_core)
			var/list/possible_turfs = RANGE_TURFS(2, I.infection_core) - RANGE_TURFS(1, I.infection_core)
			var/do_fade = FALSE
			for(var/mob/living/L in T.contents)
				L.forceMove(pick(possible_turfs))
				do_fade = TRUE
			if(do_fade)
				new /obj/effect/temp_visual/fading_person(T)
		return
	to_chat(I, "<span class='warning'>You must be above an infection to use this ability!</span>")

/datum/action/cooldown/infection/targetlocation
	name = "Target Location"
	desc = "Announces to all current sentient slimes that you want them to target the location you are currently at."
	icon_icon = 'icons/effects/landmarks_static.dmi'
	button_icon_state = "x3"
	cost = 0
	cooldown_time = 200

/datum/action/cooldown/infection/targetlocation/fire(mob/camera/commander/I, turf/T)
	StartCooldown()
	if(!I.infection_core)
		to_chat(I, "<span class='warning'>The core has not landed yet!</span>")
		return
	to_chat(I, "<span class='warning'>You alert your slimes to target this spot!</span>")
	for(var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/SM in I.infection_mobs)
		SM.playsound_local(SM.loc, 'sound/effects/magic.ogg', 100, 1)
		// give a link to the mob to walk towards the location
		to_chat(SM, "<a href=?src=[REF(SM)];walk_to=[REF(T)]>The commander is requesting that you prioritize a location!</a>")

/datum/action/cooldown/infection/creator
	name = "Create"
	desc = "New Creation Power"
	// type of infection structure to create
	var/type_to_create
	// must be placed more than this distance away from another structure of the same type
	var/distance_from_similar = 0
	// whether or not this structure requires a node to be placed down
	var/needs_node = FALSE

/datum/action/cooldown/infection/creator/fire(mob/camera/commander/I, turf/T)
	I.createSpecial(cost, type_to_create, distance_from_similar, needs_node, T)
	return TRUE

/datum/action/cooldown/infection/creator/shield
	name = "Create Shield Infection"
	desc = "Create a shield infection, which is harder to kill and has resistances to different types of attacks."
	cost = 5
	button_icon_state = "wall"
	type_to_create = /obj/structure/infection/shield

/datum/action/cooldown/infection/creator/reflective
	name = "Create Reflective Shield Infection"
	desc = "Create a shield that will reflect projectiles back at your enemies."
	cost = 10
	button_icon_state = "reflective"
	type_to_create = /obj/structure/infection/shield/reflective

/datum/action/cooldown/infection/creator/node
	name = "Create Node Infection"
	desc = "Create a node, which will power nearby factory and resource structures."
	cost = 50
	button_icon_state = "node"
	type_to_create = /obj/structure/infection/node
	distance_from_similar = 6

/datum/action/cooldown/infection/creator/resource
	name = "Create Resource Infection"
	desc = "Create a resource tower which will gradually generate resources for you."
	cost = 25
	button_icon_state = "resource"
	type_to_create = /obj/structure/infection/resource
	distance_from_similar = 4
	needs_node = TRUE

/datum/action/cooldown/infection/creator/factory
	name = "Create Factory Infection"
	desc = "Create a spore tower that will spawn spores to harass your enemies."
	cost = 50
	button_icon_state = "factory"
	type_to_create = /obj/structure/infection/factory
	distance_from_similar = 7
	needs_node = TRUE

/datum/action/cooldown/infection/creator/turret
	name = "Create Turret Infection"
	desc = "Create a turret that will automatically fire at your enemies."
	cost = 50
	button_icon_state = "turret"
	type_to_create = /obj/structure/infection/turret
	distance_from_similar = 8
	needs_node = TRUE

/datum/action/cooldown/infection/creator/beamturret
	name = "Create Beam Turret Infection"
	desc = "Create a turret that will automatically fire and instantly stick to your enemies."
	cost = 50
	button_icon_state = "beamturret"
	type_to_create = /obj/structure/infection/turret/beam
	distance_from_similar = 8
	needs_node = TRUE

/datum/action/cooldown/infection/creator/vacuum
	name = "Create Vacuum Infection"
	desc = "Create a vacuum that will suck in anything non-infectious, as well as hurt things caught in it."
	cost = 50
	button_icon_state = "vacuum"
	type_to_create = /obj/structure/infection/vacuum
	distance_from_similar = 8
	needs_node = TRUE

/datum/action/cooldown/infection/creator/barrier
	name = "Create Barrier Infection"
	desc = "Create a barrier that will function as a normal wall, but will allow infectious creatures to pull things through them."
	cost = 15
	button_icon_state = "door"
	type_to_create = /obj/structure/infection/shield/barrier
	distance_from_similar = 3

/datum/action/cooldown/infection/mininode
	name = "Miniature Node"
	desc = "Creates a miniature node on the infection you're standing on."
	button_icon_state = "node"
	cooldown_time = 600

/datum/action/cooldown/infection/mininode/fire(mob/living/simple_animal/hostile/infection/infectionspore/sentient/S, turf/T)
	var/obj/structure/infection/I = locate(/obj/structure/infection/normal) in T.contents
	if(I)
		StartCooldown()
		playsound(T, 'sound/effects/splat.ogg', 100, FALSE, pressure_affected = FALSE)
		I.change_to(/obj/structure/infection/node/mini, I.overmind, 25)
		return
	to_chat(S, "<span class='warning'>You must be above an infection to use this ability!</span>")

/datum/action/cooldown/infection/reflective
	name = "Reflective Shield"
	desc = "Creates a reflective shield on the infection you're standing on."
	button_icon_state = "reflective"
	cooldown_time = 450

/datum/action/cooldown/infection/reflective/fire(mob/living/simple_animal/hostile/infection/infectionspore/sentient/S, turf/T)
	var/obj/structure/infection/I = locate(/obj/structure/infection/normal) in T.contents
	if(I)
		StartCooldown()
		playsound(T, 'sound/effects/splat.ogg', 100, FALSE, pressure_affected = FALSE)
		I.change_to(/obj/structure/infection/shield/reflective, I.overmind, 25)
		return
	to_chat(S, "<span class='warning'>You must be above an infection to use this ability!</span>")

/datum/action/cooldown/infection/flash
	name = "Bright Flash"
	desc = "Creates a bright flash of light centered around you."
	icon_icon = 'icons/obj/assemblies/new_assemblies.dmi'
	button_icon_state = "flash"
	cooldown_time = 450

/datum/action/cooldown/infection/flash/fire(mob/living/simple_animal/hostile/infection/infectionspore/sentient/S, turf/T)
	if(ISRESPAWNING(S))
		to_chat(S, "<span class='warning'>You must be alive to use this ability!</span>")
		return
	StartCooldown()
	playsound(T, 'sound/weapons/flash.ogg', 100, FALSE, pressure_affected = FALSE)
	new /obj/effect/temp_visual/at_shield(T)
	sleep(8)
	new /obj/effect/temp_visual/at_shield(T)
	sleep(8)
	for(var/mob/living/L in viewers(S,2) - S)
		L.flash_act()
