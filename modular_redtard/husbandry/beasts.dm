/// What Ratwood writes in code, not in vars, for single beasts (the porter brings the vars: husbandry/ported/husbandry.dm), and the
/// vars of riding, milking, manure and kinship the porter does not bring yet (Ratwood can_saddle, move_to_delay of a mount, the
/// saddle states of update_icon(), milkies, pooptype, faction).

/// Deciseconds a tipped cow lies on its side (Ratwood cow attack_hand(): Paralyze 60).
#define ROGUE_TIP_TIME rogue_value("cow_tip_time")

/// Saigas and goats eat weepvines (Ratwood saiga/find_food(), goat/find_food(), goat and goatmale Life()).
/// Saigas and goats are mounts, the saiga doe and the nanny goat with saddle states of their own.
/mob/living/simple_animal/hostile/retaliate/rogue/saiga
	rogue_eats_vines = TRUE
	rogue_can_saddle = TRUE
	rogue_saddle_state = "saddle-f"
	rogue_saddle_front_state = "saddle-f-above"
	rogue_mounted_state = "saiga_mounted"
	rogue_manure_type = /obj/item/natural/poo/horse
	rogue_kin = "saiga"

/mob/living/simple_animal/hostile/retaliate/rogue/goat
	rogue_eats_vines = TRUE
	rogue_can_saddle = TRUE
	rogue_saddle_state = "saddle-f"
	rogue_saddle_front_state = "saddle-f-above"
	rogue_mounted_state = "goat_mounted"
	rogue_milk_type = /datum/reagent/consumable/milk
	rogue_manure_type = /obj/item/natural/poo/horse
	rogue_kin = "goats"

/mob/living/simple_animal/hostile/retaliate/rogue/goatmale
	rogue_eats_vines = TRUE
	rogue_taunt_angers = TRUE
	rogue_can_saddle = TRUE
	rogue_mounted_state = "goatmale_mounted"
	rogue_manure_type = /obj/item/natural/poo/horse
	rogue_kin = "goats"

/// Bulls, billy goats, saiga bucks and swine charge whoever taunts them (Ratwood taunted()).
/mob/living/simple_animal/hostile/retaliate/rogue/bull
	rogue_taunt_angers = TRUE
	rogue_manure_type = /obj/item/natural/poo/cow
	rogue_kin = "cows"

/mob/living/simple_animal/hostile/retaliate/rogue/saiga/saigabuck
	rogue_taunt_angers = TRUE
	rogue_saddle_state = "saddle"
	rogue_saddle_front_state = "saddle-above"
	rogue_mounted_state = "buck_mounted"

/mob/living/simple_animal/hostile/retaliate/rogue/saiga/saigabuck/tame/saddled
	rogue_start_saddled = TRUE

/// The deadite saiga is a risen corpse, no mount and none of the saigas' kin (Ratwood faction "zombie").
/mob/living/simple_animal/hostile/retaliate/rogue/saiga/undead
	rogue_can_saddle = FALSE
	rogue_manure_type = null
	rogue_kin = null

/mob/living/simple_animal/hostile/retaliate/rogue/swine
	rogue_taunt_angers = TRUE
	rogue_manure_type = /obj/item/natural/poo/horse
	rogue_kin = "pigs"

/// The hog is the slowest mount (Ratwood move_to_delay 10).
/mob/living/simple_animal/hostile/retaliate/rogue/swine/hog
	rogue_can_saddle = TRUE
	rogue_mount_delay = 10
	rogue_mounted_state = "piggie_mounted"

/// Horses (Ratwood modular_helmsguard horse.dm) are mounts of the horse kin; their sheet has no "saddle-above" state, so the
/// saddle is drawn under the rider only.
/mob/living/simple_animal/hostile/retaliate/rogue/horse
	rogue_can_saddle = TRUE
	rogue_saddle_front_state = null
	rogue_manure_type = /obj/item/natural/poo/horse
	rogue_kin = "horse"

/mob/living/simple_animal/hostile/retaliate/rogue/horse/male/black
	rogue_mounted_state = "horseblack_mounted"

/mob/living/simple_animal/hostile/retaliate/rogue/horse/male/black/tame/saddled
	rogue_start_saddled = TRUE

/mob/living/simple_animal/hostile/retaliate/rogue/horse/male/brown
	rogue_mounted_state = "horsebrown_mounted"

/mob/living/simple_animal/hostile/retaliate/rogue/horse/male/brown/tame/saddled
	rogue_start_saddled = TRUE

/mob/living/simple_animal/hostile/retaliate/rogue/horse/male/white
	rogue_mounted_state = "horsewhite_mounted"

/mob/living/simple_animal/hostile/retaliate/rogue/horse/male/white/tame/saddled
	rogue_start_saddled = TRUE

/// A cow is tipped over by a shove (Ratwood cow attack_hand()); the calves have no art for it.
/mob/living/simple_animal/hostile/retaliate/rogue/cow
	rogue_milk_type = /datum/reagent/consumable/milk
	rogue_manure_type = /obj/item/natural/poo/cow
	rogue_kin = "cows"
	rogue_tip_state = "cow_tip"

/mob/living/simple_animal/hostile/retaliate/rogue/cow/cowlet
	rogue_tip_state = null

