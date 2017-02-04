/*
** Procs related to processing how you see names
** remember names
** change names
** manage internal identities
*/

/*
00 mind.voiceprints entries are 5 entry lists indexed by the voiceprint, entries as follows
00 [1] The state of the voiceprint, or where we got the name of it from. See /code/__DEFINES/identity.dm 
00 [2] Timestamp as to when this voiceprint was entered into the voiceprints list. Mainly used so that
00    -- IDENTITY_SEEN will expire if you don't hear the voiceprint for IDENTITY_EXPIRE_TIME (50)
00    -- seconds.
00 [3] Name associated with voiceprint. IDENTITY_INTERACT is semi-permanent and IDENTITY_MANUAL is permanent, wereas
00    -- IDENTITY_HEARD and IDENTITY_SEEN are not.
00 [4] Associated faceprint if available.
00 [5] Last message heard.
00
00 mind.faceprints are 4 entry lists indexed by the faceprint
00 [1] The state of the faceprint, or where we got the name of it from. See /code/__DEFINES/identity.dm
00 [2] Timestamp when you last examined this faceprint.
00 [3] Name associated with the faceprint.
00 [4] Associated voiceprint if available.
00
00 mind.identity_cache entries are 6 entry lists indexed by mob reference, entries as follows
00 [1] Cached voiceprint
00 [2] Timestamp of caching so that it can expire.
00 [3] Cached faceprint
00 [4] Timestamp of [3] so that it can expire.
00 [5] Cached temporary name
00 [6] Timestamp of [5] so that it can expire.
*/

//TODO: If this gets in the game, and stays in the game, for a while, redistribute procs around to appropriate files, then delete this one.

var/global/list/used_voiceprints = list()

/proc/generate_voiceprint()
	var/voiceprint = random_string(32, hex_characters)
	while(used_voiceprints[voiceprint])
		voiceprint = random_string(32, hex_characters)
	used_voiceprints[voiceprint] = TRUE
	. = voiceprint

/atom/movable/proc/get_voiceprint()
	. = fake_voiceprint ? fake_voiceprint : voiceprint

/atom/movable/proc/get_faceprint()

/atom/movable/proc/can_see_face()

/atom/movable/proc/get_voiceprint_name(atom/movable/speaker, voice_print)
	. = speaker.default_identity_interact()

/atom/movable/proc/default_identity_heard()
	. = name

/atom/movable/proc/default_identity_seen()
	. = name

/atom/movable/proc/default_identity_interact()
	. = name

/mob/living/can_see_face()
	. = TRUE

/mob/living/get_voiceprint_name(atom/movable/speaker, voice_print)
	. = speaker.name
	if(client && mind && voice_print && speaker)
		if(voice_print == voiceprint)
			. = "[real_name]"
		else
			var/list/voiceprint_entry = mind.get_print_entry(voice_print, CATEGORY_VOICEPRINTS)
			var/voiceprint_state
			var/voiceprint_time
			var/voiceprint_name
			if(voiceprint_entry)
				voiceprint_state = voiceprint_entry[1]
				voiceprint_time = voiceprint_entry[2]
				voiceprint_name = voiceprint_entry[3]
			else
				voiceprint_entry = new(5)
				voiceprint_state = IDENTITY_HEARD
				voiceprint_time = -128
				voiceprint_name = "Unknown"
			mind.handle_voiceprint_caching(speaker, voice_print)
			if(voiceprint_state > IDENTITY_SEEN || (voiceprint_state == IDENTITY_SEEN && voiceprint_time >= (world.time - IDENTITY_EXPIRE_TIME)))
				if(speaker in view(src))
					voiceprint_name = speaker.default_identity_seen()
					voiceprint_entry[1] = IDENTITY_SEEN
				else
					voiceprint_name = speaker.default_identity_heard()
					voiceprint_entry[1] = IDENTITY_HEARD
				voiceprint_entry[3] = voiceprint_name
			voiceprint_entry[2] = world.time
			mind.set_print_entry(voice_print, voiceprint_entry, CATEGORY_VOICEPRINTS)
			. = voiceprint_name
		if(speaker == src)
			. = "[.] <span class='italics'>(You)</span>"

