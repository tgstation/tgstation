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

/datum/component/infection/upgrade/Initialize()
	. = ..()
	if(bought)
		register_signals()

/datum/component/infection/upgrade/proc/register_signals()
	RegisterSignal(parent, COMSIG_INFECTION_LIFE_TICK, .proc/life_tick)
	RegisterSignal(parent, COMSIG_INFECTION_TAKE_DAMAGE, .proc/take_damage)

/datum/component/infection/upgrade/proc/do_upgrade()
	if(!bought)
		register_signals()
	times--
	bought++
	cost += increasing_cost
	upgrade_effect()
	return

/datum/component/infection/upgrade/proc/upgrade_effect()
	return

/datum/component/infection/upgrade/proc/life_tick(datum/source)
	return

/datum/component/infection/upgrade/proc/take_damage(datum/source)
	return

///////////////////
// Spore Upgrades//
///////////////////

/datum/component/infection/upgrade/spore/register_signals()
	. = ..()
	RegisterSignal(parent, COMSIG_HOSTILE_ATTACKINGTARGET, .proc/attackingtarget)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/moved)

/datum/component/infection/upgrade/spore/proc/attackingtarget(datum/source, var/atom/target)
	return

/datum/component/infection/upgrade/spore/proc/moved(datum/source)
	return

///////////////////////////////
// Spore Type Change Upgrades//
///////////////////////////////

/datum/component/infection/upgrade/spore/type_change
	cost = 200
	var/new_type

/datum/component/infection/upgrade/spore/type_change/upgrade_effect(var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/parentspore = parent)
	parentspore.transfer_to_type(new_type)

/datum/component/infection/upgrade/spore/type_change/myconid_spore
	name = "Myconid Spore"
	description = "Has the capability to pass beacon walls and cause trouble for humans hiding behind them. Can upgrade to be able to grab humans."
	radial_icon_state = "myconid"
	new_type = /mob/living/simple_animal/hostile/infection/infectionspore/sentient/myconid

/datum/component/infection/upgrade/spore/type_change/infector_spore
	name = "Infector Spore"
	description = "An underboss of the infection. Can upgrade to repair buildings around it, and can create spore possessed humans with dead bodies. "
	radial_icon_state = "infector"
	new_type = /mob/living/simple_animal/hostile/infection/infectionspore/sentient/infector

/datum/component/infection/upgrade/spore/type_change/hunter_spore
	name = "Hunter Spore"
	description = "A fast spore with abilities useful for hunting down humans. Works well with myconid spores that can grab humans past the beacon walls."
	radial_icon_state = "hunter"
	new_type = /mob/living/simple_animal/hostile/infection/infectionspore/sentient/hunter

/datum/component/infection/upgrade/spore/type_change/destructive_spore
	name = "Destructive Spore"
	description = "A generally slow, tanky, and damaging spore useful for destroying structures. Effective for defending and advancing infectious structures."
	radial_icon_state = "destructive"
	new_type = /mob/living/simple_animal/hostile/infection/infectionspore/sentient/destructive

///////////////////////////
// Myconid Spore Upgrades//
///////////////////////////


/datum/component/infection/upgrade/spore/pulling
	name = "Suction Cup Fungi"
	description = "Allows you to pull enemies with the amazing ability of lower internal pressure."
	radial_icon_state = "suction"
	cost = 200

/datum/component/infection/upgrade/spore/pulling/upgrade_effect(var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/parentspore = parent)
	parentspore.verbs += /mob/living/verb/pulled

////////////////////////////
// Infector Spore Upgrades//
////////////////////////////

/datum/component/infection/upgrade/spore/zombification
	name = "Zombifying Fluid"
	description = "Allows you to attack dead targets to instantly possess them with a zombified spore."
	radial_icon_state = "blobpod"
	cost = 200

