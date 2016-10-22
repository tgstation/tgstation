/mob/living/captive_brain
	name = "host brain"
	real_name = "host brain"

/mob/living/captive_brain/say(var/message)

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			src << "\red You cannot speak in IC (muted)."
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if(istype(src.loc,/mob/living/simple_animal/borer))

		message = sanitize(message)
		if (!message)
			return
		log_say("[key_name(src)] : [message]")
		if (stat == 2)
			return say_dead(message)

		var/mob/living/simple_animal/borer/B = src.loc
		src << "You whisper silently, \"[message]\""
		B.victim << "The captive mind of [src] whispers, \"[message]\""

		for (var/mob/M in player_list)
			if (istype(M, /mob/new_player))
				continue
			else if(M.stat == 2 &&  M.client.prefs.toggles & CHAT_GHOSTEARS)
				M << "<i>Thought-speech, <b>[src]</b> -> <b>[B.truename]:</b> [message]</i>"

/mob/living/captive_brain/emote(var/message)
	return

/mob/living/captive_brain/resist()

	var/mob/living/simple_animal/borer/B = src.loc

	src << "<span class='danger'>You begin doggedly resisting the parasite's control (this will take approximately 20 seconds).</span>"
	B.victim << "<span class='danger'>You feel the captive mind of [src] begin to resist your control.</span>"

	spawn(rand(150,220) + B.victim.brainloss)

		if(!B || !B.controlling)
			return

		B.victim.adjustBrainLoss(rand(5,10))
		src << "<span class='danger'>With an immense exertion of will, you regain control of your body!</span>"
		B.victim << "<span class='danger'>You feel control of the host brain ripped from your grasp, and retract your probosci before the wild neural impulses can damage you.</span>"

		B.detatch()

		verbs -= /mob/living/carbon/proc/release_control
		verbs -= /mob/living/carbon/proc/spawn_larvae

var/list/mob/living/simple_animal/borer/borers = list()
var/total_borer_hosts_needed = 10

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
	attacktext = "chomps"
	attack_sound = 'sound/weapons/bite.ogg'
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	faction = list("creature")
	ventcrawler = 2
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
	var/docile = 0
	var/controlling = 0
	var/chemicals = 10
	var/used_dominate
	var/borer_chems = list()
	var/dominate_cooldown = 150
	var/leaving = 0

/mob/living/simple_animal/borer/New(atom/newloc, var/gen=1)
	..(newloc)
	generation = gen
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

	borers += src

