//An ore-devouring but easily scared creature
/mob/living/simple_animal/hostile/asteroid/goldgrub
	name = "goldgrub"
	desc = "A worm that grows fat from eating everything in its sight. Seems to enjoy precious metals and other shiny things, hence the name."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Goldgrub"
	icon_living = "Goldgrub"
	icon_aggro = "Goldgrub_alert"
	icon_dead = "Goldgrub_dead"
	icon_gib = "syndicate_gib"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	vision_range = 2
	aggro_vision_range = 9
	move_to_delay = 5
	friendly_verb_continuous = "harmlessly rolls into"
	friendly_verb_simple = "harmlessly roll into"
	maxHealth = 45
	health = 45
	harm_intent_damage = 5
	melee_damage_lower = 0
	melee_damage_upper = 0
	attack_verb_continuous = "barrels into"
	attack_verb_simple = "barrel into"
	attack_sound = 'sound/weapons/punch1.ogg'
	combat_mode = FALSE
	speak_emote = list("screeches")
	throw_message = "sinks in slowly, before being pushed out of "
	deathmessage = "stops moving as green liquid oozes from the carcass!"
	status_flags = CANPUSH
	gold_core_spawnable = HOSTILE_SPAWN
	search_objects = 1
	wanted_objects = list(/obj/item/stack/ore/diamond, /obj/item/stack/ore/gold, /obj/item/stack/ore/silver,
						  /obj/item/stack/ore/uranium)

	var/chase_time = 100
	var/will_burrow = TRUE
	var/datum/action/innate/goldgrub/spitore/spit
	var/datum/action/innate/goldgrub/burrow/burrow
	var/is_burrowed = FALSE

/mob/living/simple_animal/hostile/asteroid/goldgrub/Initialize(mapload)
	. = ..()
	var/i = rand(1,3)
	while(i)
		loot += pick(/obj/item/stack/ore/silver, /obj/item/stack/ore/gold, /obj/item/stack/ore/uranium, /obj/item/stack/ore/diamond)
		i--
	spit = new
	burrow = new
	spit.Grant(src)
	burrow.Grant(src)

/datum/action/innate/goldgrub
	background_icon_state = "bg_default"

/datum/action/innate/goldgrub/spitore
	name = "Spit Ore"
	desc = "Vomit out all of your consumed ores."

/datum/action/innate/goldgrub/spitore/Activate()
	var/mob/living/simple_animal/hostile/asteroid/goldgrub/G = owner
	if(G.stat == DEAD || G.is_burrowed)
		return
	G.barf_contents()

/datum/action/innate/goldgrub/burrow
	name = "Burrow"
	desc = "Burrow under soft ground, evading predators and increasing your speed."

/datum/action/innate/goldgrub/burrow/Activate()
	var/mob/living/simple_animal/hostile/asteroid/goldgrub/G = owner
	var/obj/effect/dummy/phased_mob/holder = null
	if(G.stat == DEAD)
		return
	var/turf/T = get_turf(G)
	if (!istype(T, /turf/open/misc/asteroid) || !do_after(G, 30, target = T))
		to_chat(G, span_warning("You can only burrow in and out of mining turfs and must stay still!"))
		return
	if (get_dist(G, T) != 0)
		to_chat(G, span_warning("Action cancelled, as you moved while reappearing."))
		return
	if(G.is_burrowed)
		holder = G.loc
		holder.eject_jaunter()
		holder = null
		G.is_burrowed = FALSE
		G.visible_message(span_danger("[G] emerges from the ground!"))
		playsound(get_turf(G), 'sound/effects/break_stone.ogg', 50, TRUE, -1)
	else
		G.visible_message(span_danger("[G] buries into the ground, vanishing from sight!"))
		playsound(get_turf(G), 'sound/effects/break_stone.ogg', 50, TRUE, -1)
		holder = new /obj/effect/dummy/phased_mob(T, G)
		G.is_burrowed = TRUE

/mob/living/simple_animal/hostile/asteroid/goldgrub/GiveTarget(new_target)
	add_target(new_target)
	if(target != null)
		if(istype(target, /obj/item/stack/ore))
			visible_message(span_notice("The [name] looks at [target.name] with hungry eyes."))
		else if(isliving(target))
			Aggro()
			visible_message(span_danger("The [name] tries to flee from [target.name]!"))
			retreat_distance = 10
			minimum_distance = 10
			if(will_burrow)
				addtimer(CALLBACK(src, .proc/Burrow), chase_time)

/mob/living/simple_animal/hostile/asteroid/goldgrub/AttackingTarget()
	if(istype(target, /obj/item/stack/ore))
		EatOre(target)
		return
	return ..()

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/EatOre(atom/movable/targeted_ore)
	if(targeted_ore && targeted_ore.loc != src)
		targeted_ore.forceMove(src)
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/asteroid/goldgrub/death(gibbed)
	barf_contents()
	return ..()

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/barf_contents()
	visible_message(span_danger("[src] spits out its consumed ores!"))
	playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
	for(var/atom/movable/AM in src)
		AM.forceMove(loc)

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/Burrow()//Begin the chase to kill the goldgrub in time
	if(!stat)
		visible_message(span_danger("The [name] buries into the ground, vanishing from sight!"))
		qdel(src)

/mob/living/simple_animal/hostile/asteroid/goldgrub/bullet_act(obj/projectile/P)
	visible_message(span_danger("The [P.name] is repelled by [name]'s girth!"))
	return BULLET_ACT_BLOCK

/mob/living/simple_animal/hostile/asteroid/goldgrub/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	vision_range = 9
	. = ..()
