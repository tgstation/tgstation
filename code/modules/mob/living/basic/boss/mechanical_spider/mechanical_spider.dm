#define DOAFTER_SOURCE_MECHSPIDER "doafter-mechspider"

/mob/living/basic/boss/mechanical_spider
	name = "mechanical spider"
	desc = "An amalgamation of exposed wires and robotic parts. It has 4 spider-like legs and a metal mask in place of the 'head'."
	icon = 'icons/mob/nonhuman-player/mechspider.dmi'
	icon_state = "active"
	icon_living = "active"
	icon_dead = "dead"
	var/icon_sleep = "sleep"
	var/icon_enrage = "rage"
	pixel_x = -4
	base_pixel_x = -4

	maxHealth = 1200
	health = 1200

	speed = 3

	mob_biotypes = MOB_ROBOTIC|MOB_SPECIAL
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG

	sharpness = SHARP_EDGED
	melee_attack_cooldown = CLICK_CD_MELEE
	melee_damage_lower = 16
	melee_damage_upper = 20
	damage_coeff = list(BRUTE = 0.8, BURN = 1, TOX = 0, STAMINA = 0, OXY = 0)
	unsuitable_atmos_damage = 1.5

	attack_verb_continuous = "eviscerates"
	attack_verb_simple = "eviscerate"
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH

	verb_say = "states"
	verb_ask = "queries"
	verb_exclaim = "declares"
	verb_yell = "alarms"
	bubble_icon = "machine"

	speech_span = SPAN_ROBOT
	death_message = "falls to the ground, beginning its reboot process..."

	nutrition = 300

	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_range = 3
	light_power = 1
	light_color = COLOR_DARK_RED
	light_on = FALSE

	/// Beyond this nutrition, the spider is forced to sleep
	var/sleep_nutrition = 640
	/// How much satiety is drained per second
	var/nutrition_per_second = 0.25
	/// Beyond this nutrition, the spider is enraged and has some restrictions lifted
	var/starvation_nutrition = 80
	/// Percentage of max HP dealt in damage when at minimum satiety
	var/starvation_damage = 0.005

	/// If is_sleeping, getting down to that health will wake us up
	VAR_PRIVATE/wakeup_health = 0

	/// How long it takes to respawn after death
	var/respawn_time = 5 MINUTES
	/// How long it takes to pry a door
	var/door_pry_time = 5 SECONDS

	/// REFs to mobs that we cannot attack
	VAR_PRIVATE/list/purity_list = list()
	/// REFs to mobs that we especially want to attack
	VAR_PRIVATE/list/impurity_list = list()

	/// Tracks if we are enraged or not
	VAR_PRIVATE/enraged = FALSE

	/// Looping sound when eating
	var/datum/looping_sound/eat_sound/eat_sound
	/// If the idle speech sound is playing
	var/idle_sound = FALSE

/mob/living/basic/boss/mechanical_spider/Initialize(mapload)
	. = ..()
	var/datum/action/adjust_vision/action = new(src)
	action.low_light_cutoff = list(18, 12, 0)
	action.medium_light_cutoff = list(30, 20, 5)
	action.high_light_cutoff = list(45, 30, 10)

	action.Grant(src)

	var/static/list/movement_triggers = list(
		COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON = PROC_REF(nearby_movement),
		COMSIG_ATOM_ENTERED = PROC_REF(nearby_movement),
		COMSIG_ATOM_EXITED = PROC_REF(nearby_movement),
	)

	AddComponent(/datum/component/connect_range, src, movement_triggers, 7, TRUE)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_RUST)
	RemoveElement(/datum/element/simple_flying)
	RemoveElement(/datum/element/wall_tearer, tear_time = 1 SECONDS)
	REMOVE_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	REMOVE_TRAIT(src, TRAIT_LAVA_IMMUNE, MEGAFAUNA_TRAIT)
	REMOVE_TRAIT(src, TRAIT_NO_TELEPORT, MEGAFAUNA_TRAIT)

	eat_sound = new(src)
	RegisterSignal(src, COMSIG_MOB_EXAMINING, PROC_REF(on_examining))
	SetSleeping(INFINITY)

/mob/living/basic/boss/mechanical_spider/Destroy()
	QDEL_NULL(eat_sound)
	return ..()

/mob/living/basic/boss/mechanical_spider/Login()
	. = ..()
	// first login wakes up from infinite sleep
	if(wakeup_health)
		return
	wake_up()

