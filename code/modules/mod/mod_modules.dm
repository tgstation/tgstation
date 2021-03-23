/obj/item/mod/module
	name = "MOD module"
	icon_state = "module"
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
	/// Linked MODsuit
	var/obj/item/mod/control/mod
	/// If we're an active module, what item are we?
	var/obj/item/device
	/// Overlay added to the user when equipped.
	var/mutable_appearance/wearer_overlay
	/// Overlay given to the user when the module is inactive
	var/overlay_state_inactive
	/// Overlay given to the user when the module is active
	var/overlay_state_active
	/// What modules are we incompatible with?
	var/list/incompatible_modules = list()
	/// Cooldown after use
	var/cooldown_time = 1 SECONDS
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
	if(overlay_state_active || overlay_state_inactive)
		wearer_overlay = mutable_appearance('icons/mob/mod.dmi', "[overlay_state_inactive ? overlay_state_inactive : null]", -ABOVE_BODY_FRONT_LAYER)

/obj/item/mod/module/Destroy()
	if(mod)
		mod.uninstall(src)
	if(device)
		UnregisterSignal(device, COMSIG_PARENT_PREQDELETED)
		QDEL_NULL(device)
	..()

/obj/item/mod/module/proc/on_install()
	return

/obj/item/mod/module/proc/on_uninstall()
	return

/obj/item/mod/module/proc/on_select()
	if(!mod.active)
		return
	if(module_type != MODULE_USABLE)
		if(active)
			on_deactivation()
		else
			on_activation()
	else
		on_use(mod.wearer)

/obj/item/mod/module/proc/on_activation()
	if(!COOLDOWN_FINISHED(src, cooldown_timer))
		return FALSE
	if(!mod.active || !mod.cell?.charge)
		return FALSE
	active = TRUE
	if(module_type == MODULE_ACTIVE)
		mod.selected_module.on_deactivation()
		mod.selected_module = src
		mod.wearer.put_in_hands(device)
		to_chat(mod.wearer, "<span class='notice'>You extend [device].</span>")
		RegisterSignal(mod.wearer, COMSIG_ATOM_EXITED, .proc/on_exit)
	if(wearer_overlay && overlay_state_active)
		wearer_overlay.icon_state = overlay_state_active
	COOLDOWN_START(src, cooldown_timer, cooldown_time)
	return TRUE

/obj/item/mod/module/proc/on_deactivation()
	active = FALSE
	if(module_type == MODULE_ACTIVE)
		mod.selected_module = null
		mod.wearer.transferItemToLoc(device, src, TRUE)
		to_chat(mod.wearer, "<span class='notice'>You retract [device].</span>")
		UnregisterSignal(mod.wearer, COMSIG_ATOM_EXITED)
	if(wearer_overlay && overlay_state_inactive)
		wearer_overlay.icon_state = overlay_state_inactive
	return TRUE

/obj/item/mod/module/proc/on_use(mob/living/user, atom/A)
	if(!COOLDOWN_FINISHED(src, cooldown_timer))
		return FALSE
	if(!drain_power(use_power_cost))
		return FALSE
	if(wearer_overlay && overlay_state_active)
		wearer_overlay.icon_state = overlay_state_active
		addtimer(VARSET_CALLBACK(wearer_overlay, icon_state, "[overlay_state_inactive ? overlay_state_inactive : null]"), cooldown_time)
	COOLDOWN_START(src, cooldown_timer, cooldown_time)
	return TRUE

/obj/item/mod/module/proc/on_process(delta_time)
	if(active)
		if(!drain_power(active_power_cost * delta_time))
			on_deactivation()
			return FALSE
	else
		drain_power(idle_power_cost * delta_time)
	return TRUE

/obj/item/mod/module/proc/drain_power(amount)
	if(!mod.cell || (mod.cell.charge < amount))
		return FALSE
	mod.cell.charge = max(0, mod.cell.charge - amount)
	return TRUE

/obj/item/mod/module/proc/on_exit(datum/source, atom/movable/offender, atom/newloc)
	SIGNAL_HANDLER

	if(newloc == mod.wearer || newloc == src)
		return
	if(offender == device)
		on_deactivation()

/obj/item/mod/module/proc/on_device_deletion(datum/source)
	SIGNAL_HANDLER

	if(source == device)
		device = null
		qdel(src)

/obj/item/mod/module/storage
	name = "MOD storage module"
	desc = "A module using nanotechnology to fit a storage inside of the MOD."
	complexity = 5
	incompatible_modules = list(/obj/item/mod/module/storage)
	var/datum/component/storage/concrete/storage
	var/max_w_class = WEIGHT_CLASS_SMALL
	var/max_combined_w_class = 14
	var/max_items = 7

/obj/item/mod/module/storage/antag
	name = "MOD syndicate storage module"
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 21
	max_items = 21

/obj/item/mod/module/storage/antag/wiz
	name = "MOD enchanted storage module"

/obj/item/mod/module/storage/Initialize()
	. = ..()
	storage = AddComponent(/datum/component/storage/concrete)
	storage.max_w_class = max_w_class
	storage.max_combined_w_class = max_combined_w_class
	storage.max_items = max_items

/obj/item/mod/module/storage/on_install()
	var/datum/component/storage/modstorage = mod.AddComponent(/datum/component/storage, storage)
	modstorage.max_w_class = max_w_class
	modstorage.max_combined_w_class = max_combined_w_class
	modstorage.max_items = max_items

/obj/item/mod/module/storage/on_uninstall()
	var/datum/component/storage/modstorage = mod.GetComponent(/datum/component/storage)
	modstorage.RemoveComponent()

/obj/item/mod/module/visor
	name = "MOD visor module"
	desc = "A module installed to the helmet, allowing access to different views."
	module_type = MODULE_TOGGLE
	complexity = 3
	active_power_cost = 10
	incompatible_modules = list(/obj/item/mod/module/visor)
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
		var/datum/atom_hud/HUD = GLOB.huds[hud_type]
		HUD.add_hud_to(mod.wearer)
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
		var/datum/atom_hud/HUD = GLOB.huds[hud_type]
		HUD.remove_hud_from(mod.wearer)
	for(var/trait in visor_traits)
		REMOVE_TRAIT(mod.wearer, trait, MOD_TRAIT)
	mod.wearer.update_sight()

/obj/item/mod/module/visor/medhud
	name = "MOD medical visor module"
	hud_type = DATA_HUD_MEDICAL_ADVANCED
	visor_traits = list(TRAIT_MEDICAL_HUD)

/obj/item/mod/module/visor/diaghud
	name = "MOD medical visor module"
	hud_type = DATA_HUD_DIAGNOSTIC_ADVANCED
	visor_traits = list(TRAIT_DIAGNOSTIC_HUD)

/obj/item/mod/module/visor/sechud
	name = "MOD medical visor module"
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
	complexity = 2
	active_power_cost = 50
	incompatible_modules = list(/obj/item/mod/module/health_analyzer)
	var/module_advanced = FALSE

/obj/item/mod/module/health_analyzer/on_use()
	. = ..()
	if(!.)
		return
	healthscan(mod.wearer, mod.wearer, advanced = module_advanced)
