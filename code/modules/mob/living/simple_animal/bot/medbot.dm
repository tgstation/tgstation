//MEDBOT
//MEDBOT PATHFINDING
//MEDBOT ASSEMBLY


/mob/living/simple_animal/bot/medbot
	name = "\improper Medibot"
	desc = "A little medical robot. He looks somewhat underwhelmed."
	icon = 'icons/mob/aibots.dmi'
	icon_state = "medibot0"
	density = FALSE
	anchored = FALSE
	health = 20
	maxHealth = 20
	pass_flags = PASSMOB

	status_flags = (CANPUSH | CANSTUN)

	radio_key = /obj/item/device/encryptionkey/headset_med
	radio_channel = "Medical"

	bot_type = MED_BOT
	model = "Medibot"
	bot_core_type = /obj/machinery/bot_core/medbot
	window_id = "automed"
	window_name = "Automatic Medical Unit v1.1"
	data_hud_type = DATA_HUD_MEDICAL_ADVANCED

	var/obj/item/weapon/reagent_containers/glass/reagent_glass = null //Can be set to draw from this for reagents.
	var/skin = null //Set to "tox", "ointment" or "o2" for the other two firstaid kits.
	var/mob/living/carbon/patient = null
	var/mob/living/carbon/oldpatient = null
	var/oldloc = null
	var/last_found = 0
	var/last_newpatient_speak = 0 //Don't spam the "HEY I'M COMING" messages
	var/injection_amount = 15 //How much reagent do we inject at a time?
	var/heal_threshold = 10 //Start healing when they have this much damage in a category
	var/use_beaker = 0 //Use reagents in beaker instead of default treatment agents.
	var/declare_crit = 1 //If active, the bot will transmit a critical patient alert to MedHUD users.
	var/declare_cooldown = 0 //Prevents spam of critical patient alerts.
	var/stationary_mode = 0 //If enabled, the Medibot will not move automatically.
	//Setting which reagents to use to treat what by default. By id.
	var/treatment_brute_avoid = "tricordrazine"
	var/treatment_brute = "bicaridine"
	var/treatment_oxy_avoid = null
	var/treatment_oxy = "dexalin"
	var/treatment_fire_avoid = "tricordrazine"
	var/treatment_fire = "kelotane"
	var/treatment_tox_avoid = "tricordrazine"
	var/treatment_tox = "charcoal"
	var/treatment_virus_avoid = null
	var/treatment_virus = "spaceacillin"
	var/treat_virus = 1 //If on, the bot will attempt to treat viral infections, curing them if possible.
	var/shut_up = 0 //self explanatory :)

/mob/living/simple_animal/bot/medbot/mysterious
	name = "\improper Mysterious Medibot"
	desc = "International Medibot of mystery."
	skin = "bezerk"
	treatment_brute = "tricordrazine"
	treatment_fire = "tricordrazine"
	treatment_tox = "tricordrazine"

/mob/living/simple_animal/bot/medbot/derelict
	name = "\improper Old Medibot"
	desc = "Looks like it hasn't been modified since the late 2080s."
	skin = "bezerk"
	heal_threshold = 0
	declare_crit = 0
	treatment_oxy = "pancuronium"
	treatment_brute_avoid = null
	treatment_brute = "pancuronium"
	treatment_fire_avoid = null
	treatment_fire = "sodium_thiopental"
	treatment_tox_avoid = null
	treatment_tox = "sodium_thiopental"

/mob/living/simple_animal/bot/medbot/update_icon()
	cut_overlays()
	if(skin)
		add_overlay("medskin_[skin]")
	if(!on)
		icon_state = "medibot0"
		return
	if(IsStun())
		icon_state = "medibota"
		return
	if(mode == BOT_HEALING)
		icon_state = "medibots[stationary_mode]"
		return
	else if(stationary_mode) //Bot has yellow light to indicate stationary mode.
		icon_state = "medibot2"
	else
		icon_state = "medibot1"

/mob/living/simple_animal/bot/medbot/Initialize(mapload, new_skin)
	. = ..()
	var/datum/job/doctor/J = new /datum/job/doctor
	access_card.access += J.get_access()
	prev_access = access_card.access
	qdel(J)
	skin = new_skin
	update_icon()

/mob/living/simple_animal/bot/medbot/update_canmove()
	. = ..()
	update_icon()

/mob/living/simple_animal/bot/medbot/bot_reset()
	..()
	patient = null
	oldpatient = null
	oldloc = null
	last_found = world.time
	declare_cooldown = 0
	update_icon()

