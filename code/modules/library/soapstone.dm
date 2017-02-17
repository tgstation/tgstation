/obj/item/soapstone
	name = "chisel"
	desc = "Leave informative messages for the crew, including the crew of future shifts!\nEven if out of uses, it can still be used to remove messages.\n(Not suitable for engraving on shuttles, off station or on cats. Side effects may include beatings, bannings and orbital bombardment.)"
	icon = 'icons/obj/items.dmi'
	icon_state = "soapstone"
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/tool_speed = 50
	var/remaining_uses = 3

	var/non_dull_name
	var/w_engrave = "engrave"
	var/w_engraving = "engraving"
	var/w_chipping = "chipping"
	var/w_dull = "dull"

/obj/item/soapstone/New()
	. = ..()
	random_name()
	check_name() // could start empty

/obj/item/soapstone/proc/random_name()
	name = pick("soapstone", "chisel", "chalk", "magic marker")
	non_dull_name = name
	if(name == "chalk" || name == "magic marker")
		desc = replacetext(desc, "engraving", "scribbling")
		w_engrave = "scribble"
		w_engraving = "scribbling"
		w_chipping = "sketching"
		if(name == "chalk")
			w_dull = "used"
		if(name == "magic marker")
			w_dull = "empty"

	if(name == "soapstone" || name == "chisel")
		desc = replacetext(desc, "scribbling", "engraving")
		w_engrave = initial(w_engrave)
		w_engraving = initial(w_engraving)
		w_chipping = initial(w_chipping)
		w_dull = "dull"

/obj/item/soapstone/examine(mob/user)
	. = ..()
	if(remaining_uses != -1)
		user << "It has [remaining_uses] uses left."
	else
		user << "It looks like it can be used an unlimited number of times."

/obj/item/soapstone/afterattack(atom/target, mob/user, proximity)
	var/turf/T = get_turf(target)
	if(!proximity)
		return


	var/obj/structure/chisel_message/already_message = locate(/obj/structure/chisel_message) in T

	var/our_message = FALSE
	if(already_message)
		our_message = already_message.creator_key == user.ckey

	if(!remaining_uses && !already_message)
		// The dull chisel is dull.
		user << "<span class='warning'>[src] is [w_dull].</span>"
		return

	if(!good_chisel_message_location(T))
		user << "<span class='warning'>It's not appropriate to [w_engrave] on [T].</span>"
		return

	if(already_message)
		user.visible_message("<span class='notice'>[user] starts erasing [already_message].</span>", "<span class='notice'>You start erasing [already_message].</span>", "<span class='italics'>You hear a [w_chipping] sound.</span>")
		playsound(loc, 'sound/items/gavel.ogg', 50, 1, -1)

		// Removing our own messages refunds a charge

		if(do_after(user, tool_speed, target=target))
			user.visible_message("<span class='notice'>[user] has erased [already_message].</span>", "<span class='notice'>You erased [already_message].</span>")
			already_message.persists = FALSE
			qdel(already_message)
			playsound(loc, 'sound/items/gavel.ogg', 50, 1, -1)
			if(our_message)
				refund_use()
		return

	var/message = stripped_input(user, "What would you like to [w_engrave]?", "[name] Message")
	if(!message)
		user << "You decide not to [w_engrave] anything."
		return

	if(!target.Adjacent(user) && locate(/obj/structure/chisel_message) in T)
		user << "You decide not to [w_engrave] anything."
		return

	playsound(loc, 'sound/items/gavel.ogg', 50, 1, -1)
	user.visible_message("<span class='notice'>[user] starts [w_engraving] a message into [T].</span>", "You start [w_engraving] a message into [T].", "<span class='italics'>You hear a [w_chipping] sound.</span>")
	if(can_use() && do_after(user, tool_speed, target=T) && can_use())
		if(!locate(/obj/structure/chisel_message in T))
			user << "You [w_engrave] a message into [T]."
			playsound(loc, 'sound/items/gavel.ogg', 50, 1, -1)
			var/obj/structure/chisel_message/M = new(T)
			M.register(user, message)
			remove_use()

/obj/item/soapstone/proc/can_use()
	if(remaining_uses == -1 || remaining_uses >= 0)
		. = TRUE
	else
		. = FALSE

/obj/item/soapstone/proc/remove_use()
	if(remaining_uses <= 0)
		// -1 == unlimited, 0 == empty
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
		name = non_dull_name
	else
		name = "[w_dull] [name]"

/* Persistent engraved messages, etched onto the station turfs to serve
   as instructions and/or memes for the next generation of spessmen.

   Limited in location to station_z only. Can be smashed out or exploded,
   but only permamently removed with the librarian's soapstone.
*/

/obj/item/soapstone/infinite
	remaining_uses = -1

/obj/item/soapstone/empty
	remaining_uses = 0

/proc/good_chisel_message_location(turf/T)
	if(!T)
		. = FALSE
	else if(T.z != ZLEVEL_STATION)
		. = FALSE
	else if(istype(get_area(T), /area/shuttle))
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
	density = 0
	anchored = 1
	luminosity = 1
	obj_integrity = 30
	max_integrity = 30

	var/hidden_message
	var/creator_key
	var/creator_name
	var/realdate
	var/map
	var/persists = TRUE
	var/list/like_keys = list()
	var/list/dislike_keys = list()

/obj/structure/chisel_message/New(newloc)
	..()
	SSpersistence.chisel_messages += src
	var/turf/T = get_turf(src)
	if(!good_chisel_message_location(T))
		persists = FALSE
		qdel(src)

/obj/structure/chisel_message/singularity_pull()
	return

/obj/structure/chisel_message/proc/register(mob/user, newmessage)
	hidden_message = newmessage
	creator_name = user.real_name
	creator_key = user.ckey
	realdate = world.timeofday
	map = MAP_NAME
	update_icon()

/obj/structure/chisel_message/update_icon()
	..()
	var/hash = md5(hidden_message)
	var/newcolor = copytext(hash, 1, 7)
	add_atom_colour("#[newcolor]", FIXED_COLOUR_PRIORITY)

/obj/structure/chisel_message/proc/pack()
	var/list/data = list()
	data["hidden_message"] = hidden_message
	data["creator_name"] = creator_name
	data["creator_key"] = creator_key
	data["realdate"] = realdate
	data["map"] = MAP_NAME
	var/turf/T = get_turf(src)
	data["x"] = T.x
	data["y"] = T.y
	data["like_keys"] = like_keys
	data["dislike_keys"] = dislike_keys

/obj/structure/chisel_message/proc/unpack(list/data)
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
	var/turf/newloc = locate(x, y, ZLEVEL_STATION)
	forceMove(newloc)
	update_icon()

/obj/structure/chisel_message/examine(mob/user)
	..()
	user << "<span class='warning'>[hidden_message]</span>"

/obj/structure/chisel_message/Destroy()
	if(persists)
		SSpersistence.SaveChiselMessage(src)
	SSpersistence.chisel_messages -= src
	. = ..()

/obj/structure/chisel_message/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = always_state)

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "engraved_message", name, 600, 300, master_ui, state)
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

	return data

/obj/structure/chisel_message/ui_act(action, params, datum/tgui/ui)
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
			var/confirm = alert(user, "Confirm deletion of engraved message?", "Confirm Deletion", "Yes", "No")
			if(confirm == "Yes")
				persists = FALSE
				qdel(src)
