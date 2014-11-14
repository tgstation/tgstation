/mob/living/captive_brain
	name = "host brain"
	real_name = "host brain"
	universal_understand=1

/mob/living/captive_brain/say(var/message)

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			src << "\red You cannot speak in IC (muted)."
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if(istype(src.loc,/mob/living/simple_animal/borer))
		var/mob/living/simple_animal/borer/B = src.loc
		src << "You whisper silently, \"[message]\""
		B.host << "The captive mind of [src] whispers, \"[message]\""

		log_say("THOUGHTSPEECH: [key_name(src)] -> [key_name(B)]: [message]")

		for(var/mob/M in player_list)
			if(istype(M, /mob/new_player))
				continue
			if(istype(M,/mob/dead/observer)  && (M.client && M.client.prefs.toggles & CHAT_GHOSTEARS))
				var/controls = "<a href='byond://?src=\ref[M];follow2=\ref[M];follow=\ref[src]'>Follow</a>"
				if(M.client.holder)
					controls+= " | <A HREF='?_src_=holder;adminmoreinfo=\ref[src]'>?</A>"
				var/rendered="<span class='thoughtspeech'>Thought-speech, <b>[src.name]</b> ([controls]) -> <b>[B.truename]:</b> [message]</span>"
				M.show_message(rendered, 2) //Takes into account blindness and such.

/mob/living/captive_brain/emote(var/message)
	return

var/global/list/borer_attached_verbs = list(
	/mob/living/simple_animal/borer/proc/bond_brain,
	/mob/living/simple_animal/borer/proc/borer_speak,
	/mob/living/simple_animal/borer/proc/kill_host,
	/mob/living/simple_animal/borer/proc/damage_brain,
	/mob/living/simple_animal/borer/proc/secrete_chemicals,
	/mob/living/simple_animal/borer/proc/abandon_host,
)
var/global/list/borer_detached_verbs = list(
	/mob/living/simple_animal/borer/proc/infest,
	/mob/living/simple_animal/borer/proc/ventcrawl,
	/mob/living/simple_animal/borer/proc/hide,
)

/datum/borer_chem
	var/name = ""
	var/cost = 1 // Per unit delivered.
	var/dose_size = 15

/datum/borer_chem/bicaridine
	name = "bicaridine"

/datum/borer_chem/tramadol
	name = "tramadol"

/datum/borer_chem/alkysine
	name = "alkysine"
	cost = 0

/datum/borer_chem/hyperzine
	name = "hyperzine"

var/global/borer_chem_types = typesof(/datum/borer_chem) - /datum/borer_chem

/mob/living/simple_animal/borer
	name = "cortical borer"
	real_name = "cortical borer"
	desc = "A small, quivering sluglike creature."
	speak_emote = list("chirrups")
	emote_hear = list("chirrups")
	response_help  = "pokes the"
	response_disarm = "prods the"
	response_harm   = "stomps on the"
	icon_state = "brainslug"
	icon_living = "brainslug"
	icon_dead = "brainslug_dead"
	speed = 5
	small = 1
	density = 0
	a_intent = "hurt"
	stop_automated_movement = 1
	status_flags = CANPUSH
	attacktext = "nips"
	friendly = "prods"
	wander = 0
	pass_flags = PASSTABLE

	universal_understand=1

	var/chemicals = 10                      // Chemicals used for reproduction and spitting neurotoxin.
	var/mob/living/carbon/human/host        // Human host for the brain worm.
	var/truename                            // Name used for brainworm-speak.
	var/mob/living/captive_brain/host_brain // Used for swapping control of the body back and forth.
	var/controlling                         // Used in human death check.
	var/list/avail_chems=list()
	var/numChildren=0

/mob/living/simple_animal/borer/New(var/loc,var/by_gamemode=0)
	..(loc)
	truename = "[pick("Primary","Secondary","Tertiary","Quaternary")] [rand(1000,9999)]"
	host_brain = new/mob/living/captive_brain(src)

	if(name == initial(name)) // Easier reporting of griff.
		name = "[name] ([rand(1, 1000)])"
		real_name = name

	// Admin spawn.  Request a player.
	if(!by_gamemode)
		var/mob/dead/observer/O = request_player()
		if(!O)
			message_admins("[src.name] self-deleting due to lack of appropriate ghosts.")
			del(src)
		transfer_personality(O.client)
	update_verbs(0)

	for(var/chemtype in borer_chem_types)
		var/datum/borer_chem/C = new chemtype()
		avail_chems[C.name]=C
		//testing("Added [C.name] to borer.")