/mob/living/simple_animal/bot/medbot/proc/soft_reset() //Allows the medibot to still actively perform its medical duties without being completely halted as a hard reset does.
	path = list()
	patient = null
	mode = BOT_IDLE
	last_found = world.time
	update_icon()

/mob/living/simple_animal/bot/medbot/set_custom_texts()

	text_hack = "You corrupt [name]'s reagent processor circuits."
	text_dehack = "You reset [name]'s reagent processor circuits."
	text_dehack_fail = "[name] seems damaged and does not respond to reprogramming!"

/mob/living/simple_animal/bot/medbot/attack_paw(mob/user)
	return attack_hand(user)

/mob/living/simple_animal/bot/medbot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += "<TT><B>Medical Unit Controls v1.1</B></TT><BR><BR>"
	dat += "Status: <A href='?src=\ref[src];power=1'>[on ? "On" : "Off"]</A><BR>"
	dat += "Maintenance panel panel is [open ? "opened" : "closed"]<BR>"
	dat += "Beaker: "
	if(reagent_glass)
		dat += "<A href='?src=\ref[src];eject=1'>Loaded \[[reagent_glass.reagents.total_volume]/[reagent_glass.reagents.maximum_volume]\]</a>"
	else
		dat += "None Loaded"
	dat += "<br>Behaviour controls are [locked ? "locked" : "unlocked"]<hr>"
	if(!locked || issilicon(user) || IsAdminGhost(user))
		dat += "<TT>Healing Threshold: "
		dat += "<a href='?src=\ref[src];adj_threshold=-10'>--</a> "
		dat += "<a href='?src=\ref[src];adj_threshold=-5'>-</a> "
		dat += "[heal_threshold] "
		dat += "<a href='?src=\ref[src];adj_threshold=5'>+</a> "
		dat += "<a href='?src=\ref[src];adj_threshold=10'>++</a>"
		dat += "</TT><br>"

		dat += "<TT>Injection Level: "
		dat += "<a href='?src=\ref[src];adj_inject=-5'>-</a> "
		dat += "[injection_amount] "
		dat += "<a href='?src=\ref[src];adj_inject=5'>+</a> "
		dat += "</TT><br>"

		dat += "Reagent Source: "
		dat += "<a href='?src=\ref[src];use_beaker=1'>[use_beaker ? "Loaded Beaker (When available)" : "Internal Synthesizer"]</a><br>"

		dat += "Treat Viral Infections: <a href='?src=\ref[src];virus=1'>[treat_virus ? "Yes" : "No"]</a><br>"
		dat += "The speaker switch is [shut_up ? "off" : "on"]. <a href='?src=\ref[src];togglevoice=[1]'>Toggle</a><br>"
		dat += "Critical Patient Alerts: <a href='?src=\ref[src];critalerts=1'>[declare_crit ? "Yes" : "No"]</a><br>"
		dat += "Patrol Station: <a href='?src=\ref[src];operation=patrol'>[auto_patrol ? "Yes" : "No"]</a><br>"
		dat += "Stationary Mode: <a href='?src=\ref[src];stationary=1'>[stationary_mode ? "Yes" : "No"]</a><br>"

	return dat

/mob/living/simple_animal/bot/medbot/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["adj_threshold"])
		var/adjust_num = text2num(href_list["adj_threshold"])
		heal_threshold += adjust_num
		if(heal_threshold < 5)
			heal_threshold = 5
		if(heal_threshold > 75)
			heal_threshold = 75

	else if(href_list["adj_inject"])
		var/adjust_num = text2num(href_list["adj_inject"])
		injection_amount += adjust_num
		if(injection_amount < 5)
			injection_amount = 5
		if(injection_amount > 15)
			injection_amount = 15

	else if(href_list["use_beaker"])
		use_beaker = !use_beaker

	else if(href_list["eject"] && (!isnull(reagent_glass)))
		reagent_glass.loc = get_turf(src)
		reagent_glass = null

	else if(href_list["togglevoice"])
		shut_up = !shut_up

	else if(href_list["critalerts"])
		declare_crit = !declare_crit

	else if(href_list["stationary"])
		stationary_mode = !stationary_mode
		path = list()
		update_icon()

	else if(href_list["virus"])
		treat_virus = !treat_virus

	update_controls()
	return

