/datum/component/infection/upgrade
	// display stuff
	var/name = ""
	var/description = ""
	var/radial_icon = 'icons/mob/blob.dmi'
	var/radial_icon_state = ""

	// application
	var/cost = 0
	var/increasing_cost = 0 // the amount the cost increases every time the upgrade is purchased
	var/times = 1 // times the upgrade can be bought
	var/bought = 0 // how many times the upgrade has been bought

/datum/component/infection/upgrade/proc/do_upgrade()
	times--
	bought++
	cost += increasing_cost
	upgrade_effect()
	return

/datum/component/infection/upgrade/proc/upgrade_effect()
	return

/*
//
// Spore Upgrades
//
*/

/datum/component/infection/upgrade/spore
	var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/parentspore
	cost = 1

/datum/component/infection/upgrade/spore/Initialize()
	. = ..()
	parentspore = parent
	RegisterSignal(parentspore, COMSIG_HOSTILE_ATTACKINGTARGET, .proc/check_attackingtarget)
	RegisterSignal(parentspore, COMSIG_MOVABLE_MOVED, .proc/check_moved)

/datum/component/infection/upgrade/spore/proc/check_attackingtarget(datum/source, var/atom/target)
	if(!bought)
		return
	on_attackingtarget(source, target)

/datum/component/infection/upgrade/spore/proc/check_moved()
	if(!bought)
		return
	on_moved()

/datum/component/infection/upgrade/spore/proc/on_attackingtarget(datum/source, var/atom/target)
	return

/datum/component/infection/upgrade/spore/proc/on_moved()
	return

/datum/component/infection/upgrade/spore/myconid_spore
	name = "Myconid Spore"
	description = "Has the capability to pass beacon walls and cause trouble for humans hiding behind them. Can upgrade to be able to grab humans."
	radial_icon_state = "myconid"

/datum/component/infection/upgrade/spore/myconid_spore/upgrade_effect()
	parentspore.transfer_to_type(/mob/living/simple_animal/hostile/infection/infectionspore/sentient/myconid)

/datum/component/infection/upgrade/spore/infector_spore
	name = "Infector Spore"
	description = "An underboss of the infection. Can upgrade to repair buildings around it, and can create spore possessed humans with dead bodies. "
	radial_icon_state = "infector"

/datum/component/infection/upgrade/spore/infector_spore/upgrade_effect()
	parentspore.transfer_to_type(/mob/living/simple_animal/hostile/infection/infectionspore/sentient/infector)

/datum/component/infection/upgrade/spore/hunter_spore
	name = "Hunter Spore"
	description = "A fast spore with abilities useful for hunting down humans. Works well with myconid spores that can grab humans past the beacon walls."
	radial_icon_state = "hunter"

/datum/component/infection/upgrade/spore/hunter_spore/upgrade_effect()
	parentspore.transfer_to_type(/mob/living/simple_animal/hostile/infection/infectionspore/sentient/hunter)

/datum/component/infection/upgrade/spore/destructive_spore
	name = "Destructive Spore"
	description = "A generally slow, tanky, and damaging spore useful for destroying structures. Effective for defending and advancing infectious structures."
	radial_icon_state = "destructive"

/datum/component/infection/upgrade/spore/destructive_spore/upgrade_effect()
	parentspore.transfer_to_type(/mob/living/simple_animal/hostile/infection/infectionspore/sentient/destructive)

/*
//
// Myconid Spore Upgrades
//
*/


/datum/component/infection/upgrade/spore/pulling
	name = "Suction Cup Fungi"
	description = "Allows you to pull enemies with the amazing ability of lower internal pressure."
	radial_icon_state = "suction"

/datum/component/infection/upgrade/spore/pulling/upgrade_effect()
	parentspore.verbs += /mob/living/verb/pulled

/*
//
// Infector Spore Upgrades
//
*/

/datum/component/infection/upgrade/spore/zombification
	name = "Zombifying Fluid"
	description = "Allows you to attack dead targets to instantly possess them with a zombified spore."
	radial_icon_state = "blobpod"

