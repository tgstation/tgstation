/obj/projectile/energy/bolt //ebow bolts
	name = "bolt"
	icon_state = "cbbolt"
	damage = 15
	stamina = 60
	damage_type = TOX
	eyeblur = 20 SECONDS
	knockdown = 1 SECONDS
	slur = 10 SECONDS
	speed = 2
	shrapnel_type = /obj/item/shrapnel/energy_bolt
	embed_type = /datum/embedding/energy_bolt

/datum/embedding/energy_bolt
	embed_chance = 100
	fall_chance = 1
	jostle_chance = 5
	jostle_pain_mult = 0.2
	pain_stam_pct = 0.2
	ignore_throwspeed_threshold = TRUE
	rip_time = 1.5 SECONDS

/datum/embedding/energy_bolt/process_effect(seconds_per_tick)
	if(!isliving(owner))
		return

	if(!(owner.mob_biotypes & MOB_ORGANIC))
		return

	owner.set_silence_if_lower(2 SECONDS)
	owner.adjust_drowsiness_up_to(1 SECONDS, 60 SECONDS)
	if(HAS_TRAIT_FROM(owner, TRAIT_INCAPACITATED, STAMINA) && !HAS_TRAIT(owner, TRAIT_KNOCKEDOUT))
		owner.AdjustSleeping(10 SECONDS)

	if(HAS_TRAIT(owner, TRAIT_KNOCKEDOUT))
		fall_chance = clamp(fall_chance + 30, 0, 100)

/obj/projectile/energy/bolt/halloween
	name = "candy corn"
	icon_state = "candy_corn"
	icon = 'icons/obj/food/food.dmi'

/obj/projectile/energy/bolt/large
	damage = 20
	stamina = 80
	knockdown = 2 SECONDS
