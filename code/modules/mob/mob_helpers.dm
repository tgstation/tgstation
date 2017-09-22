
// see _DEFINES/is_helpers.dm for mob type checks

/mob/proc/isloyal() //Checks to see if the person contains a mindshield implant, then checks that the implant is actually inside of them
	return 0

/mob/living/carbon/isloyal()
	for(var/obj/item/implant/mindshield/L in implants)
		return 1


/proc/check_zone(zone)
	if(!zone)
		return "chest"
	switch(zone)
		if("eyes")
			zone = "head"
		if("mouth")
			zone = "head"
		if("l_hand")
			zone = "l_arm"
		if("r_hand")
			zone = "r_arm"
		if("l_foot")
			zone = "l_leg"
		if("r_foot")
			zone = "r_leg"
		if("groin")
			zone = "chest"
	return zone


/proc/ran_zone(zone, probability = 80)

	zone = check_zone(zone)

	if(prob(probability))
		return zone

	var/t = rand(1, 18) // randomly pick a different zone, or maybe the same one
	switch(t)
		if(1)
			return "head"
		if(2)
			return "chest"
		if(3 to 6)
			return "l_arm"
		if(7 to 10)
			return "r_arm"
		if(11 to 14)
			return "l_leg"
		if(15 to 18)
			return "r_leg"

	return zone

/proc/above_neck(zone)
	var/list/zones = list("head", "mouth", "eyes")
	if(zones.Find(zone))
		return 1
	else
		return 0

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
	var/p = null
	p = 1
	while(p <= n)
		if ((copytext(te, p, p + 1) == " " || prob(pr)))
			t = text("[][]", t, copytext(te, p, p + 1))
		else
			t = text("[]*", t)
		p++
	return sanitize(t)

/proc/slur(n)
	var/phrase = html_decode(n)
	var/leng = lentext(phrase)
	var/counter=lentext(phrase)
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


/proc/cultslur(n) // Inflicted on victims of a stun talisman
	var/phrase = html_decode(n)
	var/leng = lentext(phrase)
	var/counter=lentext(phrase)
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


/proc/Gibberish(t, p)//t is the inputted message, and any value higher than 70 for p will cause letters to be replaced instead of added
	/* Turn text into complete gibberish! */
	var/returntext = ""
	for(var/i = 1, i <= length(t), i++)

		var/letter = copytext(t, i, i+1)
		if(prob(50))
			if(p >= 70)
				letter = ""

			for(var/j = 1, j <= rand(0, 2), j++)
				letter += pick("#","@","*","&","%","$","/", "<", ">", ";","*","*","*","*","*","*","*")

		returntext += letter

	return returntext


/proc/ninjaspeak(n) //NINJACODE
/*
The difference with stutter is that this proc can stutter more than 1 letter
The issue here is that anything that does not have a space is treated as one word (in many instances). For instance, "LOOKING," is a word, including the comma.
It's fairly easy to fix if dealing with single letters but not so much with compounds of letters./N
*/
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


/proc/shake_camera(mob/M, duration, strength=1)
	if(!M || !M.client || duration <= 0)
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



/proc/findname(msg)
	if(!istext(msg))
		msg = "[msg]"
	for(var/mob/M in GLOB.mob_list)
		if(M.real_name == msg)
			return M
	return 0

/mob/proc/first_name()
	var/static/regex/firstname = new("^\[^\\s-\]+") //First word before whitespace or "-"
	firstname.Find(real_name)
	return firstname.match

/mob/proc/abiotic(full_body = 0)
	for(var/obj/item/I in held_items)
		if(!(I.flags_1 & NODROP_1))
			return 1
	return 0

//change a mob's act-intent. Input the intent as a string such as "help" or use "right"/"left
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


/proc/is_blind(A)
	if(ismob(A))
		var/mob/B = A
		return	B.eye_blind
	return 0

/mob/proc/hallucinating()
	return FALSE

/proc/is_special_character(mob/M) // returns 1 for special characters and 2 for heroes of gamemode //moved out of admins.dm because things other than admin procs were calling this.
	if(!SSticker.HasRoundStarted())
		return 0
	if(!istype(M))
		return 0
	if(issilicon(M))
		if(iscyborg(M)) //For cyborgs, returns 1 if the cyborg has a law 0 and special_role. Returns 0 if the borg is merely slaved to an AI traitor.
			var/mob/living/silicon/robot/R = M
			if(R.mind && R.mind.special_role)
				if(R.laws && R.laws.zeroth && R.syndicate)
					if(R.connected_ai)
						if(is_special_character(R.connected_ai) && R.connected_ai.laws && (R.connected_ai.laws.zeroth_borg == R.laws.zeroth || R.connected_ai.laws.zeroth == R.laws.zeroth))
							return 0 //AI is the real traitor here, so the borg itself is not a traitor
						return 1 //Slaved but also a traitor
					return 1 //Unslaved, traitor
		else if(isAI(M))
			var/mob/living/silicon/ai/A = M
			if(A.laws && A.laws.zeroth && A.mind && A.mind.special_role)
				return 1
		return 0
	if(M.mind && M.mind.special_role)//If they have a mind and special role, they are some type of traitor or antagonist.
		switch(SSticker.mode.config_tag)
			if("revolution")
				if((M.mind in SSticker.mode.head_revolutionaries) || (M.mind in SSticker.mode.revolutionaries))
					return 2
			if("cult")
				if(M.mind in SSticker.mode.cult)
					return 2
			if("nuclear")
				if(M.mind in SSticker.mode.syndicates)
					return 2
			if("changeling")
				if(M.mind in SSticker.mode.changelings)
					return 2
			if("wizard")
				if(M.mind in SSticker.mode.wizards)
					return 2
			if("apprentice")
				if(M.mind in SSticker.mode.apprentices)
					return 2
			if("monkey")
				if(M.viruses && (locate(/datum/disease/transformation/jungle_fever) in M.viruses))
					return 2
			if("abductor")
				if(M.mind in SSticker.mode.abductors)
					return 2
		return 1
	return 0

