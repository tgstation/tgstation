/// MODsuits, trade-off between armor and utility
/obj/item/mod
	name = "Base MOD"
	desc = "You should not see this, yell at a coder!"
	icon = 'icons/obj/mod.dmi'
	icon_state = "mod_shell"
	worn_icon = 'icons/mob/mod.dmi'

/obj/item/mod/control
	name = "MOD control unit"
	desc = "The control unit of a Modular Outerwear Device, a powered, back-mounted suit that protects against various environments. Technology is amazing."
	icon_state = "control"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	strip_delay = 10 SECONDS
	slowdown = 2
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 0, FIRE = 25, ACID = 25, WOUND = 10)
	actions_types = list(/datum/action/item_action/mod/deploy, /datum/action/item_action/mod/activate, /datum/action/item_action/mod/panel)
	resistance_flags = NONE
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	siemens_coefficient = 0.5
	/// The MOD's theme, decides on some stuff like armor and statistics.
	var/datum/mod_theme/theme = /datum/mod_theme
	/// Looks of the MOD.
	var/skin = "standard"
	/// If the suit is deployed and turned on.
	var/active = FALSE
	/// If the suit wire/module hatch is open.
	var/open = FALSE
	/// If the suit is ID locked.
	var/locked = FALSE
	/// If the suit is malfunctioning.
	var/malfunctioning = FALSE
	/// If the suit is currently activating/deactivating.
	var/activating = FALSE
	/// How long the MOD is electrified for.
	var/seconds_electrified = MACHINE_NOT_ELECTRIFIED
	/// If the suit interface is broken.
	var/interface_break = FALSE
	/// How much module complexity can this MOD carry.
	var/complexity_max = DEFAULT_MAX_COMPLEXITY
	/// How much module complexity this MOD is carrying.
	var/complexity = 0
	/// Power usage of the MOD.
	var/cell_drain = 0
	/// Slowdown when active.
	var/slowdown_active = 1
	/// MOD cell.
	var/obj/item/stock_parts/cell/cell
	/// MOD helmet.
	var/obj/item/clothing/head/helmet/space/mod/helmet
	/// MOD chestplate.
	var/obj/item/clothing/suit/armor/mod/chestplate
	/// MOD gauntlets.
	var/obj/item/clothing/gloves/mod/gauntlets
	/// MOD boots.
	var/obj/item/clothing/shoes/mod/boots
	/// List of parts.
	var/list/mod_parts = list()
	/// Modules the MOD should spawn with.
	var/list/initial_modules = list()
	/// Modules the MOD currently possesses.
	var/list/modules = list()
	/// Currently used module.
	var/obj/item/mod/module/selected_module
	/// AI mob inhabiting the MOD.
	var/mob/living/silicon/ai/ai
	/// Delay between moves as AI.
	var/movedelay = 0
	/// Cooldown for AI moves.
	COOLDOWN_DECLARE(cooldown_mod_move)
	/// Person wearing the MODsuit.
	var/mob/living/carbon/human/wearer

/obj/item/mod/control/Initialize(mapload, newtheme)
	. = ..()
	if(newtheme)
		theme = newtheme
	theme = GLOB.mod_themes[theme]
	slowdown = theme.slowdown_unactive
	complexity_max = theme.complexity_max
	skin = theme.default_skin
	cell_drain = theme.cell_usage
	wires = new /datum/wires/mod(src)
	if(req_access?.len)
		locked = TRUE
	if(ispath(cell))
		cell = new cell(src)
	if(ispath(theme.helmet_path))
		helmet = new theme.helmet_path(src)
		helmet.mod = src
		mod_parts += helmet
	if(ispath(theme.chestplate_path))
		chestplate = new theme.chestplate_path(src)
		chestplate.mod = src
		mod_parts += chestplate
	if(ispath(theme.gauntlets_path))
		gauntlets = new theme.gauntlets_path(src)
		gauntlets.mod = src
		mod_parts += gauntlets
	if(ispath(theme.boots_path))
		boots = new theme.boots_path(src)
		boots.mod = src
		mod_parts += boots
	var/list/all_parts = mod_parts.Copy() + src
	for(var/obj/item/piece as anything in all_parts)
		piece.name = "[theme.name] [piece.name]"
		piece.desc = "[piece.desc] [theme.desc]"
		piece.armor = getArmor(arglist(theme.armor))
		piece.resistance_flags = theme.resistance_flags
		piece.max_heat_protection_temperature = theme.max_heat_protection_temperature
		piece.min_cold_protection_temperature = theme.min_cold_protection_temperature
		piece.gas_transfer_coefficient = theme.gas_transfer_coefficient
		piece.permeability_coefficient = theme.permeability_coefficient
		piece.siemens_coefficient = theme.siemens_coefficient
		piece.icon_state = "[skin]-[initial(piece.icon_state)]"
	for(var/obj/item/mod/module/module as anything in initial_modules)
		module = new module(src)
		install(module, TRUE)
	RegisterSignal(src, COMSIG_ATOM_EXITED, .proc/on_exit)
	movedelay = CONFIG_GET(number/movedelay/run_delay)

