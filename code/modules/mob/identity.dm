/*
** Procs related to processing how you see names
** remember names
** change names
** manage internal identities
**
** see code/__DEFINES/identity.dm for information on the data structures
*/

//TODO: If this gets in the game, and stays in the game, for a while, redistribute procs around to appropriate files, then delete this one.

var/global/list/used_voiceprints = list()

/proc/generate_voiceprint()
	var/voiceprint = random_string(32, hex_characters)
	while(used_voiceprints[voiceprint])
		voiceprint = random_string(32, hex_characters)
	used_voiceprints[voiceprint] = TRUE
	. = voiceprint

/atom/proc/get_voiceprint()

/atom/movable/get_voiceprint()
	. = fake_voiceprint ? fake_voiceprint : voiceprint

/atom/proc/get_faceprint()

/atom/proc/can_see_face()

/atom/proc/get_voiceprint_name(atom/speaker, voice_print)
	. = speaker.default_identity_interact()

/atom/proc/default_identity_heard()
	. = name

/atom/proc/default_identity_seen()
	. = name

/atom/proc/default_identity_interact()
	. = name

/atom/proc/get_interact_name(atom/target)
	. = target.default_identity_interact()

/mob/proc/identity_subject_name(atom/A)
	if(A == src)
		. = real_name
	else if(mind)
		var/list/A_identity = mind.identity_cache[A]
		var/list/A_FP_entry
		var/A_name
		var/A_voiceprint
		var/A_voiceprint_time
		var/A_faceprint
		var/A_faceprint_time
		var/A_temp
		var/A_temp_time
		if(A_identity)
			A_voiceprint = A_identity[IDENTITY_CACHE_VOICEPRINT]
			A_voiceprint_time = A_identity[IDENTITY_CACHE_VOICEPRINT_TIME]
			A_faceprint = A_identity[IDENTITY_CACHE_FACEPRINT]
			A_faceprint_time = A_identity[IDENTITY_CACHE_FACEPRINT_TIME]
			A_temp = A_identity[IDENTITY_CACHE_TEMP]
			A_temp_time = A_identity[IDENTITY_CACHE_TEMP_TIME]
		else
			A_identity = new(IDENTITY_CACHE_LENGTH)
		if(A_faceprint && A_faceprint_time >= (world.time - IDENTITY_EXPIRE_TIME))
			A_FP_entry = mind.get_print_entry(A_faceprint, CATEGORY_FACEPRINTS)
		else if(A.can_see_face())
			var/A_faceprint_new = A.get_faceprint()
			if(A_faceprint_new)
				mind.handle_faceprint_caching(A, A_faceprint_new)
				A_FP_entry = mind.get_print_entry(A_faceprint_new, CATEGORY_FACEPRINTS)
		if(A_FP_entry)
			A_name = A_FP_entry[IDENTITY_PRINT_NAME]
		if(!A_name && A_voiceprint && A_voiceprint_time >= (world.time - IDENTITY_EXPIRE_TIME))
			var/list/A_VP_entry = mind.get_print_entry(A_voiceprint, CATEGORY_VOICEPRINTS)
			if(A_VP_entry)
				A_name = A_VP_entry[IDENTITY_PRINT_NAME]
		if(!A_name)
			if(A_temp && A_temp_time >= (world.time - TEMP_IDENTITY_EXPIRE))
				A_name = A_temp
			else
				A_name = A.default_identity_seen()
				A_identity[IDENTITY_CACHE_TEMP] = A_name
				A_identity[IDENTITY_CACHE_TEMP_TIME] = world.time
		mind.identity_cache[A] = A_identity
		. = A_name

/mob/proc/parse_identity_subjects(msg, list/subjects)
	if(subjects && subjects.len)
		for(var/i=1, i<=subjects.len, i++)
			var/subject_string = IDENTITY_SUBJECT(i)
			if(!findtextEx(msg, subject_string))
				continue
			var/atom/A = subjects[i]
			var/A_name = identity_subject_name(A)
			msg = replacetextEx(msg, subject_string, A_name)
	. = msg

/mob/living/can_see_face()
	. = TRUE

