/// Ratwood fallingas thresholds (carbon/life.dm handle_sleep()): Life ticks with closed eyes until sleep, on a bed and on the ground.
#define ROGUE_FALL_ASLEEP_BED 12
#define ROGUE_FALL_ASLEEP_GROUND 25
/// Mattress wear per point of brute damage to the bed: it snaps at half the damage that breaks the frame.
#define ROGUE_MATTRESS_WEAR_PER_DAMAGE 2
/// Ratwood handle_sleep(): a bodypart that bleeds this much a Life tick or more does not mend in sleep (get_bleed_rate() >= 1).
#define ROGUE_SLEEP_BLEED_LIMIT 1

/// Medieval maps: a player human falls asleep with closed eyes, heals in sleep by the bed's quality and is warmed by fires.
/mob/living/carbon/human/Initialize(mapload)
	. = ..()
	if(!rogue_survival_enabled())
		return
	AddElement(/datum/element/rogue_warm_floor)
	AddComponent(/datum/component/rogue_sleeper)

/// Ratwood sleep (code/modules/mob/living/carbon/life.dm handle_sleep()): lying down or in a bed or chair with the eyes closed, a
/// player falls asleep after a while - soon on a bed, slowly on the ground, never in medium or heavy armour or a heavy helmet -
/// and keeps sleeping while the eyes stay closed. Asleep, a fed body heals by the quality of what it sleeps on (sleepy of the
/// bed, 0.5 on the ground, rogue_sleep_quality()): every bodypart that does not bleed and its wounds, toxins, blood; a good bed
/// warms a cold sleeper. Energy in sleep is the energy element's (hud/rogue_hud_mechanics.dm).
/datum/component/rogue_sleeper
	/// How far along falling asleep is (Ratwood fallingas).
	var/falling = 0
	/// The "can't sleep in armour" line was shown.
	var/told_blocked = FALSE

/datum/component/rogue_sleeper/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/rogue_sleeper/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/component/rogue_sleeper/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_LIVING_LIFE)

