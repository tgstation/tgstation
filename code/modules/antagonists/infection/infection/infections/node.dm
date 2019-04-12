/obj/structure/infection/node
	name = "infection node"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob"
	desc = "A large, pulsating mass."
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 65, "acid" = 90)
	health_regen = 3
	point_return = 25
	var/expansion_range = 6
	var/expansion_amount = 6
	var/base_pulse_cd // cooldown before being increased by time they've been alive

/obj/structure/infection/node/Initialize()
	GLOB.infection_nodes += src
	START_PROCESSING(SSobj, src)
	. = ..()
	base_pulse_cd = pulse_cooldown

/obj/structure/infection/node/show_description()
	return

/obj/structure/infection/node/scannerreport()
	return "Gradually expands and sustains nearby infectious structures."

/obj/structure/infection/node/Pulse_Area(mob/camera/commander/pulsing_overmind)
	..(claim_range = expansion_range, count = expansion_amount)
	playsound(src.loc, 'sound/effects/singlebeat.ogg', 600, 1, pressure_affected = FALSE)

/obj/structure/infection/node/update_icon()
	cut_overlays()
	color = null
	var/mutable_appearance/infection_overlay = mutable_appearance('icons/mob/blob.dmi', "blob")
	if(overmind)
		infection_overlay.color = overmind.infection_color
	add_overlay(infection_overlay)
	add_overlay(mutable_appearance('icons/mob/blob.dmi', "blob_node_overlay"))

/obj/structure/infection/node/Destroy()
	GLOB.infection_nodes -= src
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/infection/node/Life()
	pulse_cooldown = base_pulse_cd * CLAMP((world.time - timecreated) / 300, 1, 8)
	if(overmind && world.time >= next_pulse)
		overmind.infection_core.topulse += src