/mob/living/simple_animal/bot/medbot/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/reagent_containers/glass))
		. = 1 //no afterattack
		if(locked)
			to_chat(user, "<span class='warning'>You cannot insert a beaker because the panel is locked!</span>")
			return
		if(!isnull(reagent_glass))
			to_chat(user, "<span class='warning'>There is already a beaker loaded!</span>")
			return
		if(!user.drop_item())
			return

		W.loc = src
		reagent_glass = W
		to_chat(user, "<span class='notice'>You insert [W].</span>")
		show_controls(user)

	else
		var/current_health = health
		..()
		if(health < current_health) //if medbot took some damage
			step_to(src, (get_step_away(src,user)))

/mob/living/simple_animal/bot/medbot/emag_act(mob/user)
	..()
	if(emagged == 2)
		declare_crit = 0
		if(user)
			to_chat(user, "<span class='notice'>You short out [src]'s reagent synthesis circuits.</span>")
		audible_message("<span class='danger'>[src] buzzes oddly!</span>")
		flick("medibot_spark", src)
		playsound(src, "sparks", 75, 1)
		if(user)
			oldpatient = user

/mob/living/simple_animal/bot/medbot/process_scan(mob/living/carbon/human/H)
	if(H.stat == 2)
		return

	if((H == oldpatient) && (world.time < last_found + 200))
		return

	if(assess_patient(H))
		last_found = world.time
		if((last_newpatient_speak + 300) < world.time) //Don't spam these messages!
			var/list/messagevoice = list("Hey, [H.name]! Hold on, I'm coming." = 'sound/voice/mcoming.ogg',"Wait [H.name]! I want to help!" = 'sound/voice/mhelp.ogg',"[H.name], you appear to be injured!" = 'sound/voice/minjured.ogg')
			var/message = pick(messagevoice)
			speak(message)
			playsound(loc, messagevoice[message], 50, 0)
			last_newpatient_speak = world.time
		return H
	else
		return

/mob/living/simple_animal/bot/medbot/handle_automated_action()
	if(!..())
		return

	if(mode == BOT_HEALING)
		return

	if(IsStun())
		oldpatient = patient
		patient = null
		mode = BOT_IDLE
		return

	if(frustration > 8)
		oldpatient = patient
		soft_reset()

	if(!patient)
		if(!shut_up && prob(1))
			var/list/messagevoice = list("Radar, put a mask on!" = 'sound/voice/mradar.ogg',"There's always a catch, and I'm the best there is." = 'sound/voice/mcatch.ogg',"I knew it, I should've been a plastic surgeon." = 'sound/voice/msurgeon.ogg',"What kind of medbay is this? Everyone's dropping like flies." = 'sound/voice/mflies.ogg',"Delicious!" = 'sound/voice/mdelicious.ogg')
			var/message = pick(messagevoice)
			speak(message)
			playsound(loc, messagevoice[message], 50, 0)
		var/scan_range = (stationary_mode ? 1 : DEFAULT_SCAN_RANGE) //If in stationary mode, scan range is limited to adjacent patients.
		patient = scan(/mob/living/carbon/human, oldpatient, scan_range)
		oldpatient = patient

	if(patient && (get_dist(src,patient) <= 1)) //Patient is next to us, begin treatment!
		if(mode != BOT_HEALING)
			mode = BOT_HEALING
			update_icon()
			frustration = 0
			medicate_patient(patient)
		return

	//Patient has moved away from us!
	else if(patient && path.len && (get_dist(patient,path[path.len]) > 2))
		path = list()
		mode = BOT_IDLE
		last_found = world.time

	else if(stationary_mode && patient) //Since we cannot move in this mode, ignore the patient and wait for another.
		soft_reset()
		return

	if(patient && path.len == 0 && (get_dist(src,patient) > 1))
		path = get_path_to(src, get_turf(patient), /turf/proc/Distance_cardinal, 0, 30,id=access_card)
		mode = BOT_MOVING
		if(!path.len) //try to get closer if you can't reach the patient directly
			path = get_path_to(src, get_turf(patient), /turf/proc/Distance_cardinal, 0, 30,1,id=access_card)
			if(!path.len) //Do not chase a patient we cannot reach.
				soft_reset()

	if(path.len > 0 && patient)
		if(!bot_move(path[path.len]))
			oldpatient = patient
			soft_reset()
		return

	if(path.len > 8 && patient)
		frustration++

	if(auto_patrol && !stationary_mode && !patient)
		if(mode == BOT_IDLE || mode == BOT_START_PATROL)
			start_patrol()

		if(mode == BOT_PATROL)
			bot_patrol()

	return

