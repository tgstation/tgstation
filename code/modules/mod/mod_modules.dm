/obj/item/mod/module
	name = "MOD module"
	icon_state = "module"
	interaction_flags_atom = NONE
	/// If it can be removed
	var/removable = TRUE
	/// If it's passive, active or usable
	var/module_type = MODULE_PASSIVE
	/// Is the module active
	var/active = FALSE
	/// How much space it takes up in the MOD
	var/complexity = 0
	/// Power use when idle
	var/idle_power_cost = 0
	/// Power use when active
	var/active_power_cost = 0
	/// Power use when used
	var/use_power_cost = 0
	/// ID used by their TGUI
	var/tgui_id = null
	/// Can we be configured
	var/configurable = FALSE
	/// Linked MODsuit
	var/obj/item/mod/control/mod
	/// If we're an active module, what item are we?
	var/obj/item/device
	/// Overlay given to the user when the module is inactive
	var/overlay_state_inactive
	/// Overlay given to the user when the module is active
	var/overlay_state_active
	/// Overlay given to the user when the module is used, lasts until cooldown finishes
	var/overlay_state_use
	/// What modules are we incompatible with?
	var/list/incompatible_modules = list()
	/// Cooldown after use
	var/cooldown_time = 0
	/// Timer for the cooldown
	COOLDOWN_DECLARE(cooldown_timer)

/obj/item/mod/module/Initialize()
	. = ..()
	if(module_type != MODULE_ACTIVE)
		return
	if(ispath(device))
		device = new device(src)
		ADD_TRAIT(device, TRAIT_NODROP, MOD_TRAIT)
		RegisterSignal(device, COMSIG_PARENT_PREQDELETED, .proc/on_device_deletion)
		RegisterSignal(src, COMSIG_ATOM_EXITED, .proc/on_exit)

/obj/item/mod/module/Destroy()
	mod?.uninstall(src)
	if(device)
		UnregisterSignal(device, COMSIG_PARENT_PREQDELETED)
		QDEL_NULL(device)
	..()

/// Called from MODsuit's install() proc, so when the module is installed.
/obj/item/mod/module/proc/on_install()
	return

/// Called from MODsuit's uninstall() proc, so when the module is uninstalled.
/obj/item/mod/module/proc/on_uninstall()
	return

/// Called when the MODsuit is activated
/obj/item/mod/module/proc/on_equip()
	return

/// Called when the MODsuit is deactivated
/obj/item/mod/module/proc/on_unequip()
	return

/// Called when the module is selected from the TGUI
/obj/item/mod/module/proc/on_select()
	if(!mod.active || mod.activating)
		return
	if(module_type != MODULE_USABLE)
		if(active)
			on_deactivation()
		else
			on_activation()
	else
		on_use(mod.wearer)

/// Called when the module is activated
/obj/item/mod/module/proc/on_activation()
	if(!COOLDOWN_FINISHED(src, cooldown_timer))
		return FALSE
	if(!mod.active || mod.activating || !mod.cell?.charge)
		return FALSE
	active = TRUE
	if(module_type == MODULE_ACTIVE)
		if(mod.selected_module)
			mod.selected_module.on_deactivation()
		mod.selected_module = src
		if(device)
			mod.wearer.put_in_hands(device)
			to_chat(mod.wearer, "<span class='notice'>You extend [device].</span>")
			RegisterSignal(mod.wearer, COMSIG_ATOM_EXITED, .proc/on_exit)
		else
			to_chat(mod.wearer, "<span class='notice'>You activate [src]. You can use the middle-mouse button or alt-click to use it.</span>")
			RegisterSignal(mod.wearer, COMSIG_MOB_MIDDLECLICKON, .proc/on_select_use)
			RegisterSignal(mod.wearer, COMSIG_MOB_ALTCLICKON, .proc/on_select_use)
	COOLDOWN_START(src, cooldown_timer, cooldown_time)
	mod.wearer.update_inv_back()
	return TRUE

/// Called when the module is deactivated
/obj/item/mod/module/proc/on_deactivation()
	active = FALSE
	if(module_type == MODULE_ACTIVE)
		mod.selected_module = null
		if(device)
			mod.wearer.transferItemToLoc(device, src, TRUE)
			to_chat(mod.wearer, "<span class='notice'>You retract [device].</span>")
			UnregisterSignal(mod.wearer, COMSIG_ATOM_EXITED)
		else
			to_chat(mod.wearer, "<span class='notice'>You deactivate [src].</span>")
			UnregisterSignal(mod.wearer, COMSIG_MOB_MIDDLECLICKON)
			UnregisterSignal(mod.wearer, COMSIG_MOB_ALTCLICKON)
	mod.wearer.update_inv_back()
	return TRUE

