#define cycle_pause 4 //min 1
#define viewrange 7 //min 2

/mob/living/carbon/human/zombie/New()
 	..()
 	// Uh, what? - N3X
 	src.mind = new/datum/mind(src)


/mob/living/carbon/human/zombie						//Define
	name = "zombie"
	desc = "A Zombie."
	a_intent = "harm"

	var/state = 0

	var/list/path = new/list()

	var/frustration = 0
	var/mob/living/carbon/target
	var/list/path_target = new/list()

	var/turf/trg_idle
	var/list/path_idle = new/list()

	var/alive = 1 //1 alive, 0 dead

	var/zsay = new/list()

	New()
		..()
		zsay += "braaaaains"
		zsay += "Mrrrhrrrrrrmmmm"
		zsay += "BRAIIIIIIIIINSSSSS"
		zsay += "uuuuuuuuuuuhhhh"
		zsay += "grrrr-grrrii-gggrii-fffee-rrr"
		zsay += "UHhuHUhuhhhh"
		zsay += "thriii-thirriiill--errrr"
		zsay += "GRRRRRRRRR"
		zsay += "ahhhaaaarraaghh"
		zsay += "eeemmmmmmaaarrrrrrraggh"
		zsay += "AAARRAAAGGGGHHHHHH"
		zsay += "FFFFEEEEERRAAAAG"
		zsay += "bbbb-bbb-ainnnnnns"

		src.contract_disease(new/datum/disease/z_virus)

		src.process()

	emote(var/act)
		act = "<B>[src]</B> moans."
		for (var/mob/O in hearers(src, null))
			O.show_message(act, 2)

	Bumped(AM as mob|obj)
	//	..()
		if(istype(AM, /mob/living/carbon/human/zombie))
			return
		if(ismob(AM) && (ishuman(AM) || ismonkey(AM)) )
			src.target = AM
			set_attack()
		else if(ismob(AM))
			spawn(0)
				var/turf/T = get_turf(src)
				AM:loc = T

	Bump(atom/A)
		if(istype(A, /mob/living/carbon/human/zombie))
			return
		if(ismob(A) && (ishuman(A) || ismonkey(A)))
			src.target = A
			set_attack()
		else if(ismob(A))
			src.loc = A:loc


	proc/set_attack()
		state = 1
		if(path_idle.len) path_idle = new/list()
		trg_idle = null

	proc/set_idle()
		state = 2
		if (path_target.len) path_target = new/list()
		target = null
		frustration = 0

	proc/set_null()
		state = 0
		if (path_target.len) path_target = new/list()
		if (path_idle.len) path_idle = new/list()
		target = null
		trg_idle = null
		frustration = 0

	proc/process()
		//set background = 1
		var/quick_move = 1
		var/slow_move = 0

		if (src.stat == 2)
			return

		if (src.stat > 0 || lying)
			spawn(cycle_pause)
				src.process()
			return

		if(istype(src.shoes, /obj/item/clothing/shoes/orange))
			var/obj/item/clothing/shoes/orange/Os = src.shoes
			if(Os.chained)
				slow_move = 1
		else if(istype(src.wear_suit, /obj/item/clothing/suit/straight_jacket))
			slow_move = 1


		else if (!target)
			if (path_target.len) path_target = new/list()

			var/last_health = INFINITY

			for (var/mob/living/carbon/C in range(viewrange-2,src.loc))
				if (C.stat == 2 || !can_see(src,C,viewrange) || istype(C, /mob/living/carbon/human/zombie) || istype(C, /mob/living/carbon/monkey))
					continue
				if(C:stunned || C:paralysis || C:weakened)
					target = C
					break
				if(C:health < last_health)
					last_health = C:health
					target = C

			if(target)
				set_attack()
			else if(state != 2)
				set_idle()
				idle()

		else if(target)
			var/turf/distance = get_dist(src, target)
			set_attack()

			if(can_see(src,target,viewrange))
				if(distance <= 1 && !istype(src.wear_mask, /obj/item/clothing/mask))
					if(prob(25))
						for(var/mob/O in viewers(world.view,src))
							O.show_message("\red <B>[src] has attempted to bite [src.target]!</B>", 1, "\red You hear struggling.", 2)
					else
						for(var/mob/O in viewers(world.view,src))
							O.show_message("\red <B>[src.target] has been bitten by [src]!</B>", 1, "\red You hear struggling.", 2)
						var/mob/living/carbon/human/T = target
						T.bruteloss += rand(1,7)
						var/datum/organ/external/affecting
						if(T.organs["head"]) affecting = T.organs["head"]
						affecting.take_damage(rand(1,7), 0)
						playsound(get_turf(src), 'sound/items/eatfood.ogg', 50, 1)
						if(prob(25))
							target.contract_disease(new/datum/disease/z_virus)
						src.add_blood(src.target)
						if (prob(33))
							var/turf/location = src.target.loc
							if (istype(location, /turf/simulated))
								location.add_blood(src.target)
						if (src.wear_mask)
							src.wear_mask.add_blood(src.target)
						if (src.head)
							src.head.add_blood(src.target)
						if (src.glasses && prob(33))
							src.glasses.add_blood(src.target)
						if (src.gloves)
							src.gloves.add_blood(src.target)
						if (prob(15))
							if (src.wear_suit)
								src.wear_suit.add_blood(src.target)
							else if (src.w_uniform)
								src.w_uniform.add_blood(src.target)
					sleep(5)
					//target:paralysis = max(target:paralysis, 10)
				else if(distance <= 1 && !src.handcuffed && !istype(src.wear_suit, /obj/item/clothing/suit/straight_jacket))
					if(prob(25) && src.equipped())
						var/obj/item/weapon/A = src.equipped()
						A.attack(src.target, src)
					else if(prob(25))
						for(var/mob/O in viewers(world.view,src))
							O.show_message("\red <B>[src] has attempted to claw [src.target]!</B>", 1, "\red You hear struggling.", 2)
					else
						for(var/mob/O in viewers(world.view,src))
							O.show_message("\red <B>[src.target] has been clawed by [src]!</B>", 1, "\red You hear struggling.", 2)
						var/mob/living/carbon/human/T = target
						T.bruteloss += rand(1,7)
						var/datum/organ/external/affecting
						if(T.organs["head"]) affecting = T.organs["head"]
						affecting.take_damage(rand(1,7), 0)
						if(prob(12.5))
							target.contract_disease(new/datum/disease/z_virus)
						src.add_blood(src.target)
						if (prob(33))
							var/turf/location = src.target.loc
							if (istype(location, /turf/simulated))
								location.add_blood(src.target)
						if (src.wear_mask)
							src.wear_mask.add_blood(src.target)
						if (src.head)
							src.head.add_blood(src.target)
						if (src.glasses && prob(33))
							src.glasses.add_blood(src.target)
						if (src.gloves)
							src.gloves.add_blood(src.target)
						if (prob(15))
							if (src.wear_suit)
								src.wear_suit.add_blood(src.target)
							else if (src.w_uniform)
								src.w_uniform.add_blood(src.target)

				else
					step_towards(src,get_step_towards2(src , target))
					set_null()
					if(!slow_move)
						spawn(cycle_pause) src.process()
					else
						spawn(cycle_pause*2) src.process()
					return

			else
				if( !path_target.len )

					path_attack(target)
					if(!path_target.len)
						set_null()
						if(!slow_move)
							spawn(cycle_pause) src.process()
						else
							spawn(cycle_pause*2) src.process()
						return
				else
					var/turf/next = path_target[1]

					if(next in range(1,src))
						path_attack(target)

					if(!path_target.len)
						src.frustration += 5
					else
						next = path_target[1]
						path_target -= next
						step_towards(src,next)
						quick_move = 1

			if (get_dist(src, src.target) >= distance) src.frustration++
			else src.frustration--
			if(frustration >= 35) set_null()

		if(prob(3) && !src.stat == 2)
			if(prob(50))
				src.say(pick(zsay))
			else
				src.emote("moan")

		if(slow_move)
			spawn(cycle_pause*2)
				src.process()
		else if(quick_move)
			spawn(cycle_pause/2)
				src.process()
		else
			spawn(cycle_pause)
				src.process()


		for(var/obj/machinery/door/D in oview(1))
			D.Bumped(src)




	proc/idle()
		//set background = 1
		var/quick_move = 0

		if(state != 2 || src.stat == 2 || target) return

		step_rand(src)

		if(prob(3))
			if(prob(10))
				src.say(pick(zsay))
			else
				src.emote("moan")

		if(quick_move)
			spawn(cycle_pause/2)
				idle()
		else
			spawn(cycle_pause)
				idle()

	proc/path_idle(var/atom/trg)
		path_idle = AStar(src.loc, get_turf(trg), /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 250, null, null)
		path_idle = reverselist(path_idle)

	proc/path_attack(var/atom/trg)
		target = trg
		path_target = AStar(src.loc, target.loc, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 250, null, null)
		path_target = reverselist(path_target)


	proc/healthcheck()
		return


