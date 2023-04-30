
//reserved file just for golems since they're such a big thing, available on lavaland and from the station

//Golem shells: Spawns in Free Golem ships in lavaland. Ghosts become mineral golems and are advised to spread personal freedom.
/obj/effect/mob_spawn/ghost_role/human/golem
	name = "inert free golem shell"
	desc = "A humanoid shape, empty, lifeless, and full of potential."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "shell_complete"
	mob_species = /datum/species/golem
	anchored = FALSE
	move_resist = MOVE_FORCE_NORMAL
	density = FALSE
	prompt_name = "a free golem"
	you_are_text = "You are a Free Golem. Your family worships The Liberator."
	flavour_text = "In his infinite and divine wisdom, he set your clan free to travel the stars with a single declaration: \"Yeah go do whatever.\""
	spawner_job_path = /datum/job/free_golem
	/// Weakref to the creator of this golem shell.
	var/datum/weakref/owner_ref
	/// Typepath to a material to feed to the golem as soon as it is built
	var/initial_type

/obj/effect/mob_spawn/ghost_role/human/golem/Initialize(mapload, mob/creator, made_of)
	if(creator)
		name = "inert servant golem shell"
		prompt_name = "servant golem"
	initial_type = made_of
	. = ..()
	var/area/init_area = get_area(src)
	if(!mapload && init_area)
		notify_ghosts("\A golem shell has been completed in \the [init_area.name].", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE, ignore_key = POLL_IGNORE_GOLEM)
	if(creator)
		you_are_text = "You are a golem."
		flavour_text = "You move slowly, but are highly resistant to heat and cold as well as blunt trauma. You are unable to wear clothes, but can still use most tools."
		important_text = "Serve [creator], and assist [creator.p_them()] in completing [creator.p_their()] goals at any cost."
		owner_ref = WEAKREF(creator)
		spawner_job_path = /datum/job/servant_golem


/obj/effect/mob_spawn/ghost_role/human/golem/name_mob(mob/living/spawned_mob, forced_name)
	if(forced_name || !iscarbon(spawned_mob))
		return ..()

	if(owner_ref?.resolve())
		forced_name =  "Golem ([rand(1,999)])"
		return ..()

	var/datum/species/golem/golem_species = new()
	forced_name = golem_species.random_name()
	return ..()

/obj/effect/mob_spawn/ghost_role/human/golem/special(mob/living/new_spawn, mob/mob_possessor)
	. = ..()
	if(is_path_in_list(initial_type, GLOB.golem_stack_food_directory))
		var/datum/golem_food_buff/initial_buff = GLOB.golem_stack_food_directory[initial_type]
		initial_buff.apply_effects(new_spawn)

	var/mob/living/real_owner = owner_ref?.resolve()
	if(isnull(real_owner))
		if(!is_station_level(new_spawn.z))
			to_chat(new_spawn, "Build golem shells in the autolathe, and feed refined mineral sheets to the shells to bring them to life! \
				You are generally a peaceful group unless provoked.")
			try_keep_home(new_spawn)

		new_spawn.log_message("possessed a free golem shell.", LOG_GAME)
		log_admin("[key_name(new_spawn)] possessed a free golem shell.")

	else if(new_spawn.mind)
		new_spawn.mind.enslave_mind_to_creator(real_owner)
	else
		stack_trace("[type] created a golem without a mind.")

	if(ishuman(new_spawn))
		var/mob/living/carbon/human/human_spawn = new_spawn
		human_spawn.set_cloned_appearance()

/obj/effect/mob_spawn/ghost_role/human/golem/proc/try_keep_home(mob/new_spawn)
	var/static/list/allowed_areas = typecacheof(list(/area/icemoon, /area/lavaland, /area/ruin)) + typecacheof(/area/misc/survivalpod)

	ADD_TRAIT(new_spawn, TRAIT_FORBID_MINING_SHUTTLE_CONSOLE_OUTSIDE_STATION, INNATE_TRAIT)
	new_spawn.AddComponent(/datum/component/hazard_area, area_whitelist = allowed_areas)

/obj/effect/mob_spawn/ghost_role/human/golem/servant
	name = "inert servant golem shell"
	prompt_name = "servant golem"

/obj/effect/mob_spawn/ghost_role/human/golem/adamantine
	name = "dust-caked free golem shell"
	desc = "A humanoid shape, empty, lifeless, and full of potential."
	prompt_name = "free golem"

/obj/effect/mob_spawn/ghost_role/human/golem/adamantine/special(mob/living/new_spawn, mob/mob_possessor)
	. = ..()
	if(!ishuman(new_spawn))
		return
	var/mob/living/carbon/human/new_golem = new_spawn
	var/obj/item/organ/internal/vocal_cords/adamantine/free_golem_radio = new()
	free_golem_radio.Insert(new_golem)
