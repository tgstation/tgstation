#define NARSIE_CHANCE_TO_PICK_NEW_TARGET 5
#define NARSIE_CONSUME_RANGE 12
#define NARSIE_GRAV_PULL 10
#define NARSIE_MESMERIZE_CHANCE 25
#define NARSIE_MESMERIZE_EFFECT 60
#define NARSIE_SINGULARITY_SIZE 12

/// Nar'Sie, the God of the blood cultists
/obj/narsie
	name = "Nar'Sie"
	desc = "Your mind begins to bubble and ooze as it tries to comprehend what it sees."
	icon = 'icons/obj/narsie.dmi'
	icon_state = "narsie"
	anchored = TRUE
	appearance_flags = LONG_GLIDE
	density = FALSE
	gender = FEMALE
	layer = MASSIVE_OBJ_LAYER
	light_color = COLOR_RED
	light_power = 0.7
	light_range = 15
	light_range = 6
	move_resist = INFINITY
	obj_flags = CAN_BE_HIT | DANGEROUS_POSSESSION
	pixel_x = -236
	pixel_y = -256
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = SUPERMATTER_IGNORES_1

	/// The singularity component to move around Nar'Sie.
	/// A weak ref in case an admin removes the component to preserve the functionality.
	var/datum/weakref/singularity

	var/list/souls_needed = list()
	var/soul_goal = 0
	var/souls = 0
	var/resolved = FALSE

/obj/narsie/Initialize()
	. = ..()

	AddElement(/datum/element/point_of_interest)

	singularity = WEAKREF(AddComponent(
		/datum/component/singularity, \
		bsa_targetable = FALSE, \
		consume_callback = CALLBACK(src, .proc/consume), \
		consume_range = NARSIE_CONSUME_RANGE, \
		disregard_failed_movements = TRUE, \
		grav_pull = NARSIE_GRAV_PULL, \
		roaming = FALSE, /* This is set once the animation finishes */ \
		singularity_size = NARSIE_SINGULARITY_SIZE, \
	))

	send_to_playing_players("<span class='narsie'>NAR'SIE HAS RISEN</span>")
	sound_to_playing_players('sound/creatures/narsie_rises.ogg')

	var/area/area = get_area(src)
	if(area)
		var/mutable_appearance/alert_overlay = mutable_appearance('icons/effects/cult_effects.dmi', "ghostalertsie")
		notify_ghosts("Nar'Sie has risen in [area]. Reach out to the Geometer to be given a new shell for your soul.", source = src, alert_overlay = alert_overlay, action = NOTIFY_ATTACK)
	narsie_spawn_animation()

	GLOB.cult_narsie = src
	var/list/all_cults = list()

	for (var/datum/antagonist/cult/cultist in GLOB.antagonists)
		if (!cultist.owner)
			continue
		all_cults |= cultist.cult_team

	for (var/_cult_team in all_cults)
		var/datum/team/cult/cult_team = _cult_team
		deltimer(cult_team.blood_target_reset_timer)
		cult_team.blood_target = src
		var/datum/objective/eldergod/summon_objective = locate() in cult_team.objectives
		if(summon_objective)
			summon_objective.summoned = TRUE

	for (var/_cult_mind in SSticker.mode.cult)
		var/datum/mind/cult_mind = _cult_mind
		if (isliving(cult_mind.current))
			var/mob/living/L = cult_mind.current
			L.narsie_act()

	for (var/mob/living/carbon/player in GLOB.player_list)
		if (player.stat != DEAD && is_station_level(player.loc?.z) && !iscultist(player))
			souls_needed[player] = TRUE

	soul_goal = round(1 + LAZYLEN(souls_needed) * 0.75)
	INVOKE_ASYNC(GLOBAL_PROC, .proc/begin_the_end)

/obj/narsie/Destroy()
	send_to_playing_players("<span class='narsie'>\"<b>[pick("Nooooo...", "Not die. How-", "Die. Mort-", "Sas tyen re-")]\"</b></span>")
	sound_to_playing_players('sound/magic/demon_dies.ogg', 50)

	var/list/all_cults = list()

	for (var/datum/antagonist/cult/cultist in GLOB.antagonists)
		if (!cultist.owner)
			continue
		all_cults |= cultist.cult_team

	for(var/_cult_team in all_cults)
		var/datum/team/cult/cult_team = _cult_team
		var/datum/objective/eldergod/summon_objective = locate() in cult_team.objectives
		if (summon_objective)
			summon_objective.summoned = FALSE
			summon_objective.killed = TRUE

	return ..()