//Zombies!

/datum/disease/z_virus
	name = "T-Virus"
	max_stages = 5
	spread = "Contact"
	cure = "???"
	spread_type = SPECIAL
	cure_id = "zed"
	affected_species = list("Human", "Human/Zombie")

/datum/disease/z_virus/stage_act()
	..()
	if(istype(affected_mob, /mob/living/carbon/human/zombie) && !src.carrier)
		src.carrier = 1
		return
	switch(stage)
		if(1)
			if (prob(8))
				affected_mob << pick("\red Something about you doesnt feel right.","\red Your head starts to itch.")
		if(2)
			if (prob(8))
				affected_mob << "\red Your limbs feel numb."
				affected_mob.bruteloss += 1
				affected_mob.updatehealth()
			if (prob(9))
				affected_mob << "\red You feel ill..."
			if (prob(9))
				affected_mob << "\red You feel a pain in your stomache..."
		if(3)
			if (prob(8))
				affected_mob << text("\red []", pick("owww...","I want...","Please..."))
				affected_mob.bruteloss += 1
				affected_mob.updatehealth()
			if (prob(10))
				affected_mob << "\red You feel very ill."
				affected_mob.bruteloss += 5
				affected_mob.updatehealth()
			if (prob(4))
				affected_mob << "\red You feel a stabbing pain in your head."
				affected_mob.paralysis += 2
			if (prob(4))
				affected_mob << "\red Whats going to happen to me?"
		if(4)
			if (prob(10))
				affected_mob << pick("\red You feel violently sick.")
				affected_mob.bruteloss += 8
				affected_mob.updatehealth()
			if (prob(20))
				affected_mob.say(pick("Mmmmm.", "Hey... You look...", "Hsssshhhhh!"))
			if (prob(8))
				affected_mob << "\red You cant... feel..."
		if(5)
			affected_mob.toxloss += 10
			affected_mob.updatehealth()
			affected_mob << "You feel the life slowly slip away from you as you join the army of the undead.."
			affected_mob:Zombify()