/mob/living/basic/boss/mechanical_spider/proc/nearby_movement(datum/source, atom/entering)
	SIGNAL_HANDLER

	if(!isliving(entering) || !(entering in dview(7, loc)))
		return

	addtimer(CALLBACK(src, PROC_REF(delayed_movement_reaction), entering), 3 SECONDS, TIMER_UNIQUE)

/mob/living/basic/boss/mechanical_spider/proc/delayed_movement_reaction(mob/living/entering)
	if(entering.stat == DEAD || !(entering in dview(7, loc)))
		return

	update_enraged()

/mob/living/basic/boss/mechanical_spider/proc/update_enraged()
	var/old_enraged = enraged

	enraged = FALSE
	if(nutrition <= starvation_nutrition)
		enraged = TRUE

	else
		for(var/mob/living/nearby_mob in dview(7, loc))
			if(nearby_mob == src)
				continue
			if(REF(nearby_mob) in impurity_list)
				enraged = TRUE

	if(enraged == old_enraged)
		return

	update_appearance()
	if(enraged)
		set_varspeed(1)
		AddElement(/datum/element/door_pryer, pry_time = door_pry_time, interaction_key = DOAFTER_SOURCE_MECHSPIDER)
		AddElement(/datum/element/wall_tearer, tear_time = door_pry_time * 0.67)
		to_chat(src, span_bolddanger("You enter a rage!"))
		melee_damage_lower = 30
		melee_damage_upper = 36
		set_light_on(TRUE)

	else
		set_varspeed(3)
		RemoveElement(/datum/element/door_pryer, pry_time = door_pry_time, interaction_key = DOAFTER_SOURCE_MECHSPIDER)
		RemoveElement(/datum/element/wall_tearer, tear_time = door_pry_time * 0.67)
		to_chat(src, span_boldnotice("Your rage subsides."))
		melee_damage_lower = 16
		melee_damage_upper = 20
		set_light_on(FALSE)

/mob/living/basic/boss/mechanical_spider/set_stat(new_stat)
	. = ..()
	if(stat == UNCONSCIOUS)
		overlay_fullscreen(STAT_TRAIT, /atom/movable/screen/fullscreen/blind)
	else
		clear_fullscreen(STAT_TRAIT)
	update_appearance()

/mob/living/basic/boss/mechanical_spider/update_stat()
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	if(stat != DEAD)
		if(health <= HEALTH_THRESHOLD_DEAD)
			death()
		else if(HAS_TRAIT(src, TRAIT_KNOCKEDOUT))
			set_stat(UNCONSCIOUS)
		else
			set_stat(CONSCIOUS)
	med_hud_set_status()

/mob/living/basic/boss/mechanical_spider/update_icon_state()
	. = ..()
	switch(stat)
		if(UNCONSCIOUS)
			icon_state = icon_sleep
		if(DEAD)
			icon_state = icon_dead
		else
			icon_state = enraged ? icon_enrage : icon_living

/mob/living/basic/boss/mechanical_spider/update_nutrition()
	. = ..()
	if(nutrition > sleep_nutrition && stat == CONSCIOUS)
		fall_asleep()
	update_enraged()

/mob/living/basic/boss/mechanical_spider/proc/fall_asleep()
	if(IsSleeping())
		return

	wakeup_health = max(1, health - 50)
	playsound(src, 'sound/vehicles/mecha/mech_shield_drop.ogg', vol = 75, vary = TRUE, frequency = 0.5)
	visible_message(
		span_notice("[src] falls asleep."),
		span_notice("You fall asleep."),
	)
	SetSleeping(5 MINUTES) // just set to a long time, becuase we'll wake it up via timer
	addtimer(CALLBACK(src, PROC_REF(wake_up)), rand(2, 4) MINUTES)

/mob/living/basic/boss/mechanical_spider/proc/wake_up(attacked = FALSE)
	if(!IsSleeping())
		return

	SetSleeping(2 SECONDS)
	set_nutrition(attacked ? 100 : 400) // If attacked or otherwise forced, it'll be very angry
	playsound(src, 'sound/effects/ping_hit.ogg', vol = 75, vary = TRUE, frequency = 0.5)
	visible_message(
		span_danger("[src] rises up once again!"),
		span_notice("You wake up."),
	)
	addtimer(CALLBACK(src, PROC_REF(finish_wake_up)), 2 SECONDS)

/mob/living/basic/boss/mechanical_spider/proc/finish_wake_up()
	SetSleeping(0 SECONDS)
	update_appearance()
	update_enraged()

/mob/living/basic/boss/mechanical_spider/proc/respawn()
	if(stat != DEAD)
		return

	playsound(src, 'sound/vehicles/mecha/skyfall_power_up.ogg', vol = 75, vary = TRUE, frequency = 0.5)
	addtimer(CALLBACK(src, PROC_REF(finish_respawn)), 2 SECONDS)

