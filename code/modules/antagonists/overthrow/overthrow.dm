#define INITIAL_CRYSTALS 5 // initial telecrystals in the boss' uplink

/datum/antagonist/overthrow
	name = "Syndicate mutineer"
	roundend_category = "syndicate mutineers"
	antagpanel_category = "Syndicate Mutineers"
	job_rank = ROLE_TRAITOR
	var/datum/team/overthrow/team
	var/static/list/possible_useful_items

/datum/antagonist/overthrow/New()
	..()
	if(!possible_useful_items)
		possible_useful_items = list(/obj/item/gun/ballistic/automatic/pistol, /obj/item/storage/box/syndie_kit/throwing_weapons, /obj/item/pen/edagger, /obj/item/pen/sleepy, \
									/obj/item/soap/syndie, /obj/item/card/id/syndicate, /obj/item/storage/box/syndie_kit/chameleon)

/datum/antagonist/overthrow/on_gain()
	create_team()
	objectives += team.objectives
	owner.objectives += objectives
	..()
	equip_overthrow()

/datum/antagonist/overthrow/create_team()
	if(!team)
		team = new()
		team.add_member(owner)
		team.create_objectives()
		var/team_name = stripped_input(owner, "Name your team:", "Team name", , MAX_NAME_LEN)
		if(!team_name)
			to_chat(owner, "<span class='danger'>You must give a name to your team!</span>")
			create_team()
			return
		team.name = team_name
	else
		team.add_member(owner)

/datum/antagonist/overthrow/apply_innate_effects()
	..()
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/traitor_mob = owner.current
		if(traitor_mob && istype(traitor_mob))
			if(!silent)
				to_chat(traitor_mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			traitor_mob.dna.remove_mutation(CLOWNMUT)
	update_overthrow_icons_added()

/datum/antagonist/overthrow/remove_innate_effects()
	update_overthrow_icons_removed()
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/traitor_mob = owner.current
		if(traitor_mob && istype(traitor_mob))
			traitor_mob.dna.add_mutation(CLOWNMUT)
	..()

/datum/antagonist/overthrow/proc/update_overthrow_icons_added(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/overthrowhud = GLOB.huds[team.hud_entry_num]
	if(!overthrowhud)
		overthrowhud = new()
		team.hud_entry_num = GLOB.huds.len + 1 // the index of the hud inside huds list
		GLOB.huds += overthrowhud
	overthrowhud.join_hud(owner.current)
	set_antag_hud(owner.current, "traitor")

/datum/antagonist/overthrow/proc/update_overthrow_icons_removed(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/overthrowhud = GLOB.huds[team.hud_entry_num]
	if(overthrowhud)
		overthrowhud.leave_hud(owner.current)
		set_antag_hud(owner.current, null)

// Gives the storage implant with a random item. They're sleeping agents, after all.
/datum/antagonist/overthrow/proc/equip_overthrow()
	if(!owner || !owner.current)
		return
	var/obj/item/implant/storage/S = locate(/obj/item/implant/storage) in owner.current
	if(!S)
		S = new(owner.current)
		S.implant(owner.current)
	var/I = pick(possible_useful_items)
	if(ispath(I)) // in case some admin decides to fuck the list up for fun
		I = new I()
		SEND_SIGNAL(S, COMSIG_TRY_STORAGE_INSERT, I, null, TRUE, TRUE)

/datum/antagonist/overthrow/proc/equip_overthrow_boss()
	if(!owner || !owner.current)
		return
	var/mob/living/carbon/human/H = owner.current
	// Give uplink
	var/obj/item/uplink_holder = owner.equip_traitor(uplink_owner = src)
	var/datum/component/uplink/uplink = uplink_holder.GetComponent(/datum/component/uplink)
	uplink.telecrystals = INITIAL_CRYSTALS
	// Give AI hacking board
	var/obj/item/aiModule/core/full/overthrow/O = new(H)
	var/list/slots = list (
		"backpack" = SLOT_IN_BACKPACK,
		"left pocket" = SLOT_L_STORE,
		"right pocket" = SLOT_R_STORE
	)
	var/where = H.equip_in_one_of_slots(O, slots)
	if (!where)
		to_chat(H, "The Syndicate were unfortunately unable to get you the AI module.")
	else
		to_chat(H, "Use the AI board in your [where] to take control of the AI, as requested by the Syndicate.")
	// Give the implant converter
	var/obj/item/implanter/overthrow/I = new(H)
	where = H.equip_in_one_of_slots(I, slots)
	if (!where)
		to_chat(H, "The Syndicate were unfortunately unable to get you a converter implant.")
	else
		to_chat(H, "Use the implanter in your [where] to wake up sleeping syndicate agents, so that they can aid you.")

/datum/antagonist/overthrow/get_team()
	return team

/datum/antagonist/overthrow/greet()
	to_chat(owner.current, "<B><font size=3 color=red>You are a syndicate sleeping agent. Your job is to stage a swift, fairly bloodless coup. </font></B>")

/datum/antagonist/overthrow/boss
	name = "Syndicate initial eutineers"

/datum/antagonist/overthrow/boss/on_gain()
	..()
	equip_overthrow_boss()
