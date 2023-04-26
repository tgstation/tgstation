
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
	spawner_job_path = /datum/job/free_golem
	/// If TRUE, other golems can touch us to swap into this shell.
	var/can_transfer = TRUE
	/// Weakref to the creator of this golem shell.
	var/datum/weakref/owner_ref

/obj/effect/mob_spawn/ghost_role/human/golem/Initialize(mapload, datum/species/golem/species, mob/creator)
	if(creator)
		name = "inert servant golem shell"
		prompt_name = "servant golem"
	if(species) //spawners list uses object name to register so this goes before ..()
		name += " ([initial(species.prefix)])"
		mob_species = species
	. = ..()
	var/area/init_area = get_area(src)
	if(!mapload && init_area)
		notify_ghosts("\A [initial(species.prefix)] golem shell has been completed in \the [init_area.name].", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE, ignore_key = POLL_IGNORE_GOLEM)
	if(creator)
		you_are_text = "You are a golem."
		flavour_text = "You move slowly, but are highly resistant to heat and cold as well as blunt trauma. You are unable to wear clothes, but can still use most tools."
		important_text = "Serve [creator], and assist [creator.p_them()] in completing [creator.p_their()] goals at any cost."
		owner_ref = WEAKREF(creator)
		spawner_job_path = /datum/job/servant_golem


/obj/effect/mob_spawn/ghost_role/human/golem/name_mob(mob/living/spawned_mob, forced_name)
	if(!forced_name)
		var/datum/species/golem/golem_species = mob_species
		if(owner_ref?.resolve())
			forced_name =  "[initial(golem_species.prefix)] Golem ([rand(1,999)])"
		else
			golem_species = new mob_species
			forced_name =  golem_species.random_name()
	return ..()

/obj/effect/mob_spawn/ghost_role/human/golem/special(mob/living/new_spawn, mob/mob_possessor)
	. = ..()
	var/mob/living/real_owner = owner_ref?.resolve()
	var/datum/species/golem/golem_species = mob_species
	to_chat(new_spawn, "[initial(golem_species.info_text)]")
	if(isnull(real_owner))
		if(!is_station_level(new_spawn.z))
			to_chat(new_spawn, "Build golem shells in the autolathe, and feed refined mineral sheets to the shells to bring them to life! \
				You are generally a peaceful group unless provoked.")
			try_keep_home(new_spawn)

	else if(new_spawn.mind)
		new_spawn.mind.enslave_mind_to_creator(real_owner)

	else
		stack_trace("[type] created a golem without a mind.")

	new_spawn.log_message("possessed a golem shell[real_owner ? " enslaved to [key_name(real_owner)]" : ""].", LOG_GAME)
	log_admin("[key_name(new_spawn)] possessed a golem shell[real_owner ? " enslaved to [key_name(real_owner)]" : ""].")

	if(ishuman(new_spawn))
		var/mob/living/carbon/human/human_spawn = new_spawn
		human_spawn.set_cloned_appearance()

/obj/effect/mob_spawn/ghost_role/human/golem/proc/try_keep_home(mob/new_spawn)
	var/static/list/allowed_areas = typecacheof(list(/area/icemoon, /area/lavaland, /area/ruin)) + typecacheof(/area/misc/survivalpod)

	ADD_TRAIT(new_spawn, TRAIT_FORBID_MINING_SHUTTLE_CONSOLE_OUTSIDE_STATION, INNATE_TRAIT)
	new_spawn.AddComponent(/datum/component/hazard_area, area_whitelist = allowed_areas)

/obj/effect/mob_spawn/ghost_role/human/golem/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!isgolem(user) || !can_transfer)
		return

	var/mob/living/carbon/human/golem = user
	var/transfer_choice = tgui_alert(usr, "Transfer your soul to [src]? (Warning, your old body will die!)",,list("Yes","No"))
	if(transfer_choice != "Yes")
		return
	if(QDELETED(src) || uses <= 0)
		return
	uses -= 1
	golem.log_message("golem-swapped into [src].", LOG_GAME)
	golem.visible_message(
		span_notice("A faint light leaves [golem], moving to [src] and animating it!"),
		span_notice("You leave your old body behind, and transfer into [src]!"),
	)
	show_flavor = FALSE
	var/mob/living/carbon/human/newgolem = create(user, golem.real_name)
	golem.transfer_quirk_datums(newgolem)
	golem.death()
	check_uses()
	return TRUE

/obj/effect/mob_spawn/ghost_role/human/golem/servant
	name = "inert servant golem shell"
	prompt_name = "servant golem"

/obj/effect/mob_spawn/ghost_role/human/golem/adamantine
	name = "dust-caked free golem shell"
	desc = "A humanoid shape, empty, lifeless, and full of potential."
	prompt_name = "free golem"
	can_transfer = FALSE
	mob_species = /datum/species/golem/adamantine
