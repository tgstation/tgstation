/obj/item/mod/module/storage
	name = "MOD storage module"
	desc = "A module using nanotechnology to fit a storage inside of the MOD."
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
	icon_state = "storage_large"
	max_combined_w_class = 21
	max_items = 14

/obj/item/mod/module/storage/syndicate
	name = "MOD syndicate storage module"
	icon_state = "storage_syndi"
	max_combined_w_class = 30
	max_items = 21

/obj/item/mod/module/storage/bluespace
	name = "MOD bluespace storage module"
	icon_state = "storage_large"
	max_w_class = WEIGHT_CLASS_GIGANTIC
	max_combined_w_class = 60
	max_items = 21

/obj/item/mod/module/visor
	name = "MOD visor module"
	desc = "A module installed to the helmet, allowing access to different views."
	module_type = MODULE_TOGGLE
	complexity = 2
	active_power_cost = 5
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
	icon_state = "medhud_visor"
	hud_type = DATA_HUD_MEDICAL_ADVANCED
	visor_traits = list(TRAIT_MEDICAL_HUD)

/obj/item/mod/module/visor/diaghud
	name = "MOD diagnostic visor module"
	icon_state = "diaghud_visor"
	hud_type = DATA_HUD_DIAGNOSTIC_ADVANCED
	visor_traits = list(TRAIT_DIAGNOSTIC_HUD)

/obj/item/mod/module/visor/sechud
	name = "MOD security visor module"
	icon_state = "sechud_visor"
	hud_type = DATA_HUD_SECURITY_ADVANCED
	visor_traits = list(TRAIT_SECURITY_HUD)

/obj/item/mod/module/visor/meson
	name = "MOD meson visor module"
	icon_state = "meson_visor"
	visor_traits = list(TRAIT_MESON_VISION, TRAIT_SUPERMATTER_MADNESS_IMMUNE)

/obj/item/mod/module/visor/thermal
	name = "MOD thermal visor module"
	icon_state = "thermal_visor"
	visor_traits = list(TRAIT_THERMAL_VISION)

/obj/item/mod/module/visor/night
	name = "MOD night visor module"
	icon_state = "night_visor"
	visor_traits = list(TRAIT_TRUE_NIGHT_VISION)

/obj/item/mod/module/welding
	name = "MOD welding protection module"
	desc = "A welding mask installed onto the helmet, giving it welding protection when powered."
	complexity = 2
	incompatible_modules = list(/obj/item/mod/module/welding)
	overlay_state_inactive = "module_welding"

/obj/item/mod/module/welding/on_equip()
	mod.helmet.flash_protect = FLASH_PROTECTION_WELDER

/obj/item/mod/module/welding/on_unequip()
	mod.helmet.flash_protect = initial(mod.helmet.flash_protect)

/obj/item/mod/module/t_ray
	name = "MOD t-ray scan module"
	desc = "A module scanning the station for pipes and wires underneath."
	module_type = MODULE_TOGGLE
	complexity = 2
	active_power_cost = 15
	incompatible_modules = list(/obj/item/mod/module/t_ray)
	cooldown_time = 0.5 SECONDS
	var/range = 2

/obj/item/mod/module/t_ray/on_active_process(delta_time)
	t_ray_scan(mod.wearer, 8, range)

/obj/item/mod/module/health_analyzer
	name = "MOD health analyzer module"
	desc = "A module with a microchip health analyzer to instantly scan vitals at a range."
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = 25
	incompatible_modules = list(/obj/item/mod/module/health_analyzer)
	cooldown_time = 0.5 SECONDS

/obj/item/mod/module/health_analyzer/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!isliving(target))
		return
	healthscan(mod.wearer, target)
	drain_power(use_power_cost)

