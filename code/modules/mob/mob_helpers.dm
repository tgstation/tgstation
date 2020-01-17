// see _DEFINES/is_helpers.dm for mob type checks

///Find the mob at the bottom of a buckle chain
/mob/proc/lowest_buckled_mob()
	. = src
	if(buckled && ismob(buckled))
		var/mob/Buckled = buckled
		. = Buckled.lowest_buckled_mob()

///Convert a PRECISE ZONE into the BODY_ZONE
/proc/check_zone(zone)
	if(!zone)
		return BODY_ZONE_CHEST
	switch(zone)
		if(BODY_ZONE_PRECISE_EYES)
			zone = BODY_ZONE_HEAD
		if(BODY_ZONE_PRECISE_MOUTH)
			zone = BODY_ZONE_HEAD
		if(BODY_ZONE_PRECISE_L_HAND)
			zone = BODY_ZONE_L_ARM
		if(BODY_ZONE_PRECISE_R_HAND)
			zone = BODY_ZONE_R_ARM
		if(BODY_ZONE_PRECISE_L_FOOT)
			zone = BODY_ZONE_L_LEG
		if(BODY_ZONE_PRECISE_R_FOOT)
			zone = BODY_ZONE_R_LEG
		if(BODY_ZONE_PRECISE_GROIN)
			zone = BODY_ZONE_CHEST
	return zone

/**
  * Return the zone or randomly, another valid zone
  *
  * probability controls the chance it chooses the passed in zone, or another random zone
  * defaults to 80
  */
/proc/ran_zone(zone, probability = 80)
	if(prob(probability))
		zone = check_zone(zone)
	else
		zone = pickweight(list(BODY_ZONE_HEAD = 1, BODY_ZONE_CHEST = 1, BODY_ZONE_L_ARM = 4, BODY_ZONE_R_ARM = 4, BODY_ZONE_L_LEG = 4, BODY_ZONE_R_LEG = 4))
	return zone

///Would this zone be above the neck
/proc/above_neck(zone)
	var/list/zones = list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_EYES)
	if(zones.Find(zone))
		return 1
	else
		return 0
/**
  * Convert random parts of a passed in message to stars
  *
  * * n - the string to convert
  * * pr - probability any character gets changed
  *
  * This proc is dangerously laggy, avoid it or die
  */
/proc/stars(n, pr)
	n = html_encode(n)
	if (pr == null)
		pr = 25
	if (pr <= 0)
		return null
	else
		if (pr >= 100)
			return n
	var/te = n
	var/t = ""
	n = length(n)

	for(var/p = 1 to min(n,MAX_BROADCAST_LEN))
		if ((copytext(te, p, p + 1) == " " || prob(pr)))
			t = text("[][]", t, copytext(te, p, p + 1))
		else
			t = text("[]*", t)
	if(n > MAX_BROADCAST_LEN)
		t += "..." //signals missing text
	return sanitize(t)
/**
  * Makes you speak like you're drunk
  */
/proc/slur(n)
	var/phrase = html_decode(n)
	var/leng = length(phrase)
	var/counter=length(phrase)
	var/newphrase=""
	var/newletter=""
	while(counter>=1)
		newletter=copytext(phrase,(leng-counter)+1,(leng-counter)+2)
		if(rand(1,3)==3)
			if(lowertext(newletter)=="o")
				newletter="u"
			if(lowertext(newletter)=="s")
				newletter="ch"
			if(lowertext(newletter)=="a")
				newletter="ah"
			if(lowertext(newletter)=="u")
				newletter="oo"
			if(lowertext(newletter)=="c")
				newletter="k"
		if(rand(1,20)==20)
			if(newletter==" ")
				newletter="...huuuhhh..."
			if(newletter==".")
				newletter=" *BURP*."
		switch(rand(1,20))
			if(1)
				newletter+="'"
			if(10)
				newletter+="[newletter]"
			if(20)
				newletter+="[newletter][newletter]"
		newphrase+="[newletter]";counter-=1
	return newphrase