/datum/component/infection/upgrade/spore/zombification/on_attackingtarget(datum/source, var/atom/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.stat == DEAD)
			var/mob/living/simple_animal/hostile/infection/infectionspore/IS = new /mob/living/simple_animal/hostile/infection/infectionspore(H.loc)
			IS.Zombify(H)

/*
//
// Hunter Spore Upgrades
//
*/

/datum/component/infection/upgrade/spore/lifesteal
	name = "Lifesteal"
	description = "Does true damage to living targets by sapping health directly from them as well as healing you."
	radial_icon_state = "fire_bullet"

/datum/component/infection/upgrade/spore/lifesteal/on_attackingtarget(datum/source, var/atom/target)
	if(isliving(target))
		var/mob/living/M = target
		if(M.stat != DEAD)
			var/healedanddamage = 10
			M.apply_damage(healedanddamage)
			parentspore.adjustHealth(-healedanddamage)

/*
//
// Destructive Spore Upgrades
//
*/

/datum/component/infection/upgrade/spore/knockback
	name = "Hydraulic Fists"
	description = "The compressed fluid in your arms allows you to deal much greater impacts which throw hit objects backward."
	radial_icon_state = "blobbernaut"

/datum/component/infection/upgrade/spore/knockback/on_attackingtarget(datum/source, var/atom/target)
	if(ismovableatom(target))
		var/atom/movable/throwTarget = target
		if(!throwTarget.anchored)
			throwTarget.throw_at(get_ranged_target_turf(throwTarget, get_dir(parentspore, throwTarget), 3), 3, 4)

/*
//
// Turret Upgrades
//
*/

/datum/component/infection/upgrade/turret
	var/obj/structure/infection/turret/parentturret

/datum/component/infection/upgrade/turret/Initialize()
	. = ..()
	parentturret = parent
	RegisterSignal(parentturret, COMSIG_PROJECTILE_BEFORE_FIRE, .proc/check_before_fire)
	RegisterSignal(parentturret, COMSIG_PROJECTILE_ON_HIT, .proc/check_projectile_hit)

/datum/component/infection/upgrade/turret/proc/check_before_fire(datum/source, obj/item/projectile/A, atom/movable/target)
	if(!bought)
		return
	on_before_fire(source, A, target)

/datum/component/infection/upgrade/turret/proc/check_projectile_hit(datum/source, atom/target, blocked)
	if(!bought)
		return
	on_projectile_hit(source, target, blocked)

/datum/component/infection/upgrade/turret/proc/on_before_fire(datum/source, obj/item/projectile/A, atom/movable/target)
	return

/datum/component/infection/upgrade/turret/proc/on_projectile_hit(datum/source, atom/target, blocked)
	return

/datum/component/infection/upgrade/turret/resistant_turret
	name = "Resistant Turret"
	description = "Triples the structural integrity of your turret."
	radial_icon_state = "bullet"
	cost = 70

/datum/component/infection/upgrade/turret/resistant_turret/upgrade_effect()
	parentturret.change_to(/obj/structure/infection/turret/resistant, parentturret.overmind)

/datum/component/infection/upgrade/turret/infernal_turret
	name = "Infernal Turret"
	description = "Increases speed of bullets and changes damage to burn."
	radial_icon_state = "fire_bullet"
	cost = 70

/datum/component/infection/upgrade/turret/infernal_turret/upgrade_effect()
	parentturret.change_to(/obj/structure/infection/turret/infernal, parentturret.overmind)

/datum/component/infection/upgrade/turret/homing_turret
	name = "Homing Turret"
	description = "Shoots spores that have increased range and track their target."
	radial_icon_state = "tracking_bullet"
	cost = 70

/datum/component/infection/upgrade/turret/homing_turret/upgrade_effect()
	parentturret.change_to(/obj/structure/infection/turret/homing, parentturret.overmind)

/*
//
// Homing Turret Upgrades
//
*/

/datum/component/infection/upgrade/turret/home_target
	times = 0
	bought = 1

/datum/component/infection/upgrade/turret/home_target/on_before_fire(datum/source, obj/item/projectile/A, atom/movable/target)
	A.set_homing_target(target)

/datum/component/infection/upgrade/turret/turn_speed
	name = "Turn Speed"
	description = "Increases turn speed of shot homing spores."
	radial_icon_state = "tracking_bullet"
	cost = 60
	times = 3

