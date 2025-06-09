#define HERETIC_LEVEL_START 1
#define HERETIC_LEVEL_UPGRADE 2
#define HERETIC_LEVEL_FINAL 3

/datum/status_effect/heretic_passive
	id = "heretic_passive"
	duration = STATUS_EFFECT_PERMANENT
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	on_remove_on_mob_delete = TRUE
	///What level is our passive currently on
	var/passive_level = HERETIC_LEVEL_START
	var/name = "Heretic Passive"
	var/tier_1_description = "Grants you a passive ability based on your heretic type. This ability will upgrade as you gain more power."
	var/tier_2_description = "Your passive ability has been upgraded, doing something else."
	var/tier_3_description = "Your passive ability has been upgraded to its final form, granting you a powerful new ability."

/datum/status_effect/heretic_passive/on_apply()
	. = ..()
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(owner)
	if(!heretic_datum)
		return FALSE
	// Just in case of shenanigans, assume the antag datum is correct about our level
	if(heretic_datum.passive_level == 3)
		heretic_level_final()
		return
	if(heretic_datum.passive_level == 2)
		heretic_level_upgrade()
		return

/// Gives our first upgrade
/datum/status_effect/heretic_passive/proc/heretic_level_upgrade()
	SHOULD_CALL_PARENT(TRUE)
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(owner)
	passive_level = HERETIC_LEVEL_UPGRADE
	heretic_datum.passive_level = HERETIC_LEVEL_UPGRADE

/// Gives our final upgrade
/datum/status_effect/heretic_passive/proc/heretic_level_final()
	SHOULD_CALL_PARENT(TRUE)
	if(passive_level == HERETIC_LEVEL_START)
		heretic_level_upgrade()
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(owner)
	passive_level = HERETIC_LEVEL_FINAL
	heretic_datum.passive_level = HERETIC_LEVEL_FINAL

//---- Ash Passive
// Level 1 grants heat and ash storm immunity
// Level 2 grants lava immunity
// Level 3 grants resistance to high pressure
/datum/status_effect/heretic_passive/ash/on_apply()
	. = ..()
	owner.add_traits(list(TRAIT_RESISTHEAT, TRAIT_ASHSTORM_IMMUNE), REF(src))

/datum/status_effect/heretic_passive/ash/heretic_level_upgrade()
	. = ..()
	ADD_TRAIT(owner, TRAIT_LAVA_IMMUNE, REF(src))

/datum/status_effect/heretic_passive/ash/heretic_level_final()
	. = ..()
	owner.add_traits(list(TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTLOWPRESSURE), REF(src))

/datum/status_effect/heretic_passive/ash/on_remove()
	owner.remove_traits(list(TRAIT_RESISTHEAT, TRAIT_ASHSTORM_IMMUNE, TRAIT_LAVA_IMMUNE, TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTLOWPRESSURE), REF(src))
	return ..()

//---- Blade Passive
// Gives you riposte while wielding a heretic blade
// Cooldown starts at 20 and goes down 5 seconds per level
// Level 1 has a 20 second cooldown + counts as block
// Level 2 Makes you immune to fall damage/stun from falling
// Level 3 only has the cooldown reduction (nothing else added)
/datum/status_effect/heretic_passive/blade
	/// The cooldown before we can riposte again
	var/base_cooldown = 20 SECONDS
	/// The cooldown reduction gained from upgrading
	var/cooldown_reduction = 5 SECONDS
	/// Whether the counter-attack is ready or not.
	/// Used so we can give feedback when it's ready again
	var/riposte_ready = TRUE

/datum/status_effect/heretic_passive/blade/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(on_shield_reaction))

/datum/status_effect/heretic_passive/blade/heretic_level_upgrade()
	. = ..()
	RegisterSignal(owner, COMSIG_LIVING_Z_IMPACT, PROC_REF(z_impact_react))

/datum/status_effect/heretic_passive/blade/on_remove()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_LIVING_CHECK_BLOCK, COMSIG_LIVING_Z_IMPACT))

/// Blocks the effects from falling
/datum/status_effect/heretic_passive/blade/proc/z_impact_react(datum/source, levels, turf/fell_on)
	SIGNAL_HANDLER
	new /obj/effect/temp_visual/mook_dust(fell_on)
	owner.visible_message(span_notice("[owner] lands on [fell_on] safely, and quite stylishly on [p_their()] feet"))
	return ZIMPACT_CANCEL_DAMAGE | ZIMPACT_NO_MESSAGE | ZIMPACT_NO_SPIN

