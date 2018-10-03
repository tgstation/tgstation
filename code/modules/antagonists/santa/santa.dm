/datum/antagonist/santa
	name = "Santa"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE

/datum/antagonist/santa/on_gain()
	. = ..()
	give_equipment()
	give_objective()

/datum/antagonist/santa/greet()
	. = ..()
	to_chat(owner, "<span class='boldannounce'>You are Santa! Your objective is to bring joy to the people on this station. You can conjure more presents using a spell, and there are several presents in your bag.</span>")

/datum/antagonist/santa/proc/give_equipment()
	var/mob/living/carbon/human/H = owner.current
	if(istype(H))
		H.equipOutfit(/datum/outfit/santa)

	owner.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/presents)
	var/obj/effect/proc_holder/spell/targeted/area_teleport/teleport/telespell = new
	telespell.clothes_req = 0 //santa robes aren't actually magical.
	owner.AddSpell(telespell) //does the station have chimneys? WHO KNOWS!

/datum/antagonist/santa/proc/give_objective()
	var/datum/objective/santa_objective = new()
	santa_objective.explanation_text = "Bring joy and presents to the station!"
	santa_objective.completed = 1 //lets cut our santas some slack.
	santa_objective.owner = owner
	objectives |= santa_objective
	