/datum/component/infection/upgrade/turret/turn_speed/on_before_fire(datum/source, obj/item/projectile/A, atom/movable/target)
	A.homing_turn_speed *= 2 * bought

/datum/component/infection/upgrade/turret/flak_homing
	name = "Flak Homing"
	description = "Homings that hit targets will break into tiny spores that do damage to other living creatures around the target."
	radial_icon_state = "blob_spore_temp"
	cost = 60
	times = 3

/datum/component/infection/upgrade/turret/flak_homing/on_projectile_hit(datum/source, atom/target)
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

/datum/component/infection/upgrade/turret/stamina_damage
	name = "Stamina Damage"
	description = "Homing spores deal only stamina damage, 1.5x damage bonus."
	radial_icon = 'icons/obj/projectiles.dmi'
	radial_icon_state = "omnilaser"
	cost = 60

/datum/component/infection/upgrade/turret/stamina_damage/on_before_fire(datum/source, obj/item/projectile/A, atom/movable/target)
	A.damage_type = STAMINA
	A.damage *= 1.5

/*
//
// Infernal Turret Upgrades
//
*/

/datum/component/infection/upgrade/turret/burning_spores
	name = "Burning Spores"
	description = "Sets fire to the target on hit."
	radial_icon = 'icons/effects/fire.dmi'
	radial_icon_state = "fire"
	cost = 100

/datum/component/infection/upgrade/turret/burning_spores/on_projectile_hit(datum/source, atom/target)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(4)
		M.IgniteMob()

/datum/component/infection/upgrade/turret/fire_rate
	name = "Fire Rate"
	description = "Increases the fire rate of the turret."
	radial_icon_state = "fire_bullet"
	cost = 100
	times = 3

/datum/component/infection/upgrade/turret/fire_rate/upgrade_effect()
	parentturret.frequency++

/datum/component/infection/upgrade/turret/armour_penetration
	name = "Armour Penetration"
	description = "Increases the armour penetration of the turret."
	radial_icon_state = "tracking_bullet"
	cost = 50
	times = 3

/datum/component/infection/upgrade/turret/armour_penetration/on_before_fire(datum/source, obj/item/projectile/A, atom/movable/target)
	A.armour_penetration += 15 * bought

/*
//
// Resistant Turret Upgrades
//
*/

/datum/component/infection/upgrade/turret/knockback
	name = "Knockback Spores"
	description = "Knocks the target back on hit."
	radial_icon_state = "blobbernaut"
	cost = 100

/datum/component/infection/upgrade/turret/knockback/on_projectile_hit(datum/source, atom/target)
	if(ismovableatom(target))
		var/atom/movable/throwTarget = target
		if(!throwTarget.anchored)
			throwTarget.throw_at(get_ranged_target_turf(throwTarget, get_dir(parentturret, throwTarget), 3), 3, 4)

/datum/component/infection/upgrade/turret/shield_creator
	name = "Shield Creator"
	description = "Changes infection where the bullet is hit into shield infection."
	radial_icon_state = "blob_shield_radial"
	cost = 100

/datum/component/infection/upgrade/turret/shield_creator/on_projectile_hit(datum/source, atom/target)
	if(prob(80))
		return
	var/turf/target_turf = get_turf(target)
	var/obj/structure/infection/normal/I = locate(/obj/structure/infection/normal) in target_turf.contents
	if(I)
		I.change_to(/obj/structure/infection/shield, I.overmind)

/datum/component/infection/upgrade/turret/spore_bullets
	name = "Spore Bullets"
	description = "Has a chance to create infection spores on the target the bullet hits."
	radial_icon_state = "blobpod"
	cost = 100

/datum/component/infection/upgrade/turret/spore_bullets/on_projectile_hit(datum/source, atom/target)
	if(prob(80))
		return
	var/mob/living/simple_animal/hostile/infection/infectionspore/IS = new/mob/living/simple_animal/hostile/infection/infectionspore(target.loc, null, parentturret.overmind)
	if(parentturret.overmind)
		IS.update_icons()
		parentturret.overmind.infection_mobs.Add(IS)