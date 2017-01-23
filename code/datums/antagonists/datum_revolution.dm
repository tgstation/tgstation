/datum/team/revolutionary
	name = ROLE_REV

//Regular rev

/datum/antagonist/team/revolutionary
	name = ROLE_REV

	text_on_gain = "<span class='danger'><FONT size = 3>You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill the heads to win the revolution!</FONT></span>"
	text_on_lose = "<span class='danger'><FONT size = 3>You have been brainwashed! You are no longer a revolutionary! Your memory is hazy from the time you were a rebel...the only thing you remember is the name of the one who brainwashed you...</FONT></span>"

	give_special_equipment = FALSE

	has_objectives = FALSE

/datum/antagonist/team/revolutionary/apply_innate_effects()
	. = ..()
	//update_rev_icons_added(owner)
	if(team)
		team.members += owner

/datum/antagonist/team/revolutionary/remove_innate_effects()
	. = ..()
	//update_rev_icons_removed(owner)

/datum/antagonist/team/revolutionary/head
	text_on_gain = "<span class='userdanger'>You are a member of the revolutionaries' leadership!</span>"

	give_special_equipment = TRUE

	has_objectives = TRUE

/datum/antagonist/team/revolutionary/head/give_equipment()
	if(!(owner && owner.current))
		return
	if(!ishuman(owner.current))
		return
	var/mob/living/carbon/human/O = owner.current

	var/list/items_to_spawn = list(/obj/item/device/assembly/flash, /obj/item/toy/crayon/spraycan, /obj/item/clothing/glasses/hud/security/chameleon)

	var/list/slots_to_equip = list("backpack" = slot_in_backpack, "left pocket" = slot_l_store, "right pocket" = slot_r_store)

	for(var/i in items_to_spawn)
		var/obj/item/I = new i
		var/slot_equipped = O.equip_in_one_of_slots(I, slots_to_equip)
		if(!slot_equipped)
			O << "Your employer was unable to get you \a [I]."

/datum/antagonist/team/revolutionary/head/generate_objectives()
	var/list/heads = list()// = ticker.threat.get_living_heads() //make it a threat datum objective or something
	for(var/h in heads)
		var/datum/mind/H = h
		var/datum/objective/mutiny/viva = new
		viva.owner = owner
		viva.target = H
		viva.explanation_text = "Assassinate or exile [H.name], the [H.assigned_role]."
		current_objectives += viva