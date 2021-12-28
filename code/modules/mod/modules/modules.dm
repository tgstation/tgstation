/obj/item/mod/module/storage
	name = "MOD storage module"
	desc = "What amounts to a series of integrated storage compartments and specialized pockets installed across \
		the surface of the suit, useful for storing various bits, and or bobs."
	icon_state = "storage"
	complexity = 3
	incompatible_modules = list(/obj/item/mod/module/storage)
	var/datum/component/storage/concrete/storage
	var/max_w_class = WEIGHT_CLASS_NORMAL
	var/max_combined_w_class = 15
	var/max_items = 7

/obj/item/mod/module/storage/Initialize(mapload)
	. = ..()
	storage = AddComponent(/datum/component/storage/concrete)
	storage.max_w_class = max_w_class
	storage.max_combined_w_class = max_combined_w_class
	storage.max_items = max_items
	storage.allow_big_nesting = TRUE
	SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SET_LOCKSTATE, TRUE)

/obj/item/mod/module/storage/on_install()
	var/datum/component/storage/modstorage = mod.AddComponent(/datum/component/storage, storage)
	modstorage.max_w_class = max_w_class
	modstorage.max_combined_w_class = max_combined_w_class
	modstorage.max_items = max_items
	SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SET_LOCKSTATE, FALSE)

/obj/item/mod/module/storage/on_uninstall()
	var/datum/component/storage/modstorage = mod.GetComponent(/datum/component/storage)
	storage.slaves -= modstorage
	qdel(modstorage)
	SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SET_LOCKSTATE, TRUE)

/obj/item/mod/module/storage/large_capacity
	name = "MOD expanded storage module"
	desc = "Reverse engineered by Nakamura Engineering from Donk Corporation designs, this system of hidden compartments \
		is entirely within the suit, distributing items and weight evenly to ensure a comfortable experience for the user; \
		whether smuggling, or simply hauling."
	icon_state = "storage_large"
	max_combined_w_class = 21
	max_items = 14

/obj/item/mod/module/storage/syndicate
	name = "MOD syndicate storage module"
	desc = "A storage system using nanotechnology developed by Cybersun Industries, these compartments use \
		esoteric technology to compress the physical matter of items put inside of them, \
		essentially shrinking items for much easier and more portable storage."
	icon_state = "storage_syndi"
	max_combined_w_class = 30
	max_items = 21

/obj/item/mod/module/storage/bluespace
	name = "MOD bluespace storage module"
	desc = "A storage system developed by Nanotrasen, these compartments employ \
		miniaturized bluespace pockets for the ultimate in storage technology; regardless of the weight of objects put inside."
	icon_state = "storage_large"
	max_w_class = WEIGHT_CLASS_GIGANTIC
	max_combined_w_class = 60
	max_items = 21

/obj/item/mod/module/visor
	name = "MOD visor module"
	desc = "A heads-up display installed into the visor of the suit. They say these also let you see behind you."
	module_type = MODULE_TOGGLE
	complexity = 2
	active_power_cost = DEFAULT_CELL_DRAIN*0.3
	incompatible_modules = list(/obj/item/mod/module/visor)
	cooldown_time = 0.5 SECONDS
	var/hud_type
	var/list/visor_traits = list()

/obj/item/mod/module/visor/on_activation()
	. = ..()
	if(!.)
		return
	if(hud_type)
		var/datum/atom_hud/hud = GLOB.huds[hud_type]
		hud.add_hud_to(mod.wearer)
	for(var/trait in visor_traits)
		ADD_TRAIT(mod.wearer, trait, MOD_TRAIT)
	mod.wearer.update_sight()

/obj/item/mod/module/visor/on_deactivation()
	. = ..()
	if(!.)
		return
	if(hud_type)
		var/datum/atom_hud/hud = GLOB.huds[hud_type]
		hud.remove_hud_from(mod.wearer)
	for(var/trait in visor_traits)
		REMOVE_TRAIT(mod.wearer, trait, MOD_TRAIT)
	mod.wearer.update_sight()

/obj/item/mod/module/visor/medhud
	name = "MOD medical visor module"
	desc = "A heads-up display installed into the visor of the suit. This cross-references suit sensor data with a modern \
		biological scanning suite, allowing the user to visualize the current health of organic lifeforms, as well as \
		access data such as patient files in a convenient readout. They say these also let you see behind you."
	icon_state = "medhud_visor"
	hud_type = DATA_HUD_MEDICAL_ADVANCED
	visor_traits = list(TRAIT_MEDICAL_HUD)

/obj/item/mod/module/visor/diaghud
	name = "MOD diagnostic visor module"
	desc = "A heads-up display installed into the visor of the suit. This uses a series of advanced sensors to access data \
		from advanced machinery, exosuits, and other devices, allowing the user to visualize current power levels \
		and integrity of such. They say these also let you see behind you."
	icon_state = "diaghud_visor"
	hud_type = DATA_HUD_DIAGNOSTIC_ADVANCED
	visor_traits = list(TRAIT_DIAGNOSTIC_HUD)

/obj/item/mod/module/visor/sechud
	name = "MOD security visor module"
	desc = "A heads-up display installed into the visor of the suit. This module is a heavily-retrofitted targeting system, \
		plugged into various criminal databases to be able to view arrest records, command simple security-oriented robots, \
		and generally know who to shoot. They say these also let you see behind you."
	icon_state = "sechud_visor"
	hud_type = DATA_HUD_SECURITY_ADVANCED
	visor_traits = list(TRAIT_SECURITY_HUD)

/obj/item/mod/module/visor/meson
	name = "MOD meson visor module"
	desc = "A heads-up display installed into the visor of the suit. This module is based off well-loved meson scanner \
		technology, used by construction workers and miners across the galaxy to see basic structural and terrain layouts \
		through walls, regardless of lighting conditions. They say these also let you see behind you."
	icon_state = "meson_visor"
	visor_traits = list(TRAIT_MESON_VISION, TRAIT_SUPERMATTER_MADNESS_IMMUNE)

/obj/item/mod/module/visor/thermal
	name = "MOD thermal visor module"
	desc = "A heads-up display installed into the visor of the suit. This uses a small IR scanner to detect and identify \
		the thermal radiation output of objects near the user. While it can detect the heat output of even something as \
		small as a rodent, it still produces irritating red overlay. They say these also let you see behind you."
	icon_state = "thermal_visor"
	visor_traits = list(TRAIT_THERMAL_VISION)

/obj/item/mod/module/visor/night
	name = "MOD night visor module"
	desc = "A heads-up display installed into the visor of the suit. Typical for both civilian and military applications, \
		this allows the user to perceive their surroundings while in complete darkness, enhancing the view by tenfold; \
		yet brightening everything into a spooky green glow. They say these also let you see behind you."
	icon_state = "night_visor"
	visor_traits = list(TRAIT_TRUE_NIGHT_VISION)

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

/obj/item/mod/module/t_ray
	name = "MOD t-ray scan module"
	desc = "A module installed into the visor of the suit, allowing the user to use a pulse of terahertz radiation \
		to essentially echolocate things beneath the floor, mostly cables and pipes. \
		A staple of atmospherics work, and counter-smuggling work."
	icon_state = "tray"
	module_type = MODULE_TOGGLE
	complexity = 2
	active_power_cost = DEFAULT_CELL_DRAIN * 0.2
	incompatible_modules = list(/obj/item/mod/module/t_ray)
	cooldown_time = 0.5 SECONDS
	var/range = 2

/obj/item/mod/module/t_ray/on_active_process(delta_time)
	t_ray_scan(mod.wearer, 8, range)

#define HEALTH_SCAN "Health"
#define WOUND_SCAN "Wound"
#define CHEM_SCAN "Chemical"

/obj/item/mod/module/health_analyzer
	name = "MOD health analyzer module"
	desc = "A module installed into the glove of the suit. This is a high-tech biological scanning suite, \
		allowing the user indepth information on the vitals and injuries of others even at a distance, \
		all with the flick of the wrist. Data is displayed in a convenient package on HUD in the helmet, \
		but it's up to you to do something with it."
	icon_state = "health"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = DEFAULT_CELL_DRAIN
	incompatible_modules = list(/obj/item/mod/module/health_analyzer)
	cooldown_time = 0.5 SECONDS
	var/mode = HEALTH_SCAN
	var/static/list/modes = list(HEALTH_SCAN, WOUND_SCAN, CHEM_SCAN)

