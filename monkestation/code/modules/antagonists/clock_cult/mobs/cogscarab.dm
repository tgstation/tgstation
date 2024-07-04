GLOBAL_LIST_EMPTY(cogscarabs)

#define CLOCK_DRONE_MAX_ITEM_FORCE 15

//====Cogscarab====

/mob/living/basic/drone/cogscarab
	name = "Cogscarab"
	desc = "A mechanical device, filled with twisting cogs and mechanical parts, built to maintain Reebe."
	icon_state = "drone_clock"
	icon_living = "drone_clock"
	icon_dead = "drone_clock_dead"
	health = 35
	maxHealth = 35
	faction = list(FACTION_NEUTRAL, FACTION_SILICON, FACTION_TURRET, FACTION_CLOCK)
	default_storage = /obj/item/storage/belt/utility/clock/drone
	visualAppearance = CLOCKDRONE
	bubble_icon = "clock"
	picked = TRUE
	flavortext = span_brass("You are a cogscarab, an intricate machine that has been granted sentient by Rat'var.<br>\
		After a long and destructive conflict, Reebe has been left mostly empty;\
		you and the other cogscarabs like you were bought into existence to construct Reebe into the image of Rat'var.<br>\
		Construct defences, traps and forgeries, \
		for opening the Ark requires an unimaginable amount of power which is bound to get the attention of selfish lifeforms interested only in their own self-preservation.")
	laws = "You are have been granted the gift of sentience from Rat'var.<br>\
		You are not bound by any laws, do whatever you must to serve Rat'var!"
	chat_color = LIGHT_COLOR_CLOCKWORK
	initial_language_holder = /datum/language_holder/clockmob
	shy = FALSE
	///var for in case admins want a cogsarab to stay off reebe for some reason
	var/stay_on_reebe = TRUE

//No you can't go wielding guns like that.
/mob/living/basic/drone/cogscarab/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NOGUNS, "cogscarab")
	GLOB.cogscarabs += src
	add_actionspeed_modifier(/datum/actionspeed_modifier/cogscarab)

/datum/actionspeed_modifier/cogscarab
	multiplicative_slowdown = 0.6

/mob/living/basic/drone/cogscarab/death(gibbed)
	GLOB.cogscarabs -= src
	return ..()

/mob/living/basic/drone/cogscarab/Life(seconds, times_fired)
	if(!on_reebe(src) && !GLOB.ratvar_risen && length(GLOB.abscond_markers) && stay_on_reebe)
		try_servant_warp(src, get_turf(pick(GLOB.abscond_markers)))
	. = ..()

/mob/living/basic/drone/cogscarab/Destroy()
	GLOB.cogscarabs -= src
	return ..()

/mob/living/basic/drone/cogscarab/transferItemToLoc(obj/item/item, newloc, force, silent) //ideally I would handle this on attacking instead
	return (item.force <= CLOCK_DRONE_MAX_ITEM_FORCE) && ..()

//====Shell====

/obj/effect/mob_spawn/ghost_role/drone/cogscarab
	name = "cogscarab construct"
	desc = "The shell of an ancient construction drone, loyal to Ratvar."
	icon = 'monkestation/icons/obj/clock_cult/clockwork_objects.dmi'
	icon_state = "cogscarab_shell"
	mob_name = "cogscarab"
	mob_type = /mob/living/basic/drone/cogscarab
	role_ban = ROLE_CLOCK_CULTIST
	prompt_name = "a cogscarab"
	you_are_text = "You are a cogscarab!"
	flavour_text = "You are a cogscarab, a tiny building construct of Ratvar. While you're weak and can't leave Reebe, \
	you have a set of quick tools, as well as a replica fabricator that can create brass for construction. Work with the servants of Rat'var \
	to construct and maintain defenses at the City of Cogs."

/obj/effect/mob_spawn/ghost_role/drone/cogscarab/special(mob/living/spawned_mob, mob/mob_possessor)
	. = ..()
	spawned_mob.flags_1 |= (flags_1 & ADMIN_SPAWNED_1)
	spawned_mob.mind.add_antag_datum(/datum/antagonist/clock_cultist)

/obj/effect/mob_spawn/ghost_role/drone/cogscarab/allow_spawn(mob/user, silent)
	if(length(GLOB.cogscarabs) > MAXIMUM_COGSCARABS)
		to_chat(user, span_notice("The cult currently has its maximum amount of cogscarabs."))
		return FALSE
	return TRUE

#undef CLOCK_DRONE_MAX_ITEM_FORCE
