/obj/structure/infection/node
	name = "infection node"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob"
	desc = "A large, pulsating mass."
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 65, "acid" = 90)
	health_regen = 3
	point_return = 25
	upgrade_type = "Node"
	cost_per_level = 30
	extra_description = "Doubles current rate of expansion (minimum 2 seconds, rate slows with age to a max multiplier of 8 and starts at 2 seconds), increases range of expansion by 2, and increases amount expanded per expansion by 2."


/obj/structure/infection/node/Initialize()
	GLOB.infection_nodes += src
	START_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/infection/node/scannerreport()
	return "Gradually expands and sustains nearby infectious structures."

/obj/structure/infection/node/do_upgrade()
	pulse_cooldown /= 2

/obj/structure/infection/node/Pulse_Area(mob/camera/commander/pulsing_overmind, var/claim_range = 6, var/count = 6)
	..(claim_range = 4 + infection_level * 2, count = 4 + infection_level * 2)

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
	if(overmind && world.time >= next_pulse)
		overmind.infection_core.topulse += src