/obj/item/mod/module/health_analyzer/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!isliving(target))
		return
	switch(mode)
		if(HEALTH_SCAN)
			healthscan(mod.wearer, target)
		if(WOUND_SCAN)
			woundscan(mod.wearer, target)
		if(CHEM_SCAN)
			chemscan(mod.wearer, target)
	drain_power(use_power_cost)

/obj/item/mod/module/health_analyzer/get_configuration()
	. = ..()
	.["mode"] = add_ui_configuration("Scan Mode", "list", mode, modes)

/obj/item/mod/module/health_analyzer/configure_edit(key, value)
	switch(key)
		if("mode")
			mode = value

#undef HEALTH_SCAN
#undef WOUND_SCAN
#undef CHEM_SCAN

/obj/item/mod/module/stealth
	name = "MOD prototype cloaking module"
	desc = "A complete retrofitting of the suit, this is a form of visual concealment tech employing esoteric technology \
		to bend light around the user, as well as mimetic materials to make the surface of the suit match the \
		surroundings based off sensor data. For some reason, this tech is rarely seen."
	icon_state = "cloak"
	module_type = MODULE_TOGGLE
	complexity = 4
	active_power_cost = DEFAULT_CELL_DRAIN * 2
	use_power_cost = DEFAULT_CELL_DRAIN * 10
	incompatible_modules = list(/obj/item/mod/module/stealth)
	cooldown_time = 5 SECONDS
	var/bumpoff = TRUE
	var/stealth_alpha = 50

/obj/item/mod/module/stealth/on_activation()
	. = ..()
	if(!.)
		return
	if(bumpoff)
		RegisterSignal(mod.wearer, COMSIG_LIVING_MOB_BUMP, .proc/unstealth)
	RegisterSignal(mod.wearer, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, .proc/on_unarmed_attack)
	RegisterSignal(mod.wearer, COMSIG_ATOM_BULLET_ACT, .proc/on_bullet_act)
	RegisterSignal(mod.wearer, list(COMSIG_ITEM_ATTACK, COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_ATTACK_PAW, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW, COMSIG_CARBON_CUFF_ATTEMPTED), .proc/unstealth)
	animate(mod.wearer, alpha = stealth_alpha, time = 1.5 SECONDS)
	drain_power(use_power_cost)

/obj/item/mod/module/stealth/on_deactivation()
	. = ..()
	if(!.)
		return
	if(bumpoff)
		UnregisterSignal(mod.wearer, COMSIG_LIVING_MOB_BUMP)
	UnregisterSignal(mod.wearer, list(COMSIG_HUMAN_MELEE_UNARMED_ATTACK, COMSIG_ITEM_ATTACK, COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW, COMSIG_CARBON_CUFF_ATTEMPTED))
	animate(mod.wearer, alpha = 255, time = 1.5 SECONDS)

/obj/item/mod/module/stealth/proc/unstealth(datum/source)
	SIGNAL_HANDLER

	to_chat(mod.wearer, span_warning("[src] gets discharged from contact!"))
	do_sparks(2, TRUE, src)
	drain_power(use_power_cost)
	on_deactivation()

/obj/item/mod/module/stealth/proc/on_unarmed_attack(datum/source, atom/target)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	unstealth(source)

/obj/item/mod/module/stealth/proc/on_bullet_act(datum/source, obj/projectile/projectile)
	SIGNAL_HANDLER

	if(projectile.nodamage)
		return
	unstealth(source)

/obj/item/mod/module/stealth/ninja
	name = "MOD advanced cloaking module"
	desc = "The latest in stealth technology, this module is a definite upgrade over previous versions. \
		The field has been tuned to be even more responsive and fast-acting, with enough stability to \
		continue operation of the field even if the user bumps into others. \
		The draw on the power cell has been reduced drastically, \
		making this perfect for activities like standing near sentry turrets for extended periods of time."
	icon_state = "cloak_ninja"
	bumpoff = FALSE
	stealth_alpha = 20
	active_power_cost = DEFAULT_CELL_DRAIN
	use_power_cost = DEFAULT_CELL_DRAIN * 5
	cooldown_time = 3 SECONDS

/obj/item/mod/module/jetpack
	name = "MOD ion jetpack module"
	desc = "A series of electric thrusters installed across the suit, this is a module highly anticipated by trainee Engineers. \
		Rather than using gasses for combustion thrust, these jets are capable of accelerating ions using \
		charge from the suit's cell. Some say this isn't Nakamura Engineering's first foray into jet-enabled suits."
	icon_state = "jetpack"
	module_type = MODULE_TOGGLE
	complexity = 3
	active_power_cost = DEFAULT_CELL_DRAIN * 0.5
	use_power_cost = DEFAULT_CELL_DRAIN
	incompatible_modules = list(/obj/item/mod/module/jetpack)
	cooldown_time = 0.5 SECONDS
	overlay_state_inactive = "module_jetpack"
	overlay_state_active = "module_jetpack_on"
	var/stabilizers = FALSE
	var/full_speed = FALSE
	var/datum/effect_system/trail_follow/ion/ion_trail

/obj/item/mod/module/jetpack/Initialize(mapload)
	. = ..()
	ion_trail = new
	ion_trail.auto_process = FALSE
	ion_trail.set_up(src)

/obj/item/mod/module/jetpack/Destroy()
	QDEL_NULL(ion_trail)
	return ..()

/obj/item/mod/module/jetpack/on_activation()
	. = ..()
	if(!.)
		return
	ion_trail.start()
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, .proc/move_react)
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_PRE_MOVE, .proc/pre_move_react)
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_SPACEMOVE, .proc/spacemove_react)
	if(full_speed)
		mod.wearer.add_movespeed_modifier(/datum/movespeed_modifier/jetpack/fullspeed)

/obj/item/mod/module/jetpack/on_deactivation(mob/user)
	. = ..()
	if(!.)
		return
	ion_trail.stop()
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_PRE_MOVE)
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_SPACEMOVE)
	if(full_speed)
		mod.wearer.remove_movespeed_modifier(/datum/movespeed_modifier/jetpack/fullspeed)

/obj/item/mod/module/jetpack/get_configuration()
	. = ..()
	.["stabilizers"] = add_ui_configuration("Stabilizers", "bool", stabilizers)

/obj/item/mod/module/jetpack/configure_edit(key, value)
	switch(key)
		if("stabilizers")
			stabilizers = text2num(value)

/obj/item/mod/module/jetpack/proc/move_react(mob/user)
	SIGNAL_HANDLER

	if(!active)//If jet dont work, it dont work
		return
	if(!isturf(mod.wearer.loc))//You can't use jet in nowhere or from mecha/closet
		return
	if(!(mod.wearer.movement_type & FLOATING) || mod.wearer.buckled)//You don't want use jet in gravity or while buckled.
		return
	if(mod.wearer.pulledby)//You don't must use jet if someone pull you
		return
	if(mod.wearer.throwing)//You don't must use jet if you thrown
		return
	if(user.client && length(user.client.keys_held & user.client.movement_keys))//You use jet when press keys. yes.
		allow_thrust()

/obj/item/mod/module/jetpack/proc/pre_move_react(mob/user)
	SIGNAL_HANDLER

	ion_trail.oldposition = get_turf(src)

/obj/item/mod/module/jetpack/proc/spacemove_react(mob/user, movement_dir)
	SIGNAL_HANDLER

	if(active && (stabilizers || movement_dir))
		return COMSIG_MOVABLE_STOP_SPACEMOVE

/obj/item/mod/module/jetpack/proc/allow_thrust()
	if(!drain_power(use_power_cost))
		return
	ion_trail.generate_effect()
	return TRUE

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
	incompatible_modules = list(/obj/item/mod/module/magboot)
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

/obj/item/mod/module/holster
	name = "MOD holster module"
	desc = "Based off typical storage compartments, this system allows the suit to holster a \
		standard firearm across its surface and allow for extremely quick retrieval. \
		While some users prefer the chest, others the forearm for quick deployment, \
		some law enforcement prefer the holster to extend from the thigh."
	icon_state = "holster"
	module_type = MODULE_USABLE
	complexity = 2
	use_power_cost = DEFAULT_CELL_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/holster)
	cooldown_time = 0.5 SECONDS
	var/obj/item/gun/holstered

