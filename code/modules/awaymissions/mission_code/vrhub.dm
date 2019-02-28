/area/awaymission/vr/general
	name = "VrGeneral"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/area/awaymission/vr/hub
	name = "VrHub"
	icon_state = "awaycontent2"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/obj/effect/portal/permanent/one_way/recall
	name = "recall portal"
	desc = "Gives you a one time ability to return to this portal once you have entered."
	mech_sized = TRUE
	keep = TRUE
	var/datum/outfit/equipment // optional outfit to equip upon entering
	var/datum/outfit/recall_equipment // optional outfit to equip upon recalling

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

// the effect that happens when someone recalls to your portal
/obj/effect/portal/permanent/one_way/recall/proc/recall_effect(mob/user)
	return

/obj/effect/proc_holder/spell/portal_recall
	name = "Portal Recall"
	desc = "This will teleport you back to your previously used portal. One use only."
	clothes_req = FALSE
	action_icon_state = "blink"
	var/list/recall_portals = list()

/obj/effect/proc_holder/spell/portal_recall/Click(mob/user = usr)
	if(!recall_portals.len)
		user.mind.RemoveSpell(src) // remove spell if no portals left
	var/obj/effect/portal/permanent/one_way/recall/last_portal = recall_portals[recall_portals.len]
	var/turf/recall_turf = get_turf(last_portal)
	if(recall_turf)
		if(last_portal.recall_equipment && ishuman(user))
			var/mob/living/carbon/human/H = user
			H.delete_equipment()
			H.equipOutfit(last_portal.recall_equipment)
		last_portal.recall_effect(user)
		do_teleport(user, recall_turf, 0, no_effects = FALSE, channel = TELEPORT_CHANNEL_BLUESPACE)
		recall_portals -= last_portal
		if(!recall_portals.len)
			user.mind.RemoveSpell(src) // remove spell if no portals left

/obj/effect/mob_spawn/human/virtual_reality
	name = "Network Relay"
	desc = "A machine with flashing buttons. It seems to be some sort of teleportation pad. There doesn't seem to be any way to activate it from this side."
	mob_name = "Virtual Reality Human"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "qpad-idle"
	density = FALSE
	roundstart = FALSE
	death = FALSE
	uses = -1 // infinite
	random = TRUE
	mob_species = /datum/species/human
	outfit = /datum/outfit/vr
	flavour_text = "<span class='big bold'>You have connected to another stations virtual reality system</span>\n\
	<b>You have been assigned a mission by nanotrasen to increase productivity in a station that lacks any and all teamwork.\n\
	Your objective is to help other people by completing tasks, whether social or combatative, together, while also improving your own skills.</b>"
	assignedrole = "Vr"
	var/pacifist = TRUE // if the virtual human upon spawning is a pacifist

/obj/effect/mob_spawn/human/virtual_reality/equip(mob/living/carbon/human/H)
	. = ..()
	if(pacifist)
		H.add_trait(TRAIT_PACIFISM, TRAUMA_TRAIT)

/obj/effect/portal/permanent/one_way/recall/murderdome
	name = "Murderdome Portal"
	desc = "Active, but only occasionally. Leads to an endless battle arena."
	equipment = /datum/outfit/death_commando
	recall_equipment = /datum/outfit/vr
	id = "vr murderdome"
	light_color = LIGHT_COLOR_FIRE
	light_power = 1
	light_range = 3

/obj/effect/portal/permanent/one_way/recall/murderdome/teleport(atom/movable/M, force = FALSE)
	. = ..()
	if(. && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.remove_trait(TRAIT_PACIFISM, TRAUMA_TRAIT)

/obj/effect/portal/permanent/one_way/recall/murderdome/recall_effect(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.add_trait(TRAIT_PACIFISM, TRAUMA_TRAIT)

/obj/effect/portal/permanent/one_way/destroy/murderdome
	name = "Murderdome Exit Portal"
	id = "vr murderdome"

/obj/effect/portal/permanent/one_way/recall/syndicate
	name = "Syndicate Portal"
	desc = "Active, but only occasionally. Leads to a syndicate training program."
	equipment = /datum/outfit/vr/syndicate
	recall_equipment = /datum/outfit/vr
	id = "vr syndicate"
	light_color = LIGHT_COLOR_FIRE
	light_power = 1
	light_range = 3

/obj/effect/portal/permanent/one_way/recall/syndicate/teleport(atom/movable/M, force = FALSE)
	. = ..()
	if(. && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.remove_trait(TRAIT_PACIFISM, TRAUMA_TRAIT)

/obj/effect/portal/permanent/one_way/recall/syndicate/recall_effect(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.add_trait(TRAIT_PACIFISM, TRAUMA_TRAIT)

/obj/effect/portal/permanent/one_way/destroy/syndicate
	name = "Syndicate Exit Portal"
	id = "vr syndicate"

/obj/effect/portal/permanent/one_way/recall/snowdin
	name = "Snowdin Portal"
	desc = "Active, but only occasionally. Leads to a snowed in wasteland."
	equipment = /datum/outfit/vr/snowtide
	recall_equipment = /datum/outfit/vr
	id = "vr snowdin"
	light_color = LIGHT_COLOR_FIRE
	light_power = 1
	light_range = 3

/obj/effect/portal/permanent/one_way/recall/snowdin/teleport(atom/movable/M, force = FALSE)
	. = ..()
	if(. && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.remove_trait(TRAIT_PACIFISM, TRAUMA_TRAIT)

/obj/effect/portal/permanent/one_way/recall/snowdin/recall_effect(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.add_trait(TRAIT_PACIFISM, TRAUMA_TRAIT)

/obj/effect/portal/permanent/one_way/destroy/snowdin
	name = "Snowdin Exit Portal"
	id = "vr snowdin"