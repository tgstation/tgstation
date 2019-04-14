/datum/infection/upgrade
	// display stuff
	var/name = ""
	var/description = ""
	var/radial_icon = 'icons/mob/blob.dmi'
	var/radial_icon_state = ""

	// application
	var/cost = 0
	var/times = 1 // times the upgrade can be bought
	var/bought = 0 // how many times the upgrade has been bought

/datum/infection/upgrade/proc/do_upgrade(var/atom/P)
	times--
	bought++
	upgrade_effect(P)
	return

/datum/infection/upgrade/proc/upgrade_effect(var/atom/P)
	return

/*
//
// Spore Upgrades
//
*/

/datum/infection/upgrade/defensive_spore
	name = "Defensive Spore"
	description = "War of attrition taken to the next level."
	radial_icon_state = "bullet"
	cost = 1

/datum/infection/upgrade/defensive_spore/upgrade_effect(var/mob/living/simple_animal/hostile/infection/infectionspore/IS)
	var/mob/living/simple_animal/hostile/infection/infectionspore/defensive/DS = new /mob/living/simple_animal/hostile/infection/infectionspore/defensive(IS.loc, null, IS.overmind)
	IS.mind.transfer_to(DS)
	DS.can_zombify = FALSE
	DS.upgrade_points = IS.upgrade_points
	qdel(IS)
	return

/datum/infection/upgrade/offensive_spore
	name = "Offensive Spore"
	description = "Fully prepared to dust your enemies."
	radial_icon_state = "fire_bullet"
	cost = 1

/datum/infection/upgrade/offensive_spore/upgrade_effect(var/mob/living/simple_animal/hostile/infection/infectionspore/IS)
	var/mob/living/simple_animal/hostile/infection/infectionspore/defensive/OS = new /mob/living/simple_animal/hostile/infection/infectionspore/offensive(IS.loc, null, IS.overmind)
	IS.mind.transfer_to(OS)
	OS.can_zombify = FALSE
	OS.upgrade_points = IS.upgrade_points
	qdel(IS)
	return

/datum/infection/upgrade/supportive_spore
	name = "Supportive Spore"
	description = "Fill the gaps that your allies cannot."
	radial_icon_state = "tracking_bullet"
	cost = 1

/datum/infection/upgrade/supportive_spore/upgrade_effect(var/mob/living/simple_animal/hostile/infection/infectionspore/IS)
	var/mob/living/simple_animal/hostile/infection/infectionspore/defensive/SS = new /mob/living/simple_animal/hostile/infection/infectionspore/supportive(IS.loc, null, IS.overmind)
	IS.mind.transfer_to(SS)
	SS.can_zombify = FALSE
	SS.upgrade_points = IS.upgrade_points
	qdel(IS)
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

/datum/infection/upgrade/turret/proc/alter_projectile(var/obj/structure/infection/turret/T, obj/item/projectile/A, atom/movable/target)
	return A

/datum/infection/upgrade/turret/proc/projectile_hit(var/obj/structure/infection/turret/T, atom/target)
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
	cost = 60
	times = 3

/datum/infection/upgrade/turret/turn_speed/alter_projectile(var/obj/structure/infection/turret/T, obj/item/projectile/A, atom/movable/target)
	A.homing_turn_speed *= 2 * bought
	return A

/datum/infection/upgrade/turret/flak_homing
	name = "Flak Homing"
	description = "Homings that hit targets will break into tiny spores that do damage to other living creatures around the target."
	radial_icon_state = "blob_spore_temp"
	cost = 60
	times = 3

/datum/infection/upgrade/turret/flak_homing/projectile_hit(var/obj/structure/infection/turret/T, atom/target)
	for(var/dir in GLOB.cardinals + GLOB.diagonals)
		var/obj/item/projectile/A = new /obj/item/projectile/bullet/infection/flak(target)
		playsound(target, 'sound/weapons/gunshot_smg.ogg', 75, 1)
		A.damage *= bought

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
	cost = 60

/datum/infection/upgrade/turret/stamina_damage/alter_projectile(var/obj/structure/infection/turret/T, obj/item/projectile/A, atom/movable/target)
	A.damage_type = STAMINA
	A.damage *= 1.5
	return A

/*
//
// Infernal Turret Upgrades
//
*/

/datum/infection/upgrade/turret/burning_spores
	name = "Burning Spores"
	description = "Sets fire to the target on hit."
	radial_icon = 'icons/effects/fire.dmi'
	radial_icon_state = "fire"
	cost = 100

/datum/infection/upgrade/turret/burning_spores/projectile_hit(var/obj/structure/infection/turret/T, atom/target)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(4)
		M.IgniteMob()

/datum/infection/upgrade/turret/fire_rate
	name = "Fire Rate"
	description = "Increases the fire rate of the turret."
	radial_icon_state = "fire_bullet"
	cost = 100
	times = 3

/datum/infection/upgrade/turret/fire_rate/upgrade_effect(var/obj/structure/infection/I)
	var/obj/structure/infection/turret/T = I
	T.frequency++
	return

/datum/infection/upgrade/turret/armour_penetration
	name = "Armour Penetration"
	description = "Increases the armour penetration of the turret."
	radial_icon_state = "tracking_bullet"
	cost = 50
	times = 3

/datum/infection/upgrade/turret/armour_penetration/alter_projectile(var/obj/structure/infection/turret/T, obj/item/projectile/A, atom/movable/target)
	A.armour_penetration += 15 * bought
	return A

/*
//
// Resistant Turret Upgrades
//
*/

/datum/infection/upgrade/turret/knockback
	name = "Knockback Spores"
	description = "Knocks the target back on hit."
	radial_icon_state = "blobbernaut"
	cost = 100

/datum/infection/upgrade/turret/knockback/projectile_hit(var/obj/structure/infection/turret/T, atom/target)
	if(ismovableatom(target))
		var/atom/movable/throwTarget = target
		throwTarget.throw_at(get_ranged_target_turf(throwTarget, get_dir(T, throwTarget), 3), 3, 4)
	return

/datum/infection/upgrade/turret/shield_creator
	name = "Shield Creator"
	description = "Changes infection where the bullet is hit into shield infection."
	radial_icon_state = "blob_shield_radial"
	cost = 100

/datum/infection/upgrade/turret/shield_creator/projectile_hit(var/obj/structure/infection/turret/T, atom/target)
	var/turf/target_turf = get_turf(target)
	var/obj/structure/infection/I = locate(/obj/structure/infection) in target_turf.contents
	if(I)
		I.change_to(/obj/structure/infection/shield, I.overmind)
	return

/datum/infection/upgrade/turret/spore_bullets
	name = "Spore Bullets"
	description = "Has a chance to create infection spores on the target the bullet hits."
	radial_icon_state = "blobpod"
	cost = 100

/datum/infection/upgrade/turret/spore_bullets/projectile_hit(var/obj/structure/infection/turret/T, atom/target)
	if(prob(80))
		return
	var/mob/living/simple_animal/hostile/infection/infectionspore/IS = new/mob/living/simple_animal/hostile/infection/infectionspore(target.loc, null, T.overmind)
	if(T.overmind)
		IS.update_icons()
		T.overmind.infection_mobs.Add(IS)
	return