/obj/item/mod/module/holster/on_use()
	. = ..()
	if(!.)
		return
	if(!holstered)
		var/obj/item/gun/holding = mod.wearer.get_active_held_item()
		if(!holding)
			balloon_alert(mod.wearer, "nothing to holster!")
			return
		if(!istype(holding) || holding.w_class > WEIGHT_CLASS_BULKY)
			balloon_alert(mod.wearer, "it doesn't fit!")
			return
		if(mod.wearer.transferItemToLoc(holding, src, FALSE, FALSE))
			holstered = holding
			balloon_alert(mod.wearer, "weapon holstered")
			playsound(src, 'sound/weapons/gun/revolver/empty.ogg', 100, TRUE)
			drain_power(use_power_cost)
	else if(mod.wearer.put_in_active_hand(holstered, FALSE, TRUE))
		balloon_alert(mod.wearer, "weapon drawn")
		holstered = null
		playsound(src, 'sound/weapons/gun/revolver/empty.ogg', 100, TRUE)
		drain_power(use_power_cost)
	else
		balloon_alert(mod.wearer, "holster full!")

/obj/item/mod/module/holster/on_uninstall()
	if(holstered)
		holstered.forceMove(drop_location())
		holstered = null

/obj/item/mod/module/holster/Destroy()
	QDEL_NULL(holstered)
	return ..()

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

/obj/item/mod/module/mouthhole
	name = "MOD eating apparatus module"
	desc = "A favorite by Miners, this modification to the helmet utilizes a nanotechnology barrier infront of the mouth \
		to allow eating and drinking while retaining protection and atmosphere. \
		However, it will do nothing to improve the taste of a goliath steak."
	icon_state = "apparatus"
	complexity = 1
	incompatible_modules = list(/obj/item/mod/module/mouthhole)
	overlay_state_inactive = "module_apparatus"
	var/former_flags = NONE
	var/former_visor_flags = NONE

/obj/item/mod/module/mouthhole/on_install()
	former_flags = mod.helmet.flags_cover
	former_visor_flags = mod.helmet.visor_flags_cover
	mod.helmet.flags_cover &= ~HEADCOVERSMOUTH
	mod.helmet.visor_flags_cover &= ~HEADCOVERSMOUTH

/obj/item/mod/module/mouthhole/on_uninstall()
	if(!(former_flags & HEADCOVERSMOUTH))
		mod.helmet.flags_cover |= HEADCOVERSMOUTH
	if(!(former_visor_flags & HEADCOVERSMOUTH))
		mod.helmet.visor_flags_cover |= HEADCOVERSMOUTH

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

/obj/item/mod/module/emp_shield
	name = "MOD EMP shield module"
	desc = "A field inhibitor installed into the suit, protecting it against feedback such as \
		electromagnetic pulses that would otherwise damage the electronic systems of the suit or devices on the wearer. \
		However, it will take from the suit's power to do so. Luckily, your PDA already has one of these."
	icon_state = "empshield"
	complexity = 1
	idle_power_cost = DEFAULT_CELL_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/emp_shield)

/obj/item/mod/module/emp_shield/on_install()
	mod.AddElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_WIRES|EMP_PROTECT_CONTENTS)

/obj/item/mod/module/emp_shield/on_uninstall()
	mod.RemoveElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_WIRES|EMP_PROTECT_CONTENTS)

/obj/item/mod/module/flashlight
	name = "MOD flashlight module"
	desc = "A simple pair of flashlights installed on the left and right sides of the helmet, \
		useful for providing light in a variety of ranges and colors. \
		Some survivalists prefer the color green for their illumination, for reasons unknown."
	icon_state = "flashlight"
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = DEFAULT_CELL_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/flashlight)
	cooldown_time = 0.5 SECONDS
	overlay_state_inactive = "module_light"
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_color = COLOR_WHITE
	light_range = 3
	light_power = 1
	light_on = FALSE
	var/base_power = DEFAULT_CELL_DRAIN * 0.1
	var/min_range = 2
	var/max_range = 5

/obj/item/mod/module/flashlight/on_activation()
	. = ..()
	if(!.)
		return
	set_light_flags(light_flags | LIGHT_ATTACHED)
	set_light_on(active)
	active_power_cost = base_power * light_range

/obj/item/mod/module/flashlight/on_deactivation()
	. = ..()
	if(!.)
		return
	set_light_flags(light_flags & ~LIGHT_ATTACHED)
	set_light_on(active)

/obj/item/mod/module/flashlight/on_process(delta_time)
	. = ..()
	if(!.)
		return
	active_power_cost = base_power * light_range

/obj/item/mod/module/flashlight/generate_worn_overlay(mutable_appearance/standing)
	. = ..()
	if(!active)
		return
	var/mutable_appearance/light_icon = mutable_appearance('icons/mob/mod.dmi', "module_light_on", layer = standing.layer + 0.2)
	light_icon.appearance_flags = RESET_COLOR
	light_icon.color = light_color
	. += light_icon

/obj/item/mod/module/flashlight/get_configuration()
	. = ..()
	.["light_color"] = add_ui_configuration("Light Color", "color", light_color)
	.["light_range"] = add_ui_configuration("Light Range", "number", light_range)

/obj/item/mod/module/flashlight/configure_edit(key, value)
	switch(key)
		if("light_color")
			value = input(usr, "Pick new light color", "Flashlight Color") as color|null
			if(!value)
				return
			if(is_color_dark(value, 50))
				balloon_alert(mod.wearer, "too dark!")
				return
			set_light_color(value)
			mod.wearer.update_inv_back()
		if("light_range")
			set_light_range(clamp(value, min_range, max_range))

/obj/item/mod/module/reagent_scanner
	name = "MOD reagent scanner module"
	desc = "A module based off research-oriented Nanotrasen HUDs, this is capable of scanning the contents of \
		containers and projecting the information in an easy-to-read format on the wearer's display. \
		It cannot detect flavors, so that's up to you."
	icon_state = "scanner"
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = DEFAULT_CELL_DRAIN * 0.2
	incompatible_modules = list(/obj/item/mod/module/reagent_scanner)
	cooldown_time = 0.5 SECONDS

/obj/item/mod/module/reagent_scanner/on_activation()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(mod.wearer, TRAIT_REAGENT_SCANNER, MOD_TRAIT)

/obj/item/mod/module/reagent_scanner/on_deactivation()
	. = ..()
	if(!.)
		return
	REMOVE_TRAIT(mod.wearer, TRAIT_REAGENT_SCANNER, MOD_TRAIT)

/obj/item/mod/module/reagent_scanner/advanced
	name = "MOD advanced reagent scanner module"
	complexity = 0
	removable = FALSE
	var/explosion_detection_dist = 21

/obj/item/mod/module/reagent_scanner/advanced/on_activation()
	. = ..()
	if(!.)
		return
	mod.wearer.research_scanner++
	RegisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION, .proc/sense_explosion)

/obj/item/mod/module/reagent_scanner/advanced/on_deactivation()
	. = ..()
	if(!.)
		return
	mod.wearer.research_scanner--
	RegisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION)

