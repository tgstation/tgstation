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

/*
//
// Turret Upgrades
//
*/

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

/datum/infection/upgrade/turret/proc/alter_projectile(obj/item/projectile/A, atom/movable/target)
	return A

/datum/infection/upgrade/turret/proc/projectile_hit(atom/target)
	return

/*
//
// Homing Turret Upgrades
//
*/

/datum/infection/upgrade/turret/turn_speed
	name = "Turn Speed"
	description = "Increases turn speed of shot homing spores."
	radial_icon_state = "tracking_bullet"
	cost = 80

/datum/infection/upgrade/turret/turn_speed/alter_projectile(obj/item/projectile/A, atom/movable/target)
	A.homing_turn_speed *= 2
	return A

/datum/infection/upgrade/turret/flak_homing
	name = "Flak Homing"
	description = "Homings that hit targets will break into tiny spores that do damage to other living creatures around the target."
	radial_icon_state = "blob_spore_temp"
	cost = 120

/datum/infection/upgrade/turret/flak_homing/projectile_hit(atom/target)
	for(var/dir in GLOB.cardinals + GLOB.diagonals)
		var/obj/item/projectile/A = new /obj/item/projectile/bullet/infection/flak(target)
		playsound(target, 'sound/weapons/gunshot_smg.ogg', 75, 1)

		//Shooting Code:
		var/turf/newTarget = get_ranged_target_turf(target, dir, A.range)
		A.preparePixelProjectile(newTarget, target)
		if(ismovableatom(target))
			A.firer = target
		A.fire()
	return

/datum/infection/upgrade/turret/stamina_damage
	name = "Stamina Damage"
	description = "Homing spores deal only stamina damage, 1.5x damage bonus."
	radial_icon = 'icons/obj/projectiles.dmi'
	radial_icon_state = "omnilaser"
	cost = 100

/datum/infection/upgrade/turret/stamina_damage/alter_projectile(obj/item/projectile/A, atom/movable/target)
	A.damage_type = STAMINA
	A.damage *= 1.5
	return A

/*
//
// Infernal Turret Upgrades
//
*/

/*
//
// Resistant Turret Upgrades
//
*/