/// Called when the module is used
/obj/item/mod/module/proc/on_use()
	if(!COOLDOWN_FINISHED(src, cooldown_timer))
		return FALSE
	if(!drain_power(use_power_cost))
		return FALSE
	COOLDOWN_START(src, cooldown_timer, cooldown_time)
	addtimer(CALLBACK(mod.wearer, /mob.proc/update_inv_back), cooldown_time)
	mod.wearer.update_inv_back()
	return TRUE

/// Called when an activated module without a device is used with middle/alt click
/obj/item/mod/module/proc/on_select_use(mob/source, atom/target)
	SIGNAL_HANDLER

	if(!on_use())
		return NONE
	return COMSIG_MOB_CANCEL_CLICKON

/// Called on the MODsuit's process
/obj/item/mod/module/proc/on_process(delta_time)
	if(active)
		if(!drain_power(active_power_cost * delta_time))
			on_deactivation()
			return FALSE
	else
		drain_power(idle_power_cost * delta_time)
	return TRUE

/// Drains power from the suit cell
/obj/item/mod/module/proc/drain_power(amount)
	if(!mod.cell || (mod.cell.charge < amount))
		return FALSE
	mod.cell.charge = max(0, mod.cell.charge - amount)
	return TRUE

/// Adds additional things to the MODsuit ui_data()
/obj/item/mod/module/proc/add_ui_data()
	return list()

/// Creates a list of configuring options for this module
/obj/item/mod/module/proc/add_configure_data()
	return list()

/// Receives configure edits from the TGUI and edits the vars
/obj/item/mod/module/proc/configure_edit(key, value)
	return

/// Called when the device moves to a different place on active modules
/obj/item/mod/module/proc/on_exit(datum/source, atom/movable/offender, atom/newloc)
	SIGNAL_HANDLER

	if(newloc == mod.wearer || newloc == src)
		return
	if(offender == device)
		on_deactivation()

/// Called when the device gets deleted on active modules
/obj/item/mod/module/proc/on_device_deletion(datum/source)
	SIGNAL_HANDLER

	if(source == device)
		device = null
		qdel(src)

/// Generates an icon to be used for the suit's worn overlays
/obj/item/mod/module/proc/generate_worn_overlay()
	. = list()
	var/used_overlay
	if(overlay_state_use && !COOLDOWN_FINISHED(src, cooldown_timer))
		used_overlay = overlay_state_use
	else if(overlay_state_active && active)
		used_overlay = overlay_state_active
	else if(overlay_state_inactive)
		used_overlay = overlay_state_inactive
	var/mutable_appearance/module_icon = mutable_appearance('icons/mob/mod.dmi', used_overlay)
	. += module_icon

/obj/item/mod/module/storage
	name = "MOD storage module"
	desc = "A module using nanotechnology to fit a storage inside of the MOD."
	complexity = 5
	incompatible_modules = list(/obj/item/mod/module/storage)
	var/datum/component/storage/concrete/storage
	var/max_w_class = WEIGHT_CLASS_SMALL
	var/max_combined_w_class = 14
	var/max_items = 7

/obj/item/mod/module/storage/Initialize()
	. = ..()
	storage = AddComponent(/datum/component/storage/concrete)
	storage.max_w_class = max_w_class
	storage.max_combined_w_class = max_combined_w_class
	storage.max_items = max_items

/obj/item/mod/module/storage/on_install()
	w_class = WEIGHT_CLASS_BULKY //this sucks but we need it to not run into errors with storage inside storage
	var/datum/component/storage/modstorage = mod.AddComponent(/datum/component/storage, storage)
	modstorage.max_w_class = max_w_class
	modstorage.max_combined_w_class = max_combined_w_class
	modstorage.max_items = max_items

/obj/item/mod/module/storage/on_uninstall()
	w_class = initial(w_class)
	qdel(mod.GetComponent(/datum/component/storage))

/obj/item/mod/module/storage/antag
	name = "MOD syndicate storage module"
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 21
	max_items = 21

/obj/item/mod/module/storage/antag/wiz
	name = "MOD enchanted storage module"

