/datum/effect_system/reagents_explosion/start(var/log=TRUE)
	if(explosion_message)
		location.visible_message("<span class='danger'>The solution violently explodes!</span>", \
								"<span class='italics'>You hear an explosion!</span>")
	if (amount < 1)
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(2, 1, location)
		s.start()

		for(var/mob/living/L in viewers(1, location))
			if(prob(50 * amount))
				to_chat(L, "<span class='danger'>The explosion knocks you down.</span>")
				L.Knockdown(rand(20,100))
		return
	else
		dyn_explosion(location, amount, flashing_factor, log)