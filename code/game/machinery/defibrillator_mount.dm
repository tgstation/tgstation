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

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/defibrillator_mount, 28)

/obj/machinery/defibrillator_mount/Destroy()
	if(defib)
		QDEL_NULL(defib)
	. = ..()

/obj/machinery/defibrillator_mount/handle_atom_del(atom/A)
	if(A == defib)
		defib = null
		end_processing()
	return ..()

/obj/machinery/defibrillator_mount/examine(mob/user)
	. = ..()
	if(defib)
		. += span_notice("There is a defib unit hooked up. Alt-click to remove it.")
		if(SSsecurity_level.current_level >= SEC_LEVEL_RED)
			. += span_notice("Due to a security situation, its locking clamps can be toggled by swiping any ID.")
		else
			. += span_notice("Its locking clamps can be [clamps_locked ? "dis" : ""]engaged by swiping an ID with access.")

/obj/machinery/defibrillator_mount/update_overlays()
	. = ..()

	if(!defib)
		return

	. += "defib"

	if(defib.powered)
		var/obj/item/stock_parts/cell/C = get_cell()
		. += (defib.safety ? "online" : "emagged")
		var/ratio = C.charge / C.maxcharge
		ratio = CEILING(ratio * 4, 1) * 25
		. += "charge[ratio]"

	if(clamps_locked)
		. += "clamps"

/obj/machinery/defibrillator_mount/get_cell()
	if(defib)
		return defib.get_cell()

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

/obj/machinery/defibrillator_mount/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/defibrillator))
		if(defib)
			to_chat(user, span_warning("There's already a defibrillator in [src]!"))
			return
		var/obj/item/defibrillator/D = I
		if(!D.get_cell())
			to_chat(user, span_warning("Only defibrilators containing a cell can be hooked up to [src]!"))
			return
		if(HAS_TRAIT(I, TRAIT_NODROP) || !user.transferItemToLoc(I, src))
			to_chat(user, span_warning("[I] is stuck to your hand!"))
			return
		user.visible_message(span_notice("[user] hooks up [I] to [src]!"), \
		span_notice("You press [I] into the mount, and it clicks into place."))
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
		// Make sure the defib is set before processing begins.
		defib = I
		begin_processing()
		update_appearance()
		return
	else if(defib && I == defib.paddles)
		defib.paddles.snap_back()
		return
	var/obj/item/card/id = I.GetID()
	if(id)
		if(check_access(id) || SSsecurity_level.current_level >= SEC_LEVEL_RED) //anyone can toggle the clamps in red alert!
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
	if(!do_after(user, 100, target = src) || !clamps_locked)
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

/obj/machinery/defibrillator_mount/AltClick(mob/living/carbon/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE))
		return
	if(!defib)
		to_chat(user, span_warning("It'd be hard to remove a defib unit from a mount that has none."))
		return
	if(clamps_locked)
		to_chat(user, span_warning("You try to tug out [defib], but the mount's clamps are locked tight!"))
		return
	if(!user.put_in_hands(defib))
		to_chat(user, span_warning("You need a free hand!"))
		user.visible_message(span_notice("[user] unhooks [defib] from [src], dropping it on the floor."), \
		span_notice("You slide out [defib] from [src] and unhook the charging cables, dropping it on the floor."))
	else
		user.visible_message(span_notice("[user] unhooks [defib] from [src]."), \
		span_notice("You slide out [defib] from [src] and unhook the charging cables."))
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	// Make sure processing ends before the defib is nulled
	end_processing()
	defib = null
	update_appearance()

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


/obj/machinery/defibrillator_mount/charging/process(delta_time)
	var/obj/item/stock_parts/cell/C = get_cell()
	if(!C || !is_operational)
		return PROCESS_KILL
	if(C.charge < C.maxcharge)
		use_power(active_power_usage * delta_time)
		C.give(40 * delta_time)
		defib.update_power()

//wallframe, for attaching the mounts easily
/obj/item/wallframe/defib_mount
	name = "unhooked defibrillator mount"
	desc = "A frame for a defibrillator mount. Once placed, it can be removed with a wrench."
	icon = 'icons/obj/machines/defib_mount.dmi'
	icon_state = "defibrillator_mount"
	custom_materials = list(/datum/material/iron = 300, /datum/material/glass = 100)
	w_class = WEIGHT_CLASS_BULKY
	result_path = /obj/machinery/defibrillator_mount
	pixel_shift = 28

/obj/item/wallframe/defib_mount/charging
	name = "unhooked PENLITE defibrillator mount"
	desc = "A frame for a PENLITE defibrillator mount. Unlike the normal mount, it can passively recharge the unit inside."
	icon_state = "penlite_mount"
	custom_materials = list(/datum/material/iron = 300, /datum/material/glass = 100, /datum/material/silver = 50)
	result_path = /obj/machinery/defibrillator_mount/charging
