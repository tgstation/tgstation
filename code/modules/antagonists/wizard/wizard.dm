/datum/antagonist/wizard
	name = "\improper Space Wizard"
	roundend_category = "wizards/witches"
	antagpanel_category = "Wizard"
	job_rank = ROLE_WIZARD
	antag_hud_name = "wizard"
	antag_moodlet = /datum/mood_event/focused
	hijack_speed = 0.5
	ui_name = "AntagInfoWizard"
	suicide_cry = "FOR THE FEDERATION!!"
	preview_outfit = /datum/outfit/wizard
	var/give_objectives = TRUE
	var/strip = TRUE //strip before equipping
	var/allow_rename = TRUE
	var/datum/team/wizard/wiz_team //Only created if wizard summons apprentices
	var/move_to_lair = TRUE
	var/outfit_type = /datum/outfit/wizard
	var/wiz_age = WIZARD_AGE_MIN /* Wizards by nature cannot be too young. */
	show_to_ghosts = TRUE

/datum/antagonist/wizard_minion
	name = "Wizard Minion"
	antagpanel_category = "Wizard"
	antag_hud_name = "apprentice"
	show_in_roundend = FALSE
	show_name_in_check_antagonists = TRUE
	/// The wizard team this wizard minion is part of.
	var/datum/team/wizard/wiz_team

