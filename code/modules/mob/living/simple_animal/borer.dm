#define BORER_MODE_DETACHED 0
#define BORER_MODE_SEVERED 1
#define BORER_MODE_ATTACHED_HEAD 2
#define BORER_MODE_ATTACHED_CHEST 3
#define BORER_MODE_ATTACHED_ARM 4
#define BORER_MODE_ATTACHED_LEG 5

var/global/borer_chem_types_head = typesof(/datum/borer_chem/head) - /datum/borer_chem - /datum/borer_chem/head
var/global/borer_chem_types_chest = typesof(/datum/borer_chem/chest) - /datum/borer_chem - /datum/borer_chem/chest
var/global/borer_chem_types_arm = typesof(/datum/borer_chem/arm) - /datum/borer_chem - /datum/borer_chem/arm
var/global/borer_chem_types_leg = typesof(/datum/borer_chem/leg) - /datum/borer_chem - /datum/borer_chem/leg
var/global/borer_unlock_types_head = typesof(/datum/unlockable/borer/head) - /datum/unlockable/borer - /datum/unlockable/borer/head - /datum/unlockable/borer/head/chem_unlock - /datum/unlockable/borer/head/verb_unlock
var/global/borer_unlock_types_chest = typesof(/datum/unlockable/borer/chest) - /datum/unlockable/borer - /datum/unlockable/borer/chest - /datum/unlockable/borer/chest/chem_unlock - /datum/unlockable/borer/chest/verb_unlock
var/global/borer_unlock_types_arm = typesof(/datum/unlockable/borer/arm) - /datum/unlockable/borer - /datum/unlockable/borer/arm - /datum/unlockable/borer/arm/chem_unlock - /datum/unlockable/borer/arm/verb_unlock
var/global/borer_unlock_types_leg = typesof(/datum/unlockable/borer/leg) - /datum/unlockable/borer - /datum/unlockable/borer/leg - /datum/unlockable/borer/leg/chem_unlock - /datum/unlockable/borer/leg/verb_unlock

/mob/living/simple_animal/borer
	name = "borer"
	real_name = "borer"
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

	size = SIZE_SMALL

	min_tox = 0
	max_tox = 0

	density = 0
	a_intent = I_HURT
	stop_automated_movement = 1
	status_flags = CANPUSH
	attacktext = "nips"
	friendly = "prods"
	wander = 0
	pass_flags = PASSTABLE
	canEnterVentWith = "/mob/living/captive_brain=0&/obj/item/verbs/borer=0"
	universal_understand=1

	var/busy = 0 // So we aren't trying to lay many eggs at once.

	var/chemicals = 10                      // Chemicals used for reproduction and spitting neurotoxin.
	var/mob/living/carbon/human/host        // Human host for the brain worm.
	var/hostlimb = null						// Which limb of the host is inhabited by the borer.
	var/truename                            // Name used for brainworm-speak.
	var/mob/living/captive_brain/host_brain // Used for swapping control of the body back and forth.
	var/controlling                         // Used in human death check.
	var/list/avail_chems=list()
	var/list/unlocked_chems_head=list()
	var/list/unlocked_chems_chest=list()
	var/list/unlocked_chems_arm=list()
	var/list/unlocked_chems_leg=list()
	var/list/avail_abilities=list()         // Unlocked powers.
	var/list/attached_verbs_head=list(/obj/item/verbs/borer/attached_head)
	var/list/attached_verbs_chest=list(/obj/item/verbs/borer/attached_chest)
	var/list/attached_verbs_arm=list(/obj/item/verbs/borer/attached_arm)
	var/list/attached_verbs_leg=list(/obj/item/verbs/borer/attached_leg)
	var/list/severed_verbs=list(/obj/item/verbs/borer/severed)
	var/list/detached_verbs=list(/obj/item/verbs/borer/detached)
	var/numChildren=0

	var/datum/research_tree/borer/research
	var/list/verb_holders = list()
	var/list/borer_avail_unlocks_head = list()
	var/list/borer_avail_unlocks_chest = list()
	var/list/borer_avail_unlocks_arm = list()
	var/list/borer_avail_unlocks_leg = list()

	var/channeling = 0 //For abilities that require constant expenditure of chemicals.
	var/channeling_brute_resist = 0
	var/channeling_burn_resist = 0
	var/channeling_speed_increase = 0
	var/channeling_bone_talons = 0
	var/channeling_bone_sword = 0
	var/channeling_bone_shield = 0
	var/channeling_bone_hammer = 0
	var/channeling_bone_cocoon = 0

	var/obj/item/weapon/gun/hookshot/flesh/extend_o_arm = null
	var/extend_o_arm_unlocked = 0

	var/attack_cooldown = 0 //to prevent spamming extend_o_arm attacks at close range

	// Event handles
	var/eh_emote

	var/static/list/name_prefixes = list("Primary","Secondary","Tertiary","Quaternary","Quinary","Senary","Septenary","Octonary","Nonary","Denary")
	var/name_prefix_index = 1