/obj/item/mod/module/stealth
	name = "MOD prototype cloaking module"
	desc = "A module using prototype cloaking technology to hide the user from plain sight."
	icon_state = "cloak"
	module_type = MODULE_TOGGLE
	complexity = 4
	active_power_cost = 50
	use_power_cost = 100
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
	desc = "A module using advanced cloaking technology to hide the user from plain sight."
	icon_state = "cloak_ninja"
	bumpoff = FALSE
	stealth_alpha = 20
	active_power_cost = 10
	use_power_cost = 50
	cooldown_time = 3 SECONDS

/obj/item/mod/module/jetpack
	name = "MOD ion jetpack module"
	desc = "A module that runs a micro-jetpack using a MOD's power cell."
	icon_state = "jetpack"
	module_type = MODULE_TOGGLE
	complexity = 3
	active_power_cost = 10
	use_power_cost = 40
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
	if(!. || !allow_thrust())
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
	desc = "A module granting magnetic stability to the wearer, protecting them from forces pushing them away."
	icon_state = "magnet"
	module_type = MODULE_TOGGLE
	complexity = 2
	active_power_cost = 10
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
	desc = "A module that can instantly holster a gun inside the MOD."
	icon_state = "holster"
	module_type = MODULE_USABLE
	complexity = 2
	use_power_cost = 20
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

/obj/item/mod/module/holster/on_uninstall()
	if(holstered)
		holstered.forceMove(drop_location())
		holstered = null

/obj/item/mod/module/holster/Destroy()
	QDEL_NULL(holstered)
	return ..()

/obj/item/mod/module/tether
	name = "MOD emergency tether module"
	desc = "A module that can shoot an emergency tether to pull yourself towards an object in 0-G."
	icon_state = "tether"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_power_cost = 50
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
	desc = "A module that enables eating with the MOD helmet."
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
	desc = "A module that lets the MOD scan for radiation and protects the user from it."
	complexity = 2
	idle_power_cost = 10
	incompatible_modules = list(/obj/item/mod/module/rad_protection)
	tgui_id = "rad_counter"
	var/perceived_threat_level

/obj/item/mod/module/rad_protection/on_equip()
	AddComponent(/datum/component/geiger_sound)
	ADD_TRAIT(mod.wearer, TRAIT_BYPASS_EARLY_IRRADIATED_CHECK, MOD_TRAIT)
	RegisterSignal(mod.wearer, COMSIG_IN_RANGE_OF_IRRADIATION, .proc/on_pre_potential_irradiation)
	for(var/obj/item/part in mod.mod_parts)
		ADD_TRAIT(part, TRAIT_RADIATION_PROTECTED_CLOTHING, MOD_TRAIT)

/obj/item/mod/module/rad_protection/on_unequip()
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
	desc = "A module that shields the MOD from EMPs, taking a power cost for that."
	complexity = 1
	idle_power_cost = 10
	incompatible_modules = list(/obj/item/mod/module/emp_shield)

/obj/item/mod/module/emp_shield/on_install()
	mod.AddElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_WIRES|EMP_PROTECT_CONTENTS)

/obj/item/mod/module/emp_shield/on_uninstall()
	mod.RemoveElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_WIRES|EMP_PROTECT_CONTENTS)

/obj/item/mod/module/flashlight
	name = "MOD flashlight module"
	desc = "A module granting the MOD a light source."
	icon_state = "flashlight"
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = 10
	incompatible_modules = list(/obj/item/mod/module/flashlight)
	cooldown_time = 0.5 SECONDS
	overlay_state_inactive = "module_light"
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_color = COLOR_WHITE
	light_range = 3
	light_power = 1
	light_on = FALSE
	var/base_power = 2
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

/obj/item/mod/module/flashlight/generate_worn_overlay()
	. = ..()
	if(!active)
		return
	var/mutable_appearance/light_icon = mutable_appearance('icons/mob/mod.dmi', "module_light_on")
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
			if(color_hex2num(value) < 150)
				balloon_alert(mod.wearer, "too dark!")
				return
			set_light_color(value)
			mod.wearer.update_inv_back()
		if("light_range")
			set_light_range(clamp(value, min_range, max_range))

