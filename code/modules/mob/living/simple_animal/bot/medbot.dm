//MEDBOT
//MEDBOT PATHFINDING
//MEDBOT ASSEMBLY
#define MEDBOT_PANIC_NONE 0
#define MEDBOT_PANIC_LOW 15
#define MEDBOT_PANIC_MED 35
#define MEDBOT_PANIC_HIGH 55
#define MEDBOT_PANIC_FUCK 70
#define MEDBOT_PANIC_ENDING 90
#define MEDBOT_PANIC_END 100

#define MEDBOT_NEW_PATIENTSPEAK_DELAY (30 SECONDS)
#define MEDBOT_PATIENTSPEAK_DELAY (20 SECONDS)
#define MEDBOT_FREAKOUT_DELAY (15 SECONDS)

/mob/living/simple_animal/bot/medbot
	name = "\improper Medibot"
	desc = "A little medical robot. He looks somewhat underwhelmed."
	icon = 'icons/mob/silicon/aibots.dmi'
	icon_state = "medibot0"
	base_icon_state = "medibot"
	density = FALSE
	anchored = FALSE
	health = 20
	maxHealth = 20
	pass_flags = PASSMOB | PASSFLAPS
	status_flags = (CANPUSH | CANSTUN)

	maints_access_required = list(ACCESS_ROBOTICS, ACCESS_MEDICAL)
	radio_key = /obj/item/encryptionkey/headset_med
	radio_channel = RADIO_CHANNEL_MEDICAL
	bot_type = MED_BOT
	data_hud_type = DATA_HUD_MEDICAL_ADVANCED
	hackables = "health processor circuits"
	path_image_color = "#DDDDFF"

	/// drop determining variable
	var/healthanalyzer = /obj/item/healthanalyzer
	/// drop determining variable
	var/medkit_type = /obj/item/storage/medkit
	///based off medkit_X skins in aibots.dmi for your selection; X goes here IE medskin_tox means skin var should be "tox"
	var/skin
	var/mob/living/carbon/patient
	var/mob/living/carbon/oldpatient
	var/last_found = 0
	/// How much healing do we do at a time?
	var/heal_amount = 2.5
	/// Start healing when they have this much damage in a category
	var/heal_threshold = 10
	/// What damage type does this bot support. Because the default is brute, if the medkit is brute-oriented there is a slight bonus to healing. set to "all" for it to heal any of the 4 base damage types
	var/damagetype_healer = BRUTE

	///Flags Medbots use to decide how they should be acting.
	var/medical_mode_flags = MEDBOT_DECLARE_CRIT | MEDBOT_SPEAK_MODE
//	Selections:  MEDBOT_DECLARE_CRIT | MEDBOT_STATIONARY_MODE | MEDBOT_SPEAK_MODE

	/// techweb linked to the medbot
	var/datum/techweb/linked_techweb
	///Is the medbot currently tending wounds
	var/tending = FALSE
	///How panicked we are about being tipped over (why would you do this?)
	var/tipped_status = MEDBOT_PANIC_NONE
	///The name we got when we were tipped
	var/tipper_name

	///Last announced healing a person in critical condition
	COOLDOWN_DECLARE(last_patient_message)
	///Last announced trying to catch up to a new patient
	COOLDOWN_DECLARE(last_newpatient_speak)
	///Last time we were tipped/righted and said a voice line
	COOLDOWN_DECLARE(last_tipping_action_voice)

/mob/living/simple_animal/bot/medbot/autopatrol
	bot_mode_flags = BOT_MODE_ON | BOT_MODE_AUTOPATROL | BOT_MODE_REMOTE_ENABLED | BOT_MODE_PAI_CONTROLLABLE

/mob/living/simple_animal/bot/medbot/stationary
	medical_mode_flags = MEDBOT_DECLARE_CRIT | MEDBOT_STATIONARY_MODE | MEDBOT_SPEAK_MODE

/mob/living/simple_animal/bot/medbot/mysterious
	name = "\improper Mysterious Medibot"
	desc = "International Medibot of mystery."
	skin = "bezerk"
	damagetype_healer = "all"
	heal_amount = 10