/mob/living/get_voiceprint_name(atom/speaker, voice_print)
	. = speaker.name
	if(client && mind && voice_print)
		if(voice_print == voiceprint)
			. = "[real_name]"
		else
			var/list/voiceprint_entry = mind.get_print_entry(voice_print, CATEGORY_VOICEPRINTS)
			var/voiceprint_state
			var/voiceprint_time
			var/voiceprint_name
			if(voiceprint_entry)
				voiceprint_state = voiceprint_entry[IDENTITY_PRINT_STATE]
				voiceprint_time = voiceprint_entry[IDENTITY_PRINT_TIMESTAMP]
				voiceprint_name = voiceprint_entry[IDENTITY_PRINT_NAME]
			else
				voiceprint_entry = new(VOICEPRINTS_LIST_LENGTH)
				voiceprint_state = IDENTITY_HEARD
				voiceprint_time = -128
				voiceprint_name = "Unknown"
			mind.handle_voiceprint_caching(speaker, voice_print)
			if(voiceprint_state > IDENTITY_SEEN || (voiceprint_state == IDENTITY_SEEN && voiceprint_time >= (world.time - IDENTITY_EXPIRE_TIME)))
				if(speaker in view(src))
					voiceprint_name = speaker.default_identity_seen()
					voiceprint_entry[IDENTITY_PRINT_STATE] = IDENTITY_SEEN
				else
					voiceprint_name = speaker.default_identity_heard()
					voiceprint_entry[IDENTITY_PRINT_STATE] = IDENTITY_HEARD
				voiceprint_entry[IDENTITY_PRINT_NAME] = voiceprint_name
			voiceprint_entry[IDENTITY_PRINT_TIMESTAMP] = world.time
			mind.set_print_entry(voice_print, voiceprint_entry, CATEGORY_VOICEPRINTS)
			. = voiceprint_name
		if(speaker == src)
			. = "[.] <span class='italics'>(You)</span>"

/mob/living/get_interact_name(atom/target)
	. = target.name
	if(target == src)
		. = real_name
	else if(mind)
		var/list/faceprint_entry
		var/faceprint
		var/interact_identity = target.default_identity_interact()
		var/seen_identity = target.default_identity_seen()
		if(target.can_see_face())
			faceprint = target.get_faceprint()
			if(faceprint)
				faceprint_entry = mind.get_print_entry(faceprint, CATEGORY_FACEPRINTS)
				var/faceprint_state
				var/faceprint_name
				mind.handle_faceprint_caching(target, faceprint)
				if(faceprint_entry)
					faceprint_state = faceprint_entry[IDENTITY_PRINT_STATE]
					faceprint_name = faceprint_entry[IDENTITY_PRINT_NAME]
				if(interact_identity == seen_identity && !faceprint_name)
					faceprint_name = interact_identity
				else if(!faceprint_name || faceprint_state > IDENTITY_INTERACT)
					faceprint_state = IDENTITY_INTERACT
					faceprint_name = interact_identity
					faceprint_entry = new(FACEPRINTS_LIST_LENGTH)
					faceprint_entry[IDENTITY_PRINT_STATE] = faceprint_state
					faceprint_entry[IDENTITY_PRINT_TIMESTAMP] = world.time
					faceprint_entry[IDENTITY_PRINT_NAME] = faceprint_name
				. = faceprint_name
		else
			. = interact_identity
		var/list/cache_entry = mind.identity_cache[target]
		var/voice_print
		var/list/voiceprint_entry
		if(cache_entry)
			voice_print = cache_entry[IDENTITY_CACHE_VOICEPRINT]
			var/voiceprint_cache_time = cache_entry[IDENTITY_CACHE_VOICEPRINT_TIME]
			if(voice_print && voiceprint_cache_time >= (world.time - IDENTITY_EXPIRE_TIME))
				voiceprint_entry = mind.get_print_entry(voice_print, CATEGORY_VOICEPRINTS)
				var/voiceprint_state
				var/voiceprint_name
				if(voiceprint_entry)
					voiceprint_state = voiceprint_entry[IDENTITY_PRINT_STATE]
					voiceprint_name = voiceprint_entry[IDENTITY_PRINT_NAME]
					if(voiceprint_state >= IDENTITY_INTERACT)
						voiceprint_entry[1] = IDENTITY_INTERACT
						voiceprint_entry[IDENTITY_PRINT_NAME] = interact_identity
					else
						. = voiceprint_name
						if(faceprint_entry)
							faceprint_entry[IDENTITY_PRINT_STATE] = voiceprint_state
							faceprint_entry[IDENTITY_PRINT_NAME] = voiceprint_name
					if(faceprint_entry)
						voiceprint_entry[IDENTITY_PRINT_LINKED] = faceprint
						faceprint_entry[IDENTITY_PRINT_LINKED] = voice_print
		if(faceprint_entry)
			mind.set_print_entry(faceprint, faceprint_entry, CATEGORY_FACEPRINTS)
		if(voiceprint_entry)
			mind.set_print_entry(voice_print, voiceprint_entry, CATEGORY_VOICEPRINTS)