/mob/living/simple_animal/borer/New(var/loc, var/egg_prefix_index = 1)
	..(loc)
	name_prefix_index = min(egg_prefix_index, 10)
	truename = "[name_prefixes[name_prefix_index]] [capitalize(pick(borer_names))]"
	host_brain = new/mob/living/captive_brain(src)

	if(name == initial(name)) // Easier reporting of griff.
		name = "[name] ([rand(1, 1000)])"
		real_name = name

	update_verbs(BORER_MODE_DETACHED)

	research = new (src)

	for(var/ultype in borer_unlock_types_head)
		var/datum/unlockable/borer/head/U = new ultype()
		if(U.id!="")
			borer_avail_unlocks_head.Add(U)
	for(var/ultype in borer_unlock_types_chest)
		var/datum/unlockable/borer/chest/U = new ultype()
		if(U.id!="")
			borer_avail_unlocks_chest.Add(U)
	for(var/ultype in borer_unlock_types_arm)
		var/datum/unlockable/borer/arm/U = new ultype()
		if(U.id!="")
			borer_avail_unlocks_arm.Add(U)
	for(var/ultype in borer_unlock_types_leg)
		var/datum/unlockable/borer/leg/U = new ultype()
		if(U.id!="")
			borer_avail_unlocks_leg.Add(U)

	extend_o_arm = new /obj/item/weapon/gun/hookshot/flesh(src, src)

/mob/living/simple_animal/borer/Login()
	..()
	if(mind)
		RemoveAllFactionIcons(mind)

/mob/living/simple_animal/borer/Life()
	if(timestopped) return 0 //under effects of time magick

	..()
	if(host)
		if(!stat && !host.stat)
			if(health < 20)
				health += 0.5
			if(chemicals < 250 && !channeling)
				chemicals++
			if(controlling)
				if(prob(5))
					host.adjustBrainLoss(rand(1,2))

				if(prob(host.brainloss/20))
					host.say("*[pick(list("blink","blink_r","choke","aflap","drool","twitch","twitch_s","gasp"))]")

/mob/living/simple_animal/borer/proc/update_verbs(var/mode)
	if(verb_holders.len>0)
		for(var/VH in verb_holders)
			qdel(VH)
	verb_holders=list()
	var/list/verbtypes = list()
	avail_chems.len = 0
	switch(mode)
		if(BORER_MODE_DETACHED) // 0
			verbtypes=detached_verbs
		if(BORER_MODE_SEVERED) // 1
			verbtypes=severed_verbs
		if(BORER_MODE_ATTACHED_HEAD) // 2
			verbtypes=attached_verbs_head
			for(var/chemtype in borer_chem_types_head)
				var/datum/borer_chem/C = new chemtype()
				if(!C.unlockable)
					avail_chems[C.name]=C
			avail_chems += unlocked_chems_head
		if(BORER_MODE_ATTACHED_CHEST) // 3
			verbtypes=attached_verbs_chest
			for(var/chemtype in borer_chem_types_chest)
				var/datum/borer_chem/C = new chemtype()
				if(!C.unlockable)
					avail_chems[C.name]=C
			avail_chems += unlocked_chems_chest
		if(BORER_MODE_ATTACHED_ARM) // 4
			verbtypes=attached_verbs_arm
			for(var/chemtype in borer_chem_types_arm)
				var/datum/borer_chem/C = new chemtype()
				if(!C.unlockable)
					avail_chems[C.name]=C
			avail_chems += unlocked_chems_arm
		if(BORER_MODE_ATTACHED_LEG) // 5
			verbtypes=attached_verbs_leg
			for(var/chemtype in borer_chem_types_leg)
				var/datum/borer_chem/C = new chemtype()
				if(!C.unlockable)
					avail_chems[C.name]=C
			avail_chems += unlocked_chems_leg
	for(var/verbtype in verbtypes)
		verb_holders+=new verbtype(src)

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
		to_chat(usr, "<span class='danger'>Hell no.</span>")
		return

	switch(href_list["act"])
		if("detach")
			to_chat(src, "<span class='danger'>You feel dazed, and then appear outside of your host!</span>")
			if(host)
				to_chat(host, "<span class='info'>You no longer feel the presence in your mind!</span>")
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
			to_chat(usr, "ADDED!")
			to_chat(src, "<span class='info'>You learned how to secrete [C.name]!</span>")


/mob/living/simple_animal/borer/say(var/message)
	message = trim(copytext(message, 1, MAX_MESSAGE_LEN))
	message = capitalize(message)

	if(!message)
		return

	if (stat == 2)
		return say_dead(message)

	if (stat)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='warning'>You cannot speak in IC (muted).</span>")
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if (copytext(message, 1, 2) == "*")
		return emote(copytext(message, 2))

	if (copytext(message, 1, 2) == ";") //Brain borer hivemind.
		return borer_speak(copytext(message,2))

	if(!host)
		to_chat(src, "You have no host to speak to.")
		return //No host, no audible speech.

	var/encoded_message = html_encode(message)

	to_chat(src, "You drop words into [host]'s body: <span class='borer2host'>\"[encoded_message]\"</span>")
	if(hostlimb == LIMB_HEAD)
		to_chat(host, "<b>Your mind speaks to you:</b> <span class='borer2host'>\"[encoded_message]\"</span>")
	else
		to_chat(host, "<b>Your [limb_to_name(hostlimb)] speaks to you:</b> <span class='borer2host'>\"[encoded_message]\"</span>")
	var/list/borers_in_host = host.get_brain_worms()
	borers_in_host.Remove(src)
	if(borers_in_host.len)
		for(var/I in borers_in_host)
			to_chat(I, "<b>[truename]</b> speaks from your host's [limb_to_name(hostlimb)]: <span class='borer2host'>\"[encoded_message]\"</span>")

	var/turf/T = get_turf(src)
	log_say("[truename] [key_name(src)] (@[T.x],[T.y],[T.z]) -> [host]([key_name(host)]) Borer->Host Speech: [message]")

	for(var/mob/M in player_list)
		if(istype(M, /mob/new_player))
			continue
		if(istype(M,/mob/dead/observer)  && (M.client && M.client.prefs.toggles & CHAT_GHOSTEARS))
			var/controls = "<a href='byond://?src=\ref[M];follow2=\ref[M];follow=\ref[src]'>Follow</a>"
			if(M.client.holder)
				controls+= " | <A HREF='?_src_=holder;adminmoreinfo=\ref[src]'>?</A>"
			var/rendered="<span class='thoughtspeech'>Thought-speech, <b>[truename]</b> ([controls]) in <b>[host]</b>'s [limb_to_name(hostlimb)]: [encoded_message]</span>"
			M.show_message(rendered, 2) //Takes into account blindness and such.

	/*
	for(var/mob/M in mob_list)
		if(M.mind && (istype(M, /mob/dead/observer)))
			to_chat(M, "<i>Thought-speech, <b>[truename]</b> -> <b>[host]:</b> [copytext(html_encode(message), 2)]</i>")
	*/