/mob/living/simple_animal/bot/medbot/proc/assess_patient(mob/living/carbon/C)
	//Time to see if they need medical help!
	if(C.stat == DEAD || (C.status_flags & FAKEDEATH))
		return 0 //welp too late for them!

	if(C.suiciding)
		return 0 //Kevorkian school of robotic medical assistants.

	if(emagged == 2) //Everyone needs our medicine. (Our medicine is toxins)
		return 1

	if(declare_crit && C.health <= 0) //Critical condition! Call for help!
		declare(C)

	//If they're injured, we're using a beaker, and don't have one of our WONDERCHEMS.
	if((reagent_glass) && (use_beaker) && ((C.getBruteLoss() >= heal_threshold) || (C.getToxLoss() >= heal_threshold) || (C.getToxLoss() >= heal_threshold) || (C.getOxyLoss() >= (heal_threshold + 15))))
		for(var/datum/reagent/R in reagent_glass.reagents.reagent_list)
			if(!C.reagents.has_reagent(R.id))
				return 1

	//They're injured enough for it!
	if((!C.reagents.has_reagent(treatment_brute_avoid)) && (C.getBruteLoss() >= heal_threshold) && (!C.reagents.has_reagent(treatment_brute)))
		return 1 //If they're already medicated don't bother!

	if((!C.reagents.has_reagent(treatment_oxy_avoid)) && (C.getOxyLoss() >= (15 + heal_threshold)) && (!C.reagents.has_reagent(treatment_oxy)))
		return 1

	if((!C.reagents.has_reagent(treatment_fire_avoid)) && (C.getFireLoss() >= heal_threshold) && (!C.reagents.has_reagent(treatment_fire)))
		return 1

	if((!C.reagents.has_reagent(treatment_tox_avoid)) && (C.getToxLoss() >= heal_threshold) && (!C.reagents.has_reagent(treatment_tox)))
		return 1

	if(treat_virus && !C.reagents.has_reagent(treatment_virus_avoid) && !C.reagents.has_reagent(treatment_virus))
		for(var/thing in C.viruses)
			var/datum/disease/D = thing
			//the medibot can't detect viruses that are undetectable to Health Analyzers or Pandemic machines.
			if(!(D.visibility_flags & HIDDEN_SCANNER || D.visibility_flags & HIDDEN_PANDEMIC) \
			&& D.severity != NONTHREAT \
			&& (D.stage > 1 || (D.spread_flags & AIRBORNE))) // medibot can't detect a virus in its initial stage unless it spreads airborne.
				return 1 //STOP DISEASE FOREVER

	return 0

/mob/living/simple_animal/bot/medbot/UnarmedAttack(atom/A)
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		patient = C
		mode = BOT_HEALING
		update_icon()
		medicate_patient(C)
		update_icon()
	else
		..()

/mob/living/simple_animal/bot/medbot/examinate(atom/A as mob|obj|turf in view())
	..()
	if(!is_blind(src))
		chemscan(src, A)