/obj/item/mod/module/visor
	name = "MOD visor module"
	desc = "A module installed to the helmet, allowing access to different views."
	module_type = MODULE_TOGGLE
	complexity = 3
	active_power_cost = 10
	incompatible_modules = list(/obj/item/mod/module/visor)
	cooldown_time = 0.5 SECONDS
	var/helmet_tint = 0
	var/helmet_flash_protect = FLASH_PROTECTION_NONE
	var/hud_type = null
	var/list/visor_traits = list()

/obj/item/mod/module/visor/on_activation()
	. = ..()
	if(!.)
		return
	mod.helmet.tint = helmet_tint
	mod.helmet.flash_protect = helmet_flash_protect
	if(hud_type)
		var/datum/atom_hud/hud = GLOB.huds[hud_type]
		hud.add_hud_to(mod.wearer)
	for(var/trait in visor_traits)
		ADD_TRAIT(mod.wearer, trait, MOD_TRAIT)
	mod.wearer.update_sight()
	mod.wearer.update_tint()

/obj/item/mod/module/visor/on_deactivation()
	. = ..()
	if(!.)
		return
	mod.helmet.tint = initial(mod.helmet.tint)
	mod.helmet.flash_protect = initial(mod.helmet.flash_protect)
	if(hud_type)
		var/datum/atom_hud/hud = GLOB.huds[hud_type]
		hud.remove_hud_from(mod.wearer)
	for(var/trait in visor_traits)
		REMOVE_TRAIT(mod.wearer, trait, MOD_TRAIT)
	mod.wearer.update_sight()
	mod.wearer.update_tint()

/obj/item/mod/module/visor/medhud
	name = "MOD medical visor module"
	hud_type = DATA_HUD_MEDICAL_ADVANCED
	visor_traits = list(TRAIT_MEDICAL_HUD)

/obj/item/mod/module/visor/diaghud
	name = "MOD diagnostic visor module"
	hud_type = DATA_HUD_DIAGNOSTIC_ADVANCED
	visor_traits = list(TRAIT_DIAGNOSTIC_HUD)

/obj/item/mod/module/visor/sechud
	name = "MOD security visor module"
	hud_type = DATA_HUD_SECURITY_ADVANCED
	visor_traits = list(TRAIT_SECURITY_HUD)

/obj/item/mod/module/visor/welding
	name = "MOD welding visor module"
	helmet_tint = 2
	helmet_flash_protect = FLASH_PROTECTION_WELDER

/obj/item/mod/module/visor/sunglasses
	name = "MOD protective visor module"
	helmet_tint = 1
	helmet_flash_protect = FLASH_PROTECTION_FLASH

/obj/item/mod/module/visor/meson
	name = "MOD meson visor module"
	visor_traits = list(TRAIT_MESON_VISION)

/obj/item/mod/module/health_analyzer
	name = "MOD health analyzer module"
	desc = "A module with a microchip health analyzer to instantly scan the wearer's vitals."
	module_type = MODULE_USABLE
	complexity = 1
	use_power_cost = 30
	incompatible_modules = list(/obj/item/mod/module/health_analyzer)
	cooldown_time = 0.5 SECONDS
	var/module_advanced = FALSE

/obj/item/mod/module/health_analyzer/on_use()
	. = ..()
	if(!.)
		return
	healthscan(mod.wearer, mod.wearer, advanced = module_advanced)

/obj/item/mod/module/stealth
	name = "MOD prototype cloaking module"
	desc = "A module using prototype cloaking technology to hide the user from plain sight."
	module_type = MODULE_TOGGLE
	complexity = 5
	active_power_cost = 50
	use_power_cost = 150
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
	RegisterSignal(mod.wearer, list(COMSIG_ITEM_ATTACK, COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_ATTACK_PAW, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_CARBON_CUFF_ATTEMPTED), .proc/unstealth)
	animate(mod.wearer, alpha = stealth_alpha, time = 1.5 SECONDS)

/obj/item/mod/module/stealth/on_deactivation()
	. = ..()
	if(!.)
		return
	if(bumpoff)
		UnregisterSignal(mod.wearer, COMSIG_LIVING_MOB_BUMP)
	UnregisterSignal(mod.wearer, list(COMSIG_HUMAN_MELEE_UNARMED_ATTACK, COMSIG_ITEM_ATTACK, COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_CARBON_CUFF_ATTEMPTED))
	animate(mod.wearer, alpha = 255, time = 1.5 SECONDS)

