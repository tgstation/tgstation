/obj/projectile/energy/bolt //ebow bolts
	name = "bolt"
	icon_state = "cbbolt"
	damage = 60
	damage_type = STAMINA
	eyeblur = 20 SECONDS
	knockdown = 1 SECONDS
	slur = 10 SECONDS
	drowsy = 10 SECONDS
	speed = 2

/obj/projectile/energy/bolt/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/the_snoozer = target
		the_snoozer.adjust_silence_up_to(1 SECONDS, 2 SECONDS)
		if(HAS_TRAIT_FROM(the_snoozer, TRAIT_INCAPACITATED, STAMINA) && !HAS_TRAIT(the_snoozer, TRAIT_KNOCKEDOUT))
			the_snoozer.AdjustSleeping(drowsy)

/obj/projectile/energy/bolt/halloween
	name = "candy corn"
	icon_state = "candy_corn"
	icon = 'icons/obj/food/food.dmi'

/obj/projectile/energy/bolt/large
	damage = 80
	knockdown = 2 SECONDS
	drowsy = 30 SECONDS