/mob/living/silicon/get_voiceprint_name(atom/movable/speaker, voice_print)
	. = speaker.name
	if(client && voice_print && speaker)
		var/datum/data/record/G = find_record("voiceprint", voice_print, data_core.general)
		if(G)
			var/G_name = G.fields["name"]
			. = G_name ? G_name : "&lt;NAME MISSING{[G.fields["id"]]}&gt;"
		else
			. = "&lt;NO RECORD&gt;"

/mob/living/proc/last_voiceprint_message(voice_print, message)
	if(client && mind && voice_print && message)
		var/list/voiceprint_entry = mind.get_print_entry(voice_print, CATEGORY_VOICEPRINTS)
		if(voiceprint_entry)
			voiceprint_entry[5] = message
			mind.set_print_entry(voice_print, voiceprint_entry, CATEGORY_VOICEPRINTS)

/datum/mind/proc/remembered_faceprint_name(face_print)
	var/list/faceprint_entry = get_print_entry(face_print, CATEGORY_FACEPRINTS)
	if(faceprint_entry)
		. = faceprint_entry[3]

/datum/mind/proc/handle_voiceprint_caching(atom/movable/speaker, voice_print)
	var/list/cache_entry = identity_cache[speaker]
	if(!cache_entry)
		cache_entry = new(6)
	cache_entry[1] = voice_print
	cache_entry[2] = world.time
	identity_cache[speaker] = cache_entry

/datum/mind/proc/inverse_category(category)
	. = (category % CATEGORY_FACEPRINTS) + 1

/datum/mind/proc/get_print_entry(print, category=CATEGORY_VOICEPRINTS)
	switch(category)
		if(CATEGORY_VOICEPRINTS)
			. = voiceprints[print]
		if(CATEGORY_FACEPRINTS)
			. = faceprints[print]

/datum/mind/proc/set_print_entry(print, list/print_entry, category=CATEGORY_VOICEPRINTS)
	var/list/prints_list
	switch(category)
		if(CATEGORY_VOICEPRINTS)
			prints_list = voiceprints
		if(CATEGORY_FACEPRINTS)
			prints_list = faceprints
	if(print_entry)
		prints_list[print] = print_entry
	else
		prints_list -= print
	update_idman = TRUE

/datum/mind/proc/set_print_manual(print, manual_name, category=CATEGORY_VOICEPRINTS)
	if(print && manual_name)
		var/list/print_entry = get_print_entry(print, category)
		if(!print_entry)
			switch(category)
				if(CATEGORY_VOICEPRINTS)
					print_entry = new(5)
				if(CATEGORY_FACEPRINTS)
					print_entry = new(4)
		print_entry[1] = IDENTITY_MANUAL
		print_entry[2] = world.time
		print_entry[3] = manual_name
		var/linked_print = print_entry[4]
		if(linked_print)
			var/linked_category = inverse_category(category)
			var/linked_print_entry = get_print_entry(linked_print, linked_category)
			if(linked_print_entry && linked_print_entry[4] == print)
				linked_print_entry[1] = IDENTITY_MANUAL
				linked_print_entry[2] = world.time
				linked_print_entry[3] = manual_name
				set_print_entry(linked_print, linked_print_entry, linked_category)
		set_print_entry(print, print_entry, category)

/datum/mind/proc/handle_faceprint_caching(atom/movable/seen, faceprint)
	var/list/cache_entry = identity_cache[seen]
	if(!cache_entry)
		cache_entry = new(6)
	cache_entry[3] = faceprint
	cache_entry[4] = world.time
	identity_cache[seen] = cache_entry

/datum/mind/proc/open_idman()
	if(!current)
		return
	if(!idman)
		idman = new(src)
	idman.ui_interact(current)

/mob/living/carbon/human/default_identity_heard()
	. = "Unknown"