/obj/item/mod/module/reagent_scanner/advanced/proc/sense_explosion(datum/source, turf/epicenter,
	devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
	SIGNAL_HANDLER
	var/turf/wearer_turf = get_turf(mod.wearer)
	if(wearer_turf.z != epicenter.z)
		return
	if(get_dist(epicenter, wearer_turf) > explosion_detection_dist)
		return
	to_chat(mod.wearer, span_notice("Explosion detected! Epicenter: [devastation_range], Outer: [heavy_impact_range], Shock: [light_impact_range]"))


/obj/item/mod/module/dispenser
	name = "MOD burger dispenser module"
	desc = "A rare piece of technology reverse-engineered from a prototype found in a Donk Corporation vessel. \
		This can draw incredible amounts of power from the suit's cell to create edible organic matter in the \
		palm of the wearer's glove; however, research seemed to have entirely stopped at burgers. \
		Notably, all attempts to get it to dispense Earl Grey tea have failed."
	icon_state = "dispenser"
	module_type = MODULE_USABLE
	complexity = 3
	use_power_cost = DEFAULT_CELL_DRAIN * 2
	incompatible_modules = list(/obj/item/mod/module/dispenser)
	cooldown_time = 5 SECONDS
	var/dispense_type = /obj/item/food/burger/plain
	var/dispense_time = 0 SECONDS

/obj/item/mod/module/dispenser/on_use()
	. = ..()
	if(!.)
		return
	if(dispense_time && !do_after(mod.wearer, dispense_time, target = mod))
		balloon_alert(mod.wearer, "interrupted!")
		return
	var/obj/item/dispensed = new dispense_type(mod.wearer.loc)
	mod.wearer.put_in_hands(dispensed)
	balloon_alert(mod.wearer, "[dispensed] dispensed")
	playsound(src, 'sound/machines/click.ogg', 100, TRUE)
	drain_power(use_power_cost)

/obj/item/mod/module/gps
	name = "MOD internal GPS module"
	desc = "This module uses common Nanotrasen technology to calculate the user's position anywhere in space, \
		down to the exact coordinates. This information is fed to a central database viewable from the device itself, \
		though using it to help people is up to you."
	icon_state = "gps"
	module_type = MODULE_ACTIVE
	complexity = 1
	active_power_cost = DEFAULT_CELL_DRAIN * 0.3
	device = /obj/item/gps/mod
	incompatible_modules = list(/obj/item/mod/module/gps)
	cooldown_time = 0.5 SECONDS

/obj/item/gps/mod
	name = "MOD internal GPS"
	desc = "Common Nanotrasen technology that calcaulates the user's position from anywhere in space, down to their coordinates."
	icon_state = "gps-b"
	gpstag = "MOD0"

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

/obj/item/mod/module/quick_carry
	name = "MOD quick carry module"
	desc = "A suite of advanced servos, redirecting power from the suit's arms to help carry the wounded; \
		or simply for fun. However, Nanotrasen has locked the module's ability to assist in hand-to-hand combat."
	icon_state = "carry"
	complexity = 1
	idle_power_cost = DEFAULT_CELL_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/quick_carry, /obj/item/mod/module/constructor)

/obj/item/mod/module/quick_carry/on_suit_activation()
	ADD_TRAIT(mod.wearer, TRAIT_QUICK_CARRY, MOD_TRAIT)

/obj/item/mod/module/quick_carry/on_suit_deactivation()
	REMOVE_TRAIT(mod.wearer, TRAIT_QUICK_CARRY, MOD_TRAIT)

/obj/item/mod/module/quick_carry/advanced
	name = "MOD advanced quick carry module"
	removable = FALSE
	complexity = 0

/obj/item/mod/module/quick_carry/on_suit_activation()
	ADD_TRAIT(mod.wearer, TRAIT_QUICKER_CARRY, MOD_TRAIT)
	ADD_TRAIT(mod.wearer, TRAIT_FASTMED, MOD_TRAIT)

/obj/item/mod/module/quick_carry/on_suit_deactivation()
	REMOVE_TRAIT(mod.wearer, TRAIT_QUICKER_CARRY, MOD_TRAIT)
	REMOVE_TRAIT(mod.wearer, TRAIT_FASTMED, MOD_TRAIT)

/obj/item/mod/module/longfall
	name = "MOD longfall module"
	desc = "Useful for protecting both the suit and the wearer, \
		utilizing commonplace systems to convert the possible damage from a fall into kinetic charge, \
		as well as internal gyroscopes to ensure the user's safe falling. \
		Useful for mining, monorail tracks, or even skydiving!"
	icon_state = "longfall"
	complexity = 1
	use_power_cost = DEFAULT_CELL_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/longfall)

/obj/item/mod/module/longfall/on_suit_activation()
	RegisterSignal(mod.wearer, COMSIG_LIVING_Z_IMPACT, .proc/z_impact_react)

/obj/item/mod/module/longfall/on_suit_deactivation()
	UnregisterSignal(mod.wearer, COMSIG_LIVING_Z_IMPACT)

/obj/item/mod/module/longfall/proc/z_impact_react(datum/source, levels, turf/fell_on)
	if(!drain_power(use_power_cost*levels))
		return
	new /obj/effect/temp_visual/mook_dust(fell_on)
	mod.wearer.Stun(levels * 1 SECONDS)
	to_chat(mod.wearer, span_notice("[src] protects you from the damage!"))
	return NO_Z_IMPACT_DAMAGE

/obj/item/mod/module/thermal_regulator
	name = "MOD thermal regulator module"
	desc = "Advanced climate control, using an inner body glove interwoven with thousands of tiny, \
		flexible cooling lines. This circulates coolant at various user-controlled temperatures, \
		ensuring they're comfortable; even if they're some that like it hot."
	icon_state = "regulator"
	module_type = MODULE_TOGGLE
	complexity = 2
	active_power_cost = DEFAULT_CELL_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/thermal_regulator)
	cooldown_time = 0.5 SECONDS
	var/temperature_setting = BODYTEMP_NORMAL
	var/min_temp = 293.15
	var/max_temp = 318.15

/obj/item/mod/module/thermal_regulator/get_configuration()
	. = ..()
	.["temperature_setting"] = add_ui_configuration("Temperature", "number", temperature_setting - T0C)

/obj/item/mod/module/thermal_regulator/configure_edit(key, value)
	switch(key)
		if("temperature_setting")
			temperature_setting = clamp(value + T0C, min_temp, max_temp)

/obj/item/mod/module/thermal_regulator/on_active_process(delta_time)
	mod.wearer.adjust_bodytemperature(get_temp_change_amount((temperature_setting - mod.wearer.bodytemperature), 0.08 * delta_time))

/obj/item/mod/module/injector
	name = "MOD injector module"
	desc = "A module installed into the wrist of the suit, this functions as a high-capacity syringe, \
		with a tip fine enough to locate the emergency injection ports on any suit of armor, \
		penetrating it with ease. Even yours."
	icon_state = "injector"
	module_type = MODULE_ACTIVE
	complexity = 1
	active_power_cost = DEFAULT_CELL_DRAIN * 0.3
	device = /obj/item/reagent_containers/syringe/mod
	incompatible_modules = list(/obj/item/mod/module/injector)
	cooldown_time = 0.5 SECONDS

/obj/item/reagent_containers/syringe/mod
	name = "MOD injector syringe"
	desc = "A high-capacity syringe, with a tip fine enough to locate \
		the emergency injection ports on any suit of armor, penetrating it with ease. Even yours."
	icon_state = "mod_0"
	base_icon_state = "mod"
	amount_per_transfer_from_this = 30
	possible_transfer_amounts = list(5, 10, 15, 20, 30)
	volume = 30
	inject_flags = INJECT_CHECK_PENETRATE_THICK

/obj/item/mod/module/circuit
	name = "MOD circuit adapter module"
	desc = "A popular aftermarket module, seen in wide varieties with wide applications by those across the galaxy. \
		This is able to fit any sort of integrated circuit, hooking it into controls in the suit and displaying information \
		to the HUD. Useful for universal translation, or perhaps as a calculator."
	module_type = MODULE_USABLE
	complexity = 3
	idle_power_cost = DEFAULT_CELL_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/circuit)
	cooldown_time = 0.5 SECONDS
	var/obj/item/integrated_circuit/circuit

/obj/item/mod/module/circuit/Initialize(mapload)
	. = ..()
	circuit = new()
	AddComponent(/datum/component/shell, \
		list(new /obj/item/circuit_component/mod()), \
		capacity = SHELL_CAPACITY_LARGE, \
		shell_flags = SHELL_FLAG_CIRCUIT_UNREMOVABLE, \
		starting_circuit = circuit, \
	)

/obj/item/mod/module/circuit/on_install()
	circuit.set_cell(mod.cell)

/obj/item/mod/module/circuit/on_uninstall()
	circuit.set_cell(mod.cell)

/obj/item/mod/module/circuit/on_suit_activation()
	circuit.set_on(TRUE)

/obj/item/mod/module/circuit/on_suit_deactivation()
	circuit.set_on(FALSE)

/obj/item/mod/module/circuit/on_use()
	. = ..()
	if(!.)
		return
	circuit.interact(mod.wearer)

/obj/item/circuit_component/mod
	display_name = "MOD"
	desc = "Used to send and receive signals from a MODsuit."

	var/obj/item/mod/module/attached_module

	var/datum/port/input/module_to_select
	var/datum/port/input/toggle_suit
	var/datum/port/input/select_module

	var/datum/port/output/wearer
	var/datum/port/output/selected_module

/obj/item/circuit_component/mod/populate_ports()
	// Input Signals
	module_to_select = add_input_port("Module to Select", PORT_TYPE_STRING)
	toggle_suit = add_input_port("Toggle Suit", PORT_TYPE_SIGNAL)
	select_module = add_input_port("Select Module", PORT_TYPE_SIGNAL)
	// States
	wearer = add_output_port("Wearer", PORT_TYPE_ATOM)
	selected_module = add_output_port("Selected Module", PORT_TYPE_ATOM)