/// Makes you talk like you got cult stunned, which is slurring but with some dark messages
/proc/cultslur(n) // Inflicted on victims of a stun talisman
	var/phrase = html_decode(n)
	var/leng = length(phrase)
	var/counter=length(phrase)
	var/newphrase=""
	var/newletter=""
	while(counter>=1)
		newletter=copytext(phrase,(leng-counter)+1,(leng-counter)+2)
		if(rand(1,2)==2)
			if(lowertext(newletter)=="o")
				newletter="u"
			if(lowertext(newletter)=="t")
				newletter="ch"
			if(lowertext(newletter)=="a")
				newletter="ah"
			if(lowertext(newletter)=="u")
				newletter="oo"
			if(lowertext(newletter)=="c")
				newletter=" NAR "
			if(lowertext(newletter)=="s")
				newletter=" SIE "
		if(rand(1,4)==4)
			if(newletter==" ")
				newletter=" no hope... "
			if(newletter=="H")
				newletter=" IT COMES... "

		switch(rand(1,15))
			if(1)
				newletter="'"
			if(2)
				newletter+="agn"
			if(3)
				newletter="fth"
			if(4)
				newletter="nglu"
			if(5)
				newletter="glor"
		newphrase+="[newletter]";counter-=1
	return newphrase

///Adds stuttering to the message passed in
/proc/stutter(n)
	var/te = html_decode(n)
	var/t = ""//placed before the message. Not really sure what it's for.
	n = length(n)//length of the entire word
	var/p = null
	p = 1//1 is the start of any word
	while(p <= n)//while P, which starts at 1 is less or equal to N which is the length.
		var/n_letter = copytext(te, p, p + 1)//copies text from a certain distance. In this case, only one letter at a time.
		if (prob(80) && (ckey(n_letter) in list("b","c","d","f","g","h","j","k","l","m","n","p","q","r","s","t","v","w","x","y","z")))
			if (prob(10))
				n_letter = text("[n_letter]-[n_letter]-[n_letter]-[n_letter]")//replaces the current letter with this instead.
			else
				if (prob(20))
					n_letter = text("[n_letter]-[n_letter]-[n_letter]")
				else
					if (prob(5))
						n_letter = null
					else
						n_letter = text("[n_letter]-[n_letter]")
		t = text("[t][n_letter]")//since the above is ran through for each letter, the text just adds up back to the original word.
		p++//for each letter p is increased to find where the next letter will be.
	return copytext(sanitize(t),1,MAX_MESSAGE_LEN)

///Convert a message to derpy speak
/proc/derpspeech(message, stuttering)
	message = replacetext(message, " am ", " ")
	message = replacetext(message, " is ", " ")
	message = replacetext(message, " are ", " ")
	message = replacetext(message, "you", "u")
	message = replacetext(message, "help", "halp")
	message = replacetext(message, "grief", "grife")
	message = replacetext(message, "space", "spess")
	message = replacetext(message, "carp", "crap")
	message = replacetext(message, "reason", "raisin")
	if(prob(50))
		message = uppertext(message)
		message += "[stutter(pick("!", "!!", "!!!"))]"
	if(!stuttering && prob(15))
		message = stutter(message)
	return message

/**
  * Turn text into complete gibberish!
  *
  * text is the inputted message, replace_characters will cause original letters to be replaced and chance are the odds that a character gets modified.
  */
/proc/Gibberish(text, replace_characters = FALSE, chance = 50)
	. = ""
	for(var/i in 1 to length(text))
		var/letter = text[i]
		if(prob(chance))
			if(replace_characters)
				letter = ""
			for(var/j in 1 to rand(0, 2))
				letter += pick("#","@","*","&","%","$","/", "<", ">", ";","*","*","*","*","*","*","*")
		. += letter


/**
  * Convert a message into leet non gaijin speak
  *
  * The difference with stutter is that this proc can stutter more than 1 letter
  *
  * The issue here is that anything that does not have a space is treated as one word (in many instances). For instance, "LOOKING," is a word, including the comma.
  *
  * It's fairly easy to fix if dealing with single letters but not so much with compounds of letters./N
  */
/proc/ninjaspeak(n) //NINJACODE
	var/te = html_decode(n)
	var/t = ""
	n = length(n)
	var/p = 1
	while(p <= n)
		var/n_letter
		var/n_mod = rand(1,4)
		if(p+n_mod>n+1)
			n_letter = copytext(te, p, n+1)
		else
			n_letter = copytext(te, p, p+n_mod)
		if (prob(50))
			if (prob(30))
				n_letter = text("[n_letter]-[n_letter]-[n_letter]")
			else
				n_letter = text("[n_letter]-[n_letter]")
		else
			n_letter = text("[n_letter]")
		t = text("[t][n_letter]")
		p=p+n_mod
	return copytext(sanitize(t),1,MAX_MESSAGE_LEN)

