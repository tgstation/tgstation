GLOBAL_VAR(posibrain_notify_cooldown)

/obj/item/mmi/posibrain
	name = "positronic brain"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "posibrain"
	w_class = WEIGHT_CLASS_NORMAL
	var/ask_role = "" ///Can be set to tell ghosts what the brain will be used for
	var/next_ask ///World time tick when ghost polling will be available again
	var/askDelay = 600 ///Delay after polling ghosts
	var/searching = FALSE
	req_access = list(ACCESS_ROBOTICS)
	braintype = "Android"
	var/autoping = TRUE ///If it pings on creation immediately
	///Message sent to the user when polling ghosts
	var/begin_activation_message = "<span class='notice'>You carefully locate the manual activation switch and start the positronic brain's boot process.</span>"
	///Message sent as a visible message on success
	var/success_message = "<span class='notice'>The positronic brain pings, and its lights start flashing. Success!</span>"
	///Message sent as a visible message on failure
	var/fail_message = "<span class='notice'>The positronic brain buzzes quietly, and the golden lights fade away. Perhaps you could try again?</span>"
	///Role assigned to the newly created mind
	var/new_role = "Positronic Brain"
	///Visible message sent when a player possesses the brain
	var/new_mob_message = "<span class='notice'>The positronic brain chimes quietly.</span>"
	///Examine message when the posibrain has no mob
	var/dead_message = "<span class='deadsay'>It appears to be completely inactive. The reset light is blinking.</span>"
	///Examine message when the posibrain cannot poll ghosts due to cooldown
	var/recharge_message = "<span class='warning'>The positronic brain isn't ready to activate again yet! Give it some time to recharge.</span>"
	var/list/possible_names ///One of these names is randomly picked as the posibrain's name on possession. If left blank, it will use the global posibrain names
	var/picked_name ///Picked posibrain name

/obj/item/mmi/posibrain/Topic(href, href_list)
	if(href_list["activate"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			activate(ghost)

///Notify ghosts that the posibrain is up for grabs
/obj/item/mmi/posibrain/proc/ping_ghosts(msg, newlymade)
	if(newlymade || GLOB.posibrain_notify_cooldown <= world.time)
		notify_ghosts("[name] [msg] in [get_area(src)]! [ask_role ? "Personality requested: \[[ask_role]\]" : ""]", ghost_sound = !newlymade ? 'sound/effects/ghost2.ogg':null, notify_volume = 75, enter_link = "<a href=?src=[REF(src)];activate=1>(Click to enter)</a>", source = src, action = NOTIFY_ATTACK, flashwindow = FALSE, ignore_key = POLL_IGNORE_POSIBRAIN, notify_suiciders = FALSE)
		if(!newlymade)
			GLOB.posibrain_notify_cooldown = world.time + askDelay

/obj/item/mmi/posibrain/attack_self(mob/user)
	if(!brainmob)
		set_brainmob(new /mob/living/brain(src))
	if(!(GLOB.ghost_role_flags & GHOSTROLE_SILICONS))
		to_chat(user, "<span class='warning'>Central Command has temporarily outlawed posibrain sentience in this sector...</span>")
	if(is_occupied())
		to_chat(user, "<span class='warning'>This [name] is already active!</span>")
		return
	if(next_ask > world.time)
		to_chat(user, recharge_message)
		return
	//Start the process of requesting a new ghost.
	to_chat(user, begin_activation_message)
	ping_ghosts("requested", FALSE)
	next_ask = world.time + askDelay
	searching = TRUE
	update_icon()
	addtimer(CALLBACK(src, .proc/check_success), askDelay)

/obj/item/mmi/posibrain/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE))
		return
	var/input_seed = stripped_input(user, "Enter a personality seed", "Enter seed", ask_role, MAX_NAME_LEN)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE))
		return
	if(input_seed)
		to_chat(user, "<span class='notice'>You set the personality seed to \"[input_seed]\".</span>")
		ask_role = input_seed
		update_icon()

/obj/item/mmi/posibrain/proc/check_success()
	searching = FALSE
	update_icon()
	if(QDELETED(brainmob))
		return
	if(brainmob.client)
		visible_message(success_message)
		playsound(src, 'sound/machines/ping.ogg', 15, TRUE)
	else
		visible_message(fail_message)

///ATTACK GHOST IGNORING PARENT RETURN VALUE
/obj/item/mmi/posibrain/attack_ghost(mob/user)
	activate(user)

