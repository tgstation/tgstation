/mob/living/captive_brain
	name = "host brain"
	real_name = "host brain"

/mob/living/captive_brain/say(var/message)

	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='danger'>You cannot speak in IC (muted).</span>")
			return
		if(client.handle_spam_prevention(message,MUTE_IC))
			return

	if(isborer(loc))

		message = sanitize(message)
		if(!message)
			return
		log_say("[key_name(src)] : [message]")
		if(stat == 2)
			return say_dead(message)

		var/mob/living/simple_animal/borer/B = loc
		to_chat(src, "<i><span class='alien'>You whisper silently, \"[message]\"</span></i>")
		to_chat(B.victim, "<i><span class='alien'>The captive mind of [src] whispers, \"[message]\"</span></i>")

		for (var/mob/M in GLOB.player_list)
			if(isnewplayer(M))
				continue
			else if(M.stat == 2 &&  M.client.prefs.toggles & CHAT_GHOSTEARS)
				to_chat(M, "<i>Thought-speech, <b>[src]</b> -> <b>[B.truename]:</b> [message]</i>")

/mob/living/captive_brain/emote(var/message)
	return

/mob/living/captive_brain/resist()

	var/mob/living/simple_animal/borer/B = loc

	to_chat(src, "<span class='danger'>You begin doggedly resisting the parasite's control (this will take approximately 40 seconds).</span>")
	to_chat(B.victim, "<span class='danger'>You feel the captive mind of [src] begin to resist your control.</span>")

	var/delay = rand(150,250) + B.victim.brainloss
	addtimer(CALLBACK(src, .proc/return_control, src.loc), delay)

/mob/living/captive_brain/proc/return_control(mob/living/simple_animal/borer/B)
    if(!B || !B.controlling)
        return

    B.victim.adjustBrainLoss(rand(5,10))
    to_chat(src, "<span class='danger'>With an immense exertion of will, you regain control of your body!</span>")
    to_chat(B.victim, "<span class='danger'>You feel control of the host brain ripped from your grasp, and retract your probosci before the wild neural impulses can damage you.</span>")
    B.detatch()

GLOBAL_LIST_EMPTY(borers)
GLOBAL_VAR_INIT(total_borer_hosts_needed, 10)

/mob/living/simple_animal/borer
	name = "cortical borer"
	real_name = "cortical borer"
	desc = "A small, quivering, slug-like creature."
	icon_state = "brainslug"
	icon_living = "brainslug"
	icon_dead = "brainslug_dead"
	health = 20
	maxHealth = 20
	melee_damage_lower = 5
	melee_damage_upper = 5
	stop_automated_movement = TRUE
	attacktext = "chomps"
	attack_sound = 'sound/weapons/bite.ogg'
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	faction = list("creature")
	ventcrawler = VENTCRAWLER_ALWAYS
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500

	var/generation = 1
	var/static/list/borer_names = list(
			"Primary", "Secondary", "Tertiary", "Quaternary", "Quinary", "Senary",
			"Septenary", "Octonary", "Novenary", "Decenary", "Undenary", "Duodenary",
			)

	var/mob/living/carbon/victim = null
	var/mob/living/captive_brain/host_brain = null
	var/truename
	var/docile = FALSE
	var/bonding = FALSE
	var/controlling = FALSE
	var/chemicals = 10
	var/used_dominate
	var/borer_chems = list()
	var/leaving = FALSE
	var/hiding = FALSE
	var/waketimerid = null

	var/datum/action/innate/borer/talk_to_host/talk_to_host_action = new
	var/datum/action/innate/borer/infest_host/infest_host_action = new
	var/datum/action/innate/borer/toggle_hide/toggle_hide_action = new
	var/datum/action/innate/borer/talk_to_borer/talk_to_borer_action = new
	var/datum/action/innate/borer/talk_to_brain/talk_to_brain_action = new
	var/datum/action/innate/borer/take_control/take_control_action = new
	var/datum/action/innate/borer/give_back_control/give_back_control_action = new
	var/datum/action/innate/borer/leave_body/leave_body_action = new
	var/datum/action/innate/borer/make_chems/make_chems_action = new
	var/datum/action/innate/borer/make_larvae/make_larvae_action = new
	var/datum/action/innate/borer/freeze_victim/freeze_victim_action = new
	var/datum/action/innate/borer/punish_victim/punish_victim_action = new
	var/datum/action/innate/borer/jumpstart_host/jumpstart_host_action = new

