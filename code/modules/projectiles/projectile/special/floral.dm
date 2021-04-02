/obj/projectile/energy/floramut
	name = "alpha somatoray"
	icon_state = "energy"
	damage = 0
	damage_type = TOX
	nodamage = TRUE
	flag = ENERGY

/obj/projectile/energy/floramut/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.mob_biotypes & MOB_PLANT)
			if(prob(15))
				L.rad_act(rand(30, 80))
				L.Paralyze(100)
				L.visible_message("<span class='warning'>[L] writhes in pain as [L.p_their()] vacuoles boil.</span>", "<span class='userdanger'>You writhe in pain as your vacuoles boil!</span>", "<span class='hear'>You hear the crunching of leaves.</span>")
				if(iscarbon(L) && L.has_dna())
					var/mob/living/carbon/C = L
					if(prob(80))
						C.easy_randmut(NEGATIVE + MINOR_NEGATIVE)
					else
						C.easy_randmut(POSITIVE)
					C.randmuti()
					C.domutcheck()
			else
				L.adjustFireLoss(rand(5, 15))
				L.show_message("<span class='userdanger'>The radiation beam singes you!</span>")

/obj/projectile/energy/florayield
	name = "beta somatoray"
	icon_state = "energy2"
	damage = 0
	damage_type = TOX
	nodamage = TRUE
	flag = ENERGY

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
	nodamage = TRUE
	flag = ENERGY

/obj/projectile/energy/florarevolution/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.mob_biotypes & MOB_PLANT)
			L.show_message("<span class='notice'>The radiation beam leaves you feeling disoriented!</span>")
			L.Dizzy(15)
			L.emote("flip")
			L.emote("spin")
