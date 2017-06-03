/obj/item/weapon/gun/energy/kinetic_accelerator
	name = "proto-kinetic accelerator"
	desc = "A self recharging, ranged mining tool that does increased damage in low pressure. Capable of holding up to six slots worth of mod kits."
	icon_state = "kineticgun"
	item_state = "kineticgun"
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic)
	cell_type = /obj/item/weapon/stock_parts/cell/emproof
	needs_permit = 0
	unique_rename = 1
	origin_tech = "combat=3;powerstorage=3;engineering=3"
	weapon_weight = WEAPON_LIGHT
	can_flashlight = 1
	flight_x_offset = 15
	flight_y_offset = 9
	var/overheat_time = 16
	var/holds_charge = FALSE
	var/unique_frequency = FALSE // modified by KA modkits
	var/overheat = FALSE
	can_bayonet = TRUE
	knife_x_offset = 15
	knife_y_offset = 13

	var/max_mod_capacity = 100
	var/list/modkits = list()

	var/empty_state = "kineticgun_empty"
	var/recharge_timerid

/obj/item/weapon/gun/energy/kinetic_accelerator/examine(mob/user)
	..()
	if(max_mod_capacity)
		to_chat(user, "<b>[get_remaining_mod_capacity()]%</b> mod capacity remaining.")
		for(var/A in get_modkits())
			var/obj/item/borg/upgrade/modkit/M = A
			to_chat(user, "<span class='notice'>There is a [M.name] mod installed, using <b>[M.cost]%</b> capacity.</span>")

/obj/item/weapon/gun/energy/kinetic_accelerator/attackby(obj/item/A, mob/user)
	if(istype(A, /obj/item/weapon/crowbar))
		if(modkits.len)
			to_chat(user, "<span class='notice'>You pry the modifications out.</span>")
			playsound(loc, A.usesound, 100, 1)
			for(var/obj/item/borg/upgrade/modkit/M in modkits)
				M.uninstall(src)
		else
			to_chat(user, "<span class='notice'>There are no modifications currently installed.</span>")
	else if(istype(A, /obj/item/borg/upgrade/modkit))
		var/obj/item/borg/upgrade/modkit/MK = A
		MK.install(src, user)
	else
		..()

/obj/item/weapon/gun/energy/kinetic_accelerator/proc/get_remaining_mod_capacity()
	var/current_capacity_used = 0
	for(var/A in get_modkits())
		var/obj/item/borg/upgrade/modkit/M = A
		current_capacity_used += M.cost
	return max_mod_capacity - current_capacity_used

/obj/item/weapon/gun/energy/kinetic_accelerator/proc/get_modkits()
	. = list()
	for(var/A in modkits)
		. += A

/obj/item/weapon/gun/energy/kinetic_accelerator/proc/modify_projectile(obj/item/projectile/kinetic/K)
	K.kinetic_gun = src //do something special on-hit, easy!
	for(var/A in get_modkits())
		var/obj/item/borg/upgrade/modkit/M = A
		M.modify_projectile(K)

/obj/item/weapon/gun/energy/kinetic_accelerator/cyborg
	holds_charge = TRUE
	unique_frequency = TRUE
	max_mod_capacity = 80

/obj/item/weapon/gun/energy/kinetic_accelerator/Initialize()
	. = ..()
	if(!holds_charge)
		empty()

/obj/item/weapon/gun/energy/kinetic_accelerator/shoot_live_shot()
	. = ..()
	attempt_reload()

/obj/item/weapon/gun/energy/kinetic_accelerator/equipped(mob/user)
	. = ..()
	if(!can_shoot())
		attempt_reload()

/obj/item/weapon/gun/energy/kinetic_accelerator/dropped()
	. = ..()
	if(!holds_charge)
		// Put it on a delay because moving item from slot to hand
		// calls dropped().
		addtimer(CALLBACK(src, .proc/empty_if_not_held), 2)

/obj/item/weapon/gun/energy/kinetic_accelerator/proc/empty_if_not_held()
	if(!ismob(loc))
		empty()

/obj/item/weapon/gun/energy/kinetic_accelerator/proc/empty()
	cell.use(500)
	update_icon()