/mob/living/simple_animal/borer/Initialize(mapload, gen=1)
	..()
	generation = gen
	notify_ghosts("A cortical borer has been created in [get_area(src)]!", enter_link = "<a href=?src=\ref[src];ghostjoin=1>(Click to enter)</a>", source = src, action = NOTIFY_ATTACK)
	real_name = "Cortical Borer [rand(1000,9999)]"
	truename = "[borer_names[min(generation, borer_names.len)]] [rand(1000,9999)]"
	borer_chems += /datum/borer_chem/epinephrine
	borer_chems += /datum/borer_chem/leporazine
	borer_chems += /datum/borer_chem/mannitol
	borer_chems += /datum/borer_chem/bicaridine
	borer_chems += /datum/borer_chem/kelotane
	borer_chems += /datum/borer_chem/charcoal
	borer_chems += /datum/borer_chem/methamphetamine
	borer_chems += /datum/borer_chem/salbutamol
	borer_chems += /datum/borer_chem/spacedrugs
	//borer_chems += /datum/borer_chem/creagent
	borer_chems += /datum/borer_chem/ethanol
	borer_chems += /datum/borer_chem/rezadone

	GLOB.borers += src

	GrantBorerActions()

/mob/living/simple_animal/borer/Destroy()
	GLOB.borers -= src

	host_brain = null
	victim = null
	
	QDEL_NULL(talk_to_host_action)
	QDEL_NULL(infest_host_action)
	QDEL_NULL(toggle_hide_action)
	QDEL_NULL(talk_to_borer_action)
	QDEL_NULL(talk_to_brain_action)
	QDEL_NULL(take_control_action)
	QDEL_NULL(give_back_control_action)
	QDEL_NULL(leave_body_action)
	QDEL_NULL(make_chems_action)
	QDEL_NULL(make_larvae_action)
	QDEL_NULL(freeze_victim_action)
	QDEL_NULL(punish_victim_action)
	QDEL_NULL(jumpstart_host_action)
	
	return ..()

