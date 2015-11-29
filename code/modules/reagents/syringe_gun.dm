


/obj/item/weapon/gun/syringe
	name = "syringe gun"
	desc = "A spring loaded rifle designed to fit syringes, designed to incapacitate unruly patients from a distance."
	icon = 'icons/obj/gun.dmi'
	icon_state = "syringegun"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 4.0
	var/list/syringes = new/list()
	var/max_syringes = 1
	starting_materials = list(MAT_IRON = 2000)
	w_type = RECYK_METAL

/obj/item/weapon/gun/syringe/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>[syringes.len] / [max_syringes] syringes.</span>")

/obj/item/weapon/gun/syringe/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/reagent_containers/syringe))
		var/obj/item/weapon/reagent_containers/syringe/S = I
		if(S.mode != 2)//SYRINGE_BROKEN in syringes.dm
			if(syringes.len < max_syringes)
				user.drop_item(I, src)
				syringes += I
				to_chat(user, "<span class='notice'>You put the syringe in [src].</span>")
				to_chat(user, "<span class='notice'>[syringes.len] / [max_syringes] syringes.</span>")
			else
				to_chat(user, "<span class='warning'>[src] cannot hold more syringes.</span>")
		else
			to_chat(user, "<span class='warning'>This syringe is broken!</span>")

		return 1 // Avoid calling the syringe's afterattack()

/obj/item/weapon/gun/syringe/afterattack(obj/target, mob/user , flag)
	if(/*!isturf(target.loc) || */target == user) return
	..()

/obj/item/weapon/gun/syringe/can_fire()
	return syringes.len

/obj/item/weapon/gun/syringe/can_hit(var/mob/living/target as mob, var/mob/living/user as mob)
	return 1		//SHOOT AND LET THE GOD GUIDE IT (probably will hit a wall anyway)

/obj/item/weapon/gun/syringe/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0)
	if(syringes.len)
		if(M_CLUMSY in user.mutations)
			if(prob(50))
				to_chat(user, "<span class='warning'>You accidentally shoot yourself!</span>")
				var/obj/item/weapon/reagent_containers/syringe/S = syringes[1]
				if((!S) || (!S.reagents))
					to_chat(user, "<span class='notice'>Thankfully, nothing happens.</span>")
					return
				syringes -= S
				S.reagents.trans_to(user, S.reagents.total_volume)
				qdel(S)
				return

		spawn(0) fire_syringe(target,user)
	else
		to_chat(user, "<span class='warning'>[src] is empty.</span>")

/obj/item/weapon/gun/syringe/proc/fire_syringe(atom/target, mob/user)
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
		log_attack("[user.name] ([user.ckey]) fired \the [src] at [target] [ismob(target) ? "([target:ckey])" : ""] ([target.x],[target.y],[target.z])" )
		for(var/i=0, i<6, i++)
			if(!D) break
			if(D.loc == trg) break
			step_towards(D,trg)

			if(D)
				for(var/mob/living/carbon/M in D.loc)
					if(!istype(M,/mob/living/carbon)) continue
					if(M == user) continue
					var/blocked = 0
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						if(H.species && (H.species.chem_flags & NO_INJECT))
							H.visible_message("<span class='warning'>\The [D] bounces harmlessly off of [H].</span>", "<span class='notice'>\The [D] bounces off you harmlessly and breaks as it hits the ground.</span>")
							qdel(D)
							return

						blocked = istype(H.wear_suit, /obj/item/clothing/suit/space) // Block the syringe if the guy's wearing a spess suit.
					//Syringe gun attack logging by Yvarov
					var/R
					if(D.reagents)
						for(var/datum/reagent/A in D.reagents.reagent_list)
							R += A.id + " ("
							R += num2text(A.volume) + "),"
					if (istype(M, /mob))
						M.attack_log += "\[[time_stamp()]\] <b>[user]/[user.ckey]</b> shot <b>[M]/[M.ckey]</b> with a <b>syringegun</b> ([R]) [blocked ? "\[BLOCKED\]" : ""]"
						user.attack_log += "\[[time_stamp()]\] <b>[user]/[user.ckey]</b> shot <b>[M]/[M.ckey]</b> with a <b>syringegun</b> ([R]) [blocked ? "\[BLOCKED\]" : ""]"
						msg_admin_attack("[user] ([user.ckey]) shot [M] ([M.ckey]) with a syringegun ([R]) [blocked ? "\[BLOCKED\]" : ""] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
						if(!iscarbon(user))
							M.LAssailant = null
						else
							M.LAssailant = user

					else
						M.attack_log += "\[[time_stamp()]\] <b>UNKNOWN SUBJECT (No longer exists)</b> shot <b>[M]/[M.ckey]</b> with a <b>syringegun</b> ([R]) [blocked ? "\[BLOCKED\]" : ""]"
						msg_admin_attack("UNKNOWN shot [M] ([M.ckey]) with a <b>syringegun</b> ([R]) [blocked ? "\[BLOCKED\]" : ""] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

					if(!blocked)
						if(D.reagents)
							D.reagents.trans_to(M, 15)
						M.visible_message("<span class='danger'>[M] is hit by the syringe!</span>")

					else
						var/mob/living/carbon/human/H = M
						M.visible_message("<span class='danger'>[M] is hit by the syringe, but \his [H.wear_suit] blocked it!</span>") // Fuck you validhunters.

					qdel(D)
					break
			if(D)
				for(var/atom/A in D.loc)
					if(A == user) continue
					if(A.density) qdel(D)

			sleep(1)

		if (D) spawn(10) qdel(D)

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