/datum/component/infection/upgrade/spore/zombification/attackingtarget(datum/source, var/atom/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.stat == DEAD)
			var/mob/living/simple_animal/hostile/infection/infectionspore/IS = new /mob/living/simple_animal/hostile/infection/infectionspore(H.loc)
			IS.Zombify(H)

//////////////////////////
// Hunter Spore Upgrades//
//////////////////////////

/datum/component/infection/upgrade/spore/lifesteal
	name = "Lifesteal"
	description = "Does true damage to living targets by sapping health directly from them as well as healing you."
	radial_icon_state = "fire_bullet"
	cost = 200

/datum/component/infection/upgrade/spore/lifesteal/attackingtarget(datum/source, var/atom/target, var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/parentspore = parent)
	if(isliving(target))
		var/mob/living/M = target
		if(M.stat != DEAD)
			var/healedanddamage = 10
			M.apply_damage(healedanddamage)
			parentspore.adjustHealth(-healedanddamage)

///////////////////////////////
// Destructive Spore Upgrades//
///////////////////////////////

/datum/component/infection/upgrade/spore/knockback
	name = "Hydraulic Fists"
	description = "The compressed fluid in your arms allows you to deal much greater impacts which throw hit objects backward."
	radial_icon_state = "blobbernaut"
	cost = 200

/datum/component/infection/upgrade/spore/knockback/attackingtarget(datum/source, var/atom/target, var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/parentspore = parent)
	if(ismovableatom(target))
		var/atom/movable/throwTarget = target
		if(!throwTarget.anchored)
			throwTarget.throw_at(get_ranged_target_turf(throwTarget, get_dir(parentspore, throwTarget), 3), 3, 4)

///////////////////////
// Structure Upgrades//
///////////////////////

/datum/component/infection/upgrade/structure/register_signals()
	. = ..()
	RegisterSignal(parent, COMSIG_INFECTION_PULSED, .proc/pulsed)

/datum/component/infection/upgrade/structure/proc/pulsed()
	return

////////////////////
// Turret Upgrades//
////////////////////

/datum/component/infection/upgrade/structure/turret/register_signals()
	. = ..()
	RegisterSignal(parent, COMSIG_PROJECTILE_BEFORE_FIRE, .proc/before_fire)
	RegisterSignal(parent, COMSIG_PROJECTILE_ON_HIT, .proc/projectile_hit)

/datum/component/infection/upgrade/structure/turret/proc/before_fire(datum/source, obj/item/projectile/A, atom/movable/target)
	return

/datum/component/infection/upgrade/structure/turret/proc/projectile_hit(datum/source, atom/target, blocked)
	return

////////////////////////////////
// Turret Type Change Upgrades//
////////////////////////////////

/datum/component/infection/upgrade/structure/turret/type_change
	cost = 30
	var/new_type
	var/upgrade_wait_time = 0

/datum/component/infection/upgrade/structure/turret/type_change/upgrade_effect(var/obj/structure/infection/turret/parentturret = parent)
	parentturret.change_to(new_type, parentturret.overmind, upgrade_wait_time)

/datum/component/infection/upgrade/structure/turret/type_change/resistant_turret
	name = "Resistant Turret"
	description = "Triples the structural integrity of your turret."
	radial_icon_state = "bullet"
	new_type = /obj/structure/infection/turret/resistant

/datum/component/infection/upgrade/structure/turret/type_change/infernal_turret
	name = "Infernal Turret"
	description = "Increases speed of bullets and changes damage to burn."
	radial_icon_state = "fire_bullet"
	new_type = /obj/structure/infection/turret/infernal

/datum/component/infection/upgrade/structure/turret/type_change/homing_turret
	name = "Homing Turret"
	description = "Shoots spores that have increased range and track their target."
	radial_icon_state = "tracking_bullet"
	new_type = /obj/structure/infection/turret/homing

///////////////////////////
// Homing Turret Upgrades//
///////////////////////////

/datum/component/infection/upgrade/structure/turret/home_target
	name = "Homing Bullets"
	description = "Causes the bullets of this turret to home in on their target."
	times = 0
	bought = 1

