//////////////////Imp

/mob/living/simple_animal/hostile/imp
	name = "imp"
	real_name = "imp"
	unique_name = TRUE
	desc = "A large, menacing creature covered in armored black scales."
	speak_emote = list("cackles")
	emote_hear = list("cackles","screeches")
	response_help_continuous = "thinks better of touching"
	response_help_simple = "think better of touching"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	response_harm_continuous = "punches"
	response_harm_simple = "punch"
	icon = 'icons/mob/simple/mob.dmi'
	icon_state = "imp"
	icon_living = "imp"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	speed = 1
	combat_mode = TRUE
	stop_automated_movement = TRUE
	status_flags = CANPUSH
	attack_sound = 'sound/magic/demon_attack1.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 250 //Weak to cold
	maxbodytemp = INFINITY
	faction = list("hell")
	attack_verb_continuous = "wildly tears into"
	attack_verb_simple = "wildly tear into"
	maxHealth = 200
	health = 200
	healable = 0
	obj_damage = 40
	melee_damage_lower = 10
	melee_damage_upper = 15
	// You KNOW we're doing a lightly purple red
	lighting_cutoff_red = 30
	lighting_cutoff_green = 10
	lighting_cutoff_blue = 20
	del_on_death = TRUE
	death_message = "screams in agony as it sublimates into a sulfurous smoke."
	death_sound = 'sound/magic/demon_dies.ogg'

//////////////////The Man Behind The Slaughter

/mob/living/simple_animal/hostile/imp/slaughter
	name = "slaughter demon"
	real_name = "slaughter demon"
	unique_name = FALSE
	speak_emote = list("gurgles")
	emote_hear = list("wails","screeches")
	icon_state = "daemon"
	icon_living = "daemon"
	minbodytemp = 0
	obj_damage = 50
	melee_damage_lower = 15 // reduced from 30 to 15 with wounds since they get big buffs to slicing wounds
	melee_damage_upper = 15
	wound_bonus = -10
	bare_wound_bonus = 0
	sharpness = SHARP_EDGED

	loot = list(/obj/effect/decal/cleanable/blood, \
				/obj/effect/decal/cleanable/blood/innards, \
				/obj/item/organ/internal/heart/demon)
	del_on_death = 1

	var/crawl_type = /datum/action/cooldown/spell/jaunt/bloodcrawl/slaughter_demon
	/// How long it takes for the alt-click slam attack to come off cooldown
	var/slam_cooldown_time = 45 SECONDS
	/// The actual instance var for the cooldown
	var/slam_cooldown = 0
	/// How many times we have hit humanoid targets since we last bloodcrawled, scaling wounding power
	var/current_hitstreak = 0
	/// How much both our wound_bonus and bare_wound_bonus go up per hitstreak hit
	var/wound_bonus_per_hit = 5
	/// How much our wound_bonus hitstreak bonus caps at (peak demonry)
	var/wound_bonus_hitstreak_max = 12

/mob/living/simple_animal/hostile/imp/slaughter/Initialize(mapload)
	. = ..()
	var/datum/action/cooldown/spell/jaunt/bloodcrawl/slaughter_demon/crawl = new crawl_type(src)
	crawl.Grant(src)
	RegisterSignals(src, list(COMSIG_MOB_ENTER_JAUNT, COMSIG_MOB_AFTER_EXIT_JAUNT), PROC_REF(on_crawl))

