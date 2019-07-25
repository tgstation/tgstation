/*
	A main component of the infection that is used to expand it's territory
*/

/obj/structure/infection/node
	name = "infection node"
	desc = "A large, pulsating mass."
	icon = 'icons/mob/infection/crystaline_infection_large.dmi'
	icon_state = "crystalnode-layer"
	pixel_x = -32
	pixel_y = -24
	max_integrity = 200
	health_regen = 3
	point_return = 5
	build_time = 150
	upgrade_subtype = /datum/infection_upgrade/node
	// range of the expansion
	var/expansion_range = 8
	// amount of the node expands each pulse
	var/expansion_amount = 12
	// whether or not the node creates shields around it automatically
	var/shield_creation = FALSE

/obj/structure/infection/node/Initialize()
	GLOB.infection_nodes += src
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/infection/node/Pulse_Area(mob/camera/commander/pulsing_overmind)
	..(overmind, expansion_range, expansion_amount)
	pulse_effect()

/obj/structure/infection/node/update_icon()
	. = ..()
	underlays.Cut()
	var/mutable_appearance/node_base = mutable_appearance('icons/mob/infection/crystaline_infection_large.dmi', "crystalnode-base")
	var/mutable_appearance/infection_base = mutable_appearance('icons/mob/infection/infection.dmi', "normal")
	infection_base.pixel_x = -pixel_x
	infection_base.pixel_y = -pixel_y
	infection_base.transform = transform.Invert() // reverse the transformation on the mini node
	underlays += node_base
	underlays += infection_base

/obj/structure/infection/node/Destroy()
	. = ..()
	GLOB.infection_nodes -= src
	STOP_PROCESSING(SSobj, src)

/obj/structure/infection/node/Life()
	update_icon()
	if(shield_creation)
		for(var/obj/structure/infection/normal/N in orange(1, src))
			if(prob(25))
				INVOKE_ASYNC(N, .proc/change_to, /obj/structure/infection/shield, overmind)
	if(overmind && world.time >= next_pulse)
		overmind.infection_core.topulse += src

/*
	The effect that occurs when the node pulses
*/
/obj/structure/infection/node/proc/pulse_effect()
	playsound(src.loc, 'sound/effects/singlebeat.ogg', 600, 1, pressure_affected = FALSE)
	var/state_chosen = prob(50) ? "right" : "left"
	flick("crystalnode-layer-[state_chosen]", src)

/obj/structure/infection/node/mini
	name = "miniature infection node"
	desc = "A smaller, pulsating mass."
	icon = 'icons/mob/infection/crystaline_infection_large.dmi'
	icon_state = "crystalnode-layer"
	transform = matrix(0.5, 0, 0, 0, 0.5, 0)
	max_integrity = 50
	health_regen = 2
	point_return = 0
	upgrade_subtype = null
	expansion_range = 6
	expansion_amount = 6

/obj/structure/infection/node/mini/Initialize()
	. = ..()
	INVOKE_ASYNC(src, .proc/change_to_normal)

/*
	Changes the mini node to a normal infection after its life cycle has ended
*/
/obj/structure/infection/node/mini/proc/change_to_normal()
	sleep(300)
	change_to(/obj/structure/infection/normal, overmind)