/// Checks if we can counter-attack
/datum/status_effect/heretic_passive/blade/proc/on_shield_reaction(
	mob/living/carbon/human/source,
	atom/movable/hitby,
	damage = 0,
	attack_text = "the attack",
	attack_type = MELEE_ATTACK,
	armour_penetration = 0,
	damage_type = BRUTE,
)
	SIGNAL_HANDLER

	if(attack_type != MELEE_ATTACK)
		return

	if(!riposte_ready)
		return

	if(INCAPACITATED_IGNORING(source, INCAPABLE_GRAB))
		return

	var/mob/living/attacker = hitby.loc
	if(!istype(attacker))
		return

	if(!source.Adjacent(attacker))
		return

	// Let's check their held items to see if we can do a riposte
	var/obj/item/main_hand = source.get_active_held_item()
	var/obj/item/off_hand = source.get_inactive_held_item()
	// This is the item that ends up doing the "blocking" (flavor)
	var/obj/item/striking_with

	// First we'll check if the offhand is valid
	if(!QDELETED(off_hand) && istype(off_hand, /obj/item/melee/sickly_blade))
		striking_with = off_hand

	// Then we'll check the mainhand
	// We do mainhand second, because we want to prioritize it over the offhand
	if(!QDELETED(main_hand) && istype(main_hand, /obj/item/melee/sickly_blade))
		striking_with = main_hand

	// No valid item in either slot? No riposte
	if(!striking_with)
		return

	// If we made it here, deliver the strike
	INVOKE_ASYNC(src, PROC_REF(counter_attack), source, attacker, striking_with, attack_text)

	// And reset after a bit
	riposte_ready = FALSE
	addtimer(CALLBACK(src, PROC_REF(reset_riposte), source), (base_cooldown - cooldown_reduction * (passive_level - 1)))

	if(passive_level > HERETIC_LEVEL_START)
		return SUCCESSFUL_BLOCK

/// Does the actual counter-attack
/datum/status_effect/heretic_passive/blade/proc/counter_attack(mob/living/carbon/human/source, mob/living/target, obj/item/melee/sickly_blade/weapon, attack_text)
	playsound(get_turf(source), 'sound/items/weapons/parry.ogg', 100, TRUE)
	source.balloon_alert(source, "riposte used")
	source.visible_message(
		span_warning("[source] leans into [attack_text] and delivers a sudden riposte back at [target]!"),
		span_warning("You lean into [attack_text] and deliver a sudden riposte back at [target]!"),
		span_hear("You hear a clink, followed by a stab."),
	)
	weapon.melee_attack_chain(source, target)

/// Gives feedback to the user
/datum/status_effect/heretic_passive/blade/proc/reset_riposte(mob/living/carbon/human/source)
	riposte_ready = TRUE
	source.balloon_alert(source, "riposte ready")

//---- Cosmic Passive
// Level 1 Cosmic fields will speed up the caster and provide stamina regen
// Level 2 Cosmic fields will disable any nearby bombs/TTVs/Syndicate Bombs
// Level 3 Cosmic fields will temporarily slow down bullets that pass through them
/datum/status_effect/heretic_passive/cosmic

/datum/status_effect/heretic_passive/cosmic/tick(seconds_between_ticks)
	. = ..()
	if(locate(/obj/effect/forcefield/cosmic_field) in get_turf(owner))
		var/delta_time = DELTA_WORLD_TIME(SSmobs) * 0.5 // SSmobs.wait is 2 secs, so this should be halved.
		owner.adjustStaminaLoss(-15 * delta_time, updating_stamina = FALSE)

/**
 * Creates a cosmic field at a given loc
 *
 * * Args:
 * * `loc`: Where the cosmic field is created
 * * Optional `creator`: Checks if the passed mob has a cosmic passive. Upgrades the cosmic field based on their passive level
 * * Optional `type`: Makes a specific type of cosmic field if we don't want the default
 */
/proc/create_cosmic_field(loc, mob/living/creator, type = /obj/effect/forcefield/cosmic_field)
	var/obj/effect/forcefield/cosmic_field/new_field
	new_field = new type(loc)

	if(!creator || !ismob(creator))
		return
	if(istype(creator, /mob/living/basic/heretic_summon/star_gazer))
		new_field.slows_projectiles()
		new_field.prevents_explosions()
		return
	var/datum/status_effect/heretic_passive/cosmic/cosmic_passive = creator.has_status_effect(/datum/status_effect/heretic_passive/cosmic)
	if(!cosmic_passive)
		return
	if(cosmic_passive.passive_level > HERETIC_LEVEL_START)
		new_field.prevents_explosions()
	if(cosmic_passive.passive_level > HERETIC_LEVEL_UPGRADE)
		new_field.slows_projectiles()