/// Whenever we enter or exit blood crawl, reset our bonus and hitstreaks.
/mob/living/simple_animal/hostile/imp/slaughter/proc/on_crawl(datum/source)
	SIGNAL_HANDLER

	// Grant us a speed boost if we're on the mortal plane
	if(isturf(loc))
		add_movespeed_modifier(/datum/movespeed_modifier/slaughter)
		addtimer(CALLBACK(src, PROC_REF(remove_movespeed_modifier), /datum/movespeed_modifier/slaughter), 6 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

	// Reset our streaks
	current_hitstreak = 0
	wound_bonus = initial(wound_bonus)
	bare_wound_bonus = initial(bare_wound_bonus)


/// Performs the classic slaughter demon bodyslam on the attack_target. Yeets them a screen away.
/mob/living/simple_animal/hostile/imp/slaughter/proc/bodyslam(atom/attack_target)
	if(!isliving(attack_target))
		return

	if(!Adjacent(attack_target))
		to_chat(src, span_warning("You are too far away to use your slam attack on [attack_target]!"))
		return

	if(slam_cooldown + slam_cooldown_time > world.time)
		to_chat(src, span_warning("Your slam ability is still on cooldown!"))
		return

	face_atom(attack_target)
	var/mob/living/victim = attack_target
	victim.take_bodypart_damage(brute=20, wound_bonus=wound_bonus) // don't worry, there's more punishment when they hit something
	visible_message(span_danger("[src] slams into [victim] with monstrous strength!"), span_danger("You slam into [victim] with monstrous strength!"), ignored_mobs=victim)
	to_chat(victim, span_userdanger("[src] slams into you with monstrous strength, sending you flying like a ragdoll!"))
	var/turf/yeet_target = get_edge_target_turf(victim, dir)
	victim.throw_at(yeet_target, 10, 5, src)
	slam_cooldown = world.time
	log_combat(src, victim, "slaughter slammed")

/mob/living/simple_animal/hostile/imp/slaughter/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		bodyslam(attack_target)
		return

	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return

	if(iscarbon(attack_target))
		var/mob/living/carbon/target = attack_target
		if(target.stat != DEAD && target.mind && current_hitstreak < wound_bonus_hitstreak_max)
			current_hitstreak++
			wound_bonus += wound_bonus_per_hit
			bare_wound_bonus += wound_bonus_per_hit

	return ..()

/obj/effect/decal/cleanable/blood/innards
	name = "pile of viscera"
	desc = "A repulsive pile of guts and gore."
	gender = NEUTER
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "innards"
	random_icon_states = null

//The loot from killing a slaughter demon - can be consumed to allow the user to blood crawl
/obj/item/organ/internal/heart/demon
	name = "demon heart"
	desc = "Still it beats furiously, emanating an aura of utter hate."
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "demon_heart-on"
	decay_factor = 0

/obj/item/organ/internal/heart/demon/Initialize(mapload)
	AddElement(/datum/element/update_icon_blocker)
	return ..()

/obj/item/organ/internal/heart/demon/attack(mob/M, mob/living/carbon/user, obj/target)
	if(M != user)
		return ..()
	user.visible_message(span_warning(
		"[user] raises [src] to [user.p_their()] mouth and tears into it with [user.p_their()] teeth!"),
		span_danger("An unnatural hunger consumes you. You raise [src] your mouth and devour it!"),
		)
	playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)

	if(locate(/datum/action/cooldown/spell/jaunt/bloodcrawl) in user.actions)
		to_chat(user, span_warning("...and you don't feel any different."))
		qdel(src)
		return

	user.visible_message(
		span_warning("[user]'s eyes flare a deep crimson!"),
		span_userdanger("You feel a strange power seep into your body... you have absorbed the demon's blood-travelling powers!"),
	)
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	src.Insert(user) //Consuming the heart literally replaces your heart with a demon heart. H A R D C O R E

/obj/item/organ/internal/heart/demon/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	..()
	// Gives a non-eat-people crawl to the new owner
	var/datum/action/cooldown/spell/jaunt/bloodcrawl/crawl = new(M)
	crawl.Grant(M)

/obj/item/organ/internal/heart/demon/Remove(mob/living/carbon/M, special = FALSE)
	..()
	var/datum/action/cooldown/spell/jaunt/bloodcrawl/crawl = locate() in M.actions
	qdel(crawl)

/obj/item/organ/internal/heart/demon/Stop()
	return 0 // Always beating.

/mob/living/simple_animal/hostile/imp/slaughter/laughter
	// The laughter demon! It's everyone's best friend! It just wants to hug
	// them so much, it wants to hug everyone at once!
	name = "laughter demon"
	real_name = "laughter demon"
	desc = "A large, adorable creature covered in armor with pink bows."
	speak_emote = list("giggles","titters","chuckles")
	emote_hear = list("guffaws","laughs")
	response_help_continuous = "hugs"
	attack_verb_continuous = "wildly tickles"
	attack_verb_simple = "wildly tickle"

	attack_sound = 'sound/items/bikehorn.ogg'
	attack_vis_effect = null
	death_sound = 'sound/misc/sadtrombone.ogg'

	icon_state = "bowmon"
	icon_living = "bowmon"
	death_message = "fades out, as all of its friends are released from its \
		prison of hugs."
	loot = list(/mob/living/simple_animal/pet/cat/kitten{name = "Laughter"})

	crawl_type = /datum/action/cooldown/spell/jaunt/bloodcrawl/slaughter_demon/funny
	// Keep the people we hug!
	var/list/consumed_mobs = list()

/mob/living/simple_animal/hostile/imp/slaughter/laughter/Initialize(mapload)
	. = ..()
	if(check_holidays(APRIL_FOOLS))
		icon_state = "honkmon"

/mob/living/simple_animal/hostile/imp/slaughter/laughter/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			investigate_log("has died from a devastating explosion.", INVESTIGATE_DEATHS)
			death()
		if(EXPLODE_HEAVY)
			adjustBruteLoss(60)
		if(EXPLODE_LIGHT)
			adjustBruteLoss(30)

/mob/living/simple_animal/hostile/imp/slaughter/engine_demon
	name = "engine demon"
	faction = list("hell", FACTION_NEUTRAL)
