/obj/structure/infection/node
	name = "infection node"
	icon = 'icons/mob/infection/crystaline_infection_large.dmi'
	icon_state = "crystalnode-layer"
	pixel_x = -32
	pixel_y = -24
	desc = "A large, pulsating mass."
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 65, "acid" = 90)
	health_regen = 3
	point_return = 5
	build_time = 100
	var/expansion_range = 6
	var/expansion_amount = 6
	var/base_pulse_cd // cooldown before being increased by time they've been alive

/obj/structure/infection/node/Initialize()
	GLOB.infection_nodes += src
	. = ..()
	START_PROCESSING(SSobj, src)
	base_pulse_cd = pulse_cooldown

/obj/structure/infection/node/Pulse_Area(mob/camera/commander/pulsing_overmind)
	..(overmind, expansion_range, expansion_amount)
	pulse_effect()

/obj/structure/infection/node/update_icon()
	. = ..()
	underlays.Cut()
	var/mutable_appearance/node_base = mutable_appearance('icons/mob/infection/crystaline_infection_large.dmi', "crystalnode-base")
	underlays += node_base

/obj/structure/infection/node/Destroy()
	. = ..()
	GLOB.infection_nodes -= src
	STOP_PROCESSING(SSobj, src)

/obj/structure/infection/node/Life()
	pulse_cooldown = base_pulse_cd * CLAMP((world.time - timecreated) / 300, 1, 8)
	if(overmind && world.time >= next_pulse)
		overmind.infection_core.topulse += src

/obj/structure/infection/node/proc/pulse_effect()
	playsound(src.loc, 'sound/effects/singlebeat.ogg', 600, 1, pressure_affected = FALSE)
	var/state_chosen = prob(50) ? "right" : "left"
	flick("crystalnode-layer-[state_chosen]", src)