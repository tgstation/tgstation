


/obj/item/weapon/gun/syringe
	name = "syringe gun"
	desc = "A spring loaded rifle designed to fit syringes, designed to incapacitate unruly patients from a distance."
	icon = 'icons/obj/gun.dmi'
	icon_state = "syringegun"
	item_state = "syringegun"
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 4.0
	var/list/syringes = new/list()
	var/max_syringes = 1
	m_amt = 2000

	examine()
		set src in view()
		..()
		if (!(usr in view(2)) && usr!=src.loc) return
		usr << "\blue [syringes.len] / [max_syringes] syringes."

	attackby(obj/item/I as obj, mob/user as mob)

		if(istype(I, /obj/item/weapon/reagent_containers/syringe))
			if(syringes.len < max_syringes)
				user.drop_item()
				I.loc = src
				syringes += I
				user << "\blue You put the syringe in [src]."
				user << "\blue [syringes.len] / [max_syringes] syringes."
			else
				usr << "\red [src] cannot hold more syringes."

	afterattack(obj/target, mob/user , flag)
		if(!isturf(target.loc) || target == user) return

		if(syringes.len)
			spawn(0) fire_syringe(target,user)
		else
			usr << "\red [src] is empty."

	proc
		fire_syringe(atom/target, mob/user)
			if (locate (/obj/structure/table, src.loc))
				return
			else
				var/turf/trg = get_turf(target)
				var/obj/effect/syringe_gun_dummy/D = new/obj/effect/syringe_gun_dummy(get_turf(src))
				var/obj/item/weapon/reagent_containers/syringe/S = syringes[1]
				if((!S) || (!S.reagents))	//ho boy! wot runtimes!
					return
				S.reagents.trans_to(D, S.reagents.total_volume)
				syringes -= S
				del(S)
				D.icon_state = "syringeproj"
				D.name = "syringe"
				playsound(user.loc, 'sound/items/syringeproj.ogg', 50, 1)

				for(var/i=0, i<6, i++)
					if(!D) break
					if(D.loc == trg) break
					step_towards(D,trg)

					if(D)
						for(var/mob/living/carbon/M in D.loc)
							if(!istype(M,/mob/living/carbon)) continue
							if(M == user) continue
							//Syringe gun attack logging by Yvarov
							var/R
							if(D.reagents)
								for(var/datum/reagent/A in D.reagents.reagent_list)
									R += A.id + " ("
									R += num2text(A.volume) + "),"
							if (istype(M, /mob))
								M.attack_log += "\[[time_stamp()]\] <b>[user]/[user.ckey]</b> shot <b>[M]/[M.ckey]</b> with a <b>syringegun</b> ([R])"
								user.attack_log += "\[[time_stamp()]\] <b>[user]/[user.ckey]</b> shot <b>[M]/[M.ckey]</b> with a <b>syringegun</b> ([R])"
								log_attack("<font color='red'>[user] ([user.ckey]) shot [M] ([M.ckey]) with a syringegun ([R])</font>")

								log_admin("ATTACK: [user] ([user.ckey]) shot [M] ([M.ckey]) with a syringegun ([R])")
								msg_admin_attack("ATTACK: [user] ([user.ckey]) shot [M] ([M.ckey]) with a syringegun ([R])") //BS12 EDIT ALG

							else
								M.attack_log += "\[[time_stamp()]\] <b>UNKNOWN SUBJECT (No longer exists)</b> shot <b>[M]/[M.ckey]</b> with a <b>syringegun</b> ([R])"
								log_attack("<font color='red'>UNKNOWN shot [M] ([M.ckey]) with a <b>syringegun</b> ([R])</font>")

								log_admin("ATTACK: UNKNOWN shot [M] ([M.ckey]) with a <b>syringegun</b> ([R])")
								msg_admin_attack("ATTACK: UNKNOWN shot [M] ([M.ckey]) with a <b>syringegun</b> ([R])") //BS12 EDIT ALG

							if(D.reagents)
								D.reagents.trans_to(M, 15)
							M.take_organ_damage(5)
							for(var/mob/O in viewers(world.view, D))
								O.show_message("\red [M.name] is hit by the syringe!", 1)

							del(D)
					if(D)
						for(var/atom/A in D.loc)
							if(A == user) continue
							if(A.density) del(D)

					sleep(1)

				if (D) spawn(10) del(D)

				return

/obj/item/weapon/gun/syringe/rapidsyringe
	name = "rapid syringe gun"
	desc = "A modification of the syringe gun design, using a rotating cylinder to store up to four syringes."
	icon_state = "rapidsyringegun"
	max_syringes = 4


/obj/effect/syringe_gun_dummy
	name = ""
	desc = ""
	icon = 'icons/obj/chemical.dmi'
	icon_state = "null"
	anchored = 1
	density = 0

	New()
		var/datum/reagents/R = new/datum/reagents(15)
		reagents = R
		R.my_atom = src