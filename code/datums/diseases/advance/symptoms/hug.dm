/datum/symptom/hugging
	name = "Hugging"
	desc = "The virus causes the host to uncontrollably hug, pet, or otherwise nonharmfully interact with nearby creatures. This symptom only affects sapient creatures."
	stealth = -1
	resistance = -2
	stage_speed = 2
	transmittable = 3
	level = 8
	severity = 0
	base_message_chance = 100
	symptom_delay_min = 1 //not a typo
	symptom_delay_max = 10
	var/swap = FALSE
	threshold_desc = "<b>Resistance 9:</b> If the host is holding an item in their active hand but not in their off hand, the host will switch to their off hand before attempting to hug someone. Note that their active hand will NOT switch back once the hug attempt has been completed.<br>\
					  <b>Stage Speed 7:</b> The host hugs nearby people much more often."

/datum/symptom/hugging/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["resistance"] >= 9)
		swap = TRUE
	if(A.properties["stage_rate"] >= 7)
		symptom_delay_max = 1 //also not a typo

/datum/symptom/hugging/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage >= 4)
		var/mob/living/carbon/M = A.affected_mob
		if(M.mind) //reduces the spam from infected monkeys and such
			if(swap)
				var/obj/item/I = M.get_active_held_item()
				var/obj/item/O = M.get_inactive_held_item()
				if(I && !O)
					M.swap_hand() //No, we're not going to swap their hand back at the end. This threshold effect is SUPPOSED to be incredibly annoying.
			if(M.get_active_held_item()) //I'm not moving I and O out of the swap if statement and using them again for this check in case someone had 3+ hands or something like that
				return //no accidentally slapping people with toolboxes and stuff
			var/prev_intent = M.a_intent
			M.a_intent = INTENT_HELP
			var/list/mob/living/targets = list()
			for(var/mob/L in oview(M, 1))
				if(isliving(L))
					targets += L
			M.ClickOn(pick(targets))
			M.a_intent = prev_intent
