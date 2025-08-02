//Holds defibs does NOT recharge them
//You can activate the mount with an empty hand to grab the paddles
//Not being adjacent will cause the paddles to snap back
/obj/machinery/defibrillator_mount
	name = "defibrillator mount"
	desc = "Holds defibrillators. You can grab the paddles if one is mounted."
	icon = 'icons/obj/machines/defib_mount.dmi'
	icon_state = "defibrillator_mount"
	density = FALSE
	use_power = NO_POWER_USE
	active_power_usage = 40 * BASE_MACHINE_ACTIVE_CONSUMPTION
	power_channel = AREA_USAGE_EQUIP
	req_one_access = list(ACCESS_MEDICAL, ACCESS_COMMAND, ACCESS_SECURITY) //used to control clamps
	processing_flags = NONE
	/// The mount's defib
	var/obj/item/defibrillator/defib
	/// if true, and a defib is loaded, it can't be removed without unlocking the clamps
	var/clamps_locked = FALSE
	/// the type of wallframe it 'disassembles' into
	var/wallframe_type = /obj/item/wallframe/defib_mount

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/defibrillator_mount, 28)

/obj/machinery/defibrillator_mount/loaded/Initialize(mapload) //loaded subtype for mapping use
	. = ..()
	defib = new/obj/item/defibrillator/loaded(src)
	find_and_hang_on_wall()

/obj/machinery/defibrillator_mount/Destroy()
	QDEL_NULL(defib)
	return ..()

/obj/machinery/defibrillator_mount/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == defib)
		// Make sure processing ends before the defib is nulled
		end_processing()
		defib = null
		update_appearance()

/obj/machinery/defibrillator_mount/examine(mob/user)
	. = ..()
	if(defib)
		. += span_notice("There is a defib unit hooked up. Alt-click to remove it.")
		if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
			. += span_notice("Due to a security situation, its locking clamps can be toggled by swiping any ID.")
		else
			. += span_notice("Its locking clamps can be [clamps_locked ? "dis" : ""]engaged by swiping an ID with access.")

/obj/machinery/defibrillator_mount/update_overlays()
	. = ..()
	if(isnull(defib))
		return

	var/mutable_appearance/defib_overlay = mutable_appearance(icon, "defib", layer = layer+0.01, offset_spokesman = src)

	if(defib.powered)
		var/obj/item/stock_parts/power_store/cell = defib.cell
		var/mutable_appearance/safety = mutable_appearance(icon, defib.safety ? "online" : "emagged", offset_spokesman = src)
		var/mutable_appearance/charge_overlay = mutable_appearance(icon, "charge[CEILING((cell.charge / cell.maxcharge) * 4, 1) * 25]", offset_spokesman = src)

		defib_overlay.overlays += list(safety, charge_overlay)

	if(clamps_locked)
		var/mutable_appearance/clamps = mutable_appearance(icon, "clamps", offset_spokesman = src)
		defib_overlay.overlays += clamps

	. += defib_overlay

//defib interaction
/obj/machinery/defibrillator_mount/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!defib)
		to_chat(user, span_warning("There's no defibrillator unit loaded!"))
		return
	if(defib.paddles.loc != defib)
		to_chat(user, span_warning("[defib.paddles.loc == user ? "You are already" : "Someone else is"] holding [defib]'s paddles!"))
		return
	if(!in_range(src, user))
		to_chat(user, span_warning("[defib]'s paddles overextend and come out of your hands!"))
		return
	user.put_in_hands(defib.paddles)

/obj/machinery/defibrillator_mount/attackby(obj/item/item, mob/living/user, list/modifiers, list/attack_modifiers)
	if(istype(item, /obj/item/defibrillator))
		if(defib)
			to_chat(user, span_warning("There's already a defibrillator in [src]!"))
			return
		var/obj/item/defibrillator/new_defib = item
		if(!new_defib.get_cell())
			to_chat(user, span_warning("Only defibrilators containing a cell can be hooked up to [src]!"))
			return
		if(HAS_TRAIT(new_defib, TRAIT_NODROP) || !user.transferItemToLoc(new_defib, src))
			to_chat(user, span_warning("[new_defib] is stuck to your hand!"))
			return
		user.visible_message(span_notice("[user] hooks up [new_defib] to [src]!"), \
		span_notice("You press [new_defib] into the mount, and it clicks into place."))
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
		// Make sure the defib is set before processing begins.
		defib = new_defib
		begin_processing()
		update_appearance()
		return
	else if(defib && item == defib.paddles)
		defib.paddles.snap_back()
		return
	var/obj/item/card/id = item.GetID()
	if(id)
		if(check_access(id) || SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED) //anyone can toggle the clamps in red alert!
			if(!defib)
				to_chat(user, span_warning("You can't engage the clamps on a defibrillator that isn't there."))
				return
			clamps_locked = !clamps_locked
			to_chat(user, span_notice("Clamps [clamps_locked ? "" : "dis"]engaged."))
			update_appearance()
		else
			to_chat(user, span_warning("Insufficient access."))
		return
	..()

