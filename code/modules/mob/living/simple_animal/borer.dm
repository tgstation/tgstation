#define BORER_MODE_ATTACHED 1
#define BORER_MODE_DETACHED 0
#define BORER_MODE_BEHEADED 2

var/global/borer_chem_types = typesof(/datum/borer_chem) - /datum/borer_chem
var/global/borer_unlock_types = typesof(/datum/unlockable/borer) - /datum/unlockable/borer - /datum/unlockable/borer/chem_unlock - /datum/unlockable/borer/verb_unlock

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
	var/truename                            // Name used for brainworm-speak.
	var/mob/living/captive_brain/host_brain // Used for swapping control of the body back and forth.
	var/controlling                         // Used in human death check.
	var/list/avail_chems=list()
	var/list/avail_abilities=list()         // Unlocked powers.
	var/list/attached_verbs=list(/obj/item/verbs/borer/attached)
	var/list/beheaded_verbs=list(/obj/item/verbs/borer/beheaded)
	var/list/detached_verbs=list(/obj/item/verbs/borer/detached)
	var/numChildren=0

	var/datum/research_tree/borer/research
	var/list/verb_holders = list()
	var/list/borer_avail_unlocks = list()

	// Event handles
	var/eh_emote

/mob/living/simple_animal/borer/New(var/loc)
	..(loc)
	truename = "[pick("Primary","Secondary","Tertiary","Quaternary")] [rand(1000,9999)]"
	host_brain = new/mob/living/captive_brain(src)

	if(name == initial(name)) // Easier reporting of griff.
		name = "[name] ([rand(1, 1000)])"
		real_name = name

	update_verbs(BORER_MODE_DETACHED)

	for(var/chemtype in borer_chem_types)
		var/datum/borer_chem/C = new chemtype()
		if(!C.unlockable)
			avail_chems[C.name]=C
			//testing("Added [C.name] to borer.")

	research = new (src)

	for(var/ultype in borer_unlock_types)
		var/datum/unlockable/borer/U = new ultype()
		if(U.id!="")
			borer_avail_unlocks.Add(U)

/mob/living/simple_animal/borer/Login()
	..()
	if(mind)
		RemoveAllFactionIcons(mind)

/mob/living/simple_animal/borer/Life()
	if(timestopped) return 0 //under effects of time magick

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

/mob/living/simple_animal/borer/proc/update_verbs(var/mode)
	if(verb_holders.len>0)
		for(var/VH in verb_holders)
			qdel(VH)
	verb_holders=list()
	var/list/verbtypes = list()
	switch(mode)
		if(BORER_MODE_ATTACHED) // 1
			verbtypes=attached_verbs
		if(BORER_MODE_DETACHED) // 0
			verbtypes=detached_verbs
		if(BORER_MODE_BEHEADED) // 2
			verbtypes=beheaded_verbs
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

	to_chat(src, "You drop words into [host]'s mind: <span class='borer2host'>\"[encoded_message]\"</span>")
	to_chat(host, "<span class='borer2host'>\"[encoded_message]\"</span>")
	var/turf/T = get_turf(src)
	log_say("[truename] [key_name(src)] (@[T.x],[T.y],[T.z]) -> [host]([key_name(host)]) Borer->Host Speech: [message]")

	for(var/mob/M in player_list)
		if(istype(M, /mob/new_player))
			continue
		if(istype(M,/mob/dead/observer)  && (M.client && M.client.prefs.toggles & CHAT_GHOSTEARS))
			var/controls = "<a href='byond://?src=\ref[M];follow2=\ref[M];follow=\ref[src]'>Follow</a>"
			if(M.client.holder)
				controls+= " | <A HREF='?_src_=holder;adminmoreinfo=\ref[src]'>?</A>"
			var/rendered="<span class='thoughtspeech'>Thought-speech, <b>[truename]</b> ([controls]) -> <b>[host]:</b> [encoded_message]</span>"
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

		stat("Chemicals", chemicals)

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

	if(!host)
		to_chat(src, "You are not inside a host body.")
		return

	if(src.stat)
		to_chat(src, "You cannot do that in your current state.")
		return

	if(host.stat==DEAD)
		to_chat(src, "You cannot do that in your host's current state.")
		return

	if(research.unlocking)
		to_chat(src, "<span class='warning'>You are busy evolving.</span>")
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

	if(!host)
		to_chat(src, "You are not inside a host body.")
		return

	if(stat)
		to_chat(src, "You cannot secrete chemicals in your current state.")
		return

	if(host.stat==DEAD)
		to_chat(src, "You cannot do that in your host's current state.")
		return

	if(research.unlocking)
		to_chat(src, "<span class='warning'>You are busy evolving.</span>")
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

	if(!host)
		to_chat(src, "You are not inside a host body.")
		return

	if(stat)
		to_chat(src, "You cannot secrete chemicals in your current state.")
		return

	if(host.stat==DEAD)
		to_chat(src, "You cannot do that in your host's current state.")
		return

	if(research.unlocking)
		to_chat(src, "<span class='warning'>You are busy evolving.</span>")
		return

	to_chat(src, "<span class='danger'>You twitch your probosci.</span>")
	to_chat(host, "<span class='sinister'>You feel something twitch, and get a headache.</span>")

	host.adjustBrainLoss(15)