/mob/living/simple_animal/borer/Stat()
	..()
	if(statpanel("Status"))
		if(emergency_shuttle)
			if(emergency_shuttle.online && emergency_shuttle.location < 2)
				var/timeleft = emergency_shuttle.timeleft()
				if (timeleft)
					stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

		stat("Health", health)
		stat("Chemicals", chemicals)

/mob/living/simple_animal/borer/earprot()
	if(host)
		return host.earprot()
	else
		return ..()

/mob/living/simple_animal/borer/eyecheck()
	if(host)
		return host.eyecheck()
	else
		return ..()

/mob/living/simple_animal/borer/start_pulling(var/atom/movable/AM)
	to_chat(src, "<span class='warning'>You are too small to pull anything.</span>")

// VERBS!
/mob/living/simple_animal/borer/proc/borer_speak(var/message)
	set category = "Alien"
	set name = "Borer Speak"
	set desc = "Communicate with your bretheren"
	if(!message)
		return

	var/turf/T = get_turf(src)
	log_say("[truename] [key_name(src)] (@[T.x],[T.y],[T.z]) Borer Cortical Hivemind: [message]")

	for(var/mob/M in mob_list)
		if(istype(M, /mob/new_player))
			continue

		if( isborer(M) || (istype(M,/mob/dead/observer) && M.client && M.client.prefs.toggles & CHAT_GHOSTEARS))
			var/controls = ""
			if(isobserver(M))
				controls = " (<a href='byond://?src=\ref[M];follow2=\ref[M];follow=\ref[src]'>Follow</a>"
				if(M.client.holder)
					controls+= " | <A HREF='?_src_=holder;adminmoreinfo=\ref[src]'>?</A>"
				controls += ") in [host]"

			to_chat(M, "<span class='cortical'>Cortical link, <b>[truename]</b>[controls]: [message]</span>")

/mob/living/simple_animal/borer/proc/bond_brain()
	set category = "Alien"
	set name = "Assume Control"
	set desc = "Fully connect to the brain of your host."

	if(!check_can_do())
		return

	if(hostlimb != LIMB_HEAD)
		to_chat(src, "You are not attached to your host's brain.")
		return

	to_chat(src, "You begin delicately adjusting your connection to the host brain...")

	spawn(300+(host.brainloss*5))

		if(!host || !src || controlling)
			return
		else
			do_bonding(rptext=1)

/mob/living/simple_animal/borer/proc/do_bonding(var/rptext=0)
	if(!host || host.stat==DEAD || !src || controlling || research.unlocking)
		return

	to_chat(src, "<span class='danger'>You plunge your probosci deep into the cortex of the host brain, interfacing directly with their nervous system.</span>")
	to_chat(host, "<span class='danger'>You feel a strange shifting sensation behind your eyes as an alien consciousness displaces yours.</span>")

	host_brain.ckey = host.ckey
	host_brain.name = host.real_name
	host.ckey = src.ckey
	controlling = 1

	/* Broken
	host.verbs += /mob/living/carbon/proc/release_control
	host.verbs += /mob/living/carbon/proc/punish_host
	host.verbs += /mob/living/carbon/proc/spawn_larvae
	*/

/**
 * Kill switch for shit hosts.
 */
/mob/living/simple_animal/borer/proc/kill_host()
	set category = "Alien"
	set name = "Kill Host"
	set desc = "Give the host massive brain damage, killing them nearly instantly."

	if(!check_can_do())
		return

	var/reason = sanitize(input(usr,"Please enter a brief reason for killing the host, or press cancel.\n\nThis will be logged, and presented to the host.","Oh snap") as null|text, MAX_MESSAGE_LEN)
	if(isnull(reason) || reason=="")
		return

	to_chat(src, "<span class='danger'>You thrash your probosci around the host's brain, triggering massive brain damage and stopping your host's heart.</span>")
	to_chat(host, "<span class='sinister'>You get a splitting headache, and then, as blackness descends upon you, you hear: [reason]</span>")

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

	if(!check_can_do())
		return

	to_chat(src, "<span class='danger'>You twitch your probosci.</span>")
	to_chat(host, "<span class='sinister'>You feel something twitch, and get a headache.</span>")

	host.adjustBrainLoss(15)

/mob/living/simple_animal/borer/proc/evolve()
	set category = "Alien"
	set name = "Evolve"
	set desc = "Upgrade yourself or your host."

	if(!check_can_do())
		return

	research.display(src)

