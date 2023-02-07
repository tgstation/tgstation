#define GOOSE_SATIATED 50
/mob/living/simple_animal/hostile/retaliate/goose
	name = "goose"
	desc = "It's loose"
	icon_state = "goose" // sprites by cogwerks from goonstation, used with permission
	icon_living = "goose"
	icon_dead = "goose_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speak_chance = 0
	turns_per_move = 5
	butcher_results = list(/obj/item/food/meat/slab = 2)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	emote_taunt = list("hisses")
	taunt_chance = 30
	speed = 0
	maxHealth = 25
	health = 25
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 5
	attack_verb_continuous = "pecks"
	attack_verb_simple = "peck"
	attack_sound = "goose"
	attack_vis_effect = ATTACK_EFFECT_BITE
	speak_emote = list("honks")
	faction = list(FACTION_NEUTRAL)
	attack_same = TRUE
	gold_core_spawnable = HOSTILE_SPAWN
	var/random_retaliate = TRUE
	var/icon_vomit_start = "vomit_start"
	var/icon_vomit = "vomit"
	var/icon_vomit_end = "vomit_end"
	var/message_cooldown = 0
	var/choking = FALSE

/mob/living/simple_animal/hostile/retaliate/goose/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(goosement))

/mob/living/simple_animal/hostile/retaliate/goose/proc/goosement(atom/movable/AM, OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	if(stat == DEAD)
		return
	if(prob(5) && random_retaliate)
		Retaliate()

/mob/living/simple_animal/hostile/retaliate/goose/handle_automated_action()
	. = ..()
	feed_random()

/mob/living/simple_animal/hostile/retaliate/goose/proc/feed_random()
	var/obj/item/eat_it_motherfucker = pick(locate(/obj/item) in loc)
	if(!eat_it_motherfucker)
		return
	feed(eat_it_motherfucker)

/mob/living/simple_animal/hostile/retaliate/goose/vomit/feed_random()
	for(var/obj/item/eat_it_motherfucker in loc)
		if(!eat_it_motherfucker.has_material_type(/datum/material/plastic))
			continue
		feed(eat_it_motherfucker)
		break

/mob/living/simple_animal/hostile/retaliate/goose/proc/feed(obj/item/suffocator)
	if(stat == DEAD || choking) // plapatin I swear to god
		return FALSE
	if(suffocator.has_material_type(/datum/material/plastic)) // dumb goose'll swallow food or drink with plastic in it
		visible_message(span_danger("[src] hungrily gobbles up \the [suffocator]! "))
		visible_message(span_boldwarning("[src] is choking on \the [suffocator]! "))
		suffocator.forceMove(src)
		choke(suffocator)
		choking = TRUE
		return TRUE

/mob/living/simple_animal/hostile/retaliate/goose/vomit
	name = "Birdboat"
	real_name = "Birdboat"
	desc = "It's a sick-looking goose, probably ate too much maintenance trash. Best not to move it around too much."
	gender = MALE
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	faction = list(FACTION_NEUTRAL, FACTION_MAINT_CREATURES)
	gold_core_spawnable = NO_SPAWN
	random_retaliate = FALSE
	var/vomiting = FALSE
	var/vomitCoefficient = 1
	var/vomitTimeBonus = 0
	var/datum/action/cooldown/vomit/goosevomit

/mob/living/simple_animal/hostile/retaliate/goose/vomit/Initialize(mapload)
	. = ..()
	goosevomit = new
	goosevomit.Grant(src)
	// 5% chance every round to have anarchy mode deadchat control on birdboat.
	if(prob(5))
		desc = "[initial(desc)] It's waddling more than usual. It seems to be possessed."
		deadchat_plays()

/mob/living/simple_animal/hostile/retaliate/goose/vomit/Destroy()
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	QDEL_NULL(goosevomit)
	return ..()

/mob/living/simple_animal/hostile/retaliate/goose/vomit/examine(user)
	. = ..()
	. += span_notice("Somehow, it still looks hungry.")

/mob/living/simple_animal/hostile/retaliate/goose/attackby(obj/item/O, mob/user)
	. = ..()
	if(feed(O))
		return TRUE

/mob/living/simple_animal/hostile/retaliate/goose/vomit/feed(obj/item/food/tasty)
	. = ..()
	if(. || !istype(tasty))
		return FALSE
	if (contents.len > GOOSE_SATIATED)
		if(message_cooldown < world.time)
			visible_message(span_notice("[src] looks too full to eat \the [tasty]!"))
			message_cooldown = world.time + 5 SECONDS
		return FALSE
	if (tasty.foodtypes & GROSS)
		visible_message(span_notice("[src] hungrily gobbles up \the [tasty]!"))
		tasty.forceMove(src)
		playsound(src,'sound/items/eatfood.ogg', 70, TRUE)
		vomitCoefficient += 3
		vomitTimeBonus += 2
		return TRUE
	else
		if(message_cooldown < world.time)
			visible_message(span_notice("[src] refuses to eat \the [tasty]."))
			message_cooldown = world.time + 5 SECONDS
			return FALSE

/mob/living/simple_animal/hostile/retaliate/goose/proc/choke(obj/item/food/plastic)
	if(stat == DEAD || choking)
		return
	addtimer(CALLBACK(src, PROC_REF(suffocate)), 300)

/mob/living/simple_animal/hostile/retaliate/goose/vomit/choke(obj/item/food/plastic)
	if(stat == DEAD || choking)
		return
	if(prob(25))
		visible_message(span_warning("[src] is gagging on \the [plastic]!"))
		manual_emote("gags!")
		addtimer(CALLBACK(src, PROC_REF(vomit)), 300)
	else
		addtimer(CALLBACK(src, PROC_REF(suffocate)), 300)

/mob/living/simple_animal/hostile/retaliate/goose/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(choking && !stat)
		do_jitter_animation(50)
		if(DT_PROB(10, delta_time))
			emote("gasp")

/mob/living/simple_animal/hostile/retaliate/goose/proc/suffocate()
	if(!choking)
		return
	death_message = "lets out one final oxygen-deprived honk before [p_they()] go[p_es()] limp and lifeless.."
	death()

/mob/living/simple_animal/hostile/retaliate/goose/vomit/proc/vomit()
	if (stat == DEAD)
		return
	var/turf/T = get_turf(src)
	var/obj/item/consumed = locate() in contents //Barf out a single food item from our guts
	choking = FALSE // assume birdboat is vomiting out whatever he was choking on
	if (prob(50) && consumed)
		barf_food(consumed)
	else
		playsound(T, 'sound/effects/splat.ogg', 50, TRUE)
		T.add_vomit_floor(src)

/mob/living/simple_animal/hostile/retaliate/goose/vomit/proc/barf_food(atom/A, hard = FALSE)
	if (stat == DEAD)
		return
	if(!istype(A, /obj/item/food))
		return
	var/turf/currentTurf = get_turf(src)
	var/obj/item/food/consumed = A
	consumed.forceMove(currentTurf)
	var/destination = get_edge_target_turf(currentTurf, pick(GLOB.alldirs)) //Pick a random direction to toss them in
	var/throwRange = hard ? rand(2,8) : 1
	consumed.safe_throw_at(destination, throwRange, 2) //Thow the food at a random tile 1 spot away
	sleep(0.2 SECONDS)
	if (QDELETED(src) || QDELETED(consumed))
		return
	currentTurf = get_turf(consumed)
	currentTurf.add_vomit_floor(src)
	playsound(currentTurf, 'sound/effects/splat.ogg', 50, TRUE)

/mob/living/simple_animal/hostile/retaliate/goose/vomit/proc/vomit_prestart(duration)
	flick("vomit_start",src)
	addtimer(CALLBACK(src, PROC_REF(vomit_start), duration), 13) //13 is the length of the vomit_start animation in gooseloose.dmi

/mob/living/simple_animal/hostile/retaliate/goose/vomit/proc/vomit_start(duration)
	vomiting = TRUE
	icon_state = "vomit"
	vomit()
	addtimer(CALLBACK(src, PROC_REF(vomit_preend)), duration)

/mob/living/simple_animal/hostile/retaliate/goose/vomit/proc/vomit_preend()
	for (var/obj/item/consumed in contents) //Get rid of any food left in the poor thing
		barf_food(consumed, TRUE)
		sleep(0.1 SECONDS)
		if (QDELETED(src))
			return
	vomit_end()

/mob/living/simple_animal/hostile/retaliate/goose/vomit/proc/vomit_end()
	flick("vomit_end",src)
	vomiting = FALSE
	icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/retaliate/goose/vomit/goosement(atom/movable/AM, OldLoc, Dir, Forced)
	. = ..()
	if(vomiting)
		INVOKE_ASYNC(src, PROC_REF(vomit)) // its supposed to keep vomiting if you move
		return
	if(prob(vomitCoefficient * 0.2))
		vomit_prestart(vomitTimeBonus + 25)
		vomitCoefficient = 1
		vomitTimeBonus = 0

/// A proc to make it easier for admins to make the goose playable by deadchat.
/mob/living/simple_animal/hostile/retaliate/goose/vomit/deadchat_plays(mode = ANARCHY_MODE, cooldown = 12 SECONDS)
	. = AddComponent(/datum/component/deadchat_control/cardinal_movement, mode, list(
		"vomit" = CALLBACK(src, PROC_REF(vomit_prestart), 25),
		"honk" = CALLBACK(src, TYPE_PROC_REF(/atom/movable, say), "HONK!!!"),
		"spin" = CALLBACK(src, TYPE_PROC_REF(/mob, emote), "spin")), cooldown, CALLBACK(src, PROC_REF(stop_deadchat_plays)))

	if(. == COMPONENT_INCOMPATIBLE)
		return

	stop_automated_movement = TRUE

/datum/action/cooldown/vomit
	name = "Vomit"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "vomit"
	button_icon = 'icons/mob/simple/animal.dmi'
	cooldown_time = 250

/datum/action/cooldown/vomit/Activate(atom/target)
	if(!istype(owner, /mob/living/simple_animal/hostile/retaliate/goose/vomit))
		return FALSE

	StartCooldown(10 SECONDS)
	var/mob/living/simple_animal/hostile/retaliate/goose/vomit/probably_birdboat = owner
	if(!probably_birdboat.vomiting)
		probably_birdboat.vomit_prestart(probably_birdboat.vomitTimeBonus + 25)
		probably_birdboat.vomitCoefficient = 1
		probably_birdboat.vomitTimeBonus = 0

	StartCooldown()
	return TRUE