/mob/living/simple_animal/borer/proc/evolve()
	set category = "Alien"
	set name = "Evolve"
	set desc = "Upgrade yourself or your host."

	if(!host)
		to_chat(src, "<span class='warning'>You are not inside a host body.</span>")
		return

	if(stat)
		to_chat(src, "<span class='warning'>You cannot secrete chemicals in your current state.</span>")
		return

	if(controlling)
		to_chat(src, "<span class='warning'>You're too busy controlling your host.</span>")
		return

	if(host.stat==DEAD)
		to_chat(src, "<span class='warning'>You cannot do that in your host's current state.</span>")
		return

	if(research.unlocking)
		to_chat(src, "<span class='warning'>You are busy evolving.</span>")
		return

	research.display(src)

/mob/living/simple_animal/borer/proc/secrete_chemicals()
	set category = "Alien"
	set name = "Secrete Chemicals"
	set desc = "Push some chemicals into your host's bloodstream."

	if(!host)
		to_chat(src, "<span class='warning'>You are not inside a host body.</span>")
		return

	if(stat)
		to_chat(src, "<span class='warning'>You cannot secrete chemicals in your current state.</span>")
		return

	if(controlling)
		to_chat(src, "<span class='warning'>You're too busy controlling your host.</span>")
		return

	if(host.stat==DEAD)
		to_chat(src, "<span class='warning'>You cannot do that in your host's current state.</span>")
		return

	if(research.unlocking)
		to_chat(src, "<span class='warning'>You are busy evolving.</span>")
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


	if(!host || controlling || !src || stat) //Sanity check.
		return

	to_chat(src, "<span class='info'>You squirt a measure of [chem.name] from your reservoirs into [host]'s bloodstream.</span>")
	add_gamelogs(src, "secreted [units]U of '[chemID]' into \the [host]", admin = TRUE, tp_link = TRUE, span_class = "danger")
	host.reagents.add_reagent(chem.name, units)
	chemicals -= chem.cost*units

// We've been moved to someone's head.
/mob/living/simple_animal/borer/proc/infest_head(var/obj/item/weapon/organ/head/head)
	detach()
	head.borer=src
	loc=head

	update_verbs(BORER_MODE_BEHEADED)


/mob/living/simple_animal/borer/proc/abandon_host()
	set category = "Alien"
	set name = "Abandon Host"
	set desc = "Slither out of your host."

	var/in_head= istype(loc, /obj/item/weapon/organ/head)
	if(!host && !in_head)
		to_chat(src, "<span class='warning'>You are not inside a host body.</span>")
		return

	if(stat)
		to_chat(src, "<span class='warning'>You cannot leave your host in your current state.</span>")
		return

	if(research.unlocking && !in_head)
		to_chat(src, "<span class='warning'>You are busy evolving.</span>")
		return

	if(!src)
		return

	to_chat(src, "<span class='info'>You begin disconnecting from [host]'s synapses and prodding at their internal ear canal.</span>")

	spawn(200)

		if((!host && !in_head) || !src) return

		if(src.stat)
			to_chat(src, "<span class='warning'>You cannot abandon [host] in your current state.</span>")
			return

		if(in_head)
			to_chat(src, "<span class='info'>You wiggle out of the ear of \the [loc] and plop to the ground.</span>")
		else
			to_chat(src, "<span class='info'>You wiggle out of [host]'s ear and plop to the ground.</span>")

		detach()