/mob/living/basic/boss/mechanical_spider/proc/finish_respawn()
	if(stat != DEAD)
		return

	visible_message(
		span_danger("[src] rises up once again!"),
		span_notice("You finish the reboot process."),
	)
	revive()
	set_nutrition(100)

/mob/living/basic/boss/mechanical_spider/proc/assess_purity(mob/living/to_assess, force_impure = FALSE)
	if(!istype(to_assess) || to_assess == src || to_assess.stat == DEAD)
		return FALSE
	if(stat >= UNCONSCIOUS || (REF(to_assess) in impurity_list | purity_list))
		return
	addtimer(CALLBACK(src, PROC_REF(finish_assess_purity), to_assess, force_impure), 3 SECONDS, TIMER_UNIQUE)

/mob/living/basic/boss/mechanical_spider/proc/finish_assess_purity(mob/living/to_assess, force_impure = FALSE)
	var/assess_key = REF(to_assess)
	if((assess_key in impurity_list | purity_list) || stat >= UNCONSCIOUS)
		return
	if(!(to_assess in dview(7, loc)))
		return
	if(prob(0.1) && !force_impure)
		purity_list += assess_key
		to_chat(to_assess, span_green("[src] looks at you surprised."))
		to_chat(src, span_green("[uppertext(to_assess.name)] IS PURE. IMPOSSIBLE? PURE."))
		playsound(src, 'sound/machines/synth/synth_yes.ogg', 50, TRUE, frequency = 0.5)
		return

	impurity_list += assess_key
	to_chat(assess_key, span_userdanger("You feel unsafe near [src]..."))
	to_chat(src, span_warning("[uppertext(to_assess.name)] IS IMPURE! IMPURE. IMPURE. IMPURE."))
	playsound(src, 'sound/machines/synth/synth_no.ogg', 50, TRUE, frequency = 0.5)
	update_enraged()

//Overrides

/mob/living/basic/boss/mechanical_spider/Life(seconds_per_tick)
	. = ..()
	if(!.) // dead
		return
	if(isnull(mind) || stat >= UNCONSCIOUS)
		return
	if(SPT_PROB(2, seconds_per_tick))
		var/list/to_check_pool = list()
		for(var/mob/living/to_check in dview(7, loc))
			if(to_check.stat != CONSCIOUS || isnull(to_check.mind) || isnull(to_check.client) || to_check == src)
				continue
			var/to_check_key = REF(to_check)
			if((to_check_key in impurity_list | purity_list))
				continue
			to_check_pool += to_check
		if(length(to_check_pool))
			assess_purity(pick(to_check_pool))

	if(!idle_sound && SPT_PROB(20, seconds_per_tick))
		playsound(src, 'sound/mobs/non-humanoids/mechspider.wav', vol = enraged ? 75 : 25, vary = TRUE, extrarange = enraged ? 0 : SHORT_RANGE_SOUND_EXTRARANGE)
		idle_sound = TRUE
		addtimer(VARSET_CALLBACK(src, idle_sound, FALSE), 12 SECONDS)

	adjust_nutrition(-nutrition_per_second * seconds_per_tick)
	if(nutrition <= 0)
		adjust_brute_loss(maxHealth * starvation_damage)

/mob/living/basic/boss/mechanical_spider/get_status_tab_items()
	. = ..()
	switch(stat)
		if(DEAD)
			. += "WE ARE REBOOTING."
		if(UNCONSCIOUS)
			. += "WE ARE ASLEEP."

	if(nutrition <= 0)
		. += "Satiety: I AM GOING TO STARVE TO DEATH!! ([round(nutrition)] / [sleep_nutrition])"
	else if(nutrition <= starvation_nutrition)
		. += "Satiety: I NEED MEAT RIGHT NOW! ([round(nutrition)] / [sleep_nutrition])"
	else
		. += "Satiety: [round(nutrition)] / [sleep_nutrition]"

/mob/living/basic/boss/mechanical_spider/proc/on_examining(datum/source, atom/examinify, list/examine_list)
	SIGNAL_HANDLER

	if(!isliving(examinify))
		return

	var/examine_key = REF(examinify)
	if(examine_key in purity_list)
		examine_list += "<hr>" + span_green("THEY ARE PURE.")
		return
	if(examine_key in impurity_list)
		examine_list += "<hr>" + span_warning("THEY ARE IMPURE.")
		return
	if(get_dir(examinify, src) != examinify.dir) // Not looking in our direction
		return

	examine_list += "<hr>" + span_green("ASSESSING PURITY...")
	assess_purity(examinify)