/mob/living/silicon/get_voiceprint_name(atom/speaker, voice_print)
	. = speaker.name
	if(client && voice_print)
		var/datum/data/record/G = find_record("voiceprint", voice_print, data_core.general)
		if(G)
			var/G_name = G.fields["name"]
			. = G_name ? G_name : "&lt;NAME MISSING{[G.fields["id"]]}&gt;"
		else
			. = "&lt;NO RECORD&gt;"

/mob/living/silicon/get_interact_name(atom/target)
	. = target.name
	if(client)
		var/datum/data/record/G
		if(target.can_see_face())
			var/faceprint = target.get_faceprint()
			if(faceprint)
				G = find_record("faceprint", faceprint, data_core.general)
		if(G)
			var/G_name = G.fields["name"]
			. = G_name ? G_name : "&lt;NAME MISSING{[G.fields["id"]]}&gt;"
		else
			. = "&lt;NO RECORD&gt;"

/mob/living/silicon/identity_subject_name(atom/A)
	if(A == src)
		. = real_name
	else if(mind)
		var/list/A_identity = mind.identity_cache[A]
		var/A_name
		var/A_temp
		var/A_temp_time
		if(A_identity)
			A_temp = A_identity[IDENTITY_CACHE_TEMP]
			A_temp_time = A_identity[IDENTITY_CACHE_TEMP_TIME]
		else
			A_identity = new(IDENTITY_CACHE_LENGTH)
		if(A_temp && A_temp_time >= (world.time - TEMP_IDENTITY_EXPIRE))
			A_name = A_temp
		else
			var/faceprint = A.get_faceprint()
			var/datum/data/record/G
			if(faceprint)
				G = find_record("faceprint", faceprint, data_core.general)
			if(G)
				var/G_name = G.fields["name"]
				A_name = G_name ? G_name : "&lt;NAME MISSING{[G.fields["id"]]}&gt;"
			else
				A_name = "&lt;NO RECORD&gt;"
			A_identity[IDENTITY_CACHE_TEMP] = A_name
			A_identity[IDENTITY_CACHE_TEMP_TIME] = world.time
		mind.identity_cache[A] = A_identity
		. = A_name

/mob/dead/observer/get_voiceprint_name(atom/speaker, voice_print)
	. = speaker.name
	if(ismob(speaker))
		var/mob/M = speaker
		. = M.real_name

/mob/dead/observer/get_interact_name(atom/target)
	. = target.name
	if(ismob(target))
		var/mob/M = target
		. = M.real_name

/mob/dead/observer/identity_subject_name(atom/A)
	. = A.name
	if(ismob(A))
		var/mob/M = A
		. = M.real_name

/mob/living/proc/last_voiceprint_message(voice_print, message)
	if(client && mind && voice_print && message)
		var/list/voiceprint_entry = mind.get_print_entry(voice_print, CATEGORY_VOICEPRINTS)
		if(voiceprint_entry)
			voiceprint_entry[IDENTITY_VOICEPRINT_MSG] = message
			mind.set_print_entry(voice_print, voiceprint_entry, CATEGORY_VOICEPRINTS)

/datum/mind/proc/remembered_faceprint_name(face_print)
	var/list/faceprint_entry = get_print_entry(face_print, CATEGORY_FACEPRINTS)
	if(faceprint_entry)
		. = faceprint_entry[IDENTITY_PRINT_NAME]

/datum/mind/proc/handle_voiceprint_caching(atom/speaker, voice_print)
	var/list/cache_entry = identity_cache[speaker]
	if(!cache_entry)
		cache_entry = new(IDENTITY_CACHE_LENGTH)
	cache_entry[IDENTITY_CACHE_VOICEPRINT] = voice_print
	cache_entry[IDENTITY_CACHE_VOICEPRINT_TIME] = world.time
	identity_cache[speaker] = cache_entry