///Shake the camera of the person viewing the mob SO REAL!
/proc/shake_camera(mob/M, duration, strength=1)
	if(!M || !M.client || duration < 1)
		return
	var/client/C = M.client
	var/oldx = C.pixel_x
	var/oldy = C.pixel_y
	var/max = strength*world.icon_size
	var/min = -(strength*world.icon_size)

	for(var/i in 0 to duration-1)
		if (i == 0)
			animate(C, pixel_x=rand(min,max), pixel_y=rand(min,max), time=1)
		else
			animate(pixel_x=rand(min,max), pixel_y=rand(min,max), time=1)
	animate(pixel_x=oldx, pixel_y=oldy, time=1)


///Find if the message has the real name of any user mob in the mob_list
/proc/findname(msg)
	if(!istext(msg))
		msg = "[msg]"
	for(var/i in GLOB.mob_list)
		var/mob/M = i
		if(M.real_name == msg)
			return M
	return 0

///Find the first name of a mob from the real name with regex
/mob/proc/first_name()
	var/static/regex/firstname = new("^\[^\\s-\]+") //First word before whitespace or "-"
	firstname.Find(real_name)
	return firstname.match


/**
  * change a mob's act-intent.
  *
  * Input the intent as a string such as "help" or use "right"/"left
  */
/mob/verb/a_intent_change(input as text)
	set name = "a-intent"
	set hidden = 1

	if(!possible_a_intents || !possible_a_intents.len)
		return

	if(input in possible_a_intents)
		a_intent = input
	else
		var/current_intent = possible_a_intents.Find(a_intent)

		if(!current_intent)
			// Failsafe. Just in case some badmin was playing with VV.
			current_intent = 1

		if(input == INTENT_HOTKEY_RIGHT)
			current_intent += 1
		if(input == INTENT_HOTKEY_LEFT)
			current_intent -= 1

		// Handle looping
		if(current_intent < 1)
			current_intent = possible_a_intents.len
		if(current_intent > possible_a_intents.len)
			current_intent = 1

		a_intent = possible_a_intents[current_intent]

	if(hud_used && hud_used.action_intent)
		hud_used.action_intent.icon_state = "[a_intent]"

///Checks if passed through item is blind
/proc/is_blind(A)
	if(ismob(A))
		var/mob/B = A
		return B.eye_blind
	return FALSE

///Is the mob hallucinating?
/mob/proc/hallucinating()
	return FALSE


// moved out of admins.dm because things other than admin procs were calling this.
/**
  * Is this mob special to the gamemode?
  *
  * returns 1 for special characters and 2 for heroes of gamemode
  *
  */
/proc/is_special_character(mob/M)
	if(!SSticker.HasRoundStarted())
		return FALSE
	if(!istype(M))
		return FALSE
	if(issilicon(M))
		if(iscyborg(M)) //For cyborgs, returns 1 if the cyborg has a law 0 and special_role. Returns 0 if the borg is merely slaved to an AI traitor.
			return FALSE
		else if(isAI(M))
			var/mob/living/silicon/ai/A = M
			if(A.laws && A.laws.zeroth && A.mind && A.mind.special_role)
				return TRUE
		return FALSE
	if(M.mind && M.mind.special_role)//If they have a mind and special role, they are some type of traitor or antagonist.
		switch(SSticker.mode.config_tag)
			if("revolution")
				if(is_revolutionary(M))
					return 2
			if("cult")
				if(M.mind in SSticker.mode.cult)
					return 2
			if("nuclear")
				if(M.mind.has_antag_datum(/datum/antagonist/nukeop,TRUE))
					return 2
			if("changeling")
				if(M.mind.has_antag_datum(/datum/antagonist/changeling,TRUE))
					return 2
			if("wizard")
				if(iswizard(M))
					return 2
			if("apprentice")
				if(M.mind in SSticker.mode.apprentices)
					return 2
			if("monkey")
				if(isliving(M))
					var/mob/living/L = M
					if(L.diseases && (locate(/datum/disease/transformation/jungle_fever) in L.diseases))
						return 2
		return TRUE
	if(M.mind && LAZYLEN(M.mind.antag_datums)) //they have an antag datum!
		return TRUE
	return FALSE


/mob/proc/reagent_check(datum/reagent/R) // utilized in the species code
	return 1


