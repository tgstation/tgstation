/obj/item/style_meter
	name = "style meter attachment"
	desc = "Attach this to a pair of glasses to install a style meter system in them. \
		You get style points from performing stylish acts and lose them for breaking your style. \
		The style affects the quality of your mining, with you being able to mine ore better during a good chain. \
		A responsive data HUD gives you the ability to reflect lavaland-based projectiles by punching them with an empty hand. \
		In addition, at high style, you are able to swap an item in your hand with one in your backpack by <b>hitting</b> one with another."
	icon_state = "style_meter"
	icon = 'icons/obj/clothing/glasses.dmi'
	/// The style meter component we give.
	var/datum/component/style/style_meter
	/// Mutable appearance added to the attached glasses
	var/mutable_appearance/meter_appearance
	/// If this is multitooled, which is passed onto the component on-creation, if one doesn't currently exist
	var/multitooled = FALSE

/obj/item/style_meter/Initialize(mapload)
	. = ..()
	meter_appearance = mutable_appearance(icon, icon_state)

/obj/item/style_meter/Destroy(force)
	if(istype(loc, /obj/item/clothing/glasses))
		clean_up(loc)
	return ..()

/obj/item/style_meter/examine(mob/user)
	. = ..()
	. += span_notice("You feel like a <b>multitool</b> could be used on this.")

/obj/item/style_meter/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /obj/item/clothing/glasses))
		return NONE

	. = ITEM_INTERACT_SUCCESS

	forceMove(interacting_with)
	interacting_with.add_overlay(meter_appearance)
	RegisterSignal(interacting_with, COMSIG_ITEM_EQUIPPED, PROC_REF(check_wearing))
	RegisterSignal(interacting_with, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(interacting_with, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(interacting_with, COMSIG_CLICK_ALT, PROC_REF(on_click_alt))
	RegisterSignal(interacting_with, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL), PROC_REF(redirect_multitool))
	balloon_alert(user, "style meter attached")
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	if(!iscarbon(interacting_with.loc))
		return .

	var/mob/living/carbon/carbon_wearer = interacting_with.loc
	if(carbon_wearer.glasses != interacting_with)
		return .

	style_meter = carbon_wearer.AddComponent(/datum/component/style, multitooled)
	return .

/obj/item/style_meter/Moved(atom/old_loc, Dir, momentum_change)
	. = ..()
	if(!istype(old_loc, /obj/item/clothing/glasses))
		return
	clean_up(old_loc)


/// Check if the glasses that this meter is linked with are being worn
/obj/item/style_meter/proc/check_wearing(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(!(slot & ITEM_SLOT_EYES))
		if(style_meter)
			QDEL_NULL(style_meter)
		return

	style_meter = equipper.AddComponent(/datum/component/style, multitooled)


/// Signal proc for when the meter-holding glasses are dropped/unequipped
/obj/item/style_meter/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!style_meter)
		return

	QDEL_NULL(style_meter)


/// Signal proc for on-examine
/obj/item/style_meter/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("You feel like a <b>multitool</b> could be used on this.")
	examine_list += span_notice("<b>Alt-click</b> to remove the style meter.")


/// Signal proc to remove from glasses
/obj/item/style_meter/proc/on_click_alt(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!istype(loc, /obj/item/clothing/glasses))
		return CLICK_ACTION_BLOCKING

	clean_up()
	forceMove(get_turf(src))
	return CLICK_ACTION_SUCCESS

/obj/item/style_meter/multitool_act(mob/living/user, obj/item/tool)
	multitooled = !multitooled
	balloon_alert(user, "meter [multitooled ? "" : "un"]hacked")
	style_meter?.multitooled = multitooled
	return ITEM_INTERACT_SUCCESS

/// Redirect multitooling on our glasses to our style meter
/obj/item/style_meter/proc/redirect_multitool(datum/source, mob/living/user, obj/item/tool, ...)
	SIGNAL_HANDLER

	return multitool_act(user, tool)

/// Unregister signals and just generally clean up ourselves after being removed from glasses
/obj/item/style_meter/proc/clean_up(atom/movable/old_location)
	old_location.cut_overlay(meter_appearance)
	UnregisterSignal(old_location, COMSIG_ITEM_EQUIPPED)
	UnregisterSignal(old_location, COMSIG_ITEM_DROPPED)
	UnregisterSignal(old_location, COMSIG_ATOM_EXAMINE)
	UnregisterSignal(old_location, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL))
	if(!style_meter)
		return
	QDEL_NULL(style_meter)


/atom/movable/screen/style_meter_background
	icon_state = "style_meter_background"
	icon = 'icons/hud/style_meter.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "WEST,CENTER:16"
	maptext_height = 120
	maptext_width = 105
	maptext_x = 5
	maptext_y = 100
	maptext = ""
	layer = SCREENTIP_LAYER

/atom/movable/screen/style_meter
	icon_state = "style_meter"
	icon = 'icons/hud/style_meter.dmi'
	layer = SCREENTIP_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
