/mob/living/basic/node_drone
	name = "NODE drone"
	desc = "Standard in-atmosphere drone, used by Nanotrasen to operate and excavate valuable ore vents."
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining_node"
	icon_living = "mining_node_active"
	icon_dead = "mining_node"

	maxHealth = 100
	health = 100
	density = TRUE
	pass_flags = PASSTABLE|PASSGRILLE|PASSMOB
	mob_size = MOB_SIZE_LARGE
	mob_biotypes = MOB_ROBOTIC
	faction = list(FACTION_STATION)

	speak_emote = list("chirps")
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "clangs"
	response_harm_simple = "clang"

	ai_controller = /datum/ai_controller/basic_controller/mouse

	/// Is the drone currently attached to a vent?
	var/active_node = FALSE
	/// Weakref to the vent the drone is currently attached to.
	var/obj/structure/ore_vent/attached_vent = null

/mob/living/basic/node_drone/Initialize(mapload)
	. = ..()


/mob/living/basic/node_drone/examine(mob/user)
	. = ..()
	var/sameside = user.faction_check_mob(src, exact_match = FALSE)
	if(sameside)
		. += span_notice("This drone is currently attached to a mineral vent. You should protect it from harm to secure the mineral vent.")
	else
		. += span_warning("This vile Nanotrasen trash is trying to destroy the environment. Attack it to free the mineral vent from its grasp.")


/mob/living/basic/node_drone/death(gibbed)
	. = ..(TRUE)
	say("I'm dead now!")
	qdel(src)



