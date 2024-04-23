#define LEFT_RIGHT_COMBO "DH"
#define RIGHT_LEFT_COMBO "HD"
#define LEFT_LEFT_COMBO "HH"
#define RIGHT_RIGHT_COMBO "DD"

/datum/martial_art/boxing
	name = "Boxing"
	id = MARTIALART_BOXING
	pacifist_style = TRUE
	///Boolean on whether we are sportsmanlike in our tussling; TRUE means we have restrictions
	var/honorable_boxer = TRUE
	/// List of traits applied to users of this martial art.
	var/list/boxing_traits = list(TRAIT_BOXING_READY)
	/// Balloon alert cooldown for warning our boxer to alternate their blows to get more damage
	COOLDOWN_DECLARE(warning_cooldown)

/datum/martial_art/boxing/teach(mob/living/new_holder, make_temporary)
	if(!ishuman(new_holder))
		return FALSE
	new_holder.add_traits(boxing_traits, BOXING_TRAIT)
	RegisterSignal(new_holder, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(check_block))
	return ..()

/datum/martial_art/boxing/on_remove(mob/living/remove_from)
	remove_from.remove_traits(boxing_traits, BOXING_TRAIT)
	UnregisterSignal(remove_from, list(COMSIG_LIVING_CHECK_BLOCK))
	return ..()

///Unlike most instances of this proc, this is actually called in _proc/tussle()
///Returns a multiplier on our skill damage bonus.
/datum/martial_art/boxing/proc/check_streak(mob/living/attacker, mob/living/defender)
	var/combo_multiplier = 1

	if(findtext(streak, LEFT_LEFT_COMBO) || findtext(streak, RIGHT_RIGHT_COMBO))
		reset_streak()
		if(COOLDOWN_FINISHED(src, warning_cooldown))
			COOLDOWN_START(src, warning_cooldown, 2 SECONDS)
			attacker.balloon_alert(attacker, "weak combo, alternate your hits!")
		return combo_multiplier * 0.5

	if(findtext(streak, LEFT_RIGHT_COMBO) || findtext(streak, RIGHT_LEFT_COMBO))
		reset_streak()
		return combo_multiplier * 1.5

	return combo_multiplier

/datum/martial_art/boxing/disarm_act(mob/living/attacker, mob/living/defender)
	if(honor_check(defender))
		add_to_streak("D", defender)
	tussle(attacker, defender, "right hook", "right hooked")
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/boxing/grab_act(mob/living/attacker, mob/living/defender)
	if(honorable_boxer)
		attacker.balloon_alert(attacker, "no grabbing while boxing!")
		return MARTIAL_ATTACK_FAIL
	return MARTIAL_ATTACK_INVALID //UNLESS YOU'RE EVIL

/datum/martial_art/boxing/harm_act(mob/living/attacker, mob/living/defender)
	if(honor_check(defender))
		add_to_streak("H", defender)
	tussle(attacker, defender, "left hook", "left hooked")
	return MARTIAL_ATTACK_SUCCESS