/mob/living/simple_animal/bot/medbot/derelict
	name = "\improper Old Medibot"
	desc = "Looks like it hasn't been modified since the late 2080s."
	skin = "bezerk"
	damagetype_healer = "all"
	medical_mode_flags = MEDBOT_SPEAK_MODE
	heal_threshold = 0
	heal_amount = 5

/mob/living/simple_animal/bot/medbot/examine(mob/user)
	. = ..()
	if(tipped_status == MEDBOT_PANIC_NONE)
		return

	switch(tipped_status)
		if(MEDBOT_PANIC_NONE to MEDBOT_PANIC_LOW)
			. += "It appears to be tipped over, and is quietly waiting for someone to set it right."
		if(MEDBOT_PANIC_LOW to MEDBOT_PANIC_MED)
			. += "It is tipped over and requesting help."
		if(MEDBOT_PANIC_MED to MEDBOT_PANIC_HIGH)
			. += "They are tipped over and appear visibly distressed." // now we humanize the medbot as a they, not an it
		if(MEDBOT_PANIC_HIGH to MEDBOT_PANIC_FUCK)
			. += span_warning("They are tipped over and visibly panicking!")
		if(MEDBOT_PANIC_FUCK to INFINITY)
			. += span_warning("<b>They are freaking out from being tipped over!</b>")

/mob/living/simple_animal/bot/medbot/update_icon_state()
	. = ..()
	if(!(bot_mode_flags & BOT_MODE_ON))
		icon_state = "[base_icon_state]0"
		return
	if(HAS_TRAIT(src, TRAIT_INCAPACITATED))
		icon_state = "[base_icon_state]a"
		return
	if(mode == BOT_HEALING)
		icon_state = "[base_icon_state]s[get_bot_flag(medical_mode_flags, MEDBOT_STATIONARY_MODE)]"
		return
	icon_state = "[base_icon_state][get_bot_flag(medical_mode_flags, MEDBOT_STATIONARY_MODE) ? 2 : 1]" //Bot has yellow light to indicate stationary mode.

/mob/living/simple_animal/bot/medbot/update_overlays()
	. = ..()
	if(skin)
		. += "medskin_[skin]"

/mob/living/simple_animal/bot/medbot/Initialize(mapload, new_skin)
	. = ..()

	// Doing this hurts my soul, but simplebot access reworks are for another day.
	var/datum/id_trim/job/para_trim = SSid_access.trim_singletons_by_path[/datum/id_trim/job/paramedic]
	access_card.add_access(para_trim.access + para_trim.wildcard_access)
	prev_access = access_card.access.Copy()

	skin = new_skin
	update_appearance()
	if(!CONFIG_GET(flag/no_default_techweb_link) && !linked_techweb)
		linked_techweb = SSresearch.science_tech

	AddComponent(/datum/component/tippable, \
		tip_time = 3 SECONDS, \
		untip_time = 3 SECONDS, \
		self_right_time = 3.5 MINUTES, \
		pre_tipped_callback = CALLBACK(src, PROC_REF(pre_tip_over)), \
		post_tipped_callback = CALLBACK(src, PROC_REF(after_tip_over)), \
		post_untipped_callback = CALLBACK(src, PROC_REF(after_righted)))

/mob/living/simple_animal/bot/medbot/bot_reset()
	..()
	patient = null
	oldpatient = null
	last_found = world.time
	update_appearance()

/mob/living/simple_animal/bot/medbot/proc/soft_reset() //Allows the medibot to still actively perform its medical duties without being completely halted as a hard reset does.
	path = list()
	patient = null
	mode = BOT_IDLE
	last_found = world.time
	update_appearance()

/mob/living/simple_animal/bot/medbot/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/mob/living/simple_animal/bot/medbot/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(!QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb))
		linked_techweb = tool.buffer
	return TRUE