//---- Flesh Passive
// Makes you never get disgust, virus immune and immune to damage from space ants
// Level 2, organs and raw meat heals you. You also become a voracious glutton who likes all food
// Level 3, no slowdown from being fat, being fat gives damage resistance
/datum/status_effect/heretic_passive/flesh/on_apply()
	. = ..()
	owner.add_traits(list(TRAIT_VIRUSIMMUNE, TRAIT_SPACE_ANT_IMMUNITY), REF(src))

/datum/status_effect/heretic_passive/flesh/tick(seconds_between_ticks)
	. = ..()
	owner.set_disgust(0)

/datum/status_effect/heretic_passive/flesh/heretic_level_upgrade()
	. = ..()
	RegisterSignal(owner, COMSIG_FOOD_BIT, PROC_REF(on_eat))
	owner.add_traits(list(TRAIT_FAT_IGNORE_SLOWDOWN, TRAIT_VORACIOUS, TRAIT_GLUTTON), REF(src))
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/fat_human = owner
	fat_human.on_fat() // Make sure to update the movespeed modifier in case we gain the trait while already fat
	var/obj/item/organ/tongue/tongue = fat_human.get_organ_slot(ORGAN_SLOT_TONGUE)
	tongue.liked_foodtypes = MEAT | VEGETABLES | RAW | JUNKFOOD | GRAIN | FRUIT | DAIRY | FRIED | ALCOHOL | SUGAR | GROSS | TOXIC | PINEAPPLE | BREAKFAST | CLOTH | NUTS | SEAFOOD | ORANGES | BUGS | GORE | STONE
	tongue.disliked_foodtypes = NONE
	tongue.toxic_foodtypes = NONE

/// Any time you take a bite of something, if it's meat or an organ you will heal some damage
/datum/status_effect/heretic_passive/flesh/proc/on_eat(mob/eater, atom/food)
	SIGNAL_HANDLER
	if(istype(food, /obj/item/organ))
		var/obj/item/organ/consumed_organ = food
		if(!(consumed_organ.foodtype_flags & MEAT))
			return
		owner.adjustBruteLoss(-2)
		owner.adjustFireLoss(-2)
		owner.adjustOxyLoss(-2)
		owner.adjustToxLoss(-2, forced = TRUE)
		if(owner?.blood_volume)
			owner.blood_volume += 2.5
		if(!iscarbon(eater))
			return
		var/mob/living/carbon/carbon_eater = eater
		for(var/obj/item/bodypart/wounded_limb as anything in carbon_eater.bodyparts)
			for(var/datum/wound/to_cure as anything in wounded_limb.wounds)
				to_cure.remove_wound()
		return

	if(!istype(food, /obj/item/food))
		return
	var/obj/item/food/consumed_food = food
	if(!(consumed_food.foodtypes & MEAT))
		return

	owner.adjustBruteLoss(-2)
	owner.adjustFireLoss(-2)
	owner.adjustOxyLoss(-2)
	owner.adjustToxLoss(-2, forced = TRUE)
	if(owner?.blood_volume)
		owner.blood_volume += 2.5
	if(!iscarbon(eater))
		return
	var/mob/living/carbon/carbon_eater = eater
	for(var/obj/item/bodypart/wounded_limb as anything in carbon_eater.bodyparts)
		for(var/datum/wound/to_cure as anything in wounded_limb.wounds)
			to_cure.remove_wound()

/datum/status_effect/heretic_passive/flesh/heretic_level_final()
	. = ..()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/fat_human = owner
	RegisterSignals(fat_human, list(SIGNAL_ADDTRAIT(TRAIT_FAT), SIGNAL_REMOVETRAIT(TRAIT_FAT)), PROC_REF(on_fat))
	on_fat()

/// Gives/Removes damage resistance when we become/lose fatness
/datum/status_effect/heretic_passive/flesh/proc/on_fat(datum/source)
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/heretic = owner
	if(HAS_TRAIT(heretic, TRAIT_FAT))
		heretic.physiology.damage_resistance += 15
	else
		heretic.physiology.damage_resistance -= 15