/obj/item/circuit_component/mod/register_shell(atom/movable/shell)
	if(istype(shell, /obj/item/mod/module))
		attached_module = shell
	RegisterSignal(attached_module, COMSIG_MOVABLE_MOVED, .proc/on_move)

/obj/item/circuit_component/mod/unregister_shell(atom/movable/shell)
	UnregisterSignal(attached_module, COMSIG_MOVABLE_MOVED)
	attached_module = null

/obj/item/circuit_component/mod/input_received(datum/port/input/port)
	var/obj/item/mod/module/module
	for(var/obj/item/mod/module/potential_module as anything in attached_module.mod.modules)
		if(potential_module.name == module_to_select.value)
			module = potential_module
	if(COMPONENT_TRIGGERED_BY(toggle_suit, port))
		INVOKE_ASYNC(attached_module.mod, /obj/item/mod/control.proc/toggle_activate, attached_module.mod.wearer)
	if(module && COMPONENT_TRIGGERED_BY(select_module, port))
		INVOKE_ASYNC(module, /obj/item/mod/module.proc/on_select)

/obj/item/circuit_component/mod/proc/on_move(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	if(istype(source.loc, /obj/item/mod/control))
		RegisterSignal(source.loc, COMSIG_MOD_MODULE_SELECTED, .proc/on_module_select)
		RegisterSignal(source.loc, COMSIG_ITEM_EQUIPPED, .proc/equip_check)
		equip_check()
	else if(istype(old_loc, /obj/item/mod/control))
		UnregisterSignal(old_loc, list(COMSIG_MOD_MODULE_SELECTED, COMSIG_ITEM_EQUIPPED))
		selected_module.set_output(null)
		wearer.set_output(null)

/obj/item/circuit_component/mod/proc/on_module_select()
	SIGNAL_HANDLER
	selected_module.set_output(attached_module.mod.selected_module)

/obj/item/circuit_component/mod/proc/equip_check()
	SIGNAL_HANDLER

	if(!attached_module.mod?.wearer)
		return
	wearer.set_output(attached_module.mod.wearer)

/obj/item/mod/module/clamp
	name = "MOD hydraulic clamp module"
	desc = "A series of actuators installed into both arms of the suit, boasting a lifting capacity of almost a ton. \
		However, this design has been locked by Nanotrasen to be primarily utilized for lifting various crates. \
		A lot of people would say that loading cargo is a dull job, but you could not disagree more."
	icon_state = "clamp"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_power_cost = DEFAULT_CELL_DRAIN
	incompatible_modules = list(/obj/item/mod/module/clamp)
	cooldown_time = 0.5 SECONDS
	var/max_crates = 5
	var/list/stored_crates = list()

/obj/item/mod/module/clamp/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!mod.wearer.Adjacent(target))
		return
	if(istype(target, /obj/structure/closet/crate))
		var/atom/movable/picked_crate = target
		if(length(stored_crates) >= max_crates)
			balloon_alert(mod.wearer, "too many crates!")
			return
		if(!do_after(mod.wearer, 1 SECONDS, target = target))
			balloon_alert(mod.wearer, "interrupted!")
			return
		stored_crates += picked_crate
		picked_crate.forceMove(src)
		balloon_alert(mod.wearer, "picked up [picked_crate]")
		playsound(src, 'sound/mecha/hydraulic.ogg', 25, TRUE)
		drain_power(use_power_cost)
	else if(length(stored_crates))
		var/turf/target_turf = get_turf(target)
		if(target_turf.is_blocked_turf())
			return
		if(!do_after(mod.wearer, 1 SECONDS, target = target))
			balloon_alert(mod.wearer, "interrupted!")
			return
		if(target_turf.is_blocked_turf())
			return
		var/atom/movable/dropped_crate = pop(stored_crates)
		dropped_crate.forceMove(target_turf)
		balloon_alert(mod.wearer, "dropped [dropped_crate]")
		playsound(src, 'sound/mecha/hydraulic.ogg', 25, TRUE)
		drain_power(use_power_cost)

/obj/item/mod/module/clamp/on_uninstall()
	for(var/atom/movable/crate as anything in stored_crates)
		crate.forceMove(drop_location())
		stored_crates -= crate

/obj/item/mod/module/bikehorn
	name = "MOD bike horn module"
	desc = "A shoulder-mounted piece of heavy sonic artillery, this module uses the finest femto-manipulator technology to \
		precisely deliver an almost lethal squeeze to... a bike horn, producing a significantly memorable sound."
	icon_state = "bikehorn"
	module_type = MODULE_USABLE
	complexity = 1
	use_power_cost = DEFAULT_CELL_DRAIN
	incompatible_modules = list(/obj/item/mod/module/bikehorn)
	cooldown_time = 1 SECONDS

/obj/item/mod/module/bikehorn/on_use()
	. = ..()
	if(!.)
		return
	playsound(src, 'sound/items/bikehorn.ogg', 100, FALSE)
	drain_power(use_power_cost)

/obj/item/mod/module/drill
	name = "MOD drill module"
	desc = "An integrated drill, typically extending over the user's hand. While useful for drilling through rock, \
		your drill is surely the one that both pierces and creates the heavens."
	icon_state = "drill"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = DEFAULT_CELL_DRAIN
	incompatible_modules = list(/obj/item/mod/module/drill)
	cooldown_time = 0.5 SECONDS

/obj/item/mod/module/drill/on_activation()
	. = ..()
	if(!.)
		return
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_BUMP, .proc/bump_mine)

/obj/item/mod/module/drill/on_deactivation()
	. = ..()
	if(!.)
		return
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_BUMP)

/obj/item/mod/module/drill/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!mod.wearer.Adjacent(target))
		return
	if(istype(target, /turf/closed/mineral))
		var/turf/closed/mineral/mineral_turf = target
		mineral_turf.gets_drilled(mod.wearer)
		drain_power(use_power_cost)

/obj/item/mod/module/drill/proc/bump_mine(mob/living/carbon/human/bumper, atom/bumped_into, proximity)
	SIGNAL_HANDLER
	if(!istype(bumped_into, /turf/closed/mineral) || !drain_power(use_power_cost))
		return
	var/turf/closed/mineral/mineral_turf = bumped_into
	mineral_turf.gets_drilled(mod.wearer)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/mod/module/orebag
	name = "MOD ore bag module"
	desc = "An integrated ore storage system installed into the suit, \
		this utilizes precise electromagnets and storage compartments to automatically collect and deposit ore. \
		It's recommended by Nakamura Engineering to actually deposit that ore at local refineries."
	icon_state = "ore"
	module_type = MODULE_USABLE
	complexity = 2
	use_power_cost = DEFAULT_CELL_DRAIN * 0.2
	incompatible_modules = list(/obj/item/mod/module/orebag)
	cooldown_time = 0.5 SECONDS
	var/list/ores = list()

/obj/item/mod/module/orebag/on_equip()
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, .proc/ore_pickup)

/obj/item/mod/module/orebag/on_unequip()
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED)

/obj/item/mod/module/orebag/proc/ore_pickup(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	for(var/obj/item/stack/ore/ore in get_turf(mod.wearer))
		INVOKE_ASYNC(src, .proc/move_ore, ore)
		playsound(src, "rustle", 50, TRUE)

/obj/item/mod/module/orebag/proc/move_ore(obj/item/stack/ore)
	for(var/obj/item/stack/stored_ore as anything in ores)
		if(!ore.can_merge(stored_ore))
			continue
		ore.merge(stored_ore)
		if(QDELETED(ore))
			return
		break
	ore.forceMove(src)
	ores += ore

/obj/item/mod/module/orebag/on_use()
	. = ..()
	if(!.)
		return
	for(var/obj/item/ore as anything in ores)
		ore.forceMove(drop_location())
		ores -= ore
	drain_power(use_power_cost)

/obj/item/mod/module/microwave_beam
	name = "MOD microwave beam module"
	desc = "An oddly domestic device, this module is installed into the user's palm, \
		hooking up with culinary scanners located in the helmet to blast food with precise microwave radiation, \
		allowing them to cook food from a distance, with the greatest of ease. Not recommended for use against grapes."
	icon_state = "microwave_beam"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = DEFAULT_CELL_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/microwave_beam)
	cooldown_time = 10 SECONDS

