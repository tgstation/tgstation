
//reserved file just for golems since they're such a big thing, available on lavaland and from the station

//Golem shells: Spawns in Free Golem ships in lavaland. Ghosts become mineral golems and are advised to spread personal freedom.
/obj/effect/mob_spawn/ghost_role/human/golem
	name = "inert free golem shell"
	desc = "A humanoid shape, empty, lifeless, and full of potential."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	mob_species = /datum/species/golem
	anchored = FALSE
	move_resist = MOVE_FORCE_NORMAL
	density = FALSE
	prompt_name = "a free golem"
	you_are_text = "You are a Free Golem. Your family worships The Liberator."
	flavour_text = "In his infinite and divine wisdom, he set your clan free to travel the stars with a single declaration: \"Yeah go do whatever.\""
	var/has_owner = FALSE
	var/can_transfer = TRUE //if golems can switch bodies to this new shell
	var/mob/living/owner = null //golem's owner if it has one

/obj/effect/mob_spawn/ghost_role/human/golem/Initialize(mapload, datum/species/golem/species = null, mob/creator = null)
	if(species) //spawners list uses object name to register so this goes before ..()
		name += " ([initial(species.prefix)])"
		mob_species = species
	. = ..()
	var/area/init_area = get_area(src)
	if(!mapload && init_area)
		notify_ghosts("\A [initial(species.prefix)] golem shell has been completed in \the [init_area.name].", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE, ignore_key = POLL_IGNORE_GOLEM)
	if(has_owner && creator)
		you_are_text = "You are a golem."
		flavour_text = "You move slowly, but are highly resistant to heat and cold as well as blunt trauma. You are unable to wear clothes, but can still use most tools."
		important_text = "Serve [creator], and assist [creator.p_them()] in completing [creator.p_their()] goals at any cost."
		owner = creator


/obj/effect/mob_spawn/ghost_role/human/golem/name_mob(mob/living/spawned_mob, forced_name)
	if(!forced_name)
		var/datum/species/golem/golem_species = mob_species
		if(has_owner)
			forced_name =  "[initial(golem_species.prefix)] Golem ([rand(1,999)])"
		else
			golem_species = new mob_species
			forced_name =  golem_species.random_name()
	. = ..()

/obj/effect/mob_spawn/ghost_role/human/golem/special(mob/living/new_spawn, mob/mob_possessor)
	. = ..()
	var/datum/species/golem/X = mob_species
	to_chat(new_spawn, "[initial(X.info_text)]")
	if(!owner)
		var/policy = get_policy(ROLE_FREE_GOLEM)
		if (policy)
			to_chat(new_spawn, policy)
		to_chat(new_spawn, "Build golem shells in the autolathe, and feed refined mineral sheets to the shells to bring them to life! You are generally a peaceful group unless provoked.")
		try_keep_home(new_spawn)
	else
		new_spawn.mind.enslave_mind_to_creator(owner)
		new_spawn.log_message("possessed a golem shell enslaved to [key_name(owner)].", LOG_GAME)
		log_admin("[key_name(new_spawn)] possessed a golem shell enslaved to [key_name(owner)].")
	if(ishuman(new_spawn))
		var/mob/living/carbon/human/H = new_spawn
		if(has_owner)
			var/datum/species/golem/G = H.dna.species
			G.owner = owner
		H.set_cloned_appearance()
	if(has_owner && new_spawn.mind)
		new_spawn.mind.set_assigned_role(SSjob.GetJobType(/datum/job/servant_golem))
	else
		new_spawn.mind.set_assigned_role(SSjob.GetJobType(/datum/job/free_golem))

/obj/effect/mob_spawn/ghost_role/human/golem/proc/try_keep_home(mob/new_spawn)
	var/static/list/allowed_areas = typecacheof(list(/area/icemoon, /area/lavaland, /area/ruin)) + typecacheof(/area/misc/survivalpod)

	ADD_TRAIT(new_spawn, TRAIT_FORBID_MINING_SHUTTLE_CONSOLE_OUTSIDE_STATION, INNATE_TRAIT)
	new_spawn.AddComponent(/datum/component/hazard_area, area_whitelist = allowed_areas)

/obj/effect/mob_spawn/ghost_role/human/golem/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(isgolem(user) && can_transfer)
		var/mob/living/carbon/human/H = user
		var/transfer_choice = tgui_alert(usr, "Transfer your soul to [src]? (Warning, your old body will die!)",,list("Yes","No"))
		if(transfer_choice != "Yes")
			return
		if(QDELETED(src) || uses <= 0)
			return
		H.log_message("golem-swapped into [src].", LOG_GAME)
		H.visible_message(span_notice("A faint light leaves [H], moving to [src] and animating it!"),span_notice("You leave your old body behind, and transfer into [src]!"))
		show_flavor = FALSE
		var/mob/living/carbon/human/newgolem = create(newname = H.real_name)
		H.transfer_quirk_datums(newgolem)
		H.mind.transfer_to(newgolem)
		H.death()
		return

/obj/effect/mob_spawn/ghost_role/human/golem/servant
	has_owner = TRUE
	name = "inert servant golem shell"
	prompt_name = "servant golem"


/obj/effect/mob_spawn/ghost_role/human/golem/adamantine
	name = "dust-caked free golem shell"
	desc = "A humanoid shape, empty, lifeless, and full of potential."
	prompt_name = "free golem"
	can_transfer = FALSE
	mob_species = /datum/species/golem/adamantine