/mob/living/simple_animal/borer/Life()
	..()
	if(host)
		if(!stat && !host.stat)
			if(chemicals < 250)
				chemicals++
			if(controlling)
				if(prob(5))
					host.adjustBrainLoss(rand(1,2))

				if(prob(host.brainloss/20))
					host.say("*[pick(list("blink","blink_r","choke","aflap","drool","twitch","twitch_s","gasp"))]")

/mob/living/simple_animal/borer/proc/update_verbs(var/attached)
	if(attached)
		verbs += borer_attached_verbs
		verbs -= borer_detached_verbs
	else
		verbs -= borer_attached_verbs
		verbs += borer_detached_verbs

/mob/living/simple_animal/borer/player_panel_controls(var/mob/user)
	var/html="<h2>[src] Controls</h2>"
	if(host)
		html +="<b>Host:</b> [host] (<A HREF='?_src_=holder;adminmoreinfo=\ref[host]'>?</A> | <a href='?_src_=vars;mob_player_panel=\ref[host]'>PP</a>)"
	else
		html += "<em>No host</em>"
	html += "<ul>"
	if(user.check_rights(R_ADMIN))
		html += "<li><a href=\"?src=\ref[src]&act=add_chem\">Give Chem</a></li>" // PARTY SLUG
		html += "<li><a href=\"?src=\ref[src]&act=detach\">Detach</a></li>"
		html += "<li><a href=\"?src=\ref[src]&act=verbs\">Resend Verbs</a></li>"
		if(host)
			html += "<li><a href=\"?src=\ref[src]&act=release\">Release Control</a></li>"
	return html + "</ul>"

/mob/living/simple_animal/borer/Topic(href, href_list)
	if(!usr.check_rights(R_ADMIN))
		usr << "<span class='danger'>Hell no.</span>"
		return

	switch(href_list["act"])
		if("detach")
			src << "<span class='danger'>You feel dazed, and then appear outside of your host!</span>"
			if(host)
				host << "<span class='info'>You no longer feel the presence in your mind!</span>"
			detach()
		if("release")
			if(host)
				host.do_release_control()
		if("verbs")
			update_verbs(!isnull(host))
		if("add_chem")
			var/chemID = input("Chem name (ex: creatine):","Chemicals") as text|null
			if(isnull(chemID))
				return
			var/datum/borer_chem/C = new /datum/borer_chem()
			C.name=chemID
			C.cost=0
			avail_chems[C.name]=C
			usr << "ADDED!"
			src << "<span class='info'>You learned how to secrete [C.name]!</span>"


/mob/living/simple_animal/borer/say(var/message)

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	message = capitalize(message)

	if(!message)
		return

	if (stat == 2)
		return say_dead(message)

	if (stat)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			src << "\red You cannot speak in IC (muted)."
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if (copytext(message, 1, 2) == "*")
		return emote(copytext(message, 2))

	if (copytext(message, 1, 2) == ";") //Brain borer hivemind.
		return borer_speak(message)

	if(!host)
		src << "You have no host to speak to."
		return //No host, no audible speech.

	src << "You drop words into [host]'s mind: \"[message]\""
	host << "Your own thoughts speak: \"[message]\""

	log_say("THOUGHTSPEECH: [truename] ([key_name(src)]) -> [host] ([key_name(host)]): [message]")

	for(var/mob/M in player_list)
		if(istype(M, /mob/new_player))
			continue
		if(istype(M,/mob/dead/observer)  && (M.client && M.client.prefs.toggles & CHAT_GHOSTEARS))
			var/controls = "<a href='byond://?src=\ref[M];follow2=\ref[M];follow=\ref[src]'>Follow</a>"
			if(M.client.holder)
				controls+= " | <A HREF='?_src_=holder;adminmoreinfo=\ref[src]'>?</A>"
			var/rendered="<span class='thoughtspeech'>Thought-speech, <b>[truename]</b> ([controls]) -> <b>[host]:</b> [message]</span>"
			M.show_message(rendered, 2) //Takes into account blindness and such.

	/*
	for(var/mob/M in mob_list)
		if(M.mind && (istype(M, /mob/dead/observer)))
			M << "<i>Thought-speech, <b>[truename]</b> -> <b>[host]:</b> [copytext(message, 2)]</i>"
	*/