/datum/antagonist/wizard_minion/create_team(datum/team/wizard/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	wiz_team = new_team

/datum/antagonist/wizard_minion/apply_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	current_mob.faction |= ROLE_WIZARD
	add_team_hud(current_mob)

/datum/antagonist/wizard_minion/remove_innate_effects(mob/living/mob_override)
	var/mob/living/last_mob = mob_override || owner.current
	last_mob.faction -= ROLE_WIZARD

/datum/antagonist/wizard_minion/on_gain()
	create_objectives()
	return ..()

/datum/antagonist/wizard_minion/proc/create_objectives()
	if(!wiz_team)
		return
	var/datum/objective/custom/custom_objective = new()
	custom_objective.owner = owner
	custom_objective.name = "Serve [wiz_team.master_wizard?.owner]"
	custom_objective.explanation_text = "Serve [wiz_team.master_wizard?.owner]"
	objectives += custom_objective

/datum/antagonist/wizard_minion/get_team()
	return wiz_team

/datum/antagonist/wizard/on_gain()
	equip_wizard()
	if(give_objectives)
		create_objectives()
	if(move_to_lair)
		send_to_lair()
	. = ..()
	if(allow_rename)
		rename_wizard()

/datum/antagonist/wizard/create_team(datum/team/wizard/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	wiz_team = new_team

/datum/antagonist/wizard/get_team()
	return wiz_team

/datum/team/wizard
	name = "wizard team"
	var/datum/antagonist/wizard/master_wizard

/datum/antagonist/wizard/proc/create_wiz_team()
	wiz_team = new(owner)
	wiz_team.name = "[owner.current.real_name] team"
	wiz_team.master_wizard = src

/datum/antagonist/wizard/proc/send_to_lair()
	if(!owner)
		CRASH("Antag datum with no owner.")
	if(!owner.current)
		return
	if(!GLOB.wizardstart.len)
		SSjob.SendToLateJoin(owner.current)
		to_chat(owner, "HOT INSERTION, GO GO GO")
	owner.current.forceMove(pick(GLOB.wizardstart))

/datum/antagonist/wizard/proc/create_objectives()
	switch(rand(1,100))
		if(1 to 30)
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			objectives += kill_objective

			if (!(locate(/datum/objective/escape) in objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = owner
				objectives += escape_objective

		if(31 to 60)
			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = owner
			steal_objective.find_target()
			objectives += steal_objective

			if (!(locate(/datum/objective/escape) in objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = owner
				objectives += escape_objective

		if(61 to 85)
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			objectives += kill_objective

			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = owner
			steal_objective.find_target()
			objectives += steal_objective

			if (!(locate(/datum/objective/survive) in objectives))
				var/datum/objective/survive/survive_objective = new
				survive_objective.owner = owner
				objectives += survive_objective

		else
			if (!(locate(/datum/objective/hijack) in objectives))
				var/datum/objective/hijack/hijack_objective = new
				hijack_objective.owner = owner
				objectives += hijack_objective

/datum/antagonist/wizard/on_removal()
	owner.RemoveAllSpells() // TODO keep track which spells are wizard spells which innate stuff
	return ..()

/datum/antagonist/wizard/proc/equip_wizard()
	if(!owner)
		CRASH("Antag datum with no owner.")
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return
	if(strip)
		H.delete_equipment()
	//Wizards are human by default. Use the mirror if you want something else.
	H.set_species(/datum/species/human)
	if(H.age < wiz_age)
		H.age = wiz_age
	H.equipOutfit(outfit_type)

/datum/antagonist/wizard/ui_static_data(mob/user)
	. = ..()
	var/list/data = list()
	data["objectives"] = get_objectives()
	return data

/datum/antagonist/wizard/proc/rename_wizard()
	set waitfor = FALSE

	var/wizard_name_first = pick(GLOB.wizard_first)
	var/wizard_name_second = pick(GLOB.wizard_second)
	var/randomname = "[wizard_name_first] [wizard_name_second]"
	var/mob/living/wiz_mob = owner.current
	var/newname = sanitize_name(reject_bad_text(tgui_input_text(wiz_mob, "You are the [name]. Would you like to change your name to something else?", "Name change", randomname, MAX_NAME_LEN)))

	if (!newname)
		newname = randomname

	wiz_mob.fully_replace_character_name(wiz_mob.real_name, newname)

/datum/antagonist/wizard/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	M.faction |= ROLE_WIZARD
	add_team_hud(M)

/datum/antagonist/wizard/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	M.faction -= ROLE_WIZARD


/datum/antagonist/wizard/get_admin_commands()
	. = ..()
	.["Send to Lair"] = CALLBACK(src,.proc/admin_send_to_lair)

/datum/antagonist/wizard/proc/admin_send_to_lair(mob/admin)
	owner.current.forceMove(pick(GLOB.wizardstart))

/datum/antagonist/wizard/apprentice
	name = "Wizard Apprentice"
	antag_hud_name = "apprentice"
	var/datum/mind/master
	var/school = APPRENTICE_DESTRUCTION
	outfit_type = /datum/outfit/wizard/apprentice
	wiz_age = APPRENTICE_AGE_MIN

/datum/antagonist/wizard/apprentice/greet()
	to_chat(owner, "<B>You are [master.current.real_name]'s apprentice! You are bound by magic contract to follow [master.p_their()] orders and help [master.p_them()] in accomplishing [master.p_their()] goals.")
	owner.announce_objectives()

/datum/antagonist/wizard/apprentice/equip_wizard()
	. = ..()
	if(!owner)
		CRASH("Antag datum with no owner.")
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return
	switch(school)
		if(APPRENTICE_DESTRUCTION)
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/projectile/magic_missile(null))
			owner.AddSpell(new /obj/effect/proc_holder/spell/aimed/fireball(null))
			to_chat(owner, "<B>Your service has not gone unrewarded, however. Studying under [master.current.real_name], you have learned powerful, destructive spells. You are able to cast magic missile and fireball.")
		if(APPRENTICE_BLUESPACE)
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/area_teleport/teleport(null))
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt(null))
			to_chat(owner, "<B>Your service has not gone unrewarded, however. Studying under [master.current.real_name], you have learned reality-bending mobility spells. You are able to cast teleport and ethereal jaunt.")
		if(APPRENTICE_HEALING)
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/charge(null))
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/forcewall(null))
			H.put_in_hands(new /obj/item/gun/magic/staff/healing(H))
			to_chat(owner, "<B>Your service has not gone unrewarded, however. Studying under [master.current.real_name], you have learned life-saving survival spells. You are able to cast charge and forcewall.")
		if(APPRENTICE_ROBELESS)
			owner.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock(null))
			owner.AddSpell(new /obj/effect/proc_holder/spell/pointed/mind_transfer(null))
			to_chat(owner, "<B>Your service has not gone unrewarded, however. Studying under [master.current.real_name], you have learned stealthy, robeless spells. You are able to cast knock and mindswap.")