// Variables sent to TGUI
/mob/living/simple_animal/bot/medbot/ui_data(mob/user)
	var/list/data = ..()
	if(!(bot_cover_flags & BOT_COVER_LOCKED) || issilicon(user) || isAdminGhostAI(user))
		data["custom_controls"]["heal_threshold"] = heal_threshold
		data["custom_controls"]["speaker"] = medical_mode_flags & MEDBOT_SPEAK_MODE
		data["custom_controls"]["crit_alerts"] = medical_mode_flags & MEDBOT_DECLARE_CRIT
		data["custom_controls"]["stationary_mode"] = medical_mode_flags & MEDBOT_STATIONARY_MODE
		data["custom_controls"]["sync_tech"] = TRUE
	return data

// Actions received from TGUI
/mob/living/simple_animal/bot/medbot/ui_act(action, params)
	. = ..()
	if(. || (bot_cover_flags & BOT_COVER_LOCKED && !usr.has_unlimited_silicon_privilege))
		return

	switch(action)
		if("heal_threshold")
			var/adjust_num = round(text2num(params["threshold"]))
			heal_threshold = adjust_num
			if(heal_threshold < 5)
				heal_threshold = 5
			if(heal_threshold > 75)
				heal_threshold = 75
		if("speaker")
			medical_mode_flags ^= MEDBOT_SPEAK_MODE
		if("crit_alerts")
			medical_mode_flags ^= MEDBOT_DECLARE_CRIT
		if("stationary_mode")
			medical_mode_flags ^= MEDBOT_STATIONARY_MODE
			path = list()
		if("sync_tech")
			if(!linked_techweb)
				to_chat(usr, span_notice("No research techweb connected."))
				return
			var/oldheal_amount = heal_amount
			var/tech_boosters
			for(var/index in linked_techweb.researched_designs)
				var/datum/design/surgery/healing/design = SSresearch.techweb_design_by_id(index)
				if(!istype(design))
					continue
				tech_boosters++
			if(tech_boosters)
				heal_amount = (round(tech_boosters/2,0.1)*initial(heal_amount))+initial(heal_amount) //every 2 tend wounds tech gives you an extra 100% healing, adjusting for unique branches (combo is bonus)
				if(oldheal_amount < heal_amount)
					speak("New knowledge found! Surgical efficacy improved to [round(heal_amount/initial(heal_amount)*100)]%!")

	update_appearance()

/mob/living/simple_animal/bot/medbot/attackby(obj/item/W as obj, mob/user as mob, params)
	var/current_health = health
	..()
	if(health < current_health) //if medbot took some damage
		step_to(src, (get_step_away(src,user)))