/mob/living/simple_animal/borer/Stat()
	..()
	statpanel("Status")

	if(emergency_shuttle)
		if(emergency_shuttle.online && emergency_shuttle.location < 2)
			var/timeleft = emergency_shuttle.timeleft()
			if (timeleft)
				stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

	if (client.statpanel == "Status")
		stat("Chemicals", chemicals)

// VERBS!

/mob/living/simple_animal/borer/proc/borer_speak(var/message)
	if(!message)
		return

	message = copytext(message,2)
	log_say("CORTICAL: [key_name(src)]: [message]")

	for(var/mob/M in mob_list)
		if(istype(M, /mob/new_player))
			continue

		if( (istype(M,/mob/dead/observer) && M.client && !(M.client.prefs.toggles & CHAT_GHOSTEARS)) \
			|| isborer(M))
			var/controls = ""
			if(isobserver(M))
				controls = " (<a href='byond://?src=\ref[M];follow2=\ref[M];follow=\ref[src]'>Follow</a>"
				if(M.client.holder)
					controls+= " | <A HREF='?_src_=holder;adminmoreinfo=\ref[src]'>?</A>"
				controls += ") in [host]"

			M << "<span class='cortical'>Cortical link, <b>[truename]</b>[controls]: [message]</span>"

/mob/living/simple_animal/borer/proc/bond_brain()
	set category = "Alien"
	set name = "Assume Control"
	set desc = "Fully connect to the brain of your host."

	if(!host)
		src << "You are not inside a host body."
		return

	if(src.stat)
		src << "You cannot do that in your current state."
		return

	if(host.stat==DEAD)
		src << "You cannot do that in your host's current state."
		return

	src << "You begin delicately adjusting your connection to the host brain..."

	spawn(300+(host.brainloss*5))

		if(!host || !src || controlling)
			return
		else
			do_bonding(rptext=1)

/mob/living/simple_animal/borer/proc/do_bonding(var/rptext=0)
	if(!host || host.stat==DEAD || !src || controlling)
		return

	src << "\red <B>You plunge your probosci deep into the cortex of the host brain, interfacing directly with their nervous system.</B>"
	host << "\red <B>You feel a strange shifting sensation behind your eyes as an alien consciousness displaces yours.</B>"

	host_brain.ckey = host.ckey
	host.ckey = src.ckey
	controlling = 1

	host.verbs += /mob/living/carbon/proc/release_control
	host.verbs += /mob/living/carbon/proc/punish_host
	host.verbs += /mob/living/carbon/proc/spawn_larvae

/**
 * Kill switch for shit hosts.
 */
/mob/living/simple_animal/borer/proc/kill_host()
	set category = "Alien"
	set name = "Kill Host"
	set desc = "Give the host massive brain damage, killing them nearly instantly."

	if(!host)
		src << "You are not inside a host body."
		return

	if(stat)
		src << "You cannot secrete chemicals in your current state."
		return

	if(host.stat==DEAD)
		src << "You cannot do that in your host's current state."
		return

	var/reason = sanitize(input(usr,"Please enter a brief reason for killing the host, or press cancel.\n\nThis will be logged, and presented to the host.","Oh snap") as null|text, MAX_MESSAGE_LEN)
	if(isnull(reason) || reason=="")
		return

	src << "<span class='danger'>You thrash your probosci around the host's brain, triggering massive brain damage and stopping your host's heart.</span>"
	host << "<span class='sinister'>You get a splitting headache, and then, as blackness descends upon you, you hear: [reason]</span>"

	spawn(10)
		if(!host || !src || stat)
			return

		host.adjustBrainLoss(100)
		if(host.stat != DEAD)
			host.death(0)
			host.attack_log += "\[[time_stamp()]\]<font color='red'>Killed by an unhappy borer: [key_name(src)] Reason: [reason]</font>"

			message_admins("Borer [key_name_admin(src)] killed [key_name_admin(host)] for reason: [reason]")
		detach()