/datum/antagonist/wizard/apprentice/create_objectives()
	var/datum/objective/protect/new_objective = new /datum/objective/protect
	new_objective.owner = owner
	new_objective.target = master
	new_objective.explanation_text = "Protect [master.current.real_name], the wizard."
	objectives += new_objective

//Random event wizard
/datum/antagonist/wizard/apprentice/imposter
	name = "Wizard Imposter"
	show_in_antagpanel = FALSE
	allow_rename = FALSE
	move_to_lair = FALSE

/datum/antagonist/wizard/apprentice/imposter/greet()
	. = ..()
	to_chat(owner, "<B>Trick and confuse the crew to misdirect malice from your handsome original!</B>")
	owner.announce_objectives()

/datum/antagonist/wizard/apprentice/imposter/equip_wizard()
	var/mob/living/carbon/human/master_mob = master.current
	var/mob/living/carbon/human/H = owner.current
	if(!istype(master_mob) || !istype(H))
		return
	if(master_mob.ears)
		H.equip_to_slot_or_del(new master_mob.ears.type, ITEM_SLOT_EARS)
	if(master_mob.w_uniform)
		H.equip_to_slot_or_del(new master_mob.w_uniform.type, ITEM_SLOT_ICLOTHING)
	if(master_mob.shoes)
		H.equip_to_slot_or_del(new master_mob.shoes.type, ITEM_SLOT_FEET)
	if(master_mob.wear_suit)
		H.equip_to_slot_or_del(new master_mob.wear_suit.type, ITEM_SLOT_OCLOTHING)
	if(master_mob.head)
		H.equip_to_slot_or_del(new master_mob.head.type, ITEM_SLOT_HEAD)
	if(master_mob.back)
		H.equip_to_slot_or_del(new master_mob.back.type, ITEM_SLOT_BACK)

	//Operation: Fuck off and scare people
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/area_teleport/teleport(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/turf_teleport/blink(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt(null))

/datum/antagonist/wizard/academy
	name = "Academy Teacher"
	show_in_antagpanel = FALSE
	outfit_type = /datum/outfit/wizard/academy
	move_to_lair = FALSE

/datum/antagonist/wizard/academy/equip_wizard()
	. = ..()

	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt)
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/projectile/magic_missile)
	owner.AddSpell(new /obj/effect/proc_holder/spell/aimed/fireball)

	var/mob/living/M = owner.current
	if(!istype(M))
		return

	var/obj/item/implant/exile/Implant = new/obj/item/implant/exile(M)
	Implant.implant(M)

/datum/antagonist/wizard/academy/create_objectives()
	var/datum/objective/new_objective = new("Protect Wizard Academy from the intruders")
	new_objective.owner = owner
	objectives += new_objective

//Solo wizard report
/datum/antagonist/wizard/roundend_report()
	var/list/parts = list()

	parts += printplayer(owner)

	var/count = 1
	var/wizardwin = 1
	for(var/datum/objective/objective in objectives)
		if(objective.check_completion())
			parts += "<B>Objective #[count]</B>: [objective.explanation_text] [span_greentext("Success!")]"
		else
			parts += "<B>Objective #[count]</B>: [objective.explanation_text] [span_redtext("Fail.")]"
			wizardwin = 0
		count++

	if(wizardwin)
		parts += span_greentext("The wizard was successful!")
	else
		parts += span_redtext("The wizard has failed!")

	if(owner.spell_list.len>0)
		parts += "<B>[owner.name] used the following spells: </B>"
		var/list/spell_names = list()
		for(var/obj/effect/proc_holder/spell/S in owner.spell_list)
			spell_names += S.name
		parts += spell_names.Join(", ")

	return parts.Join("<br>")

//Wizard with apprentices report
/datum/team/wizard/roundend_report()
	var/list/parts = list()

	parts += "<span class='header'>Wizards/witches of [master_wizard.owner.name] team were:</span>"
	parts += master_wizard.roundend_report()
	parts += " "
	parts += "<span class='header'>[master_wizard.owner.name] apprentices and minions were:</span>"
	parts += printplayerlist(members - master_wizard.owner)

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"
