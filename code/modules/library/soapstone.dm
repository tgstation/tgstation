#define POINT_THRESHOLD_PLASTIC -INFINITY
#define POINT_THRESHOLD_IRON 1
#define POINT_THRESHOLD_BRONZE 15
#define POINT_THRESHOLD_SILVER 30
#define POINT_THRESHOLD_GOLD 45
#define POINT_THRESHOLD_DIAMOND 60

/obj/item/soapstone
	name = "soapstone"
	desc = "Leave informative messages for the crew, including the crew of future shifts!\nEven if out of uses, it can still be used to remove messages.\n(Not suitable for engraving on shuttles, off station or on cats. Side effects may include prompt beatings, psychotic clown incursions, and/or orbital bombardment.)"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "soapstone"
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/tool_speed = 50
	var/remaining_uses = 3

/obj/item/soapstone/Initialize(mapload)
	. = ..()
	check_name()

/obj/item/soapstone/examine(mob/user)
	. = ..()
	if(remaining_uses != -1)
		. += "It has [remaining_uses] uses left."

/obj/item/soapstone/afterattack(atom/target, mob/user, proximity)
	. = ..()
	var/turf/T = get_turf(target)
	if(!proximity)
		return

	var/obj/structure/chisel_message/existing_message = locate() in T

	if(!remaining_uses && !existing_message)
		to_chat(user, span_warning("[src] is too worn out to use."))
		return

	if(!good_chisel_message_location(T))
		to_chat(user, span_warning("It's not appropriate to engrave on [T]."))
		return

	if(existing_message)
		user.visible_message(span_notice("[user] starts erasing [existing_message]."), span_notice("You start erasing [existing_message]."), span_hear("You hear a chipping sound."))
		playsound(loc, 'sound/items/gavel.ogg', 50, TRUE, -1)
		if(do_after(user, tool_speed, target = existing_message))
			user.visible_message(span_notice("[user] erases [existing_message]."), span_notice("You erase [existing_message][existing_message.creator_key == user.ckey ? ", refunding a use" : ""]."))
			existing_message.persists = FALSE
			qdel(existing_message)
			playsound(loc, 'sound/items/gavel.ogg', 50, TRUE, -1)
			if(existing_message.creator_key == user.ckey)
				refund_use()
		return

	var/message = stripped_input(user, "What would you like to engrave?", "Leave a message")
	if(!message)
		to_chat(user, span_notice("You decide not to engrave anything."))
		return

	if(!target.Adjacent(user) && locate(/obj/structure/chisel_message) in T)
		to_chat(user, span_warning("Someone wrote here before you chose! Find another spot."))
		return
	playsound(loc, 'sound/items/gavel.ogg', 50, TRUE, -1)
	user.visible_message(span_notice("[user] starts engraving a message into [T]..."), span_notice("You start engraving a message into [T]..."), span_hear("You hear a chipping sound."))
	if(can_use() && do_after(user, tool_speed, target = T) && can_use()) //This looks messy but it's actually really clever!
		if(!locate(/obj/structure/chisel_message) in T)
			user.visible_message(span_notice("[user] leaves a message for future spacemen!"), span_notice("You engrave a message into [T]!"), span_hear("You hear a chipping sound."))
			playsound(loc, 'sound/items/gavel.ogg', 50, TRUE, -1)
			var/obj/structure/chisel_message/M = new(T)
			M.register(user, message)
			remove_use()

/obj/item/soapstone/proc/can_use()
	return remaining_uses == -1 || remaining_uses > 0

/obj/item/soapstone/proc/remove_use()
	if(remaining_uses <= 0)
		return
	remaining_uses--
	check_name()

/obj/item/soapstone/proc/refund_use()
	if(remaining_uses == -1)
		return
	remaining_uses++
	check_name()

/obj/item/soapstone/proc/check_name()
	if(remaining_uses)
		// This will mess up RPG loot names, but w/e
		name = initial(name)
	else
		name = "dull [initial(name)]"

/* Persistent engraved messages, etched onto the station turfs to serve
as instructions and/or memes for the next generation of spessmen.

Limited in location to station_z only. Can be smashed out or exploded,
but only permanently removed with the curator's soapstone.
*/

/obj/item/soapstone/infinite
	remaining_uses = -1

/obj/item/soapstone/empty
	remaining_uses = 0

/proc/good_chisel_message_location(turf/T)
	if(!T)
		. = FALSE
	else if(!(isfloorturf(T) || iswallturf(T)))
		. = FALSE
	else
		. = TRUE

/obj/structure/chisel_message
	name = "engraved message"
	desc = "A message from a past traveler."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "soapstone_message"
	layer = LATTICE_LAYER
	density = FALSE
	anchored = TRUE
	max_integrity = 30

	var/hidden_message
	var/creator_key
	var/creator_name
	var/realdate
	var/map
	var/persists = TRUE
	var/list/like_keys = list()
	var/list/dislike_keys = list()

	var/turf/original_turf

	/// Total vote count at or below which we won't persist.
	var/delete_at = -5

/obj/structure/chisel_message/Initialize(mapload)
	. = ..()
	SSpersistence.chisel_messages += src
	var/turf/T = get_turf(src)
	original_turf = T

	if(!good_chisel_message_location(T))
		persists = FALSE
		return INITIALIZE_HINT_QDEL

	if(like_keys.len - dislike_keys.len <= delete_at)
		persists = FALSE

/obj/structure/chisel_message/proc/register(mob/user, newmessage)
	hidden_message = newmessage
	creator_name = user.real_name
	creator_key = user.ckey
	realdate = world.realtime
	map = SSmapping.config.map_name
	update_appearance()

