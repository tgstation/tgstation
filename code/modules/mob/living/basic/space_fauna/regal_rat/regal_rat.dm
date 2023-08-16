/mob/living/simple_animal/hostile/regalrat
	name = "feral regal rat"
	desc = "An evolved rat, created through some strange science. They lead nearby rats with deadly efficiency to protect their kingdom. Not technically a king."
	icon_state = "regalrat"
	icon_living = "regalrat"
	icon_dead = "regalrat_dead"
	speak_chance = 0
	turns_per_move = 5
	maxHealth = 70
	health = 70
	// Slightly brown red, for the eyes
	// Might be a bit too dim
	lighting_cutoff_red = 22
	lighting_cutoff_green = 8
	lighting_cutoff_blue = 5
	obj_damage = 10
	butcher_results = list(/obj/item/food/meat/slab/mouse = 2, /obj/item/clothing/head/costume/crown = 1)
	response_help_continuous = "glares at"
	response_help_simple = "glare at"
	response_disarm_continuous = "skoffs at"
	response_disarm_simple = "skoff at"
	response_harm_continuous = "slashes"
	response_harm_simple = "slash"
	melee_damage_lower = 13
	melee_damage_upper = 15
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	unique_name = TRUE
	faction = list(FACTION_RAT, FACTION_MAINT_CREATURES)

	///Whether or not the regal rat is already opening an airlock
	var/opening_airlock = FALSE
	///Should we request a mind immediately upon spawning?
	var/poll_ghosts = FALSE
	///The spell that the rat uses to generate miasma
	var/datum/action/cooldown/mob_cooldown/domain/domain
	///The Spell that the rat uses to recruit/convert more rats.
	var/datum/action/cooldown/mob_cooldown/riot/riot

/mob/living/simple_animal/hostile/regalrat/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	AddElement(/datum/element/waddling)
	AddComponent(\
		/datum/component/ghost_direct_control,\
		poll_candidates = poll_ghosts,\
		role_name = "the Regal Rat, cheesy be their crown",\
		poll_ignore_key = POLL_IGNORE_REGAL_RAT,\
		assumed_control_message = "You are an independent, invasive force on the station! Hoard coins, trash, cheese, and the like from the safety of darkness!",\
		after_assumed_control = CALLBACK(src, PROC_REF(became_player_controlled)),\
	)
	domain = new(src)
	riot = new(src)
	domain.Grant(src)
	riot.Grant(src)

/mob/living/simple_animal/hostile/regalrat/Destroy()
	QDEL_NULL(domain)
	QDEL_NULL(riot)
	return ..()

/mob/living/simple_animal/hostile/regalrat/proc/became_player_controlled()
	notify_ghosts(
		"All rise for the rat king, ascendant to the throne in \the [get_area(src)].",
		source = src,
		action = NOTIFY_ORBIT,
		flashwindow = FALSE,
		header = "Sentient Rat Created",
	)

/mob/living/simple_animal/hostile/regalrat/handle_automated_action()
	if(prob(20))
		riot.Trigger()
	else if(prob(50))
		domain.Trigger()
	return ..()

/mob/living/simple_animal/hostile/regalrat/CanAttack(atom/the_target)
	if(isliving(the_target))
		var/mob/living/living_target = the_target
		if (living_target.stat != DEAD)
			return !living_target.faction_check_mob(src, exact_match = TRUE)

	return ..()

/mob/living/simple_animal/hostile/regalrat/examine(mob/user)
	. = ..()

	if(ismouse(user))
		if(user.faction_check_mob(src, TRUE))
			. += span_notice("This is your king. Long live [p_their()] majesty!")
		else
			. += span_warning("This is a false king! Strike [p_them()] down!")

	else if(user != src && isregalrat(user))
		. += span_warning("Who is this foolish false king? This will not stand!")

/mob/living/simple_animal/hostile/regalrat/handle_environment(datum/gas_mixture/environment)
	. = ..()
	if(stat == DEAD || !environment || !environment.gases[/datum/gas/miasma])
		return
	var/miasma_percentage = environment.gases[/datum/gas/miasma][MOLES] / environment.total_moles()
	if(miasma_percentage >= 0.25)
		heal_bodypart_damage(1)

#define REGALRAT_INTERACTION "regalrat"

/mob/living/simple_animal/hostile/regalrat/AttackingTarget()
	if (DOING_INTERACTION(src, REGALRAT_INTERACTION) || QDELETED(target))
		return
	if(istype(target, /obj/machinery/door/airlock) && !opening_airlock)
		pry_door(target)
		return
	if (src.mind && !src.combat_mode && target.reagents && target.is_injectable(src, allowmobs = TRUE) && !istype(target, /obj/item/food/cheese))
		src.visible_message(span_warning("[src] starts licking [target] passionately!"),span_notice("You start licking [target]..."))
		if (do_after(src, 2 SECONDS, target, interaction_key = REGALRAT_INTERACTION))
			target.reagents.add_reagent(/datum/reagent/rat_spit,rand(1,3),no_react = TRUE)
			to_chat(src, span_notice("You finish licking [target]."))
		return
	else
		SEND_SIGNAL(target, COMSIG_RAT_INTERACT, src)
	return ..()

#undef REGALRAT_INTERACTION

/**
 * Conditionally "eat" cheese object and heal, if injured.
 *
 * A private proc for sending a message to the mob's chat about them
 * eating some sort of cheese, then healing them, then deleting the cheese.
 * The "eating" is only conditional on the mob being injured in the first
 * place.
 */
/mob/living/simple_animal/hostile/regalrat/proc/cheese_heal(obj/item/target, amount, message)
	if(health < maxHealth)
		to_chat(src, message)
		heal_bodypart_damage(amount)
		qdel(target)
	else
		to_chat(src, span_warning("You feel fine, no need to eat anything!"))

/**
 * Allows rat king to pry open an airlock if it isn't locked.
 *
 * A proc used for letting the rat king pry open airlocks instead of just attacking them.
 * This allows the rat king to traverse the station when there is a lack of vents or
 * accessible doors, something which is common in certain rat king spawn points.
 */
/mob/living/simple_animal/hostile/regalrat/proc/pry_door(target)
	var/obj/machinery/door/airlock/prying_door = target
	if(!prying_door.density || prying_door.locked || prying_door.welded || prying_door.seal)
		return FALSE
	opening_airlock = TRUE
	visible_message(
		span_warning("[src] begins prying open the airlock..."),
		span_notice("You begin digging your claws into the airlock..."),
		span_warning("You hear groaning metal..."),
	)
	var/time_to_open = 0.5 SECONDS
	if(prying_door.hasPower())
		time_to_open = 5 SECONDS
		playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, vary = TRUE)
	if(do_after(src, time_to_open, prying_door))
		opening_airlock = FALSE
		if(prying_door.density && !prying_door.open(BYPASS_DOOR_CHECKS))
			to_chat(src, span_warning("Despite your efforts, the airlock managed to resist your attempts to open it!"))
			return FALSE
		prying_door.open()
		return FALSE
	opening_airlock = FALSE

/mob/living/simple_animal/hostile/regalrat/controlled
	poll_ghosts = TRUE

/mob/living/simple_animal/hostile/regalrat/controlled/Initialize(mapload)
	. = ..()
	var/kingdom = pick("Plague","Miasma","Maintenance","Trash","Garbage","Rat","Vermin","Cheese")
	var/title = pick("King","Lord","Prince","Emperor","Supreme","Overlord","Master","Shogun","Bojar","Tsar")
	name = "[kingdom] [title]"