/obj/item/mod/control/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(!QDELETED(helmet))
		helmet.mod = null
		QDEL_NULL(helmet)
	if(!QDELETED(chestplate))
		chestplate.mod = null
		QDEL_NULL(chestplate)
	if(!QDELETED(gauntlets))
		gauntlets.mod = null
		QDEL_NULL(gauntlets)
	if(!QDELETED(boots))
		boots.mod = null
		QDEL_NULL(boots)
	for(var/obj/item/mod/module/module as anything in modules)
		module.mod = null
		QDEL_NULL(module)
	QDEL_NULL(wires)
	QDEL_NULL(cell)
	..()

/obj/item/mod/control/process(delta_time)
	if(seconds_electrified > MACHINE_NOT_ELECTRIFIED)
		seconds_electrified--
	if(!cell?.charge && active && !activating)
		power_off()
		return PROCESS_KILL
	var/malfunctioning_charge_drain = 0
	if(malfunctioning)
		malfunctioning_charge_drain = rand(1,20)
	cell.charge = max(0, cell.charge - (cell_drain + malfunctioning_charge_drain)*delta_time)
	for(var/obj/item/mod/module/module as anything in modules)
		if(malfunctioning && module.active && DT_PROB(5, delta_time))
			module.on_deactivation()
		module.on_process(delta_time)

/obj/item/mod/control/equipped(mob/user, slot)
	..()
	if(slot == ITEM_SLOT_BACK)
		wearer = user
		RegisterSignal(wearer, COMSIG_ATOM_EXITED, .proc/on_exit)
	else if(wearer)
		UnregisterSignal(wearer, COMSIG_ATOM_EXITED)
		wearer = null

/obj/item/mod/control/dropped(mob/user)
	..()
	wearer = null

/obj/item/mod/control/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_BACK)
		return TRUE

/obj/item/mod/control/allow_attack_hand_drop(mob/user)
	var/mob/living/carbon/carbon_user = user
	if(!istype(carbon_user) || src != carbon_user.back)
		return ..()
	for(var/obj/item/part in mod_parts)
		if(part.loc != src)
			to_chat(carbon_user, "<span class='warning'>ERROR: At least one of the parts are still on your body, please retract them and try again.</span>")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, FALSE)
			return FALSE

/obj/item/mod/control/MouseDrop(atom/over_object)
	if(src != wearer?.back || !istype(over_object, /atom/movable/screen/inventory/hand))
		return ..()
	for(var/obj/item/part in mod_parts)
		if(part.loc != src)
			to_chat(wearer, "<span class='warning'>ERROR: At least one of the parts are still on your body, please retract them and try again.</span>")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, FALSE)
			return
	if(!wearer.incapacitated())
		var/atom/movable/screen/inventory/hand/ui_hand = over_object
		if(wearer.putItemFromInventoryInHandIfPossible(src, ui_hand.held_index))
			add_fingerprint(usr)
			return ..()

/obj/item/mod/control/attack_hand(mob/user)
	if(seconds_electrified && cell.charge)
		if(shock(user))
			return
	if(open && cell && loc == user)
		to_chat(user, "<span class='notice'>You start removing [cell].</span>")
		if(do_after(user, 5 SECONDS, target = src))
			to_chat(user, "<span class='notice'>You remove [cell].</span>")
			playsound(src, 'sound/machines/click.ogg', 50, TRUE)
			if(!user.put_in_hands(cell))
				cell.forceMove(drop_location())
		return
	return ..()

