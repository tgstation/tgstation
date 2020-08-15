/// RIGsuits, trade-off between armor and utility
/obj/item/rig
	name = "Base RIG"
	desc = "You should not see this, yell at a coder!"
	icon = 'icons/obj/rig.dmi'
	icon_state = "rig_shell"
	worn_icon = 'icons/mob/rig.dmi'

/obj/item/rig/control
	name = "RIG control module"
	desc = "A special powered suit that protects against various environments. Wear it on your back, deploy it and activate it."
	icon_state = "engi-control"
	worn_icon_state = "engi-control"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	slowdown = 2
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 30, "acid" = 100)
	actions_types = list(/datum/action/item_action/rig/deploy, /datum/action/item_action/rig/activate)
	resistance_flags = ACID_PROOF
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	permeability_coefficient = 0.01
	/// How the RIG and things connected to it look
	var/theme = "engi"
	/// If the suit is deployed and turned on
	var/active = FALSE
	/// If the suit wire/module hatch is open
	var/open = FALSE
	/// If the suit is ID locked
	var/locked = TRUE
	/// If the suit is malfunctioning
	var/malfunctioning = FALSE
	/// If the suit has EMP protection
	var/emp_protection = FALSE
	/// If the suit is currently activating/deactivating
	var/activating = FALSE
	/// How long the RIG is electrified for
	var/seconds_electrified = MACHINE_NOT_ELECTRIFIED
	/// If the suit interface is broken
	var/interface_break = FALSE
	/// Can the RIG swap out modules/parts
	var/no_customization = FALSE
	/// How much modules can this RIG carry without malfunctioning
	var/complexity_max = DEFAULT_MAX_COMPLEXITY
	/// How much modules this RIG is carrying
	var/complexity = 0
	/// How much battery power the RIG uses per tick
	var/cell_usage = 0
	/// Slowdown when active
	var/slowdown_active = 1
	/// RIG cell
	var/obj/item/stock_parts/cell/cell = /obj/item/stock_parts/cell/high
	/// RIG helmet
	var/obj/item/clothing/head/helmet/space/rig/helmet = /obj/item/clothing/head/helmet/space/rig
	/// RIG chestplate
	var/obj/item/clothing/suit/armor/rig/chestplate = /obj/item/clothing/suit/armor/rig
	/// RIG gauntlets
	var/obj/item/clothing/gloves/rig/gauntlets = /obj/item/clothing/gloves/rig
	/// RIG boots
	var/obj/item/clothing/shoes/rig/boots = /obj/item/clothing/shoes/rig
	/// List of parts
	var/list/rig_parts
	/// Modules the RIG should spawn with
	var/list/initial_modules = list()
	/// Modules the RIG currently possesses
	var/list/modules
	/// Person wearing the RIGsuit
	var/mob/living/carbon/human/wearer

/obj/item/rig/control/Initialize()
	..()
	START_PROCESSING(SSobj,src)
	icon_state = "[theme]-control"
	worn_icon_state = "[theme]-control"
	wires = new /datum/wires/rig(src)
	if((!req_access || !req_access.len) && (!req_one_access || !req_one_access.len))
		locked = FALSE
	if(ispath(cell))
		cell = new cell(src)
	if(ispath(helmet))
		helmet = new helmet(src)
		helmet.rig = src
		LAZYADD(rig_parts, helmet)
	if(ispath(chestplate))
		chestplate = new chestplate(src)
		chestplate.rig = src
		LAZYADD(rig_parts, chestplate)
	if(ispath(gauntlets))
		gauntlets = new gauntlets(src)
		gauntlets.rig = src
		LAZYADD(rig_parts, gauntlets)
	if(ispath(boots))
		boots = new boots(src)
		boots.rig = src
		LAZYADD(rig_parts, boots)
	if(LAZYLEN(rig_parts))
		for(var/obj/item/piece in rig_parts)
			piece.desc = "It seems to be a part of [src]."
			piece.armor = armor.Copy()
			piece.resistance_flags = resistance_flags
			piece.max_heat_protection_temperature = max_heat_protection_temperature
			piece.min_cold_protection_temperature = min_cold_protection_temperature
			piece.permeability_coefficient = permeability_coefficient
			if(piece.siemens_coefficient > siemens_coefficient)
				piece.siemens_coefficient = siemens_coefficient
			piece.icon_state = "[theme]-[icon_state]"
			piece.worn_icon_state = "[theme]-[icon_state]"
	if(initial_modules.len)
		for(var/obj/item/rig/module/module in initial_modules)
			module = new module(src)
			install(module, TRUE)


