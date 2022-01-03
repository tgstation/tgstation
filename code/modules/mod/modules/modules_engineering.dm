//Engineering modules for MODsuits

//Welding Protection

/obj/item/mod/module/welding
	name = "MOD welding protection module"
	desc = "A module installed into the visor of the suit, this projects a \
		polarized, holographic overlay in front of the user's eyes. It's rated high enough for \
		immunity against extremities such as spot and arc welding, solar eclipses, and handheld flashlights."
	icon_state = "welding"
	complexity = 1
	incompatible_modules = list(/obj/item/mod/module/welding)
	overlay_state_inactive = "module_welding"

/obj/item/mod/module/welding/on_suit_activation()
	mod.helmet.flash_protect = FLASH_PROTECTION_WELDER

/obj/item/mod/module/welding/on_suit_deactivation()
	mod.helmet.flash_protect = initial(mod.helmet.flash_protect)

//T-Ray Scan

/obj/item/mod/module/t_ray
	name = "MOD t-ray scan module"
	desc = "A module installed into the visor of the suit, allowing the user to use a pulse of terahertz radiation \
		to essentially echolocate things beneath the floor, mostly cables and pipes. \
		A staple of atmospherics work, and counter-smuggling work."
	icon_state = "tray"
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = DEFAULT_CELL_DRAIN * 0.2
	incompatible_modules = list(/obj/item/mod/module/t_ray)
	cooldown_time = 0.5 SECONDS
	var/range = 2

/obj/item/mod/module/t_ray/on_active_process(delta_time)
	t_ray_scan(mod.wearer, 8, range)

//Magnetic Stability

/obj/item/mod/module/magboot
	name = "MOD magnetic stability module"
	desc = "These are powerful electromagnets fitted into the suit's boots, allowing users both \
		excellent traction no matter the condition indoors, and to essentially hitch a ride on the exterior of a hull. \
		However, these basic models do not feature computerized systems to automatically toggle them on and off, \
		so numerous users report a certain stickiness to their steps."
	icon_state = "magnet"
	module_type = MODULE_TOGGLE
	complexity = 2
	active_power_cost = DEFAULT_CELL_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/magboot, /obj/item/mod/module/atrocinator)
	cooldown_time = 0.5 SECONDS
	var/slowdown_active = 0.5

/obj/item/mod/module/magboot/on_activation()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(mod.wearer, TRAIT_NEGATES_GRAVITY, MOD_TRAIT)
	ADD_TRAIT(mod.wearer, TRAIT_NOSLIPWATER, MOD_TRAIT)
	mod.slowdown += slowdown_active
	mod.wearer.update_gravity(mod.wearer.has_gravity())
	mod.wearer.update_equipment_speed_mods()

/obj/item/mod/module/magboot/on_deactivation()
	. = ..()
	if(!.)
		return
	REMOVE_TRAIT(mod.wearer, TRAIT_NEGATES_GRAVITY, MOD_TRAIT)
	REMOVE_TRAIT(mod.wearer, TRAIT_NOSLIPWATER, MOD_TRAIT)
	mod.slowdown -= slowdown_active
	mod.wearer.update_gravity(mod.wearer.has_gravity())
	mod.wearer.update_equipment_speed_mods()

/obj/item/mod/module/magboot/advanced
	name = "MOD advanced magnetic stability module"
	removable = FALSE
	complexity = 0
	slowdown_active = 0

//Emergency Tether

/obj/item/mod/module/tether
	name = "MOD emergency tether module"
	desc = "A custom-built grappling-hook powered by a winch capable of hauling the user. \
		While some older models of cargo-oriented grapples have capacities of a few tons, \
		these are only capable of working in zero-gravity environments, a blessing to some Engineers."
	icon_state = "tether"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_power_cost = DEFAULT_CELL_DRAIN
	incompatible_modules = list(/obj/item/mod/module/tether)
	cooldown_time = 1.5 SECONDS

/obj/item/mod/module/tether/on_use()
	if(mod.wearer.has_gravity(get_turf(src)))
		balloon_alert(mod.wearer, "too much gravity!")
		playsound(src, 'sound/weapons/gun/general/dry_fire.ogg', 25, TRUE)
		return FALSE
	return ..()

/obj/item/mod/module/tether/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/obj/projectile/tether = new /obj/projectile/tether(mod.wearer.loc)
	tether.preparePixelProjectile(target, mod.wearer)
	tether.firer = mod.wearer
	INVOKE_ASYNC(tether, /obj/projectile.proc/fire)
	drain_power(use_power_cost)

/obj/projectile/tether
	name = "tether"
	icon_state = "tether_projectile"
	icon = 'icons/obj/mod.dmi'
	pass_flags = PASSTABLE
	damage = 0
	nodamage = TRUE
	range = 10
	hitsound = 'sound/weapons/batonextend.ogg'
	hitsound_wall = 'sound/weapons/batonextend.ogg'
	suppressed = SUPPRESSED_VERY
	hit_threshhold = LATTICE_LAYER
	var/line

/obj/projectile/tether/fire(setAngle)
	if(firer)
		line = firer.Beam(src, "line", 'icons/obj/mod.dmi')
	..()

/obj/projectile/tether/on_hit(atom/target)
	. = ..()
	if(firer)
		firer.throw_at(target, 10, 1, firer, FALSE, FALSE, null, MOVE_FORCE_NORMAL, TRUE)

