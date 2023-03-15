/datum/symptom/gateway
	name = "Bluespace Instability"
	desc = "This virus increases the host's sensitivity to fluxuations in bluespace, causing random and minor teleportation as they pass through unseen holes of bluespace."
	stealth = 0
	resistance = 2
	stage_speed = -2
	transmission = -2
	level = 8 		//Balancing stats and level around Thermal Retrostable Displacement
	severity = 2 	//Starts annoying and potentially harmful, but not directly.
	symptom_delay_min = 8
	symptom_delay_max = 10
	var/random_teleportation = TRUE
	var/has_prophet = FALSE
	var/has_blink = FALSE
	var/blink_distance = 2
	var/blink_cooldown
	threshold_desc = "<b>Stage Speed:</b> Increases the maximum distance that the infected can be sent with every teleport.<br>\
					<b>Resistance 12:</b> Gives the infected more control over their teleportation and no longer causes it to happen at random.<br>\
					<b>Stealth 4:</b> Allows the infected to percieve the rifts of bluespace in their path instead of running in blindly."

/datum/symptom/gateway/severityset(datum/disease/advance/A)
	. = ..()
	if(A.resistance >= 12 || A.stealth >= 4)
		severity -= 2

/datum/symptom/gateway/Start(datum/disease/advance/A)
	if(!..())
		return
	blink_distance = blink_distance + (round(A.stage_rate/4))
	if(A.stage_rate <= 0)
		blink_distance = 2
	blink_cooldown = (blink_distance * 10) - 10 //Between 10 seconds for a 2 tile blink and 50 seconds for a 6 tile blink. This is Blink with the cooldown of Teleport.
	if(A.resistance >= 12)
		random_teleportation = FALSE
		has_blink = TRUE
	if(A.stealth >= 4)
		random_teleportation = FALSE
		has_prophet = TRUE

/datum/symptom/gateway/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob

	if(A.stage >= 2 && random_teleportation)
		if(prob(15))
			to_chat(M, "<span class='warning'>[pick(
			"You feel unstable.",
			"There's a blue glow in the edge of your sight.",
			"You observe a bit of dust vanish in mid-air.",
			"The flows of bluespace are whimsical today.",
			"An extremity vanishes and reappears in the blink of an eye.",
			"It seems like you are in two places at once.",
			"You feel stretched thin.")]</span>")
	if(A.stage >= 4) //Bluespace Prophet comes earlier than the blink spell and random teleportation.
		if(has_prophet && ishuman(M))
			var/mob/living/carbon/human/H = A.affected_mob
			has_prophet = FALSE
			H.gain_trauma(/datum/brain_trauma/special/bluespace_prophet, TRAUMA_RESILIENCE_ABSOLUTE)

	if(A.stage >= 5)	//Random teleports or blink, both based off the distance of teleportation
		if(has_blink && ishuman(M))
			has_blink = FALSE
			var/mob/living/carbon/C = A.affected_mob
			if(locate(/obj/effect/proc_holder/spell/targeted/turf_teleport/viro_blink) in C.mob_spell_list)
				return
			var/obj/effect/proc_holder/spell/targeted/turf_teleport/viro_blink/Blink = new()
			Blink.outer_tele_radius = src.blink_distance
			Blink.charge_max = (src.blink_cooldown * 10)
			Blink.charge_counter = (src.blink_cooldown * 10)
			M.AddSpell(Blink)
			to_chat(M, "<span class='notice'>You feel charged with bluespace energy!</span>")
		if(random_teleportation && prob(15))
			do_teleport(M, get_turf(M), blink_distance, channel = TELEPORT_CHANNEL_BLUESPACE)
			M.visible_message("<span class='warning'>[M] [pick("stumbles into a hidden bluespace portal!", "suddenly vanishes from sight!", "is there one moment, then isn't!", "vanishes in a cloud of sparks!", "is no longer there!", "rudely leaves without a word.", "walks into an unseen gateway.", "wasn't where they were a moment ago.", "shifts position before your eyes.", "warps away in a flash of blue.", "catches a case of the Freakin' Gones!", "goes poof!", "blinks and...Flash! Bang! Alakazam! They're gone!")]</span>")

/datum/symptom/gateway/End(datum/disease/advance/A)
	. = ..()
	var/mob/living/carbon/M = A.affected_mob

	if(ishuman(M))
		var/mob/living/carbon/human/H = A.affected_mob
		M.RemoveSpell(/obj/effect/proc_holder/spell/targeted/turf_teleport/viro_blink)
		H.cure_trauma_type(/datum/brain_trauma/special/bluespace_prophet, TRAUMA_RESILIENCE_ABSOLUTE)

/obj/effect/proc_holder/spell/targeted/turf_teleport/viro_blink //Between 10 seconds for a 2 tile blink and 50 seconds for a 6 tile blink. This is Blink with the cooldown of Teleport.
	var/magic_check = FALSE
	var/holy_check = FALSE
	name = "Bluespace Jump"
	desc = "This symptom teleports you a short distance."
	charge_counter = 0
	charge_max = 20
	clothes_req = FALSE
	range = -1
	include_user = TRUE
	charge_type = "recharge"

	inner_tele_radius = 0
	outer_tele_radius = 0 //Between two and six tiles, based off stage speed

	action_icon = 'monkestation/icons/mob/actions/actions_viro.dmi'
	action_background_icon_state = "bg_viro"
	action_icon_state = "viro_blink"
	sound1 = 'sound/magic/blink.ogg'