// Our only boxing move, which occurs on literally all attacks; the tussle. However, quite a lot morphs the results of this proc. Combos, unlike most martial arts attacks, are checked in this proc rather than our standard unarmed procs
/datum/martial_art/boxing/proc/tussle(mob/living/attacker, mob/living/defender, atk_verb = "blind jab", atk_verbed = "blind jabbed")

	if(honorable_boxer) //Being a good sport, you never hit someone on the ground or already knocked down. It shows you're the better person.
		if(defender.body_position == LYING_DOWN && defender.getStaminaLoss() >= 100 || defender.IsUnconscious()) //If they're in stamcrit or unconscious, don't bloody punch them
			attacker.balloon_alert(attacker, "unsportsmanlike behaviour!")
			return FALSE

	var/obj/item/bodypart/arm/active_arm = attacker.get_active_hand()

	//The values between which damage is rolled for punches
	var/lower_force = active_arm.unarmed_damage_low
	var/upper_force = active_arm.unarmed_damage_high

	//Determines knockout potential and armor penetration (if that matters)
	var/base_unarmed_effectiveness = active_arm.unarmed_effectiveness

	//Determines attack sound based on attacker arm
	var/attack_sound = active_arm.unarmed_attack_sound

	// Out athletics skill is added as a damage bonus
	var/athletics_skill =  attacker.mind?.get_skill_level(/datum/skill/athletics)

	// If true, grants experience for punching; we only gain experience if we punch another boxer.
	var/grant_experience = FALSE

	// What type of damage does our kind of boxing do? Defaults to STAMINA, unless you're performing EVIL BOXING
	var/damage_type = honorable_boxer ? STAMINA : attacker.get_attack_type()

	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)

	//Determines damage dealt on a punch. Against a boxing defender, we apply our skill bonus.
	var/damage = rand(lower_force, upper_force)

	if(honor_check(defender))
		var/strength_bonus = HAS_TRAIT(attacker, TRAIT_STRENGTH) ? 2 : 0 //Investing into genetic strength improvements makes you a better boxer
		damage += round(athletics_skill * check_streak(attacker, defender) + strength_bonus)
		grant_experience = TRUE

	var/current_atk_verb = atk_verb
	var/current_atk_verbed = atk_verbed

	if(is_detective_job(attacker.mind?.assigned_role)) //In short: discombobulate
		current_atk_verb = "discombobulate"
		current_atk_verbed = "discombulated"

	// Similar to a normal punch, should we have a value of 0 for our lower force, we simply miss outright.
	if(!lower_force)
		playsound(defender.loc, active_arm.unarmed_miss_sound, 25, TRUE, -1)
		defender.visible_message(span_warning("[attacker]'s [current_atk_verb] misses [defender]!"), \
			span_danger("You avoid [attacker]'s [current_atk_verb]!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, attacker)
		to_chat(attacker, span_warning("Your [current_atk_verb] misses [defender]!"))
		log_combat(attacker, defender, "attempted to hit", current_atk_verb)
		return FALSE

	if(defender.check_block(attacker, damage, "[attacker]'s [current_atk_verb]", UNARMED_ATTACK))
		return FALSE

	var/obj/item/bodypart/affecting = defender.get_bodypart(defender.get_random_valid_zone(attacker.zone_selected))
	var/armor_block = defender.run_armor_check(affecting, MELEE, armour_penetration = base_unarmed_effectiveness)

	playsound(defender, attack_sound, 25, TRUE, -1)

	defender.visible_message(
		span_danger("[attacker] [current_atk_verbed] [defender]!"),
		span_userdanger("You're [current_atk_verbed] by [attacker]!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		COMBAT_MESSAGE_RANGE,
		attacker,
	)

	to_chat(attacker, span_danger("You [current_atk_verbed] [defender]!"))

	defender.apply_damage(damage, damage_type, affecting, armor_block)

	log_combat(attacker, defender, "punched (boxing) ")

	if(grant_experience)
		skill_experience_adjustment(attacker, (damage/lower_force))

	if(defender.stat == DEAD || !honor_check(defender)) //early returning here so we don't worry about knockout probs
		return TRUE

	//Determine our attackers athletics level as a knockout probability bonus
	var/attacker_athletics_skill =  (attacker.mind?.get_skill_modifier(/datum/skill/athletics, SKILL_RANDS_MODIFIER) + base_unarmed_effectiveness)

	// Defender boxing skill and armor block are used as a defense here. This has already factored in base_unarmed_effectiveness from the attacker
	var/defender_athletics_skill =  clamp(defender.mind?.get_skill_modifier(/datum/skill/athletics, SKILL_RANDS_MODIFIER), 0, 100)

	//Determine our final probability, using a clamp to stop any prob() weirdness.
	var/final_knockout_probability = clamp(round(attacker_athletics_skill - defender_athletics_skill), 0 , 100)

	if(!prob(final_knockout_probability))
		return TRUE

	if(defender.get_timed_status_effect_duration(/datum/status_effect/staggered))
		defender.visible_message(
			span_danger("[attacker] knocks [defender] out with a haymaker!"),
			span_userdanger("You're knocked unconscious by [attacker]!"),
			span_hear("You hear a sickening sound of flesh hitting flesh!"),
			COMBAT_MESSAGE_RANGE,
			attacker,
		)
		to_chat(attacker, span_danger("You knock [defender] out with a haymaker!"))
		defender.apply_effect(20 SECONDS, EFFECT_KNOCKDOWN, armor_block)
		defender.SetSleeping(10 SECONDS)
		log_combat(attacker, defender, "knocked out (boxing) ")
	else
		defender.visible_message(
			span_danger("[attacker] staggers [defender] with a haymaker!"),
			span_userdanger("You're nearly knocked off your feet by [attacker]!"),
			span_hear("You hear a sickening sound of flesh hitting flesh!"),
			COMBAT_MESSAGE_RANGE,
			attacker,
		)
		defender.adjust_staggered_up_to(STAGGERED_SLOWDOWN_LENGTH, 10 SECONDS)
		to_chat(attacker, span_danger("You stagger [defender] with a haymaker!"))
		log_combat(attacker, defender, "staggered (boxing) ")

	playsound(defender, 'sound/effects/coin2.ogg', 40, TRUE)
	new /obj/effect/temp_visual/crit(get_turf(defender))
	skill_experience_adjustment(attacker, (damage/lower_force)) //double experience for a successful crit

	return TRUE

/// Returns whether whoever is checked by this proc is complying with the rules of boxing. The boxer cannot block non-boxers, and cannot apply their scariest moves against non-boxers.
/datum/martial_art/boxing/proc/honor_check(mob/living/possible_boxer)
	if(!honorable_boxer)
		return TRUE //You scoundrel!!

	if(!HAS_TRAIT(possible_boxer, TRAIT_BOXING_READY))
		return FALSE

	return TRUE

/// Handles our instances of experience gain while boxing. It also applies the exercised status effect.
/datum/martial_art/boxing/proc/skill_experience_adjustment(mob/living/boxer, experience_value)
	//Boxing in heavier gravity gives you more experience
	var/gravity_modifier = boxer.has_gravity() > STANDARD_GRAVITY ? 1 : 0.5

	//You gotta sleep before you get any experience!
	boxer.mind?.adjust_experience(/datum/skill/athletics, experience_value * gravity_modifier)
	boxer.apply_status_effect(/datum/status_effect/exercised)

/// Handles our blocking signals, similar to hit_reaction() on items. Only blocks while the boxer is in throw mode.
/datum/martial_art/boxing/proc/check_block(mob/living/boxer, atom/movable/hitby, damage, attack_text, attack_type, ...)
	SIGNAL_HANDLER

	if(!can_use(boxer) || !boxer.throw_mode || boxer.incapacitated(IGNORE_GRAB))
		return NONE

	if(attack_type != UNARMED_ATTACK)
		return NONE

	//Determines unarmed defense against boxers using our current active arm.
	var/obj/item/bodypart/arm/active_arm = boxer.get_active_hand()
	var/base_unarmed_effectiveness = active_arm.unarmed_effectiveness

	// Out athletics skill is added to our block potential
	var/athletics_skill_rands =  boxer.mind?.get_skill_modifier(/datum/skill/athletics, SKILL_RANDS_MODIFIER)

	var/block_chance = base_unarmed_effectiveness + athletics_skill_rands

	var/block_text = pick("block", "evade")

	if(!prob(block_chance))
		return NONE

	var/mob/living/attacker = GET_ASSAILANT(hitby)

	if(!honor_check(attacker))
		return NONE

	if(istype(attacker) && boxer.Adjacent(attacker))
		attacker.apply_damage(10, STAMINA)
		boxer.apply_damage(5, STAMINA)

	boxer.visible_message(
		span_danger("[boxer] [block_text]s [attack_text]!"),
		span_userdanger("You [block_text] [attack_text]!"),
	)
	if(block_text == "evade")
		playsound(boxer.loc, active_arm.unarmed_miss_sound, 25, TRUE, -1)

	skill_experience_adjustment(boxer, 1) //just getting hit a bunch doesn't net you much experience

	return SUCCESSFUL_BLOCK

/datum/martial_art/boxing/can_use(mob/living/martial_artist)
	if(!ishuman(martial_artist))
		return FALSE
	return ..()

/// Evil Boxing; for sick, evil scoundrels. Has no honor, making it more lethal (therefore unable to be used by pacifists).
/// Grants Strength and Stimmed to speed up any experience gain.

/datum/martial_art/boxing/evil
	name = "Evil Boxing"
	id = MARTIALART_EVIL_BOXING
	pacifist_style = FALSE
	honorable_boxer = FALSE
	boxing_traits = list(TRAIT_BOXING_READY, TRAIT_STRENGTH, TRAIT_STIMMED)

#undef LEFT_RIGHT_COMBO
#undef RIGHT_LEFT_COMBO
#undef LEFT_LEFT_COMBO
#undef RIGHT_RIGHT_COMBO