/obj/item/weapon/gun/energy/kinetic_accelerator/proc/attempt_reload(recharge_time)
	if(overheat)
		return
	if(!recharge_time)
		recharge_time = overheat_time
	overheat = TRUE

	var/carried = 0
	if(!unique_frequency)
		for(var/obj/item/weapon/gun/energy/kinetic_accelerator/K in loc.GetAllContents())

			carried++

		carried = max(carried, 1)
	else
		carried = 1

	deltimer(recharge_timerid)
	recharge_timerid = addtimer(CALLBACK(src, .proc/reload), recharge_time * carried, TIMER_STOPPABLE)

/obj/item/weapon/gun/energy/kinetic_accelerator/emp_act(severity)
	return

/obj/item/weapon/gun/energy/kinetic_accelerator/proc/reload()
	cell.give(500)
	recharge_newshot(1)
	if(!suppressed)
		playsound(src.loc, 'sound/weapons/kenetic_reload.ogg', 60, 1)
	else
		to_chat(loc, "<span class='warning'>[src] silently charges up.<span>")
	update_icon()
	overheat = FALSE

/obj/item/weapon/gun/energy/kinetic_accelerator/update_icon()
	..()

	if(empty_state && !can_shoot())
		add_overlay(empty_state)

//Casing
/obj/item/ammo_casing/energy/kinetic
	projectile_type = /obj/item/projectile/kinetic
	select_name = "kinetic"
	e_cost = 500
	fire_sound = 'sound/weapons/Kenetic_accel.ogg' // fine spelling there chap

/obj/item/ammo_casing/energy/kinetic/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	..()
	if(loc && istype(loc, /obj/item/weapon/gun/energy/kinetic_accelerator))
		var/obj/item/weapon/gun/energy/kinetic_accelerator/KA = loc
		KA.modify_projectile(BB)

//Projectiles
/obj/item/projectile/kinetic
	name = "kinetic force"
	icon_state = null
	damage = 40
	damage_type = BRUTE
	flag = "bomb"
	range = 3
	log_override = TRUE

	var/pressure_decrease = 0.25
	var/obj/item/weapon/gun/energy/kinetic_accelerator/kinetic_gun

/obj/item/projectile/kinetic/Destroy()
	kinetic_gun = null
	return ..()

/obj/item/projectile/kinetic/prehit(atom/target)
	var/turf/target_turf = get_turf(target)
	if(!isturf(target_turf))
		return
	var/datum/gas_mixture/environment = target_turf.return_air()
	var/pressure = environment.return_pressure()
	if(pressure > 50)
		name = "weakened [name]"
		damage = damage * pressure_decrease
	. = ..()

/obj/item/projectile/kinetic/on_range()
	strike_thing()
	..()

/obj/item/projectile/kinetic/on_hit(atom/target)
	strike_thing(target)
	. = ..()

/obj/item/projectile/kinetic/proc/strike_thing(atom/target)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		target_turf = get_turf(src)
	if(kinetic_gun) //hopefully whoever shot this was not very, very unfortunate.
		for(var/obj/item/borg/upgrade/modkit/M in kinetic_gun.get_modkits())
			M.projectile_strike(src, target_turf, target, kinetic_gun)
	if(ismineralturf(target_turf))
		var/turf/closed/mineral/M = target_turf
		M.gets_drilled(firer)
	var/obj/effect/temp_visual/kinetic_blast/K = new /obj/effect/temp_visual/kinetic_blast(target_turf)
	K.color = color


//Modkits
/obj/item/borg/upgrade/modkit
	name = "kinetic accelerator modification kit"
	desc = "An upgrade for kinetic accelerators."
	icon = 'icons/obj/objects.dmi'
	icon_state = "modkit"
	origin_tech = "programming=2;materials=2;magnets=4"
	w_class = WEIGHT_CLASS_SMALL
	require_module = 1
	module_type = /obj/item/weapon/robot_module/miner
	var/denied_type = null
	var/maximum_of_type = 1
	var/cost = 30
	var/modifier = 1 //For use in any mod kit that has numerical modifiers

/obj/item/borg/upgrade/modkit/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Occupies <b>[cost]%</b> of mod capacity.</span>")

/obj/item/borg/upgrade/modkit/attackby(obj/item/A, mob/user)
	if(istype(A, /obj/item/weapon/gun/energy/kinetic_accelerator) && !issilicon(user))
		install(A, user)
	else
		..()

