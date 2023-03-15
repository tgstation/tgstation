/datum/symptom/goat
	name = "Caprinae Muscular Hypertrophy"
	desc = "This viral infection causes the afflicted to experience a rapid growth in leg muscles, may cause increased aggression and a desire to climb."
	//Stats will be based off of Necropolis Seed because this symptom is powerful and should be slow
	stealth = -1
	resistance = 3
	stage_speed = -8 			//Threshold will be based off this, so it needs to start low.
	transmission = -4 			//Equal to the hardest hitting symptoms. Not possible to make airborne
	level = 9 					//Powerful symptom, should be rare(ground sample only) as well as one of the few positive level 9s.
	severity = -1 				//Positive with a catch.
	symptom_delay_min = 15
	symptom_delay_max = 20
	var/speed_bonus = -0.10 	//Negative values increase speed, positive decreases.
	var/has_headbutt = FALSE
	threshold_desc = "<b>Resistance 6: </b>The infected becomes slightly quicker on their feet.<br>\
					<b>Stage Speed 10: </b>The legs of the infected contain enough muscle mass to leap forward in a charge."

/datum/symptom/goat/severityset(datum/disease/advance/A)
	. = ..()
	if(A.resistance >= 6 || A.stage_rate >= 10)
		severity -= 2

/datum/symptom/goat/Start(datum/disease/advance/A)
	if(!..())
		return
	RegisterSignal(A.affected_mob, COMSIG_MOB_SAY, .proc/handle_speech) //Causes the infected to 'roll' their A's
	if(A.resistance >= 6)
		speed_bonus = -0.2 //While fairly low, consider triple-stacked viruses. That is 60% possible speed.
	if(A.stage_rate >= 10)
		has_headbutt = TRUE

/datum/symptom/goat/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob

	if(A.stage >= 2)
		if(prob(10)) //Works as both a virus 'warning' and hints at effects of the virus itself.
			to_chat(M, "<span class='warning'>[pick(
			"You feel like chewing on some cans.",
			"For some reason, you want to climb to high places.",
			"Vines are no match for you.",
			"You're starting to understand why Pete is so mad.",
			"You have a desire to headbutt someone.",
			"You let out a bleat under your breath.")]</span>")

	if(A.stage >= 3 && speed_bonus && ishuman(M)) //Grants speed, trash eating trait and climb speed bonus.
		M.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=speed_bonus, blacklisted_movetypes=(FLYING|FLOATING))
		speed_bonus = FALSE
		var/mob/living/carbon/human/H = A.affected_mob
		ADD_TRAIT(H, TRAIT_TRASH_EATER, type)
		to_chat(M, "<span class='notice'>You feel more limber and able to climb with ease!</span>")

	if(A.stage >= 5 && has_headbutt) 				//Checks for existing headbutt ability before granting it.
		var/mob/living/carbon/C = A.affected_mob
		if(locate(/obj/effect/proc_holder/spell/aimed/headbutt) in C.mob_spell_list) //Check for existing headbutt.
			return
		var/obj/effect/proc_holder/spell/aimed/headbutt/headbuttgrant = new()
		M.AddSpell(headbuttgrant)
		to_chat(M, "<span class='notice'>You're ready to charge!</span>")
		has_headbutt = FALSE

/datum/symptom/goat/End(datum/disease/advance/A)
	. = ..()
	var/mob/living/carbon/M = A.affected_mob
	M.remove_movespeed_modifier(type)
	if(ishuman(M))
		var/mob/living/carbon/human/H = A.affected_mob
		REMOVE_TRAIT(H, TRAIT_TRASH_EATER, type)
	M.RemoveSpell(/obj/effect/proc_holder/spell/aimed/headbutt)
	UnregisterSignal(M, COMSIG_MOB_SAY)

/datum/symptom/goat/proc/handle_speech(datum/source, list/speech_args) //Creates a "baa" effect on the infected's speech
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	var/list/split_message = splittext(message, "")
	for (var/i in 1 to length(split_message))
		if(findtext(split_message[i], "a"))
			if(prob(25))
				split_message[i] = pick("a-a-a", "a-a")
	message = jointext(split_message, "")
	speech_args[SPEECH_MESSAGE] = message

/obj/effect/proc_holder/spell/aimed/headbutt
	name = "Headbutt"
	desc = "Causes you to charge forward towards a nearby target"
	charge_type = "recharge"
	charge_max	= 150
	cooldown_min = 150
	clothes_req = FALSE
	projectile_type = null
	action_icon = 'monkestation/icons/mob/actions/actions_viro.dmi'
	action_background_icon_state = "bg_viro"
	base_icon_state = "viro_goat0"
	action_icon_state = "viro_goat1"
	active_msg = "You ready yourself to headbutt!"
	deactive_msg = "You relax your muscles."

/obj/effect/proc_holder/spell/aimed/headbutt/update_icon()
	if(!action)
		return
	if(active)
		action.button_icon_state = base_icon_state
	else
		action.button_icon_state = action_icon_state
	action.UpdateButtonIcon()
	return

/obj/effect/proc_holder/spell/aimed/headbutt/cast(list/targets, mob/user = usr)
	var/target = get_turf(targets[1])
	var/mob/living/M = user
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = user
		if(H.legcuffed) 					//No headbutts while your LEGS are cuffed!
			user.visible_message("<span class='warning'>[user] trips while trying to charge!</span>")
			M.Paralyze(20)
			return
	user.throwforce = 25 //Just enough to very slowly break a door, window or crate. 25 hits on a crate.
	user.emote("scream")
	user.visible_message("<span class='warning'>[user] charges forward!</span>")
	user.throw_at(target, 4, 4)
	M.Paralyze(20) 	//You're stunned, hit or miss
	spawn(10) 		//Waits on the hit/miss to apply brain damage and readjust the throwforce.
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2) //Very minor brain damage since you're hitting your head against things.
		user.throwforce = 10