/mob/living/simple_animal/borer/proc/secrete_chemicals()
	set category = "Alien"
	set name = "Secrete Chemicals"
	set desc = "Push some chemicals into your host's bloodstream."

	if(!check_can_do())
		return

	var/chemID = input("Select a chemical to secrete.", "Chemicals") as null|anything in avail_chems
	if(!chemID)
		return

	var/datum/borer_chem/chem = avail_chems[chemID]

	var/max_amount = 50
	if(chem.cost>0)
		max_amount = round(chemicals / chem.cost)

	if(max_amount==0)
		to_chat(src, "<span class='warning'>You don't have enough energy to even synthesize one unit!</span>")
		return

	var/units = input("Enter dosage in units.\n\nMax: [max_amount]\nCost: [chem.cost]/unit","Chemicals") as num

	units = round(units)

	if(units < 1)
		to_chat(src, "<span class='warning'>You cannot synthesize this little.</span>")
		return

	if(chemicals < chem.cost*units)
		to_chat(src, "<span class='warning'>You don't have enough energy to synthesize this much!</span>")
		return

	var/datum/reagent/C = chemical_reagents_list[chemID] //we need to get the datum for this reagent to read the overdose threshold
	if(units >= C.overdose - host.reagents.get_reagent_amount(chemID) && C.overdose > 0)
		if(alert("Secreting that much [chemID] would cause an overdose in your host. Are you sure?", "Secrete Chemicals", "Yes", "No") != "Yes")
			return
		add_gamelogs(src, "intentionally overdosed \the [host] with '[chemID]'", admin = TRUE, tp_link = TRUE, span_class = "danger")

	if(!host || controlling || !src || stat) //Sanity check.
		return

	if(chem.name == BLOOD)
		if(istype(host, /mob/living/carbon/human) && !(host.species.flags & NO_BLOOD))
			host.vessel.add_reagent(chem.name, units)
		else
			to_chat(src, "<span class='notice'>Your host seems to be a species that doesn't use blood.<span>")
			return
	else
		host.reagents.add_reagent(chem.name, units)

	to_chat(src, "<span class='info'>You squirt a measure of [chem.name] from your reservoirs into [host]'s bloodstream.</span>")
	add_gamelogs(src, "secreted [units]U of '[chemID]' into \the [host]", admin = TRUE, tp_link = TRUE, span_class = "message")

	chemicals -= chem.cost*units

// We've been moved to someone's head.
/mob/living/simple_animal/borer/proc/infest_limb(var/obj/item/weapon/organ/limb)
	detach()
	limb.borer=src
	loc=limb

	update_verbs(BORER_MODE_SEVERED)

/mob/living/simple_animal/borer/proc/abandon_host()
	set category = "Alien"
	set name = "Abandon Host"
	set desc = "Slither out of your host."

	var/severed = istype(loc, /obj/item/weapon/organ)
	if(!host && !severed)
		to_chat(src, "<span class='warning'>You are not inside a host body.</span>")
		return

	if(stat == UNCONSCIOUS)
		to_chat(src, "<span class='warning'>You cannot leave your host while unconscious.</span>")
		return

	if(channeling)
		to_chat(src, "<span class='warning'>You cannot do this while your focus is directed elsewhere.</span>")
		return

	if(stat)
		to_chat(src, "<span class='warning'>You cannot leave your host in your current state.</span>")
		return

	if(research.unlocking && !severed)
		to_chat(src, "<span class='warning'>You are busy evolving.</span>")
		return

	var/response = alert(src, "Are you -sure- you want to abandon your current host?\n(This will take a few seconds and cannot be halted!)","Are you sure you want to abandon host?","Yes","No")
	if(response != "Yes")
		return

	if(!src)
		return

	if(hostlimb == LIMB_HEAD)
		to_chat(src, "<span class='info'>You begin disconnecting from [host]'s synapses and prodding at their internal ear canal.</span>")
	else
		to_chat(src, "<span class='info'>You begin disconnecting from [host]'s nerve endings and prodding at the surface of their skin.</span>")

	spawn(200)

		if((!host && !severed) || !src) return

		if(src.stat)
			to_chat(src, "<span class='warning'>You cannot abandon [host] in your current state.</span>")
			return

		if(channeling)
			to_chat(src, "<span class='warning'>You cannot abandon [host] while your focus is directed elsewhere.</span>")
			return

		if(controlling)
			to_chat(src, "<span class='warning'>You're too busy controlling your host.</span>")
			return

		if(research.unlocking)
			to_chat(src, "<span class='warning'>You are busy evolving.</span>")
			return

		if(severed)
			if(hostlimb == LIMB_HEAD)
				to_chat(src, "<span class='info'>You wiggle out of the ear of \the [loc] and plop to the ground.</span>")
			else
				to_chat(src, "<span class='info'>You wiggle out of \the [limb_to_name(hostlimb)] and plop to the ground.</span>")
		else
			if(hostlimb == LIMB_HEAD)
				to_chat(src, "<span class='info'>You wiggle out of [host]'s ear and plop to the ground.</span>")
			else
				to_chat(src, "<span class='info'>You wiggle out of [host]'s [limb_to_name(hostlimb)] and plop to the ground.</span>")

		detach()