/obj/item/borg/upgrade/modkit/action(mob/living/silicon/robot/R)
	if(..())
		return

	for(var/obj/item/weapon/gun/energy/kinetic_accelerator/cyborg/H in R.module.modules)
		return install(H, usr)

/obj/item/borg/upgrade/modkit/proc/install(obj/item/weapon/gun/energy/kinetic_accelerator/KA, mob/user)
	. = TRUE
	if(denied_type)
		var/number_of_denied = 0
		for(var/A in KA.get_modkits())
			var/obj/item/borg/upgrade/modkit/M = A
			if(istype(M, denied_type))
				number_of_denied++
			if(number_of_denied >= maximum_of_type)
				. = FALSE
				break
	if(KA.get_remaining_mod_capacity() >= cost)
		if(.)
			if(!user.transferItemToLoc(src, KA))
				return
			to_chat(user, "<span class='notice'>You install the modkit.</span>")
			playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
			KA.modkits += src
		else
			to_chat(user, "<span class='notice'>The modkit you're trying to install would conflict with an already installed modkit. Use a crowbar to remove existing modkits.</span>")
	else
		to_chat(user, "<span class='notice'>You don't have room(<b>[KA.get_remaining_mod_capacity()]%</b> remaining, [cost]% needed) to install this modkit. Use a crowbar to remove existing modkits.</span>")
		. = FALSE

/obj/item/borg/upgrade/modkit/proc/uninstall(obj/item/weapon/gun/energy/kinetic_accelerator/KA)
	forceMove(get_turf(KA))
	KA.modkits -= src

/obj/item/borg/upgrade/modkit/proc/modify_projectile(obj/item/projectile/kinetic/K)

/obj/item/borg/upgrade/modkit/proc/projectile_strike(obj/item/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/weapon/gun/energy/kinetic_accelerator/KA)

//Range
/obj/item/borg/upgrade/modkit/range
	name = "range increase"
	desc = "Increases the range of a kinetic accelerator when installed."
	modifier = 1
	cost = 25

/obj/item/borg/upgrade/modkit/range/modify_projectile(obj/item/projectile/kinetic/K)
	K.range += modifier


//Damage
/obj/item/borg/upgrade/modkit/damage
	name = "damage increase"
	desc = "Increases the damage of kinetic accelerator when installed."
	modifier = 10

/obj/item/borg/upgrade/modkit/damage/modify_projectile(obj/item/projectile/kinetic/K)
	K.damage += modifier


//Cooldown
/obj/item/borg/upgrade/modkit/cooldown
	name = "cooldown decrease"
	desc = "Decreases the cooldown of a kinetic accelerator."
	modifier = 2.5

/obj/item/borg/upgrade/modkit/cooldown/install(obj/item/weapon/gun/energy/kinetic_accelerator/KA, mob/user)
	. = ..()
	if(.)
		KA.overheat_time -= modifier

/obj/item/borg/upgrade/modkit/cooldown/uninstall(obj/item/weapon/gun/energy/kinetic_accelerator/KA)
	KA.overheat_time += modifier
	..()


//AoE blasts
/obj/item/borg/upgrade/modkit/aoe
	modifier = 0
	var/turf_aoe = FALSE
	var/stats_stolen = FALSE

/obj/item/borg/upgrade/modkit/aoe/install(obj/item/weapon/gun/energy/kinetic_accelerator/KA, mob/user)
	. = ..()
	if(.)
		for(var/obj/item/borg/upgrade/modkit/aoe/AOE in KA.modkits) //make sure only one of the aoe modules has values if somebody has multiple
			if(AOE.stats_stolen)
				continue
			modifier += AOE.modifier //take its modifiers
			AOE.modifier = 0
			turf_aoe += AOE.turf_aoe
			AOE.turf_aoe = FALSE
			AOE.stats_stolen = TRUE