/mob/living/simple_animal/borer/proc/damage_brain()
	set category = "Alien"
	set name = "Retard Host"
	set desc = "Give the host a bit of brain damage.  Can be healed with alkysine."

	if(!host)
		src << "You are not inside a host body."
		return

	if(stat)
		src << "You cannot secrete chemicals in your current state."
		return

	if(host.stat==DEAD)
		src << "You cannot do that in your host's current state."
		return

	src << "<span class='danger'>You twitch your probosci.</span>"
	host << "<span class='sinister'>You feel something twitch, and get a headache.</span>"

	host.adjustBrainLoss(15)


/mob/living/simple_animal/borer/proc/secrete_chemicals()
	set category = "Alien"
	set name = "Secrete Chemicals"
	set desc = "Push some chemicals into your host's bloodstream."

	if(!host)
		src << "<span class='warning'>You are not inside a host body.</span>"
		return

	if(stat)
		src << "<span class='warning'>You cannot secrete chemicals in your current state.</span>"
		return

	if(controlling)
		src << "<span class='warning'>You're too busy controlling your host.</span>"
		return

	if(host.stat==DEAD)
		src << "<span class='warning'>You cannot do that in your host's current state.</span>"
		return

	var/chemID = input("Select a chemical to secrete.", "Chemicals") in avail_chems|null
	if(!chemID)
		return

	var/datum/borer_chem/chem = avail_chems[chemID]

	var/max_amount = 50
	if(chem.cost>0)
		max_amount = round(chemicals / chem.cost)

	if(max_amount==0)
		src << "<span class='warning'>You don't have enough energy to even synthesize one unit!</span>"
		return

	var/units = input("Enter dosage in units.\n\nMax: [max_amount]\nCost: [chem.cost]/unit","Chemicals") as num

	units = round(units)

	if(units < 1)
		src << "<span class='warning'>You cannot synthesize this little.</span>"
		return

	if(chemicals < chem.cost*units)
		src << "<span class='warning'>You don't have enough energy to synthesize this much!</span>"
		return


	if(!host || controlling || !src || stat) //Sanity check.
		return

	src << "<span class='info'>You squirt a measure of [chem.name] from your reservoirs into [host]'s bloodstream.</span>"
	host.reagents.add_reagent(chem.name, units)
	chemicals -= chem.cost*units

/mob/living/simple_animal/borer/proc/abandon_host()
	set category = "Alien"
	set name = "Abandon Host"
	set desc = "Slither out of your host."

	if(!host)
		src << "<span class='warning'>You are not inside a host body.</span>"
		return

	if(stat)
		src << "<span class='warning'>You cannot leave your host in your current state.</span>"
		return

	if(!src)
		return

	src << "<span class='info'>You begin disconnecting from [host]'s synapses and prodding at their internal ear canal.</span>"

	spawn(200)

		if(!host || !src) return

		if(src.stat)
			src << "<span class='warning'>You cannot abandon [host] in your current state.</span>"
			return

		src << "<span class='info'>You wiggle out of [host]'s ear and plop to the ground.</span>"

		detach()