/mob/proc/reagent_check(datum/reagent/R) // utilized in the species code
	return 1

/proc/notify_ghosts(var/message, var/ghost_sound = null, var/enter_link = null, var/atom/source = null, var/mutable_appearance/alert_overlay = null, var/action = NOTIFY_JUMP, flashwindow = TRUE) //Easy notification of ghosts.
	if(SSatoms.initialized != INITIALIZATION_INNEW_REGULAR)	//don't notify for objects created during a map load
		return
	for(var/mob/dead/observer/O in GLOB.player_list)
		if(O.client)
			to_chat(O, "<span class='ghostalert'>[message][(enter_link) ? " [enter_link]" : ""]</span>")
			if(ghost_sound)
				SEND_SOUND(O, sound(ghost_sound))
			if(flashwindow)
				window_flash(O.client)
			if(source)
				var/obj/screen/alert/notify_action/A = O.throw_alert("\ref[source]_notify_action", /obj/screen/alert/notify_action)
				if(A)
					if(O.client.prefs && O.client.prefs.UI_style)
						A.icon = ui_style2icon(O.client.prefs.UI_style)
					A.desc = message
					A.action = action
					A.target = source
					if(!alert_overlay)
						alert_overlay = new(source)
					alert_overlay.layer = FLOAT_LAYER
					alert_overlay.plane = FLOAT_PLANE
					A.add_overlay(alert_overlay)

/proc/item_heal_robotic(mob/living/carbon/human/H, mob/user, brute_heal, burn_heal)
	var/obj/item/bodypart/affecting = H.get_bodypart(check_zone(user.zone_selected))
	if(affecting && affecting.status == BODYPART_ROBOTIC)
		var/dam //changes repair text based on how much brute/burn was supplied
		if(brute_heal > burn_heal)
			dam = 1
		else
			dam = 0
		if((brute_heal > 0 && affecting.brute_dam > 0) || (burn_heal > 0 && affecting.burn_dam > 0))
			if(affecting.heal_damage(brute_heal, burn_heal, 1, 0))
				H.update_damage_overlays()
			user.visible_message("[user] has fixed some of the [dam ? "dents on" : "burnt wires in"] [H]'s [affecting.name].", \
			"<span class='notice'>You fix some of the [dam ? "dents on" : "burnt wires in"] [H]'s [affecting.name].</span>")
			return 1 //successful heal
		else
			to_chat(user, "<span class='warning'>[affecting] is already in good condition!</span>")


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

/proc/offer_control(mob/M)
	to_chat(M, "Control of your mob has been offered to dead players.")
	if(usr)
		log_admin("[key_name(usr)] has offered control of ([key_name(M)]) to ghosts.")
		message_admins("[key_name_admin(usr)] has offered control of ([key_name_admin(M)]) to ghosts")
	var/poll_message = "Do you want to play as [M.real_name]?"
	if(M.mind && M.mind.assigned_role)
		poll_message = "[poll_message] Job:[M.mind.assigned_role]."
	if(M.mind && M.mind.special_role)
		poll_message = "[poll_message] Status:[M.mind.special_role]."
	var/list/mob/dead/observer/candidates = pollCandidatesForMob(poll_message, "pAI", null, FALSE, 100, M)
	var/mob/dead/observer/theghost = null

	if(candidates.len)
		theghost = pick(candidates)
		to_chat(M, "Your mob has been taken over by a ghost!")
		message_admins("[key_name_admin(theghost)] has taken control of ([key_name_admin(M)])")
		M.ghostize(0)
		M.key = theghost.key
		return TRUE
	else
		to_chat(M, "There were no ghosts willing to take control.")
		message_admins("No ghosts were willing to take control of [key_name_admin(M)])")
		return FALSE

/mob/proc/is_flying(mob/M = src)
	if(M.movement_type & FLYING)
		return 1
	else
		return 0

/mob/proc/click_random_mob()
	var/list/nearby_mobs = list()
	for(var/mob/living/L in range(1, src))
		if(L!=src)
			nearby_mobs |= L
	if(nearby_mobs.len)
		var/mob/living/T = pick(nearby_mobs)
		ClickOn(T)

/mob/proc/log_message(message, message_type)
	if(!LAZYLEN(message) || !message_type)
		return

	if(!islist(logging[message_type]))
		logging[message_type] = list()

	var/list/timestamped_message = list("[LAZYLEN(logging[message_type]) + 1]\[[time_stamp()]\] [key_name(src)]" = message)

	logging[message_type] += timestamped_message

/mob/proc/can_hear()
	. = TRUE
