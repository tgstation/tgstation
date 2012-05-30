//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:05

/obj/machinery/containment_field
	name = "Containment Field"
	desc = "An energy field."
	icon = 'singularity.dmi'
	icon_state = "Contain_F"
	anchored = 1
	density = 0
	unacidable = 1
	use_power = 0
	var/obj/machinery/field_generator/FG1 = null
	var/obj/machinery/field_generator/FG2 = null

	New()
		spawn(1)
			src.sd_SetLuminosity(5)


	Del()
		if(FG1 && !FG1.clean_up)
			FG1.cleanup()
		if(FG2 && !FG2.clean_up)
			FG2.cleanup()
		..()

	attack_hand(mob/user as mob)
		if(get_dist(src, user) > 1)
			return 0
		else
			shock(user)
			return 1


	blob_act()
		return 0


	ex_act(severity)
		return 0


	HasProximity(atom/movable/AM as mob|obj)
		if(istype(AM,/mob/living/silicon) && prob(40))
			shock(AM)
			return 1
		if(istype(AM,/mob/living/carbon) && prob(50))
			shock(AM)
			return 1
		return 0


	proc
		shock(mob/living/user as mob)
			if(!FG1 || !FG2)
				del(src)
				return 0
			if(iscarbon(user))
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, user.loc)
				s.start()
				var/shock_damage = min(rand(30,40),rand(30,40))
				user.burn_skin(shock_damage)
				user.updatehealth()
				user.visible_message("\red [user.name] was shocked by the [src.name]!", \
					"\red <B>You feel a powerful shock course through your body, sending you flying!</B>", \
					"\red You hear a heavy electrical crack")

				var/stun = min(shock_damage, 15)
				user.Stun(stun)
				user.Weaken(10)

				user.updatehealth()
				var/atom/target = get_edge_target_turf(user, get_dir(src, get_step_away(user, src)))
				user.throw_at(target, 200, 4)
				return
			else if(issilicon(user))
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, user.loc)
				s.start()
				var/shock_damage = rand(15,30)
				user.take_overall_damage(0,shock_damage)
				user.visible_message("\red [user.name] was shocked by the [src.name]!", \
					"\red <B>Energy pulse detected, system damaged!</B>", \
					"\red You hear an electrical crack")
				if(prob(20))
					user.Stun(2)
				return
			return

		set_master(var/master1,var/master2)
			if(!master1 || !master2)
				return 0
			FG1 = master1
			FG2 = master2
			return 1