/datum/status_effect/heretic_passive/flesh/on_remove()
	. = ..()
	owner.remove_traits(list(TRAIT_VIRUSIMMUNE, TRAIT_SPACE_ANT_IMMUNITY, TRAIT_FAT_IGNORE_SLOWDOWN, TRAIT_VORACIOUS, TRAIT_GLUTTON), REF(src))
	UnregisterSignal(owner, list(COMSIG_FOOD_BIT, SIGNAL_ADDTRAIT(TRAIT_FAT), SIGNAL_REMOVETRAIT(TRAIT_FAT)))
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/heretic = owner
	if(!HAS_TRAIT(heretic, TRAIT_FAT))
		return
	heretic.physiology.damage_resistance -= 15
	heretic.on_fat()

//---- Lock Passive
// On gain you can understand and speak every language
// Level 1 Hand insulation + Side knowledge is cheaper
// Level 2 Gains X-ray Vision
// Level 3 your grasp no longer goes on cooldown when opening things
/datum/status_effect/heretic_passive/lock/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_SHOCKIMMUNE, REF(src))

/datum/status_effect/heretic_passive/lock/heretic_level_upgrade()
	. = ..()
	ADD_TRAIT(owner, TRAIT_XRAY_VISION, REF(src))
	owner.update_sight()

/datum/status_effect/heretic_passive/lock/heretic_level_final()
	. = ..()
	ADD_TRAIT(owner, TRAIT_LOCK_GRASP_UPGRADED, REF(src))

/datum/status_effect/heretic_passive/lock/on_remove()
	owner.remove_traits(list(TRAIT_SHOCKIMMUNE, TRAIT_XRAY_VISION, TRAIT_LOCK_GRASP_UPGRADED), REF(src))
	owner.update_sight()
	return ..()

//---- Moon Passive
// Heals 5 brain damage per level
// Prevents brain trauma
// Level 2 grants sleep immunity
// Level 3, Mind gate + Ringleader's rise will channel the moon amulet effects
/datum/status_effect/heretic_passive/moon
	/// Built-in moon amulet which channels through your spells
	var/obj/item/clothing/neck/heretic_focus/moon_amulet/amulet
	/// When were we last attacked?
	var/last_attack = 0

/datum/status_effect/heretic_passive/moon/on_apply()
	. = ..()
	var/obj/item/organ/brain/our_brain = owner.get_organ_slot(ORGAN_SLOT_BRAIN)
	ADD_TRAIT(our_brain, TRAIT_BRAIN_TRAUMA_IMMUNITY, REF(src))
	owner.AddElement(/datum/element/relay_attackers)
	RegisterSignal(owner, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))

/// Saves world.time when we are attacked by anything
/datum/status_effect/heretic_passive/moon/proc/on_attacked(mob/victim, atom/attacker)
	SIGNAL_HANDLER
	last_attack = world.time

/datum/status_effect/heretic_passive/moon/tick(seconds_between_ticks)
	. = ..()
	owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, ((world.time > last_attack + 5 SECONDS) ? 0 : -5 * passive_level * seconds_between_ticks))

	var/obj/item/organ/brain/our_brain = owner.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(!our_brain)
		return
	for(var/datum/brain_trauma/trauma as anything in our_brain.traumas)
		if(istype(trauma, BRAIN_TRAUMA_MILD) || istype(trauma, BRAIN_TRAUMA_SEVERE))
			our_brain.cure_trauma_type(trauma.type, trauma.resilience)

/datum/status_effect/heretic_passive/moon/heretic_level_upgrade()
	. = ..()
	ADD_TRAIT(owner, TRAIT_SLEEPIMMUNE, REF(src))

/datum/status_effect/heretic_passive/moon/heretic_level_final()
	. = ..()
	amulet = new(owner) // Yeah just shove an amulet up his ass, he'll be fine

/datum/status_effect/heretic_passive/moon/on_remove()
	var/obj/item/organ/brain/our_brain = owner.get_organ_slot(ORGAN_SLOT_BRAIN)
	REMOVE_TRAIT(our_brain, TRAIT_BRAIN_TRAUMA_IMMUNITY, REF(src))
	REMOVE_TRAIT(owner, TRAIT_SLEEPIMMUNE, REF(src))
	UnregisterSignal(owner, COMSIG_ATOM_WAS_ATTACKED)
	qdel(amulet)
	return ..()

//---- Rust Passive
// Level 2 and 3 will increase our rust strength
// Level 1 provides healing and baton resist when standing on rust
// Level 2 will heal wounds when standing on rust
// Level 3 will restore lost limbs when standing on rust
/datum/status_effect/heretic_passive/rust/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(owner, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/status_effect/heretic_passive/rust/on_remove()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_LIFE))