/obj/item/borg/upgrade/modkit/aoe/uninstall(obj/item/weapon/gun/energy/kinetic_accelerator/KA)
	..()
	modifier = initial(modifier) //get our modifiers back
	turf_aoe = initial(turf_aoe)
	if(stats_stolen) //if we had our stats stolen, find the stealer and take them from it
		for(var/obj/item/borg/upgrade/modkit/aoe/AOE in KA.modkits)
			if(AOE.stats_stolen)
				continue
			AOE.modifier -= modifier
			AOE.turf_aoe -= turf_aoe
	else //otherwise, reset the stolen stats and have it recalculate
		var/obj/item/borg/upgrade/modkit/aoe/new_stealer
		for(var/obj/item/borg/upgrade/modkit/aoe/AOE in KA.modkits)
			if(!new_stealer)
				new_stealer = AOE //just make the first one a stealer
			AOE.modifier = initial(AOE.modifier)
			AOE.turf_aoe = initial(AOE.turf_aoe)
			AOE.stats_stolen = FALSE
		if(new_stealer) //if there's no stealer, then there's no other aoe modkits
			for(var/obj/item/borg/upgrade/modkit/aoe/AOE in KA.modkits)
				if(AOE != new_stealer)
					new_stealer.modifier += AOE.modifier
					AOE.modifier = 0
					new_stealer.turf_aoe += AOE.turf_aoe
					AOE.turf_aoe = FALSE
					AOE.stats_stolen = TRUE
	stats_stolen = FALSE

/obj/item/borg/upgrade/modkit/aoe/modify_projectile(obj/item/projectile/kinetic/K)
	K.name = "kinetic explosion"

/obj/item/borg/upgrade/modkit/aoe/projectile_strike(obj/item/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/weapon/gun/energy/kinetic_accelerator/KA)
	if(stats_stolen)
		return
	new /obj/effect/temp_visual/explosion/fast(target_turf)
	if(turf_aoe)
		for(var/T in RANGE_TURFS(1, target_turf) - target_turf)
			if(ismineralturf(T))
				var/turf/closed/mineral/M = T
				M.gets_drilled(K.firer)
	if(modifier)
		for(var/mob/living/L in range(1, target_turf) - K.firer - target)
			var/armor = L.run_armor_check(K.def_zone, K.flag, "", "", K.armour_penetration)
			L.apply_damage(K.damage*modifier, K.damage_type, K.def_zone, armor)
			to_chat(L, "<span class='userdanger'>You're struck by a [K.name]!</span>")


/obj/item/borg/upgrade/modkit/aoe/turfs
	name = "mining explosion"
	desc = "Causes the kinetic accelerator to destroy rock in an AoE."
	denied_type = /obj/item/borg/upgrade/modkit/aoe/turfs
	turf_aoe = TRUE

/obj/item/borg/upgrade/modkit/aoe/turfs/andmobs
	name = "offensive mining explosion"
	desc = "Causes the kinetic accelerator to destroy rock and damage mobs in an AoE."
	maximum_of_type = 3
	modifier = 0.25

/obj/item/borg/upgrade/modkit/aoe/mobs
	name = "offensive explosion"
	desc = "Causes the kinetic accelerator to damage mobs in an AoE."
	modifier = 0.2

//Tendril-unique modules
/obj/item/borg/upgrade/modkit/cooldown/repeater
	name = "rapid repeater"
	desc = "Quarters the kinetic accelerator's cooldown on striking a living target, but greatly increases the base cooldown."
	denied_type = /obj/item/borg/upgrade/modkit/cooldown/repeater
	modifier = -14 //Makes the cooldown 3 seconds(with no cooldown mods) if you miss. Don't miss.
	cost = 50

/obj/item/borg/upgrade/modkit/cooldown/repeater/projectile_strike(obj/item/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/weapon/gun/energy/kinetic_accelerator/KA)
	var/valid_repeat = FALSE
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat != DEAD)
			valid_repeat = TRUE
	if(ismineralturf(target_turf))
		valid_repeat = TRUE
	if(valid_repeat)
		KA.overheat = FALSE
	KA.attempt_reload(KA.overheat_time * 0.25) //If you hit, the cooldown drops to 0.75 seconds.

/obj/item/borg/upgrade/modkit/lifesteal
	name = "lifesteal crystal"
	desc = "Causes kinetic accelerator shots to slightly heal the firer on striking a living target."
	icon_state = "modkit_crystal"
	denied_type = /obj/item/borg/upgrade/modkit/lifesteal
	modifier = 2.5 //Not a very effective method of healing.
	cost = 20
	var/static/list/damage_heal_order = list(BRUTE, BURN, OXY)

/obj/item/borg/upgrade/modkit/lifesteal/projectile_strike(obj/item/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/weapon/gun/energy/kinetic_accelerator/KA)
	if(isliving(target) && isliving(K.firer))
		var/mob/living/L = target
		if(L.stat == DEAD)
			return
		L = K.firer
		L.heal_ordered_damage(modifier, damage_heal_order)

