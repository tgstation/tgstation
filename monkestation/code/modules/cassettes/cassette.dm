
/obj/item/device/cassette_tape
	name = "Debug Cassette Tape"
	desc = "You shouldn't be seeing this!"
	icon = 'monkestation/code/modules/cassettes/icons/walkman.dmi'
	icon_state = "cassette_flip"
	w_class = WEIGHT_CLASS_SMALL
	///icon of the cassettes front side
	var/side1_icon = "cassette_worstmap"
	var/side2_icon = "cassette_worstmap"
	///if the cassette is flipped, for playing second list of songs
	var/flipped = FALSE
	///list of songs each side has to play
	var/list/songs = list("side1" = list(),
						  "side2" = list())
	///list of each songs name in the order they appear
	var/list/song_names = list("side1" = list(),
						 	   "side2" = list())
	///the id of the cassette
	var/id
	///the ckey of the cassette author
	var/ckey_author
	///the authors name displayed in examine text
	var/author_name
	///are we an approved tape?
	var/approved_tape = FALSE
	///are we random?
	var/random = FALSE
	var/cassette_desc_string = "Generic Desc"

/obj/item/device/cassette_tape/Initialize()
	. = ..()
	var/ids_exist = file("data/cassette_storage/ids.json")

	if(!length(GLOB.approved_ids) && fexists(ids_exist))
		GLOB.approved_ids = json_decode(file2text("data/cassette_storage/ids.json"))

	if(random && fexists(ids_exist))
		if(length(GLOB.approved_ids))
			id = pick(GLOB.approved_ids)

	var/file = file("data/cassette_storage/[id].json")
	if(!fexists(file))
		return

	var/list/data = json_decode(file2text(file))
	name = data["name"]
	cassette_desc_string = data["desc"]
	icon_state = data["side1_icon"]
	side1_icon = data["side1_icon"]
	side2_icon = data["side2_icon"]
	songs = data["songs"]
	song_names = data["song_names"]
	author_name = data["author_name"]
	ckey_author = data["author_ckey"]
	approved_tape = data["approved"]

	update_appearance()

/obj/item/device/cassette_tape/attack_self(mob/user)
	..()
	icon_state = flipped ? side1_icon : side2_icon
	flipped = !flipped
	to_chat(user,"You flip [src]")

/obj/item/device/cassette_tape/update_desc(updates)
	. = ..()
	desc = cassette_desc_string
	desc += "\n"
	if(!approved_tape)
		desc += span_warning("It appears to be a bootleg tape, quality is not a guarentee!\n")
	if(author_name)
		desc += span_notice("Mixed by [author_name]\n")

/obj/item/device/cassette_tape/attackby(obj/item/item, mob/living/user)
	if(!istype(item, /obj/item/pen))
		return ..()
	var/choice = input("What would you like to change?") in list("Cassette Name", "Cassette Description", "Cancel")
	switch(choice)
		if("Cassette Name")
			///the name we are giving the cassette
			var/newcassettename = reject_bad_text(stripped_input(user, "Write a new Cassette name:", name, name))
			if(!user.can_perform_action (src, TRUE))
				return
			if (length(newcassettename) > 20)
				to_chat(user, "<span class='warning'>That name is too long!</span>")
				return
			if(!newcassettename)
				to_chat(user, "<span class='warning'>That name is invalid.</span>")
				return
			else
				name = "[lowertext(newcassettename)]"
		if("Cassette Description")
			///the description we are giving the cassette
			var/newdesc = stripped_input(user, "Write a new description:", name, desc)
			if(!user.can_perform_action(src, TRUE))
				return
			if (length(newdesc) > 180)
				to_chat(user, "<span class='warning'>That description is too long!</span>")
				return
			if(!newdesc)
				to_chat(user, "<span class='warning'>That description is invalid.</span>")
				return
			cassette_desc_string = newdesc
			update_appearance()
		else
			return

/datum/cassette/cassette_tape
	var/name = "Broken Cassette"
	var/desc = "You shouldn't be seeing this! Make an issue about it"
	var/icon_state = "cassette_flip"
	var/side1_icon = "cassette_flip"
	var/side2_icon = "cassette_flip"
	var/id = "blank"
	var/creator_ckey = "Dwasint"
	var/creator_name = "Collects-The-Candy"
	var/approved = TRUE
	var/list/song_names = list("side1" = list(),
							   "side2" = list())

	var/list/songs = list("side1" = list(),
						  "side2" = list())

/obj/item/device/cassette_tape/blank
	id = "blank"

/obj/item/device/cassette_tape/friday
	id = "friday"