/obj/item/mod/module/reagent_scanner
	name = "MOD reagent scanner module"
	desc = "A module that enables internal reagent scanners in the MOD."
	icon_state = "scanner"
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = 5
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
	desc = "A module that dispenses burgers."
	module_type = MODULE_USABLE
	complexity = 3
	use_power_cost = 50
	incompatible_modules = list(/obj/item/mod/module/dispenser)
	cooldown_time = 5 SECONDS
	var/dispense_type = /obj/item/food/burger/plain
	var/dispense_time = 0 SECONDS

/obj/item/mod/module/dispenser/on_use()
	. = ..()
	if(!.)
		return
	if(dispense_time && !do_after(mod.wearer, dispense_time, src))
		return
	var/obj/item/dispensed = new dispense_type(mod.wearer.loc)
	mod.wearer.put_in_hands(dispensed)
	balloon_alert(mod.wearer, "[dispensed] dispensed")
	playsound(src, 'sound/machines/click.ogg', 100, TRUE)
	drain_power(use_power_cost)

/obj/item/mod/module/gps
	name = "MOD internal GPS module"
	desc = "A module that extends a GPS."
	module_type = MODULE_ACTIVE
	complexity = 1
	active_power_cost = 5
	device = /obj/item/gps/mod
	incompatible_modules = list(/obj/item/mod/module/gps)
	cooldown_time = 0.5 SECONDS

/obj/item/gps/mod
	name = "MOD internal GPS"
	desc = "A MODsuit internal positioning system."
	icon_state = "gps-b"
	gpstag = "MOD0"

/obj/item/mod/module/constructor
	name = "MOD constructor module"
	desc = "A module that lets you scan the surrounding environment for construction holograms and speeds up wall construction time."
	icon_state = "constructor"
	module_type = MODULE_USABLE
	complexity = 2
	idle_power_cost = 3
	use_power_cost = 50
	incompatible_modules = list(/obj/item/mod/module/constructor, /obj/item/mod/module/quick_carry)
	cooldown_time = 11 SECONDS

/obj/item/mod/module/constructor/on_equip()
	ADD_TRAIT(mod.wearer, TRAIT_QUICK_BUILD, MOD_TRAIT)

/obj/item/mod/module/constructor/on_unequip()
	REMOVE_TRAIT(mod.wearer, TRAIT_QUICK_BUILD, MOD_TRAIT)

/obj/item/mod/module/constructor/on_use()
	. = ..()
	if(!.)
		return
	rcd_scan(src, fade_time = 10 SECONDS)
	drain_power(use_power_cost)

/obj/item/mod/module/quick_carry
	name = "MOD quick carry module"
	desc = "A module that redirects power to arms, allowing for quicker carrying."
	icon_state = "constructor"
	complexity = 1
	idle_power_cost = 3
	incompatible_modules = list(/obj/item/mod/module/quick_carry, /obj/item/mod/module/constructor)

/obj/item/mod/module/quick_carry/on_equip()
	ADD_TRAIT(mod.wearer, TRAIT_QUICK_CARRY, MOD_TRAIT)

/obj/item/mod/module/quick_carry/on_unequip()
	REMOVE_TRAIT(mod.wearer, TRAIT_QUICK_CARRY, MOD_TRAIT)

/obj/item/mod/module/quick_carry/advanced
	name = "MOD advanced quick carry module"
	removable = FALSE
	complexity = 0

/obj/item/mod/module/quick_carry/on_equip()
	ADD_TRAIT(mod.wearer, TRAIT_QUICKER_CARRY, MOD_TRAIT)
	ADD_TRAIT(mod.wearer, TRAIT_FASTMED, MOD_TRAIT)