/obj/item/mod/module/stealth/proc/unstealth(datum/source)
	SIGNAL_HANDLER

	to_chat(mod.wearer, "<span class='warning'>[src] gets discharged from contact!</span>")
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

	if(!projectile.nodamage)
		unstealth(source)

/obj/item/mod/module/stealth/ninja
	name = "MOD advanced cloaking module"
	desc = "A module using advanced cloaking technology to hide the user from plain sight."
	bumpoff = FALSE
	stealth_alpha = 20
	active_power_cost = 10
	use_power_cost = 50
	cooldown_time = 3 SECONDS

/obj/item/mod/module/jetpack
	name = "MOD ion jetpack module"
	desc = "A module that runs a micro-jetpack using a MOD's power cell."
	module_type = MODULE_TOGGLE
	complexity = 3
	active_power_cost = 20
	use_power_cost = 80
	incompatible_modules = list(/obj/item/mod/module/jetpack)
	cooldown_time = 0.5 SECONDS
	configurable = TRUE
	var/stabilizers = FALSE
	var/full_speed = FALSE
	var/datum/effect_system/trail_follow/ion/ion_trail

/obj/item/mod/module/jetpack/Initialize()
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
	mod.wearer.remove_movespeed_modifier(/datum/movespeed_modifier/jetpack/fullspeed)

/obj/item/mod/module/jetpack/proc/move_react(mob/user)
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
	module_type = MODULE_TOGGLE
	complexity = 2
	active_power_cost = 20
	incompatible_modules = list(/obj/item/mod/module/magboot)
	cooldown_time = 0.5 SECONDS
	var/slowdown_active = 1

/obj/item/mod/module/magboot/on_activation()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(mod.wearer, TRAIT_NEGATES_GRAVITY, MOD_TRAIT)
	mod.slowdown += slowdown_active
	mod.wearer.update_equipment_speed_mods()
	mod.wearer.update_gravity(mod.wearer.has_gravity())

/obj/item/mod/module/magboot/on_deactivation()
	. = ..()
	if(!.)
		return
	REMOVE_TRAIT(mod.wearer, TRAIT_NEGATES_GRAVITY, MOD_TRAIT)
	mod.slowdown -= slowdown_active
	mod.wearer.update_equipment_speed_mods()
	mod.wearer.update_gravity(mod.wearer.has_gravity())

/obj/item/mod/module/holster
	name = "MOD holster module"
	desc = "A module that can instantly holster a gun inside the MOD."
	module_type = MODULE_USABLE
	complexity = 2
	use_power_cost = 25
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
			to_chat(mod.wearer, "<span class='notice'>You aren't holding anything to holster!</span>")
			return
		if(!istype(holding) || holding.w_class > WEIGHT_CLASS_BULKY || holding.weapon_weight > WEAPON_MEDIUM)
			to_chat(mod.wearer, "<span class='notice'>[holding] doesn't fit in the holster!</span>")
			return
		if(mod.wearer.transferItemToLoc(holding, src, FALSE, FALSE))
			holstered = holding
			to_chat(mod.wearer, "<span class='notice'>You holster [holstered].</span>")
			playsound(src, 'sound/weapons/gun/revolver/empty.ogg', 100, TRUE)
	else if(mod.wearer.put_in_active_hand(holstered, FALSE, TRUE))
		to_chat(mod.wearer, "<span class='notice'>You draw [holstered].</span>")
		holstered = null
		playsound(src, 'sound/weapons/gun/revolver/empty.ogg', 100, TRUE)

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
	module_type = MODULE_ACTIVE
	complexity = 3
	use_power_cost = 50
	incompatible_modules = list(/obj/item/mod/module/tether)
	cooldown_time = 1.5 SECONDS

/obj/item/mod/module/tether/on_use()
	if(mod.wearer.has_gravity(get_turf(src)))
		to_chat(mod.wearer, "<span class='warning'>You need to be in a 0-G environment to use [src]!</span>")
		playsound(src, 'sound/weapons/gun/general/dry_fire.ogg', 25, TRUE)
		return FALSE
	return ..()

/obj/item/mod/module/tether/on_select_use(mob/source, atom/target)
	. = ..()
	if(!.)
		return
	var/obj/projectile/tether = new /obj/projectile/tether
	tether.preparePixelProjectile(target, mod.wearer)
	tether.firer = mod.wearer
	INVOKE_ASYNC(tether, /obj/projectile/proc/fire)

/obj/projectile/tether
	name = "tether"
	icon_state = "tether"
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
	complexity = 2
	incompatible_modules = list(/obj/item/mod/module/mouthhole)
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