/obj/item/mod/control/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(active || activating)
		to_chat(user, "<span class='warning'>ERROR: Suit activated. Deactivate before further action.</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
		return FALSE
	to_chat(user, "<span class='notice'>You start to [open ? "screw the panel back on" : "unscrew the panel"]...</span>")
	I.play_tool_sound(src, 100)
	if(I.use_tool(src, user, 2 SECONDS))
		if(active || activating)
			return FALSE
		I.play_tool_sound(src, 100)
		user.visible_message("<span class='notice'>[user] [open ? "screws the panel back on" : "unscrews the panel"].</span>",
			"<span class='notice'>You [open ? "screw the panel back on" : "unscrew the panel"].</span>",
			"<span class='hear'>You hear metal noises.</span>")
		open = !open
	return TRUE

/obj/item/mod/control/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(!open)
		to_chat(user, "<span class='warning'>ERROR: Suit panel not open.</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
		return FALSE
	if(modules.len)
		for(var/obj/item/mod/module/module as anything in modules)
			if(module.removable)
				uninstall(module)
				module.forceMove(drop_location())
			else
				audible_message("<span class='warning'>[src] indicates that [module] cannot be removed.</span>", "<span class='warning'>[src] flashes an error message.</span>", hearing_distance = 1)
				playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
				return
		I.play_tool_sound(src, 100)
		return TRUE
	to_chat(user, "<span class='warning'>ERROR: There's no modules on [src]!</span>")
	playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
	return FALSE

/obj/item/mod/control/attackby(obj/item/attacking_item, mob/living/user, params)
	if(istype(attacking_item, /obj/item/mod/module))
		if(!open)
			audible_message("<span class='warning'>[src] indicates that it needs to be open before installing [attacking_item].</span>", "<span class='warning'>[src] flashes an error message.</span>", hearing_distance = 1)
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
			return FALSE
		install(attacking_item, FALSE)
		return TRUE
	else if(istype(attacking_item, /obj/item/stock_parts/cell))
		if(!open)
			audible_message("<span class='warning'>[src] indicates that it needs to be open before installing [attacking_item].</span>", "<span class='warning'>[src] flashes an error message.</span>", hearing_distance = 1)
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
			return FALSE
		if(cell)
			audible_message("<span class='warning'>[src] indicates that there is a cell already installed.</span>", "<span class='warning'>[src] flashes an error message.</span>", hearing_distance = 1)
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
			return FALSE
		attacking_item.forceMove(src)
		cell = attacking_item
		audible_message("<span class='notice'>[src] indicates that [cell] has been succesfully installed.</span>", "<span class='warning'>[src] flashes a confirmation message.</span>", hearing_distance = 1)
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
		return TRUE
	else if(is_wire_tool(attacking_item) && open)
		wires.interact(user)
		return TRUE
	else if(istype(attacking_item, /obj/item/mod/paint) && paint(user, attacking_item))
		to_chat(user, "<span class='notice'>You paint [src] with [attacking_item].</span>")
		qdel(attacking_item)
		return TRUE
	else if(open && attacking_item.GetID())
		update_access(attacking_item)
		return TRUE
	return ..()

/obj/item/mod/control/get_cell()
	if(!wearer)
		return cell

/obj/item/mod/control/emag_act(mob/user)
	locked = !locked
	to_chat(user, "<span class='notice'>You emag [src], [locked ? "locking" : "unlocking"] it.</span>")

/obj/item/mod/control/emp_act(severity)
	. = ..()
	to_chat(wearer, "<span class='notice'>[severity > 1 ? "Light" : "Strong"] electromagnetic pulse detected!</span>")
	if(!active || !wearer || . & EMP_PROTECT_CONTENTS)
		return
	wearer.apply_damage(10 / severity, BURN, spread_damage=TRUE)
	to_chat(wearer, "<span class='danger'>You feel [src] heat up from the EMP burning you slightly.</span>")
	if (wearer.stat < UNCONSCIOUS && prob(10))
		wearer.emote("scream")

/obj/item/mod/control/doStrip(mob/stripper, mob/owner)
	toggle_activate(stripper, TRUE)
	for(var/part in modules)
		conceal(stripper, part)
	return ..()

/obj/item/mod/control/worn_overlays()
	. = ..()
	if(!active)
		return
	for(var/obj/item/mod/module/module as anything in modules)
		var/used_overlay
		if(module.overlay_state_active && module.active)
			used_overlay = module.overlay_state_active
		else if(module.overlay_state_inactive)
			used_overlay = module.overlay_state_inactive
		if(!used_overlay)
			continue
		var/icon/module_icon
		module_icon = icon('icons/mob/mod.dmi', used_overlay)
		. += module_icon

/obj/item/mod/control/proc/paint(mob/user, obj/item/paint)
	if(theme.skins.len <= 1)
		return FALSE
	var/list/display_names = list()
	var/list/skins = list()
	for(var/mod_skin in theme.skins)
		display_names[mod_skin] = REF(mod_skin)
		var/image/skin_image = image(icon = icon, icon_state = "[mod_skin]-control")
		skins += list(mod_skin = skin_image)
	var/pick = show_radial_menu(user, src, skins, custom_check = FALSE, require_near = TRUE)
	if(!pick || !user.is_holding(paint))
		return FALSE
	var/skin_reference = display_names[pick]
	var/new_skin = locate(skin_reference) in theme.skins
	skin = new_skin
	var/list/skin_updating = mod_parts.Copy() + src
	for(var/obj/item/piece as anything in skin_updating)
		piece.icon_state = "[skin]-[initial(piece.icon_state)]"
	wearer.update_icons()
	return TRUE

/obj/item/mod/control/proc/shock(mob/living/user)
	if(!istype(user) || cell.charge < 1)
		return FALSE
	do_sparks(5, TRUE, src)
	var/check_range = TRUE
	return electrocute_mob(user, cell, src, 0.7, check_range)

/obj/item/mod/control/proc/install(module, starting_module = FALSE)
	var/obj/item/mod/module/new_module = module
	for(var/obj/item/mod/module/old_module as anything in modules)
		if(is_type_in_list(new_module, old_module.incompatible_modules) || is_type_in_list(old_module, new_module.incompatible_modules))
			if(!starting_module)
				audible_message("<span class='warning'>[src] indicates that [new_module] is incompatible with [old_module].</span>", "<span class='warning'>[src] flashes an error message.</span>")
				playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
				return
	if(is_type_in_list(module, theme.module_blacklist))
		if(!starting_module)
			audible_message("<span class='warning'>[src] indicates that it rejects [new_module].</span>", "<span class='warning'>[src] flashes an error message.</span>")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
			return
	var/complexity_with_module = complexity
	complexity_with_module += new_module.complexity
	if(complexity_with_module > complexity_max)
		if(!starting_module)
			audible_message("<span class='warning'>[src] indicates that [new_module] is too complex for its firmware.</span>", "<span class='warning'>[src] flashes an error message.</span>")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
			return
	new_module.forceMove(src)
	modules += new_module
	complexity += new_module.complexity
	new_module.mod = src
	new_module.on_install()
	if(!starting_module)
		audible_message("<span class='notice'>[src] indicates that [new_module] has been installed successfully.</span>", "<span class='warning'>[src] flashes a confirmation message.</span>", hearing_distance = 1)
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)

/obj/item/mod/control/proc/uninstall(module)
	var/obj/item/mod/module/old_module = module
	modules -= old_module
	complexity -= old_module.complexity
	if(old_module.active)
		old_module.on_deactivation()
	old_module.on_uninstall()
	old_module.mod = null

/obj/item/mod/control/proc/update_access(card)
	var/obj/item/card/id/access_id = card
	if(!allowed(wearer))
		to_chat(wearer, "<span class='warning'>ERROR: Access denied.</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
		return
	req_access = access_id.access.Copy()
	to_chat(wearer, "<span class='notice'>Access levels updated.</span>")

/obj/item/mod/control/proc/power_off()
	to_chat(wearer, "<span class='warning'>ERROR: Insufficient power.</span>")
	toggle_activate(wearer, force_deactivate = TRUE)

/obj/item/mod/control/proc/on_exit(datum/source, atom/movable/part, atom/newloc)
	SIGNAL_HANDLER

	if(newloc == src)
		return
	if(part == cell)
		cell = null
		return
	if(newloc == wearer)
		return
	if(modules.Find(part))
		var/obj/item/mod/module/module = part
		if(module.module_type == MODULE_TOGGLE || module.module_type == MODULE_ACTIVE)
			module.on_deactivation()
		uninstall(module)
		return
	if(mod_parts.Find(part))
		conceal(wearer, part)
		if(active)
			INVOKE_ASYNC(src, .proc/toggle_activate, wearer, TRUE)
		return

/obj/item/clothing/head/helmet/space/mod
	name = "MOD helmet"
	desc = "A helmet for a MODsuit."
	icon = 'icons/obj/mod.dmi'
	icon_state = "helmet"
	worn_icon = 'icons/mob/mod.dmi'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 0, FIRE = 25, ACID = 25, WOUND = 10)
	body_parts_covered = HEAD
	heat_protection = HEAD
	cold_protection = HEAD
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	clothing_flags = THICKMATERIAL
	resistance_flags = NONE
	flash_protect = FLASH_PROTECTION_NONE
	clothing_flags = SNUG_FIT
	flags_inv = HIDEFACIALHAIR
	flags_cover = HEADCOVERSMOUTH
	visor_flags = THICKMATERIAL|STOPSPRESSUREDAMAGE
	visor_flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR
	visor_flags_cover = HEADCOVERSEYES|PEPPERPROOF
	alternate_worn_layer = NECK_LAYER
	var/obj/item/mod/control/mod

/obj/item/clothing/head/helmet/space/mod/Destroy()
	..()
	if(!QDELETED(mod))
		mod.helmet = null
		QDEL_NULL(mod)

/obj/item/clothing/suit/armor/mod
	name = "MOD chestplate"
	desc = "A chestplate for a MODsuit."
	icon = 'icons/obj/mod.dmi'
	icon_state = "chestplate"
	worn_icon = 'icons/mob/mod.dmi'
	blood_overlay_type = "armor"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 0, FIRE = 25, ACID = 25, WOUND = 10)
	body_parts_covered = CHEST|GROIN
	heat_protection = CHEST|GROIN
	cold_protection = CHEST|GROIN
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	clothing_flags = THICKMATERIAL
	visor_flags = STOPSPRESSUREDAMAGE
	visor_flags_inv = HIDEJUMPSUIT
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals)
	resistance_flags = NONE
	var/obj/item/mod/control/mod

