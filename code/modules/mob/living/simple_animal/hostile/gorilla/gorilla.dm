#define GORILLA_HANDS_LAYER 1
#define GORILLA_TOTAL_LAYERS 1

/mob/living/simple_animal/hostile/gorilla
	name = "Gorilla"
	desc = "A ground-dwelling, predominantly herbivorous ape that inhabits the forests of central Africa."
	icon = 'icons/mob/gorilla.dmi'
	icon_state = "crawling"
	icon_living = "crawling"
	icon_dead = "dead"
	health_doll_icon = "crawling"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	speak_chance = 80
	maxHealth = 220
	health = 220
	loot = list(/obj/effect/gibspawner/generic/animal)
	butcher_results = list(/obj/item/food/meat/slab/gorilla = 4)
	response_help_continuous = "prods"
	response_help_simple = "prod"
	response_disarm_continuous = "challenges"
	response_disarm_simple = "challenge"
	response_harm_continuous = "thumps"
	response_harm_simple = "thump"
	speed = 0.5
	melee_damage_lower = 15
	melee_damage_upper = 18
	damage_coeff = list(BRUTE = 1, BURN = 1.5, TOX = 1.5, CLONE = 0, STAMINA = 0, OXY = 1.5)
	obj_damage = 20
	environment_smash = ENVIRONMENT_SMASH_WALLS
	attack_verb_continuous = "pummels"
	attack_verb_simple = "pummel"
	attack_sound = 'sound/weapons/punch1.ogg'
	dextrous = TRUE
	held_items = list(null, null)
	faction = list("monkey", "jungle")
	robust_searching = TRUE
	stat_attack = HARD_CRIT
	minbodytemp = 270
	maxbodytemp = 350
	unique_name = TRUE
	footstep_type = FOOTSTEP_MOB_BAREFOOT

	var/list/gorilla_overlays[GORILLA_TOTAL_LAYERS]
	var/oogas = 0

// Gorillas like to dismember limbs from unconcious mobs.
// Returns null when the target is not an unconcious carbon mob; a list of limbs (possibly empty) otherwise.
/mob/living/simple_animal/hostile/gorilla/proc/get_target_bodyparts(atom/hit_target)
	if(!iscarbon(hit_target))
		return

	var/mob/living/carbon/carbon_target = hit_target
	if(carbon_target.stat < UNCONSCIOUS)
		return

	var/list/parts = list()
	for(var/obj/item/bodypart/part as anything in carbon_target.bodyparts)
		if(part.body_part == HEAD || part.body_part == CHEST)
			continue
		if(part.dismemberable)
			continue
		parts += part
	return parts

/mob/living/simple_animal/hostile/gorilla/AttackingTarget(atom/attacked_target)
	. = ..()
	if(!.)
		return

	if(client)
		oogaooga()

	var/list/parts = get_target_bodyparts(target)
	if(length(parts))
		var/obj/item/bodypart/to_dismember = pick(parts)
		to_dismember.dismember()
		return

	if(isliving(target))
		var/mob/living/living_target = target
		if(prob(80))
			living_target.throw_at(get_edge_target_turf(living_target, dir), rand(1, 2), 7, src)

		else
			living_target.Paralyze(2 SECONDS)
			visible_message(span_danger("[src] knocks [living_target] down!"))

/mob/living/simple_animal/hostile/gorilla/CanAttack(atom/the_target)
	var/list/parts = get_target_bodyparts(target)
	return ..() && !ismonkey(the_target) && (!parts || length(parts) > 3)

/mob/living/simple_animal/hostile/gorilla/CanSmashTurfs(turf/T)
	return iswallturf(T)

/mob/living/simple_animal/hostile/gorilla/gib(no_brain)
	if(!no_brain)
		var/mob/living/brain/gorilla_brain = new(drop_location())
		gorilla_brain.name = real_name
		gorilla_brain.real_name = real_name
		mind?.transfer_to(gorilla_brain)
	return ..()

/mob/living/simple_animal/hostile/gorilla/handle_automated_speech(override)
	if(speak_chance && (override || prob(speak_chance)))
		playsound(src, 'sound/creatures/gorilla.ogg', 50)
	return ..()

/mob/living/simple_animal/hostile/gorilla/can_use_guns(obj/item/G)
	to_chat(src, span_warning("Your meaty finger is much too large for the trigger guard!"))
	return FALSE

/mob/living/simple_animal/hostile/gorilla/proc/oogaooga()
	oogas -= 1
	if(oogas <= 0)
		oogas = rand(2,6)
		playsound(src, 'sound/creatures/gorilla.ogg', 50)


/mob/living/simple_animal/hostile/gorilla/cargo_domestic
	name = "Cargorilla" // Overriden, normally
	icon = 'icons/mob/cargorillia.dmi'
	desc = "Cargo's pet gorilla. They seem to have an 'I love Mom' tattoo."
	maxHealth = 200
	health = 200
	faction = list("neutral", "monkey", "jungle")
	gold_core_spawnable = NO_SPAWN
	unique_name = FALSE
	/// Whether we're currently being polled over
	var/being_polled_for = FALSE

/mob/living/simple_animal/hostile/gorilla/cargo_domestic/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_PACIFISM, INNATE_TRAIT)
	AddComponent(/datum/component/crate_carrier)

/mob/living/simple_animal/hostile/gorilla/cargo_domestic/attack_ghost(mob/user)
	if(being_polled_for || mind || client || (flags_1 & ADMIN_SPAWNED_1))
		return ..()

	if(is_banned_from(user.ckey, list(ROLE_SENTIENCE, ROLE_SYNDICATE)))
		return ..()

	if(!SSticker.HasRoundStarted())
		return ..()

	var/become_gorilla = tgui_alert(user, "Become a Cargorilla?", "Confirm", list("Yes", "No"))
	if(become_gorilla != "Yes" || QDELETED(src) || QDELETED(user) || being_polled_for || mind || client)
		return

	enter_ghost(user)

/// Poll ghosts for control of the gorilla.
/mob/living/simple_animal/hostile/gorilla/cargo_domestic/proc/poll_for_gorilla()
	being_polled_for = TRUE
	var/list/mob/dead/candidates = poll_candidates_for_mob(
		"Do you want to play as a Cargorilla?",
		jobban_type = ROLE_SENTIENCE,
		poll_time = 30 SECONDS,
		target_mob = src,
	)

	being_polled_for = FALSE
	if(QDELETED(src) || mind || client)
		return

	if(LAZYLEN(candidates))
		enter_ghost(pick(candidates))

/// Brings in the a ghost to take control of the gorilla.
/mob/living/simple_animal/hostile/gorilla/cargo_domestic/proc/enter_ghost(mob/dead/user)
	key = user.key
	if(!mind)
		CRASH("[type] - enter_ghost didn't end up with a mind.")

	mind.set_assigned_role(SSjob.GetJobType(/datum/job/cargo_technician))
	mind.special_role = "Cargorilla"
	to_chat(src, span_boldnotice("You are a Cargorilla, a pacifistic friend of the station and carrier of freight."))
	to_chat(src, span_notice("You can pick up crates by clicking on them, and drop them by clicking on the ground."))

/obj/item/card/id/advanced/cargo_gorilla
	name = "cargorilla ID"
	desc = "A card used to provide ID and determine access across the station. A gorilla-sized ID for a gorilla-sized cargo technician."
	trim = /datum/id_trim/job/cargo_technician
