#define INITIAL_CRYSTALS 5 // initial telecrystals in the boss' uplink

// Syndicate mutineer agents. They're agents selected by the Syndicate to take control of stations when assault teams like nuclear operatives cannot be sent.
// They sent teams made of 3 agents, of which only one is woke up at round start. The others are, lore-wise, sleeping agents and must be implanted with the converter to wake up.
// Mechanics wise, it's just 1 dude per team and he can convert maximum 2 more people of his choice, based on the implanter use var, Upon converting, the newly made guys are given access
// to a storage implant they came with when the Syndicate sent them aboard, with one random low-cost traitor item. The initial agent also has this. The only difference between
// initial agents and converted ones is that the initial agent has the items required to convert people and the AI.
/datum/antagonist/overthrow
	name = "Syndicate mutineer"
	roundend_category = "syndicate mutineers"
	antagpanel_category = "Syndicate Mutineers"
	job_rank = ROLE_TRAITOR // simply use the traitor preference & jobban settings
	var/datum/team/overthrow/team
	var/static/list/possible_useful_items

// Overthrow agent. The idea is based on sleeping agents being sent as crewmembers, with one for each team that starts woken up who can also wake up others with their converter implant.
// Obviously they can just convert anyone, the idea of sleeping agents is just lore. This also explains why this antag type has no deconversion way: they're traitors. Traitors cannot be
// deconverted.
// Generates the list of possible items for the storage implant given on_gain
/datum/antagonist/overthrow/New()
	..()
	if(!possible_useful_items)
		possible_useful_items = list(/obj/item/gun/ballistic/automatic/pistol, /obj/item/storage/box/syndie_kit/throwing_weapons, /obj/item/pen/edagger, /obj/item/pen/sleepy, \
									/obj/item/soap/syndie, /obj/item/card/id/syndicate, /obj/item/storage/box/syndie_kit/chameleon)

// Sets objectives, equips all antags with the storage implant.
/datum/antagonist/overthrow/on_gain()
	objectives += team.objectives
	..()
	owner.announce_objectives()
	equip_overthrow()
	owner.special_role = ROLE_OVERTHROW

/datum/antagonist/overthrow/on_removal()
	owner.special_role = null
	..()

// Creates the overthrow team, or sets it. The objectives are static for all the team members.
/datum/antagonist/overthrow/create_team(datum/team/overthrowers)
	if(!overthrowers)
		team = new()
		team.add_member(owner)
		name_team()
		team.create_objectives()
	else
		team = overthrowers
		team.add_member(owner)

// Used to name the team at round start. If no name is passed, a syndicate themed one is given randomly.
/datum/antagonist/overthrow/proc/name_team()
	var/team_name = stripped_input(owner.current, "Name your team:", "Team name", , MAX_NAME_LEN)
	var/already_taken = FALSE
	for(var/datum/antagonist/overthrow/O in GLOB.antagonists)
		if(team_name == O.name)
			already_taken = TRUE
			break
	if(!team_name || already_taken) // basic protection against two teams with the same name. This could still happen with extreme unluck due to syndicate_name() but it shouldn't break anything.
		team.name = syndicate_name()
		to_chat(owner, "<span class='danger'>Since you gave [already_taken ? "an already used" : "no"] name, your team's name has been randomly generated: [team.name]!</span>")
		return
	team.name = team_name

// CLOWNMUT removal and HUD creation/being given
/datum/antagonist/overthrow/apply_innate_effects()
	..()
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/traitor_mob = owner.current
		if(traitor_mob && istype(traitor_mob))
			if(!silent)
				to_chat(traitor_mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			traitor_mob.dna.remove_mutation(CLOWNMUT)
	update_overthrow_icons_added()

// The opposite
/datum/antagonist/overthrow/remove_innate_effects()
	update_overthrow_icons_removed()
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/traitor_mob = owner.current
		if(traitor_mob && istype(traitor_mob))
			traitor_mob.dna.add_mutation(CLOWNMUT)
	..()

/datum/antagonist/overthrow/get_admin_commands()
	. = ..()
	.["Give storage with random item"] = CALLBACK(src,.proc/equip_overthrow)
	.["Give overthrow boss equip"] = CALLBACK(src,.proc/equip_initial_overthrow_agent)

// Dynamically creates the HUD for the team if it doesn't exist already, inserting it into the global huds list, and assigns it to the user. The index is saved into a var owned by the team datum.
/datum/antagonist/overthrow/proc/update_overthrow_icons_added(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/overthrowhud = GLOB.huds[team.hud_entry_num]
	if(!overthrowhud)
		overthrowhud = new()
		team.hud_entry_num = GLOB.huds.len + 1 // the index of the hud inside huds list
		GLOB.huds += overthrowhud
	overthrowhud.join_hud(owner.current)
	set_antag_hud(owner.current, "traitor")
// Removes hud. Destroying the hud datum itself in case the team is deleted is done on team Destroy().
/datum/antagonist/overthrow/proc/update_overthrow_icons_removed(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/overthrowhud = GLOB.huds[team.hud_entry_num]
	if(overthrowhud)
		overthrowhud.leave_hud(owner.current)
		set_antag_hud(owner.current, null)

// Gives the storage implant with a random item. They're sleeping agents, after all.
/datum/antagonist/overthrow/proc/equip_overthrow()
	if(!owner || !owner.current || !ishuman(owner.current)) // only equip existing human overthrow members. This excludes the AI, in particular.
		return
	var/obj/item/implant/storage/S = locate(/obj/item/implant/storage) in owner.current
	if(!S)
		S = new(owner.current)
		S.implant(owner.current)
	var/I = pick(possible_useful_items)
	if(ispath(I)) // in case some admin decides to fuck the list up for fun
		I = new I()
		SEND_SIGNAL(S, COMSIG_TRY_STORAGE_INSERT, I, null, TRUE, TRUE)

// Equip the initial overthrow agent. Manually called in overthrow gamemode, when the initial agents are chosen. Gives uplink, AI module board and the converter.
/datum/antagonist/overthrow/proc/equip_initial_overthrow_agent()
	if(!owner || !owner.current || !ishuman(owner.current))
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
	var/obj/item/overthrow_converter/I = new(H)
	where = H.equip_in_one_of_slots(I, slots)
	if (!where)
		to_chat(H, "The Syndicate were unfortunately unable to get you a converter implant.")
	else
		to_chat(H, "Use the implanter in your [where] to wake up sleeping syndicate agents, so that they can aid you.")

/datum/antagonist/overthrow/get_team()
	return team

/datum/antagonist/overthrow/greet()
	to_chat(owner.current, "<B><font size=3 color=red>You are a syndicate sleeping agent!</font> <font size=2 color=red>Your job is to stage a swift, fairly bloodless coup. Your team has a two-use converter that can be used to convert \
			anyone you want, although mind shield implants need to be removed firstly for it to work. Your team also has a special version of the Syndicate module to be used to convert the AI, too. You \
			will be able to use the special storage implant you came aboard with, which contains a random, cheap item from our special selection which will aid in your mission. \
			Your team objective is to deal with the heads, the AI and a special target who angered us for several reasons which you're not entitled to know. Converting to your team will let us \
			take control of the station faster, so it should be prioritized, especially over killing, which should be avoided where possible. The other Syndicate teams are NOT friends and should not \
			be trusted.</font></B>")