// Try to reset everything, also while handling invalid host/host_brain states.
/mob/living/simple_animal/borer/proc/detach()
	if(host)
		if(istype(host,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = host
			var/datum/organ/external/implanted = H.get_organ(hostlimb)
			implanted.implants -= src

	src.forceMove(get_turf(src))
	controlling = 0

	reset_view(null)
	machine = null

	if(host)
		host.reset_view(null)
		host.machine = null

		host.verbs -= /mob/living/carbon/proc/release_control
		host.verbs -= /mob/living/carbon/proc/punish_host

		// Remove any unlocks that affect the host.
		for(var/uid in research.unlocked.Copy())
			var/datum/unlockable/borer/U = research.get(uid)
			if(U)
				if(U.remove_on_detach)
					U.relock()
				U.on_detached()

		host.on_emote.Remove(eh_emote)

	if(host_brain && host_brain.ckey)
		src.ckey = host.ckey
		host.ckey = host_brain.ckey
		host_brain.ckey = null
		host_brain.name = "host brain"
		host_brain.real_name = "host brain"

	host = null
	hostlimb = null
	channeling = 0
	channeling_brute_resist = 0
	channeling_burn_resist = 0
	channeling_speed_increase = 0
	channeling_bone_talons = 0
	channeling_bone_sword = 0
	channeling_bone_shield = 0
	channeling_bone_hammer = 0
	channeling_bone_cocoon = 0
	update_verbs(BORER_MODE_DETACHED)

	extend_o_arm.forceMove(src)

/client/proc/borer_infest()
	set category = "Alien"
	set name = "Infest"
	set desc = "Infest a suitable humanoid host."

	var/mob/living/simple_animal/borer/B=mob
	if(!istype(B)) return
	B.infest()

/mob/living/simple_animal/borer/proc/limb_to_name(var/limb = null)
	if(!limb)
		return
	var/limbname = ""
	switch(limb)
		if(LIMB_HEAD)
			limbname = LIMB_HEAD
		if(LIMB_CHEST)
			limbname = LIMB_CHEST
		if(LIMB_RIGHT_ARM)
			limbname = "right arm"
		if(LIMB_LEFT_ARM)
			limbname = "left arm"
		if(LIMB_RIGHT_LEG)
			limbname = "right leg"
		if(LIMB_LEFT_LEG)
			limbname = "left leg"
	return limbname

/mob/living/simple_animal/borer/proc/limb_to_mode(var/limb = null)
	if(!limb)
		return
	var/mode = 0
	switch(limb)
		if(LIMB_HEAD)
			mode = BORER_MODE_ATTACHED_HEAD
		if(LIMB_CHEST)
			mode = BORER_MODE_ATTACHED_CHEST
		if(LIMB_RIGHT_ARM)
			mode = BORER_MODE_ATTACHED_ARM
		if(LIMB_LEFT_ARM)
			mode = BORER_MODE_ATTACHED_ARM
		if(LIMB_RIGHT_LEG)
			mode = BORER_MODE_ATTACHED_LEG
		if(LIMB_LEFT_LEG)
			mode = BORER_MODE_ATTACHED_LEG
	return mode

/mob/living/simple_animal/borer/proc/limb_covered(var/mob/living/carbon/C = null, var/limb = null)
	if(!limb || !C)
		return

	if(!istype(C,/mob/living/carbon/human))
		return 0

	var/mob/living/carbon/human/H = C

	switch(limb)
		if(LIMB_HEAD)
			if(H.check_body_part_coverage(EARS))
				return 1
		if(LIMB_CHEST)
			if(H.check_body_part_coverage(UPPER_TORSO) && limb_covered(C, LIMB_RIGHT_ARM) && limb_covered(C, LIMB_LEFT_ARM) && limb_covered(C, LIMB_RIGHT_LEG) && limb_covered(C, LIMB_LEFT_LEG)) //any gap in protection will allow a borer to squeeze underneath chest protection
				return 1
		if(LIMB_RIGHT_ARM)
			if(H.check_body_part_coverage(ARM_RIGHT) && H.check_body_part_coverage(HAND_RIGHT))
				return 1
		if(LIMB_LEFT_ARM)
			if(H.check_body_part_coverage(ARM_LEFT) && H.check_body_part_coverage(HAND_LEFT))
				return 1
		if(LIMB_RIGHT_LEG)
			if(H.check_body_part_coverage(LEG_RIGHT) && H.check_body_part_coverage(FOOT_RIGHT))
				return 1
		if(LIMB_LEFT_LEG)
			if(H.check_body_part_coverage(LEG_LEFT) && H.check_body_part_coverage(FOOT_LEFT))
				return 1
	return 0

/mob/living/simple_animal/borer/proc/infest()
	set category = "Alien"
	set name = "Infest"
	set desc = "Infest a suitable humanoid host."

	if(host)
		to_chat(src, "You are already within a host.")
		return

	if(stat == UNCONSCIOUS)
		to_chat(src, "<span class='warning'>You cannot infest a target while unconscious.</span>")
		return

	if(channeling)
		to_chat(src, "<span class='warning'>You cannot do this while your focus is directed elsewhere.</span>")

	if(stat)
		to_chat(src, "You cannot infest a target in your current state.")
		return

	if(research.unlocking)
		to_chat(src, "<span class='warning'>You are busy evolving.</span>")
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(1,src))
		if(C.stat != 2 && src.Adjacent(C))
			choices += C

	var/mob/living/carbon/M = input(src,"Who do you wish to infest?") in null|choices

	if(!M || !src) return

	if(!(src.Adjacent(M))) return

	var/area = src.zone_sel.selecting
	var/region = LIMB_HEAD

	if(istype(M, /mob/living/carbon/human))
		switch(area)
			if(LIMB_HEAD)
				region = LIMB_HEAD
			if("mouth")
				region = LIMB_HEAD
			if("eyes")
				region = LIMB_HEAD
			if(LIMB_CHEST)
				region = LIMB_CHEST
			if(LIMB_GROIN)
				region = LIMB_CHEST
			if(LIMB_RIGHT_ARM)
				region = LIMB_RIGHT_ARM
			if(LIMB_RIGHT_HAND)
				region = LIMB_RIGHT_ARM
			if(LIMB_LEFT_ARM)
				region = LIMB_LEFT_ARM
			if(LIMB_LEFT_HAND)
				region = LIMB_LEFT_ARM
			if(LIMB_RIGHT_LEG)
				region = LIMB_RIGHT_LEG
			if(LIMB_RIGHT_FOOT)
				region = LIMB_RIGHT_LEG
			if(LIMB_LEFT_LEG)
				region = LIMB_LEFT_LEG
			if(LIMB_LEFT_FOOT)
				region = LIMB_LEFT_LEG

		var/mob/living/carbon/human/H = M
		var/datum/organ/external/O = H.get_organ(region)
		if(!O.is_organic())
			to_chat(src, "You cannot infest this host's inorganic [limb_to_name(region)]!")
			return

		if(!O.is_existing())
			to_chat(src, "This host does not have a [limb_to_name(region)]!")
			return

	if(M.has_brain_worms(region))
		to_chat(src, "This host's [limb_to_name(region)] is already infested!")
		return

	if(limb_covered(M, region))
		to_chat(src, "You cannot get through the protective gear on that host's [limb_to_name(region)].")
		return

	switch(region)
		if(LIMB_HEAD)
			to_chat(src, "You slither up [M] and begin probing at their ear canal...")
			to_chat(M, "<span class='sinister'>You feel something slithering up your leg and probing at your ear canal...</span>")
		if(LIMB_CHEST)
			to_chat(src, "You slither up [M] and begin probing just below their sternum...")
			to_chat(M, "<span class='sinister'>You feel something slithering up your leg and probing just below your sternum...</span>")
		if(LIMB_RIGHT_ARM)
			to_chat(src, "You slither up [M] and begin probing at their right arm...")
			to_chat(M, "<span class='sinister'>You feel something slithering up your leg and probing at your right arm...</span>")
		if(LIMB_LEFT_ARM)
			to_chat(src, "You slither up [M] and begin probing at their left arm...")
			to_chat(M, "<span class='sinister'>You feel something slithering up your leg and probing at your left arm...</span>")
		if(LIMB_RIGHT_LEG)
			to_chat(src, "You slither up [M]'s right leg and begin probing at the back of their knee...")
			to_chat(M, "<span class='sinister'>You feel something slithering up your right leg and probing just behind your knee...</span>")
		if(LIMB_LEFT_LEG)
			to_chat(src, "You slither up [M]'s left leg and begin probing at the back of their knee...")
			to_chat(M, "<span class='sinister'>You feel something slithering up your left leg and probing just behind your knee...</span>")

	if(!do_after(src,M,50))
		to_chat(src, "As [M] moves away, you are dislodged and fall to the ground.")
		return

	if(!M || !src) return

	if(src.stat)
		to_chat(src, "You cannot infest a target in your current state.")
		return

	if(M.stat == 2)
		to_chat(src, "That is not an appropriate target.")
		return

	if(M.has_brain_worms(region))
		to_chat(src, "This host's [limb_to_name(region)] is already infested!")
		return

	if(M in view(1, src))
		to_chat(src, "[region == LIMB_HEAD ? "You wiggle into [M]'s ear." : "You burrow under [M]'s skin."]")
		src.perform_infestation(M, region)

		return
	else
		to_chat(src, "They are no longer in range!")
		return

/mob/living/simple_animal/borer/proc/perform_infestation(var/mob/living/carbon/M, var/body_region = LIMB_HEAD)
	if(!M || !istype(M))
		error("[src]: Unable to perform_infestation on [M]!")
		return 0

	hostlimb = body_region

	update_verbs(limb_to_mode(hostlimb)) // Must be called before being removed from turf. (BYOND verb transfer bug)

	src.host = M
	src.forceMove(M)

	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/implanted = H.get_organ(body_region)
		implanted.implants += src

	host_brain.name = M.name
	host_brain.real_name = M.real_name

	eh_emote = host.on_emote.Add(src,"host_emote")

	// Tell our upgrades that we've attached.
	for(var/uid in research.unlocked.Copy())
		var/datum/unlockable/borer/U = research.get(uid)
		if(U)
			U.on_attached()

	// /vg/ - Our users are shit, so we start with control over host.
	if(config.borer_takeover_immediately)
		do_bonding(rptext=1)

	extend_o_arm.forceMove(host)

// So we can hear our host doing things.
// NOTE:  We handle both visible and audible emotes because we're a brainslug that can see the impulses and shit.
/mob/living/simple_animal/borer/proc/host_emote(var/list/args)
	src.show_message(args["message"], args["m_type"])
	host_brain.show_message(args["message"], args["m_type"])

/mob/living/simple_animal/borer/proc/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Alien"

	if(stat == UNCONSCIOUS)
		to_chat(src, "<span class='warning'>You cannot ventcrawl while unconscious.</span>")
		return

	if(stat)
		to_chat(src, "You cannot ventcrawl your current state.")
		return

	if(research.unlocking)
		to_chat(src, "<span class='warning'>You are busy evolving.</span>")
		return

	var/pipe = start_ventcrawl()
	if(pipe)
		handle_ventcrawl(pipe)

//copy paste from alien/larva, if that func is updated please update this one alsoghost
/mob/living/simple_animal/borer/proc/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Alien"

	if(isUnconscious())
		return

	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		plane = PLANE_TURF
		to_chat(src, text("<span class='notice'>You are now hiding.</span>"))
	else
		layer = MOB_LAYER
		plane = PLANE_MOB
		to_chat(src, text("<span class='notice'>You have stopped hiding.</span>"))



/mob/living/simple_animal/borer/proc/reproduce()
	set name = "Reproduce"
	set desc = "Spawn offspring in the form of an egg."
	set category = "Alien"

	if(stat == UNCONSCIOUS)
		to_chat(src, "<span class='warning'>You cannot reproduce while unconscious.</span>")
		return

	if(stat)
		to_chat(src, "You cannot reproduce in your current state.")
		return

	if(research.unlocking)
		to_chat(src, "<span class='warning'>You are busy evolving.</span>")
		return

	if(busy)
		to_chat(src, "<span class='warning'>You are already doing something.</span>")
		return

	if(chemicals >= 100)
		busy=1
		to_chat(src, "<span class='warning'>You strain, trying to push out your young...</span>")
		visible_message("<span class='warning'>\The [src] begins to struggle and strain!</span>", \
			drugged_message = "<span class='notice'>\The [src] starts dancing.</span>")
		var/turf/T = get_turf(src)
		if(do_after(src, T, 5 SECONDS))
			to_chat(src, "<span class='danger'>You twitch and quiver as you rapidly excrete an egg from your sluglike body.</span>")
			visible_message("<span class='danger'>\The [src] heaves violently, expelling a small, gelatinous egg!</span>", \
				drugged_message = "<span class='notice'>\The [src] starts farting a rainbow! Suddenly, a pot of gold appears.</span>")
			chemicals -= 100

			numChildren++

			playsound(T, 'sound/effects/splat.ogg', 50, 1)
			if(istype(T, /turf/simulated))
				T.add_vomit_floor(null, 1)
			var/obj/item/weapon/reagent_containers/food/snacks/borer_egg/E = new (T)
			E.child_prefix_index = (name_prefix_index + 1)
		busy=0

	else
		to_chat(src, "You do not have enough chemicals stored to reproduce.")
		return()

//Procs for grabbing players.
/mob/living/simple_animal/borer/proc/request_player()
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

/mob/living/simple_animal/borer/proc/transfer_personality(var/client/candidate)


	if(!candidate)
		return

	src.mind = candidate.mob.mind
	src.ckey = candidate.ckey
	if(src.mind)
		src.mind.assigned_role = "Borer"

		// Assign objectives
		//forge_objectives()

		// tl;dr
		to_chat(src, "<span class='danger'>You are a Borer!</span>")
		to_chat(src, "<span class='info'>You are a small slug-like symbiote that attaches to your host's body.  Your only goals are to survive and procreate. However, there are those who would like to destroy you, and hosts don't take kindly to jerks.  Being as helpful to your host as possible is the best option for survival.</span>")
		to_chat(src, "<span class='info'>Borers can speak with other borers over the Cortical Link.  To do so, release control and use <code>say \";message\"</code>.  To communicate with your host only, speak normally.</span>")
		to_chat(src, "<span class='info'><b>New:</b> To get new abilities for you and your host, use <em>Evolve</em> to unlock things.  Borers are now symbiotic biological pAIs.</span>")
		if(config.borer_takeover_immediately)
			to_chat(src, "<span class='info'><b>Important:</b> While you receive full control at the start, <em>it is asked that you release control at some point so your host has a chance to play.</em>  If they misbehave, you are permitted to kill them.</span>")

		//var/obj_count = 1
		//for(var/datum/objective/objective in mind.objectives)
//			to_chat(src, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		//	obj_count++

/mob/living/simple_animal/borer/proc/forge_objectives()
	var/datum/objective/survive/survive_objective = new
	survive_objective.owner = mind
	mind.objectives += survive_objective

	/*
	var/datum/objective/multiply/multiply_objective = new
	multiply_objective.owner = mind
	mind.objectives += multiply_objective
	*/



/mob/living/simple_animal/borer/proc/analyze_host()
	set name = "Analyze Health"
	set desc = "Check the health of your host."
	set category = "Alien"

	to_chat(src, "<span class='info'>You listen to the song of your host's nervous system, hunting for dischordant notes...</span>")
	spawn(5 SECONDS)
		healthanalyze(host, src, mode=1, silent=1, skip_checks=1) // I am not rewriting this shit with more immersive strings.  Deal with it. - N3X

/mob/living/simple_animal/borer/proc/taste_blood()
	set name = "Taste Blood"
	set desc = "See if there's anything within the blood of your host."
	set category = "Alien"

	if(!check_can_do())
		return

	to_chat(src, "<span class='info'>You taste the blood of your host, and process it for abnormalities.</span>")
	if(!isnull(host.reagents))
		var/dat = ""
		if(host.reagents.reagent_list.len > 0)
			for (var/datum/reagent/R in host.reagents.reagent_list)
				if(R.id == BLOOD) continue // Like we need to know that blood contains blood.
				dat += "\n \t <span class='notice'>[R] ([R.volume] units)</span>"
		if(dat)
			to_chat(src, "<span class='notice'>Chemicals found: [dat]</span>")
		else
			to_chat(src, "<span class='notice'>No active chemical agents found in [host]'s blood.</span>")
	else
		to_chat(src, "<span class='notice'>No significant chemical agents found in [host]'s blood.</span>")


/mob/living/simple_animal/borer/attack_ghost(var/mob/dead/observer/O)
	if(!(src.key))
		if(O.can_reenter_corpse)
			var/response = alert(O,"Do you want to take it over?","This borer has no soul","Yes","No")
			if(response == "Yes")
				if(!(src.key))
					src.transfer_personality(O.client)
				else if(src.key)
					to_chat(src, "<span class='notice'>Somebody jumped your claim on this borer and is already controlling it. Try another </span>")
		else if(!(O.can_reenter_corpse))
			to_chat(O,"<span class='notice'>While the borer may be mindless, you have recently ghosted and thus are not allowed to take over for now.</span>")

/mob/living/simple_animal/borer/proc/passout(var/wait_time = 0, var/show_message = 0)
	if(!wait_time)
		return
	if(show_message)
		to_chat(src, "<span class='warning'>You lose consciousness due to overexertion.</span>")

	wait_time = min(wait_time, 60)
	stat = UNCONSCIOUS
	spawn()
		sleep(wait_time*10)
		stat = CONSCIOUS
		to_chat(src, "<span class='notice'>You have regained consciousness.</span>")

/mob/living/simple_animal/borer/proc/check_can_do(var/check_channeling = 1)
	if(!host)
		to_chat(src, "<span class='warning'>You are not inside a host body.</span>")
		return 0

	if(stat == UNCONSCIOUS)
		to_chat(src, "<span class='warning'>You cannot do this while unconscious.</span>")
		return 0

	if(stat)
		to_chat(src, "<span class='warning'>You cannot do this in your current state.</span>")
		return 0

	if(controlling)
		to_chat(src, "<span class='warning'>You're too busy controlling your host.</span>")
		return 0

	if(host.stat==DEAD)
		to_chat(src, "<span class='warning'>You cannot do that in your host's current state.</span>")
		return 0

	if(research.unlocking)
		to_chat(src, "<span class='warning'>You are busy evolving.</span>")
		return 0

	if(check_channeling)
		if(channeling)
			to_chat(src, "<span class='warning'>You can't do this while your focus is directed elsewhere.</span>")
			return 0

	return 1

/mob/living/simple_animal/borer/ClickOn( var/atom/A, var/params )
	..()
	if(host)
		if(extend_o_arm_unlocked)
			if(hostlimb == LIMB_RIGHT_ARM || hostlimb == LIMB_LEFT_ARM)
				if(!extend_o_arm)
					extend_o_arm = new /obj/item/weapon/gun/hookshot/flesh(src, src)
					extend_o_arm.forceMove(host)
				if(istype(host.get_held_item_by_index(GRASP_RIGHT_HAND), /obj/item/offhand) || istype(host.get_held_item_by_index(GRASP_LEFT_HAND), /obj/item/offhand)) //If the host is two-handing something.
					to_chat(src, "<span class='warning'>You cannot swing this item while your host holds it with both hands!</span>")
					return
				if(host.stunned)
					to_chat(src, "<span class='warning'>Your host's muscles are tightened. You can't extend your arm!</span>")
					return
				var/datum/reagents/R = host.reagents
				if(R)
					if(R.has_reagent(SILICATE))
						to_chat(src, "<span class='warning'>Something in your host's bloodstream is tightening their muscles. You can't extend your arm!</span>")
						return
				if(host.Adjacent(A))
					if(hostlimb == LIMB_RIGHT_ARM)
						if(host.get_held_item_by_index(GRASP_RIGHT_HAND))
							if(attack_cooldown)
								return
							else
								A.attackby(host.get_held_item_by_index(GRASP_RIGHT_HAND), host, 1, src)
								attack_cooldown = 1
								reset_attack_cooldown()
								return
						else if(istype(A, /obj/item))
							var/obj/item/I = A
							if(!I.anchored)
								host.put_in_r_hand(A)
								return
					else
						if(host.get_held_item_by_index(GRASP_LEFT_HAND))
							if(attack_cooldown)
								return
							else
								A.attackby(host.get_held_item_by_index(GRASP_LEFT_HAND), host, 1, src)
								attack_cooldown = 1
								reset_attack_cooldown()
								return
						else if(istype(A, /obj/item))
							var/obj/item/I = A
							if(!I.anchored)
								host.put_in_l_hand(A)
								return
				if(get_turf(A) == get_turf(host) && !istype(A, /obj/item))
					return
				if(hostlimb == LIMB_RIGHT_ARM)
					if(host.get_held_item_by_index(GRASP_RIGHT_HAND))
						if(istype(host.get_held_item_by_index(GRASP_RIGHT_HAND), /obj/item/weapon/gun/hookshot)) //I don't want to deal with the fleshshot interacting with hookshots
							return
						if(chemicals < 10)
							to_chat(src, "<span class='warning'>You don't have enough chemicals stored to swing an item with this arm!</span>")
							return
						else
							if(!(extend_o_arm.hook || extend_o_arm.chain_datum || extend_o_arm.rewinding))	//If the arm is not currently extended.
								chemicals -= 10		//It costs 10 chems to fire the fleshshot while holding an item.
				else if(hostlimb == LIMB_LEFT_ARM)
					if(host.get_held_item_by_index(GRASP_LEFT_HAND))
						if(istype(host.get_held_item_by_index(GRASP_LEFT_HAND), /obj/item/weapon/gun/hookshot))
							return
						if(chemicals < 10)
							to_chat(src, "<span class='warning'>You don't have enough chemicals stored to swing an item with this arm!</span>")
							return
						else
							if(!(extend_o_arm.hook || extend_o_arm.chain_datum || extend_o_arm.rewinding))
								chemicals -= 10
				extend_o_arm.afterattack(A, host)

/mob/living/simple_animal/borer/proc/reset_attack_cooldown()
	spawn(10)
		attack_cooldown = 0
