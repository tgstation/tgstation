/area/awaymission/vr/hub
	name = "VrHub"
	icon_state = "away"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/obj/effect/mob_spawn/human/virtual_reality
	name = "Network Relay"
	desc = "A machine with flashing buttons. It seems to be some sort of teleportation pad. There doesn't seem to be any way to activate it from this side."
	mob_name = "Virtual Reality Human"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "qpad-idle"
	density = TRUE
	roundstart = FALSE
	death = FALSE
	uses = -1 // infinite
	random = TRUE
	mob_species = /datum/species/human
	outfit = /datum/outfit/vr
	flavour_text = "<span class='big bold'>You have connected to another stations virtual reality system. Your objective is to learn as much as you can about teamwork across a language barrier.</span>"
	assignedrole = "Vr"

/obj/effect/portal/permanent/one_way/recall
	name = "recall portal"
	desc = "Gives you a one time ability to return to this portal once you have entered."
	mech_sized = TRUE
	keep = TRUE
	var/datum/outfit/equipment // optional outfit to equip upon entering

/obj/effect/portal/permanent/one_way/recall/Crossed(atom/movable/AM, oldloc)
	if(ismob(AM))
		var/mob/user = AM
		var/check = locate(/obj/effect/proc_holder/spell/portal_recall) in user.mind.spell_list
		if(check)
			var/obj/effect/proc_holder/spell/portal_recall/mob_recall = check
			for(var/obj/effect/portal/permanent/one_way/recall/P in mob_recall.recall_portals)
				if(src == P)
					return ..(AM, oldloc, force_stop = TRUE) // don't teleport if they have a recall spell with this portal already (or have just teleported onto it)
	return ..()

/obj/effect/portal/permanent/one_way/recall/teleport(atom/movable/M, force = FALSE)
	. = ..()
	if(. && ismob(M))
		var/mob/user = M
		var/findspell = locate(/obj/effect/proc_holder/spell/portal_recall) in user.mind.spell_list
		var/obj/effect/proc_holder/spell/portal_recall/personal_recall = findspell ? findspell : new
		personal_recall.recall_portals += src
		if(!findspell)
			user.mind.AddSpell(personal_recall)
		if(equipment && ishuman(user))
			var/mob/living/carbon/human/H = user
			H.delete_equipment()
			H.equipOutfit(equipment)

/obj/effect/proc_holder/spell/portal_recall
	name = "Portal Recall"
	desc = "This will teleport you back to your previously used portal. One use only."
	clothes_req = FALSE
	action_icon_state = "blink"
	var/list/recall_portals = list()

/obj/effect/proc_holder/spell/portal_recall/Click(mob/user = usr)
	if(!recall_portals.len)
		user.mind.RemoveSpell(src) // remove spell if no portals left
	var/turf/recall_turf = get_turf(recall_portals[recall_portals.len])
	if(recall_turf)
		do_teleport(user, recall_turf, 0, no_effects = FALSE, channel = TELEPORT_CHANNEL_BLUESPACE)
		recall_portals -= recall_portals[recall_portals.len]
		if(!recall_portals.len)
			user.mind.RemoveSpell(src) // remove spell if no portals left

/obj/effect/portal/permanent/one_way/recall/megafauna_arena
	name = "Megafauna Arena Portal"
	desc = "Fight against megafauna in the safety of virtual reality."
	equipment = /datum/outfit/job/miner/equipped/vr
	id = "vr megafauna arena"

/obj/effect/portal/permanent/one_way/destroy/megafauna_arena
	name = "Megafauna Arena Exit Portal"
	id = "vr megafauna arena"

/obj/effect/portal/permanent/one_way/recall/murderdome
	name = "Murderdome Portal"
	desc = "Active, but only occasionally. Leads to an endless battle arena."
	equipment = /datum/outfit/death_commando
	id = "vr murderdome"

/obj/effect/portal/permanent/one_way/destroy/murderdome
	name = "Murderdome Exit Portal"
	id = "vr murderdome"

/obj/effect/portal/permanent/one_way/recall/syndicate
	name = "Syndicate Portal"
	desc = "Active, but only occasionally. Leads to a syndicate training program."
	equipment = /datum/outfit/vr/syndicate
	id = "vr syndicate"

/obj/effect/portal/permanent/one_way/destroy/syndicate
	name = "Syndicate Exit Portal"
	id = "vr syndicate"

/obj/effect/portal/permanent/one_way/recall/snowdin
	name = "Snowdin Portal"
	desc = "Active, but only occasionally. Leads to a snowed in wasteland."
	equipment = /datum/outfit/vr/snowtide
	id = "vr snowdin"

/obj/effect/portal/permanent/one_way/destroy/snowdin
	name = "Snowdin Exit Portal"
	id = "vr snowdin"