/datum/mind/proc/voiceprint_edit_tag(voice_print)
	if(!voice_print)
		return
	var/list/voiceprint_entry = get_print_entry(voice_print, CATEGORY_VOICEPRINTS)
	var/list/tag_entry
	var/edit_tag
	var/generate = TRUE
	if(!voiceprint_entry)
		return
	edit_tag = voiceprint_entry[IDENTITY_VOICEPRINT_EDIT]
	tag_entry = identity_edit_tags[edit_tag]
	if(tag_entry)
		if(tag_entry[IDENTITY_EDIT_TAG_TIMESTAMP] >= world.time - IDENTITY_EXPIRE_TIME)
			generate = FALSE
		else
			identity_edit_tags -= edit_tag
	while(generate)
		edit_tag = random_string(8, hex_characters)
		tag_entry = identity_edit_tags[edit_tag]
		if(!tag_entry || tag_entry[IDENTITY_EDIT_TAG_TIMESTAMP] < world.time - IDENTITY_EXPIRE_TIME)
			generate = FALSE
	voiceprint_entry[IDENTITY_VOICEPRINT_EDIT] = edit_tag
	set_print_entry(voice_print, voiceprint_entry, CATEGORY_VOICEPRINTS)
	if(!tag_entry)
		tag_entry = new(IDENTITY_TAGS_LENGTH)
	tag_entry[IDENTITY_EDIT_TAG_PRINT] = voice_print
	tag_entry[IDENTITY_EDIT_TAG_TIMESTAMP] = world.time
	identity_edit_tags[edit_tag] = tag_entry
	return edit_tag

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
					print_entry = new(VOICEPRINTS_LIST_LENGTH)
				if(CATEGORY_FACEPRINTS)
					print_entry = new(FACEPRINTS_LIST_LENGTH)
		print_entry[IDENTITY_PRINT_STATE] = IDENTITY_MANUAL
		print_entry[IDENTITY_PRINT_TIMESTAMP] = world.time
		print_entry[IDENTITY_PRINT_NAME] = manual_name
		var/linked_print = print_entry[IDENTITY_PRINT_LINKED]
		if(linked_print)
			var/linked_category = inverse_category(category)
			var/linked_print_entry = get_print_entry(linked_print, linked_category)
			if(linked_print_entry && linked_print_entry[IDENTITY_PRINT_LINKED] == print)
				linked_print_entry[IDENTITY_PRINT_STATE] = IDENTITY_MANUAL
				linked_print_entry[IDENTITY_PRINT_TIMESTAMP] = world.time
				linked_print_entry[IDENTITY_PRINT_NAME] = manual_name
				set_print_entry(linked_print, linked_print_entry, linked_category)
		set_print_entry(print, print_entry, category)

/datum/mind/proc/preknown_identity(mob/living/subject)
	var/voice_print = subject.voiceprint
	var/faceprint = subject.get_faceprint()
	var/subject_name = subject.real_name
	if(voice_print)
		set_print_manual(voice_print, subject_name, CATEGORY_VOICEPRINTS)
	if(faceprint)
		set_print_manual(faceprint, subject_name, CATEGORY_FACEPRINTS)
	if(voice_print && faceprint)
		unlink_print(voice_print, CATEGORY_VOICEPRINTS)
		unlink_print(faceprint, CATEGORY_FACEPRINTS)
		link_print(voice_print, faceprint, CATEGORY_VOICEPRINTS)

/datum/mind/proc/link_print(print, linked_print, print_category)
	var/print_entry = get_print_entry(print, print_category)
	var/linked_category = inverse_category(print_category)
	var/list/linked_print_entry = get_print_entry(linked_print, linked_category)
	if(!(print_entry && linked_print_entry))
		return FALSE
	var/print_name = print_entry[IDENTITY_PRINT_NAME]
	linked_print_entry[IDENTITY_PRINT_LINKED] = print
	print_entry[IDENTITY_PRINT_LINKED] = linked_print
	set_print_entry(linked_print, linked_print_entry, linked_category)
	set_print_entry(print, print_entry, print_category)
	set_print_manual(print, print_name, print_category)
	. = TRUE

/datum/mind/proc/unlink_print(print, category)
	var/list/print_entry = get_print_entry(print, category)
	if(!print_entry)
		return
	var/linked_category = inverse_category(category)
	var/linked_print = print_entry[IDENTITY_PRINT_LINKED]
	if(linked_print)
		var/list/linked_print_entry = get_print_entry(linked_print, linked_category)
		if(linked_print_entry && linked_print_entry[IDENTITY_PRINT_LINKED] == print)
			linked_print_entry[IDENTITY_PRINT_LINKED] = null
			set_print_entry(linked_print, linked_print_entry, linked_category)
	print_entry[IDENTITY_PRINT_LINKED] = null
	set_print_entry(print, print_entry, category)