/obj/item/mod/module/microwave_beam/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!istype(target, /obj/item))
		return
	if(!isturf(target.loc))
		balloon_alert(mod.wearer, "must be on the floor!")
		return
	var/obj/item/microwave_target = target
	var/datum/effect_system/spark_spread/spark_effect = new()
	spark_effect.set_up(2, 1, mod.wearer)
	spark_effect.start()
	mod.wearer.Beam(target,icon_state="lightning[rand(1,12)]", time = 5)
	if(microwave_target.microwave_act())
		playsound(src, 'sound/machines/microwave/microwave-end.ogg', 50, FALSE)
	else
		balloon_alert(mod.wearer, "can't be microwaved!")
	var/datum/effect_system/spark_spread/spark_effect_two = new()
	spark_effect_two.set_up(2, 1, microwave_target)
	spark_effect_two.start()
	drain_power(use_power_cost)

/obj/item/mod/module/organ_thrower
	name = "MOD organ thrower module"
	desc = "A device recovered from a crashed Interdyne Pharmaceuticals vessel, \
		this module has been unearthed for better or for worse. \
		It's an arm-mounted device utilizing technology similar to modern-day part replacers, \
		capable of storing and inserting organs into open patients. \
		It's recommended by the DeForest Medical Corporation to not inform patients it has been used."
	icon_state = "organ_thrower"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = DEFAULT_CELL_DRAIN
	incompatible_modules = list(/obj/item/mod/module/organ_thrower)
	cooldown_time = 0.5 SECONDS
	var/max_organs = 5
	var/organ_list = list()

/obj/item/mod/module/organ_thrower/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/wearer_human = mod.wearer
	if(istype(target, /obj/item/organ))
		if(!wearer_human.Adjacent(target))
			return
		var/atom/movable/organ = target
		if(length(organ_list) >= max_organs)
			balloon_alert(mod.wearer, "too many organs!")
			return
		organ_list += organ
		organ.forceMove(src)
		balloon_alert(mod.wearer, "picked up [organ]")
		playsound(src, 'sound/mecha/hydraulic.ogg', 25, TRUE)
		drain_power(use_power_cost)
		return
	if(!length(organ_list))
		return
	var/atom/movable/fired_organ = pop(organ_list)
	var/obj/projectile/organ/projectile = new /obj/projectile/organ(mod.wearer.loc, fired_organ)
	projectile.preparePixelProjectile(target, mod.wearer)
	projectile.firer = mod.wearer
	playsound(src, 'sound/mecha/hydraulic.ogg', 25, TRUE)
	INVOKE_ASYNC(projectile, /obj/projectile.proc/fire)
	drain_power(use_power_cost)

/obj/projectile/organ
	name = "organ"
	damage = 0
	nodamage = TRUE
	hitsound = 'sound/effects/attackblob.ogg'
	hitsound_wall = 'sound/effects/attackblob.ogg'
	var/obj/item/organ/organ

/obj/projectile/organ/Initialize(mapload, obj/item/stored_organ)
	. = ..()
	if(!stored_organ)
		return INITIALIZE_HINT_QDEL
	appearance = stored_organ.appearance
	stored_organ.forceMove(src)
	organ = stored_organ

/obj/projectile/organ/Destroy()
	organ = null
	return ..()

/obj/projectile/organ/on_hit(atom/target)
	. = ..()
	if(!ishuman(target))
		organ.forceMove(drop_location())
		organ = null
		return
	var/mob/living/carbon/human/organ_receiver = target
	var/succeed = FALSE
	if(organ_receiver.surgeries.len)
		for(var/datum/surgery/procedure as anything in organ_receiver.surgeries)
			if(procedure.location != organ.zone)
				continue
			if(!istype(procedure, /datum/surgery/organ_manipulation))
				continue
			var/datum/surgery_step/surgery_step = procedure.get_surgery_step()
			if(!istype(surgery_step, /datum/surgery_step/manipulate_organs))
				continue
			succeed = TRUE
			break
	if(succeed)
		var/list/organs_to_boot_out = organ_receiver.getorganslot(organ.slot)
		for(var/obj/item/organ/organ_evacced as anything in organs_to_boot_out)
			if(organ_evacced.organ_flags & ORGAN_UNREMOVABLE)
				continue
			organ_evacced.Remove(target)
			organ_evacced.forceMove(get_turf(target))
		organ.Insert(target)
	else
		organ.forceMove(drop_location())
	organ = null

/obj/item/mod/module/pathfinder
	name = "MOD pathfinder module"
	desc = "This module, brought to you by Nakamura Engineering, has two components. \
		The first component is a series of thrusters and a computerized location subroutine installed into the \
		very control unit of the suit, allowing it flight at highway speeds, \
		and to be able to locate the second part of the system; \
		a pathfinding implant installed into the base of the user's spine, \
		broadcasting their location to the suit and allowing them to recall it to their back at any time. \
		Nakamura Engineering swears up and down there's airbrakes."
	icon_state = "pathfinder"
	complexity = 2
	use_power_cost = DEFAULT_CELL_DRAIN * 10
	incompatible_modules = list(/obj/item/mod/module/pathfinder)
	var/obj/item/implant/mod/implant

/obj/item/mod/module/pathfinder/Initialize(mapload)
	. = ..()
	implant = new(src)

/obj/item/mod/module/pathfinder/Destroy()
	implant = null
	return ..()

/obj/item/mod/module/pathfinder/examine(mob/user)
	. = ..()
	if(implant)
		. += span_notice("Use it on a human to implant them.")
	else
		. += span_warning("The implant is missing.")

/obj/item/mod/module/pathfinder/attack(mob/living/target, mob/living/user, params)
	if(!ishuman(target) || !implant)
		return
	if(!do_after(user, 1.5 SECONDS, target = target))
		balloon_alert(user, "interrupted!")
		return
	if(!implant.implant(target, user))
		balloon_alert(user, "can't implant!")
		return
	if(target == user)
		to_chat(user, span_notice("You implant yourself with [implant]."))
	else
		target.visible_message(span_notice("[user] implants [target]."), span_notice("[user] implants you with [implant]."))
	playsound(src, 'sound/effects/spray.ogg', 30, TRUE, -6)
	icon_state = "pathfinder_empty"
	implant = null