/mob/living/simple_animal/borer/attack_ghost(mob/user)
	if(ckey)
		return
	if(stat != CONSCIOUS)
		return
	var/be_swarmer = alert("Become a cortical borer? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(be_swarmer == "No")
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
		src << "You do not have a host to communicate with!"
		return

	if(stat)
		src << "You cannot do that in your current state."
		return

	var/input = stripped_input(src, "Please enter a message to tell your host.", "Borer", null)
	if(!input) return


	var/say_string = (docile) ? "slurs" :"states"
	if(victim)
		victim << "<span class='changeling'><i>[src.truename] [say_string]:</i> [input]</span>"
		log_say("Borer Communication: [key_name(src)] -> [key_name(victim)] : [input]")
		for(var/M in dead_mob_list)
			if(istype(M, /mob/dead/observer))
				var/rendered = "<span class='changeling'><i>Borer Communication from <b>[src.truename]</b> : [input]</i>"
				var/link = FOLLOW_LINK(M, src)
				M << "[link] [rendered]"
	src << "<span class='changeling'><i>[src.truename] [say_string]:</i> [input]</span>"
	victim.verbs += /mob/living/proc/borer_comm

/mob/living/proc/borer_comm()
	set name = "Converse with Borer"
	set category = "Borer"
	set desc = "Communicate mentally with your borer."


	var/mob/living/simple_animal/borer/B = src.has_brain_worms()
	if(!B)
		return

	var/input = stripped_input(src, "Please enter a message to tell the borer.", "Message", null)
	if(!input) return

	B << "<span class='changeling'><i>[src] says:</i> [input]</span>"
	log_say("Borer Communication: [key_name(src)] -> [key_name(B)] : [input]")

	for(var/M in dead_mob_list)
		if(istype(M, /mob/dead/observer))
			var/rendered = "<span class='changeling'><i>Borer Communication from <b>[src]</b> : [input]</i>"
			var/link = FOLLOW_LINK(M, src)
			M << "[link] [rendered]"
	src << "<span class='changeling'><i>[src] says:</i> [input]</span>"

/mob/living/proc/trapped_mind_comm()
	set name = "Converse with Trapped Mind"
	set category = "Borer"
	set desc = "Communicate mentally with the trapped mind of your host."


	var/mob/living/simple_animal/borer/B = src.has_brain_worms()
	if(!B || !B.host_brain)
		return
	var/mob/living/captive_brain/CB = B.host_brain
	var/input = stripped_input(src, "Please enter a message to tell the trapped mind.", "Message", null)
	if(!input) return

	CB << "<span class='changeling'><i>[B.truename] says:</i> [input]</span>"
	log_say("Borer Communication: [key_name(B)] -> [key_name(CB)] : [input]")

	for(var/M in dead_mob_list)
		if(istype(M, /mob/dead/observer))
			var/rendered = "<span class='changeling'><i>Borer Communication from <b>[B]</b> : [input]</i>"
			var/link = FOLLOW_LINK(M, src)
			M << "[link] [rendered]"
	src << "<span class='changeling'><i>[B.truename] says:</i> [input]</span>"

/mob/living/simple_animal/borer/Life()

	..()

	if(victim)
		if(stat != DEAD)
			if(victim.stat == DEAD)
				chemicals++
			else if(chemicals < 250)
				chemicals+=2
			if (chemicals > 250)
				chemicals = 250 //to prevent 251 chemical bug from +2 per tick


		if(stat != DEAD && victim.stat != DEAD)

			if(victim.reagents.has_reagent("sugar"))
				if(!docile)
					if(controlling)
						victim << "<span class='warning'>You feel the soporific flow of sugar in your host's blood, lulling you into docility.</span>"
					else
						src << "<span class='warning'>You feel the soporific flow of sugar in your host's blood, lulling you into docility.</span>"
					docile = 1
			else
				if(docile)
					if(controlling)
						victim << "<span class='warning'>You shake off your lethargy as the sugar leaves your host's blood.</span>"
					else
						src << "<span class='warning'>You shake off your lethargy as the sugar leaves your host's blood.</span>"
					docile = 0
			if(controlling)

				if(docile)
					victim << "<span class='warning'>You are feeling far too docile to continue controlling your host...</span>"
					victim.release_control()
					return

				if(prob(5))
					victim.adjustBrainLoss(rand(1,2))

				if(prob(victim.brainloss/20))
					victim.say("*[pick(list("blink","blink_r","choke","aflap","drool","twitch","twitch_s","gasp"))]")

/mob/living/simple_animal/borer/say(message)
	if(dd_hasprefix(message, ";"))
		message = copytext(message,2)
		for(var/borer in borers)
			borer << "<span class='borer'>Cortical Link: [truename] sings, \"[message]\""
		for(var/mob/dead in dead_mob_list)
			dead << "<span class='borer'>Cortical Link: [truename] sings, \"[message]\""
		return
	if(!victim)
		src << "<span class='warning'>You cannot speak without a host!</span>"
		return
	if(message == "")
		return

/mob/living/simple_animal/borer/UnarmedAttack(mob/living/M)
	healthscan(usr, M)
	chemscan(usr, M)
	return

/mob/living/simple_animal/borer/ex_act()
	if(victim)
		return

	..()

/mob/living/simple_animal/borer/proc/Infect(mob/living/carbon/victim)
	if(!victim)
		return

	if(victim.borer)
		src << "<span class='warning'>[victim] is already infested!</span>"
		return

	if(!victim.key || !victim.mind)
		src << "<span class='warning'>[victim]'s mind seems unresponsive. Try someone else!</span>"
		return

	if (victim && victim.dna && istype(victim.dna.species, /datum/species/skeleton))
		src << "<span class='warning'>[victim] does not possess the vital systems needed to support us.</span>"
		return

	src.victim = victim
	victim.borer = src
	src.forceMove(victim)

	log_game("[src]/([src.ckey]) has infested [victim]/([victim.ckey]")

/mob/living/simple_animal/borer/proc/leave_victim()
	if(!victim)
		return

	if(controlling)
		detatch()

	src.forceMove(get_turf(victim))

	victim.borer = null
	reset_perspective(null)

	var/mob/living/V = victim
	V.verbs -= /mob/living/proc/borer_comm
	victim = null
	return

/mob/living/simple_animal/borer/verb/infect_victim()
	set name = "Infest"
	set category = "Borer"
	set desc = "Infest a suitable humanoid host."

	if(victim)
		src << "<span class='warning'>You are already within a host.</span>"

	if(stat == DEAD)
		return

	var/list/choices = list()
	for(var/mob/living/carbon/H in view(1,src))
		if(H!=src && Adjacent(H))
			choices += H

	var/mob/living/carbon/human/H = input(src,"Who do you wish to infest?") in null|choices
	if(!H) return

	if(H.has_brain_worms())
		src << "<span class='warning'>[victim] is already infested!</span>"
		return

	if(CanInfect(H))
		src << "<span class='warning'>You slither up [H] and begin probing at their ear canal...</span>"
		src.layer = MOB_LAYER
		if(!do_mob(src, H, 30))
			src << "<span class='warning'>As [H] moves away, you are dislodged and fall to the ground.</span>"
			return

		if(!H || !src) return

		Infect(H)

/mob/living/simple_animal/borer/proc/CanInfect(var/mob/living/carbon/human/H)
	if(!Adjacent(H))
		return 0

	if(stat != CONSCIOUS)
		src << "<span class='warning'>You cannot do that in your current state.</span>"
		return 0

	return 1

/mob/living/simple_animal/borer/verb/secrete_chemicals()
	set category = "Borer"
	set name = "Secrete Chemicals"
	set desc = "Push some chemicals into your host's bloodstream."

	if(!victim)
		src << "<span class='warning'>You are not inside a host body.</span>"
		return

	if(stat != CONSCIOUS)
		src << "<span class='warning'>You cannot secrete chemicals in your current state.</span>"

	if(docile)
		src << "<span class='warning'>You are feeling far too docile to do that.</span>"
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
		src << "<span class='warning'>You cannot do this whilst you are infesting a host</span>"

	if(src.stat != CONSCIOUS)
		return

	if (src.layer != TURF_LAYER+0.2)
		src.layer = TURF_LAYER+0.2
		src.visible_message("<span class='name'>[src] scurries to the ground!</span>", \
						"<span class='noticealien'>You are now hiding.</span>")
	else
		src.layer = MOB_LAYER
		src.visible_message("[src] slowly peaks up from the ground...", \
					"<span class='noticealien'>You stop hiding.</span>")

/mob/living/simple_animal/borer/verb/dominate_victim()
	set category = "Borer"
	set name = "Paralyze Victim"
	set desc = "Freeze the limbs of a potential host with supernatural fear."

	if(world.time - used_dominate < 150)
		src << "<span class='warning'>You cannot use that ability again so soon.</span>"
		return

	if(victim)
		src << "<span class='warning'>You cannot do that from within a host body.</span>"
		return

	if(src.stat != CONSCIOUS)
		src << "<span class='warning'>You cannot do that in your current state.</span>"
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(1,src))
		if(C.stat == CONSCIOUS)
			choices += C

	if(world.time - used_dominate < dominate_cooldown)
		src << "<span class='warning'>You cannot use that ability again so soon.</span>"
		return

	var/mob/living/carbon/M = input(src,"Who do you wish to dominate?") in null|choices


	if(!M || !src) return
	if(!Adjacent(M)) return

	if(M.borer)
		src << "<span class='warning'>You cannot paralyze someone who is already infested!</span>"
		return

	src.layer = MOB_LAYER

	src << "<span class='warning'>You focus your psychic lance on [M] and freeze their limbs with a wave of terrible dread.</span>"
	M << "<span class='userdanger'>You feel a creeping, horrible sense of dread come over you, freezing your limbs and setting your heart racing.</span>"
	M.Stun(4)

	used_dominate = world.time

