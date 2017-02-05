#define SOAPSTONE_PREFIX_FILE "strings/soapstone_prefixes.txt"
#define SOAPSTONE_SUFFIX_FILE "soapstone_suffixes.json"
//Vocabulary lists; soapstones use a prefix and a suffix. Optionally, they can have a prefix and suffix, then a conjunction that links another set.
var/global/list/soapstone_prefixes = list() //Read from "strings/soapstone_prefixes.txt"; if you're adding your own, put **** where the subject should be!
var/global/list/soapstone_suffixes = list() //Read from "strings/soapstone_suffixes.json"
/obj/item/soapstone
	name = "chisel"
	desc = "Leave \"informative\" messages for the crew, including the crew of future shifts!\n\
	(Not suitable for engraving on shuttles, off station or on cats. Side effects may include beatings, bannings and orbital bombardment.)"
	icon = 'icons/obj/items.dmi'
	icon_state = "soapstone"
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/remaining_uses = 3

	var/non_dull_name
	var/w_dull = "dull"

/obj/item/soapstone/New()
	. = ..()
	if(!soapstone_prefixes.len)
		soapstone_prefixes = file2list(SOAPSTONE_PREFIX_FILE, "\n")
	if(!soapstone_suffixes.len)
		soapstone_suffixes = list(\
		"Characters" = strings(SOAPSTONE_SUFFIX_FILE, "Characters"), \
		"Careers" = strings(SOAPSTONE_SUFFIX_FILE, "Careers"), \
		"Antagonists" = strings(SOAPSTONE_SUFFIX_FILE, "Antagonists"), \
		"Objects" = strings(SOAPSTONE_SUFFIX_FILE, "Objects"), \
		"Techniques" = strings(SOAPSTONE_SUFFIX_FILE, "Techniques"), \
		"Actions" = strings(SOAPSTONE_SUFFIX_FILE, "Actions"), \
		"Geography" = strings(SOAPSTONE_SUFFIX_FILE, "Geography"), \
		"Orientation" = strings(SOAPSTONE_SUFFIX_FILE, "Orientation"), \
		"Body parts" = strings(SOAPSTONE_SUFFIX_FILE, "Body parts"), \
		"Concepts" = strings(SOAPSTONE_SUFFIX_FILE, "Concepts"), \
		"Musings" = strings(SOAPSTONE_SUFFIX_FILE, "Musings"), \
		)
	random_name()

/obj/item/soapstone/proc/random_name()
	name = pick("soapstone", "chisel", "chalk", "magic marker")
	non_dull_name = name
	if(name == "chalk" || name == "magic marker")
		desc = replacetext(desc, "engraving", "scribbling")
		if(name == "chalk")
			w_dull = "used"
		if(name == "magic marker")
			w_dull = "empty"

	if(name == "soapstone" || name == "chisel")
		desc = replacetext(desc, "scribbling", "engraving")
		w_dull = "dull"

/obj/item/soapstone/examine(mob/user)
	. = ..()
	if(remaining_uses != -1)
		user << "It has [remaining_uses] uses left."
	else
		user << "It looks like it can be used an unlimited number of times."