/mob/living/carbon/human/default_identity_seen(default_to_heard=TRUE)
	if(w_uniform && !(wear_suit && (wear_suit.flags_inv & HIDEJUMPSUIT)) && w_uniform.identity_name)
		. = w_uniform.identity_name
	else if(wear_suit && wear_suit.identity_name)
		. = wear_suit.identity_name
	else if(default_to_heard)
		. = default_identity_heard()

/mob/living/carbon/human/default_identity_interact()
	. = get_id_name("")
	if(!.)
		var/hair_text
		var/seen_text = default_identity_seen(FALSE)
		var/accessory_text
		// eyecolor, haircolor+hairstyle, hat or mask, jobname
		if(!hair_covered() && hair_color && hair_style)
			var/htext_color = consonants(color_hex2color(hair_color))
			var/htext_style = consonants(hair_style)
			var/datum/sprite_accessory/hair/tortoise = hair_styles_list[hair_style]
			if(htext_color && tortoise && tortoise.icon_state)
				hair_text = "[htext_color] [htext_style]"
			else
				hair_text = "[htext_style]"
		if(head && head.name)
			accessory_text = " [consonants(head.name)]"
		else if(wear_mask && wear_mask.name)
			accessory_text = " [consonants(wear_mask.name)]"
		. = "[hair_text][seen_text ? " [seen_text]" : ""][accessory_text]"

/mob/living/carbon/human/get_faceprint()
	if(dna)
		. = dna.uni_identity

/datum/identity_manager
	var/cat = CATEGORY_VOICEPRINTS
	var/datum/mind/mind
	var/list/print_refs = list()
	var/list/refs_lookup = list()
	var/selected_ref
	var/select_mode

/datum/identity_manager/New(datum/mind/the_mind)
	if(the_mind && istype(the_mind))
		mind = the_mind
	else
		qdel(src)

/datum/identity_manager/proc/done_selecting()
	if(select_mode == IDMAN_MODE_LINK)
		cat = mind.inverse_category(cat)
	selected_ref = null
	select_mode = null

/datum/identity_manager/proc/unlink(print)
	var/list/print_entry = mind.get_print_entry(print, cat)
	if(!print_entry)
		return
	var/linked_cat = mind.inverse_category(cat)
	var/linked_print = print_entry[4]
	if(linked_print)
		var/list/linked_print_entry = mind.get_print_entry(linked_print, linked_cat)
		if(linked_print_entry && linked_print_entry[4] == print)
			linked_print_entry[4] = null
			mind.set_print_entry(linked_print, linked_print_entry, linked_cat)
	print_entry[4] = null
	mind.set_print_entry(print, print_entry, cat)

/datum/identity_manager/proc/delete_print(ref)
	var/print = print_refs[ref]
	refs_lookup -= print
	print_refs -= ref
	var/list/print_entry = mind.get_print_entry(print, cat)
	if(!print_entry)
		return
	unlink(print)
	mind.set_print_entry(print, null, cat)
	if(selected_ref == ref)
		done_selecting()

/datum/identity_manager/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = alive_state)
	if(!mind)
		qdel(src)
		return
	if(ui && !force_open && !mind.update_idman)
		return
	mind.update_idman = FALSE
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "identity_manager", "identity manager", 700, 800, master_ui, state)
		ui.open()

