/datum/infection/upgrade
	// display stuff
	var/name = ""
	var/description = ""
	var/radial_icon = 'icons/mob/blob.dmi'
	var/radial_icon_state = ""

	// application
	var/cost = 0
	var/times = 1 // times the upgrade can be applied
	var/bought = FALSE // if the upgrade has been bought / applied

/datum/infection/upgrade/proc/upgrade_effect(var/obj/structure/infection/I)
	return

/datum/infection/upgrade/resistant_turret
	name = "Resistant Turret"
	description = "Triples the structural integrity of your turret."
	radial_icon_state = "bullet"
	cost = 70

/datum/infection/upgrade/resistant_turret/upgrade_effect(var/obj/structure/infection/I)
	I.change_to(/obj/structure/infection/turret/resistant, I.overmind)
	return

/datum/infection/upgrade/infernal_turret
	name = "Infernal Turret"
	description = "Increases speed of bullets and changes damage to burn."
	radial_icon_state = "fire_bullet"
	cost = 70

/datum/infection/upgrade/infernal_turret/upgrade_effect(var/obj/structure/infection/I)
	I.change_to(/obj/structure/infection/turret/infernal, I.overmind)
	return

/datum/infection/upgrade/homing_turret
	name = "Homing Turret"
	description = "Shoots spores that have increased range and track their target."
	radial_icon_state = "tracking_bullet"
	cost = 70

/datum/infection/upgrade/homing_turret/upgrade_effect(var/obj/structure/infection/I)
	I.change_to(/obj/structure/infection/turret/homing, I.overmind)
	return

/datum/infection/upgrade/homing/turn_speed
	name = "Turn Speed"
	description = "Increases turn speed of shot homing spores."
	radial_icon_state = "tracking_bullet"
	cost = 80

/datum/infection/upgrade/homing/turn_speed/upgrade_effect(var/obj/structure/infection/I)
	return

/datum/infection/upgrade/homing/flak_homing
	name = "Flak Homing"
	description = "Homings that hit targets will break into tiny bullets that do damage to other living creatures around the target."
	radial_icon_state = "blob_spore_temp"
	cost = 120

/datum/infection/upgrade/homing/flak_homing/upgrade_effect(var/obj/structure/infection/I)
	return

/datum/infection/upgrade/homing/stamina_damage
	name = "Stamina Damage"
	description = "Homing spores will instead deal stamina damage."
	radial_icon = 'icons/obj/projectiles.dmi'
	radial_icon_state = "omnilaser"
	cost = 100

/datum/infection/upgrade/homing/stamina_damage/upgrade_effect(var/obj/structure/infection/I)
	return