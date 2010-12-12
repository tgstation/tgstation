/client/proc/only_one()
	set category = "Fun"
	set name = "THERE CAN BE ONLY ONE"

	if(!ticker)
		alert("The game hasn't started yet!")
		return
	for(var/mob/living/carbon/human/H in world)
		if(H.stat == 2 || !(H.client)) continue
		if(checktraitor(H)) continue

		ticker.mode.equip_traitor(H)
		ticker.mode.traitors += H.mind
		H.mind.special_role = "traitor"

		var/datum/objective/steal/steal_objective = new
		steal_objective.owner = H.mind
		steal_objective.target_name = "nuclear authentication disk"
		steal_objective.steal_target = /obj/item/weapon/disk/nuclear
		steal_objective.explanation_text = "Steal a [steal_objective.target_name]."
		H.mind.objectives += steal_objective

		var/datum/objective/hijack/hijack_objective = new
		hijack_objective.owner = H.mind
		H.mind.objectives += hijack_objective

		H << "<B>You are the traitor.</B>"
		var/obj_count = 1
		for(var/datum/objective/OBJ in H.mind.objectives)
			H << "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]"
			obj_count++
		new /obj/item/weapon/pinpointer(H.loc)

	message_admins("\blue [key_name_admin(usr)] used THERE CAN BE ONLY ONE!", 1)
	log_admin("[key_name(usr)] used there can be only one.")