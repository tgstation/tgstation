/*
	Datums that store the things that upgrades do as well as the information on them
*/

/datum/infection_upgrade
	// name of the upgrade
	var/name = ""
	// description of the upgrade
	var/description = ""

	// cost of the upgrade
	var/cost = 0
	// cost that increases every time the upgrade is purchased
	var/increasing_cost = 0
	// the amount of times that this upgrade can actually be bought
	var/times = 1
	// the amount of times this upgrade has been bought already
	var/bought = 0

/*
	Handles pre-upgrade incrementing
*/
/datum/infection_upgrade/proc/do_upgrade(atom/parent)
	times--
	bought++
	cost += increasing_cost
	upgrade_effect(parent)
	return

/*
	Actual place to put your upgrade code
*/
/datum/infection_upgrade/proc/upgrade_effect(atom/parent)
	return

///////////////////////
// Overmind Upgrades //
///////////////////////

/datum/infection_upgrade/overmind
	// action type to unlock and add to the commander (if there is one)
	var/action_type

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

/datum/infection_upgrade/overmind/reflective
	name = "Reflective Shield Infection"
	description = "Gives you the ability to create reflective shield infection. These reflect projectiles back at whatever sent them."
	action_type = /datum/action/cooldown/infection/creator/reflective
	cost = 1

/datum/infection_upgrade/overmind/vacuum
	name = "Vacuum Infection"
	description = "Gives you the ability to create vacuum infection. Vacuum infection automatically suck in any non-infectious objects, and damage them once they are on top."
	action_type = /datum/action/cooldown/infection/creator/vacuum
	cost = 1

/datum/infection_upgrade/overmind/barrier
	name = "Barrier Infection"
	description = "Gives you the ability to create barrier infection. These allow infectious creatures to pull objects through them unlike normal walls."
	action_type = /datum/action/cooldown/infection/creator/barrier
	cost = 1

/datum/infection_upgrade/overmind/medical
	name = "Medical Diagnostics System"
	description = "Allows you to see the health of allies and enemies alike, giving you even greater strategical planning power with your forces."
	cost = 1

/datum/infection_upgrade/overmind/medical/upgrade_effect(mob/camera/commander/parentcommander)
	parentcommander.toggle_medical_hud()

/datum/infection_upgrade/overmind/createslime
	name = "Create Evolving Slime"
	description = "Attempts to create an evolving slime for your army."
	cost = 1
	times = 10

/datum/infection_upgrade/overmind/createslime/upgrade_effect(mob/camera/commander/parentcommander)
	if(!parentcommander.create_spore())
		times++

/*
	Type change spore upgrades, turns the upgrader into the mob type that corresponds to that upgrade
*/

/datum/infection_upgrade/spore_type_change
	cost = 200
	// the type that the spore will change into
	var/new_type

/datum/infection_upgrade/spore_type_change/upgrade_effect(mob/living/simple_animal/hostile/infection/infectionspore/sentient/parentspore)
	parentspore.transfer_to_type(new_type)

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

/*
	Upgrade exclusively for the infection spore type
*/

/datum/infection_upgrade/infector/mininode
	name = "Miniature Node"
	description = "Allows you to place down a miniature node that lasts a short time, but expands infection around it like a true node. Comes with normal construction time."
	cost = 1000

/datum/infection_upgrade/infector/mininode/upgrade_effect(mob/living/simple_animal/hostile/infection/infectionspore/sentient/infector/parentinfector)
	var/datum/action/cooldown/infection/add_action = new /datum/action/cooldown/infection/mininode()
	add_action.Grant(parentinfector)

/datum/infection_upgrade/infector/reflective
	name = "Reflective Shield"
	description = "Somewhere being attacked? Grants you the ability to create a reflective shield. Comes with normal construction time."
	cost = 600

/datum/infection_upgrade/infector/reflective/upgrade_effect(mob/living/simple_animal/hostile/infection/infectionspore/sentient/infector/parentinfector)
	var/datum/action/cooldown/infection/add_action = new /datum/action/cooldown/infection/reflective()
	add_action.Grant(parentinfector)

/datum/infection_upgrade/infector/spacewalk
	name = "Compressed Air Storage"
	description = "The stored air in your body allows you to move anywhere, including space, with ease."
	cost = 200

/datum/infection_upgrade/infector/spacewalk/upgrade_effect(mob/living/simple_animal/hostile/infection/infectionspore/sentient/infector/parentinfector)
	parentinfector.spacewalk = TRUE

/datum/infection_upgrade/infector/respawn_time
	name = "Reduce Respawn Time"
	description = "Slightly reduces respawn time."
	cost = 50
	increasing_cost = 25
	times = 5

/datum/infection_upgrade/infector/respawn_time/upgrade_effect(mob/living/simple_animal/hostile/infection/infectionspore/sentient/infector/parentinfector)
	parentinfector.respawn_time -= 6

/*
	Upgrade exclusively for the hunter spore type
*/

/datum/infection_upgrade/hunter/lifesteal
	name = "Lifesteal"
	description = "Does true damage to living targets by sapping health directly from them as well as healing you."
	cost = 600

/datum/infection_upgrade/hunter/lifesteal/upgrade_effect(atom/parent)
	parent.AddComponent(/datum/component/lifesteal, 10)

/datum/infection_upgrade/hunter/napalm
	name = "Burning Fists"
	description = "Your body now produces fluid which allows you to increasingly set on fire targets that you hit."
	cost = 200

/datum/infection_upgrade/hunter/napalm/upgrade_effect(atom/parent)
	parent.AddComponent(/datum/component/igniter, 1)

/datum/infection_upgrade/hunter/flash
	name = "Bright Flash"
	description = "Gain the ability to create bright flashes of light around you that can disorient opponents without protection."
	cost = 200