/obj/item/mod/module/quick_carry/on_unequip()
	REMOVE_TRAIT(mod.wearer, TRAIT_QUICKER_CARRY, MOD_TRAIT)
	REMOVE_TRAIT(mod.wearer, TRAIT_FASTMED, MOD_TRAIT)

/obj/item/mod/module/longfall
	name = "MOD longfall module"
	desc = "A module that stops fall damage from happening to the user, converting into kinetic charge."
	complexity = 1
	use_power_cost = 100
	incompatible_modules = list(/obj/item/mod/module/longfall)

/obj/item/mod/module/longfall/on_equip()
	RegisterSignal(mod.wearer, COMSIG_LIVING_Z_IMPACT, .proc/z_impact_react)

/obj/item/mod/module/longfall/on_unequip()
	UnregisterSignal(mod.wearer, COMSIG_LIVING_Z_IMPACT)

/obj/item/mod/module/longfall/proc/z_impact_react(datum/source, levels, turf/fell_on)
	if(!drain_power(use_power_cost*levels))
		return
	new /obj/effect/temp_visual/mook_dust(fell_on)
	mod.wearer.Stun(levels * 1 SECONDS)
	to_chat(mod.wearer, span_notice("[src] protects you from the damage!"))
	return COMPONENT_NO_Z_DAMAGE

/obj/item/mod/module/thermal_regulator
	name = "MOD thermal regulator module"
	desc = "A module that lets you set a temperature to keep your body at."
	icon_state = "regulator"
	module_type = MODULE_TOGGLE
	complexity = 2
	active_power_cost = 5
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
	desc = "A module that extends a piercing injector."
	module_type = MODULE_ACTIVE
	complexity = 1
	active_power_cost = 5
	device = /obj/item/reagent_containers/syringe/mod
	incompatible_modules = list(/obj/item/mod/module/injector)
	cooldown_time = 0.5 SECONDS

/obj/item/reagent_containers/syringe/mod
	name = "MOD injector syringe"
	desc = "A piercing injector fitting in a MODsuit."
	icon_state = "mod_0"
	base_icon_state = "mod"
	amount_per_transfer_from_this = 30
	possible_transfer_amounts = list(5, 10, 15, 20, 30)
	volume = 30
	inject_flags = INJECT_CHECK_PENETRATE_THICK

/obj/item/mod/module/circuit
	name = "MOD circuit adapter module"
	desc = "A module that adapts an integrated circuit to a MODsuit."
	module_type = MODULE_USABLE
	complexity = 3
	idle_power_cost = 5
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

/obj/item/mod/module/circuit/on_equip()
	circuit.set_on(TRUE)

/obj/item/mod/module/circuit/on_unequip()
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
	desc = "A specialized clamp system that allows the MODSuit to pick up crates."
	module_type = MODULE_ACTIVE
	complexity = 3
	use_power_cost = 25
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

/obj/item/mod/module/bikehorn
	name = "MOD bike horn module"
	desc = "A bike horn for honking."
	module_type = MODULE_USABLE
	complexity = 1
	use_power_cost = 25
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
	desc = "A specialized drilling system that allows the MODsuit to pierce the heavens."
	icon_state = "drill"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = 50
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
	desc = "An integrated ore storage system that allows the MODsuit to automatically collect and deposit ore."
	module_type = MODULE_USABLE
	complexity = 2
	use_power_cost = 25
	incompatible_modules = list(/obj/item/mod/module/orebag)
	cooldown_time = 0.5 SECONDS
	var/list/ores = list()

/obj/item/mod/module/orebag/on_equip()
	. = ..()
	if(!.)
		return
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, .proc/ore_pickup)

/obj/item/mod/module/orebag/on_unequip()
	. = ..()
	if(!.)
		return
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
		ore.forceMove(mod.drop_location())
		ores -= ore
	drain_power(use_power_cost)