/obj/machinery/defibrillator_mount/multitool_act(mob/living/user, obj/item/multitool)
	..()
	if(!defib)
		to_chat(user, span_warning("There isn't any defibrillator to clamp in!"))
		return TRUE
	if(!clamps_locked)
		to_chat(user, span_warning("[src]'s clamps are disengaged!"))
		return TRUE
	user.visible_message(span_notice("[user] presses [multitool] into [src]'s ID slot..."), \
	span_notice("You begin overriding the clamps on [src]..."))
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	if(!do_after(user, 10 SECONDS, target = src) || !clamps_locked)
		return
	user.visible_message(span_notice("[user] pulses [multitool], and [src]'s clamps slide up."), \
	span_notice("You override the locking clamps on [src]!"))
	playsound(src, 'sound/machines/locktoggle.ogg', 50, TRUE)
	clamps_locked = FALSE
	update_appearance()
	return TRUE

/obj/machinery/defibrillator_mount/wrench_act_secondary(mob/living/user, obj/item/tool)
	if(!wallframe_type)
		return ..()
	if(user.combat_mode)
		return ..()
	if(defib)
		to_chat(user, span_warning("The mount can't be deconstructed while a defibrillator unit is loaded!"))
		..()
		return TRUE
	new wallframe_type(get_turf(src))
	qdel(src)
	tool.play_tool_sound(user)
	to_chat(user, span_notice("You remove [src] from the wall."))
	return TRUE

/obj/machinery/defibrillator_mount/click_alt(mob/living/carbon/user)
	if(!defib)
		to_chat(user, span_warning("It'd be hard to remove a defib unit from a mount that has none."))
		return CLICK_ACTION_BLOCKING
	if(clamps_locked)
		to_chat(user, span_warning("You try to tug out [defib], but the mount's clamps are locked tight!"))
		return CLICK_ACTION_BLOCKING
	if(!user.put_in_hands(defib))
		to_chat(user, span_warning("You need a free hand!"))
		user.visible_message(span_notice("[user] unhooks [defib] from [src], dropping it on the floor."), \
		span_notice("You slide out [defib] from [src] and unhook the charging cables, dropping it on the floor."))
	else
		user.visible_message(span_notice("[user] unhooks [defib] from [src]."), \
		span_notice("You slide out [defib] from [src] and unhook the charging cables."))
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	return CLICK_ACTION_SUCCESS

/obj/machinery/defibrillator_mount/charging
	name = "PENLITE defibrillator mount"
	desc = "Holds defibrillators. You can grab the paddles if one is mounted. This PENLITE variant also allows for slow, passive recharging of the defibrillator."
	icon_state = "penlite_mount"
	use_power = IDLE_POWER_USE
	wallframe_type = /obj/item/wallframe/defib_mount/charging


/obj/machinery/defibrillator_mount/charging/Initialize(mapload)
	. = ..()
	if(is_operational)
		begin_processing()


/obj/machinery/defibrillator_mount/charging/on_set_is_operational(old_value)
	if(old_value) //Turned off
		end_processing()
	else //Turned on
		begin_processing()


/obj/machinery/defibrillator_mount/charging/process(seconds_per_tick)
	if(isnull(defib))
		return
	var/obj/item/stock_parts/power_store/defib_cell = defib.get_cell()
	if(isnull(defib_cell)) // Something is very wrong if we hit this, so we should stack trace
		stack_trace("[src] was set to process with no cell inside its defib")
		return PROCESS_KILL
	if(defib_cell.charge < defib_cell.maxcharge)
		charge_cell(active_power_usage * seconds_per_tick, defib_cell)
		defib.update_power()

//wallframe, for attaching the mounts easily
/obj/item/wallframe/defib_mount
	name = "unhooked defibrillator mount"
	desc = "A frame for a defibrillator mount. Once placed, it can be removed with a wrench."
	icon = 'icons/obj/machines/defib_mount.dmi'
	icon_state = "defibrillator_mount"
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 3, /datum/material/glass = SMALL_MATERIAL_AMOUNT)
	w_class = WEIGHT_CLASS_BULKY
	result_path = /obj/machinery/defibrillator_mount
	pixel_shift = 28

/obj/item/wallframe/defib_mount/charging
	name = "unhooked PENLITE defibrillator mount"
	desc = "A frame for a PENLITE defibrillator mount. Unlike the normal mount, it can passively recharge the unit inside."
	icon_state = "penlite_mount"
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 3, /datum/material/glass = SMALL_MATERIAL_AMOUNT, /datum/material/silver = SMALL_MATERIAL_AMOUNT * 0.5)
	result_path = /obj/machinery/defibrillator_mount/charging

//mobile defib

/obj/machinery/defibrillator_mount/mobile
	name = "mobile defibrillator mount"
	icon_state = "mobile"
	anchored = FALSE
	density = TRUE

/obj/machinery/defibrillator_mount/mobile/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noisy_movement)

/obj/machinery/defibrillator_mount/mobile/wrench_act_secondary(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return ..()
	if(defib)
		to_chat(user, span_warning("The mount can't be deconstructed while a defibrillator unit is loaded!"))
		..()
		return TRUE
	balloon_alert(user, "deconstructing...")
	tool.play_tool_sound(src)
	if(tool.use_tool(src, user, 5 SECONDS))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, vary = TRUE)
		deconstruct()
	return TRUE

/obj/machinery/defibrillator_mount/mobile/on_deconstruction(disassembled)
	var/atom/drop = drop_location()
	if(disassembled)
		new /obj/item/stack/sheet/iron(drop, 5)
		new /obj/item/stack/sheet/mineral/silver(drop)
		new /obj/item/stack/cable_coil(drop, 15)
	else
		new /obj/item/stack/sheet/iron(drop, 5)