/obj/narsie/attack_ghost(mob/user)
	makeNewConstruct(/mob/living/simple_animal/hostile/construct/harvester, user, cultoverride = TRUE, loc_override = loc)

/obj/narsie/process()
	var/datum/component/singularity/singularity_component = singularity.resolve()

	if (!isnull(singularity_component) && (!singularity_component?.target || prob(NARSIE_CHANCE_TO_PICK_NEW_TARGET)))
		pickcultist()

	if (prob(NARSIE_MESMERIZE_CHANCE))
		mesmerize()

/obj/narsie/Bump(atom/target)
	var/turf/target_turf = get_turf(target)
	if (target_turf == loc)
		target_turf = get_step(target, target.dir) //please don't slam into a window like a bird, Nar'Sie
	forceMove(target_turf)

/// Stun people around Nar'Sie that aren't cultists
/obj/narsie/proc/mesmerize()
	for (var/mob/living/carbon/victim in viewers(NARSIE_CONSUME_RANGE, src))
		if (victim.stat == CONSCIOUS)
			if (!iscultist(victim))
				to_chat(victim, "<span class='cultsmall'>You feel conscious thought crumble away in an instant as you gaze upon [src]...</span>")
				victim.apply_effect(NARSIE_MESMERIZE_EFFECT, EFFECT_STUN)

/// Narsie rewards her cultists with being devoured first, then picks a ghost to follow.
/obj/narsie/proc/pickcultist()
	var/list/cultists = list()
	var/list/noncultists = list()

	for (var/mob/living/carbon/food in GLOB.alive_mob_list) //we don't care about constructs or cult-Ians or whatever. cult-monkeys are fair game i guess
		var/turf/pos = get_turf(food)
		if (!pos || (pos.z != z))
			continue

		if (iscultist(food))
			cultists += food
		else
			noncultists += food

		if (cultists.len) //cultists get higher priority
			acquire(pick(cultists))
			return

		if (noncultists.len)
			acquire(pick(noncultists))
			return

	//no living humans, follow a ghost instead.
	for (var/mob/dead/observer/ghost in GLOB.player_list)
		var/turf/pos = get_turf(ghost)
		if (!pos || (pos.z != z))
			continue
		cultists += ghost
	if (cultists.len)
		acquire(pick(cultists))
		return

/// Nar'Sie gets a taste of something, and will start to gravitate towards it
/obj/narsie/proc/acquire(atom/food)
	var/datum/component/singularity/singularity_component = singularity.resolve()

	if (isnull(singularity_component))
		return

	var/old_target = singularity_component.target
	if (food == old_target)
		return

	to_chat(old_target, "<span class='cultsmall'>NAR'SIE HAS LOST INTEREST IN YOU.</span>")
	singularity_component.target = food
	if(ishuman(food))
		to_chat(food, "<span class='cult'>NAR'SIE HUNGERS FOR YOUR SOUL.</span>")
	else
		to_chat(food, "<span class='cult'>NAR'SIE HAS CHOSEN YOU TO LEAD HER TO HER NEXT MEAL.</span>")

/// Called to make Nar'Sie convert objects to cult stuff, or to eat
/obj/narsie/proc/consume(atom/target)
	if (isturf(target))
		target.narsie_act()

/obj/narsie/proc/narsie_spawn_animation()
	setDir(SOUTH)
	flick("narsie_spawn_anim", src)
	addtimer(CALLBACK(src, .proc/narsie_spawn_animation_end), 3.5 SECONDS)

/obj/narsie/proc/narsie_spawn_animation_end()
	var/datum/component/singularity/singularity_component = singularity.resolve()
	singularity_component?.roaming = TRUE

/**
 * Begins the process of ending the round via cult narsie win
 * Consists of later called procs (in order of called):
 *  * [/proc/narsie_end_begin_check()]
 *  * [/proc/narsie_end_second_check()]
 *  * [/proc/narsie_start_destroy_station()]
 *  * [/proc/narsie_apocalypse()]
 *  * [/proc/narsie_last_second_win()]
 *  * [/proc/cult_ending_helper()]
 */
/proc/begin_the_end()
	addtimer(CALLBACK(GLOBAL_PROC, .proc/narsie_end_begin_check), 5 SECONDS)