/obj/item/clothing/suit/armor/mod/Destroy()
	..()
	if(!QDELETED(mod))
		mod.chestplate = null
		QDEL_NULL(mod)

/obj/item/clothing/gloves/mod
	name = "MOD gauntlets"
	desc = "A pair of gauntlets for a MODsuit."
	icon = 'icons/obj/mod.dmi'
	icon_state = "gauntlets"
	worn_icon = 'icons/mob/mod.dmi'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 0, FIRE = 25, ACID = 25, WOUND = 10)
	body_parts_covered = HANDS|ARMS
	heat_protection = HANDS|ARMS
	cold_protection = HANDS|ARMS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	clothing_flags = THICKMATERIAL
	resistance_flags = NONE
	var/obj/item/mod/control/mod
	var/obj/item/clothing/overslot

/obj/item/clothing/gloves/mod/Destroy()
	..()
	if(!QDELETED(mod))
		mod.gauntlets = null
		QDEL_NULL(mod)

/obj/item/clothing/gloves/mod/proc/show_overslot()
	SIGNAL_HANDLER

	if(!overslot)
		return
	if(!mod.wearer.equip_to_slot_if_possible(overslot, overslot.slot_flags, FALSE, TRUE))
		mod.wearer.dropItemToGround(overslot, TRUE, TRUE)
	overslot = null