/obj/item/mod/module/pathfinder/proc/attach(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	if(human_user.back && !human_user.dropItemToGround(human_user.back))
		return
	if(!human_user.equip_to_slot_if_possible(mod, mod.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE))
		return
	human_user.update_action_buttons(TRUE)
	balloon_alert(human_user, "[mod] attached")
	playsound(mod, 'sound/machines/ping.ogg', 50, TRUE)
	drain_power(use_power_cost)

/obj/item/implant/mod
	name = "MOD pathfinder implant"
	desc = "Lets you recall a MODsuit to you at any time."
	actions_types = list(/datum/action/item_action/mod_recall)
	var/obj/item/mod/module/pathfinder/module
	var/image/jet_icon

/obj/item/implant/mod/Initialize(mapload)
	. = ..()
	if(!istype(loc, /obj/item/mod/module/pathfinder))
		return INITIALIZE_HINT_QDEL
	module = loc
	jet_icon = image(icon = 'icons/obj/mod.dmi', icon_state = "mod_jet", layer = LOW_ITEM_LAYER)

/obj/item/implant/mod/Destroy()
	if(module?.mod?.ai_controller)
		end_recall(successful = FALSE)
	module = null
	jet_icon = null
	return ..()

/obj/item/implant/mod/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Nakamura Engineering Pathfinder Implant<BR>
				<b>Implant Details:</b> Allows for the recall of a Modular Outerwear Device by the implant owner at any time.<BR>"}
	return dat

/obj/item/implant/mod/proc/recall()
	if(!module?.mod)
		balloon_alert(imp_in, "no connected suit!")
		return FALSE
	if(module.mod.open)
		balloon_alert(imp_in, "suit is open!")
		return FALSE
	if(module.mod.ai_controller)
		balloon_alert(imp_in, "already in transit!")
		return FALSE
	if(ismob(get_atom_on_turf(module.mod)))
		balloon_alert(imp_in, "already on someone!")
		return FALSE
	if(module.z != z || get_dist(imp_in, module.mod) > MOD_AI_RANGE)
		balloon_alert(imp_in, "too far away!")
		return FALSE
	var/datum/ai_controller/mod_ai = new /datum/ai_controller/mod(module.mod)
	module.mod.ai_controller = mod_ai
	mod_ai.current_movement_target = imp_in
	mod_ai.blackboard[BB_MOD_TARGET] = imp_in
	mod_ai.blackboard[BB_MOD_IMPLANT] = src
	module.mod.interaction_flags_item &= ~INTERACT_ITEM_ATTACK_HAND_PICKUP
	module.mod.AddElement(/datum/element/movetype_handler)
	ADD_TRAIT(module.mod, TRAIT_MOVE_FLYING, MOD_TRAIT)
	animate(module.mod, 0.2 SECONDS, pixel_x = base_pixel_y, pixel_y = base_pixel_y)
	module.mod.add_overlay(jet_icon)
	RegisterSignal(module.mod, COMSIG_MOVABLE_MOVED, .proc/on_move)
	balloon_alert(imp_in, "suit recalled")
	return TRUE

/obj/item/implant/mod/proc/end_recall(successful = TRUE)
	if(!module?.mod)
		return
	QDEL_NULL(module.mod.ai_controller)
	module.mod.interaction_flags_item |= INTERACT_ITEM_ATTACK_HAND_PICKUP
	REMOVE_TRAIT(module.mod, TRAIT_MOVE_FLYING, MOD_TRAIT)
	module.mod.RemoveElement(/datum/element/movetype_handler)
	module.mod.cut_overlay(jet_icon)
	module.mod.transform = matrix()
	UnregisterSignal(module.mod, COMSIG_MOVABLE_MOVED)
	if(!successful)
		balloon_alert(imp_in, "suit lost connection!")

/obj/item/implant/mod/proc/on_move(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	var/matrix/mod_matrix = matrix()
	mod_matrix.Turn(get_angle(source, imp_in))
	source.transform = mod_matrix

/datum/action/item_action/mod_recall
	name = "Recall MOD"
	desc = "Recall a MODsuit anyplace, anytime."
	check_flags = AB_CHECK_CONSCIOUS
	background_icon_state = "bg_tech_blue"
	icon_icon = 'icons/mob/actions/actions_mod.dmi'
	button_icon_state = "recall"
	COOLDOWN_DECLARE(recall_cooldown)
	var/obj/item/implant/mod/implant

/datum/action/item_action/mod_recall/New(Target)
	..()
	implant = Target

/datum/action/item_action/mod_recall/Trigger()
	. = ..()
	if(!.)
		return
	if(!COOLDOWN_FINISHED(src, recall_cooldown))
		implant.balloon_alert(implant.imp_in, "on cooldown!")
		return
	if(implant.recall())
		COOLDOWN_START(src, recall_cooldown, 15 SECONDS)

/obj/item/mod/module/dna_lock
	name = "MOD DNA lock module"
	desc = "A module which engages with the various locks and seals tied to the suit's systems, \
		enabling it to only be worn by someone corresponding with the user's exact DNA profile; \
		however, this incredibly sensitive module is shorted out by EMPs. Luckily, cloning has been outlawed."
	icon_state = "dnalock"
	module_type = MODULE_USABLE
	complexity = 2
	use_power_cost = DEFAULT_CELL_DRAIN * 3
	incompatible_modules = list(/obj/item/mod/module/dna_lock)
	cooldown_time = 0.5 SECONDS
	var/dna = null

/obj/item/mod/module/dna_lock/on_install()
	RegisterSignal(mod, COMSIG_MOD_ACTIVATE, .proc/on_mod_activation)
	RegisterSignal(mod, COMSIG_MOD_MODULE_REMOVAL, .proc/on_mod_removal)
	RegisterSignal(mod, COMSIG_ATOM_EMP_ACT, .proc/on_emp)
	RegisterSignal(mod, COMSIG_ATOM_EMAG_ACT, .proc/on_emag)

/obj/item/mod/module/dna_lock/on_uninstall()
	UnregisterSignal(mod, COMSIG_MOD_ACTIVATE)
	UnregisterSignal(mod, COMSIG_MOD_MODULE_REMOVAL)
	UnregisterSignal(mod, COMSIG_ATOM_EMP_ACT)
	UnregisterSignal(mod, COMSIG_ATOM_EMAG_ACT)

/obj/item/mod/module/dna_lock/on_use()
	. = ..()
	if(!.)
		return
	dna = mod.wearer.dna.unique_enzymes
	balloon_alert(mod.wearer, "dna updated")
	drain_power(use_power_cost)

/obj/item/mod/module/dna_lock/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	on_emp(src, severity)

/obj/item/mod/module/dna_lock/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	on_emag(src, user, emag_card)

/obj/item/mod/module/dna_lock/proc/dna_check()
	if(!dna || (mod.wearer.has_dna() && mod.wearer.dna.unique_enzymes == dna))
		return TRUE
	balloon_alert(mod.wearer, "dna locked!")
	return FALSE

/obj/item/mod/module/dna_lock/proc/on_emp(datum/source, severity)
	SIGNAL_HANDLER

	dna = null

/obj/item/mod/module/dna_lock/proc/on_emag(datum/source, mob/user, obj/item/card/emag/emag_card)
	SIGNAL_HANDLER

	dna = null

/obj/item/mod/module/dna_lock/proc/on_mod_activation(datum/source)
	SIGNAL_HANDLER

	if(!dna_check())
		return MOD_CANCEL_ACTIVATE

/obj/item/mod/module/dna_lock/proc/on_mod_removal(datum/source)
	SIGNAL_HANDLER

	if(!dna_check())
		return MOD_CANCEL_REMOVAL

/obj/item/mod/module/armor_booster
	name = "MOD armor booster module"
	desc = "A retrofitted series of retractable armor plates, allowing the suit to function as essentially power armor, \
		giving the user incredible protection against conventional firearms, or everyday attacks in close-quarters. \
		However, the additional plating cannot deploy alongside parts of the suit used for vacuum sealing, \
		so this extra armor provides zero ability for extravehicular activity while deployed."
	icon_state = "armor_booster"
	module_type = MODULE_TOGGLE
	active_power_cost = DEFAULT_CELL_DRAIN * 0.3
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/armor_booster)
	cooldown_time = 0.5 SECONDS
	overlay_state_inactive = "module_armorbooster_off"
	overlay_state_active = "module_armorbooster_on"
	var/remove_pressure_protection = TRUE
	var/added_slowdown = -0.5
	var/list/armor_values = list(MELEE = 40, BULLET = 50, LASER = 30, ENERGY = 40)
	var/list/spaceproofed = list()

/obj/item/mod/module/armor_booster/generate_worn_overlay(mutable_appearance/standing)
	overlay_state_inactive = "[initial(overlay_state_inactive)]-[mod.skin]"
	overlay_state_active = "[initial(overlay_state_active)]-[mod.skin]"
	return ..()

/obj/item/mod/module/armor_booster/on_activation()
	. = ..()
	if(!.)
		return
	playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	mod.slowdown += added_slowdown
	mod.wearer.update_equipment_speed_mods()
	var/list/parts = mod.mod_parts + mod
	for(var/obj/item/part as anything in parts)
		part.armor = part.armor.modifyRating(arglist(armor_values))
		if(!remove_pressure_protection || !isclothing(part))
			continue
		var/obj/item/clothing/clothing_part = part
		if(clothing_part.clothing_flags & STOPSPRESSUREDAMAGE)
			clothing_part.clothing_flags &= ~STOPSPRESSUREDAMAGE
			clothing_part.heat_protection = NONE
			clothing_part.cold_protection = NONE
			spaceproofed[clothing_part] = TRUE

/obj/item/mod/module/armor_booster/on_deactivation()
	. = ..()
	if(!.)
		return
	playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	mod.slowdown -= added_slowdown
	mod.wearer.update_equipment_speed_mods()
	var/list/parts = mod.mod_parts + mod
	var/list/removed_armor = armor_values.Copy()
	for(var/armor_type in removed_armor)
		removed_armor[armor_type] = -removed_armor[armor_type]
	for(var/obj/item/part as anything in parts)
		part.armor = part.armor.modifyRating(arglist(removed_armor))
		if(!remove_pressure_protection || !isclothing(part))
			continue
		var/obj/item/clothing/clothing_part = part
		if(spaceproofed[clothing_part])
			clothing_part.clothing_flags |= STOPSPRESSUREDAMAGE
			clothing_part.heat_protection = initial(clothing_part.heat_protection)
			clothing_part.cold_protection = initial(clothing_part.cold_protection)
	spaceproofed = list()

/obj/item/mod/module/armor_booster/elite
	name = "MOD elite armor booster module"
	armor_values = list(MELEE = 60, BULLET = 60, LASER = 50, ENERGY = 60)
	added_slowdown = -0.25

/obj/item/mod/module/energy_shield
	name = "MOD energy shield module"
	desc = "A personal, protective forcefield typically seen in military applications. \
		This advanced deflector shield is essentially a scaled down version of those seen on starships, \
		and the power cost can be an easy indicator of this. However, it is capable of blocking nearly any incoming attack, \
		though with its' low amount of separate charges, the user remains mortal."
	icon_state = "energy_shield"
	complexity = 3
	idle_power_cost = DEFAULT_CELL_DRAIN * 0.5
	use_power_cost = DEFAULT_CELL_DRAIN * 2
	incompatible_modules = list(/obj/item/mod/module/energy_shield)
	var/max_charges = 3
	var/recharge_start_delay = 20 SECONDS
	var/charge_increment_delay = 1 SECONDS
	var/charge_recovery = 1
	var/lose_multiple_charges = FALSE
	var/recharge_path = null
	var/shield_icon_file = 'icons/effects/effects.dmi'
	var/shield_icon = "shield-red"
	var/charges

/obj/item/mod/module/energy_shield/Initialize(mapload)
	. = ..()
	charges = max_charges

/obj/item/mod/module/energy_shield/on_suit_activation()
	mod.AddComponent(/datum/component/shielded, max_charges = max_charges, recharge_start_delay = recharge_start_delay, charge_increment_delay = charge_increment_delay, \
	charge_recovery = charge_recovery, lose_multiple_charges = lose_multiple_charges, recharge_path = recharge_path, starting_charges = charges, shield_icon_file = shield_icon_file, shield_icon = shield_icon)
	RegisterSignal(mod.wearer, COMSIG_HUMAN_CHECK_SHIELDS, .proc/shield_reaction)

/obj/item/mod/module/energy_shield/on_suit_deactivation()
	var/datum/component/shielded/shield = mod.GetComponent(/datum/component/shielded)
	charges = shield.current_charges
	qdel(shield)
	UnregisterSignal(mod.wearer, COMSIG_HUMAN_CHECK_SHIELDS)

/obj/item/mod/module/energy_shield/proc/shield_reaction(mob/living/carbon/human/owner, atom/movable/hitby, damage = 0, attack_text = "the attack", attack_type = MELEE_ATTACK, armour_penetration = 0)
	if(SEND_SIGNAL(mod, COMSIG_ITEM_HIT_REACT, owner, hitby, attack_text, 0, damage, attack_type) & COMPONENT_HIT_REACTION_BLOCK)
		drain_power(use_power_cost)
		return SHIELD_BLOCK
	return NONE

/obj/item/mod/module/energy_shield/wizard
	name = "MOD battlemage shield module"
	desc = "The caster wielding this spell gains a visible barrier around them, channeling arcane power through \
		specialized runes engraved onto the surface of the suit to generate a wall of force. \
		This shield can perfectly nullify attacks ranging from high-caliber rifles to magic missiles, \
		though can also be drained by more mundane attacks. It will not protect the caster from social ridicule."
	icon_state = "battlemage_shield"
	idle_power_cost = DEFAULT_CELL_DRAIN * 0 //magic
	use_power_cost = DEFAULT_CELL_DRAIN * 0 //magic too
	max_charges = 15
	recharge_start_delay = 0 SECONDS
	charge_recovery = 8
	shield_icon_file = 'icons/effects/magic.dmi'
	shield_icon = "mageshield"
	recharge_path = /obj/item/wizard_armour_charge

/obj/item/mod/module/plasma_stabilizer
	name = "MOD plasma stabilizer module"
	desc = "This system essentially forms an atmosphere of its' own inside the suit, \
		safely ejecting oxygen from the inside and allowing the wearer, a plasmaman, \
		to have their internal plasma circulate around them somewhat like a sauna. \
		This prevents them from self-igniting, and leads to greater comfort overall. \
		The purple glass of the visor seems to be constructed for nostalgic purposes."
	icon_state = "plasma_stabilizer"
	complexity = 1
	idle_power_cost = DEFAULT_CELL_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/plasma_stabilizer)
	overlay_state_inactive = "module_plasma"