/mob/living/simple_animal/bot/medbot/proc/medicate_patient(mob/living/carbon/C)
	if(!on)
		return

	if(!istype(C))
		oldpatient = patient
		soft_reset()
		return

	if(C.stat == DEAD || (C.status_flags & FAKEDEATH))
		var/list/messagevoice = list("No! Stay with me!" = 'sound/voice/mno.ogg',"Live, damnit! LIVE!" = 'sound/voice/mlive.ogg',"I...I've never lost a patient before. Not today, I mean." = 'sound/voice/mlost.ogg')
		var/message = pick(messagevoice)
		speak(message)
		playsound(loc, messagevoice[message], 50, 0)
		oldpatient = patient
		soft_reset()
		return

	var/reagent_id = null

	if(emagged == 2) //Emagged! Time to poison everybody.
		reagent_id = "toxin"

	else
		if(treat_virus)
			var/virus = 0
			for(var/thing in C.viruses)
				var/datum/disease/D = thing
				//detectable virus
				if((!(D.visibility_flags & HIDDEN_SCANNER)) || (!(D.visibility_flags & HIDDEN_PANDEMIC)))
					if(D.severity != NONTHREAT)      //virus is harmful
						if((D.stage > 1) || (D.spread_flags & AIRBORNE))
							virus = 1

			if(!reagent_id && (virus))
				if(!C.reagents.has_reagent(treatment_virus) && !C.reagents.has_reagent(treatment_virus_avoid))
					reagent_id = treatment_virus

		if(!reagent_id && (C.getBruteLoss() >= heal_threshold))
			if(!C.reagents.has_reagent(treatment_brute) && !C.reagents.has_reagent(treatment_brute_avoid))
				reagent_id = treatment_brute

		if(!reagent_id && (C.getOxyLoss() >= (15 + heal_threshold)))
			if(!C.reagents.has_reagent(treatment_oxy) && !C.reagents.has_reagent(treatment_oxy_avoid))
				reagent_id = treatment_oxy

		if(!reagent_id && (C.getFireLoss() >= heal_threshold))
			if(!C.reagents.has_reagent(treatment_fire) && !C.reagents.has_reagent(treatment_fire_avoid))
				reagent_id = treatment_fire

		if(!reagent_id && (C.getToxLoss() >= heal_threshold))
			if(!C.reagents.has_reagent(treatment_tox) && !C.reagents.has_reagent(treatment_tox_avoid))
				reagent_id = treatment_tox

		//If the patient is injured but doesn't have our special reagent in them then we should give it to them first
		if(reagent_id && use_beaker && reagent_glass && reagent_glass.reagents.total_volume)
			for(var/datum/reagent/R in reagent_glass.reagents.reagent_list)
				if(!C.reagents.has_reagent(R.id))
					reagent_id = "internal_beaker"
					break

	if(!reagent_id) //If they don't need any of that they're probably cured!
		var/list/messagevoice = list("All patched up!" = 'sound/voice/mpatchedup.ogg',"An apple a day keeps me away." = 'sound/voice/mapple.ogg',"Feel better soon!" = 'sound/voice/mfeelbetter.ogg')
		var/message = pick(messagevoice)
		speak(message)
		playsound(loc, messagevoice[message], 50, 0)
		bot_reset()
		return
	else
		if(!emagged && check_overdose(patient,reagent_id,injection_amount))
			soft_reset()
			return
		C.visible_message("<span class='danger'>[src] is trying to inject [patient]!</span>", \
			"<span class='userdanger'>[src] is trying to inject you!</span>")

		var/failed = FALSE;
		if(do_mob(src, patient, 30))	//Is C == patient? This is so confusing
			if((get_dist(src, patient) <= 1) && (on) && assess_patient(patient))
				if(reagent_id == "internal_beaker")
					if(use_beaker && reagent_glass && reagent_glass.reagents.total_volume)
						var/fraction = min(injection_amount/reagent_glass.reagents.total_volume, 1)
						reagent_glass.reagents.reaction(patient, INJECT, fraction)
						reagent_glass.reagents.trans_to(patient,injection_amount) //Inject from beaker instead.
				else
					patient.reagents.add_reagent(reagent_id,injection_amount)
				C.visible_message("<span class='danger'>[src] injects [patient] with its syringe!</span>", \
					"<span class='userdanger'>[src] injects you with its syringe!</span>")
			else
				failed = TRUE
		else
			failed = TRUE

		if(failed)
			visible_message("[src] retracts its syringe.")
		update_icon()
		soft_reset()
		return

	reagent_id = null
	return

/mob/living/simple_animal/bot/medbot/proc/check_overdose(mob/living/carbon/patient,reagent_id,injection_amount)
	var/datum/reagent/R  = GLOB.chemical_reagents_list[reagent_id]
	if(!R.overdose_threshold) //Some chems do not have an OD threshold
		return 0
	var/current_volume = patient.reagents.get_reagent_amount(reagent_id)
	if(current_volume + injection_amount > R.overdose_threshold)
		return 1
	return 0

/mob/living/simple_animal/bot/medbot/explode()
	on = FALSE
	visible_message("<span class='boldannounce'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)

	new /obj/item/weapon/storage/firstaid(Tsec)

	new /obj/item/device/assembly/prox_sensor(Tsec)

	new /obj/item/device/healthanalyzer(Tsec)

	if(reagent_glass)
		reagent_glass.loc = Tsec
		reagent_glass = null

	if(prob(50))
		new /obj/item/bodypart/l_arm/robot(Tsec)

	if(emagged && prob(25))
		playsound(loc, 'sound/voice/minsult.ogg', 50, 0)

	do_sparks(3, TRUE, src)
	..()

/mob/living/simple_animal/bot/medbot/proc/declare(crit_patient)
	if(declare_cooldown > world.time)
		return
	var/area/location = get_area(src)
	speak("Medical emergency! [crit_patient ? "<b>[crit_patient]</b>" : "A patient"] is in critical condition at [location]!",radio_channel)
	declare_cooldown = world.time + 200

/obj/machinery/bot_core/medbot
	req_one_access =list(ACCESS_MEDICAL, ACCESS_ROBOTICS)