/mob/living/carbon/human/proc/Zombify()
	if (src.monkeyizing)
		return
	update_icons() // update_clothing()
	var/mob/living/carbon/human/zombie/O = new/mob/living/carbon/human/zombie( src.loc )
	//Yay, Zombie!
	O.name = name
	O.r_hair = name
	O.g_hair = g_hair
	O.b_hair = b_hair
	O.h_style = h_style
	O.r_facial = r_facial
	O.g_facial = g_facial
	O.b_facial = b_facial
	O.f_style = f_style
	O.r_eyes = r_eyes
	O.g_eyes = g_eyes
	O.b_eyes = b_eyes
	O.s_tone = s_tone
	O.age = age

	O.real_name = real_name

	O.wear_mask = wear_mask
	O.l_hand = l_hand
	O.r_hand = r_hand
	O.wear_suit = wear_suit
	O.w_uniform = w_uniform
//	O.w_radio = null
	O.shoes = shoes
	O.belt = belt
	O.gloves = gloves
	O.glasses = glasses
	O.head = head
	O.ears = ears
	O.wear_id = wear_id
	O.r_store = r_store
	O.l_store = l_store
	O.back = back

	O.stand_icon = stand_icon
	O.lying_icon = lying_icon

	//O.last_b_state = last_b_state

	//O.face_standing = face_standing
	//O.face_lying = face_lying

	//O.hair_icon_state = hair_icon_state
	//O.face_icon_state = face_icon_state

	//O.body_standing = body_standing
	//O.body_lying = body_lying
	for(var/obj/Q in src)
		Q.loc = O
	O.update_icons()//update_clothing()
	src.ghostize()
	O.loc = src.loc
	del(src)
	return

/obj/item/weapon/reagent_containers/glass/bottle/t_virus
	name = "Z-Virus culture bottle"
	desc = "A small bottle. Contains Z-Virus virion in synthblood medium."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 5

	New()
		var/datum/reagents/R = new/datum/reagents(20)
		reagents = R
		R.my_atom = src
		var/datum/disease/F = new /datum/disease/z_virus(0)
		var/list/data = list("virus"= F)
		R.add_reagent("blood", 20, data)

///////////////////////////CURE//////////////////////////////////////////

datum/reagent/zed
	name = "Zombie Elixer"
	id = "zed"
	description = "For treating the Z-Virus."
	//reagent_state = LIQUID

	on_mob_life(var/mob/M)//no more mr. panacea
		holder.remove_reagent(src.id, 0.2)
		return



