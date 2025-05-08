#define WOUND_COMBO "HH"
#define DROP_COMBO "DD"
#define LONG_COMBO "HDH"
//Breacher Knuckle has no way to add a grab to your streak, which means you can grab at any point during it without interrupting your combo. Neato!
/datum/martial_art/breacher_knuckle
	name = "Breacher Knuckle"
	id = MARTIALART_BREACHERKNUCKLE
	help_verb = /mob/living/proc/breacher_knuckle_help
	display_combos = TRUE

/datum/martial_art/breacher_knuckle/proc/check_streak(mob/living/attacker, mob/living/defender)
	if(findtext(streak,WOUND_COMBO))
		reset_streak()
		return woundStrike(attacker, defender)

	if(findtext(streak,DROP_COMBO))
		reset_streak()
		return dropStrike(attacker, defender)

	if(findtext(streak,LONG_COMBO))
		reset_streak()
		return longStrike(attacker, defender)

	return FALSE

///Shipbreaker Strike: Harm Harm, 22 force and wound bonus. For breaking bones.
/datum/martial_art/breacher_knuckle/proc/woundStrike(mob/living/attacker, mob/living/defender)
	var/obj/item/bodypart/affecting = defender.get_bodypart(defender.get_random_valid_zone(attacker.zone_selected))
	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("brutally kick", "violently elbow", "precisely punche", "viciously strike")
	defender.visible_message(
		span_danger("[attacker] [atk_verb]s [defender]!"),
		span_userdanger("[attacker] [atk_verb]s you!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		null,
		attacker,
	)
	to_chat(attacker, span_danger("You deliver a breaking strike to [defender]!"))
	playsound(defender, 'sound/items/weapons/breachknuckle/doubleStrike.ogg', 50, TRUE, -1)
	log_combat(attacker, defender, "wound striked (breacher knuckle)")
	defender.apply_damage(22, attacker.get_attack_type(), affecting, wound_bonus = 20) //essence of bone hurting
	return TRUE

///Orbital Launch: Disarm Disarm, knocks down.
/datum/martial_art/breacher_knuckle/proc/dropStrike(mob/living/attacker, mob/living/defender)
	var/obj/item/bodypart/affecting = defender.get_bodypart(defender.get_random_valid_zone(attacker.zone_selected))
	attacker.do_attack_animation(defender, ATTACK_EFFECT_KICK)
	var/atk_verb = pick("brutally drop", "violently knee")
	defender.visible_message(
		span_danger("[attacker] [atk_verb]s [defender]!"),
		span_userdanger("[attacker] [atk_verb]s you!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		null,
		attacker,
	)
	to_chat(attacker, span_danger("You orbital drop [defender]!"))
	playsound(defender, 'sound/items/weapons/breachknuckle/doubleStrike.ogg', 50, TRUE, -1)
	log_combat(attacker, defender, "drop strike (breacher knuckle)")
	defender.apply_damage(22, attacker.get_attack_type(), affecting)
	defender.Knockdown(6 SECONDS)
	return TRUE

///Crescent Kick: Harm Disarm Harm combo, gives you the dreaded THROW FUNCTION. Means you can loop this to lock someone down. Requires a wall though.
/datum/martial_art/breacher_knuckle/proc/longStrike(mob/living/attacker, mob/living/defender)
	var/obj/item/bodypart/affecting = defender.get_bodypart(defender.get_random_valid_zone(attacker.zone_selected))
	attacker.do_attack_animation(defender, ATTACK_EFFECT_KICK)
	var/atk_verb = pick("axe kick", "roundhouse kick")
	defender.visible_message(
		span_danger("[attacker] [atk_verb]s [defender]!"),
		span_userdanger("[attacker] [atk_verb]s you!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		null,
		attacker,
	)
	to_chat(attacker, span_danger("You deliver a crescent kick to [defender]!"))
	playsound(defender, 'sound/items/weapons/breachknuckle/longStrike.ogg', 50, TRUE, -1)
	log_combat(attacker, defender, "launch strike (breacher knuckle)")
	var/atom/throw_target = get_edge_target_turf(defender, attacker.dir)
	defender.throw_at(throw_target, 3, 4, attacker)
	defender.apply_damage(25, attacker.get_attack_type(), affecting, wound_bonus = 18)
	return TRUE

/datum/martial_art/breacher_knuckle/harm_act(mob/living/attacker, mob/living/defender)

	var/atk_verb = pick("kick", "strike", "hit", "slam")
	if(defender.check_block(attacker, 17, "[attacker]'s [atk_verb]", UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL

	add_to_streak("H", defender)
	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS

	var/obj/item/bodypart/affecting = defender.get_bodypart(defender.get_random_valid_zone(attacker.zone_selected))
	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	defender.visible_message(
		span_danger("[attacker] [atk_verb]s [defender]!"),
		span_userdanger("[attacker] [atk_verb]s you!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		null,
		attacker,
	)
	to_chat(attacker, span_danger("You [atk_verb] [defender]!"))
	defender.apply_damage(17, attacker.get_attack_type(), affecting)
	playsound(defender, 'sound/items/weapons/breachknuckle/basicStrike.ogg', 50, TRUE, -1)
	log_combat(attacker, defender, "punched (breacher knuckle)")
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/breacher_knuckle/disarm_act(mob/living/attacker, mob/living/defender)

	if(defender.check_block(attacker, 0, attacker.name, UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL

	add_to_streak("D", defender)
	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS

	var/obj/item/bodypart/affecting = defender.get_bodypart(defender.get_random_valid_zone(attacker.zone_selected))
	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	playsound(defender, 'sound/items/weapons/breachknuckle/shoveStrike.ogg', 50, TRUE, -1)
	defender.apply_damage(17, attacker.get_attack_type(), affecting)
	log_combat(attacker, defender, "dis-harmed (breacher knuckle)")
	return MARTIAL_ATTACK_INVALID // normal disarm after we hurt people

/// Verb added to anyone with breacher knuckle.
/mob/living/proc/breacher_knuckle_help()
	set name = "Recall Teachings"
	set desc = "Remember your martial training."
	set category = "Breacher Knuckle"

	to_chat(usr, "<b><i>You think, and recall what you've learned about unarmed combat...</i></b>\n\
	[span_notice("Shipbreaker Strike")]: Punch Punch. Deal additional damage with a bonus to wound.\n\
	[span_notice("Orbital Drop")]: Shove Shove. Deal additional damage with a knockdown and a slow.\n\
	[span_notice("Crescent Kick")]: Punch Shove Punch. Deliver a devestating launching kick. Launches far, wounds good, and hurts like hell.\n\
	[span_notice("Shove-kick")]: Your disarms now additionally deal moderate damage.</span>")


/obj/item/clothing/gloves/breacher_knuckle
	name = "breacher nanogloves"
	desc = "These hands of mine glow with an awesome power!"
	icon_state = "black"
	greyscale_colors = COLOR_BLACK
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE

/obj/item/clothing/gloves/breacher_knuckle/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/martial_art_giver, /datum/martial_art/breacher_knuckle)

#undef WOUND_COMBO
#undef DROP_COMBO
#undef LONG_COMBO
