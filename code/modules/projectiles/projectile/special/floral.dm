/obj/projectile/energy/floramut
	name = "alpha somatoray"
	icon_state = "energy"
	damage = 0
	damage_type = TOX
	armor_flag = ENERGY

/obj/projectile/energy/floramut/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.mob_biotypes & MOB_PLANT)
			if(prob(15))
				L.adjustToxLoss(rand(3, 6))
				L.Paralyze(100)
				L.visible_message(span_warning("[L] writhes in pain as [L.p_their()] vacuoles boil."), span_userdanger("You writhe in pain as your vacuoles boil!"), span_hear("You hear the crunching of leaves."))
				if(iscarbon(L) && L.has_dna())
					var/mob/living/carbon/C = L
					if(prob(80))
						C.easy_random_mutate(NEGATIVE + MINOR_NEGATIVE)
					else
						C.easy_random_mutate(POSITIVE)
					C.random_mutate_unique_identity()
					C.random_mutate_unique_features()
					C.domutcheck()
			else
				L.adjustFireLoss(rand(5, 15))
				L.show_message(span_userdanger("The radiation beam singes you!"))

/obj/projectile/energy/florayield
	name = "beta somatoray"
	icon_state = "energy2"
	damage = 0
	damage_type = TOX
	armor_flag = ENERGY

/obj/projectile/energy/florayield/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.mob_biotypes & MOB_PLANT)
			L.set_nutrition(min(L.nutrition + 30, NUTRITION_LEVEL_FULL))

/obj/projectile/energy/florarevolution
	name = "gamma somatoray"
	icon_state = "energy3"
	damage = 0
	damage_type = TOX
	armor_flag = ENERGY

/obj/projectile/energy/florarevolution/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.mob_biotypes & MOB_PLANT)
			L.show_message(span_notice("The radiation beam leaves you feeling disoriented!"))
			L.set_dizzy_if_lower(30 SECONDS)
			L.emote("flip")
			L.emote("spin")