/mob/living/simple_animal/borer/verb/release_victim()
	set category = "Borer"
	set name = "Release Host"
	set desc = "Slither out of your host."

	if(!victim)
		src << "<span class='userdanger'>You are not inside a host body.</span>"
		return

	if(stat != CONSCIOUS)
		src << "<span class='userdanger'>You cannot leave your host in your current state.</span>"

	if(!victim || !src) return

	if(leaving)
		leaving = 0
		src << "<span class='userdanger'>You decide against leaving your host.</span>"
		return

	src << "<span class='userdanger'>You begin disconnecting from [victim]'s synapses and prodding at their internal ear canal.</span>"

	if(victim.stat != DEAD)
		host << "<span class='userdanger'>An odd, uncomfortable pressure begins to build inside your skull, behind your ear...</span>"

	leaving = 1

	spawn(100)

		if(!victim || !src) return
		if(!leaving) return
		if(controlling) return

		if(src.stat != CONSCIOUS)
			src << "<span class='userdanger'>You cannot release your host in your current state.</span>"
			return

		src << "<span class='userdanger'>You wiggle out of [victim]'s ear and plop to the ground.</span>"
		if(victim.mind)
			host << "<span class='danger'>Something slimy wiggles out of your ear and plops to the ground!</span>"
			host << "<span class='danger'>As though waking from a dream, you shake off the insidious mind control of the brain worm. Your thoughts are your own again.</span>"

		leave_victim()