/mob/living/simple_animal/hostile/retaliate/rogue/cow/bullet
	rogue_tip_state = null

/mob/living/simple_animal/hostile/retaliate/rogue/chicken
	rogue_manure_type = /obj/item/natural/poo/horse
	rogue_kin = "chickens"

/mob/living/simple_animal/hostile/retaliate/rogue/trufflepig
	rogue_manure_type = /obj/item/natural/poo/horse
	rogue_kin = "pigs"

/// The beetle carries one rider and drops nothing (Ratwood pooptype = null); its saddle is one state drawn twice.
/mob/living/simple_animal/hostile/retaliate/rogue/beetle
	rogue_can_saddle = TRUE
	rogue_mount_seats = 1
	rogue_saddle_front_state = "saddle"
	rogue_manure_type = null
	rogue_kin = "beetles"

/// Beasts that drop nothing when fed (Ratwood pooptype = null): rats, bears, mimics, minotaurs, moles, spiders and wolves.
/mob/living/simple_animal/hostile/retaliate/rogue/bigrat
	rogue_manure_type = null

/mob/living/simple_animal/hostile/retaliate/rogue/direbear
	rogue_manure_type = null

/mob/living/simple_animal/hostile/retaliate/rogue/mimic
	rogue_manure_type = null

/mob/living/simple_animal/hostile/retaliate/rogue/minotaur
	rogue_manure_type = null

/mob/living/simple_animal/hostile/retaliate/rogue/mole
	rogue_manure_type = null

/mob/living/simple_animal/hostile/retaliate/rogue/spider
	rogue_manure_type = null

/mob/living/simple_animal/hostile/retaliate/rogue/wolf
	rogue_manure_type = null

/mob/living/simple_animal/hostile/retaliate/rogue/wolf_undead
	rogue_manure_type = null

/mob/living/simple_animal/hostile/retaliate/rogue/beetle/tame/saddled
	rogue_start_saddled = TRUE

/// Goats and the hog seat their riders lower than the saiga (Ratwood goat, goatmale and hog tamed()).
/mob/living/simple_animal/hostile/retaliate/rogue/goat/rogue_rider_offsets(pass_index)
	return rogue_low_rider_offsets(pass_index)

/mob/living/simple_animal/hostile/retaliate/rogue/goatmale/rogue_rider_offsets(pass_index)
	return rogue_low_rider_offsets(pass_index)

/mob/living/simple_animal/hostile/retaliate/rogue/swine/hog/rogue_rider_offsets(pass_index)
	return rogue_low_rider_offsets(pass_index)

/mob/living/basic/rockhill/proc/rogue_low_rider_offsets(pass_index)
	var/static/list/rider = list(TEXT_NORTH = list(0, 6), TEXT_SOUTH = list(0, 6), TEXT_EAST = list(-2, 6), TEXT_WEST = list(2, 6))
	var/static/list/passenger = list(TEXT_NORTH = list(0, -2), TEXT_SOUTH = list(0, 14), TEXT_EAST = list(-10, 6), TEXT_WEST = list(10, 6))
	return pass_index > 1 ? passenger : rider

/// The beetle covers its rider facing away from the viewer (Ratwood beetle tamed(): north above the mob layer).
/mob/living/simple_animal/hostile/retaliate/rogue/beetle/rogue_mount_layers()
	var/static/list/layers = list(
		TEXT_NORTH = list(0, 0, MOB_LAYER + 0.5),
		TEXT_SOUTH = list(0, 0, MOB_BELOW_PIGGYBACK_LAYER),
		TEXT_EAST = list(0, 0, MOB_BELOW_PIGGYBACK_LAYER),
		TEXT_WEST = list(0, 0, MOB_BELOW_PIGGYBACK_LAYER),
	)
	return layers

/mob/living/basic/rockhill
	/// Ratwood cow attack_hand(): the look of the beast tipped over on its side; null - it cannot be tipped.
	var/rogue_tip_state

/// Ratwood cow attack_hand() with the disarm intent: a shove (or a right click) with an empty hand tips a cow over, unless it is down
/// or ridden.
/mob/living/basic/rockhill/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. != SECONDARY_ATTACK_CALL_NORMAL || !rogue_tip_state || stat != STABLE || has_buckled_mobs() || !isliving(user) || !rogue_husbandry_enabled())
		return
	rogue_tip_over(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/// Ratwood cow attack_hand(): the beast lies on its side for a few seconds.
/mob/living/basic/rockhill/proc/rogue_tip_over(mob/living/tipper)
	tipper.visible_message(span_warning("[tipper] tips over [src]."), span_notice("I tip over [src]."))
	to_chat(src, span_danger("I am tipped over by [tipper]!"))
	tipper.changeNext_move(CLICK_CD_MELEE)
	Paralyze(ROGUE_TIP_TIME, ignore_canstun = TRUE)
	icon_state = rogue_tip_state
	addtimer(CALLBACK(src, PROC_REF(rogue_get_up)), ROGUE_TIP_TIME, TIMER_UNIQUE | TIMER_OVERRIDE)

/// Ratwood untip_check(): back on its feet, if it lives.
/mob/living/basic/rockhill/proc/rogue_get_up()
	if(stat != DEAD && icon_state == rogue_tip_state)
		icon_state = icon_living

#undef ROGUE_TIP_TIME
