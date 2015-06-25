///////////
// EARTH //
///////////

/////////
// AIR //
/////////

/obj/effect/proc_holder/spell/targeted/lightning/elemental
	name = "Storm Bolt"
	panel = "Abilities"
	invocation_type = null
	charge_max = 200
	clothes_req = 0

/obj/effect/proc_holder/spell/aoe_turf/repulse/elemental
	name = "Gale"
	panel = "Abilities"
	invocation_type = null
	charge_max = 250
	clothes_req = 0

/obj/effect/proc_holder/spell/targeted/stormwinds
	name = "Cyclonic Winds"
	desc = "Envelop yourself in cyclonic winds and charge forward, knocking down anyone in your path."
	panel = "Abilities"
	charge_max = 500
	clothes_req = 0
	range = -1
	include_user = 1

/obj/effect/proc_holder/spell/targeted/stormwinds/cast(list/targets)
	for(var/mob/living/simple_animal/elemental/air/user in targets)
		if(!istype(user))
			return
		user.visible_message("<span class='warning'>The winds around [user] begin to swell and rush...</span>")
		sleep(20)
		user.visible_message("<span class='boldannounce'>[user] rockets forward!</span>")
		for(var/i = 0, i < 20, i++)
			sleep(0.5)
			var/turf/stepTurf = get_step(user, user.dir)
			for(var/mob/living/carbon/M in stepTurf.contents)
				M.Weaken(5)
				M.apply_damage(10, BRUTE)
				M.visible_message("<span class='warning'>[user] bowls [M] over!</span>", \
							      "<span class='warning'><b>[user] bowls you over!</b></span>")
			step_to(user,stepTurf,1)