/datum/mind/proc/handle_faceprint_caching(atom/seen, faceprint)
	var/list/cache_entry = identity_cache[seen]
	if(!cache_entry)
		cache_entry = new(IDENTITY_CACHE_LENGTH)
	cache_entry[IDENTITY_CACHE_FACEPRINT] = faceprint
	cache_entry[IDENTITY_CACHE_FACEPRINT_TIME] = world.time
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
		var/text_count = 0
		var/see_face = can_see_face()
		var/hair_text
		var/identity_text = default_identity_seen(FALSE)
		var/accessory_text
		var/eye_text
		if(identity_text)
			text_count++
		else //since we didn't get an identity_name from clothing, don't count this towards the text count
			var/temp_gender = gender
			var/list/obscured = check_obscured_slots()
			if((slot_w_uniform in obscured) && !see_face)
				temp_gender = PLURAL
			var/static/list/identity_text_genders = list(MALE, FEMALE)
			if(temp_gender in identity_text_genders)
				identity_text = temp_gender
			else
				identity_text = default_identity_heard()
		if(!hair_covered() && hair_color && hair_style)
			var/htext_color = color_hex2color(hair_color)
			var/htext_style = hair_style
			var/datum/sprite_accessory/hair/tortoise = hair_styles_list[hair_style]
			if(htext_color && tortoise && tortoise.icon_state)
				hair_text = "[htext_color] [htext_style]ed "
				text_count++
		if(text_count < 2)
			if(head && head.name)
				accessory_text = " with [head.name]"
				text_count++
			else if(wear_mask && wear_mask.name)
				accessory_text = " with [wear_mask.name]"
				text_count++
		if(text_count < 2 && eye_color && see_face && !(head && head.flags_inv & HIDEEYES))
			var/color_eyes = color_hex2color(eye_color)
			if(color_eyes)
				eye_text = "[color_eyes] eyed "
				text_count++
		. = capitalize("[hair_text][eye_text][identity_text][accessory_text]")

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

/datum/identity_manager/Destroy()
	if(mind)
		mind.idman = null
		qdel(mind)
		mind = null

/datum/identity_manager/proc/done_selecting()
	if(select_mode == IDMAN_MODE_LINK)
		cat = mind.inverse_category(cat)
	selected_ref = null
	select_mode = null

/datum/identity_manager/proc/delete_print(ref)
	var/print = print_refs[ref]
	refs_lookup -= print
	print_refs -= ref
	var/list/print_entry = mind.get_print_entry(print, cat)
	if(!print_entry)
		return
	mind.unlink_print(print, cat)
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
		var/print_state = prints_entry[IDENTITY_PRINT_STATE]
		var/print_time = prints_entry[IDENTITY_PRINT_TIMESTAMP]
		var/print_name = prints_entry[IDENTITY_PRINT_NAME]
		if(print_state > IDENTITY_INTERACT && print_time < (world.time - IDENTITY_EXPIRE_TIME))
			var/oldref = refs_lookup[print]
			if(oldref)
				delete_print(oldref)
			continue
		print_send["identitystate"] = print_state
		print_send["timestamp"] = gameTimestamp(print_time, "hh:mm")
		print_send["time"] = print_time
		print_send["name"] = print_name
		print_send["linked"] = prints_entry[IDENTITY_PRINT_LINKED] ? "1" : ""
		switch(cat)
			if(CATEGORY_VOICEPRINTS)
				print_send["lastmsg"] = prints_entry[IDENTITY_VOICEPRINT_MSG]
			if(CATEGORY_FACEPRINTS)
				var/voice_print = prints_entry[IDENTITY_PRINT_LINKED]
				var/VP_entry = mind.get_print_entry(voice_print, CATEGORY_VOICEPRINTS)
				if(VP_entry)
					print_send["lastmsg"] = VP_entry[IDENTITY_VOICEPRINT_MSG]
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
			if(print_entry[IDENTITY_PRINT_STATE] > IDENTITY_INTERACT)
				mind.set_print_manual(print, print_entry[IDENTITY_PRINT_NAME], cat)
			if(select_mode != IDMAN_MODE_LINK)
				selected_ref = ref
				select_mode = IDMAN_MODE_LINK
				cat = mind.inverse_category(cat)
			else
				var/selected_cat = mind.inverse_category(cat)
				var/list/selected_print = print_refs[selected_ref]
				if(!(selected_ref && selected_print))
					done_selecting()
					return
				mind.link_print(selected_print, print, selected_cat)
				done_selecting()
		if("unlinkprint")
			var/ref = params["printref"]
			var/print = print_refs[ref]
			if(print)
				mind.unlink_print(print, cat)
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
