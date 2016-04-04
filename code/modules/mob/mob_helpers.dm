
// see _DEFINES/is_helpers.dm for mob type checks

/proc/isloyal(A) //Checks to see if the person contains a loyalty implant, then checks that the implant is actually inside of them
	for(var/obj/item/weapon/implant/loyalty/L in A)
		if(L && L.implanted)
			return 1
	return 0

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
			if(lowertext(newletter)=="s")
				newletter="ch"
			if(lowertext(newletter)=="a")
				newletter="ah"
			if(lowertext(newletter)=="u")
				newletter="oo"
			if(lowertext(newletter)=="c")
				newletter=" NAR "
			if(lowertext(newletter)=="t")
				newletter=" SIE "
		if(rand(1,4)==4)
			if(newletter==" ")
				newletter=" GLORY "
			if(newletter=="H")
				newletter=" HAIL "

		switch(rand(1,10))
			if(1)
				newletter="'"
			if(2)
				newletter+="agn"
			if(3)
				newletter="fth"
			if(4)
				newletter="nglu"
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
	for(var/mob/M in mob_list)
		if(M.real_name == msg)
			return M
	return 0


/mob/proc/abiotic(full_body = 0)
	if(l_hand && !l_hand.flags&ABSTRACT || r_hand && !r_hand.flags&ABSTRACT)
		return 1
	return 0

//converts intent-strings into numbers and back
/proc/intent_numeric(argument)
	if(istext(argument))
		switch(argument)
			if("help")
				return 0
			if("disarm")
				return 1
			if("grab")
				return 2
			else
				return 3
	else
		switch(argument)
			if(0)
				return "help"
			if(1)
				return "disarm"
			if(2)
				return "grab"
			else
				return "harm"

//change a mob's act-intent. Input the intent as a string such as "help" or use "right"/"left
/mob/verb/a_intent_change(input as text)
	set name = "a-intent"
	set hidden = 1

	if(ishuman(src) || isalienadult(src) || isbrain(src))
		switch(input)
			if("help", "disarm", "grab", "harm")
				a_intent = input
			if("right")
				a_intent = intent_numeric((intent_numeric(a_intent) + 1) % 4)
			if("left")
				a_intent = intent_numeric((intent_numeric(a_intent) + 3) % 4)

		if(hud_used && hud_used.action_intent)
			hud_used.action_intent.icon_state = "[a_intent]"

	else if(isrobot(src) || ismonkey(src) || islarva(src))
		switch(input)
			if("help")
				a_intent = "help"
			if("harm")
				a_intent = "harm"
			if("right","left")
				a_intent = intent_numeric(intent_numeric(a_intent) - 3)

		if(hud_used && hud_used.action_intent)
			hud_used.action_intent.icon_state = "[a_intent]"

/proc/is_blind(A)
	if(ismob(A))
		var/mob/B = A
		return	B.eye_blind
	return 0

/proc/is_special_character(mob/M) // returns 1 for special characters and 2 for heroes of gamemode //moved out of admins.dm because things other than admin procs were calling this.
	if(!ticker || !ticker.mode)
		return 0
	if(!istype(M))
		return 0
	if(issilicon(M))
		if(isrobot(M)) //For cyborgs, returns 1 if the cyborg has a law 0 and special_role. Returns 0 if the borg is merely slaved to an AI traitor.
			var/mob/living/silicon/robot/R = M
			if(R.emagged || R.syndicate) //Count as antags
				return 1
			if(R.mind && R.mind.special_role && R.laws && R.laws.zeroth).
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
		switch(ticker.mode.config_tag)
			if("revolution")
				if((M.mind in ticker.mode.head_revolutionaries) || (M.mind in ticker.mode.revolutionaries))
					return 2
			if("cult")
				if(M.mind in ticker.mode.cult)
					return 2
			if("nuclear")
				if(M.mind in ticker.mode.syndicates)
					return 2
			if("changeling")
				if(M.mind in ticker.mode.changelings)
					return 2
			if("wizard")
				if(M.mind in ticker.mode.wizards)
					return 2
			if("apprentice")
				if(M.mind in ticker.mode.apprentices)
					return 2
			if("monkey")
				if(M.viruses && (locate(/datum/disease/transformation/jungle_fever) in M.viruses))
					return 2
			if("abductor")
				if(M.mind in ticker.mode.abductors)
					return 2
		return 1
	return 0

/proc/get_both_hands(mob/living/carbon/M)
	var/list/hands = list(M.l_hand, M.r_hand)
	return hands

/mob/proc/reagent_check(datum/reagent/R) // utilized in the species code
	return 1

/proc/notify_ghosts(var/message, var/ghost_sound = null, var/enter_link = null, var/atom/source = null, var/image/alert_overlay = null, var/attack_not_jump = 0) //Easy notification of ghosts.
	for(var/mob/dead/observer/O in player_list)
		if(O.client)
			O << "<span class='ghostalert'>[message][(enter_link) ? " [enter_link]" : ""]<span>"
			if(ghost_sound)
				O << sound(ghost_sound)
			if(source)
				var/obj/screen/alert/notify_jump/A = O.throw_alert("\ref[source]_notify_jump", /obj/screen/alert/notify_jump)
				if(A)
					if(O.client.prefs && O.client.prefs.UI_style)
						A.icon = ui_style2icon(O.client.prefs.UI_style)
					A.desc = message
					A.attack_not_jump = attack_not_jump
					A.jump_target = source
					if(!alert_overlay)
						var/old_layer = source.layer
						source.layer = FLOAT_LAYER
						A.overlays += source
						source.layer = old_layer
					else
						alert_overlay.layer = FLOAT_LAYER
						A.overlays += alert_overlay

/proc/item_heal_robotic(mob/living/carbon/human/H, mob/user, brute, burn)
	var/obj/item/organ/limb/affecting = H.get_organ(check_zone(user.zone_selected))

	var/dam //changes repair text based on how much brute/burn was supplied

	if(brute > burn)
		dam = 1
	else
		dam = 0

	if(affecting.status == ORGAN_ROBOTIC)
		if(brute > 0 && affecting.brute_dam > 0 || burn > 0 && affecting.burn_dam > 0)
			affecting.heal_damage(brute,burn,1)
			H.update_damage_overlays(0)
			H.updatehealth()
			user.visible_message("[user] has fixed some of the [dam ? "dents on" : "burnt wires in"] [H]'s [affecting.getDisplayName()].", "<span class='notice'>You fix some of the [dam ? "dents on" : "burnt wires in"] [H]'s [affecting.getDisplayName()].</span>")
			return
		else
			user << "<span class='warning'>[H]'s [affecting.getDisplayName()] is already in good condition!</span>"
			return
	else
		return

/proc/IsAdminGhost(var/mob/user)
	if(!user.client) // Do they have a client?
		return
	if(!isobserver(user)) // Are they a ghost?
		return
	if(!check_rights_for(user.client, R_ADMIN)) // Are they allowed?
		return
	if(!user.client.AI_Interact) // Do they have it enabled?
		return
	return TRUE