/obj/item/clothing/shoes/mod
	name = "MOD boots"
	desc = "A pair of boots for a MODsuit."
	icon = 'icons/obj/mod.dmi'
	icon_state = "boots"
	worn_icon = 'icons/mob/mod.dmi'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 0, FIRE = 25, ACID = 25, WOUND = 10)
	body_parts_covered = FEET|LEGS
	heat_protection = FEET|LEGS
	cold_protection = FEET|LEGS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	clothing_flags = THICKMATERIAL
	resistance_flags = NONE
	var/obj/item/mod/control/mod
	var/obj/item/clothing/overslot

/obj/item/clothing/shoes/mod/Destroy()
	..()
	if(!QDELETED(mod))
		mod.boots = null
		QDEL_NULL(mod)

/obj/item/clothing/shoes/mod/proc/show_overslot()
	SIGNAL_HANDLER

	if(!overslot)
		return
	if(!mod.wearer.equip_to_slot_if_possible(overslot, overslot.slot_flags, FALSE, TRUE))
		mod.wearer.dropItemToGround(overslot, TRUE, TRUE)
	overslot = null

/obj/item/mod/control/pre_equipped
	cell = /obj/item/stock_parts/cell/high

/obj/item/mod/control/pre_equipped/engineering
	theme = /datum/mod_theme/engineering

/obj/item/mod/control/pre_equipped/syndicate
	theme = /datum/mod_theme/syndicate
	req_access = list(ACCESS_SYNDICATE)
	cell = /obj/item/stock_parts/cell/hyper
	initial_modules = list(/obj/item/mod/module/storage/antag, /obj/item/mod/module/jetpack)