/datum/component/infection/upgrade/structure/turret/home_target/before_fire(datum/source, obj/item/projectile/A, atom/movable/target)
	A.set_homing_target(target)

/datum/component/infection/upgrade/structure/turret/turn_speed
	name = "Turn Speed"
	description = "Increases turn speed of shot homing spores."
	radial_icon_state = "tracking_bullet"
	cost = 10
	times = 3

/datum/component/infection/upgrade/structure/turret/turn_speed/before_fire(datum/source, obj/item/projectile/A, atom/movable/target)
	A.homing_turn_speed *= 2 * bought

/datum/component/infection/upgrade/structure/turret/flak_homing
	name = "Flak Homing"
	description = "Homings that hit targets will break into tiny spores that do damage to other living creatures around the target."
	radial_icon_state = "blob_spore_temp"
	cost = 10
	times = 3

/datum/component/infection/upgrade/structure/turret/flak_homing/projectile_hit(datum/source, atom/target)
	for(var/dir in GLOB.cardinals + GLOB.diagonals)
		var/obj/item/projectile/A = new /obj/item/projectile/bullet/infection/flak(target)
		playsound(target, 'sound/weapons/gunshot_smg.ogg', 75, 1)
		A.damage *= bought

		var/turf/newTarget = get_ranged_target_turf(target, dir, A.range)
		A.preparePixelProjectile(newTarget, target)
		if(ismovableatom(target))
			A.firer = target
		A.fire()

/datum/component/infection/upgrade/structure/turret/stamina_damage
	name = "Stamina Damage"
	description = "Homing spores deal only stamina damage, 1.5x damage bonus."
	radial_icon = 'icons/obj/projectiles.dmi'
	radial_icon_state = "omnilaser"
	cost = 10

/datum/component/infection/upgrade/structure/turret/stamina_damage/before_fire(datum/source, obj/item/projectile/A, atom/movable/target)
	A.damage_type = STAMINA
	A.damage *= 1.5

/////////////////////////////
// Infernal Turret Upgrades//
/////////////////////////////

/datum/component/infection/upgrade/structure/turret/burning_spores
	name = "Burning Spores"
	description = "Sets fire to the target on hit."
	radial_icon = 'icons/effects/fire.dmi'
	radial_icon_state = "fire"
	cost = 15

/datum/component/infection/upgrade/structure/turret/burning_spores/projectile_hit(datum/source, atom/target)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(4)
		M.IgniteMob()

/datum/component/infection/upgrade/structure/turret/fire_rate
	name = "Fire Rate"
	description = "Increases the fire rate of the turret."
	radial_icon_state = "fire_bullet"
	cost = 15
	times = 3

/datum/component/infection/upgrade/structure/turret/fire_rate/upgrade_effect(var/obj/structure/infection/turret/parentturret = parent)
	parentturret.frequency++

/datum/component/infection/upgrade/structure/turret/armour_penetration
	name = "Armour Penetration"
	description = "Increases the armour penetration of the turret."
	radial_icon_state = "tracking_bullet"
	cost = 15
	times = 3

/datum/component/infection/upgrade/structure/turret/armour_penetration/before_fire(datum/source, obj/item/projectile/A, atom/movable/target)
	A.armour_penetration += 15 * bought

//////////////////////////////
// Resistant Turret Upgrades//
//////////////////////////////

/datum/component/infection/upgrade/structure/turret/knockback
	name = "Knockback Spores"
	description = "Knocks the target back on hit."
	radial_icon_state = "blobbernaut"
	cost = 10

/datum/component/infection/upgrade/structure/turret/knockback/projectile_hit(datum/source, atom/target, var/obj/structure/infection/turret/parentturret = parent)
	if(ismovableatom(target))
		var/atom/movable/throwTarget = target
		if(!throwTarget.anchored)
			throwTarget.throw_at(get_ranged_target_turf(throwTarget, get_dir(parentturret, throwTarget), 3), 3, 4)

