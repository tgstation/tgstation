/datum/infection_upgrade
	// display stuff
	var/name = ""
	var/description = ""

	// application
	var/cost = 0
	var/increasing_cost = 0 // the amount the cost increases every time the upgrade is purchased
	var/times = 1 // times the upgrade can be bought
	var/bought = 0 // how many times the upgrade has been bought

/datum/infection_upgrade/proc/do_upgrade(atom/parent)
	times--
	bought++
	cost += increasing_cost
	upgrade_effect(parent)
	return

/datum/infection_upgrade/proc/upgrade_effect(atom/parent)
	return

///////////////////////
// Overmind Upgrades //
///////////////////////

/datum/infection_upgrade/overmind
	var/action_type // action type to unlock and add to the commander (if there is one)

/datum/infection_upgrade/overmind/upgrade_effect(mob/camera/commander/parentcommander)
	var/datum/action/cooldown/infection/add_action = new action_type()
	add_action.Grant(parentcommander)

/datum/infection_upgrade/overmind/turret
	name = "Turret Infection"
	description = "Gives you the ability to create turret infection. These automically target any hostile creatures around them, and have various effects to deal with many types of intruders."
	action_type = /datum/action/cooldown/infection/creator/turret
	cost = 1

/datum/infection_upgrade/overmind/beamturret
	name = "Beam Turret Infection"
	description = "Gives you the ability to create beam turret infection. These automically target and instantly stick to hostile creatures that enter their range."
	action_type = /datum/action/cooldown/infection/creator/beamturret
	cost = 1

/datum/infection_upgrade/overmind/freecam
	name = "Full Vision"
	description = "Allows you to see the entire station with no restrictions on the movement of your camera."
	action_type = /datum/action/cooldown/infection/freecam
	cost = 1

/datum/infection_upgrade/overmind/emppulse
	name = "Electromagnetic Pulse"
	description = "Generates an EMP in an area around your camera. Charges up for a period of time overlaying the area it will EMP before doing so."
	action_type = /datum/action/cooldown/infection/emppulse
	cost = 1

/datum/infection_upgrade/overmind/medical
	name = "Medical Diagnostics System"
	description = "Allows you to see the health of allies and enemies alike, giving you even greater strategical planning power with your forces."
	action_type = /datum/action/cooldown/infection/medicalhud
	cost = 1

///////////////////////////////
// Spore Type Change Upgrades//
///////////////////////////////

/datum/infection_upgrade/spore_type_change
	cost = 200
	var/new_type

/datum/infection_upgrade/spore_type_change/upgrade_effect(mob/living/simple_animal/hostile/infection/infectionspore/sentient/parentspore)
	parentspore.transfer_to_type(new_type)

/datum/infection_upgrade/spore_type_change/myconid_spore
	name = "Myconid Spore"
	description = "Has the capability to pass beacon walls and cause trouble for humans hiding behind them. Can upgrade to be able to grab humans."
	new_type = /mob/living/simple_animal/hostile/infection/infectionspore/sentient/myconid

/datum/infection_upgrade/spore_type_change/infector_spore
	name = "Infector Spore"
	description = "An underboss of the infection. Can upgrade to repair buildings around it, and can create spore possessed humans with dead bodies. "
	new_type = /mob/living/simple_animal/hostile/infection/infectionspore/sentient/infector

/datum/infection_upgrade/spore_type_change/hunter_spore
	name = "Hunter Spore"
	description = "A fast spore with abilities useful for hunting down humans. Works well with myconid spores that can grab humans past the beacon walls."
	new_type = /mob/living/simple_animal/hostile/infection/infectionspore/sentient/hunter

/datum/infection_upgrade/spore_type_change/destructive_spore
	name = "Destructive Spore"
	description = "A generally slow, tanky, and damaging spore useful for destroying structures. Effective for defending and advancing infectious structures."
	new_type = /mob/living/simple_animal/hostile/infection/infectionspore/sentient/destructive

///////////////////////////
// Myconid Spore Upgrades//
///////////////////////////

/datum/infection_upgrade/myconid

////////////////////////////
// Infector Spore Upgrades//
////////////////////////////

/datum/infection_upgrade/infector

//////////////////////////
// Hunter Spore Upgrades//
//////////////////////////

/datum/infection_upgrade/hunter/lifesteal
	name = "Lifesteal"
	description = "Does true damage to living targets by sapping health directly from them as well as healing you."
	cost = 200

/datum/infection_upgrade/hunter/lifesteal/upgrade_effect(atom/parent)
	parent.AddComponent(/datum/component/lifesteal, 5)

///////////////////////////////
// Destructive Spore Upgrades//
///////////////////////////////

/datum/infection_upgrade/destructive/hydraulic_fists
	name = "Hydraulic Fists"
	description = "The compressed fluid in your arms allows you to deal much greater impacts which throw hit objects backward."
	cost = 200

/datum/infection_upgrade/destructive/hydraulic_fists/upgrade_effect(atom/parent)
	parent.AddComponent(/datum/component/knockback, 4)

////////////////////
// Turret Upgrades//
////////////////////

/datum/infection_upgrade/turret/flak_bullets
	name = "Flak Bullets"
	description = "Bullets that hit targets will break into tiny spores that do damage to other living creatures around the target."
	cost = 50

/datum/infection_upgrade/turret/flak_bullets/upgrade_effect(atom/parent)
	parent.AddComponent(/datum/component/shrapnel, /obj/item/projectile/bullet/infection/flak, 2)

/datum/infection_upgrade/turret/armour_penetration
	name = "Armour Penetration"
	description = "Increases the armour penetration of the turret."
	cost = 15
	times = 3

/datum/infection_upgrade/infernal/armour_penetration/upgrade_effect(atom/parent)
	return

//////////////////////
// Resource Upgrades//
//////////////////////

/datum/infection_upgrade/resource/storage_unit
	name = "Storage Unit"
	description = "Increases the point return of this infection every time it produces, up to a maximum of 100 points. You can remove the structure at any time to claim the extra points."
	cost = 100

/datum/infection_upgrade/resource/storage_unit/upgrade_effect(obj/structure/infection/resource/parentresource)
	parentresource.point_return_gain += 0.25
	return

///////////////////
// Node Upgrades///
///////////////////

/datum/infection_upgrade/node/defensive_shield
	name = "Defensive Shield"
	description = "Automatically produces shield infection from all normal infection that are adjacent."
	cost = 50

/datum/infection_upgrade/node/defensive_shield/upgrade_effect(atom/parent)
	return

//////////////////////
// Factory Upgrades///
//////////////////////

/datum/infection_upgrade/factory