/obj/item/rig/control/Destroy()
	..()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(wires)
	if(cell)
		QDEL_NULL(cell)
	if(helmet)
		helmet.rig = null
		QDEL_NULL(helmet)
	if(chestplate)
		chestplate.rig = null
		QDEL_NULL(chestplate)
	if(gauntlets)
		gauntlets.rig = null
		QDEL_NULL(gauntlets)
	if(boots)
		boots.rig = null
		QDEL_NULL(boots)
	for(var/obj/item/rig/module/thingy in modules)
		thingy.rig = null
		QDEL_NULL(thingy)

/obj/item/rig/control/process()
	if(seconds_electrified > MACHINE_NOT_ELECTRIFIED)
		seconds_electrified--
	if(cell && cell.charge > 0 && active)
		if((cell.charge -= cell_usage) < 0)
			cell.charge = 0
		else
			cell.charge -= cell_usage

/obj/item/rig/control/equipped(mob/user, slot)
	..()
	if(slot == ITEM_SLOT_BACK)
		wearer = user
	else
		wearer = null

/obj/item/rig/control/dropped(mob/user)
	..()
	wearer = null

/obj/item/rig/control/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_BACK)
		return TRUE

/obj/item/rig/control/allow_attack_hand_drop(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/guy = user
		if(src == guy.back)
			for(var/obj/item/part in rig_parts)
				if(part.loc != src)
					to_chat(guy, "<span class='warning'>At least one of the parts are still on your body, please retract them and try again.</span>")
					playsound(src, 'sound/machines/scanbuzz.ogg', 25, FALSE)
					return FALSE
	return ..()

/obj/item/rig/control/MouseDrop(atom/over_object)
	if(src == wearer.back && istype(over_object, /obj/screen/inventory/hand))
		for(var/obj/item/part in rig_parts)
			if(part.loc != src)
				to_chat(wearer, "<span class='warning'>At least one of the parts are still on your body, please retract them and try again.</span>")
				playsound(src, 'sound/machines/scanbuzz.ogg', 25, FALSE)
				return
		if(!wearer.incapacitated())
			var/obj/screen/inventory/hand/H = over_object
			if(wearer.putItemFromInventoryInHandIfPossible(src, H.held_index))
				add_fingerprint(usr)
	return ..()

/obj/item/rig/control/attack_hand(mob/user)
	if(seconds_electrified && cell.charge)
		if(shock(user, 100))
			return
	if(open && cell && loc == user)
		to_chat(user, "<span class='notice'>You start removing [cell].</span>")
		if(do_after(user, 50, target = src))
			to_chat(user, "<span class='notice'>You remove [cell].</span>")
			user.put_in_hands(cell)
			cell = null
		return
	..()

/obj/item/rig/control/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(active || activating)
		to_chat(user, "<span class='warning'>ERROR: Suit activated. Deactivate before further action.</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
		return FALSE
	to_chat(user, "<span class='notice'>You start to [open ? "screw the panel back on" : "unscrew the panel"]...</span>")
	I.play_tool_sound(src, 100)
	if(I.use_tool(src, user, 20))
		I.play_tool_sound(src, 100)
		user.visible_message("<span class='notice'>[user] [open ? "screws the panel back on" : "unscrews the panel"].</span>",
			"<span class='notice'>You [open ? "screw the panel back on" : "unscrew the panel"].</span>",
			"<span class='hear'>You hear metal noises.</span>")
		open = !open
	return TRUE

/obj/item/rig/control/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(!open)
		to_chat(user, "<span class='warning'>ERROR: Suit panel not open.</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
		return FALSE
	if(modules.len)
		for(var/obj/item/rig/module/thingy in modules)
			if(thingy.removable)
				uninstall(thingy)
				I.play_tool_sound(src, 100)
		return TRUE
	to_chat(user, "<span class='warning'>There's no modules on [src]!</span>")
	playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
	return FALSE

/obj/item/rig/control/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/rig/module))
		if(open && !active && !activating && !no_customization)
			install(I, FALSE)
			return TRUE
		else
			audible_message("<span class='warning'>[src] indicates that something prevents installing [I].</span>")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
			return FALSE
	else if(istype(I, /obj/item/stock_parts/cell))
		if(open && !active && !activating && !cell)
			I.forceMove(src)
			cell = I
			audible_message("<span class='notice'>[src] indicates that [cell] has been succesfully installed.</span>")
			playsound(src, 'sound/machines/click.ogg', 50, TRUE)
			return TRUE
		else
			audible_message("<span class='warning'>[src] indicates that something prevents installing [I].</span>")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
			return FALSE
	else if(is_wire_tool(I) && open)
		wires.interact(user)
	..()

/obj/item/rig/control/proc/shock(mob/living/user)
	if(!istype(wearer) || cell.charge < 1)
		return FALSE
	do_sparks(5, TRUE, src)
	var/check_range = TRUE
	if(electrocute_mob(wearer, get_area(src), src, 0.7, check_range))
		return TRUE
	else
		return FALSE

/obj/item/rig/control/proc/install(module, starting_module = FALSE)
	if(!starting_module && no_customization)
		audible_message("<span class='warning'>[src] indicates that it cannot be modified.</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
		return
	var/obj/item/rig/module/thingy = module
	var/complexity_with_thingy = complexity
	complexity_with_thingy += thingy.complexity
	if(complexity_with_thingy > complexity_max)
		if(!starting_module)
			audible_message("<span class='warning'>[src] indicates that the module would make it too complex.</span>")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
		return
	thingy.forceMove(src)
	LAZYADD(modules, thingy)
	complexity += thingy.complexity
	thingy.rig = src
	thingy.on_install()
	if(!starting_module)
		audible_message("<span class='notice'>[src] indicates that the module has been installed successfully.</span>")
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)

/obj/item/rig/control/proc/uninstall(module)
	if(no_customization)
		audible_message("<span class='warning'>[src] indicates that it cannot be modified.</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
		return
	var/obj/item/rig/module/thingy = module
	if(!thingy.removable)
		audible_message("<span class='warning'>[src] indicates that the module cannot be removed.</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
		return
	thingy.forceMove(get_turf(src))
	LAZYREMOVE(modules, thingy)
	complexity -= thingy.complexity
	thingy.on_uninstall()
	thingy.rig = null

/obj/item/clothing/head/helmet/space/rig
	name = "RIG helmet"
	icon = 'icons/obj/rig.dmi'
	icon_state = "helmet"
	worn_icon = 'icons/mob/rig.dmi'
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 30, "acid" = 100)
	flash_protect = FLASH_PROTECTION_NONE
	clothing_flags = THICKMATERIAL | SNUG_FIT
	resistance_flags = ACID_PROOF
	flags_inv = HIDEFACIALHAIR
	flags_cover = HEADCOVERSMOUTH
	alternate_worn_layer = NECK_LAYER
	permeability_coefficient = 0.01
	var/obj/item/rig/control/rig

/obj/item/clothing/head/helmet/space/rig/Destroy()
	..()
	if(rig)
		rig.helmet = null
		QDEL_NULL(rig)

/obj/item/clothing/suit/armor/rig
	name = "RIG chestplate"
	icon = 'icons/obj/rig.dmi'
	icon_state = "chestplate"
	worn_icon = 'icons/mob/rig.dmi'
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 30, "acid" = 100)
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	heat_protection = CHEST|GROIN|LEGS|ARMS
	cold_protection = CHEST|GROIN|LEGS|ARMS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	clothing_flags = THICKMATERIAL
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals)
	resistance_flags = ACID_PROOF
	permeability_coefficient = 0.01
	var/obj/item/rig/control/rig

/obj/item/clothing/suit/armor/rig/Destroy()
	..()
	if(rig)
		rig.chestplate = null
		QDEL_NULL(rig)

/obj/item/clothing/gloves/rig
	name = "RIG gauntlets"
	icon = 'icons/obj/rig.dmi'
	icon_state = "gauntlets"
	worn_icon = 'icons/mob/rig.dmi'
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 30, "acid" = 100)
	resistance_flags = ACID_PROOF
	permeability_coefficient = 0.01
	var/obj/item/rig/control/rig

/obj/item/clothing/gloves/rig/Destroy()
	..()
	if(rig)
		rig.gauntlets = null
		QDEL_NULL(rig)

/obj/item/clothing/shoes/rig
	name = "RIG boots"
	icon = 'icons/obj/rig.dmi'
	icon_state = "boots"
	worn_icon = 'icons/mob/rig.dmi'
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 30, "acid" = 100)
	resistance_flags = ACID_PROOF
	permeability_coefficient = 0.01
	var/obj/item/rig/control/rig

/obj/item/clothing/shoes/rig/Destroy()
	..()
	if(rig)
		rig.boots = null
		QDEL_NULL(rig)