// Try to reset everything, also while handling invalid host/host_brain states.
mob/living/simple_animal/borer/proc/detach()
	if(host)
		if(istype(host,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = host
			var/datum/organ/external/head = H.get_organ("head")
			head.implants -= src

	src.loc = get_turf(src)
	controlling = 0

	reset_view(null)
	machine = null

	if(host)
		host.reset_view(null)
		host.machine = null

		host.verbs -= /mob/living/carbon/proc/release_control
		host.verbs -= /mob/living/carbon/proc/punish_host
		host.verbs -= /mob/living/carbon/proc/spawn_larvae

	if(host_brain && host_brain.ckey)
		src.ckey = host.ckey
		host.ckey = host_brain.ckey
		host_brain.ckey = null
		host_brain.name = "host brain"
		host_brain.real_name = "host brain"

	host = null
	update_verbs(0)

/mob/living/simple_animal/borer/proc/infest()
	set category = "Alien"
	set name = "Infest"
	set desc = "Infest a suitable humanoid host."

	if(host)
		src << "You are already within a host."
		return

	if(stat)
		src << "You cannot infest a target in your current state."
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(1,src))
		if(C.stat != 2 && src.Adjacent(C))
			choices += C

	var/mob/living/carbon/M = input(src,"Who do you wish to infest?") in null|choices

	if(!M || !src) return

	if(!(src.Adjacent(M))) return

	if(M.has_brain_worms())
		src << "You cannot infest someone who is already infested!"
		return

	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		if(H.check_head_coverage(HIDEEARS))
			src << "You cannot get through that host's protective gear."
			return

	src << "You slither up [M] and begin probing at their ear canal..."

	if(!do_after(src,50))
		src << "As [M] moves away, you are dislodged and fall to the ground."
		return

	if(!M || !src) return

	if(src.stat)
		src << "You cannot infest a target in your current state."
		return

	if(M.stat == 2)
		src << "That is not an appropriate target."
		return

	if(M in view(1, src))
		src << "You wiggle into [M]'s ear."
		src.perform_infestation(M)

		return
	else
		src << "They are no longer in range!"
		return

/mob/living/simple_animal/borer/proc/perform_infestation(var/mob/living/carbon/M)
	if(!M || !istype(M))
		error("[src]: Unable to perform_infestation on [M]!")
		return 0
	src.host = M
	src.loc = M

	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/head = H.get_organ("head")
		head.implants += src

	host_brain.name = M.name
	host_brain.real_name = M.real_name

	// /vg/ - Our users are shit, so we start with control over host.
	// TODO:  Config value.
	do_bonding(rptext=1)

	update_verbs(1)

/mob/living/simple_animal/borer/proc/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Alien"
	if(src.canmove)
		handle_ventcrawl()

//copy paste from alien/larva, if that func is updated please update this one alsoghost
/mob/living/simple_animal/borer/proc/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Alien"

	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		src << text("\blue You are now hiding.")
	else
		layer = MOB_LAYER
		src << text("\blue You have stopped hiding.")

//Procs for grabbing players.
mob/living/simple_animal/borer/proc/request_player()
	var/list/candidates=list()
	//testing("Polling for borers.")
	for(var/mob/dead/observer/G in get_active_candidates(ROLE_BORER, poll="HEY KID, YOU WANNA BE A BORER?"))
		if(!G.client)
			//testing("Client of [G] inexistent")
			continue

		//#warning Uncomment me.
		/*if(G.client.holder)
			//testing("Client of [G] is admin.")
			continue*/

		if(jobban_isbanned(G, "Syndicate"))
			//testing("[G] is jobbanned.")
			continue

		candidates += G

	if(!candidates.len)
		//message_admins("Unable to find a mind for [src.name]")
		return 0

	shuffle(candidates)
	for(var/mob/i in candidates)
		if(!i || !i.client) continue //Dont bother removing them from the list since we only grab one wizard
		return i

	return 0

mob/living/simple_animal/borer/proc/transfer_personality(var/client/candidate)

	if(!candidate)
		return

	src.mind = candidate.mob.mind
	src.ckey = candidate.ckey
	if(src.mind)
		src.mind.assigned_role = "Cortical Borer"

		// Tell gamemode about us.
		if(src.mind in ticker.mode.borers)
			ticker.mode.borers.Add(src.mind)

		// Assign objectives
		forge_objectives()

		// tl;dr
		src << "<span class='danger'>You are a Cortical Borer!</span>"
		src << "<span style='info'>You are a small slug-like parasite that attaches to your host's brain and can control every aspect of their lives.  Your only goals are to survive and procreate, so being as low-key as possible is best.</span>"
		src << "<span style='info'>Borers can speak with other borers over the Cortical Link.  To do so, release control and use <code>say \";message\"</code>.  To communicate with your host only, speak normally.</span>"
		src << "<span style='info'><b>Important:</b> While you receive full control at the start, <em>it is asked that you release control at some point so your host has a chance to play.</em>  If they misbehave, you are permitted to kill them.</span>"

		var/obj_count = 1
		for(var/datum/objective/objective in mind.objectives)
			src << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
			obj_count++

mob/living/simple_animal/borer/proc/forge_objectives()
	var/datum/objective/survive/survive_objective = new
	survive_objective.owner = mind
	mind.objectives += survive_objective

	var/datum/objective/multiply/multiply_objective = new
	multiply_objective.owner = mind
	mind.objectives += multiply_objective