/mob/living/basic/boss/mechanical_spider/updatehealth()
	. = ..()
	if(stat == UNCONSCIOUS && health < wakeup_health)
		wake_up(TRUE)

/mob/living/basic/boss/mechanical_spider/death(gibbed)
	if(gibbed)
		return ..()

	to_chat(src, span_cult("You begin the reboot process... (This will take about [DisplayTimeText(respawn_time)].)"))
	playsound(src, 'sound/effects/ping_hit.ogg', vol = 75, vary = TRUE, frequency = 0.5)
	addtimer(CALLBACK(src, PROC_REF(respawn)), respawn_time)
	return ..()

/mob/living/basic/boss/mechanical_spider/gib()
	return

/mob/living/basic/boss/mechanical_spider/early_melee_attack(atom/target, list/modifiers, ignore_cooldown)
	if(REF(target) in purity_list)
		to_chat(src, span_green("They are pure... We will grant their wish."))
		return BASIC_MOB_END_ATTACK_CHAIN_COOLDOWN

	var/mob/living/living_target = target
	if(ishuman(target) && !ismonkey(target) && (nutrition >= starvation_nutrition) && !(REF(target) in impurity_list) && living_target.stat != DEAD)
		to_chat(src, span_warning("We cannot decide if they are pure or not just yet..."))
		return BASIC_MOB_END_ATTACK_CHAIN_COOLDOWN

	if(DOING_INTERACTION(src, DOAFTER_SOURCE_MECHSPIDER))
		return BASIC_MOB_END_ATTACK_CHAIN_COOLDOWN

	// parent call handles devour logic
	return ..()

/mob/living/basic/boss/mechanical_spider/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	if(istype(attack_target, /obj/machinery/door/airlock) && !enraged)
		return

	return ..()

/mob/living/basic/boss/mechanical_spider/should_devour(mob/living/victim)
	return ..() && (ishuman(victim) || (victim.mob_biotypes & MOB_ORGANIC))

/mob/living/basic/boss/mechanical_spider/devour(mob/living/victim)
	visible_message(span_danger("[src] stabs [victim] with its two metal legs, ripping into [victim.p_them()]!"))
	eat_sound.start()
	if(!do_after(src, 4 SECONDS, victim, extra_checks = CALLBACK(src, PROC_REF(should_devour), victim), interaction_key = DOAFTER_SOURCE_MECHSPIDER))
		eat_sound.stop()
		return FALSE

	eat_sound.stop()
	var/gained_nutriment = victim.mob_size * 10
	if(istype(victim, /mob/living/basic/goat)) // Likes goats
		gained_nutriment = round(sleep_nutrition * 0.5)
	else if(ismonkey(victim))
		gained_nutriment = round(sleep_nutrition * 0.2)
	else if(ishuman(victim))
		gained_nutriment = round(sleep_nutrition * 0.4)

	playsound(src, 'sound/effects/magic/demon_consume.ogg', rand(15, 35), TRUE)
	visible_message(span_danger("[src] consumes [victim]!"))
	victim.gib(DROP_ALL_REMAINS)
	adjust_nutrition(gained_nutriment)
	adjust_brute_loss(-gained_nutriment * 1.5)
	return TRUE

// Getting attacked/examined all down here
/mob/living/basic/boss/mechanical_spider/examine(mob/user)
	. = ..()
	if(stat == UNCONSCIOUS)
		. += span_notice("It is asleep now, but not for long...")
	else
		. += span_warning("You get the feeling you shouldn't stick around - Or look at it too closely...")
		if(get_dir(user, src) == user.dir)
			assess_purity(user)

/mob/living/basic/boss/mechanical_spider/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(. && user.combat_mode)
		assess_purity(user, force_impure = TRUE)

/mob/living/basic/boss/mechanical_spider/attacked_by(obj/item/attacking_item, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(. != ATTACK_FAILED && attacking_item.damtype != STAMINA)
		assess_purity(user, force_impure = TRUE)

/mob/living/basic/boss/mechanical_spider/bullet_act(obj/projectile/proj, def_zone, piercing_hit, blocked)
	. = ..()
	if (. == BULLET_ACT_HIT && proj.firer && proj.is_hostile_projectile())
		assess_purity(proj.firer, force_impure = TRUE)

/datum/looping_sound/eat_sound
	mid_sounds = 'sound/effects/magic/demon_consume.ogg'
	mid_length = 2 SECONDS
	volume = 25
	ignore_walls = FALSE