/datum/component/infection/upgrade/structure/turret/shield_creator
	name = "Shield Creator"
	description = "Has a chance to change infection where the bullet is hit into shield infection."
	radial_icon_state = "blob_shield_radial"
	cost = 10

/datum/component/infection/upgrade/structure/turret/shield_creator/projectile_hit(datum/source, atom/target)
	if(prob(90))
		return
	var/turf/target_turf = get_turf(target)
	var/obj/structure/infection/normal/I = locate(/obj/structure/infection/normal) in target_turf.contents
	if(I)
		I.change_to(/obj/structure/infection/shield, I.overmind)

/datum/component/infection/upgrade/structure/turret/spore_bullets
	name = "Spore Bullets"
	description = "Has a chance to create infection spores on the target the bullet hits."
	radial_icon_state = "blobpod"
	cost = 10

/datum/component/infection/upgrade/structure/turret/spore_bullets/projectile_hit(datum/source, atom/target, var/obj/structure/infection/turret/parentturret = parent)
	if(prob(90))
		return
	var/mob/living/simple_animal/hostile/infection/infectionspore/IS = new/mob/living/simple_animal/hostile/infection/infectionspore(target.loc, null, parentturret.overmind)
	if(parentturret.overmind)
		IS.update_icons()
		parentturret.overmind.infection_mobs.Add(IS)

//////////////////////
// Resource Upgrades//
//////////////////////

/datum/component/infection/upgrade/structure/resource/production_rate
	name = "Production Rate"
	description = "Increases the points produced per tick by the resource structure."
	radial_icon_state = "ui_increase"
	cost = 10
	increasing_cost = 10
	times = 3

/datum/component/infection/upgrade/structure/resource/production_rate/upgrade_effect(var/obj/structure/infection/resource/parentresource = parent)
	parentresource.produced++

/datum/component/infection/upgrade/structure/resource/storage_unit
	name = "Storage Unit"
	description = "Increases the point return of this infection every time it produces, up to a maximum of 100 points. You can remove the structure at any time to claim the extra points."
	radial_icon_state = "block2"
	cost = 40

/datum/component/infection/upgrade/structure/resource/storage_unit/life_tick(datum/source, var/obj/structure/infection/resource/parentresource = parent)
	parentresource.point_return = min(parentresource.point_return + 0.2, 100)

//////////////////////
// Factory Upgrades///
//////////////////////

/datum/component/infection/upgrade/structure/factory/royal_guard
	name = "Royal Guard"
	description = "Attempts to produce a spore automatically whenever this structure takes damage. Can only produce 3 more than maximum spores."
	radial_icon_state = "blobpod"
	cost = 10

/datum/component/infection/upgrade/structure/factory/royal_guard/take_damage(datum/source, var/obj/structure/infection/factory/parentfactory = parent)
	if(parentfactory.spores.len >= (parentfactory.max_spores + 3))
		return
	var/mob/living/simple_animal/hostile/infection/infectionspore/IS = new/mob/living/simple_animal/hostile/infection/infectionspore(parentfactory.loc, parentfactory, parentfactory.overmind)
	if(parentfactory.overmind) //if we don't have an overmind, we don't need to do anything but make a spore
		IS.update_icons()
		parentfactory.overmind.infection_mobs.Add(IS)

/datum/component/infection/upgrade/structure/factory/defensive_shield
	name = "Defensive Shield"
	description = "Automatically produces shield infection from all normal infection that are adjacent."
	radial_icon_state = "blob_shield_radial"
	cost = 20

/datum/component/infection/upgrade/structure/factory/defensive_shield/life_tick(datum/source, var/obj/structure/infection/factory/parentfactory = parent)
	for(var/obj/structure/infection/normal/I in range(1, parentfactory))
		if(prob(80))
			continue
		I.change_to(/obj/structure/infection/shield, parentfactory.overmind)