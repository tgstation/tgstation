
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
	see_in_dark = 15
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	obj_damage = 10
	butcher_results = list(/obj/item/clothing/head/costume/crown = 1,)
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
	faction = list(FACTION_RAT)
	///Whether or not the regal rat is already opening an airlock
	var/opening_airlock = FALSE
	///The spell that the rat uses to generate miasma
	var/datum/action/cooldown/domain/domain
	///The Spell that the rat uses to recruit/convert more rats.
	var/datum/action/cooldown/riot/riot

/mob/living/simple_animal/hostile/regalrat/Initialize(mapload)
	. = ..()
	domain = new(src)
	riot = new(src)
	domain.Grant(src)
	riot.Grant(src)
	AddElement(/datum/element/waddling)

	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/simple_animal/hostile/regalrat/Destroy()
	QDEL_NULL(domain)
	QDEL_NULL(riot)
	return ..()

/mob/living/simple_animal/hostile/regalrat/proc/get_player()
	var/list/mob/dead/observer/candidates = poll_ghost_candidates("Do you want to play as the Regal Rat, cheesey be their crown?", ROLE_SENTIENCE, ROLE_SENTIENCE, 100, POLL_IGNORE_REGAL_RAT)
	if(LAZYLEN(candidates) && !mind)
		var/mob/dead/observer/C = pick(candidates)
		key = C.key
		notify_ghosts("All rise for the rat king, ascendant to the throne in \the [get_area(src)].", source = src, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Sentient Rat Created")
	to_chat(src, span_notice("You are an independent, invasive force on the station! Horde coins, trash, cheese, and the like from the safety of darkness!"))

/mob/living/simple_animal/hostile/regalrat/attack_ghost(mob/user)
	. = ..()
	if(. || !(GLOB.ghost_role_flags & GHOSTROLE_SPAWNER))
		return
	get_clicked_player(user)

/**
 * Sets a ghost to control the rat if the rat is eligible
 *
 * Asks the interacting ghost if they would like to control the rat.
 * If they answer yes, and another ghost hasn't taken control, sets the ghost to control the rat.
 * Arguments:
 * * mob/user - The ghost to possibly control the rat
 */
/mob/living/simple_animal/hostile/regalrat/proc/get_clicked_player(mob/user)
	if(key || stat)
		return
	if(!SSticker.HasRoundStarted())
		to_chat(user, span_warning("You cannot assume control of this until after the round has started!"))
		return
	var/rat_ask = tgui_alert(usr, "Become the Royal Rat?", "Are you sure?", list("Yes", "No"))
	if(rat_ask != "Yes" || QDELETED(src))
		return
	if(key)
		to_chat(user, span_warning("Someone else already took the rat!"))
		return
	key = user.key
	src.log_message("took control of [name].", LOG_GAME)

/mob/living/simple_animal/hostile/regalrat/handle_automated_action()
	if(prob(20))
		riot.Trigger()
	else if(prob(50))
		domain.Trigger()
	return ..()

/mob/living/simple_animal/hostile/regalrat/CanAttack(atom/the_target)
	if(isliving(the_target))
		var/mob/living/living_target = the_target
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
	if(miasma_percentage>=0.25)
		heal_bodypart_damage(1)

#define REGALRAT_INTERACTION "regalrat"

/mob/living/simple_animal/hostile/regalrat/AttackingTarget()
	if (DOING_INTERACTION(src, REGALRAT_INTERACTION))
		return
	if (QDELETED(target))
		return
	if(istype(target, /obj/machinery/door/airlock) && !opening_airlock)
		pry_door(target)
		return

	if (target.reagents && target.is_injectable(src, allowmobs = TRUE) && !istype(target, /obj/item/food/cheese))
		src.visible_message(span_warning("[src] starts licking [target] passionately!"),span_notice("You start licking [target]..."))
		if (do_mob(src, target, 2 SECONDS, interaction_key = REGALRAT_INTERACTION))
			target.reagents.add_reagent(/datum/reagent/rat_spit,rand(1,3),no_react = TRUE)
			to_chat(src, span_notice("You finish licking [target]."))
			return
	else
		SEND_SIGNAL(target, COMSIG_RAT_INTERACT, src)
		if(QDELETED(target))
			return

	if (DOING_INTERACTION(src, REGALRAT_INTERACTION)) // check again in case we started interacting
		return
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
		if(prying_door.density && !prying_door.open(2))
			to_chat(src, span_warning("Despite your efforts, the airlock managed to resist your attempts to open it!"))
			return FALSE
		prying_door.open()
		return FALSE
	opening_airlock = FALSE

/mob/living/simple_animal/hostile/regalrat/controlled/Initialize(mapload)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(get_player))
	var/kingdom = pick("Plague","Miasma","Maintenance","Trash","Garbage","Rat","Vermin","Cheese")
	var/title = pick("King","Lord","Prince","Emperor","Supreme","Overlord","Master","Shogun","Bojar","Tsar")
	name = "[kingdom] [title]"