/datum/identity_manager/ui_data(mob/user)
	var/list/data = list()
	var/list/prints_to_parse
	data["category"] = cat
	data["selectedref"] = selected_ref
	data["selectmode"] = select_mode
	var/list/sent_prints = list()
	var/list/priority_prints = list()
	switch(cat)
		if(CATEGORY_VOICEPRINTS)
			prints_to_parse = mind.voiceprints
		if(CATEGORY_FACEPRINTS)
			prints_to_parse = mind.faceprints
	for(var/print in prints_to_parse)
		var/list/print_send = list()
		var/list/prints_entry = prints_to_parse[print]
		var/print_state = prints_entry[1]
		var/print_time = prints_entry[2]
		var/print_name = prints_entry[3]
		if(print_state > IDENTITY_INTERACT && print_time < (world.time - IDENTITY_EXPIRE_TIME))
			var/oldref = refs_lookup[print]
			if(oldref)
				delete_print(oldref)
			continue
		print_send["identitystate"] = print_state
		print_send["timestamp"] = gameTimestamp(print_time, "hh:mm")
		print_send["time"] = print_time
		print_send["name"] = print_name
		print_send["linked"] = prints_entry[4] ? "1" : ""
		switch(cat)
			if(CATEGORY_VOICEPRINTS)
				print_send["lastmsg"] = prints_entry[5]
			if(CATEGORY_FACEPRINTS)
				var/voice_print = prints_entry[4]
				var/VP_entry = mind.get_print_entry(voice_print, CATEGORY_VOICEPRINTS)
				if(VP_entry)
					print_send["lastmsg"] = VP_entry[5]
		var/ref = refs_lookup[print]
		if(!ref)
			ref = random_string(8, hex_characters)
			while(print_refs[ref])
				ref = random_string(8, hex_characters)
			print_refs[ref] = print
			refs_lookup[print] = ref
		print_send["printref"] = ref
		if(selected_ref != ref)
			sent_prints[++sent_prints.len] = print_send
		else
			priority_prints[++priority_prints.len] = print_send
	sortTim(sent_prints, /proc/cmp_identitymanager_sort)
	if(priority_prints.len)
		sortTim(priority_prints, /proc/cmp_identitymanager_sort)
		sent_prints.Insert(1, priority_prints)
	data["prints"] = sent_prints
	. = data

/datum/identity_manager/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!mind)
		qdel(src)
		return
	mind.update_idman = TRUE
	. = 1
	switch(action)
		if("deleteprint")
			var/ref = params["printref"]
			delete_print(ref)
		if("changecategory")
			var/acceptablecats = list(CATEGORY_VOICEPRINTS, CATEGORY_FACEPRINTS) //meow
			var/possiblecat = text2num(params["category"])
			if(possiblecat in acceptablecats)
				cat = possiblecat
		if("editprint")
			var/ref = params["printref"]
			if(!ref)
				return 0
			selected_ref = ref
			select_mode = IDMAN_MODE_EDIT
		if("selectprint")
			var/ref = params["printref"]
			if(!ref || select_mode)
				return 0
			selected_ref = ref
		if("cancelselect")
			done_selecting()
		if("linkprint")
			var/ref = params["printref"]
			var/print = print_refs[ref]
			var/list/print_entry = mind.get_print_entry(print, cat)
			if(!(ref && print && print_entry))
				return 0
			if(print_entry[1] > IDENTITY_INTERACT)
				mind.set_print_manual(print, print_entry[3], cat)
			if(select_mode != IDMAN_MODE_LINK)
				selected_ref = ref
				select_mode = IDMAN_MODE_LINK
				cat = mind.inverse_category(cat)
			else
				var/selected_cat = mind.inverse_category(cat)
				var/list/selected_print = print_refs[selected_ref]
				if(!selected_ref || !selected_print) 
					done_selecting()
					return
				var/list/selected_print_entry = mind.get_print_entry(selected_print, selected_cat)
				if(!selected_print_entry)
					done_selecting()
					return
				var/selected_name = selected_print_entry[3]
				selected_print_entry[4] = print
				print_entry[4] = selected_print
				mind.set_print_entry(selected_print, selected_print_entry, selected_cat)
				mind.set_print_entry(print, print_entry, cat)
				mind.set_print_manual(selected_print, selected_name, selected_cat)
				done_selecting()
		if("unlinkprint")
			var/ref = params["printref"]
			var/print = print_refs[ref]
			if(print)
				unlink(print)
		if("writeprint")
			var/ref = params["printref"]
			var/print = print_refs[ref]
			var/print_entry = mind.get_print_entry(print, cat)
			var/newname = params["name"]
			done_selecting()
			if(!(ref && print && print_entry && newname))
				return
			newname = strip_html_simple(newname)
			mind.set_print_manual(print, newname, cat)