/obj/item/mod/module/rad_counter
	name = "MOD radiation counter module"
	desc = "A module that enables a radiation scan in the MOD."
	complexity = 1
	idle_power_cost = 3
	incompatible_modules = list(/obj/item/mod/module/rad_counter)
	tgui_id = "rad_counter"
	var/current_tick_amount = 0
	var/radiation_count = 0
	var/grace = RAD_GEIGER_GRACE_PERIOD
	var/datum/looping_sound/geiger/soundloop

/obj/item/mod/module/rad_counter/Initialize()
	. = ..()
	soundloop = new(list(), FALSE, TRUE)
	soundloop.volume = 5

/obj/item/mod/module/rad_counter/on_equip()
	soundloop.start(mod.wearer)
	RegisterSignal(mod, COMSIG_ATOM_RAD_ACT, .proc/rad_react)

/obj/item/mod/module/rad_counter/on_unequip()
	soundloop.stop(mod.wearer)
	UnregisterSignal(mod, COMSIG_ATOM_RAD_ACT)

/obj/item/mod/module/rad_counter/on_process(delta_time)
	. = ..()
	if(!.)
		return
	radiation_count = LPFILTER(radiation_count, current_tick_amount, delta_time, RAD_GEIGER_RC)
	if(current_tick_amount)
		grace = RAD_GEIGER_GRACE_PERIOD
	else
		grace -= delta_time
		if(grace <= 0)
			radiation_count = 0
	current_tick_amount = 0
	soundloop.last_radiation = radiation_count

/obj/item/mod/module/rad_counter/add_ui_data()
	. = ..()
	.["userrads"] = mod.wearer ? mod.wearer.radiation : 0
	.["usercontam"] = mod.wearer ? get_rad_contamination(mod.wearer) : 0
	.["radcount"] = radiation_count

/obj/item/mod/module/rad_counter/proc/rad_react(datum/source, amount)
	if(amount <= RAD_BACKGROUND_RADIATION)
		return
	current_tick_amount += amount

/obj/item/mod/module/emp_shield
	name = "MOD EMP shield module"
	desc = "A module that shields the MOD from EMP's."
	complexity = 2
	idle_power_cost = 10
	incompatible_modules = list(/obj/item/mod/module/emp_shield)

/obj/item/mod/module/emp_shield/on_install()
	. = ..()
	mod.AddElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_WIRES|EMP_PROTECT_CONTENTS)

/obj/item/mod/module/emp_shield/on_uninstall()
	mod.RemoveElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_WIRES|EMP_PROTECT_CONTENTS)

/obj/item/mod/module/flashlight
	name = "MOD flashlight module"
	desc = "A module granting the MOD a light source."
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = 15
	incompatible_modules = list(/obj/item/mod/module/flashlight)
	cooldown_time = 0.5 SECONDS
	overlay_state_inactive = "module_light"
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_color = COLOR_WHITE
	light_range = 3
	light_power = 1
	light_on = FALSE
	var/base_power = 5
	var/min_range = 1
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
	if(!. || !active)
		return
	var/mutable_appearance/light_icon = mutable_appearance('icons/mob/mod.dmi', "module_light_on")
	light_icon.appearance_flags = RESET_COLOR
	light_icon.color = light_color
	. += light_icon

/obj/item/mod/module/flashlight/add_configure_data()
	. = ..()
	.["light_color"] = "color"
	.["light_range"] = "number"

/obj/item/mod/module/flashlight/configure_edit(key, value)
	switch(key)
		if("light_color")
			var/new_color = input(usr, "Pick new light color", "Flashlight Color") as color|null
			if(new_color)
				light_color = new_color
				mod.wearer.update_inv_back()
		if("light_range")
			light_range = clamp(value, min_range, max_range)

/obj/item/mod/module/science_scanner
	name = "MOD science scanner module"
	desc = "A module that enables internal research and reagent scanners in the MOD."
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = 5
	incompatible_modules = list(/obj/item/mod/module/science_scanner)
	cooldown_time = 0.5 SECONDS

/obj/item/mod/module/science_scanner/on_activation()
	. = ..()
	if(!.)
		return
	mod.wearer.research_scanner++
	mod.helmet.clothing_flags |= SCAN_REAGENTS

/obj/item/mod/module/science_scanner/on_deactivation()
	. = ..()
	if(!.)
		return
	mod.wearer.research_scanner--
	mod.helmet.clothing_flags &= ~SCAN_REAGENTS