/mob/living/simple_animal/borer/verb/jumpstart()
	set category = "Borer"
	set name = "Jumpstart Host"
	set desc = "Brings your host back from the dead."

	if(!victim)
		src << "<span class='warning'>You need a host to be able to use this.</span>"
		return

	if(docile)
		src << "<span class='warning'>You are feeling too docile to use this!</span>"
		return

	if(chemicals < 250)
		src << "<span class='warning'>You need 250 chemicals to use this!</span>"
		return

	if(victim.stat == DEAD)
		dead_mob_list -= victim
		living_mob_list += victim
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
		if(istype(victim,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = victim
			H.restore_blood()
			H.remove_all_embedded_objects()
		victim.update_canmove()
		victim.med_hud_set_status()
		victim.med_hud_set_health()
		victim.stat = CONSCIOUS
		log_game("[src]/([src.ckey]) has revived [victim]/([victim.ckey]")
		chemicals -= 250
		src << "<span class='notice'>You send a jolt of energy to your host, reviving them!</span>"
		victim.grab_ghost(force = TRUE) //brings the host back, no eggscape
		victim <<"<span class='notice'>You bolt upright, gasping for breath!</span>"

/mob/living/simple_animal/borer/verb/bond_brain()
	set category = "Borer"
	set name = "Assume Control"
	set desc = "Fully connect to the brain of your host."

	if(!victim)
		src << "<span class='warning'>You are not inside a host body.</span>"
		return

	if(src.stat != CONSCIOUS)
		src << "You cannot do that in your current state."
		return

	if(docile)
		src << "<span class='warning'>You are feeling far too docile to do that.</span>"
		return

	if(victim.stat == DEAD)
		src << "<span class='warning'>This host lacks enough brain function to control.</span>"
		return

	src << "<span class='danger'>You begin delicately adjusting your connection to the host brain...</span>"

	spawn(200+(victim.brainloss*5))

		if(!victim || !src || controlling || victim.stat == DEAD)
			return
		if(docile)
			src <<"<span class='warning'>You are feeling far too docile to do that.</span>"
			return
		else


			log_game("[src]/([src.ckey]) assumed control of [victim]/([victim.ckey] with borer powers.")
			src << "<span class='warning'>You plunge your probosci deep into the cortex of the host brain, interfacing directly with their nervous system.</span>"
			victim << "<span class='userdanger'>You feel a strange shifting sensation behind your eyes as an alien consciousness displaces yours.</span>"

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

			controlling = 1

			victim.verbs += /mob/living/carbon/proc/release_control
			victim.verbs += /mob/living/carbon/proc/spawn_larvae
			victim.verbs -= /mob/living/proc/borer_comm
			victim.verbs += /mob/living/proc/trapped_mind_comm

			victim.med_hud_set_status()

/mob/living/simple_animal/borer/verb/punish()
	set category = "Borer"
	set name = "Punish"
	set desc = "Punish your victim."

	if(!victim)
		src << "<span class='warning'>You are not inside a host body.</span>"
		return

	if(src.stat != CONSCIOUS)
		src << "You cannot do that in your current state."
		return

	if(docile)
		src << "<span class='warning'>You are feeling far too docile to do that.</span>"
		return

	if(chemicals < 75)
		src << "<span class='warning'>You need 75 chems to punish your host.</span>"
		return

	var/punishment = input("Select a punishment:.", "Punish") as null|anything in list("Blindness","Deafness","Stun")

	if(!punishment)
		return

	if(chemicals < 75)
		src << "<span class='warning'>You need 75 chems to punish your host.</span>"
		return

	switch(punishment) //Hardcoding this stuff.
		if("Blindness")
			victim.blind_eyes(2)
		if("Deafness")
			victim.ear_deaf = 20
		if("Stun")
			victim.Weaken(10)

	log_game("[src]/([src.ckey]) punished [victim]/([victim.ckey] with [punishment]")

	chemicals -= 75


mob/living/carbon/proc/release_control()

	set category = "Borer"
	set name = "Release Control"
	set desc = "Release control of your host's body."

	if(borer && borer.host_brain)
		src << "<span class='danger'>You withdraw your probosci, releasing control of [borer.host_brain]</span>"

		borer.detatch()

		verbs -= /mob/living/carbon/proc/release_control
		verbs -= /mob/living/carbon/proc/spawn_larvae
		verbs += /mob/living/proc/borer_comm
		verbs -= /mob/living/proc/trapped_mind_comm

//Check for brain worms in head.
/mob/proc/has_brain_worms()

	for(var/I in contents)
		if(istype(I,/mob/living/simple_animal/borer))
			return I

	return 0

/mob/living/carbon/proc/spawn_larvae()
	set category = "Borer"
	set name = "Reproduce"
	set desc = "Spawn several young."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(istype(src, /mob/living/brain))
		src << "<span class='usernotice'>You need a mouth to be able to do this.</span>"
		return
	if(!B)
		return

	if(B.chemicals >= 100)
		visible_message("<span class='danger'>[src] heaves violently, expelling a rush of vomit and a wriggling, sluglike creature!</span>")
		B.chemicals -= 100

		new /obj/effect/decal/cleanable/vomit(get_turf(src))
		playsound(loc, 'sound/effects/splat.ogg', 50, 1)
		new /mob/living/simple_animal/borer(get_turf(src), B.generation + 1)
		log_game("[src]/([src.ckey]) has spawned a new borer via reproducing.")
	else
		src << "<span class='warning'>You do not have enough chemicals stored to reproduce.</span>"
		return


/mob/living/simple_animal/borer/proc/transfer_personality(var/client/candidate)
	if(!candidate || !candidate.mob)
		return

	var/datum/mind/M = create_borer_mind(candidate.ckey)
	M.transfer_to(src)

	candidate.mob = src
	ckey = candidate.ckey

	if(mind)
		mind.store_memory("You <b>MUST</b> escape with at least [total_borer_hosts_needed] borers with hosts on the shuttle.")

	src << "<span class='notice'>You are a cortical borer!</span> You are a brain slug that worms its way \
	into the head of its victim. Use stealth, persuasion and your powers of mind control to keep you, \
	your host and your eventual spawn safe and warm."
	src << "You can speak to your fellow borers by prefixing your messages with ';'. Check out your borer tab to see your powers as a borer."
	src << "You <b>MUST</b> escape with at least [total_borer_hosts_needed] borers with hosts on the shuttle."
/mob/living/simple_animal/borer/proc/detatch()
	if(!victim || !controlling) return

	controlling = 0

	victim.verbs -= /mob/living/carbon/proc/release_control
	victim.verbs -= /mob/living/carbon/proc/spawn_larvae
	victim.verbs += /mob/living/proc/borer_comm
	victim.verbs -= /mob/living/proc/trapped_mind_comm

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