/obj/item/weapon/zedpen
	desc = "Small non-refillable auto-injector for curing the Z-Virus in early stages."
	name = "Z.E.D. Pen."
	icon = 'icons/obj/items.dmi'
	icon_state = "zed_1"
	flags = FPRINT | TABLEPASS/* | ONBELT*/
	throwforce = 0
	w_class = 1.0
	throw_speed = 7
	throw_range = 15
	m_amt = 60

/obj/item/weapon/zedpen/attack_paw(mob/user as mob)
	return src.attack_hand(user)
	return

/obj/item/weapon/zedpen/New()
	var/datum/reagents/R = new/datum/reagents(10)
	reagents = R
	R.my_atom = src
	R.add_reagent("zed", 10)
	..()
	return

/obj/item/weapon/zedpen/attack(mob/M as mob, mob/user as mob)
	if (!( istype(M, /mob) ))
		return
	if (reagents.total_volume)
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\blue [] has been stabbed with [] by [].", M, src, user), 1)
//		user << "\red You stab [M] with the pen."
//		M << "\red You feel a tiny prick!"
		if(M.reagents) reagents.trans_to(M, 10)
		icon_state = "zed_0"
	return




/obj/item/weapon/storage/firstaid/zed
	name = "Zed-Kit"
	icon_state = "zedkit"
	item_state = "firstaid-zed"

/obj/item/weapon/storage/firstaid/zed/New()

	..()
	new /obj/item/weapon/zedpen( src )
	new /obj/item/weapon/zedpen( src )
	new /obj/item/weapon/zedpen( src )
	new /obj/item/weapon/zedpen( src )
	new /obj/item/weapon/zedpen( src )
	new /obj/item/weapon/zedpen( src )
	new /obj/item/device/healthanalyzer( src )
	return


////////////////////////////////////////////event code/////////////////////////////////////////

/obj/landmark/zspawn
	name = "zombie spawn"

/*
/client/update_admins(var/rank)
	..()
	if(rank == "Game Master"/* || rank == "Coder" || rank == "Primary Administrator" || rank == "Administrator"*/)
		src.verbs += /client/proc/zombie_event
*/

/client/proc/zombie_event()
	set category = "Special Verbs"
	set name = "Spawn Zombies"

//	if(!istype(ticker.mode, /datum/game_mode/biohazard))
//		if(src)
//			src << "\red Wrong game mode!"
//			return

	if(usr) message_admins("[key_name_admin(usr)] has spawned a zombie", 1)
	biohazard_alert(7)
	var/list/t = list()
	for(var/obj/landmark/zspawn/O in world)
		t += O
	if(!t.len)
		usr<<"No spawn points exist."
		return
	var/obj/landmark/s = pick(t)
	var/mob/living/carbon/human/zombie/Z = new/mob/living/carbon/human/zombie(s.loc)

	Z.gender = pick(MALE, FEMALE)

	/* DNA2 broke this
	var/flooks = new/list()
	var/mlooks = new/list()
	flooks += "0990CC0FF000000000DC0000033000902136F93"
	flooks += "0CC000033000000000DC0000033000C4308DEB4"
	flooks += "066000033000000000B90000033000E1E03FD3F"
	flooks += "066000033000000000690000033000A0F06C6D5"
	flooks += "0CC000000000000000EB0000000066D1F11EDA3"
	//flooks += "0FF0000FF000000000F50000000066B360B819"

	mlooks += "066000033000000000CD000000000071E0F7382"
	mlooks += "066000033000000000B9006603300037909B45A"
	mlooks += "000000000000000000690000000066487060580"
	mlooks += "000000000000000000CD0000000000638074390"
	mlooks += "066000033066000033CD00000000000D8D20B9B"

	if(Z.gender == MALE)
		Z.dna.unique_enzymes = pick(mlooks)
	else
		Z.dna.unique_enzymes = pick(flooks)
	*/

	Z.UpdateAppearance()

	if(Z.gender == MALE)
		Z.real_name = text("[] []", pick(first_names_male), pick(last_names))
	else
		Z.real_name = text("[] []", pick(first_names_female), pick(last_names))

	//var/a = pick("Janitor", "Medical Doctor", "Assistant", "Atmospheric Technician", "Security Officer", "Botanist", "Cargo Technician")
	//Z.Equip_Rank(a, 0)
	//Commented out by pygmy. Reason: Triggers my anti-spawn-at-menu code. Compromising this risks server.
	Z.loc = s.loc