/mob/living/simple_animal/bot/medbot/emag_act(mob/user)
	..()
	if(!(bot_cover_flags & BOT_COVER_EMAGGED))
		return
	medical_mode_flags &= ~MEDBOT_DECLARE_CRIT
	if(user)
		to_chat(user, span_notice("You short out [src]'s reagent synthesis circuits."))
	audible_message(span_danger("[src] buzzes oddly!"))
	flick("medibot_spark", src)
	playsound(src, SFX_SPARKS, 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	if(user)
		oldpatient = user

/mob/living/simple_animal/bot/medbot/process_scan(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return null
	if((H == oldpatient) && (world.time < last_found + 200))
		return null
	if(!assess_patient(H))
		return null

	last_found = world.time
	if(COOLDOWN_FINISHED(src, last_newpatient_speak))
		COOLDOWN_START(src, last_newpatient_speak, MEDBOT_NEW_PATIENTSPEAK_DELAY)
		var/list/messagevoice = list("Hey, [H.name]! Hold on, I'm coming." = 'sound/voice/medbot/coming.ogg',"Wait [H.name]! I want to help!" = 'sound/voice/medbot/help.ogg',"[H.name], you appear to be injured!" = 'sound/voice/medbot/injured.ogg')
		var/message = pick(messagevoice)
		speak(message)
		playsound(src, messagevoice[message], 50, FALSE)
	return H

/*
 * Proc used in a callback for before this medibot is tipped by the tippable component.
 *
 * user - the mob who is tipping us over
 */
/mob/living/simple_animal/bot/medbot/proc/pre_tip_over(mob/user)
	if(!COOLDOWN_FINISHED(src, last_tipping_action_voice))
		return

	COOLDOWN_START(src, last_tipping_action_voice, MEDBOT_FREAKOUT_DELAY) // message for tipping happens when we start interacting, message for righting comes after finishing
	var/static/list/messagevoice = list(
		"Hey, wait..." = 'sound/voice/medbot/hey_wait.ogg',
		"Please don't..." = 'sound/voice/medbot/please_dont.ogg',
		"I trusted you..." = 'sound/voice/medbot/i_trusted_you.ogg',
		"Nooo..." = 'sound/voice/medbot/nooo.ogg',
		"Oh fuck-" = 'sound/voice/medbot/oh_fuck.ogg',
		)
	var/message = pick(messagevoice)
	speak(message)
	playsound(src, messagevoice[message], 70, FALSE)

/*
 * Proc used in a callback for after this medibot is tipped by the tippable component.
 *
 * user - the mob who tipped us over
 */
/mob/living/simple_animal/bot/medbot/proc/after_tip_over(mob/user)
	mode = BOT_TIPPED
	tipper_name = user.name
	playsound(src, 'sound/machines/warning-buzzer.ogg', 50)

/*
 * Proc used in a callback for after this medibot is righted, either by themselves or by a mob, by the tippable component.
 *
 * user - the mob who righted us. Can be null.
 */
/mob/living/simple_animal/bot/medbot/proc/after_righted(mob/user)
	var/list/messagevoice
	if(user)
		if(user.name == tipper_name)
			messagevoice = list("I forgive you." = 'sound/voice/medbot/forgive.ogg')
		else
			messagevoice = list("Thank you!" = 'sound/voice/medbot/thank_you.ogg', "You are a good person." = 'sound/voice/medbot/youre_good.ogg')
	else
		messagevoice = list("Fuck you." = 'sound/voice/medbot/fuck_you.ogg', "Your behavior has been reported, have a nice day." = 'sound/voice/medbot/reported.ogg')
	tipper_name = null

	if(COOLDOWN_FINISHED(src, last_tipping_action_voice))
		COOLDOWN_START(src, last_tipping_action_voice, MEDBOT_FREAKOUT_DELAY)
		var/message = pick(messagevoice)
		speak(message)
		playsound(src, messagevoice[message], 70)
	tipped_status = MEDBOT_PANIC_NONE
	mode = BOT_IDLE

/// if someone tipped us over, check whether we should ask for help or just right ourselves eventually
/mob/living/simple_animal/bot/medbot/proc/handle_panic()
	tipped_status++
	var/list/messagevoice

	switch(tipped_status)
		if(MEDBOT_PANIC_LOW)
			messagevoice = list("I require assistance." = 'sound/voice/medbot/i_require_asst.ogg')
		if(MEDBOT_PANIC_MED)
			messagevoice = list("Please put me back." = 'sound/voice/medbot/please_put_me_back.ogg')
		if(MEDBOT_PANIC_HIGH)
			messagevoice = list("Please, I am scared!" = 'sound/voice/medbot/please_im_scared.ogg')
		if(MEDBOT_PANIC_FUCK)
			messagevoice = list("I don't like this, I need help!" = 'sound/voice/medbot/dont_like.ogg', "This hurts, my pain is real!" = 'sound/voice/medbot/pain_is_real.ogg')
		if(MEDBOT_PANIC_ENDING)
			messagevoice = list("Is this the end?" = 'sound/voice/medbot/is_this_the_end.ogg', "Nooo!" = 'sound/voice/medbot/nooo.ogg')
		if(MEDBOT_PANIC_END)
			speak("PSYCH ALERT: Crewmember [tipper_name] recorded displaying antisocial tendencies torturing bots in [get_area(src)]. Please schedule psych evaluation.", radio_channel)

	if(prob(tipped_status))
		do_jitter_animation(tipped_status * 0.1)

	if(messagevoice)
		var/message = pick(messagevoice)
		speak(message)
		playsound(src, messagevoice[message], 70)
	else if(prob(tipped_status * 0.2))
		playsound(src, 'sound/machines/warning-buzzer.ogg', 30, extrarange=-2)

/mob/living/simple_animal/bot/medbot/handle_automated_action()
	. = ..()
	if(!.)
		return

	switch(mode)
		if(BOT_TIPPED)
			handle_panic()
			return
		if(BOT_HEALING)
			return

	if(IsStun() || IsParalyzed())
		oldpatient = patient
		patient = null
		mode = BOT_IDLE
		return

	if(frustration > 8)
		oldpatient = patient
		soft_reset()

	if(QDELETED(patient))
		if(medical_mode_flags & MEDBOT_SPEAK_MODE && prob(1))
			if(bot_cover_flags & BOT_COVER_EMAGGED && prob(30))
				var/list/i_need_scissors = list(
					'sound/voice/medbot/fuck_you.ogg',
					'sound/voice/medbot/turn_off.ogg',
					'sound/voice/medbot/im_different.ogg',
					'sound/voice/medbot/close.ogg',
					'sound/voice/medbot/shindemashou.ogg',
				)
				playsound(src, pick(i_need_scissors), 70)
			else
				var/static/list/messagevoice = list(
					"Delicious!" = 'sound/voice/medbot/delicious.ogg',
					"I knew it, I should've been a plastic surgeon." = 'sound/voice/medbot/surgeon.ogg',
					"Radar, put a mask on!" = 'sound/voice/medbot/radar.ogg',
					"There's always a catch, and I'm the best there is." = 'sound/voice/medbot/catch.ogg',
					"What kind of medbay is this? Everyone's dropping like flies." = 'sound/voice/medbot/flies.ogg',
					"Why are we still here? Just to suffer?" = 'sound/voice/medbot/why.ogg',
				)
				var/message = pick(messagevoice)
				speak(message)
				playsound(src, messagevoice[message], 50)
		var/scan_range = (medical_mode_flags & MEDBOT_STATIONARY_MODE ? 1 : DEFAULT_SCAN_RANGE) //If in stationary mode, scan range is limited to adjacent patients.
		patient = scan(list(/mob/living/carbon/human), oldpatient, scan_range)
		oldpatient = patient

	if(patient && (get_dist(src,patient) <= 1) && !tending) //Patient is next to us, begin treatment!
		if(mode != BOT_HEALING)
			mode = BOT_HEALING
			update_appearance()
			frustration = 0
			medicate_patient(patient)
		return

	//Patient has moved away from us!
	else if(patient && path.len && (get_dist(patient,path[path.len]) > 2))
		path = list()
		mode = BOT_IDLE
		last_found = world.time

	else if(medical_mode_flags & MEDBOT_STATIONARY_MODE && patient) //Since we cannot move in this mode, ignore the patient and wait for another.
		soft_reset()
		return

	if(patient && path.len == 0 && (get_dist(src,patient) > 1))
		path = get_path_to(src, patient, max_distance=30, id=access_card)
		mode = BOT_MOVING
		if(!path.len) //try to get closer if you can't reach the patient directly
			path = get_path_to(src, patient, max_distance=30, mintargetdist=1, id=access_card)
			if(!path.len) //Do not chase a patient we cannot reach.
				soft_reset()

	if(path.len > 0 && patient)
		if(!bot_move(path[path.len]))
			oldpatient = patient
			soft_reset()
		return

	if(path.len > 8 && patient)
		frustration++

	if(bot_mode_flags & BOT_MODE_AUTOPATROL && !(medical_mode_flags & MEDBOT_STATIONARY_MODE) && !patient)
		switch(mode)
			if(BOT_IDLE, BOT_START_PATROL)
				start_patrol()
			if(BOT_PATROL)
				bot_patrol()

/mob/living/simple_animal/bot/medbot/proc/assess_patient(mob/living/carbon/C)
	. = FALSE
	//Time to see if they need medical help!
	if(medical_mode_flags & MEDBOT_STATIONARY_MODE && !Adjacent(C)) //YOU come to ME, BRO
		return FALSE

	if(C.stat == DEAD || (HAS_TRAIT(C, TRAIT_FAKEDEATH)))
		return FALSE //welp too late for them!

	if(!(loc == C.loc) && !(isturf(C.loc) && isturf(loc)))
		return FALSE

	if(C.suiciding)
		return FALSE //Kevorkian school of robotic medical assistants.

	if(bot_cover_flags & BOT_COVER_EMAGGED) //Everyone needs our medicine. (Our medicine is toxins)
		return TRUE

	if(HAS_TRAIT(C, TRAIT_MEDIBOTCOMINGTHROUGH) && !HAS_TRAIT_FROM(C, TRAIT_MEDIBOTCOMINGTHROUGH, tag)) //the early medbot gets the worm (or in this case the patient)
		return FALSE

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if (H.wear_suit && H.head && istype(H.wear_suit, /obj/item/clothing) && istype(H.head, /obj/item/clothing))
			var/obj/item/clothing/CS = H.wear_suit
			var/obj/item/clothing/CH = H.head
			if (CS.clothing_flags & CH.clothing_flags & THICKMATERIAL)
				return FALSE // Skip over them if they have no exposed flesh.

	if(medical_mode_flags & MEDBOT_DECLARE_CRIT && C.health <= 0) //Critical condition! Call for help!
		declare(C)

	//They're injured enough for it!
	var/list/treat_me_for = list()
	if(C.getBruteLoss() > heal_threshold)
		treat_me_for += BRUTE

	if(C.getOxyLoss() > (5 + heal_threshold))
		treat_me_for += OXY

	if(C.getFireLoss() > heal_threshold)
		treat_me_for += BURN

	if(C.getToxLoss() > heal_threshold)
		treat_me_for += TOX

	if(damagetype_healer in treat_me_for)
		return TRUE
	if(damagetype_healer == "all" && treat_me_for.len)
		return TRUE

/mob/living/simple_animal/bot/medbot/UnarmedAttack(atom/A, proximity_flag, list/modifiers)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	if(iscarbon(A) && !tending)
		var/mob/living/carbon/C = A
		patient = C
		mode = BOT_HEALING
		update_appearance()
		medicate_patient(C)
		update_appearance()
		return
	..()

/mob/living/simple_animal/bot/medbot/examinate(atom/A as mob|obj|turf in view())
	..()
	if(!is_blind())
		chemscan(src, A)

/mob/living/simple_animal/bot/medbot/proc/medicate_patient(mob/living/carbon/C)
	if(!(bot_mode_flags & BOT_MODE_ON))
		return

	if(!istype(C))
		oldpatient = patient
		soft_reset()
		return

	if(C.stat == DEAD || (HAS_TRAIT(C, TRAIT_FAKEDEATH)))
		var/list/messagevoice = list("No! Stay with me!" = 'sound/voice/medbot/no.ogg',"Live, damnit! LIVE!" = 'sound/voice/medbot/live.ogg',"I...I've never lost a patient before. Not today, I mean." = 'sound/voice/medbot/lost.ogg')
		var/message = pick(messagevoice)
		speak(message)
		playsound(src, messagevoice[message], 50)
		oldpatient = patient
		soft_reset()
		return

	tending = TRUE
	while(tending)
		var/treatment_method
		var/list/potential_methods = list()

		if(C.getBruteLoss() > heal_threshold)
			potential_methods += BRUTE

		if(C.getFireLoss() > heal_threshold)
			potential_methods += BURN

		if(C.getOxyLoss() > (5 + heal_threshold))
			potential_methods += OXY

		if(C.getToxLoss() > heal_threshold)
			potential_methods += TOX

		for(var/i in potential_methods)
			if(i != damagetype_healer)
				continue
			treatment_method = i

		if(damagetype_healer == "all" && potential_methods.len)
			treatment_method = pick(potential_methods)

		if(!treatment_method && !(bot_cover_flags & BOT_COVER_EMAGGED)) //If they don't need any of that they're probably cured!
			if(C.maxHealth - C.get_organic_health() < heal_threshold)
				to_chat(src, span_notice("[C] is healthy! Your programming prevents you from tending the wounds of anyone without at least [heal_threshold] damage of any one type ([heal_threshold + 5] for oxygen damage.)"))

			var/list/messagevoice = list("All patched up!" = 'sound/voice/medbot/patchedup.ogg',"An apple a day keeps me away." = 'sound/voice/medbot/apple.ogg',"Feel better soon!" = 'sound/voice/medbot/feelbetter.ogg')
			var/message = pick(messagevoice)
			speak(message)
			playsound(src, messagevoice[message], 50)
			bot_reset()
			tending = FALSE
		else if(patient)
			C.visible_message(span_danger("[src] is trying to tend the wounds of [patient]!"), \
				span_userdanger("[src] is trying to tend your wounds!"))

			if(do_after(src, 2 SECONDS, patient)) //Slightly faster than default tend wounds, but does less HPS
				if((get_dist(src, patient) <= 1) && (bot_mode_flags & BOT_MODE_ON) && assess_patient(patient))
					var/healies = heal_amount
					var/obj/item/storage/medkit/medkit = medkit_type
					if(treatment_method == BRUTE && initial(medkit.damagetype_healed) == BRUTE) //specialized brute gets a bit of bonus, as a snack.
						healies *= 1.1
					if(bot_cover_flags & BOT_COVER_EMAGGED)
						patient.reagents.add_reagent(/datum/reagent/toxin/chloralhydrate, 5)
						patient.apply_damage_type((healies*1),treatment_method)
						log_combat(src, patient, "pretended to tend wounds on", "internal tools", "([uppertext(treatment_method)]) (EMAGGED)")
					else
						patient.apply_damage_type((healies*-1),treatment_method) //don't need to check treatment_method since we know by this point that they were actually damaged.
						log_combat(src, patient, "tended the wounds of", "internal tools", "([uppertext(treatment_method)])")
					C.visible_message(span_notice("[src] tends the wounds of [patient]!"), \
						"<span class='infoplain'>[span_green("[src] tends your wounds!")]</span>")
					ADD_TRAIT(patient,TRAIT_MEDIBOTCOMINGTHROUGH,tag)
					addtimer(TRAIT_CALLBACK_REMOVE(patient, TRAIT_MEDIBOTCOMINGTHROUGH, tag), (30 SECONDS))
				else
					tending = FALSE
			else
				tending = FALSE

			update_appearance()
			if(!tending)
				visible_message("<span class='infoplain'>[src] places its tools back into itself.</span>")
				soft_reset()
		else
			tending = FALSE

/mob/living/simple_animal/bot/medbot/explode()
	var/atom/Tsec = drop_location()

	drop_part(medkit_type, Tsec)
	new /obj/item/assembly/prox_sensor(Tsec)
	drop_part(healthanalyzer, Tsec)

	if(bot_cover_flags & BOT_COVER_EMAGGED && prob(25))
		playsound(src, 'sound/voice/medbot/insult.ogg', 50)
	return ..()

/mob/living/simple_animal/bot/medbot/proc/declare(crit_patient)
	if(!COOLDOWN_FINISHED(src, last_patient_message))
		return
	COOLDOWN_START(src, last_patient_message, MEDBOT_PATIENTSPEAK_DELAY)
	var/area/location = get_area(src)
	speak("Medical emergency! [crit_patient || "A patient"] is in critical condition at [location]!", radio_channel)

#undef MEDBOT_NEW_PATIENTSPEAK_DELAY
#undef MEDBOT_PATIENTSPEAK_DELAY
#undef MEDBOT_FREAKOUT_DELAY

#undef MEDBOT_PANIC_NONE
#undef MEDBOT_PANIC_LOW
#undef MEDBOT_PANIC_MED
#undef MEDBOT_PANIC_HIGH
#undef MEDBOT_PANIC_FUCK
#undef MEDBOT_PANIC_ENDING
#undef MEDBOT_PANIC_END
