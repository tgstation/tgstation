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
	pixel_x = -16
	base_pixel_x = -16

	maxHealth = 1200
	health = 1200

	speed = 1

	mob_biotypes = MOB_ROBOTIC|MOB_SPECIAL

	sharpness = SHARP_EDGED
	melee_attack_cooldown = CLICK_CD_MELEE
	melee_damage_lower = 30
	melee_damage_upper = 36
	damage_coeff = list(BRUTE = 0.75, BURN = 1, TOX = 0, STAMINA = 0, OXY = 0)

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

	/// REFs to mobs that we cannot attack
	VAR_PRIVATE/list/purity_list = list()
	/// REFs to mobs that we especially want to attack
	VAR_PRIVATE/list/impurity_list = list()

	/// If TRUE - The mob will automatically trigger attack when bumping a living mob
	var/bump_attack = TRUE

	/// Tracks if we are enraged or not
	VAR_PRIVATE/enraged = FALSE

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

	RegisterSignal(src, COMSIG_MOB_EXAMINING, PROC_REF(on_examining))

/mob/living/basic/boss/mechanical_spider/proc/nearby_movement(datum/source, atom/entering)
	SIGNAL_HANDLER

	if(!isliving(entering) || !(entering in dview(7, src)))
		return

	update_enraged()

/mob/living/basic/boss/mechanical_spider/proc/update_enraged()
	var/old_enraged = enraged

	enraged = FALSE
	set_varspeed(1)

	if(nutrition <= starvation_nutrition)
		enraged = TRUE

	else
		for(var/mob/living/nearby_mob in dview(7, src))
			if(nearby_mob == src)
				continue
			if(REF(nearby_mob) in impurity_list)
				enraged = TRUE

	if(enraged)
		set_varspeed(3)
		AddElement(/datum/element/door_pryer, pry_time = 5 SECONDS, interaction_key = DOAFTER_SOURCE_MECHSPIDER)
	else
		RemoveElement(/datum/element/door_pryer, pry_time = 5 SECONDS, interaction_key = DOAFTER_SOURCE_MECHSPIDER)

	if(enraged != old_enraged)
		update_appearance()

/mob/living/basic/boss/mechanical_spider/set_stat(new_stat)
	. = ..()
	update_appearance()

/mob/living/basic/boss/mechanical_spider/update_icon_state()
	. = ..()
	switch(stat)
		if(UNCONSCIOUS)
			icon_state = "sleep"
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

	wakeup_health = health - 50
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
	revive()
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

/mob/living/basic/boss/mechanical_spider/proc/assess_purity(mob/living/to_assess)
	if(!istype(to_assess) || to_assess == src || to_assess.stat == DEAD)
		return FALSE
	if(stat >= UNCONSCIOUS || (REF(to_assess) in impurity_list | purity_list))
		return
	addtimer(CALLBACK(src, PROC_REF(finish_assess_purity), to_assess), 3 SECONDS, TIMER_UNIQUE)

/mob/living/basic/boss/mechanical_spider/proc/finish_assess_purity(mob/living/to_assess)
	var/assess_key = REF(to_assess)
	if((assess_key in impurity_list | purity_list) || stat >= UNCONSCIOUS)
		return
	if(!(to_assess in dview(7, src)))
		return
	// Good luck, lmao
	if(rand(0, 10000) == 1)
		purity_list += assess_key
		to_chat(to_assess, span_green("[src] looks at you surprised. It can grant any wish, right?"))
		to_chat(src, span_green("[uppertext(src)] IS PURE. IMPOSSIBLE? PURE."))
		playsound(src, 'sound/machines/synth/synth_yes.ogg', 50, TRUE)
		return

	impurity_list += assess_key
	to_chat(assess_key, span_userdanger("You feel unsafe near [src]..."))
	to_chat(src, span_warning("[uppertext(assess_key)] IS IMPURE! IMPURE. IMPURE. IMPURE."))
	playsound(src, 'sound/machines/synth/synth_no.ogg', 25, TRUE)
	update_enraged()

//Overrides