/obj/item/borg/upgrade/modkit/resonator_blasts
	name = "resonator blast"
	desc = "Causes kinetic accelerator shots to leave and detonate resonator blasts."
	denied_type = /obj/item/borg/upgrade/modkit/resonator_blasts
	cost = 30
	modifier = 0.25 //A bonus 15 damage if you burst the field on a target, 60 if you lure them into it.

/obj/item/borg/upgrade/modkit/resonator_blasts/projectile_strike(obj/item/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/weapon/gun/energy/kinetic_accelerator/KA)
	if(target_turf && !ismineralturf(target_turf)) //Don't make fields on mineral turfs.
		var/obj/effect/temp_visual/resonance/R = locate(/obj/effect/temp_visual/resonance) in target_turf
		if(R)
			R.damage_multiplier = modifier
			R.burst()
			return
		new /obj/effect/temp_visual/resonance(target_turf, K.firer, null, 30)

//Indoors
/obj/item/borg/upgrade/modkit/indoors
	name = "decrease pressure penalty"
	desc = "A syndicate modification kit that increases the damage a kinetic accelerator does in a high pressure environment."
	modifier = 2
	denied_type = /obj/item/borg/upgrade/modkit/indoors
	maximum_of_type = 2
	cost = 35

/obj/item/borg/upgrade/modkit/indoors/modify_projectile(obj/item/projectile/kinetic/K)
	K.pressure_decrease *= modifier


//Trigger Guard
/obj/item/borg/upgrade/modkit/trigger_guard
	name = "modified trigger guard"
	desc = "Allows creatures normally incapable of firing guns to operate the weapon when installed."
	cost = 20
	denied_type = /obj/item/borg/upgrade/modkit/trigger_guard

/obj/item/borg/upgrade/modkit/trigger_guard/install(obj/item/weapon/gun/energy/kinetic_accelerator/KA, mob/user)
	. = ..()
	if(.)
		KA.trigger_guard = TRIGGER_GUARD_ALLOW_ALL

/obj/item/borg/upgrade/modkit/trigger_guard/uninstall(obj/item/weapon/gun/energy/kinetic_accelerator/KA)
	KA.trigger_guard = TRIGGER_GUARD_NORMAL
	..()


//Cosmetic

/obj/item/borg/upgrade/modkit/chassis_mod
	name = "super chassis"
	desc = "Makes your KA yellow. All the fun of having a more powerful KA without actually having a more powerful KA."
	cost = 0
	denied_type = /obj/item/borg/upgrade/modkit/chassis_mod
	var/chassis_icon = "kineticgun_u"
	var/chassis_name = "super-kinetic accelerator"

/obj/item/borg/upgrade/modkit/chassis_mod/install(obj/item/weapon/gun/energy/kinetic_accelerator/KA, mob/user)
	. = ..()
	if(.)
		KA.icon_state = chassis_icon
		KA.name = chassis_name

/obj/item/borg/upgrade/modkit/chassis_mod/uninstall(obj/item/weapon/gun/energy/kinetic_accelerator/KA)
	KA.icon_state = initial(KA.icon_state)
	KA.name = initial(KA.name)
	..()

/obj/item/borg/upgrade/modkit/chassis_mod/orange
	name = "hyper chassis"
	desc = "Makes your KA orange. All the fun of having explosive blasts without actually having explosive blasts."
	chassis_icon = "kineticgun_h"
	chassis_name = "hyper-kinetic accelerator"

/obj/item/borg/upgrade/modkit/tracer
	name = "white tracer bolts"
	desc = "Causes kinetic accelerator bolts to have a white tracer trail and explosion."
	cost = 0
	denied_type = /obj/item/borg/upgrade/modkit/tracer
	var/bolt_color = "#FFFFFF"

/obj/item/borg/upgrade/modkit/tracer/modify_projectile(obj/item/projectile/kinetic/K)
	K.icon_state = "ka_tracer"
	K.color = bolt_color

/obj/item/borg/upgrade/modkit/tracer/adjustable
	name = "adjustable tracer bolts"
	desc = "Causes kinetic accelerator bolts to have a adjustably-colored tracer trail and explosion. Use in-hand to change color."

/obj/item/borg/upgrade/modkit/tracer/adjustable/attack_self(mob/user)
	bolt_color = input(user,"Choose Color") as color
