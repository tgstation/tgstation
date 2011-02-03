
/obj/machinery/containment_field
	name = "Containment Field"
	desc = "An energy field."
	icon = 'singularity.dmi'
	icon_state = "Contain_F"
	anchored = 1
	density = 0
	unacidable = 1
	power_usage = 0

	New()
		spawn(1)
			src.sd_SetLuminosity(5)


	attack_hand(mob/user as mob)
		if(get_dist(src, user) > 1)
			return 0
		else
			shock(user)
			return 1


	blob_act()
		return


	ex_act(severity)
		return


	HasProximity(atom/movable/AM as mob|obj)
		if(istype(AM,/mob/living/silicon) && prob(40))
			shock(AM)
			return
		if(istype(AM,/mob/living/carbon) && prob(50))
			shock(AM)
			return


	proc
		shock(mob/user as mob)
			if(iscarbon(user))
				var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
				s.set_up(5, 1, user.loc)
				s.start()
				var/shock_damage = min(rand(30,40),rand(30,40))
				user.burn_skin(shock_damage)
				user.updatehealth()
				user.visible_message("\red [user.name] was shocked by the [src.name]!", \
					"\red <B>You feel a powerful shock course through your body sending you flying!</B>", \
					"\red You hear a heavy electrical crack")
				var/stun = min(shock_damage, 15)
				if(user.stunned < shock_damage)	user.stunned = stun
				if(user.weakened < 10)	user.weakened = 10
				user.updatehealth()
				var/atom/target = get_edge_target_turf(user, get_dir(src, get_step_away(user, src)))
				user.throw_at(target, 200, 4)
				return
			else if(issilicon(user))
				var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
				s.set_up(5, 1, user.loc)
				s.start()
				var/shock_damage = rand(15,30)
				user.fireloss += shock_damage
				user.updatehealth()
				user.visible_message("\red [user.name] was shocked by the [src.name]!", \
					"\red <B>Energy pulse detected, system damaged!</B>", \
					"\red You hear an electrical crack")
				if(prob(20))
					if(user.stunned < 2)
						user.stunned = 2
				return
			return