/datum/infection_upgrade/hunter/flash/upgrade_effect(mob/living/simple_animal/hostile/infection/infectionspore/sentient/hunter/parenthunter)
	var/datum/action/cooldown/infection/add_action = new /datum/action/cooldown/infection/flash()
	add_action.Grant(parenthunter)

/datum/infection_upgrade/hunter/speed
	name = "Speed Boost"
	description = "Move faster than your foes can run away."
	cost = 100
	increasing_cost = 50
	times = 5

/datum/infection_upgrade/hunter/speed/upgrade_effect(mob/living/simple_animal/hostile/infection/infectionspore/sentient/hunter/parenthunter)
	parenthunter.set_varspeed(-0.1 * bought)

/datum/infection_upgrade/hunter/damage
	name = "Damage Increase"
	description = "Gain the strength to take down your foes."
	cost = 50
	increasing_cost = 50
	times = 5

/datum/infection_upgrade/hunter/damage/upgrade_effect(mob/living/simple_animal/hostile/infection/infectionspore/sentient/hunter/parenthunter)
	parenthunter.melee_damage_lower += 4
	parenthunter.melee_damage_upper += 4

/*
	Upgrades exclusively for the destructive spore type
*/

/datum/infection_upgrade/destructive/hydraulic_fists
	name = "Hydraulic Fists"
	description = "The compressed fluid in your arms allows you to deal much greater impacts which throw hit objects backward."
	cost = 600

/datum/infection_upgrade/destructive/hydraulic_fists/upgrade_effect(atom/parent)
	parent.AddComponent(/datum/component/knockback, 4)

/datum/infection_upgrade/destructive/lead
	name = "Lead Muscles"
	description = "The muscles in your body are converted to a lead based substance, causing you to be almost impossible to move, and making you able to move many things."
	cost = 200

/datum/infection_upgrade/destructive/lead/upgrade_effect(mob/living/simple_animal/hostile/infection/infectionspore/sentient/destructive/parentdestructive)
	parentdestructive.move_force = MOVE_FORCE_EXTREMELY_STRONG
	parentdestructive.move_resist = MOVE_FORCE_EXTREMELY_STRONG
	parentdestructive.pull_force = MOVE_FORCE_EXTREMELY_STRONG

/datum/infection_upgrade/destructive/health
	name = "Health Boost"
	description = "Sustain more damage before having to reform."
	cost = 50
	increasing_cost = 50
	times = 6

/datum/infection_upgrade/destructive/health/upgrade_effect(mob/living/simple_animal/hostile/infection/infectionspore/sentient/destructive/parentdestructive)
	parentdestructive.maxHealth += 10

/datum/infection_upgrade/destructive/burn_protection
	name = "Burn Protection"
	description = "Take less burn damage."
	cost = 50
	increasing_cost = 50
	times = 5

/datum/infection_upgrade/destructive/burn_protection/upgrade_effect(mob/living/simple_animal/hostile/infection/infectionspore/sentient/destructive/parentdestructive)
	parentdestructive.damage_coeff[BURN] -= 0.1

/datum/infection_upgrade/destructive/brute_protection
	name = "Brute Protection"
	description = "Take less brute damage."
	cost = 50
	increasing_cost = 50
	times = 5

/datum/infection_upgrade/destructive/brute_protection/upgrade_effect(mob/living/simple_animal/hostile/infection/infectionspore/sentient/destructive/parentdestructive)
	parentdestructive.damage_coeff[BRUTE] -= 0.1

/*
	Upgrade types for the infection turrets
*/

/datum/infection_upgrade/turret/flak_bullets
	name = "Flak Bullets"
	description = "Bullets that hit targets will break into tiny spores that do damage to other living creatures around the target."
	cost = 50

/datum/infection_upgrade/turret/flak_bullets/upgrade_effect(atom/parent)
	parent.AddComponent(/datum/component/shrapnel, /obj/item/projectile/bullet/infection/flak, 2)

/*
	Upgrade types for the infection resource generators
*/

/datum/infection_upgrade/resource/storage_unit
	name = "Storage Unit"
	description = "Increases the point return of this infection every time it produces, up to a maximum of 100 points. You can remove the structure at any time to claim the extra points."
	cost = 80

/datum/infection_upgrade/resource/storage_unit/upgrade_effect(obj/structure/infection/resource/parentresource)
	parentresource.point_return_gain += 0.25
	return

/*
	Upgrade types for the infection nodes
*/

/datum/infection_upgrade/node/defensive_shield
	name = "Defensive Shield"
	description = "Automatically produces shield infection from all normal infection that are adjacent."
	cost = 50

/datum/infection_upgrade/node/defensive_shield/upgrade_effect(obj/structure/infection/node/parentnode)
	parentnode.shield_creation = TRUE
	return

/datum/infection_upgrade/node/range
	name = "Expansion Range"
	description = "Increases the expansion range of the node."
	cost = 50
	times = 3

/datum/infection_upgrade/node/range/upgrade_effect(obj/structure/infection/node/parentnode)
	parentnode.expansion_range += 2
	return

/datum/infection_upgrade/node/amount
	name = "Expansion Increase"
	description = "Makes the node expand more infecton whenever it fires."
	cost = 50
	times = 3

/datum/infection_upgrade/node/amount/upgrade_effect(obj/structure/infection/node/parentnode)
	parentnode.expansion_amount += 4
	return

/*
	Upgrade types for the infection factories
*/

/datum/infection_upgrade/factory

/*
	Upgrade types for the infection beam turrets
*/

/datum/infection_upgrade/beamturret

/*
	Upgrade types for the infection vacuums
*/

/datum/infection_upgrade/vacuum
