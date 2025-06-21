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

/datum/embedding/energy_bolt/process(seconds_per_tick)
	. = ..()

	if(!isliving(owner))
		return

	var/mob/living/living_owner = owner

	if(!(living_owner.mob_biotypes & MOB_ORGANIC))
		return

	living_owner.set_silence_if_lower(2 SECONDS)
	living_owner.adjust_drowsiness_up_to(1 SECONDS, 60 SECONDS)
	if(HAS_TRAIT_FROM(living_owner, TRAIT_INCAPACITATED, STAMINA) && !HAS_TRAIT(living_owner, TRAIT_KNOCKEDOUT))
		living_owner.AdjustSleeping(10 SECONDS)

	if(HAS_TRAIT(living_owner, TRAIT_KNOCKEDOUT))
		fall_chance = clamp(fall_chance + 30, 0, 100)

/obj/projectile/energy/bolt/halloween
	name = "candy corn"
	icon_state = "candy_corn"
	icon = 'icons/obj/food/food.dmi'

/obj/projectile/energy/bolt/large
	damage = 20
	stamina = 80
	knockdown = 2 SECONDS