/obj/projectile/tether/Destroy()
	QDEL_NULL(line)
	return ..()

//Radiation Protection

/obj/item/mod/module/rad_protection
	name = "MOD radiation protection module"
	desc = "A module utilizing polymers and reflective shielding to protect the user against ionizing radiation; \
		a common danger in space. This comes with software to notify the wearer that they're even in a radioactive area, \
		giving a voice to an otherwise silent killer."
	icon_state = "radshield"
	complexity = 2
	idle_power_cost = DEFAULT_CELL_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/rad_protection)
	tgui_id = "rad_counter"
	var/perceived_threat_level

/obj/item/mod/module/rad_protection/on_suit_activation()
	AddComponent(/datum/component/geiger_sound)
	ADD_TRAIT(mod.wearer, TRAIT_BYPASS_EARLY_IRRADIATED_CHECK, MOD_TRAIT)
	RegisterSignal(mod.wearer, COMSIG_IN_RANGE_OF_IRRADIATION, .proc/on_pre_potential_irradiation)
	for(var/obj/item/part in mod.mod_parts)
		ADD_TRAIT(part, TRAIT_RADIATION_PROTECTED_CLOTHING, MOD_TRAIT)

/obj/item/mod/module/rad_protection/on_suit_deactivation()
	qdel(GetComponent(/datum/component/geiger_sound))
	REMOVE_TRAIT(mod.wearer, TRAIT_BYPASS_EARLY_IRRADIATED_CHECK, MOD_TRAIT)
	UnregisterSignal(mod.wearer, COMSIG_IN_RANGE_OF_IRRADIATION)
	for(var/obj/item/part in mod.mod_parts)
		REMOVE_TRAIT(part, TRAIT_RADIATION_PROTECTED_CLOTHING, MOD_TRAIT)

/obj/item/mod/module/rad_protection/add_ui_data()
	. = ..()
	.["userradiated"] = mod.wearer ? HAS_TRAIT(mod.wearer, TRAIT_IRRADIATED) : 0
	.["usertoxins"] = mod.wearer ? mod.wearer.getToxLoss() : 0
	.["threatlevel"] = perceived_threat_level

/obj/item/mod/module/rad_protection/proc/on_pre_potential_irradiation(datum/source, datum/radiation_pulse_information/pulse_information, insulation_to_target)
	SIGNAL_HANDLER

	perceived_threat_level = get_perceived_radiation_danger(pulse_information, insulation_to_target)
	addtimer(VARSET_CALLBACK(src, perceived_threat_level, null), TIME_WITHOUT_RADIATION_BEFORE_RESET, TIMER_UNIQUE | TIMER_OVERRIDE)

//Constructor

/obj/item/mod/module/constructor
	name = "MOD constructor module"
	desc = "This module entirely occupies the wearer's forearm, notably causing conflict with \
		advanced arm servos meant to carry crewmembers. However, it functions as an \
		extremely advanced construction hologram scanner, as well as containing the \
		latest engineering schematics combined with inbuilt memory to help the user build walls."
	icon_state = "constructor"
	module_type = MODULE_USABLE
	complexity = 2
	idle_power_cost = DEFAULT_CELL_DRAIN * 0.2
	use_power_cost = DEFAULT_CELL_DRAIN * 2
	incompatible_modules = list(/obj/item/mod/module/constructor, /obj/item/mod/module/quick_carry)
	cooldown_time = 11 SECONDS

/obj/item/mod/module/constructor/on_suit_activation()
	ADD_TRAIT(mod.wearer, TRAIT_QUICK_BUILD, MOD_TRAIT)

/obj/item/mod/module/constructor/on_suit_deactivation()
	REMOVE_TRAIT(mod.wearer, TRAIT_QUICK_BUILD, MOD_TRAIT)

/obj/item/mod/module/constructor/on_use()
	. = ..()
	if(!.)
		return
	rcd_scan(src, fade_time = 10 SECONDS)
	drain_power(use_power_cost)

//Kinesis

/obj/item/mod/module/kinesis //TODO POST-MERGE MAKE NOT SUCK ASS, MAKE BALLER AS FUCK
	name = "MOD kinesis module"
	desc = "A modular plug-in to the forearm, this module was presumed lost for many years, \
		despite the suits it used to be mounted on still seeing some circulation. \
		This piece of technology allows the user to generate precise anti-gravity fields, \
		letting them move objects as small as a titanium rod to as large as industrial machinery. \
		Oddly enough, it doesn't seem to work on living creatures."
	icon_state = "kinesis"
//	module_type = MODULE_ACTIVE
	module_type = MODULE_TOGGLE
//	complexity = 3
	complexity = 0
	active_power_cost = DEFAULT_CELL_DRAIN*0.75
//	use_power_cost = DEFAULT_CELL_DRAIN*3
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/kinesis)
	cooldown_time = 0.5 SECONDS
	overlay_state_inactive = "module_kinesis"
	var/has_tk = FALSE

/obj/item/mod/module/kinesis/on_activation()
	. = ..()
	if(!.)
		return
	if(mod.wearer.dna.check_mutation(TK))
		has_tk = TRUE
		return
	mod.wearer.dna.add_mutation(TK_MOD)

/obj/item/mod/module/kinesis/on_deactivation()
	. = ..()
	if(!.)
		return
	if(has_tk)
		has_tk = FALSE
		return
	mod.wearer.dna.remove_mutation(TK_MOD)