///First crew last second win check and flufftext for [/proc/begin_the_end()]
/proc/narsie_end_begin_check()
	if(QDELETED(GLOB.cult_narsie)) // uno
		priority_announce("Status report? We detected an anomaly, but it disappeared almost immediately.","Central Command Higher Dimensional Affairs", 'sound/misc/notice1.ogg')
		GLOB.cult_narsie = null
		addtimer(CALLBACK(GLOBAL_PROC, .proc/cult_ending_helper, 2), 2 SECONDS)
		return
	priority_announce("An acausal dimensional event has been detected in your sector. Event has been flagged EXTINCTION-CLASS. Directing all available assets toward simulating solutions. SOLUTION ETA: 60 SECONDS.","Central Command Higher Dimensional Affairs", 'sound/misc/airraid.ogg')
	addtimer(CALLBACK(GLOBAL_PROC, .proc/narsie_end_second_check), 50 SECONDS)

///Second crew last second win check and flufftext for [/proc/begin_the_end()]
/proc/narsie_end_second_check()
	if(QDELETED(GLOB.cult_narsie)) // dos
		priority_announce("Simulations aborted, sensors report that the acasual event is normalizing. Good work, crew.","Central Command Higher Dimensional Affairs", 'sound/misc/notice1.ogg')
		GLOB.cult_narsie = null
		addtimer(CALLBACK(GLOBAL_PROC, .proc/cult_ending_helper, 2), 2 SECONDS)
		return
	priority_announce("Simulations on acausal dimensional event complete. Deploying solution package now. Deployment ETA: ONE MINUTE. ","Central Command Higher Dimensional Affairs")
	addtimer(CALLBACK(GLOBAL_PROC, .proc/narsie_start_destroy_station), 5 SECONDS)

///security level and shuttle lockdowns for [/proc/begin_the_end()]
/proc/narsie_start_destroy_station()
	set_security_level("delta")
	SSshuttle.registerHostileEnvironment(GLOB.cult_narsie)
	SSshuttle.lockdown = TRUE
	addtimer(CALLBACK(GLOBAL_PROC, .proc/narsie_apocalypse), 1 MINUTES)

///Third crew last second win check and flufftext for [/proc/begin_the_end()]
/proc/narsie_apocalypse()
	if(QDELETED(GLOB.cult_narsie)) // tres
		priority_announce("Normalization detected! Abort the solution package!","Central Command Higher Dimensional Affairs", 'sound/misc/notice1.ogg')
		GLOB.cult_narsie = null
		addtimer(CALLBACK(GLOBAL_PROC, .proc/narsie_last_second_win), 2 SECONDS)
		return
	if(GLOB.cult_narsie.resolved == FALSE)
		GLOB.cult_narsie.resolved = TRUE
		sound_to_playing_players('sound/machines/alarm.ogg')
		addtimer(CALLBACK(GLOBAL_PROC, .proc/cult_ending_helper), 12 SECONDS)

///Called only if the crew managed to destroy narsie at the very last second for [/proc/begin_the_end()]
/proc/narsie_last_second_win()
	set_security_level("red")
	SSshuttle.clearHostileEnvironment()
	SSshuttle.lockdown = FALSE
	INVOKE_ASYNC(GLOBAL_PROC, .proc/cult_ending_helper, 2)

///Helper to set the round to end asap. Current usage Cult round end code
/proc/ending_helper()
	SSticker.force_ending = 1

/**
 * Selects cinematic to play as part of the cult end depending on the outcome then ends the round afterward
 * called either when narsie eats everyone, or when [/proc/begin_the_end()] reaches it's conclusion
 */
/proc/cult_ending_helper(ending_type = 0)
	if(ending_type == 2) //narsie fukkin died
		Cinematic(CINEMATIC_CULT_FAIL,world,CALLBACK(GLOBAL_PROC,/proc/ending_helper))
	else if(ending_type) //no explosion
		Cinematic(CINEMATIC_CULT,world,CALLBACK(GLOBAL_PROC,/proc/ending_helper))
	else // explosion
		Cinematic(CINEMATIC_CULT_NUKE,world,CALLBACK(GLOBAL_PROC,/proc/ending_helper))

#undef NARSIE_CHANCE_TO_PICK_NEW_TARGET
#undef NARSIE_CONSUME_RANGE
#undef NARSIE_GRAV_PULL
#undef NARSIE_MESMERIZE_CHANCE
#undef NARSIE_MESMERIZE_EFFECT
#undef NARSIE_SINGULARITY_SIZE