/obj/item/mmi/posibrain/proc/is_occupied()
	if(brainmob.key)
		return TRUE
	if(iscyborg(loc))
		var/mob/living/silicon/robot/R = loc
		if(R.mmi == src)
			return TRUE
	return FALSE

///Two ways to activate a positronic brain. A clickable link in the ghost notif, or simply clicking the object itself.
/obj/item/mmi/posibrain/proc/activate(mob/user)
	if(QDELETED(brainmob))
		return
	if(is_occupied() || is_banned_from(user.ckey, ROLE_POSIBRAIN) || QDELETED(brainmob) || QDELETED(src) || QDELETED(user))
		return
	if(user.suiciding) //if they suicided, they're out forever.
		to_chat(user, "<span class='warning'>[src] fizzles slightly. Sadly it doesn't take those who suicided!</span>")
		return
	var/posi_ask = alert("Become a [name]? (Warning, You can no longer be revived, and all past lives will be forgotten!)","Are you positive?","Yes","No")
	if(posi_ask == "No" || QDELETED(src))
		return
	if(brainmob.suiciding) //clear suicide status if the old occupant suicided.
		brainmob.set_suicide(FALSE)
	transfer_personality(user)

/obj/item/mmi/posibrain/transfer_identity(mob/living/carbon/C)
	name = "[initial(name)] ([C])"
	brainmob.name = C.real_name
	brainmob.real_name = C.real_name
	if(C.has_dna())
		if(!brainmob.stored_dna)
			brainmob.stored_dna = new /datum/dna/stored(brainmob)
		C.dna.copy_dna(brainmob.stored_dna)
	brainmob.timeofhostdeath = C.timeofdeath
	brainmob.set_stat(CONSCIOUS)
	if(brainmob.mind)
		brainmob.mind.assigned_role = new_role
	if(C.mind)
		C.mind.transfer_to(brainmob)

	brainmob.mind.remove_all_antag()
	brainmob.mind.wipe_memory()
	update_icon()

///Moves the candidate from the ghost to the posibrain
/obj/item/mmi/posibrain/proc/transfer_personality(mob/candidate)
	if(QDELETED(brainmob))
		return
	if(is_occupied()) //Prevents hostile takeover if two ghosts get the prompt or link for the same brain.
		to_chat(candidate, "<span class='warning'>This [name] was taken over before you could get to it! Perhaps it might be available later?</span>")
		return FALSE
	if(candidate.mind && !isobserver(candidate))
		candidate.mind.transfer_to(brainmob)
	else
		brainmob.ckey = candidate.ckey
	name = "[initial(name)] ([brainmob.name])"
	var/policy = get_policy(ROLE_POSIBRAIN)
	if(policy)
		to_chat(brainmob, policy)
	brainmob.mind.assigned_role = new_role
	brainmob.set_stat(CONSCIOUS)

	visible_message(new_mob_message)
	check_success()
	return TRUE


/obj/item/mmi/posibrain/examine(mob/user)
	. = ..()
	if(brainmob?.key)
		switch(brainmob.stat)
			if(CONSCIOUS)
				if(!brainmob.client)
					. += "It appears to be in stand-by mode." //afk
			if(DEAD)
				. += "<span class='deadsay'>It appears to be completely inactive.</span>"
	else
		. += "[dead_message]"
		if(ask_role)
			. += "<span class='notice'>Current consciousness seed: \"[ask_role]\"</span>"
		. += "<span class='boldnotice'>Alt-click to set a consciousness seed, specifying what [src] will be used for. This can help generate a personality interested in that role.</span>"

/obj/item/mmi/posibrain/Initialize()
	. = ..()
	set_brainmob(new /mob/living/brain(src))
	var/new_name
	if(!LAZYLEN(possible_names))
		new_name = pick(GLOB.posibrain_names)
	else
		new_name = pick(possible_names)
	brainmob.name = "[new_name]-[rand(100, 999)]"
	brainmob.real_name = brainmob.name
	brainmob.forceMove(src)
	brainmob.container = src
	if(autoping)
		ping_ghosts("created", TRUE)


/obj/item/mmi/posibrain/attackby(obj/item/O, mob/user)
	return


/obj/item/mmi/posibrain/update_icon_state()
	if(searching)
		icon_state = "[initial(icon_state)]-searching"
	else if(brainmob?.key)
		icon_state = "[initial(icon_state)]-occupied"
	else
		icon_state = initial(icon_state)

/obj/item/mmi/posibrain/add_mmi_overlay()
	return