/obj/item/mod/module/microwave_beam
	name = "MOD microwave beam module"
	desc = "A hand-mounted microwave beam to cook your food to perfection."
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = 50
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
	desc = "An arm mounted organ launching device to automatically insert organs into open bodies."
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = 50
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
	desc = "A module linked to an implant, able to find the user and attach itself onto them. To inject the implant, hit someone with it."
	icon_state = "pathfinder"
	complexity = 2
	use_power_cost = 100
	incompatible_modules = list(/obj/item/mod/module/pathfinder)
	var/obj/item/implant/mod/implant

/obj/item/mod/module/pathfinder/Initialize(mapload)
	. = ..()
	implant = new(src)

/obj/item/mod/module/pathfinder/Destroy()
	implant = null
	return ..()

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
	desc = "A module that locks the MODsuit's activation to the wearer's DNA. Shorted out by EMPs."
	module_type = MODULE_USABLE
	complexity = 2
	use_power_cost = 100
	incompatible_modules = list(/obj/item/mod/module/dna_lock)
	cooldown_time = 0.5 SECONDS
	var/dna = null

/obj/item/mod/module/dna_lock/on_install()
	RegisterSignal(mod, COMSIG_MOD_ACTIVATE, .proc/on_mod_activation)
	RegisterSignal(mod, COMSIG_ATOM_EMP_ACT, .proc/on_emp)
	RegisterSignal(mod, COMSIG_ATOM_EMAG_ACT, .proc/on_emag)

/obj/item/mod/module/dna_lock/on_uninstall()
	UnregisterSignal(mod, COMSIG_MOD_ACTIVATE)
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

/obj/item/mod/module/dna_lock/proc/on_emp(datum/source, severity)
	SIGNAL_HANDLER

	dna = null

/obj/item/mod/module/dna_lock/proc/on_emag(datum/source, mob/user, obj/item/card/emag/emag_card)
	SIGNAL_HANDLER

	dna = null

/obj/item/mod/module/dna_lock/proc/on_mod_activation(datum/source)
	SIGNAL_HANDLER

	if(!dna || (mod.wearer.has_dna() && mod.wearer.dna.unique_enzymes == dna))
		return
	balloon_alert(mod.wearer, "dna locked!")
	return MOD_CANCEL_ACTIVATE

/obj/item/mod/module/armor_booster
	name = "MOD armor booster module"
	desc = "A module that uses the suit's power to boost armor. To increase efficiency, some parts of the armor are retracted."
	idle_power_cost = 5
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/armor_booster)
	var/remove_pressure_protection = TRUE
	var/list/armor_values = list(MELEE = 40, BULLET = 50, LASER = 30, ENERGY = 40)
	var/list/spaceproofed = list()

/obj/item/mod/module/armor_booster/on_equip()
	var/list/parts = mod.mod_parts + mod
	for(var/obj/item/part as anything in parts)
		part.armor = part.armor.modifyRating(arglist(armor_values))
		if(!remove_pressure_protection || !isclothing(part))
			continue
		var/obj/item/clothing/clothing_part = part
		if(clothing_part.clothing_flags & STOPSPRESSUREDAMAGE)
			clothing_part.clothing_flags &= ~STOPSPRESSUREDAMAGE
			spaceproofed[clothing_part] = TRUE

/obj/item/mod/module/armor_booster/on_unequip()
	var/list/parts = mod.mod_parts + mod
	var/list/removed_armor = armor_values.Copy()
	for(var/value in removed_armor)
		value = -value
	for(var/obj/item/part as anything in parts)
		part.armor = part.armor.modifyRating(arglist(removed_armor))
		if(!remove_pressure_protection || !isclothing(part))
			continue
		var/obj/item/clothing/clothing_part = part
		if(spaceproofed[clothing_part])
			clothing_part.clothing_flags |= STOPSPRESSUREDAMAGE
	spaceproofed = list()

/obj/item/mod/module/armor_booster/elite
	name = "MOD elite armor booster module"
	armor_values = list(MELEE = 60, BULLET = 60, LASER = 50, ENERGY = 60)