/obj/structure/chisel_message/update_icon()
	. = ..()

	var/newcolor = COLOR_SOAPSTONE_PLASTIC
	switch(like_keys.len - dislike_keys.len)
		if(POINT_THRESHOLD_PLASTIC to POINT_THRESHOLD_IRON-1)
			newcolor = COLOR_SOAPSTONE_PLASTIC
		if(POINT_THRESHOLD_IRON to POINT_THRESHOLD_BRONZE-1)
			newcolor = COLOR_SOAPSTONE_IRON
		if(POINT_THRESHOLD_BRONZE to POINT_THRESHOLD_SILVER-1)
			newcolor = COLOR_SOAPSTONE_BRONZE
		if(POINT_THRESHOLD_SILVER to POINT_THRESHOLD_GOLD-1)
			newcolor = COLOR_SOAPSTONE_SILVER
		if(POINT_THRESHOLD_GOLD to POINT_THRESHOLD_DIAMOND-1)
			newcolor = COLOR_SOAPSTONE_GOLD
		if(POINT_THRESHOLD_DIAMOND to INFINITY)
			newcolor = COLOR_SOAPSTONE_DIAMOND

	add_atom_colour("[newcolor]", FIXED_COLOUR_PRIORITY)
	set_light_color("[newcolor]")
	set_light(1)

/obj/structure/chisel_message/update_name()
	switch(like_keys.len - dislike_keys.len)
		if(POINT_THRESHOLD_PLASTIC to POINT_THRESHOLD_IRON-1)
			name = "plastic [initial(name)]"
		if(POINT_THRESHOLD_IRON to POINT_THRESHOLD_BRONZE-1)
			name = "iron [initial(name)]"
		if(POINT_THRESHOLD_BRONZE to POINT_THRESHOLD_SILVER-1)
			name = "bronze [initial(name)]"
		if(POINT_THRESHOLD_SILVER to POINT_THRESHOLD_GOLD-1)
			name = "silver [initial(name)]"
		if(POINT_THRESHOLD_GOLD to POINT_THRESHOLD_DIAMOND-1)
			name = "gold [initial(name)]"
		if(POINT_THRESHOLD_DIAMOND to INFINITY)
			name = "diamond [initial(name)]"
	return ..()

/obj/structure/chisel_message/proc/pack()
	var/list/data = list()
	data["hidden_message"] = hidden_message
	data["creator_name"] = creator_name
	data["creator_key"] = creator_key
	data["realdate"] = realdate
	data["map"] = SSmapping.config.map_name
	data["x"] = original_turf.x
	data["y"] = original_turf.y
	data["z"] = original_turf.z
	data["like_keys"] = like_keys
	data["dislike_keys"] = dislike_keys
	return data

/obj/structure/chisel_message/proc/unpack(list/data)
	if(!islist(data))
		return

	hidden_message = data["hidden_message"]
	creator_name = data["creator_name"]
	creator_key = data["creator_key"]
	realdate = data["realdate"]
	like_keys = data["like_keys"]
	if(!like_keys)
		like_keys = list()
	dislike_keys = data["dislike_keys"]
	if(!dislike_keys)
		dislike_keys = list()

	var/x = data["x"]
	var/y = data["y"]
	var/z = data["z"]
	var/turf/newloc = locate(x, y, z)
	if(isturf(newloc))
		forceMove(newloc)
	update_appearance()

/obj/structure/chisel_message/examine(mob/user)
	. = ..()
	ui_interact(user)

/obj/structure/chisel_message/Destroy()
	if(persists)
		SSpersistence.SaveChiselMessage(src)
	SSpersistence.chisel_messages -= src
	return ..()

/obj/structure/chisel_message/interact()
	return

/obj/structure/chisel_message/ui_status(mob/user)
	if(isobserver(user)) // ignore proximity restrictions if we're an observer
		return UI_INTERACTIVE
	return ..()

/obj/structure/chisel_message/ui_state(mob/user)
	return GLOB.always_state

/obj/structure/chisel_message/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EngravedMessage", name)
		ui.open()

/obj/structure/chisel_message/ui_data(mob/user)
	var/list/data = list()

	data["hidden_message"] = hidden_message
	data["realdate"] = SQLtime(realdate)
	data["num_likes"] = like_keys.len
	data["num_dislikes"] = dislike_keys.len
	data["is_creator"] = user.ckey == creator_key
	data["has_liked"] = (user.ckey in like_keys)
	data["has_disliked"] = (user.ckey in dislike_keys)

	if(check_rights_for(user.client, R_ADMIN))
		data["admin_mode"] = TRUE
		data["creator_key"] = creator_key
		data["creator_name"] = creator_name
	else
		data["admin_mode"] = FALSE
		data["creator_key"] = null
		data["creator_name"] = null

	return data

/obj/structure/chisel_message/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/mob/user = usr
	var/is_admin = check_rights_for(user.client, R_ADMIN)
	var/is_creator = user.ckey == creator_key
	var/has_liked = (user.ckey in like_keys)
	var/has_disliked = (user.ckey in dislike_keys)

	switch(action)
		if("like")
			if(is_creator)
				return
			if(has_disliked)
				dislike_keys -= user.ckey
			like_keys |= user.ckey
			. = TRUE
		if("dislike")
			if(is_creator)
				return
			if(has_liked)
				like_keys -= user.ckey
			dislike_keys |= user.ckey
			. = TRUE
		if("neutral")
			if(is_creator)
				return
			dislike_keys -= user.ckey
			like_keys -= user.ckey
			. = TRUE
		if("delete")
			if(!is_admin)
				return
			var/confirm = tgui_alert(user, "Confirm deletion of engraved message?", "Confirm Deletion", list("Yes", "No"))
			if(confirm == "Yes")
				persists = FALSE
				qdel(src)
				return

	update_appearance()
	persists = like_keys.len - dislike_keys.len > delete_at