/datum/status_effect/heretic_passive/rust/heretic_level_upgrade()
	. = ..()
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(owner)
	if(heretic_datum.rust_strength < 2)
		heretic_datum.increase_rust_strength() // Bring us up to 2

/datum/status_effect/heretic_passive/rust/heretic_level_final()
	. = ..()
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(owner)
	if(heretic_datum.rust_strength < 3)
		heretic_datum.increase_rust_strength() // Bring us up to 3

/*
 * Signal proc for [COMSIG_MOVABLE_MOVED].
 *
 * Checks if we should have baton resistance on the new turf.
 */
/datum/status_effect/heretic_passive/rust/proc/on_move(mob/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	var/turf/mover_turf = get_turf(source)
	if(HAS_TRAIT(mover_turf, TRAIT_RUSTY))
		ADD_TRAIT(source, TRAIT_BATON_RESISTANCE, REF(src))
	else
		REMOVE_TRAIT(source, TRAIT_BATON_RESISTANCE, REF(src))

/**
 * Signal proc for [COMSIG_LIVING_LIFE].
 *
 * Gradually heals the heretic ([source]) on rust,
 * including baton knockdown and stamina damage.
 */
/datum/status_effect/heretic_passive/rust/proc/on_life(mob/living/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	var/turf/our_turf = get_turf(source)
	if(!HAS_TRAIT(our_turf, TRAIT_RUSTY))
		return

	// Heals all damage + Stamina
	var/need_mob_update = FALSE
	var/delta_time = DELTA_WORLD_TIME(SSmobs) * 0.5 // SSmobs.wait is 2 secs, so this should be halved.
	need_mob_update += source.adjustBruteLoss((-1) * delta_time, updating_health = FALSE)
	need_mob_update += source.adjustFireLoss((-1) * delta_time, updating_health = FALSE)
	need_mob_update += source.adjustToxLoss((-1) * delta_time, updating_health = FALSE, forced = TRUE) // Slimes are people too
	need_mob_update += source.adjustOxyLoss((-1) * delta_time, updating_health = FALSE)
	need_mob_update += source.adjustStaminaLoss((-5) * delta_time, updating_stamina = FALSE)
	if(need_mob_update)
		source.updatehealth()
	// Reduces duration of stuns/etc
	source.AdjustAllImmobility((-0.5 SECONDS) * delta_time)
	// Heals blood loss
	if(source.blood_volume < BLOOD_VOLUME_NORMAL)
		source.blood_volume += 2.5 * delta_time

	if(!iscarbon(source))
		return
	var/mob/living/carbon/carbon_owner = source
	if(passive_level < HERETIC_LEVEL_UPGRADE)
		return
	for(var/obj/item/bodypart/wounded_limb as anything in carbon_owner.bodyparts)
		for(var/datum/wound/to_cure as anything in wounded_limb.wounds)
			to_cure.remove_wound()
	if(passive_level < HERETIC_LEVEL_FINAL)
		return
	if(length(carbon_owner.get_missing_limbs()))
		carbon_owner.regenerate_limbs()

//---- Void Passive
// Level 1 Cold and Low pressure resist
// Level 2 No breathe
// Level 3 No slip on water/ice
/datum/status_effect/heretic_passive/void/on_apply()
	. = ..()
	owner.add_traits(list(TRAIT_RESISTCOLD, TRAIT_RESISTLOWPRESSURE), REF(src))

/datum/status_effect/heretic_passive/void/heretic_level_upgrade()
	. = ..()
	ADD_TRAIT(owner, TRAIT_NOBREATH, REF(src))

/datum/status_effect/heretic_passive/void/heretic_level_final()
	. = ..()
	owner.add_traits(list(TRAIT_NO_SLIP_WATER, TRAIT_NO_SLIP_ICE, TRAIT_NO_SLIP_SLIDE), REF(src))

/datum/status_effect/heretic_passive/void/on_remove()
	. = ..()
	owner.remove_traits(list(TRAIT_RESISTCOLD, TRAIT_RESISTLOWPRESSURE, TRAIT_NOBREATH, TRAIT_NO_SLIP_WATER, TRAIT_NO_SLIP_ICE, TRAIT_NO_SLIP_SLIDE), REF(src))

#undef HERETIC_LEVEL_START
#undef HERETIC_LEVEL_UPGRADE
#undef HERETIC_LEVEL_FINAL