/mob/living/basic/boss/mechanical_spider/Life(seconds_per_tick)
	. = ..()
	if(!.) // dead
		return
	if(isnull(mind) || stat >= UNCONSCIOUS)
		return
	if(SPT_PROB(2, seconds_per_tick)) // Random purity check!
		var/list/to_check_pool = list()
		for(var/mob/living/to_check in dview(7, src))
			if(to_check.stat != CONSCIOUS || isnull(to_check.mind) || isnull(to_check.client) || to_check == src)
				continue
			var/to_check_key = REF(to_check)
			if((to_check_key in impurity_list | purity_list))
				continue
			to_check_pool += to_check
		if(length(to_check_pool))
			assess_purity(pick(to_check_pool))

	adjust_nutrition(-nutrition_per_second * seconds_per_tick)
	if(nutrition <= 0) // Starvation, so you don't just run at mach 3 all the time
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
	if(get_dir(examinify, src) != examinify.dir) // Not looking in our direction
		return

	var/examine_key = REF(examinify)
	if(examine_key in purity_list)
		examine_list += "<hr>" + span_green("THEY ARE PURE.")
		return
	if(examine_key in impurity_list)
		examine_list += "<hr>" + span_warning("THEY ARE IMPURE.")
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

// If bump attack is enabled, we will automaticall attack mobs that we bump into
/mob/living/basic/boss/mechanical_spider/Bump(atom/bumped_atom)
	. = ..()
	if(bump_attack && isliving(bumped_atom) && next_move > world.time)
		UnarmedAttack(bumped_atom)

/mob/living/basic/boss/mechanical_spider/early_melee_attack(atom/target, list/modifiers, ignore_cooldown)
	if(REF(target) in purity_list)
		to_chat(src, span_green("They are pure... We will grant their wish."))
		return BASIC_MOB_END_ATTACK_CHAIN_COOLDOWN

	var/mob/living/living_target = target
	if(ishuman(target) && !ismonkey(target) && (nutrition >= starvation_nutrition) && !(REF(target) in impurity_list) && living_target.stat != DEAD)
		to_chat(src, span_warning("We cannot decide if they are pure or not just yet..."))
		return BASIC_MOB_END_ATTACK_CHAIN_COOLDOWN

	// parent call handles devour logic
	return ..()

/mob/living/basic/boss/mechanical_spider/devour(mob/living/victim)
	visible_message(span_danger("[src] stabs [victim] with its two metal legs, ripping into [victim.p_them()]!"))
	if(!do_after(src, 4 SECONDS, victim, extra_checks = CALLBACK(src, PROC_REF(should_devour), victim), interaction_key = DOAFTER_SOURCE_MECHSPIDER))
		return FALSE

	var/gained_nutriment = victim.mob_size
	if(istype(victim, /mob/living/basic/goat)) // Likes goats
		gained_nutriment = round(sleep_nutrition * 0.5)
	else if(ismonkey(victim))
		gained_nutriment = round(sleep_nutrition * 0.05)
	else if(ishuman(victim))
		gained_nutriment = round(sleep_nutrition * 0.2)

	playsound(src, 'sound/effects/magic/demon_consume.ogg', rand(15, 35), TRUE)
	visible_message(span_danger("[src] consumes [victim]!"))
	victim.gib()
	adjust_nutrition(gained_nutriment)
	adjust_brute_loss(-gained_nutriment * 1.5)
	return TRUE

// Getting attacked/examined all down here
/mob/living/basic/boss/mechanical_spider/examine(mob/user)
	. = ..()
	if(stat == UNCONSCIOUS)
		. += span_notice("It is asleep now, but not for long...")
	else
		. += span_warning("You get the feeling you shouldn't stick around.")
		assess_purity(user)

/mob/living/basic/boss/mechanical_spider/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(. && user.combat_mode)
		assess_purity(user)

/mob/living/basic/boss/mechanical_spider/attacked_by(obj/item/attacking_item, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(. != ATTACK_FAILED && attacking_item.damtype != STAMINA)
		assess_purity(user)

/mob/living/basic/boss/mechanical_spider/bullet_act(obj/projectile/proj, def_zone, piercing_hit, blocked)
	. = ..()
	if (. == BULLET_ACT_HIT && proj.firer && proj.is_hostile_projectile())
		assess_purity(proj.firer)