/**
  * Fancy notifications for ghosts
  *
  * The kitchen sink of notification procs
  *
  * Arguments:
  * * message
  * * ghost_sound sound to play
  * * enter_link Href link to enter the ghost role being notified for
  * * source The source of the notification
  * * alert_overlay The alert overlay to show in the alert message
  * * action What action to take upon the ghost interacting with the notification, defaults to NOTIFY_JUMP
  * * flashwindow Flash the byond client window
  * * ignore_key  Ignore keys if they're in the GLOB.poll_ignore list
  * * header The header of the notifiaction
  * * notify_suiciders If it should notify suiciders (who do not qualify for many ghost roles)
  * * notify_volume How loud the sound should be to spook the user
  */
/proc/notify_ghosts(message, ghost_sound = null, enter_link = null, atom/source = null, mutable_appearance/alert_overlay = null, action = NOTIFY_JUMP, flashwindow = TRUE, ignore_mapload = TRUE, ignore_key, header = null, notify_suiciders = TRUE, notify_volume = 100) //Easy notification of ghosts.
	if(ignore_mapload && SSatoms.initialized != INITIALIZATION_INNEW_REGULAR)	//don't notify for objects created during a map load
		return
	for(var/mob/dead/observer/O in GLOB.player_list)
		if(!notify_suiciders && (O in GLOB.suicided_mob_list))
			continue
		if (ignore_key && (O.ckey in GLOB.poll_ignore[ignore_key]))
			continue
		var/orbit_link
		if (source && action == NOTIFY_ORBIT)
			orbit_link = " <a href='?src=[REF(O)];follow=[REF(source)]'>(Orbit)</a>"
		to_chat(O, "<span class='ghostalert'>[message][(enter_link) ? " [enter_link]" : ""][orbit_link]</span>")
		if(ghost_sound)
			SEND_SOUND(O, sound(ghost_sound, volume = notify_volume))
		if(flashwindow)
			window_flash(O.client)
		if(source)
			var/obj/screen/alert/notify_action/A = O.throw_alert("[REF(source)]_notify_action", /obj/screen/alert/notify_action)
			if(A)
				if(O.client.prefs && O.client.prefs.UI_style)
					A.icon = ui_style2icon(O.client.prefs.UI_style)
				if (header)
					A.name = header
				A.desc = message
				A.action = action
				A.target = source
				if(!alert_overlay)
					alert_overlay = new(source)
				alert_overlay.layer = FLOAT_LAYER
				alert_overlay.plane = FLOAT_PLANE
				A.add_overlay(alert_overlay)

/**
  * Heal a robotic body part on a mob
  */