/datum/component/rogue_sleeper/proc/on_life(mob/living/carbon/human/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER
	if(!source.client || source.stat == DEAD || HAS_TRAIT(source, TRAIT_NOSLEEP))
		falling = 0
		return
	if(source.IsSleeping())
		falling = 0
		told_blocked = FALSE
		sleep_heal(source, seconds_per_tick)
		if(source.rogue_eyes_closed)
			source.Sleeping(30 SECONDS)
		return
	var/quality = source.rogue_sleep_quality()
	if(!source.rogue_eyes_closed || source.stat != STABLE || (!quality && source.body_position != LYING_DOWN))
		falling = 0
		told_blocked = FALSE
		return
	if(armor_keeps_awake(source))
		if(!told_blocked)
			to_chat(source, span_warning("I can't sleep like this. My armor is burdening me."))
			told_blocked = TRUE
		return
	if(!falling)
		to_chat(source, span_warning((quality ? "I'll fall asleep soon..." : "I'll fall asleep soon, although a bed would be more comfortable...")))
	falling += HAS_TRAIT(source, TRAIT_FASTSLEEP) ? 2 : 1
	// Ratwood: the night fatigue (survival/fatigue.dm) brings sleep sooner - in bed from the second step, on the ground at the third.
	var/fatigue = source.rogue_fatigue_stage()
	if(quality)
		falling += fatigue >= 3 ? 2 : (fatigue == 2 ? 1 : 0)
	else if(fatigue >= 3)
		falling++
	if(falling > (quality ? ROGUE_FALL_ASLEEP_BED : ROGUE_FALL_ASLEEP_GROUND))
		falling = 0
		source.Sleeping(30 SECONDS)

/// Ratwood: a heavy helmet (stab armour over 70) or medium or heavy body armour keeps one awake, unless it cannot come off; the
/// exhausted (third step of night fatigue, survival/fatigue.dm) sleep in anything.
/datum/component/rogue_sleeper/proc/armor_keeps_awake(mob/living/carbon/human/source)
	if(source.rogue_fatigue_stage() >= 3)
		return FALSE
	var/obj/item/clothing/helmet = source.head
	if(istype(helmet) && !HAS_TRAIT(helmet, TRAIT_NODROP))
		var/datum/rogue_armor/armor = helmet.get_rogue_armor()
		if(armor?.stab > 70)
			return TRUE
	var/obj/item/clothing/suit = source.wear_suit
	if(istype(suit) && !HAS_TRAIT(suit, TRAIT_NODROP) && suit.armor_class >= ARMOR_CLASS_MEDIUM)
		return TRUE
	return FALSE

/// Ratwood healing in sleep, per two seconds: brute and burn of every bodypart that bleeds less than a unit a Life tick (bandage
/// counted, combat/blood.dm), and each of its wounds by the wound's sleep_healing (combat/medicine.dm rogue_sleep_healing(),
/// heal_wound(sleep_healing * sleepy_mod)), toxins, blood, by the quality of the bed (0.5 on the ground). A bedroll or better
/// warms a cold sleeper.
/datum/component/rogue_sleeper/proc/sleep_heal(mob/living/carbon/human/source, seconds_per_tick)
	var/quality = source.rogue_sleep_quality() || ROGUE_ENERGY_GROUND_FACTOR
	if(quality >= 2 && source.bodytemperature < BODYTEMP_NORMAL - ROGUE_FIRE_REST_COLD)
		source.adjust_bodytemperature(0.5 * seconds_per_tick / 2)
	if(source.nutrition <= 0 && !HAS_TRAIT(source, TRAIT_NOHUNGER))
		return
	var/amount = quality * CONFIG_GET(number/rogue_sleep_heal_multiplier) * seconds_per_tick / 2
	if(amount <= 0)
		return
	var/need_update = FALSE
	for(var/obj/item/bodypart/part as anything in source.bodyparts)
		if(part.rogue_limb_bleed_rate() * ROGUE_LIFE_TICK >= ROGUE_SLEEP_BLEED_LIMIT)
			continue
		if(part.heal_damage(amount, amount, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC))
			need_update = TRUE
		for(var/datum/wound/wound as anything in LAZYCOPY(part.wounds))
			var/sleep_healing = wound.rogue_sleep_healing()
			if(sleep_healing > 0)
				wound.rogue_heal_wound(sleep_healing * amount)
	if(!source.is_bleeding())
		source.adjust_blood_volume(4 * amount, maximum = BLOOD_VOLUME_NORMAL)
	need_update += source.adjust_tox_loss(-amount, updating_health = FALSE, required_biotype = MOB_ORGANIC)
	if(need_update)
		source.updatehealth()
		source.update_damage_overlays()

/// Ratwood mattress (code/game/objects/structures/beds_chairs/roguechair.dm damage_bed()): a good bed wears out and its mattress
/// snaps, after which it sleeps no better than a straw bed. Ratwood wears it only in its adult content, which is not ported; here
/// blows to the bed wear the mattress before the frame. Straw beds and bedrolls (quality 2 or less) do not break further.
/obj/structure/bed/rockhill/rogue
	var/broken_matress = FALSE
	/// Wear of the mattress, 100 - broken.
	var/broken_percentage = 0
	/// How fast it wears (double beds half as fast).
	var/broken_rate = 1

/obj/structure/bed/rockhill/rogue/inn/double
	broken_rate = 0.5

/obj/structure/bed/rockhill/rogue/inn/wooldouble
	broken_rate = 0.5

/obj/structure/bed/rockhill/rogue/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	. = ..()
	if(. && damage_type == BRUTE && !QDELETED(src))
		damage_bed(. * ROGUE_MATTRESS_WEAR_PER_DAMAGE)

/obj/structure/bed/rockhill/rogue/proc/damage_bed(wear)
	if(broken_matress)
		return
	if(sleepy <= 2)
		return
	broken_percentage = min(broken_percentage + wear * broken_rate, 100)
	if(broken_percentage < 100)
		playsound(src, pick('modular_redtard/survival/sound/bed_squeak1.ogg', 'modular_redtard/survival/sound/bed_squeak2.ogg', 'modular_redtard/survival/sound/bed_squeak3.ogg'), 25, TRUE, ignore_walls = FALSE)
		if(broken_percentage > 10)
			playsound(src, 'modular_redtard/survival/sound/bed_damage.ogg', broken_percentage / 4, TRUE, ignore_walls = FALSE)
		return
	broken_matress = TRUE
	sleepy = 1
	desc += " The bed looks stained and has seen better daes."
	visible_message(span_warning("\The [src] gives a violent snap. It looks broken!"))
	playsound(src, 'modular_redtard/survival/sound/bed_break.ogg', 50, TRUE, ignore_walls = FALSE)

/obj/structure/bed/rockhill/rogue/examine(mob/user)
	. = ..()
	if(broken_matress)
		. += span_warning("Its mattress is broken.")
	else if(broken_percentage >= 50)
		. += span_notice("Its mattress is worn.")

/// Ratwood bedroll (roguechair.dm bed/rogue/bedroll): a hand on it rolls it up in two seconds; the rolled bedroll (/obj/item/bedroll)
/// is laid out again in hand on free ground.
/obj/structure/bed/rockhill/rogue/bedroll/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || has_buckled_mobs())
		return
	user.visible_message(span_notice("[user] begins rolling up \the [src]."))
	if(!do_after(user, 2 SECONDS, target = src) || has_buckled_mobs())
		return TRUE
	var/obj/item/bedroll/rolled = new(drop_location())
	rolled.color = color
	qdel(src)
	user.put_in_hands(rolled)
	return TRUE

/obj/item/bedroll/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return
	var/turf/spot = get_turf(user)
	if(!isfloorturf(spot))
		to_chat(user, span_warning("I need ground to plant this on!"))
		return TRUE
	if(!bedroll_fits(user, spot))
		return TRUE
	user.visible_message(span_notice("[user] begins placing \the [src] down on the ground."))
	if(!do_after(user, 2 SECONDS, target = spot) || !bedroll_fits(user, spot))
		return TRUE
	var/obj/structure/bed/rockhill/rogue/bedroll/laid = new(spot)
	laid.color = color
	qdel(src)
	return TRUE

/obj/item/bedroll/proc/bedroll_fits(mob/user, turf/spot)
	for(var/obj/thing in spot)
		if(isstructure(thing))
			to_chat(user, span_warning("I need some free space to deploy \the [src] here!"))
			return FALSE
		if(thing.density && !(thing.flags_1 & ON_BORDER_1))
			to_chat(user, span_warning("There is already something here!"))
			return FALSE
	return TRUE

/obj/item/bedroll/examine(mob/user)
	. = ..()
	. += span_notice("Use it in hand to lay it out on the ground.")

#undef ROGUE_FALL_ASLEEP_BED
#undef ROGUE_FALL_ASLEEP_GROUND
#undef ROGUE_MATTRESS_WEAR_PER_DAMAGE
#undef ROGUE_SLEEP_BLEED_LIMIT
