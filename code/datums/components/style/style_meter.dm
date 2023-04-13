/obj/item/style_meter
	name = "style meter attachment"
	desc = "Attach this to a pair of glasses to install a style meter system in them. \
		You get style points from performing stylish acts and lose them for breaking your style. \
		The style affects the quality of your mining, with you being able to mine ore better during a good chain. \
		A responsive data HUD gives you the ability to reflect projectiles by punching them with an empty hand."
	icon_state = "style_meter"
	icon = 'icons/obj/clothing/glasses.dmi'
	/// The style meter component we give.
	var/datum/component/style/style_meter
	/// Mutable appearance added to the attached glasses
	var/mutable_appearance/meter_appearance

/obj/item/style_meter/Initialize(mapload)
	. = ..()
	meter_appearance = mutable_appearance(icon, icon_state)

/obj/item/style_meter/afterattack(atom/movable/attacked_atom, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!istype(attacked_atom, /obj/item/clothing/glasses))
		return

	forceMove(attacked_atom)
	attacked_atom.add_overlay(meter_appearance)
	RegisterSignal(attacked_atom, COMSIG_ITEM_EQUIPPED, PROC_REF(check_wearing))
	RegisterSignal(attacked_atom, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(attacked_atom, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(attacked_atom, COMSIG_CLICK_ALT, PROC_REF(on_altclick))
	balloon_alert(user, "style meter attached")
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	if(!iscarbon(attacked_atom.loc))
		return

	var/mob/living/carbon/carbon_wearer = attacked_atom.loc
	if(carbon_wearer.glasses != attacked_atom)
		return

	style_meter = carbon_wearer.AddComponent(/datum/component/style)

/obj/item/style_meter/Moved(atom/old_loc, Dir, momentum_change)
	. = ..()
	if(!istype(old_loc, /obj/item/clothing/glasses))
		return
	clean_up(old_loc)

/obj/item/style_meter/Destroy(force)
	if(istype(loc, /obj/item/clothing/glasses))
		clean_up(loc)
	return ..()

/obj/item/style_meter/proc/check_wearing(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(!(slot & ITEM_SLOT_EYES))
		if(style_meter)
			QDEL_NULL(style_meter)
		return

	style_meter = equipper.AddComponent(/datum/component/style)

/obj/item/style_meter/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!style_meter)
		return

	QDEL_NULL(style_meter)

/obj/item/style_meter/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("<b>Alt-click</b> to remove the style meter.")

/obj/item/style_meter/proc/on_altclick(datum/source, mob/user)
	SIGNAL_HANDLER

	if(istype(loc, /obj/item/clothing/glasses))
		clean_up()
		forceMove(get_turf(src))

	return COMPONENT_CANCEL_CLICK_ALT

/obj/item/style_meter/proc/clean_up(atom/movable/old_location)
	old_location.cut_overlay(meter_appearance)
	UnregisterSignal(old_location, COMSIG_ITEM_EQUIPPED)
	UnregisterSignal(old_location, COMSIG_ITEM_DROPPED)
	UnregisterSignal(old_location, COMSIG_PARENT_EXAMINE)
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