// Try to reset everything, also while handling invalid host/host_brain states.
/mob/living/simple_animal/borer/proc/detach()
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
	update_verbs(BORER_MODE_DETACHED)

/client/proc/borer_infest()
	set category = "Alien"
	set name = "Infest"
	set desc = "Infest a suitable humanoid host."

	var/mob/living/simple_animal/borer/B=mob
	if(!istype(B)) return
	B.infest()

/mob/living/simple_animal/borer/proc/infest()
	set category = "Alien"
	set name = "Infest"
	set desc = "Infest a suitable humanoid host."

	if(host)
		to_chat(src, "You are already within a host.")
		return

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

	if(M.has_brain_worms())
		to_chat(src, "You cannot infest someone who is already infested!")
		return

	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		if(H.check_body_part_coverage(EARS))
			to_chat(src, "You cannot get through that host's protective gear.")
			return

	to_chat(src, "You slither up [M] and begin probing at their ear canal...")
	to_chat(M, "<span class='sinister'>You feel something slithering up your leg...</span>")

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

	if(M in view(1, src))
		to_chat(src, "You wiggle into [M]'s ear.")
		src.perform_infestation(M)

		return
	else
		to_chat(src, "They are no longer in range!")
		return

/mob/living/simple_animal/borer/proc/perform_infestation(var/mob/living/carbon/M)
	if(!M || !istype(M))
		error("[src]: Unable to perform_infestation on [M]!")
		return 0

	update_verbs(BORER_MODE_ATTACHED) // Must be called before being removed from turf. (BYOND verb transfer bug)

	src.host = M
	src.loc = M

	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/head = H.get_organ("head")
		head.implants += src

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

// So we can hear our host doing things.
// NOTE:  We handle both visible and audible emotes because we're a brainslug that can see the impulses and shit.
/mob/living/simple_animal/borer/proc/host_emote(var/list/args)
	src.show_message(args["message"], args["m_type"])
	host_brain.show_message(args["message"], args["m_type"])

/mob/living/simple_animal/borer/proc/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Alien"

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

	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		to_chat(src, text("<span class='notice'>You are now hiding.</span>"))
	else
		layer = MOB_LAYER
		to_chat(src, text("<span class='notice'>You have stopped hiding.</span>"))



/mob/living/simple_animal/borer/proc/reproduce()
	set name = "Reproduce"
	set desc = "Spawn offspring in the form of an egg."
	set category = "Alien"

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
			new /obj/item/weapon/reagent_containers/food/snacks/borer_egg(T)
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
		src.mind.assigned_role = "Cortical Borer"

		// Assign objectives
		//forge_objectives()

		// tl;dr
		to_chat(src, "<span class='danger'>You are a Cortical Borer!</span>")
		to_chat(src, "<span class='info'>You are a small slug-like symbiote that attaches to your host's brain.  Your only goals are to survive and procreate. However, there are those who would like to destroy you, and hosts don't take kindly to jerks.  Being as helpful to your host as possible is the best option for survival.</span>")
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

	if(stat)
		to_chat(src, "You cannot taste blood in your current state.")
		return

	if(research.unlocking)
		to_chat(src, "<span class='warning'>You are busy evolving.</span>")
		return

	to_chat(src, "<span class='info'>You taste the blood of your host, and process it for abnormalities.</span>")
	if(!isnull(host.reagents))
		var/dat = ""
		if(host.reagents.reagent_list.len > 0)
			for (var/datum/reagent/R in host.reagents.reagent_list)
				if(R.id == "blood") continue // Like we need to know that blood contains blood.
				dat += "\n \t <span class='notice'>[R] ([R.volume] units)</span>"
		if(dat)
			to_chat(src, "<span class='notice'>Chemicals found: [dat]</span>")
		else
			to_chat(src, "<span class='notice'>No active chemical agents found in [host]'s blood.</span>")
	else
		to_chat(src, "<span class='notice'>No significant chemical agents found in [host]'s blood.</span>")
