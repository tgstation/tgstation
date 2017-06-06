/datum/gun
	var/name = "guncrafting datum"

	var/gun_name = "prototype energy gun"	//User choosable
	var/gun_name_appends = ""	//Mandatory appends
	var/projectile_name = "prototype energy beam"	//Mandatory
	var/obj/item/weapon/gun/energy/prototype/holder
	var/weapon_weight = 2	//1-2-3-4 Small-Medium-Large-Bulky Pockets-Backpack-BOH-Only_in_suit_storage_or_back for weapon size.
	var/list/obj/item/device/guncrafting/module/modules = list()	//All the modules in the gun
	var/list/obj/item/device/guncrafting/module/trigger/trigger_modules = list()	//Trigger modules
	var/obj/item/device/guncrafting/module/projector/base/projector_base = list()	//Base projectile types
	var/list/obj/item/device/guncrafting/module/projector/mod/projector_modules	= list()	//Projectile effect range modifiers
	var/list/obj/item/device/guncrafting/module/power/power_modules = list()	//Power modules
	var/list/obj/item/device/guncrafting/module/chassis/chassis_modules = list()	//Chassis modules
	var/list/obj/item/device/guncrafting/module/effect/effect_modules = list()	//Effect modules
	var/list/obj/item/device/guncrafting/module/barrel/barrel_modules	= list()	//Barrel modules
	var/list/obj/item/device/guncrafting/module/cosmetic/cosmetic_stackable/cosmetic_modules = list()	//Stackable cosmetic effects
	var/obj/item/device/guncrafting/module/cosmetic/cosmetic_projectile	//Projectile icon
	var/obj/item/device/guncrafting/module/cosmetic/cosmetic_chassis	//Chassis icon
	var/obj/item/device/guncrafting/module/cosmetic/cosmetic_color	//Projectile color
	var/list/obj/item/device/guncrafting/module/other_modules = list()	//Other modules

	var/requires_processing = 0	//Fastprocess?
	var/list/obj/item/device/guncrafting/module/processing_modules = list()	//Modules that need processing
	var/list/obj/item/projectile/prototype/projectiles = list()	//Tracks projectiles

	var/energy_cost = 0	//Running total of energy costs
	var/energy_max = 0	//All power module capacities combined
	var/energy = 0	//Power module energy amounts combined

/datum/gun/proc/process()
	for(var/obj/item/device/guncrafting/module/M in processing_modules)
		M.process()

/datum/gun/proc/can_fire()
	var/energy_needed = energy_cost
	for(var/obj/item/device/guncrafting/module/power/P in power_modules)
		if(energy_needed <= 0)
			return TRUE
		energy_needed -= P.use_power(energy_needed)
	if(!holder.can_fire())
		return FALSE
	return FALSE

/datum/gun/proc/on_fire(atom/target, mob/living/user, params, distro, quiet, zone_override, spread)
	for(var/obj/item/device/guncrafting/module/M in modules)
		if(!M.on_fire(atom/target, mob/living/user, params, distro, quiet, zone_override, spread))
			return FALSE
	return TRUE

/datum/gun/proc/on_range(turf/T)	//Return 1 to override deletion - DONT DO THIS UNLESS ABSOLUTELY NECESSARY
	. = 0
	for(var/obj/item/device/guncrafting/module/M in modules)
		. += M.on_range(T)
	return .

/datum/gun/proc/on_hit(atom/target, blocked)	//Return 0 to override hit effects defaults
	for(var/obj/item/device/guncrafting/module/M in modules)
		M.on_hit(target, blocked)
	. = ..(target, blocked)

/datum/gun/proc/volume()	//volume in percentages
	. = 75
	for(var/obj/item/device/guncrafting/module/M in modules)
		. += M.check_volume()
	return .

/datum/gun/proc/spread()
	. = 0
	. += holder.check_spread()
	for(var/obj/item/device/guncrafting/module/M in modules)
		. += M.check_spread()
	return .