/**
 *Increase the rat king's domain
 */

/datum/action/cooldown/domain
	name = "Rat King's Domain"
	desc = "Corrupts this area to be more suitable for your rat army."
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 6 SECONDS
	melee_cooldown_time = 0 SECONDS
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	background_icon_state = "bg_clock"
	button_icon_state = "coffer"

/datum/action/cooldown/domain/proc/domain()
	var/turf/T = get_turf(owner)
	T.atmos_spawn_air("miasma=4;TEMP=[T20C]")
	switch (rand(1,10))
		if (8)
			new /obj/effect/decal/cleanable/vomit(T)
		if (9)
			new /obj/effect/decal/cleanable/vomit/old(T)
		if (10)
			new /obj/effect/decal/cleanable/oil/slippery(T)
		else
			new /obj/effect/decal/cleanable/dirt(T)
	StartCooldown()

/datum/action/cooldown/domain/Activate(atom/target)
	StartCooldown(10 SECONDS)
	domain()
	StartCooldown()

/**
 * This action checks all nearby mice, and converts them into hostile rats.
 * If no mice are nearby, creates a new one.
 */
/datum/action/cooldown/riot
	name = "Raise Army"
	desc = "Raise an army out of the hordes of mice and pests crawling around the maintenance shafts."
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "riot"
	background_icon_state = "bg_clock"
	cooldown_time = 8 SECONDS
	melee_cooldown_time = 0 SECONDS

/datum/action/cooldown/riot/Activate(atom/target)
	StartCooldown(10 SECONDS)
	riot()
	StartCooldown()

/datum/action/cooldown/riot/proc/riot()
	var/cap = CONFIG_GET(number/ratcap)
	var/uplifted_mice = FALSE
	for(var/mob/living/basic/mouse/nearby_mouse in oview(owner, 5))
		// This mouse is already rat controlled, let's not bother with it.
		if(istype(nearby_mouse.ai_controller, /datum/ai_controller/basic_controller/mouse/rat))
			continue
		var/mob/living/basic/mouse/rat/rat_path = /mob/living/basic/mouse/rat

		// Buffs our combat stats to that of a rat
		nearby_mouse.melee_damage_lower = initial(rat_path.melee_damage_lower)
		nearby_mouse.melee_damage_upper = initial(rat_path.melee_damage_upper)
		nearby_mouse.obj_damage = initial(rat_path.obj_damage)
		nearby_mouse.maxHealth = initial(rat_path.maxHealth)
		nearby_mouse.health = initial(rat_path.health)
		// Replace our AI with a rat one
		nearby_mouse.ai_controller = new /datum/ai_controller/basic_controller/mouse/rat(nearby_mouse)
		// Give a hint in description too
		nearby_mouse.desc += " ...Except this one looks corrupted and aggressive."
		// Now we share factions!
		nearby_mouse.faction = owner.faction.Copy()
		uplifted_mice = TRUE

	if(uplifted_mice)
		owner.visible_message(span_warning("[owner] commands their army to action, mutating them into rats!"))

	else if(LAZYLEN(SSmobs.cheeserats) < cap)
		new /mob/living/basic/mouse(owner.loc)
		owner.visible_message(span_warning("[owner] commands a rat to their side!"))

	else
		to_chat(owner,span_warning("There's too many mice on this station to beckon a new one! Find them first!"))

	StartCooldown()

/**
 *Spittle; harmless reagent that is added by rat king, and makes you disgusted.
 */

/datum/reagent/rat_spit
	name = "Rat Spit"
	description = "Something coming from a rat. Dear god! Who knows where it's been!"
	reagent_state = LIQUID
	color = "#C8C8C8"
	metabolization_rate = 0.03 * REAGENTS_METABOLISM
	taste_description = "something funny"
	overdose_threshold = 20

/datum/reagent/rat_spit/on_mob_metabolize(mob/living/L)
	..()
	if(HAS_TRAIT(L, TRAIT_AGEUSIA))
		return
	to_chat(L, span_notice("This food has a funny taste!"))

/datum/reagent/rat_spit/overdose_start(mob/living/M)
	..()
	var/mob/living/carbon/victim = M
	if (istype(victim) && !(FACTION_RAT in victim.faction))
		to_chat(victim, span_userdanger("With this last sip, you feel your body convulsing horribly from the contents you've ingested. As you contemplate your actions, you sense an awakened kinship with rat-kind and their newly risen leader!"))
		victim.faction |= FACTION_RAT
		victim.vomit()
	metabolization_rate = 10 * REAGENTS_METABOLISM

/datum/reagent/rat_spit/on_mob_life(mob/living/carbon/C)
	if(prob(15))
		to_chat(C, span_notice("You feel queasy!"))
		C.adjust_disgust(3)
	else if(prob(10))
		to_chat(C, span_warning("That food does not sit up well!"))
		C.adjust_disgust(5)
	else if(prob(5))
		C.vomit()
	..()