/obj/item/soapstone/afterattack(atom/target, mob/user, proximity)
	if(!remaining_uses)
		user << "<span class='warning'>[src] is [w_dull] and can't be used anymore!</span>"
		return
	var/turf/T = get_turf(target)
	if(!proximity)
		return
	if(!good_chisel_message_location(T))
		user << "<span class='warning'>You can't write there!</span>"
		return
	var/obj/structure/chisel_message/msg = locate(/obj/structure/chisel_message) in T
	if(msg)
		if(msg.creator_key != user.ckey)
			user << "<span class='warning'>You can't write there!</span>"
			return
		if(alert(user, "Erase this message?", name, "Yes", "No") == "Yes")
			user.visible_message("<span class='notice'>[user] swipes away [msg].</span>", "<span class='notice'>You sweep away [msg].</span>")
			playsound(msg, 'sound/items/gavel.ogg', 50, 1)
			msg.persists = 0
			qdel(msg)
			refund_use()
			return
		return
	var/prefix = input(user, "Choose a prefix for your message.", name) as null|anything in soapstone_prefixes
	if(!prefix)
		return
	var/suffix_category_string = input(user, "Choose a suffix category.", "[prefix]...") as null|anything in soapstone_suffixes
	var/list/suffix_category = soapstone_suffixes[suffix_category_string]
	if(!suffix_category || !suffix_category.len)
		return
	var/suffix = input(user, "Choose a suffix.", "[prefix]...") as null|anything in suffix_category
	if(!suffix)
		return
	var/processed_message = replacetext(prefix, "****", suffix)
	if(!user.Adjacent(T) || !good_chisel_message_location(T) || locate(/obj/structure/chisel_message) in T)
		return
	user.visible_message("<span class='notice'>[user] writes a message onto [T]!</span>", "<span class='notice'>You write a message onto [T].</span>")
	playsound(T, 'sound/items/gavel.ogg', 50, 1)
	var/obj/structure/chisel_message/M = new(T)
	M.register(user, processed_message)
	remove_use()
	return 1

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
	if(!remaining_uses)
		non_dull_name = name
		name = "[w_dull] [name]"

/obj/item/soapstone/proc/refund_use()
	if(remaining_uses == -1)
		return
	var/was_dull = !remaining_uses
	remaining_uses++

	if(was_dull)
		name = non_dull_name

/* Persistent engraved messages, etched onto the station turfs to serve
   as instructions and/or memes for the next generation of spessmen.

   Limited in location to station_z only. Can be smashed out or exploded,
   but only permamently removed with the librarian's soapstone.
*/

/obj/item/soapstone/infinite
	remaining_uses = -1

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

	var/positive_ratings = 0
	var/negative_ratings = 0

	var/list/raters = list() //Ckeys who have rated this message

/obj/structure/chisel_message/attack_hand(mob/user)
	if(user.ckey == creator_key)
		user << "<span class='warning'>You can't rate your own messages!</span>"
		return
	if(raters[user.ckey])
		user << "<span class='warning'>You've already rated this message!</span>"
		return
	switch(alert(user, "How would you like to rate this message?", "Message Rating", "Positive", "Negative", "Cancel"))
		if("Positive")
			for(var/client/C in clients)
				if(C.ckey == creator_key)
					C.mob << "<span class='notice'>One of your messages was rated as positive!</span>"
			user << "<span class='noticealien'>You rated this message as positive.</span>"
			positive_ratings++
			raters[user.ckey] = "positive"
		if("Negative")
			for(var/client/C in clients)
				if(C.ckey == creator_key)
					C.mob << "<span class='danger'>One of your messages was rated as negative!</span>"
			user << "<span class='danger'>You rated this message as negative.</span>"
			negative_ratings++
			raters[user.ckey] = "negative"

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
	data["pos_ratings"] = positive_ratings
	data["neg_ratings"] = positive_ratings
	data["raters"] = raters
	return data

/obj/structure/chisel_message/proc/unpack(list/data)
	hidden_message = data["hidden_message"]
	creator_name = data["creator_name"]
	creator_key = data["creator_key"]
	realdate = data["realdate"]
	positive_ratings = data["pos_ratings"]
	negative_ratings = data["neg_ratings"]
	raters = data["raters"]

	var/x = data["x"]
	var/y = data["y"]
	var/turf/newloc = locate(x, y, ZLEVEL_STATION)
	forceMove(newloc)
	update_icon()

/obj/structure/chisel_message/examine(mob/user)
	..()
	user << "<span class='notice'>[hidden_message]</span>"
	user << "Ratings: <span class='noticealien'>[positive_ratings]</span> <span class='danger'>[negative_ratings]</span>"
	if(raters[user.ckey])
		user << "<i>You rated this message as [raters[user.ckey]].</i>"

/obj/structure/chisel_message/Destroy()
	if(persists)
		SSpersistence.SaveChiselMessage(src)
	SSpersistence.chisel_messages -= src
	. = ..()
