
/obj/item/device/cassette_tape
	name = "Debug Cassette Tape"
	desc = "You shouldn't be seeing this!"
	icon = 'monkestation/icons/obj/walkman.dmi'
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
	//the cassette_tape type datum
	var/datum/cassette/cassette_tape/tape
	///are we an approved tape?
	var/approved_tape = FALSE

/obj/item/device/cassette_tape/Initialize()
	. = ..()

	if(!tape)
		return

	tape = new tape
	id = tape.id
	var/file = file("data/cassette_storage/[id].json")
	if(!fexists(file))
		qdel(tape)
		return
	var/list/data = json_decode(file2text(file))
	name = data["name"]
	desc = data["desc"]
	icon_state = data["side1_icon"]
	side1_icon = data["side1_icon"]
	side2_icon = data["side2_icon"]
	songs = data["songs"]
	song_names = data["song_names"]
	author_name = data["author_name"]
	ckey_author = data["author_ckey"]
	approved_tape = data["approved"]
	qdel(tape)

/obj/item/device/cassette_tape/attack_self(mob/user)
	..()
	icon_state = flipped ? side1_icon : side2_icon
	flipped = !flipped
	to_chat(user,"You flip [src]")

/obj/item/device/cassette_tape/update_desc(updates)
	. = ..()
	if(!approved_tape)
		.+= span_warning("It appears to be a bootleg tape, quality is not a guarentee!")
	if(author_name)
		.+= span_notice("Mixed by [author_name]")

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
			desc = newdesc
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

/datum/cassette/cassette_tape/blank
	id = "blank"

/obj/item/device/cassette_tape/blank
	tape = /datum/cassette/cassette_tape/blank

/datum/cassette/cassette_tape/friday
	id = "friday"

/obj/item/device/cassette_tape/friday
	tape = /datum/cassette/cassette_tape/friday