/obj/item/mod/module/plasma_stabilizer/on_equip()
	ADD_TRAIT(mod.wearer, TRAIT_NOSELFIGNITION, MOD_TRAIT)

/obj/item/mod/module/plasma_stabilizer/on_unequip()
	REMOVE_TRAIT(mod.wearer, TRAIT_NOSELFIGNITION, MOD_TRAIT)

/obj/item/mod/module/anti_magic
	name = "MOD magic nullifier module"
	desc = "A series of obsidian rods installed into critical points around the suit, \
		vibrated at a certain low frequency to enable them to resonate. \
		This creates a low-range, yet strong, magic nullification field around the user, \
		aided by a full replacement of the suit's normal coolant with holy water. \
		Spells will spall right off this field, though it'll do nothing to help others believe you about all this."
	icon_state = "magic_nullifier"
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/anti_magic)

/obj/item/mod/module/anti_magic/on_suit_activation()
	ADD_TRAIT(mod.wearer, TRAIT_ANTIMAGIC, MOD_TRAIT)
	ADD_TRAIT(mod.wearer, TRAIT_HOLY, MOD_TRAIT)

/obj/item/mod/module/anti_magic/on_suit_deactivation()
	REMOVE_TRAIT(mod.wearer, TRAIT_ANTIMAGIC, MOD_TRAIT)
	REMOVE_TRAIT(mod.wearer, TRAIT_HOLY, MOD_TRAIT)

/obj/item/mod/module/anti_magic/wizard
	name = "MOD magic neutralizer module"
	desc = "The caster wielding this spell gains an invisible barrier around them, channeling arcane power through \
		specialized runes engraved onto the surface of the suit to generate anti-magic field. \
		The field will neutralize all magic that comes into contact with the user. \
		It will not protect the caster from social ridicule."
	icon_state = "magic_neutralizer"

/obj/item/mod/module/anti_magic/wizard/on_suit_activation()
	ADD_TRAIT(mod.wearer, TRAIT_ANTIMAGIC_NO_SELFBLOCK, MOD_TRAIT)

/obj/item/mod/module/anti_magic/wizard/on_suit_deactivation()
	REMOVE_TRAIT(mod.wearer, TRAIT_ANTIMAGIC_NO_SELFBLOCK, MOD_TRAIT)

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
	var/has_tk = FALSE

/obj/item/mod/module/kinesis/on_activation()
	. = ..()
	if(!.)
		return
	if(mod.wearer.dna.check_mutation(TK))
		has_tk = TRUE
	else
		mod.wearer.dna.add_mutation(TK)

/obj/item/mod/module/kinesis/on_deactivation()
	. = ..()
	if(!.)
		return
	if(has_tk)
		has_tk = FALSE
		return
	mod.wearer.dna.remove_mutation(TK)

/obj/item/mod/module/insignia
	name = "MOD insignia module"
	desc = "Despite the existence of IFF systems, radio communique, and modern methods of deductive reasoning involving \
		the wearer's own eyes, colorful paint jobs remain a popular way for different factions in the galaxy to display who \
		they are. This system utilizes a series of tiny moving paint sprayers to both apply and remove different \
		color patterns to and from the suit."
	icon_state = "insignia"
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/insignia)
	overlay_state_inactive = "insignia"

/obj/item/mod/module/insignia/generate_worn_overlay(mutable_appearance/standing)
	overlay_state_inactive = "[initial(overlay_state_inactive)]-[mod.skin]"
	. = ..()
	for(var/mutable_appearance/appearance as anything in .)
		appearance.color = color

/obj/item/mod/module/insignia/commander
	color = "#4980a5"

/obj/item/mod/module/insignia/security
	color = "#b30d1e"

/obj/item/mod/module/insignia/engineer
	color = "#e9c80e"

/obj/item/mod/module/insignia/medic
	color = "#ebebf5"

/obj/item/mod/module/insignia/janitor
	color = "#7925c7"

/obj/item/mod/module/insignia/clown
	color = "#ff1fc7"

/obj/item/mod/module/insignia/chaplain
	color = "#f0a00c"