/proc/item_heal_robotic(mob/living/carbon/human/H, mob/user, brute_heal, burn_heal)
	var/obj/item/bodypart/affecting = H.get_bodypart(check_zone(user.zone_selected))
	if(affecting && affecting.status == BODYPART_ROBOTIC)
		var/dam //changes repair text based on how much brute/burn was supplied
		if(brute_heal > burn_heal)
			dam = 1
		else
			dam = 0
		if((brute_heal > 0 && affecting.brute_dam > 0) || (burn_heal > 0 && affecting.burn_dam > 0))
			if(affecting.heal_damage(brute_heal, burn_heal, 0, BODYPART_ROBOTIC))
				H.update_damage_overlays()
			user.visible_message("<span class='notice'>[user] has fixed some of the [dam ? "dents on" : "burnt wires in"] [H]'s [affecting.name].</span>", \
			"<span class='notice'>You fix some of the [dam ? "dents on" : "burnt wires in"] [H == user ? "your" : "[H]'s"] [affecting.name].</span>")
			return 1 //successful heal
		else
			to_chat(user, "<span class='warning'>[affecting] is already in good condition!</span>")

///Is the passed in mob an admin ghost
/proc/IsAdminGhost(var/mob/user)
	if(!user)		//Are they a mob? Auto interface updates call this with a null src
		return
	if(!user.client) // Do they have a client?
		return
	if(!isobserver(user)) // Are they a ghost?
		return
	if(!check_rights_for(user.client, R_ADMIN)) // Are they allowed?
		return
	if(!user.client.AI_Interact) // Do they have it enabled?
		return
	return TRUE

/**
  * Offer control of the passed in mob to dead player
  *
  * Automatic logging and uses pollCandidatesForMob, how convenient
  */
/proc/offer_control(mob/M)
	to_chat(M, "Control of your mob has been offered to dead players.")
	if(usr)
		log_admin("[key_name(usr)] has offered control of ([key_name(M)]) to ghosts.")
		message_admins("[key_name_admin(usr)] has offered control of ([ADMIN_LOOKUPFLW(M)]) to ghosts")
	var/poll_message = "Do you want to play as [M.real_name]?"
	if(M.mind && M.mind.assigned_role)
		poll_message = "[poll_message] Job:[M.mind.assigned_role]."
	if(M.mind && M.mind.special_role)
		poll_message = "[poll_message] Status:[M.mind.special_role]."
	else if(M.mind)
		var/datum/antagonist/A = M.mind.has_antag_datum(/datum/antagonist/)
		if(A)
			poll_message = "[poll_message] Status:[A.name]."
	var/list/mob/dead/observer/candidates = pollCandidatesForMob(poll_message, ROLE_PAI, null, FALSE, 100, M)

	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		to_chat(M, "Your mob has been taken over by a ghost!")
		message_admins("[key_name_admin(C)] has taken control of ([ADMIN_LOOKUPFLW(M)])")
		M.ghostize(0)
		M.key = C.key
		return TRUE
	else
		to_chat(M, "There were no ghosts willing to take control.")
		message_admins("No ghosts were willing to take control of [ADMIN_LOOKUPFLW(M)])")
		return FALSE

///Is the mob a flying mob
/mob/proc/is_flying()
	return (movement_type & FLYING)

///Is the mob a floating mob
/mob/proc/is_floating()
	return (movement_type & FLOATING)


///Clicks a random nearby mob with the source from this mob
/mob/proc/click_random_mob()
	var/list/nearby_mobs = list()
	for(var/mob/living/L in range(1, src))
		if(L!=src)
			nearby_mobs |= L
	if(nearby_mobs.len)
		var/mob/living/T = pick(nearby_mobs)
		ClickOn(T)

/// Logs a message in a mob's individual log, and in the global logs as well if log_globally is true
/mob/log_message(message, message_type, color=null, log_globally = TRUE)
	if(!LAZYLEN(message))
		stack_trace("Empty message")
		return

	// Cannot use the list as a map if the key is a number, so we stringify it (thank you BYOND)
	var/smessage_type = num2text(message_type)

	if(client)
		if(!islist(client.player_details.logging[smessage_type]))
			client.player_details.logging[smessage_type] = list()

	if(!islist(logging[smessage_type]))
		logging[smessage_type] = list()

	var/colored_message = message
	if(color)
		if(color[1] == "#")
			colored_message = "<font color=[color]>[message]</font>"
		else
			colored_message = "<font color='[color]'>[message]</font>"

	var/list/timestamped_message = list("[LAZYLEN(logging[smessage_type]) + 1]\[[time_stamp()]\] [key_name(src)] [loc_name(src)]" = colored_message)

	logging[smessage_type] += timestamped_message

	if(client)
		client.player_details.logging[smessage_type] += timestamped_message

	..()

///Can the mob hear
/mob/proc/can_hear()
	. = TRUE

/**
  * Examine text for traits shared by multiple types.
  *
  * I wish examine was less copypasted. (oranges say, be the change you want to see buddy)
  */
/mob/proc/common_trait_examine()
	if(HAS_TRAIT(src, TRAIT_DISSECTED))
		var/dissectionmsg = ""
		if(HAS_TRAIT_FROM(src, TRAIT_DISSECTED,"Extraterrestrial Dissection"))
			dissectionmsg = " via Extraterrestrial Dissection. It is no longer worth experimenting on"
		else if(HAS_TRAIT_FROM(src, TRAIT_DISSECTED,"Experimental Dissection"))
			dissectionmsg = " via Experimental Dissection"
		else if(HAS_TRAIT_FROM(src, TRAIT_DISSECTED,"Thorough Dissection"))
			dissectionmsg = " via Thorough Dissection"
		. += "<span class='notice'>This body has been dissected and analyzed[dissectionmsg].</span><br>"

/**
  * Get the list of keywords for policy config
  *
  * This gets the type, mind assigned roles and antag datums as a list, these are later used
  * to send the user relevant headadmin policy config
  */
/mob/proc/get_policy_keywords()
	. = list()
	. += "[type]"
	if(mind)
		. += mind.assigned_role
		. += mind.special_role //In case there's something special leftover, try to avoid
		for(var/datum/antagonist/A in mind.antag_datums)
			. += "[A.type]"

///Can the mob see reagents inside of containers?
/mob/proc/can_see_reagents()
	return stat == DEAD || has_unlimited_silicon_privilege //Dead guys and silicons can always see reagents