/mob/living/simple_animal/borer/Topic(href, href_list)//not entirely sure if this is even required
	if(href_list["ghostjoin"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			attack_ghost(ghost)

/mob/living/simple_animal/borer/attack_ghost(mob/user)
	if(jobban_isbanned(user, ROLE_BORER) || jobban_isbanned(user, "Syndicate"))
		return
	if(key)
		return
	if(stat != CONSCIOUS)
		return
	var/be_borer = alert("Become a cortical borer? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(be_borer == "No" || !src || QDELETED(src))
		return
	if(key)
		return
	transfer_personality(user.client)

/mob/living/simple_animal/borer/Stat()
	..()

	if(statpanel("Status"))
		stat(null, "Chemicals: [chemicals]")

	src << output(chemicals, "ViewBorer\ref[src]Chems.browser:update_chemicals")

/mob/living/simple_animal/borer/verb/Communicate()
	set category = "Borer"
	set name = "Converse with Host"
	set desc = "Send a silent message to your host."

	if(!victim)
		to_chat(src, "You do not have a host to communicate with!")
		return

	if(stat)
		to_chat(src, "You cannot do that in your current state.")
		return

	var/input = stripped_input(src, "Please enter a message to tell your host.", "Borer", null)
	if(!input)
		return

	if(src && !QDELETED(src) && !QDELETED(victim))
		var/say_string = (docile) ? "slurs" :"states"
		if(victim)
			to_chat(victim, "<span class='changeling'><i>[truename] [say_string]:</i> [input]</span>")
			log_say("Borer Communication: [key_name(src)] -> [key_name(victim)] : [input]")
			for(var/M in GLOB.dead_mob_list)
				if(isobserver(M))
					var/rendered = "<span class='changeling'><i>Borer Communication from <b>[truename]</b> : [input]</i>"
					var/link = FOLLOW_LINK(M, src)
					to_chat(M, "[link] [rendered]")
		to_chat(src, "<span class='changeling'><i>[truename] [say_string]:</i> [input]</span>")
		victim.verbs += /mob/living/proc/borer_comm
		talk_to_borer_action.Grant(victim)

/mob/living/proc/borer_comm()
	set name = "Converse with Borer"
	set category = "Borer"
	set desc = "Communicate mentally with your borer."


	var/mob/living/simple_animal/borer/B = has_brain_worms()
	if(!B)
		return

	var/input = stripped_input(src, "Please enter a message to tell the borer.", "Message", null)
	if(!input)
		return

	to_chat(B, "<span class='changeling'><i>[src] says:</i> [input]</span>")
	log_say("Borer Communication: [key_name(src)] -> [key_name(B)] : [input]")

	for(var/M in GLOB.dead_mob_list)
		if(isobserver(M))
			var/rendered = "<span class='changeling'><i>Borer Communication from <b>[src]</b> : [input]</i>"
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [rendered]")
	to_chat(src, "<span class='changeling'><i>[src] says:</i> [input]</span>")

/mob/living/proc/trapped_mind_comm()
	set name = "Converse with Trapped Mind"
	set category = "Borer"
	set desc = "Communicate mentally with the trapped mind of your host."


	var/mob/living/simple_animal/borer/B = has_brain_worms()
	if(!B || !B.host_brain)
		return
	var/mob/living/captive_brain/CB = B.host_brain
	var/input = stripped_input(src, "Please enter a message to tell the trapped mind.", "Message", null)
	if(!input)
		return

	to_chat(CB, "<span class='changeling'><i>[B.truename] says:</i> [input]</span>")
	log_say("Borer Communication: [key_name(B)] -> [key_name(CB)] : [input]")

	for(var/M in GLOB.dead_mob_list)
		if(isobserver(M))
			var/rendered = "<span class='changeling'><i>Borer Communication from <b>[B]</b> : [input]</i>"
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [rendered]")
	to_chat(src, "<span class='changeling'><i>[B.truename] says:</i> [input]</span>")

/mob/living/simple_animal/borer/Life()

	..()

	if(victim)
		if(stat != DEAD)
			if(victim.stat == DEAD)
				chemicals++
			else if(chemicals < 250)
				chemicals+=2
			chemicals = min(250, chemicals)


		if(stat != DEAD && victim.stat != DEAD)

			if(victim.reagents.has_reagent("sugar"))
				if(!docile || waketimerid)
					if(controlling)
						to_chat(victim, "<span class='warning'>You feel the soporific flow of sugar in your host's blood, lulling you into docility.</span>")
					else
						to_chat(src, "<span class='warning'>You feel the soporific flow of sugar in your host's blood, lulling you into docility.</span>")
					if(waketimerid)
						deltimer(waketimerid)
						waketimerid = null
					docile = TRUE
			else
				if(docile && !waketimerid)
					if(controlling)
						to_chat(victim, "<span class='warning'>You start shaking off your lethargy as the sugar leaves your host's blood. This will take about 10 seconds...</span>")
					else
						to_chat(src, "<span class='warning'>You start shaking off your lethargy as the sugar leaves your host's blood. This will take about 10 seconds...</span>")

					waketimerid = addtimer(CALLBACK(src, "wakeup"), 10, TIMER_STOPPABLE)
			if(controlling)

				if(docile)
					to_chat(victim, "<span class='warning'>You are feeling far too docile to continue controlling your host...</span>")
					victim.release_control()
					return

				if(prob(5))
					victim.adjustBrainLoss(rand(1,2))

				if(prob(victim.brainloss/10))
					victim.say("*[pick(list("blink","blink_r","choke","aflap","drool","twitch","twitch_s","gasp"))]")

/mob/living/simple_animal/borer/proc/wakeup()
	if(controlling)
		to_chat(victim, "<span class='warning'>You finish shaking off your lethargy.</span>")
	else
		to_chat(src, "<span class='warning'>You finish shaking off your lethargy.</span>")
	docile = FALSE
	if(waketimerid)
		waketimerid = null

/mob/living/simple_animal/borer/say(message)
	if(dd_hasprefix(message, ";"))
		message = copytext(message,2)
		for(var/borer in GLOB.borers)
			to_chat(borer, "<span class='borer'>Cortical Link: [truename] sings, \"[message]\"")
		for(var/mob/D in GLOB.dead_mob_list)
			to_chat(D, "<span class='borer'>Cortical Link: [truename] sings, \"[message]\"")
		return
	if(!victim)
		to_chat(src, "<span class='warning'>You cannot speak without a host!</span>")
		return
	if(message == "")
		return

/mob/living/simple_animal/borer/UnarmedAttack(atom/A)
	if(isliving(A))
		healthscan(usr, A)
		chemscan(usr, A)

/mob/living/simple_animal/borer/ex_act()
	if(victim)
		return

	..()

/mob/living/simple_animal/borer/verb/infect_victim()
	set name = "Infest"
	set category = "Borer"
	set desc = "Infest a suitable humanoid host."

	if(victim)
		to_chat(src, "<span class='warning'>You are already within a host.</span>")

	if(stat == DEAD)
		return

	var/list/choices = list()
	for(var/mob/living/carbon/H in view(1,src))
		if(H!=src && Adjacent(H))
			choices += H

	if(!choices.len)
		return
	var/mob/living/carbon/H = choices.len > 1 ? input(src,"Who do you wish to infest?") in null|choices : choices[1]
	if(!H || !src)
		return

	if(!Adjacent(H))
		return FALSE

	if(stat != CONSCIOUS)
		to_chat(src, "<span class='warning'>You cannot do that in your current state.</span>")
		return FALSE

	if(H.has_brain_worms())
		to_chat(src, "<span class='warning'>[victim] is already infested!</span>")
		return

	to_chat(src, "<span class='warning'>You slither up [H] and begin probing at their ear canal...</span>")
	if(!do_mob(src, H, 30))
		to_chat(src, "<span class='warning'>As [H] moves away, you are dislodged and fall to the ground.</span>")
		return

	if(!H || !src)
		return

	Infect(H)

/mob/living/simple_animal/borer/proc/Infect(mob/living/carbon/C)

	if(!C)
		return

	if(C.has_brain_worms())
		to_chat(src, "<span class='warning'>[C] is already infested!</span>")
		return

	if(!C.key || !C.mind)
		to_chat(src, "<span class='warning'>[C]'s mind seems unresponsive. Try someone else!</span>")
		return

	if(C && C.dna && istype(C.dna.species, /datum/species/skeleton))
		to_chat(src, "<span class='warning'>[C] does not possess the vital systems needed to support us.</span>")
		return

	victim = C
	forceMove(victim)

	RemoveBorerActions()
	GrantInfestActions()

	log_game("[src]/([src.ckey]) has infested [victim]/([victim.ckey]")

/mob/living/simple_animal/borer/verb/secrete_chemicals()
	set category = "Borer"
	set name = "Secrete Chemicals"
	set desc = "Push some chemicals into your host's bloodstream."

	if(!victim)
		to_chat(src, "<span class='warning'>You are not inside a host body.</span>")
		return

	if(stat != CONSCIOUS)
		to_chat(src, "<span class='warning'>You cannot secrete chemicals in your current state.</span>")

	if(docile)
		to_chat(src, "<span class='warning'>You are feeling far too docile to do that.</span>")
		return

	var content = ""
	content += "<p>Chemicals: <span id='chemicals'>[chemicals]</span></p>"

	content += "<table>"

	for(var/datum in typesof(/datum/borer_chem))
		var/datum/borer_chem/C = new datum()
		if(C.chemname)
			content += "<tr><td><a class='chem-select' href='?_src_=\ref[src];src=\ref[src];borer_use_chem=[C.chemname]'>[C.chemname] ([C.chemuse])</a><p>[C.chem_desc]</p></td></tr>"

	content += "</table>"

	var/html = get_html_template(content)

	usr << browse(null, "window=ViewBorer\ref[src]Chems;size=600x800")
	usr << browse(html, "window=ViewBorer\ref[src]Chems;size=600x800")

	return

/mob/living/simple_animal/borer/verb/hide()
	set category = "Borer"
	set name = "Hide"
	set desc = "Become invisible to the common eye."

	if(victim)
		to_chat(src, "<span class='warning'>You cannot do this while you're inside a host.</span>")

	if(stat != CONSCIOUS)
		return

	if(!hiding)
		layer = LATTICE_LAYER
		visible_message("<span class='name'>[src] scurries to the ground!</span>", \
						"<span class='noticealien'>You are now hiding.</span>")
		hiding = TRUE
	else
		layer = MOB_LAYER
		visible_message("[src] slowly peaks up from the ground...", \
					"<span class='noticealien'>You stop hiding.</span>")
		hiding = FALSE

/mob/living/simple_animal/borer/verb/dominate_victim()
	set category = "Borer"
	set name = "Paralyze Victim"
	set desc = "Freeze the limbs of a potential host with supernatural fear."

	if(world.time - used_dominate < 150)
		to_chat(src, "<span class='warning'>You cannot use that ability again so soon.</span>")
		return

	if(victim)
		to_chat(src, "<span class='warning'>You cannot do that from within a host body.</span>")
		return

	if(stat != CONSCIOUS)
		to_chat(src, "<span class='warning'>You cannot do that in your current state.</span>")
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(1,src))
		if(C.stat == CONSCIOUS)
			choices += C
			
	if(!choices.len)
		return
	var/mob/living/carbon/M = choices.len > 1 ? input(src,"Who do you wish to dominate?") in null|choices : choices[1]


	if(!M || !src || stat != CONSCIOUS || victim || (world.time - used_dominate < 150))
		return
	if(!Adjacent(M))
		return

	if(M.has_brain_worms())
		to_chat(src, "<span class='warning'>You cannot paralyze someone who is already infested!</span>")
		return

	layer = MOB_LAYER

	to_chat(src, "<span class='warning'>You focus your psychic lance on [M] and freeze their limbs with a wave of terrible dread.</span>")
	to_chat(M, "<span class='userdanger'>You feel a creeping, horrible sense of dread come over you, freezing your limbs and setting your heart racing.</span>")
	M.Stun(3)

	used_dominate = world.time

/mob/living/simple_animal/borer/verb/release_victim()
	set category = "Borer"
	set name = "Release Host"
	set desc = "Slither out of your host."

	if(!victim)
		to_chat(src, "<span class='userdanger'>You are not inside a host body.</span>")
		return

	if(stat != CONSCIOUS)
		to_chat(src, "<span class='userdanger'>You cannot leave your host in your current state.</span>")

	if(leaving)
		leaving = FALSE
		to_chat(src, "<span class='userdanger'>You decide against leaving your host.</span>")
		return

	to_chat(src, "<span class='userdanger'>You begin disconnecting from [victim]'s synapses and prodding at their internal ear canal.</span>")

	if(victim.stat != DEAD)
		to_chat(victim, "<span class='userdanger'>An odd, uncomfortable pressure begins to build inside your skull, behind your ear...</span>")

	leaving = TRUE

	addtimer(CALLBACK(src, .proc/release_host), 100)

/mob/living/simple_animal/borer/proc/release_host()
	if(!victim || !src || QDELETED(victim) || QDELETED(src))
		return
	if(!leaving)
		return
	if(controlling)
		return

	if(stat != CONSCIOUS)
		to_chat(src, "<span class='userdanger'>You cannot release your host in your current state.</span>")
		return

	to_chat(src, "<span class='userdanger'>You wiggle out of [victim]'s ear and plop to the ground.</span>")
	if(victim.mind)
		to_chat(victim, "<span class='danger'>Something slimy wiggles out of your ear and plops to the ground!</span>")
		to_chat(victim, "<span class='danger'>As though waking from a dream, you shake off the insidious mind control of the brain worm. Your thoughts are your own again.</span>")

	leaving = FALSE

	leave_victim()

/mob/living/simple_animal/borer/proc/leave_victim()
	if(!victim)
		return

	if(controlling)
		detatch()

	GrantBorerActions()
	RemoveInfestActions()

	forceMove(get_turf(victim))

	reset_perspective(null)
	machine = null

	victim.reset_perspective(null)
	victim.machine = null

	var/mob/living/V = victim
	V.verbs -= /mob/living/proc/borer_comm
	talk_to_borer_action.Remove(victim)
	victim = null
	return

/mob/living/simple_animal/borer/verb/jumpstart()
	set category = "Borer"
	set name = "Jumpstart Host"
	set desc = "Bring your host back to life."

	if(!victim)
		to_chat(src, "<span class='warning'>You need a host to be able to use this.</span>")
		return

	if(docile)
		to_chat(src, "<span class='warning'>You are feeling too docile to use this!</span>")
		return

	if(victim.stat != DEAD)
		to_chat(src, "<span class='warning'>Your host is already alive!</span>")
		return

	if(chemicals < 250)
		to_chat(src, "<span class='warning'>You need 250 chemicals to use this!</span>")
		return

	if(victim.stat == DEAD)
		victim.tod = null
		victim.setToxLoss(0)
		victim.setOxyLoss(0)
		victim.setCloneLoss(0)
		victim.SetParalysis(0)
		victim.SetStunned(0)
		victim.SetWeakened(0)
		victim.radiation = 0
		victim.heal_overall_damage(victim.getBruteLoss(), victim.getFireLoss())
		victim.reagents.clear_reagents()
		if(ishuman(victim))
			var/mob/living/carbon/human/H = victim
			H.restore_blood()
			H.remove_all_embedded_objects()
		victim.revive()
		log_game("[src]/([src.ckey]) has revived [victim]/([victim.ckey]")
		chemicals -= 250
		to_chat(src, "<span class='notice'>You send a jolt of energy to your host, reviving them!</span>")
		victim.grab_ghost(force = TRUE) //brings the host back, no eggscape
		to_chat(victim, "<span class='notice'>You bolt upright, gasping for breath!</span>")

/mob/living/simple_animal/borer/verb/bond_brain()
	set category = "Borer"
	set name = "Assume Control"
	set desc = "Fully connect to the brain of your host."

	if(!victim)
		to_chat(src, "<span class='warning'>You are not inside a host body.</span>")
		return

	if(stat != CONSCIOUS)
		to_chat(src, "You cannot do that in your current state.")
		return

	if(docile)
		to_chat(src, "<span class='warning'>You are feeling far too docile to do that.</span>")
		return

	if(victim.stat == DEAD)
		to_chat(src, "<span class='warning'>This host lacks enough brain function to control.</span>")
		return

	if(bonding)
		bonding = FALSE
		to_chat(src, "<span class='userdanger'>You stop attempting to take control of your host.</span>")
		return

	to_chat(src, "<span class='danger'>You begin delicately adjusting your connection to the host brain...</span>")

	if(QDELETED(src) || QDELETED(victim))
		return

	bonding = TRUE

	var/delay = 200+(victim.brainloss*5)
	addtimer(CALLBACK(src, .proc/assume_control), delay)

/mob/living/simple_animal/borer/proc/assume_control()
	if(!victim || !src || controlling || victim.stat == DEAD)
		return
	if(!bonding)
		return
	if(docile)
		to_chat(src, "<span class='warning'>You are feeling far too docile to do that.</span>")
		return
	if(is_servant_of_ratvar(victim) || iscultist(victim) || victim.isloyal())
		to_chat(src, "<span class='warning'>[victim]'s mind seems to be blocked by some unknown force!</span>")
		return

	else

		log_game("[src]/([src.ckey]) assumed control of [victim]/([victim.ckey] with borer powers.")
		to_chat(src, "<span class='warning'>You plunge your probosci deep into the cortex of the host brain, interfacing directly with their nervous system.</span>")
		to_chat(victim, "<span class='userdanger'>You feel a strange shifting sensation behind your eyes as an alien consciousness displaces yours.</span>")

		// host -> brain
		var/h2b_id = victim.computer_id
		var/h2b_ip= victim.lastKnownIP
		victim.computer_id = null
		victim.lastKnownIP = null

		qdel(host_brain)
		host_brain = new(src)

		host_brain.ckey = victim.ckey

		host_brain.name = victim.name

		if(victim.mind)
			host_brain.mind = victim.mind

		if(!host_brain.computer_id)
			host_brain.computer_id = h2b_id

		if(!host_brain.lastKnownIP)
			host_brain.lastKnownIP = h2b_ip

		to_chat(host_brain, "You are trapped in your own mind. You feel that there must be a way to resist!")

		// self -> host
		var/s2h_id = src.computer_id
		var/s2h_ip= src.lastKnownIP
		src.computer_id = null
		src.lastKnownIP = null

		victim.ckey = src.ckey
		victim.mind = src.mind

		if(!victim.computer_id)
			victim.computer_id = s2h_id

		if(!victim.lastKnownIP)
			victim.lastKnownIP = s2h_ip

		bonding = FALSE
		controlling = TRUE

		victim.verbs += /mob/living/carbon/proc/release_control
		victim.verbs += /mob/living/carbon/proc/spawn_larvae
		victim.verbs -= /mob/living/proc/borer_comm
		victim.verbs += /mob/living/proc/trapped_mind_comm
		GrantControlActions()
		talk_to_borer_action.Remove(victim)

		victim.med_hud_set_status()

/mob/living/simple_animal/borer/verb/punish()
	set category = "Borer"
	set name = "Punish"
	set desc = "Punish your victim."

	if(!victim)
		to_chat(src, "<span class='warning'>You are not inside a host body.</span>")
		return

	if(stat != CONSCIOUS)
		to_chat(src, "You cannot do that in your current state.")
		return

	if(docile)
		to_chat(src, "<span class='warning'>You are feeling far too docile to do that.</span>")
		return

	if(chemicals < 75)
		to_chat(src, "<span class='warning'>You need 75 chems to punish your host.</span>")
		return

	var/punishment = input("Select a punishment:.", "Punish") as null|anything in list("Blindness","Deafness","Stun")

	if(!punishment)
		return

	if(chemicals < 75)
		to_chat(src, "<span class='warning'>You need 75 chems to punish your host.</span>")
		return

	switch(punishment) //Hardcoding this stuff.
		if("Blindness")
			victim.blind_eyes(2)
		if("Deafness")
			victim.minimumDeafTicks(20)
		if("Stun")
			victim.Weaken(10)

	log_game("[src]/([src.ckey]) punished [victim]/([victim.ckey] with [punishment]")

	chemicals -= 75


/mob/living/carbon/proc/release_control()

	set category = "Borer"
	set name = "Release Control"
	set desc = "Release control of your host's body."

	var/mob/living/simple_animal/borer/B = has_brain_worms()
	if(B && B.host_brain)
		to_chat(src, "<span class='danger'>You withdraw your probosci, releasing control of [B.host_brain]</span>")

		B.detatch()

//Check for brain worms in head.
/mob/proc/has_brain_worms()

	for(var/I in contents)
		if(isborer(I))
			return I

	return FALSE

/mob/living/carbon/proc/spawn_larvae()
	set category = "Borer"
	set name = "Reproduce"
	set desc = "Spawn several young."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(isbrain(src))
		to_chat(src, "<span class='usernotice'>You need a mouth to be able to do this.</span>")
		return
	if(!B)
		return

	if(B.chemicals >= 200)
		visible_message("<span class='danger'>[src] heaves violently, expelling a rush of vomit and a wriggling, sluglike creature!</span>")
		B.chemicals -= 200

		new /obj/effect/decal/cleanable/vomit(get_turf(src))
		playsound(loc, 'sound/effects/splat.ogg', 50, 1)
		new /mob/living/simple_animal/borer(get_turf(src), B.generation + 1)
		log_game("[src]/([src.ckey]) has spawned a new borer via reproducing.")
	else
		to_chat(src, "<span class='warning'>You need 200 chemicals stored to reproduce.</span>")
		return


/mob/living/simple_animal/borer/proc/transfer_personality(var/client/candidate)
	if(!candidate || !candidate.mob)
		return

	if(!QDELETED(candidate) || !QDELETED(candidate.mob))
		var/datum/mind/M = create_borer_mind(candidate.ckey)
		M.transfer_to(src)

		candidate.mob = src
		ckey = candidate.ckey

		if(mind)
			mind.store_memory("You must escape with at least [GLOB.total_borer_hosts_needed] borers with hosts on the shuttle.")

		to_chat(src, "<span class='notice'>You are a cortical borer!</span>")
		to_chat(src, "You are a brain slug that worms its way into the head of its victim. Use stealth, persuasion and your powers of mind control to keep you, your host and your eventual spawn safe and warm.")
		to_chat(src, "Sugar nullifies your abilities, avoid it at all costs!")
		to_chat(src, "You can speak to your fellow borers by prefixing your messages with ';'. Check out your Borer tab to see your abilities.")
		to_chat(src, "You must escape with at least [GLOB.total_borer_hosts_needed] borers with hosts on the shuttle. To reproduce you must have 100 chemicals and be controlling a host.")

/mob/living/simple_animal/borer/proc/detatch()
	if(!victim || !controlling)
		return

	controlling = FALSE

	victim.verbs -= /mob/living/carbon/proc/release_control
	victim.verbs -= /mob/living/carbon/proc/spawn_larvae
	victim.verbs += /mob/living/proc/borer_comm
	victim.verbs -= /mob/living/proc/trapped_mind_comm
	RemoveControlActions()
	talk_to_borer_action.Grant(victim)

	victim.med_hud_set_status()

	if(host_brain)

		// these are here so bans and multikey warnings are not triggered on the wrong people when ckey is changed.
		// computer_id and IP are not updated magically on their own in offline mobs -walter0o

		// host -> self
		var/h2s_id = victim.computer_id
		var/h2s_ip= victim.lastKnownIP
		victim.computer_id = null
		victim.lastKnownIP = null

		ckey = victim.ckey
		mind = victim.mind


		if(!computer_id)
			computer_id = h2s_id

		if(!host_brain.lastKnownIP)
			lastKnownIP = h2s_ip

		// brain -> host
		var/b2h_id = host_brain.computer_id
		var/b2h_ip= host_brain.lastKnownIP
		host_brain.computer_id = null
		host_brain.lastKnownIP = null

		victim.ckey = host_brain.ckey

		victim.mind = host_brain.mind

		if(!victim.computer_id)
			victim.computer_id = b2h_id

		if(!victim.lastKnownIP)
			victim.lastKnownIP = b2h_ip

	log_game("[src]/([src.ckey]) released control of [victim]/([victim.ckey]")

	qdel(host_brain)

/proc/create_borer_mind(key)
	var/datum/mind/M = new /datum/mind(key)
	M.assigned_role = "Cortical Borer"
	M.special_role = "Cortical Borer"
	return M

/mob/living/simple_animal/borer/proc/GrantBorerActions()
	infest_host_action.Grant(src)
	toggle_hide_action.Grant(src)
	freeze_victim_action.Grant(src)

/mob/living/simple_animal/borer/proc/RemoveBorerActions()
	infest_host_action.Remove(src)
	toggle_hide_action.Remove(src)
	freeze_victim_action.Remove(src)

/mob/living/simple_animal/borer/proc/GrantInfestActions()
	talk_to_host_action.Grant(src)
	leave_body_action.Grant(src)
	take_control_action.Grant(src)
	punish_victim_action.Grant(src)
	make_chems_action.Grant(src)
	jumpstart_host_action.Grant(src)

/mob/living/simple_animal/borer/proc/RemoveInfestActions()
	talk_to_host_action.Remove(src)
	take_control_action.Remove(src)
	leave_body_action.Remove(src)
	punish_victim_action.Remove(src)
	make_chems_action.Remove(src)
	jumpstart_host_action.Remove(src)

/mob/living/simple_animal/borer/proc/GrantControlActions()
	talk_to_brain_action.Grant(victim)
	give_back_control_action.Grant(victim)
	make_larvae_action.Grant(victim)

/mob/living/simple_animal/borer/proc/RemoveControlActions()
	talk_to_brain_action.Remove(victim)
	make_larvae_action.Remove(victim)
	give_back_control_action.Remove(victim)

/datum/action/innate/borer
	background_icon_state = "bg_alien"

/datum/action/innate/borer/talk_to_host
	name = "Converse with Host"
	desc = "Send a silent message to your host."
	button_icon_state = "alien_whisper"

/datum/action/innate/borer/talk_to_host/Activate()
	var/mob/living/simple_animal/borer/B = owner
	B.Communicate()

/datum/action/innate/borer/infest_host
	name = "Infest"
	desc = "Infest a suitable humanoid host."
	button_icon_state = "infest"

/datum/action/innate/borer/infest_host/Activate()
	var/mob/living/simple_animal/borer/B = owner
	B.infect_victim()

/datum/action/innate/borer/toggle_hide
	name = "Toggle Hide"
	desc = "Become invisible to the common eye. Toggled on or off."
	button_icon_state = "borer_hiding_false"

/datum/action/innate/borer/toggle_hide/Activate()
	var/mob/living/simple_animal/borer/B = owner
	B.hide()
	button_icon_state = "borer_hiding_[B.hiding ? "true" : "false"]"
	UpdateButtonIcon()

/datum/action/innate/borer/talk_to_borer
	name = "Converse with Borer"
	desc = "Communicate mentally with your borer."
	button_icon_state = "alien_whisper"

/datum/action/innate/borer/talk_to_borer/Activate()
	var/mob/living/simple_animal/borer/B = owner.has_brain_worms()
	B.victim = owner
	B.victim.borer_comm()


/datum/action/innate/borer/talk_to_brain
	name = "Converse with Trapped Mind"
	desc = "Communicate mentally with the trapped mind of your host."
	button_icon_state = "alien_whisper"

/datum/action/innate/borer/talk_to_brain/Activate()
	var/mob/living/simple_animal/borer/B = owner.has_brain_worms()
	B.victim = owner
	B.victim.trapped_mind_comm()

/datum/action/innate/borer/take_control
	name = "Assume Control"
	desc = "Fully connect to the brain of your host."
	button_icon_state = "borer_brain"

/datum/action/innate/borer/take_control/Activate()
	var/mob/living/simple_animal/borer/B = owner
	B.bond_brain()

/datum/action/innate/borer/give_back_control
	name = "Release Control"
	desc = "Release control of your host's body."
	button_icon_state = "borer_leave"

/datum/action/innate/borer/give_back_control/Activate()
	var/mob/living/simple_animal/borer/B = owner.has_brain_worms()
	B.victim = owner
	B.victim.release_control()

/datum/action/innate/borer/leave_body
	name = "Release Host"
	desc = "Slither out of your host."
	button_icon_state = "borer_leave"

/datum/action/innate/borer/leave_body/Activate()
	var/mob/living/simple_animal/borer/B = owner
	B.release_victim()

/datum/action/innate/borer/make_chems
	name = "Secrete Chemicals"
	desc = "Push some chemicals into your host's bloodstream."
	icon_icon = 'icons/obj/chemical.dmi'
	button_icon_state = "minidispenser"

/datum/action/innate/borer/make_chems/Activate()
	var/mob/living/simple_animal/borer/B = owner
	B.secrete_chemicals()

/datum/action/innate/borer/make_larvae
	name = "Reproduce"
	desc = "Spawn several young."
	button_icon_state = "borer_reproduce"

/datum/action/innate/borer/make_larvae/Activate()
	var/mob/living/simple_animal/borer/B = owner.has_brain_worms()
	B.victim = owner
	B.victim.spawn_larvae()

/datum/action/innate/borer/freeze_victim
	name = "Paralyze Victim"
	desc = "Freeze the limbs of a potential host with supernatural fear."
	button_icon_state = "freeze"

/datum/action/innate/borer/freeze_victim/Activate()
	var/mob/living/simple_animal/borer/B = owner
	B.dominate_victim()

/datum/action/innate/borer/punish_victim
	name = "Punish"
	desc = "Punish your victim."
	button_icon_state = "blind"

/datum/action/innate/borer/punish_victim/Activate()
	var/mob/living/simple_animal/borer/B = owner
	B.punish()

/datum/action/innate/borer/jumpstart_host
	name = "Jumpstart Host"
	desc = "Bring your host back to life."
	icon_icon = 'icons/obj/weapons.dmi'
	button_icon_state = "defibpaddles0"

/datum/action/innate/borer/jumpstart_host/Activate()
	var/mob/living/simple_animal/borer/B = owner
	B.jumpstart()
