/mob/living/carbon/human
	name = "human"
	real_name = "human"
	voice_name = "human"
	icon = 'mob.dmi'
	icon_state = "m-none"


	var/r_hair = 0.0
	var/g_hair = 0.0
	var/b_hair = 0.0
	var/h_style = "Short Hair"
	var/datum/sprite_accessory/hair/hair_style
	var/r_facial = 0.0
	var/g_facial = 0.0
	var/b_facial = 0.0
	var/f_style = "Shaved"
	var/datum/sprite_accessory/facial_hair/facial_hair_style
	var/r_eyes = 0.0
	var/g_eyes = 0.0
	var/b_eyes = 0.0
	var/s_tone = 0.0
	var/species = "Human"
	age = 30.0
	var/used_skillpoints = 0
	var/skill_specialization = null
	var/list/skills = null
//	var/b_type

	var/obj/item/wear_suit = null
	var/obj/item/w_uniform = null
	var/obj/item/shoes = null
	var/obj/item/belt = null
	var/obj/item/gloves = null
	var/obj/item/glasses = null
	var/obj/item/head = null
	var/obj/item/l_ear = null
	var/obj/item/r_ear = null
	var/obj/item/weapon/card/id/wear_id = null
	var/obj/item/r_store = null
	var/obj/item/l_store = null
	var/obj/item/s_store = null

	var/icon/stand_icon = null
	var/icon/lying_icon = null

	var/last_b_state = 1.0

	var/image/face_standing = null
	var/image/face_lying = null

	var/hair_icon_state = "hair_a"
	var/face_icon_state = "bald"

	var/list/body_standing = list()
	var/list/body_lying = list()

	var/mutantrace = null

	var/bloodloss = 0
	var/datum/reagents/vessel
	var/pale = 0
	var/examine_text = ""

/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	nodamage = 1
	universal_speak = 1



/mob/living/carbon/human/New()

	..()



	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src

	if(!dna)
		dna = new /datum/dna(null)

	new /datum/organ/external/chest(src)
	new /datum/organ/external/groin(src)
	new /datum/organ/external/head(src)
	new /datum/organ/external/l_arm(src)
	new /datum/organ/external/r_arm(src)
	new /datum/organ/external/r_leg(src)
	new /datum/organ/external/l_leg(src)
	new /datum/organ/external/l_hand(src)
	new /datum/organ/external/l_foot(src)
	new /datum/organ/external/r_hand(src)
	new /datum/organ/external/r_foot(src)
	var/datum/organ/external/part = organs["chest"]
	part.children = list(organs["r_leg"],organs["l_leg"],organs["r_arm"],organs["l_arm"],organs["groin"],organs["head"])
	part = organs["head"]
	part.parent = organs["chest"]
	part = organs["groin"]
	part.parent = organs["chest"]
	part = organs["r_leg"]
	part.children = list(organs["r_foot"])
	part.parent = organs["chest"]
	part = organs["l_leg"]
	part.children = list(organs["l_foot"])
	part.parent = organs["chest"]
	part = organs["r_arm"]
	part.children = list(organs["r_hand"])
	part.parent = organs["chest"]
	part = organs["l_arm"]
	part.children = list(organs["l_hand"])
	part.parent = organs["chest"]
	part = organs["r_foot"]
	part.parent = organs["r_leg"]
	part = organs["l_foot"]
	part.parent = organs["l_leg"]
	part = organs["r_hand"]
	part.parent = organs["r_arm"]
	part = organs["l_hand"]
	part.parent = organs["l_arm"]

	var/g = "m"
	if (gender == MALE)
		g = "m"
	else if (gender == FEMALE)
		g = "f"
	else
		gender = MALE
		g = "m"

	spawn(1)
		stand_icon = new /icon('human.dmi', "body_[g]_s")
		lying_icon = new /icon('human.dmi', "body_[g]_l")
		icon = stand_icon
		rebuild_appearance()

		src << "\blue Your icons have been generated!"


	spawn(10) // Failsafe for.. weirdness.
		rebuild_appearance()

	vessel = new/datum/reagents(600)
	vessel.my_atom = src
	vessel.add_reagent("blood",560)
	spawn(1)
		fixblood()

	..()

	spawn(5) // Failsafe for.. weirdness.
		update_clothing()
		update_body()

	/*var/known_languages = list()
	known_languages.Add("english")*/

//	organStructure = new /obj/effect/organstructure/human(src)

/mob/living/carbon/human/proc/fixblood()
	for(var/datum/reagent/blood/B in vessel.reagent_list)
		if(B.id == "blood")
			B.data = list("donor"=src,"viruses"=null,"blood_DNA"=dna.unique_enzymes,"blood_type"=dna.b_type,"resistances"=null,"trace_chem"=null,"virus2"=(virus2 ? virus2.getcopy() : null),"antibodies"=0)

/mob/living/carbon/human/drip(var/amt as num)
	if(!amt)
		return

	var/amm = 0.1 * amt
	var/turf/T = get_turf(src)
	var/list/obj/effect/decal/cleanable/blood/drip/nums = list()
	var/list/iconL = list("1","2","3","4","5")

	vessel.remove_reagent("blood",amm)

	for(var/obj/effect/decal/cleanable/blood/drip/G in T)
		nums += G
		iconL.Remove(G.icon_state)
		if(nums.len >= 3)
			var/obj/effect/decal/cleanable/blood/drip/D = pick(nums)
			D.blood_DNA[dna.unique_enzymes] = dna.b_type
			if(virus2)
				D.virus2 = virus2.getcopy()
			return

	var/obj/effect/decal/cleanable/blood/drip/this = new(T)
	this.icon_state = pick(iconL)
	this.blood_DNA = list()
	this.blood_DNA[dna.unique_enzymes] = dna.b_type
	this.blood_owner = src

	if(virus2)
		this.virus2 = virus2.getcopy()

/mob/living/carbon/human/Bump(atom/movable/AM as mob|obj, yes)
	if ((!( yes ) || now_pushing))
		return
	now_pushing = 1
	if (ismob(AM))
		var/mob/tmob = AM

//BubbleWrap - Should stop you pushing a restrained person out of the way

		if(istype(tmob, /mob/living/carbon/human))

			for(var/mob/M in range(tmob, 1))
				if( ((M.pulling == tmob && ( tmob.restrained() && !( M.restrained() ) && M.stat == 0)) || locate(/obj/item/weapon/grab, tmob.grabbed_by.len)) )
					if ( !(world.time % 5) )
						src << "\red [tmob] is restrained, you cannot push past"
					now_pushing = 0
					return
				if( tmob.pulling == M && ( M.restrained() && !( tmob.restrained() ) && tmob.stat == 0) )
					if ( !(world.time % 5) )
						src << "\red [tmob] is restraining [M], you cannot push past"
					now_pushing = 0
					return

		//BubbleWrap: people in handcuffs are always switched around as if they were on 'help' intent to prevent a person being pulled from being seperated from their puller
		if((tmob.a_intent == "help" || tmob.restrained()) && (a_intent == "help" || src.restrained()) && tmob.canmove && canmove) // mutual brohugs all around!
			var/turf/oldloc = loc
			loc = tmob.loc
			tmob.loc = oldloc
			now_pushing = 0
			for(var/mob/living/carbon/metroid/Metroid in view(1,tmob))
				if(Metroid.Victim == tmob)
					Metroid.UpdateFeed()
			return

		if(tmob.r_hand && istype(tmob.r_hand, /obj/item/weapon/shield/riot))
			if(prob(99))
				now_pushing = 0
				return
		if(tmob.l_hand && istype(tmob.l_hand, /obj/item/weapon/shield/riot))
			if(prob(99))
				now_pushing = 0
				return
		if(tmob.nopush)
			now_pushing = 0
			return

		tmob.LAssailant = src

	now_pushing = 0
	spawn(0)
		..()
		if (!istype(AM, /atom/movable))
			return
		if (!now_pushing)
			now_pushing = 1

			if (!AM.anchored)
				var/t = get_dir(src, AM)
				if (istype(AM, /obj/structure/window))
					if(AM:ini_dir == NORTHWEST || AM:ini_dir == NORTHEAST || AM:ini_dir == SOUTHWEST || AM:ini_dir == SOUTHEAST)
						for(var/obj/structure/window/win in get_step(AM,t))
							now_pushing = 0
							return
				step(AM, t)
			now_pushing = 0
		return
	return

/mob/living/carbon/human/movement_delay()
	var/tally = 0
	var/mob/M = pulling

	if(reagents.has_reagent("hyperzine")) return -1

	if(reagents.has_reagent("nuka_cola")) return -1

	if(analgesic) return -1

	if (istype(loc, /turf/space)) return -1 // It's hard to be slowed down in space by... anything

	var/health_deficiency = traumatic_shock
	if(health_deficiency >= 40) tally += (health_deficiency / 25)

	var/hungry = (500 - nutrition)/5 // So overeat would be 100 and default level would be 80
	if (hungry >= 70) tally += hungry/300


	for(var/organ in list("l_leg","l_foot","r_leg","r_foot"))
		var/datum/organ/external/o = organs["[organ]"]
		if(o.broken)
			tally += 6

	if(wear_suit)
		tally += wear_suit.slowdown

	if(shoes)
		tally += shoes.slowdown

	if(bodytemperature < 283.222)
		tally += (283.222 - bodytemperature) / 10 * 1.75
		if (stuttering < 10)
			stuttering = 10

	if(shock_stage >= 10) tally += 3

	if(tally < 0)
		tally = 0

	if(mutations & mRun)
		tally = 0

	if(istype(M) && M.lying) //Pulling lying down people is slower
		tally += 3

	return tally

/mob/living/carbon/human/Stat()
	..()
	statpanel("Status")

	stat(null, "Intent: [a_intent]")
	stat(null, "Move Mode: [m_intent]")
	if(ticker && ticker.mode && ticker.mode.name == "AI malfunction")
		if(ticker.mode:malf_mode_declared)
			stat(null, "Time left: [max(ticker.mode:AI_win_timeleft/(ticker.mode:apcs/3), 0)]")
	if(emergency_shuttle)
		if(emergency_shuttle.online && emergency_shuttle.location < 2)
			var/timeleft = emergency_shuttle.timeleft()
			if (timeleft)
				stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

	if (client.statpanel == "Status")
		if (internal)
			if (!internal.air_contents)
				del(internal)
			else
				stat("Internal Atmosphere Info", internal.name)
				stat("Tank Pressure", internal.air_contents.return_pressure())
				stat("Distribution Pressure", internal.distribute_pressure)
		if (mind)
			if (mind.special_role == "Changeling" && changeling)
				stat("Chemical Storage", changeling.chem_charges)
				stat("Genetic Damage Time", changeling.geneticdamage)
		if (istype(wear_suit, /obj/item/clothing/suit/space/space_ninja)&&wear_suit:s_initialized)
			stat("Energy Charge", round(wear_suit:cell:charge/100))

/mob/living/carbon/human/ex_act(severity)
	flick("flash", flash)

// /obj/item/clothing/suit/bomb_suit(src)
// /obj/item/clothing/head/bomb_hood(src)
/*
	if (stat == 2 && client)
		gib()
		return

	else if (stat == 2 && !client)
		gibs(loc, viruses)
		del(src)
		return
*/
	var/shielded = 0
	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if (1.0)
			b_loss += 500
			if (!prob(getarmor(null, "bomb")))
				gib()
				return
			else
				var/atom/target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
				throw_at(target, 200, 4)
			//return
//				var/atom/target = get_edge_target_turf(user, get_dir(src, get_step_away(user, src)))
				//user.throw_at(target, 200, 4)

		if (2.0)
			if (!shielded)
				b_loss += 60

			f_loss += 60

			if (!prob(getarmor(null, "bomb")))
				b_loss = b_loss/1.5
				f_loss = f_loss/1.5

			if (!istype(l_ear, /obj/item/clothing/ears/earmuffs) && !istype(r_ear, /obj/item/clothing/ears/earmuffs))
				ear_damage += 30
				ear_deaf += 120

		if(3.0)
			b_loss += 30
			if (!prob(getarmor(null, "bomb")))
				b_loss = b_loss/2
			if (!istype(l_ear, /obj/item/clothing/ears/earmuffs) && !istype(r_ear, /obj/item/clothing/ears/earmuffs))
				ear_damage += 15
				ear_deaf += 60
			if (prob(50) && !shielded)
				Paralyse(10)

	for(var/name in organs)
		var/datum/organ/external/temp = organs[name]
		var/au_msg = "Explosion" // for autopsy
		switch(temp.name)
			if("head")
				temp.take_damage(b_loss * 0.2, f_loss * 0.2, 0, used_weapon = au_msg)
			if("chest")
				temp.take_damage(b_loss * 0.4, f_loss * 0.4, 0, used_weapon = au_msg)
			if("l_arm")
				temp.take_damage(b_loss * 0.05, f_loss * 0.05, 0, used_weapon = au_msg)
			if("r_arm")
				temp.take_damage(b_loss * 0.05, f_loss * 0.05, 0, used_weapon = au_msg)
			if("l_leg")
				temp.take_damage(b_loss * 0.05, f_loss * 0.05, 0, used_weapon = au_msg)
			if("r_leg")
				temp.take_damage(b_loss * 0.05, f_loss * 0.05, 0, used_weapon = au_msg)
	UpdateDamageIcon()


/mob/living/carbon/human/blob_act()
	if(stat == 2)	return
	show_message("\red The blob attacks you!")
	var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
	var/datum/organ/external/affecting = get_organ(ran_zone(dam_zone))
	apply_damage(rand(30,40), BRUTE, affecting, run_armor_check(affecting, "melee"))
	UpdateDamageIcon()
	return

/mob/living/carbon/human/u_equip(obj/item/W as obj)
	if (W == wear_suit)
		W = s_store
		if (W)
			u_equip(W)
			if (client)
				client.screen -= W
			if (W)
				W.loc = loc
				W.dropped(src)
				W.layer = initial(W.layer)
		wear_suit = null
	else if (W == w_uniform)
		W = r_store
		if (W)
			u_equip(W)
			if (client)
				client.screen -= W
			if (W)
				W.loc = loc
				W.dropped(src)
				W.layer = initial(W.layer)
		W = l_store
		if (W)
			u_equip(W)
			if (client)
				client.screen -= W
			if (W)
				W.loc = loc
				W.dropped(src)
				W.layer = initial(W.layer)
		W = wear_id
		if (W)
			u_equip(W)
			if (client)
				client.screen -= W
			if (W)
				W.loc = loc
				W.dropped(src)
				W.layer = initial(W.layer)
		W = belt
		if (W)
			u_equip(W)
			if (client)
				client.screen -= W
			if (W)
				W.loc = loc
				W.dropped(src)
				W.layer = initial(W.layer)
		w_uniform = null
	else if (W == gloves)
		gloves = null
	else if (W == glasses)
		glasses = null
	else if (W == head)
		var/obj/item/prev_head = W
		head = null
		if(prev_head && (prev_head.flags & BLOCKHAIR))
			// rebuild face
			del(face_standing)
			del(face_lying)

	else if (W == l_ear)
		l_ear = null
	else if (W == r_ear)
		r_ear = null
	else if (W == shoes)
		shoes = null
	else if (W == belt)
		belt = null
	else if (W == wear_mask)
		var/obj/item/prev_mask = W
		if(internal)
			if (internals)
				internals.icon_state = "internal0"
			internal = null
		wear_mask = null
		if(prev_mask && (prev_mask.flags & BLOCKHAIR))
			// rebuild face
			del(face_standing)
			del(face_lying)

	else if (W == wear_id)
		wear_id = null
	else if (W == r_store)
		r_store = null
	else if (W == l_store)
		l_store = null
	else if (W == s_store)
		s_store = null
	else if (W == back)
		back = null
	else if (W == handcuffed)
		handcuffed = null
	else if (W == r_hand)
		r_hand = null
	else if (W == l_hand)
		l_hand = null

	update_clothing()

/mob/living/carbon/human/db_click(text, t1)
	var/obj/item/W = equipped()
	var/emptyHand = (W == null)
	if ((!emptyHand) && (!istype(W, /obj/item)))
		return
	if (emptyHand)
		usr.next_move = usr.prev_move
		usr:lastDblClick -= 3	//permit the double-click redirection to proceed.
	switch(text)
		if("mask")
			if (wear_mask)
				if (emptyHand)
					wear_mask.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/mask) ))
				return
			u_equip(W)
			wear_mask = W
			if(wear_mask && (wear_mask.flags & BLOCKHAIR))
				del(face_standing)
				del(face_lying)

			W.equipped(src, text)
		if("back")
			if (back)
				if (emptyHand)
					back.DblClick()
				return
			if (!istype(W, /obj/item))
				return
			if (!( W.slot_flags & SLOT_BACK ))
				return
			if(istype(W,/obj/item/weapon/twohanded) && W:wielded)
				usr << "<span class='warning'>Unwield the [initial(W.name)] first!</span>"
				return
			u_equip(W)
			back = W
			W.equipped(src, text)

/*		if("headset")
			if (ears)
				if (emptyHand)
					ears.DblClick()
				return
			if (!( istype(W, /obj/item/device/radio/headset) ))
				return
			u_equip(W)
			w_radio = W
			W.equipped(src, text) */
		if("o_clothing")
			if (wear_suit)
				if (emptyHand)
					wear_suit.DblClick()
				return
			if (!istype(W, /obj/item))
				return
			if (!( W.slot_flags & SLOT_OCLOTHING ))
				return
				return
			u_equip(W)
			wear_suit = W
			W.equipped(src, text)
		if("gloves")
			if (gloves)
				if (emptyHand)
					gloves.DblClick()
				return
			if (!istype(W, /obj/item))
				return
			if (!( W.slot_flags & SLOT_GLOVES ))
				return
			u_equip(W)
			gloves = W
			W.equipped(src, text)
		if("shoes")
			if (shoes)
				if (emptyHand)
					shoes.DblClick()
				return
			if (!istype(W, /obj/item))
				return
			if (!( W.slot_flags & SLOT_FEET ))
				return
			u_equip(W)
			shoes = W
			W.equipped(src, text)
		if("belt")
			if (belt)
				if (emptyHand)
					belt.DblClick()
				return
			if (!istype(W, /obj/item))
				return
			if (!( W.slot_flags & SLOT_BELT ))
				return
			u_equip(W)
			belt = W
			W.equipped(src, text)
		if("eyes")
			if (glasses)
				if (emptyHand)
					glasses.DblClick()
				return
			if (!istype(W, /obj/item))
				return
			if (!( W.slot_flags & SLOT_EYES ))
				return
			u_equip(W)
			glasses = W
			W.equipped(src, text)
		if("head")
			if (head)
				if (emptyHand)
					head.DblClick()
				return
			if (!istype(W, /obj/item))
				return
			if (!( W.slot_flags & SLOT_HEAD ))
				return
			u_equip(W)
			head = W
			if(head && (head.flags & BLOCKHAIR))
				del(face_standing)
				del(face_lying)

			if(istype(W,/obj/item/clothing/head/kitty))
				W.update_icon(src)
			W.equipped(src, text)
		if("l_ear")
			if (l_ear)
				if (emptyHand)
					l_ear.DblClick()
				return
			else if(emptyHand)
				return
			if (!( istype(W, /obj/item/clothing/ears) ) && !( istype(W, /obj/item/device/radio/headset) ) && W.w_class != 1)
				return
			if(istype(W,/obj/item/clothing/ears) && W:twoeared && r_ear)
				return
			u_equip(W)
			l_ear = W
			if(istype(W,/obj/item/clothing/ears) && W:twoeared)
				var/obj/item/clothing/ears/offear/O = new(W)
				O.loc = src
				equip_if_possible(O, slot_ears)
			W.equipped(src, text)
		if("r_ear")
			if (r_ear)
				if (emptyHand)
					r_ear.DblClick()
				return
			else if(emptyHand)
				return
			if (!( istype(W, /obj/item/clothing/ears) ) && !( istype(W, /obj/item/device/radio/headset) ) && W.w_class != 1)
				return
			if(istype(W,/obj/item/clothing/ears) && W:twoeared && l_ear)
				return
			u_equip(W)
			r_ear = W
			if(istype(W,/obj/item/clothing/ears) && W:twoeared)
				var/obj/item/clothing/ears/offear/O = new(W)
				O.loc = src
				equip_if_possible(O, slot_ears)
			W.equipped(src, text)
		if("i_clothing")
			if (w_uniform)
				if (emptyHand)
					w_uniform.DblClick()
				return
			if (!istype(W, /obj/item))
				return
			if (!( W.slot_flags & SLOT_ICLOTHING ))
				return
				return
			u_equip(W)
			w_uniform = W
			W.equipped(src, text)
		if("id")
			if (wear_id)
				if (emptyHand)
					wear_id.DblClick()
				return
			if (!w_uniform)
				return
			if (!istype(W, /obj/item))
				return
			if (!( W.slot_flags & SLOT_ID ))
				return
			u_equip(W)
			wear_id = W
			W.equipped(src, text)
		if("storage1")
			if (l_store)
				if (emptyHand)
					l_store.DblClick()
				return
			if (!istype(W, /obj/item))
				return
			if ( ( W.slot_flags & SLOT_DENYPOCKET ) )
				return
			if ( W.w_class <= 2 || ( W.slot_flags & SLOT_POCKET ) )
				u_equip(W)
				l_store = W
		if("storage2")
			if (r_store)
				if (emptyHand)
					r_store.DblClick()
				return
			if (!istype(W, /obj/item))
				return
			if ( ( W.slot_flags & SLOT_DENYPOCKET ) )
				return
			if ( W.w_class <= 2 || ( W.slot_flags & SLOT_POCKET ) )
				u_equip(W)
				r_store = W
		if("suit storage")
			if (s_store)
				if (emptyHand)
					s_store.DblClick()
				return
			var/confirm
			if (wear_suit)
				if(!wear_suit.allowed)
					usr << "You somehow have a suit with no defined allowed items for suit storage, stop that."
					return
				if (istype(W, /obj/item/device/pda) || istype(W, /obj/item/weapon/pen))
					confirm = 1
				if (is_type_in_list(W, wear_suit.allowed))
					confirm = 1
			if (!confirm) return
			else
				u_equip(W)
				s_store = W

	update_clothing()

	return

/mob/living/carbon/human/meteorhit(O as obj)
	for(var/mob/M in viewers(src, null))
		if ((M.client && !( M.blinded )))
			M.show_message(text("\red [] has been hit by []", src, O), 1)
	if (health > 0)
		var/datum/organ/external/affecting = get_organ(pick("chest", "chest", "chest", "head"))
		if(!affecting || affecting.destroyed)	return
		if (istype(O, /obj/effect/immovablerod))
			affecting.take_damage(101, 0)
		else
			affecting.take_damage((istype(O, /obj/effect/meteor/small) ? 10 : 25), 30)
			UpdateDamageIcon()
		updatehealth()
	return

/mob/living/carbon/human/Move(a, b, flag)

	if (buckled)
		return

	if (restrained())
		pulling = null


	var/t7 = 1
	if (restrained())
		for(var/mob/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				t7 = null
	if ((t7 && (pulling && ((get_dist(src, pulling) <= 1 || pulling.loc == loc) && (client && client.moving)))))
		var/turf/T = loc
		. = ..()

		if (pulling && pulling.loc)
			if(!( isturf(pulling.loc) ))
				pulling = null
				return
			else
				if(Debug)
					diary <<"pulling disappeared? at [__LINE__] in mob.dm - pulling = [pulling]"
					diary <<"REPORT THIS"

		/////
		if(pulling && pulling.anchored)
			pulling = null
			return

		if (!restrained())
			var/diag = get_dir(src, pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((get_dist(src, pulling) > 1 || diag))
				if (ismob(pulling))
					var/mob/M = pulling
					var/ok = 1
					if (locate(/obj/item/weapon/grab, M.grabbed_by))
						if (prob(75))
							var/obj/item/weapon/grab/G = pick(M.grabbed_by)
							if (istype(G, /obj/item/weapon/grab))
								for(var/mob/O in viewers(M, null))
									O.show_message(text("\red [] has been pulled from []'s grip by []", G.affecting, G.assailant, src), 1)
								//G = null
								del(G)
						else
							ok = 0
						if (locate(/obj/item/weapon/grab, M.grabbed_by.len))
							ok = 0
					if (ok)
						var/t = M.pulling
						M.pulling = null

						//this is the gay blood on floor shit -- Added back -- Skie
						if (M.lying && (prob(M.getBruteLoss() / 6)))
							var/turf/location = M.loc
							if (istype(location, /turf/simulated))
								location.add_blood(M)


						step(pulling, get_dir(pulling.loc, T))
						M.pulling = t
				else
					if (pulling)
						if (istype(pulling, /obj/structure/window))
							if(pulling:ini_dir == NORTHWEST || pulling:ini_dir == NORTHEAST || pulling:ini_dir == SOUTHWEST || pulling:ini_dir == SOUTHEAST)
								for(var/obj/structure/window/win in get_step(pulling,get_dir(pulling.loc, T)))
									pulling = null
					if (pulling)
						step(pulling, get_dir(pulling.loc, T))
	else
		pulling = null
		. = ..()
	if ((s_active && !( s_active in contents ) ))
		s_active.close(src)

	for(var/mob/living/carbon/metroid/M in view(1,src))
		M.UpdateFeed(src)
	return

/mob/living/carbon/human/proc/rebuild_body_overlays()
	// This proc REBUILDS the body overlays. These are the overlays displayed under the clothing.
	// Builds the body overlays both for lying and standing states.
	//
	// This is necessary whenever something about the mob's body appearance changes, for example:
	// - When the mutantrace changes
	// - When a visible wound is added to the mob's skin
	// - When the mob loses a limb
	body_overlays_standing.Cut()
	body_overlays_lying.Cut()

	if (mutations & HULK)
		body_overlays_standing += image("icon" = 'genetics.dmi', "icon_state" = "hulk_[gender]_s")
		body_overlays_lying    += image("icon" = 'genetics.dmi', "icon_state" = "hulk_[gender]_l")

	if (mutations & COLD_RESISTANCE)
		body_overlays_standing += image("icon" = 'genetics.dmi', "icon_state" = "fire_s")
		body_overlays_lying    += image("icon" = 'genetics.dmi', "icon_state" = "fire_l")

	if (mutations & TK)
		body_overlays_standing += image("icon" = 'genetics.dmi', "icon_state" = "telekinesishead_s")
		body_overlays_lying	   += image("icon" = 'genetics.dmi', "icon_state" = "telekinesishead_l")

	if (mutations & LASER)
		body_overlays_standing += image("icon" = 'genetics.dmi', "icon_state" = "lasereyes_s")
		body_overlays_lying	   += image("icon" = 'genetics.dmi', "icon_state" = "lasereyes_l")

	if (mutantrace)
		switch(mutantrace)
			if("golem","metroid")
				body_overlays_standing += image("icon" = 'genetics.dmi', "icon_state" = "[mutantrace]_s")
				body_overlays_lying    += image("icon" = 'genetics.dmi', "icon_state" = "[mutantrace]_l")
				if(face_standing)
					del(face_standing)
				if(face_lying)
					del(face_lying)
				if(stand_icon)
					del(stand_icon)
				if(lying_icon)
					del(lying_icon)
			if("lizard")
				body_overlays_standing += image("icon" = 'genetics.dmi', "icon_state" = "[mutantrace]_[gender]_s")
				body_overlays_lying	   += image("icon" = 'genetics.dmi', "icon_state" = "[mutantrace]_[gender]_l")
				if(face_standing)
					del(face_standing)
				if(face_lying)
					del(face_lying)
				if(stand_icon)
					del(stand_icon)
				if(lying_icon)
					del(lying_icon)
			if("plant")
				if(stat != 2) //if not dead, that is
					body_overlays_standing += image("icon" = 'genetics.dmi', "icon_state" = "[mutantrace]_[gender]_s")
					body_overlays_lying    += image("icon" = 'genetics.dmi', "icon_state" = "[mutantrace]_[gender]_l")
				else
					// not sure why this doesn't need separate lying/standing states
					body_overlays_lying += image("icon" = 'genetics.dmi', "icon_state" = "[mutantrace]_d")
				if(face_standing)
					del(face_standing)
				if(face_lying)
					del(face_lying)
				if(stand_icon)
					del(stand_icon)
				if(lying_icon)
					del(lying_icon)
	else
		// TODO: rewrite update_face() and update_body() if necessary
		if(!face_standing || !face_lying)
			update_face()
		if(!stand_icon || !lying_icon)
			update_body()

	// Other procs(probably update_face() and update_body() ) also rebuild their own
	// kinds of overlay lists. Think about merging those procs into this proc.
	body_overlays_lying += body_lying
	body_overlays_standing += body_standing

	// face_lying and face_standing are the face icons, not a flag
	body_overlays_lying += face_lying
	body_overlays_standing += face_standing



/mob/living/carbon/human/proc/rebuild_clothing_overlays()
	// This proc REBUILDS the clothing overlays entirely.
	// This is necessary whenever clothing changes, or when the mob switches from laying
	// into standing state or vice verca.

	// This should possibly be split into two categories:
	// - "under", which is stuff that is worn at the lowest clothing layer and doesn't change often,
	//    such as jumpsuits, gloves, headset, etc.
	// - "over", which is stuff that is worn at the highest clothing layer and changes very often,
	//    such as stuff in the user's hand, space suits, helmets, etc.

	// Delete all items from the overlay lists
	clothing_overlays.Cut()

	// Uniform
	if(w_uniform)
		// What is screen_loc stuff doing here?!
		w_uniform.screen_loc = ui_iclothing

		if(istype(w_uniform, /obj/item/clothing/under))
			var/t1 = w_uniform.color
			if (!t1)
				t1 = icon_state
			clothing_overlays += image("icon" = 'uniform.dmi', "icon_state" = text("[][]",t1, (!(lying) ? "_s" : "_l")), "layer" = MOB_LAYER)
			if (w_uniform.blood_DNA)
				var/icon/stain_icon = icon('blood.dmi', "uniformblood[!lying ? "" : "2"]")
				clothing_overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)

	if (wear_id)
		if(wear_id.over_jumpsuit)
			clothing_overlays += image("icon" = 'mob.dmi', "icon_state" = "id[!lying ? null : "2"]", "layer" = MOB_LAYER)

	if (client)
		client.screen -= hud_used.intents
		client.screen -= hud_used.mov_int


	//Screenlocs for these slots are handled by the huds other_update()
	//because theyre located on the 'other' inventory bar.

	// Gloves
	var/datum/organ/external/lo = organs["l_hand"]
	var/datum/organ/external/ro = organs["r_hand"]
	if (!lo.destroyed || !ro.destroyed)
		if (gloves)
			var/t1 = gloves.item_state
			if (!t1)
				t1 = gloves.icon_state
			var/icon/gloves_icon = new /icon("icon" = 'hands.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")))
			if(lo.destroyed)
				gloves_icon.Blend(new /icon('limb_mask.dmi', "right_[lying?"l":"s"]"), ICON_MULTIPLY)
			if(ro.destroyed)
				gloves_icon.Blend(new /icon('limb_mask.dmi', "left_[lying?"l":"s"]"), ICON_MULTIPLY)
			clothing_overlays += image(gloves_icon, "layer" = MOB_LAYER)
			if (gloves.blood_DNA)
				var/icon/stain_icon = icon('blood.dmi', "bloodyhands[!lying ? "" : "2"]")
				if(lo.destroyed)
					stain_icon.Blend(new /icon('limb_mask.dmi', "right_[lying?"l":"s"]"), ICON_MULTIPLY)
				else if(ro.destroyed)
					stain_icon.Blend(new /icon('limb_mask.dmi', "left_[lying?"l":"s"]"), ICON_MULTIPLY)
				clothing_overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
		else if (blood_DNA)
			var/icon/stain_icon = icon('blood.dmi', "bloodyhands[!lying ? "" : "2"]")
			if(lo.destroyed)
				stain_icon.Blend(new /icon('limb_mask.dmi', "right_[lying?"l":"s"]"), ICON_MULTIPLY)
			else if(ro.destroyed)
				stain_icon.Blend(new /icon('limb_mask.dmi', "left_[lying?"l":"s"]"), ICON_MULTIPLY)
			clothing_overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)

	// Glasses
	if (glasses)
		var/t1 = glasses.icon_state
		clothing_overlays += image("icon" = 'eyes.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)

	// Ears
	if (l_ear)
		var/t1 = l_ear.icon_state
		clothing_overlays += image("icon" = 'ears.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
	if (r_ear)
		var/t1 = r_ear.icon_state
		clothing_overlays += image("icon" = 'ears.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)

	// Shoes
	lo = organs["l_foot"]
	ro = organs["r_foot"]
	if ((!lo.destroyed || !ro.destroyed) && shoes)
		var/t1 = shoes.icon_state
		var/icon/shoes_icon = new /icon("icon" = 'feet.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")))
		if(lo.destroyed && !lying)
			shoes_icon.Blend(new /icon('limb_mask.dmi', "right[lying?"_l":""]"), ICON_MULTIPLY)
		else if(ro.destroyed && !lying)
			shoes_icon.Blend(new /icon('limb_mask.dmi', "left[lying?"_l":""]"), ICON_MULTIPLY)
		clothing_overlays += image(shoes_icon, "layer" = MOB_LAYER)
		if (shoes.blood_DNA)
			var/icon/stain_icon = icon('blood.dmi', "shoeblood[!lying ? "" : "2"]")
			if(lo.destroyed)
				stain_icon.Blend(new /icon('limb_mask.dmi', "right_[lying?"l":"s"]"), ICON_MULTIPLY)
			else if(ro.destroyed)
				stain_icon.Blend(new /icon('limb_mask.dmi', "left_[lying?"l":"s"]"), ICON_MULTIPLY)
			clothing_overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)	// Radio

	if (s_store)
		var/t1 = s_store.item_state
		if (!t1)
			t1 = s_store.icon_state
		if(!istype(wear_suit, /obj/item/clothing/suit/storage/armoredundersuit))
			clothing_overlays += image("icon" = 'belt_mirror.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
		s_store.screen_loc = ui_sstore1


	if (wear_suit)
		if (istype(wear_suit, /obj/item/clothing/suit))
			var/t1 = wear_suit.icon_state
			clothing_overlays += image("icon" = 'suit.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)

		if (wear_suit)
			if (wear_suit.blood_DNA)
				var/icon/stain_icon = null
				if (istype(wear_suit, /obj/item/clothing/suit/armor/vest || /obj/item/clothing/suit/storage/wcoat))
					stain_icon = icon('blood.dmi', "armorblood[!lying ? "" : "2"]")
				else if (istype(wear_suit, /obj/item/clothing/suit/storage/det_suit || /obj/item/clothing/suit/storage/labcoat))
					stain_icon = icon('blood.dmi', "coatblood[!lying ? "" : "2"]")
				else
					stain_icon = icon('blood.dmi', "suitblood[!lying ? "" : "2"]")
				clothing_overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
			wear_suit.screen_loc = ui_oclothing

		if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
			if (handcuffed)
				handcuffed.loc = loc
				handcuffed.layer = initial(handcuffed.layer)
				handcuffed = null
			if ((l_hand || r_hand))
				// I don't know what this does, but it looks horrible
				var/h = hand
				hand = 1
				drop_item()
				hand = 0
				drop_item()
				hand = h

	if (wear_mask)
		if (istype(wear_mask, /obj/item/clothing/mask))
			var/t1 = wear_mask.icon_state
			clothing_overlays += image("icon" = 'mask.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
			if (!istype(wear_mask, /obj/item/clothing/mask/cigarette))
				if (wear_mask.blood_DNA)
					var/icon/stain_icon = icon('blood.dmi', "maskblood[!lying ? "" : "2"]")
					clothing_overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
			wear_mask.screen_loc = ui_mask

	// Head
	if (head)
		var/t1 = head.icon_state
		var/icon/head_icon = icon('head.dmi', text("[][]", t1, (!( lying ) ? null : "2")))
		if(istype(head,/obj/item/clothing/head/kitty))
			head_icon = (( lying ) ? head:mob2 : head:mob)
		clothing_overlays += image("icon" = head_icon, "layer" = MOB_LAYER)
		if(gimmick_hat)
			clothing_overlays += image("icon" = icon('gimmick_head.dmi', "[gimmick_hat][!lying ? "" : "2"]"), "layer" = MOB_LAYER)
		if (head.blood_DNA)
			var/icon/stain_icon = icon('blood.dmi', "helmetblood[!lying ? "" : "2"]")
			clothing_overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
		head.screen_loc = ui_head

	// Belt
	if (belt)
		var/t1 = belt.item_state
		if (!t1)
			t1 = belt.icon_state
		clothing_overlays += image("icon" = 'belt.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
		belt.screen_loc = ui_belt

	if (wear_id)
		wear_id.screen_loc = ui_id

	if (l_store)
		l_store.screen_loc = ui_storage1

	if (r_store)
		r_store.screen_loc = ui_storage2

	if (back)
		var/t1 = back.icon_state
		clothing_overlays += image("icon" = 'back.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
		back.screen_loc = ui_back

	if(client) hud_used.other_update() //Update the screenloc of the items on the 'other' inventory bar
								       //to hide / show them.
								       // WHAT IS THIS DOING IN UPDATE_CLOTHING(), AHHHHHHHHHHHHH
	if (handcuffed)
		pulling = null
		var/h1 = handcuffed.icon_state
		if (!lying)
			clothing_overlays += image("icon" = 'mob.dmi', "icon_state" = "[h1]1", "layer" = MOB_LAYER)
		else
			clothing_overlays += image("icon" = 'mob.dmi', "icon_state" = "[h1]2", "layer" = MOB_LAYER)


	if (r_hand)
		clothing_overlays += image("icon" = 'items_righthand.dmi', "icon_state" = r_hand.item_state ? r_hand.item_state : r_hand.icon_state, "layer" = MOB_LAYER+1)

		r_hand.screen_loc = ui_rhand

	if (l_hand)
		clothing_overlays += image("icon" = 'items_lefthand.dmi', "icon_state" = l_hand.item_state ? l_hand.item_state : l_hand.icon_state, "layer" = MOB_LAYER+1)

		l_hand.screen_loc = ui_lhand

	var/shielded = 0
	for (var/obj/item/weapon/cloaking_device/S in src)
		if (S.active)
			shielded = 2
			break

	if(istype(wear_suit, /obj/item/clothing/suit/space/space_ninja)&&wear_suit:s_active)
		shielded = 3

	if(shielded == 1)
		clothing_overlays += image("icon" = 'effects.dmi', "icon_state" = "shield", "layer" = MOB_LAYER+1)


	if(client && client.admin_invis)
		invisibility = 100
	else if (shielded == 2)
		invisibility = 2
	else
		invisibility = 0
		if(targeted_by && target_locked)
			clothing_overlays += target_locked
		else if(targeted_by)
			target_locked = new /obj/effect/target_locked(src)
			clothing_overlays += target_locked
		else if(!targeted_by && target_locked)
			del(target_locked)

	last_b_state = stat

/mob/living/carbon/human/proc/misc_clothing_updates()
	// Temporary proc to shove stuff in that was put into update_clothing()
	// for questionable reasons

	if (client)
		if (i_select)
			if (intent)
				client.screen += hud_used.intents

				var/list/L = dd_text2list(intent, ",")
				L[1] += ":-11"
				i_select.screen_loc = dd_list2text(L,",") //ICONS4, FUCKING SHIT
			else
				i_select.screen_loc = null
		if (m_select)
			if (m_int)
				client.screen += hud_used.mov_int

				var/list/L = dd_text2list(m_int, ",")
				L[1] += ":-11"
				m_select.screen_loc = dd_list2text(L,",") //ICONS4, FUCKING SHIT
			else
				m_select.screen_loc = null

	// Probably a lazy way to make sure all items are on the screen exactly once
	if (client)
		client.screen -= contents
		client.screen += contents

/mob/living/carbon/human/rebuild_appearance()
	// Lazy method: Just rebuild everything.
	// This can be called when the mob is created, but on other occasions, rebuild_body_overlays(),
	// rebuild_clothing_overlays() etc. should be called individually.

	handle_clothing() // nonvisual stuff
	misc_clothing_updates() // silly stuff

	rebuild_body_overlays() // rebuild the body itself, that is mutant race traits, hair, limbs, etc.
	rebuild_clothing_overlays() // rebuild the entire clothing

	update_overlays_from_lists()

/mob/living/carbon/human/proc/update_overlays_from_lists()
	// This will simply update the overlays without actually
	// rebuilding anything. Can be called often without much
	// effect on performance.


	// Update the actual overlays from our prebuilt lists
	overlays = null

	if (monkeyizing) // while monkeyizing we do not wish to display any overlays
		return

	if(lying)
		icon = lying_icon
		overlays += body_overlays_lying

	if(!lying)
		icon = stand_icon
		overlays += body_overlays_standing



	overlays += clothing_overlays

/mob/living/carbon/human/update_body_appearance()
	// Should be called whenever something about the body appearance itself changes.

	rebuild_body_overlays()
	update_overlays_from_lists()

/mob/living/carbon/human/update_lying()
	// Should be called whenever something about the lying status of the mob might have changed.

	if(visual_lying != lying)
		visual_lying = lying
		rebuild_clothing_overlays()
		update_overlays_from_lists()

/mob/living/carbon/human/update_clothing()
	// Should be called only when something about the clothing itself changed
	// which is not handled by the equip code.
	rebuild_appearance()

	return

	// TODO: once I have replaced the udpate_clothing() calls with update_lying() or
	//		 update_body_appearance() calls where suitable, the following code should
	//		 be used. furthermore, handle_clothes() should be moved to Life()

	rebuild_clothing_overlays()
	update_overlays_from_lists()

/mob/living/carbon/human/hand_p(mob/M as mob)
	var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
	var/datum/organ/external/affecting = get_organ(ran_zone(dam_zone))
	var/armor = run_armor_check(affecting, "melee")
	apply_damage(rand(1,2), BRUTE, affecting, armor)
	if(armor >= 2)	return

	for(var/datum/disease/D in M.viruses)
		if(istype(D, /datum/disease/jungle_fever))
			var/mob/living/carbon/human/H = src
			src = null
			src = H.monkeyize()
			contract_disease(D,1,0)
	return



/mob/living/carbon/human/attack_animal(mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		M.emote("[M.friendly] [src]")
	else
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[M]</B> [M.attacktext] [src]!", 1)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
		var/datum/organ/external/affecting = get_organ(ran_zone(dam_zone))
		var/armor = run_armor_check(affecting, "melee")
		apply_damage(damage, BRUTE, affecting, armor)
		if(armor >= 2)	return


/mob/living/carbon/human/attack_metroid(mob/living/carbon/metroid/M as mob)
	if(M.Victim) return // can't attack while eating!

	if (health > -100)

		for(var/mob/O in viewers(src, null))
			if ((O.client && !( O.blinded )))
				O.show_message(text("\red <B>The [M.name] has [pick("bit","slashed")] []!</B>", src), 1)

		var/damage = rand(1, 3)

		if(istype(M, /mob/living/carbon/metroid/adult))
			damage = rand(10, 35)
		else
			damage = rand(5, 25)


		var/dam_zone = pick("head", "chest", "l_arm", "r_arm", "l_leg", "r_leg", "groin")

		var/datum/organ/external/affecting = get_organ(ran_zone(dam_zone))
		var/armor_block = run_armor_check(affecting, "melee")
		apply_damage(damage, CLONE, affecting, armor_block)
		UpdateDamageIcon()


		if(M.powerlevel > 0)
			var/stunprob = 10
			var/power = M.powerlevel + rand(0,3)

			switch(M.powerlevel)
				if(1 to 2) stunprob = 20
				if(3 to 4) stunprob = 30
				if(5 to 6) stunprob = 40
				if(7 to 8) stunprob = 60
				if(9) 	   stunprob = 70
				if(10) 	   stunprob = 95

			if(prob(stunprob))
				M.powerlevel -= 3
				if(M.powerlevel < 0)
					M.powerlevel = 0

				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>The [M.name] has shocked []!</B>", src), 1)

				Weaken(power)
				if (stuttering < power)
					stuttering = power
				Stun(power)

				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()

				if (prob(stunprob) && M.powerlevel >= 8)
					adjustFireLoss(M.powerlevel * rand(6,10))


		updatehealth()

	return


/mob/living/carbon/human/restrained()
	if (handcuffed)
		return 1
	if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
		return 1
	return 0

/mob/living/carbon/human/proc/update_body()
	if(stand_icon)
		del(stand_icon)
	if(lying_icon)
		del(lying_icon)

	if (mutantrace)
		return

	var/g = "m"
	if (gender == MALE)
		g = "m"
	else if (gender == FEMALE)
		g = "f"

	stand_icon = new /icon('human.dmi', "torso_[g]_s")
	lying_icon = new /icon('human.dmi', "torso_[g]_l")

	var/husk = (mutations & HUSK)

	stand_icon.Blend(new /icon('human.dmi', "chest_[g]_s"), ICON_OVERLAY)
	lying_icon.Blend(new /icon('human.dmi', "chest_[g]_l"), ICON_OVERLAY)

	var/datum/organ/external/head = organs["head"]
	if(!head.destroyed)
		stand_icon.Blend(new /icon('human.dmi', "head_[g]_s"), ICON_OVERLAY)
		lying_icon.Blend(new /icon('human.dmi', "head_[g]_l"), ICON_OVERLAY)

	for(var/name in organs)
		var/datum/organ/external/part = organs[name]
		if(!istype(part, /datum/organ/external/groin) \
			&& !istype(part, /datum/organ/external/chest) \
			&& !istype(part, /datum/organ/external/head) \
			&& !part.destroyed)
			var/icon/temp = new /icon('human.dmi', "[part.icon_name]_s")
			if(part.robot) temp.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
			stand_icon.Blend(temp, ICON_OVERLAY)
			temp = new /icon('human.dmi', "[part.icon_name]_l")
			if(part.robot) temp.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
			lying_icon.Blend(temp , ICON_OVERLAY)

	stand_icon.Blend(new /icon('human.dmi', "groin_[g]_s"), ICON_OVERLAY)
	lying_icon.Blend(new /icon('human.dmi', "groin_[g]_l"), ICON_OVERLAY)

	if (husk)
		var/icon/husk_s = new /icon('human.dmi', "husk_s")
		var/icon/husk_l = new /icon('human.dmi', "husk_l")

		for(var/name in organs)
			var/datum/organ/external/part = organs[name]
			if(!istype(part, /datum/organ/external/groin) \
				&& !istype(part, /datum/organ/external/chest) \
				&& !istype(part, /datum/organ/external/head) \
				&& part.destroyed)
				husk_s.Blend(new /icon('dam_mask.dmi', "[part.icon_name]"), ICON_SUBTRACT)
				husk_l.Blend(new /icon('dam_mask.dmi', "[part.icon_name]2"), ICON_SUBTRACT)

		stand_icon.Blend(husk_s, ICON_OVERLAY)
		lying_icon.Blend(husk_l, ICON_OVERLAY)

	// Skin tone
	if (s_tone >= 0)
		stand_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
		lying_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
	else
		stand_icon.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)
		lying_icon.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)
	if(pale)
		stand_icon.Blend(rgb(100,100,100))
		lying_icon.Blend(rgb(100,100,100))

	if (underwear < 6 && underwear > 0)
//		if(!obese)
		stand_icon.Blend(new /icon('human.dmi', "underwear[underwear]_[g]_s"), ICON_OVERLAY)
		lying_icon.Blend(new /icon('human.dmi', "underwear[underwear]_[g]_l"), ICON_OVERLAY)

/mob/living/carbon/human/proc/update_face()
	if(organs)
		var/datum/organ/external/head = organs["head"]
		if(head)
			if(head.destroyed)
				del(face_standing)
				del(face_lying)
				return
	if(!facial_hair_style || !hair_style)	return//Seems people like to lose their icons, this should stop the runtimes for now
	del(face_standing)
	del(face_lying)

	if (mutantrace)
		return

	var/g = "m"
	if (gender == MALE)
		g = "m"
	else if (gender == FEMALE)
		g = "f"

	var/icon/eyes_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "eyes_s")
	var/icon/eyes_l = new/icon("icon" = 'human_face.dmi', "icon_state" = "eyes_l")
	eyes_s.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)
	eyes_l.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)

	var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
	var/icon/hair_l = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_l")
	hair_s.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)
	hair_l.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)

	var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
	var/icon/facial_l = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_l")
	facial_s.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)
	facial_l.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)

	var/icon/mouth_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "mouth_[g]_s")
	var/icon/mouth_l = new/icon("icon" = 'human_face.dmi', "icon_state" = "mouth_[g]_l")

	// if the head or mask has the flag BLOCKHAIR (equal to 5), then do not apply hair
	if((!(head && (head.flags & BLOCKHAIR))) && !(wear_mask && (wear_mask.flags & BLOCKHAIR)))
		eyes_s.Blend(hair_s, ICON_OVERLAY)
		eyes_l.Blend(hair_l, ICON_OVERLAY)

	eyes_s.Blend(mouth_s, ICON_OVERLAY)
	eyes_l.Blend(mouth_l, ICON_OVERLAY)

	// if BLOCKHAIR, do not apply facial hair
	if((!(head && (head.flags & BLOCKHAIR))) && !(wear_mask && (wear_mask.flags & BLOCKHAIR)))
		eyes_s.Blend(facial_s, ICON_OVERLAY)
		eyes_l.Blend(facial_l, ICON_OVERLAY)


	face_standing = new /image()
	face_lying = new /image()
	face_standing.icon = eyes_s
	face_standing.layer = MOB_LAYER
	face_lying.icon = eyes_l
	face_lying.layer = MOB_LAYER

	del(mouth_l)
	del(mouth_s)
	del(facial_l)
	del(facial_s)
	del(hair_l)
	del(hair_s)
	del(eyes_l)
	del(eyes_s)

/mob/living/carbon/human/var/co2overloadtime = null
/mob/living/carbon/human/var/temperature_resistance = T0C+75

/obj/effect/equip_e/human/process()
	if (item)
		item.add_fingerprint(source)
	if (!item)
		switch(place)
			if("mask")
				if (!( target.wear_mask ))
					//SN src = null
					del(src)
					return
/*			if("headset")
				if (!( target.w_radio ))
					//SN src = null
					del(src)
					return */
			if("l_hand")
				if (!( target.l_hand ))
					//SN src = null
					del(src)
					return
			if("r_hand")
				if (!( target.r_hand ))
					//SN src = null
					del(src)
					return
			if("suit")
				if (!( target.wear_suit ))
					//SN src = null
					del(src)
					return
			if("uniform")
				if (!( target.w_uniform ))
					//SN src = null
					del(src)
					return
			if("back")
				if (!( target.back ))
					//SN src = null
					del(src)
					return
			if("syringe")
				return
			if("pill")
				return
			if("fuel")
				return
			if("drink")
				return
			if("dnainjector")
				return
			if("handcuff")
				if (!( target.handcuffed ))
					//SN src = null
					del(src)
					return
			if("id")
				if ((!( target.wear_id ) || !( target.w_uniform )))
					//SN src = null
					del(src)
					return
			if("internal")
				if ((!( (istype(target.wear_mask, /obj/item/clothing/mask) && (istype(target.back, /obj/item/weapon/tank) || istype(target.belt, /obj/item/weapon/tank) || istype(target.s_store, /obj/item/weapon/tank)) && !( target.internal )) ) && !( target.internal )))
					//SN src = null
					del(src)
					return

	var/list/L = list( "syringe", "pill", "drink", "dnainjector", "fuel")
	if ((item && !( L.Find(place) )))
		if(isrobot(source) && place != "handcuff")
			del(src)
			return
		for(var/mob/O in viewers(target, null))
			O.show_message(text("\red <B>[] is trying to put \a [] on []</B>", source, item, target), 1)
	else
		var/message=null
		switch(place)
			if("syringe")
				message = text("\red <B>[] is trying to inject []!</B>", source, target)
			if("pill")
				message = text("\red <B>[] is trying to force [] to swallow []!</B>", source, target, item)
			if("fuel")
				message = text("\red [source] is trying to force [target] to eat the [item:content]!")
			if("drink")
				message = text("\red <B>[] is trying to force [] to swallow a gulp of []!</B>", source, target, item)
			if("dnainjector")
				message = text("\red <B>[] is trying to inject [] with the []!</B>", source, target, item)
			if("mask")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their mask removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) mask</font>")
				if(istype(target.wear_mask, /obj/item/clothing)&&!target.wear_mask:canremove)
					message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.wear_mask, target)
				else
					message = text("\red <B>[] is trying to take off \a [] from []'s head!</B>", source, target.wear_mask, target)
/*			if("headset")
				message = text("\red <B>[] is trying to take off \a [] from []'s face!</B>", source, target.w_radio, target) */
			if("l_hand")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their left hand item removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) left hand item</font>")
				message = text("\red <B>[] is trying to take off \a [] from []'s left hand!</B>", source, target.l_hand, target)
			if("r_hand")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their right hand item removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) right hand item</font>")
				message = text("\red <B>[] is trying to take off \a [] from []'s right hand!</B>", source, target.r_hand, target)
			if("gloves")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their gloves removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) gloves</font>")
				if(istype(target.gloves, /obj/item/clothing)&&!target.gloves:canremove)
					message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.gloves, target)
				else
					message = text("\red <B>[] is trying to take off the [] from []'s hands!</B>", source, target.gloves, target)
			if("eyes")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their eyewear removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) eyewear</font>")
				if(istype(target.glasses, /obj/item/clothing)&&!target.glasses:canremove)
					message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.glasses, target)
				else
					message = text("\red <B>[] is trying to take off the [] from []'s eyes!</B>", source, target.glasses, target)
			if("l_ear")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their left ear item removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) left ear item</font>")
				if(istype(target.l_ear, /obj/item/clothing)&&!target.l_ear:canremove)
					message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.l_ear, target)
				else
					message = text("\red <B>[] is trying to take off the [] from []'s left ear!</B>", source, target.l_ear, target)
			if("r_ear")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their right ear item removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) right ear item</font>")
				if(istype(target.r_ear, /obj/item/clothing)&&!target.r_ear:canremove)
					message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.r_ear, target)
				else
					message = text("\red <B>[] is trying to take off the [] from []'s right ear!</B>", source, target.r_ear, target)
			if("head")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their hat removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) hat</font>")
				if(istype(target.head, /obj/item/clothing)&&!target.head:canremove)
					message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.head, target)
				else
					message = text("\red <B>[] is trying to take off the [] from []'s head!</B>", source, target.head, target)
			if("shoes")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their shoes removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) shoes</font>")
				if(istype(target.shoes, /obj/item/clothing)&&!target.shoes:canremove)
					message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.shoes, target)
				else
					message = text("\red <B>[] is trying to take off the [] from []'s feet!</B>", source, target.shoes, target)
			if("belt")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their belt item removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) belt item</font>")
				message = text("\red <B>[] is trying to take off the [] from []'s belt!</B>", source, target.belt, target)
			if("suit")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their suit removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) suit</font>")
				if(istype(target.wear_suit, /obj/item/clothing)&&!target.wear_suit:canremove)
					message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.wear_suit, target)
				else
					message = text("\red <B>[] is trying to take off \a [] from []'s body!</B>", source, target.wear_suit, target)
			if("back")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their back item removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) back item</font>")
				message = text("\red <B>[] is trying to take off \a [] from []'s back!</B>", source, target.back, target)
			if("handcuff")
				message = text("\red <B>[] is trying to unhandcuff []!</B>", source, target)
			if("uniform")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their uniform removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) uniform</font>")
				if(istype(target.w_uniform, /obj/item/clothing)&&!target.w_uniform:canremove)
					message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.w_uniform, target)
				else
					message = text("\red <B>[] is trying to take off \a [] from []'s body!</B>", source, target.w_uniform, target)
			if("s_store")
				message = text("\red <B>[] is trying to take off \a [] from []'s suit!</B>", source, target.s_store, target)
			if("pockets")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their pockets emptied by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to empty [target.name]'s ([target.ckey]) pockets</font>")
				for(var/obj/item/weapon/mousetrap/MT in  list(target.l_store, target.r_store))
					if(MT.armed)
						for(var/mob/O in viewers(target, null))
							if(O == source)
								O.show_message(text("\red <B>You reach into the [target]'s pockets, but there was a live mousetrap in there!</B>"), 1)
							else
								O.show_message(text("\red <B>[source] reaches into [target]'s pockets and sets off a hidden mousetrap!</B>"), 1)
						target.u_equip(MT)
						if (target.client)
							target.client.screen -= MT
						MT.loc = source.loc
						MT.triggered(source, source.hand ? "l_hand" : "r_hand")
						MT.layer = OBJ_LAYER
						return
				message = text("\red <B>[] is trying to empty []'s pockets!!</B>", source, target)
			if("CPR")
				if (target.cpr_time >= world.time + 3)
					//SN src = null
					del(src)
					return
				message = text("\red <B>[] is trying to perform CPR on []!</B>", source, target)
			if("id")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their ID removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) ID</font>")
				message = text("\red <B>[] is trying to take off [] from []'s uniform!</B>", source, target.wear_id, target)
			if("internal")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their internals toggled by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to toggle [target.name]'s ([target.ckey]) internals</font>")
				if (target.internal)
					message = text("\red <B>[] is trying to remove []'s internals</B>", source, target)
				else
					message = text("\red <B>[] is trying to set on []'s internals.</B>", source, target)
		for(var/mob/M in viewers(target, null))
			M.show_message(message, 1)
	spawn( 40 )
		done()
		return
	return

/*
This proc equips stuff (or does something else) when removing stuff manually from the character window when you click and drag.
It works in conjuction with the process() above.
This proc works for humans only. Aliens stripping humans and the like will all use this proc. Stripping monkeys or somesuch will use their version of this proc.
The first if statement for "mask" and such refers to items that are already equipped and un-equipping them.
The else statement is for equipping stuff to empty slots.
!canremove refers to variable of /obj/item/clothing which either allows or disallows that item to be removed.
It can still be worn/put on as normal.
*/
/obj/effect/equip_e/human/done()
	if(!source || !target)						return
	if(source.loc != s_loc)						return
	if(target.loc != t_loc)						return
	if(LinkBlocked(s_loc,t_loc))				return
	if(item && source.equipped() != item)		return
	if ((source.restrained() || source.stat))	return
	switch(place)
		if("mask")
			if (target.wear_mask)
				if(istype(target.wear_mask, /obj/item/clothing)&& !target.wear_mask:canremove)
					return
				var/obj/item/clothing/W = target.wear_mask
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					if (W)
						W.layer = initial(W.layer)
						W.add_fingerprint(source)
			else
				if(!item) return
				if (istype(item, /obj/item/clothing/mask))
					source.drop_item()
					loc = target
					item.layer = 20
					target.wear_mask = item
					item.loc = target
/*		if("headset")
			if (target.w_radio)
				var/obj/item/W = target.w_radio
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
			else
				if (istype(item, /obj/item/device/radio/headset))
					source.drop_item()
					loc = target
					item.layer = 20
					target.w_radio = item
					item.loc = target*/
		if("gloves")
			if (target.gloves)
				if(istype(target.gloves, /obj/item/clothing)&& !target.gloves:canremove)
					return
				var/obj/item/clothing/W = target.gloves
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
			else
				if(!item) return
				if (istype(item, /obj/item/clothing/gloves))
					source.drop_item()
					loc = target
					item.layer = 20
					target.gloves = item
					item.loc = target
		if("eyes")
			if (target.glasses)
				if(istype(target.glasses, /obj/item/clothing)&& !target.glasses:canremove)
					return
				var/obj/item/W = target.glasses
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
			else
				if(!item) return
				if (istype(item, /obj/item/clothing/glasses))
					source.drop_item()
					loc = target
					item.layer = 20
					target.glasses = item
					item.loc = target
		if("belt")
			if (target.belt)
				var/obj/item/W = target.belt
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
			else
				if(!item) return
				if ((istype(item, /obj) && item.flags & 128 && target.w_uniform))
					source.drop_item()
					loc = target
					item.layer = 20
					target.belt = item
					item.loc = target
		if("s_store")
			if (target.s_store)
				var/obj/item/W = target.s_store
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
			else
				if(!item) return
				if (istype(item, /obj) && target.wear_suit)
					var/confirm
					for(var/i=1, i<=target.wear_suit.allowed.len, i++)
		//				world << "[target.wear_suit.allowed[i]] and [W.type]"
						if (findtext("[item.type]","[target.wear_suit.allowed[i]]") || istype(item, /obj/item/device/pda) || istype(item, /obj/item/weapon/pen))
							confirm = 1
							break
					if (!confirm) return
					else
						source.drop_item()
						loc = target
						item.layer = 20
						target.s_store = item
						item.loc = target
		if("head")
			if (target.head)
				if(istype(target.head, /obj/item/clothing)&& !target.head:canremove)
					return
				var/obj/item/W = target.head
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
			else
				if(!item) return
				if (istype(item, /obj/item/clothing/head))
					source.drop_item()
					loc = target
					item.layer = 20
					target.head = item
					item.loc = target
		if("l_ear")
			if (target.l_ear)
				if(istype(target.l_ear, /obj/item/clothing)&& !target.l_ear:canremove)
					return
				var/obj/item/W = target.l_ear
				target.u_equip(W)

				if(istype(W,/obj/item/clothing/ears/offear))
					W = target.r_ear
				if(istype(W, /obj/item/clothing/ears) && W:twoeared)
					if (target.client)
						target.client.screen -= target.r_ear
					target.u_equip(target.r_ear)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
			else
				if(!item) return
				if (istype(item, /obj/item/clothing/ears) || istype(item, /obj/item/device/radio/headset) || item.w_class == 1)
					source.drop_item()
					if(istype(item, /obj/item/clothing/ears) && item:twoeared && target.r_ear)
						loc = target.loc
					else
						loc = target
						item.layer = 20
						target.l_ear = item
						item.loc = target
						if(istype(item, /obj/item/clothing/ears) && item:twoeared)
							var/obj/item/clothing/ears/offear/O = new(item)
							O.loc = target
							target.equip_if_possible(O, target.slot_ears)
		if("r_ear")
			if (target.r_ear)
				if(istype(target.r_ear, /obj/item/clothing)&& !target.r_ear:canremove)
					return
				var/obj/item/W = target.r_ear
				target.u_equip(W)

				if(istype(W,/obj/item/clothing/ears/offear))
					W = target.l_ear
				if(istype(W, /obj/item/clothing/ears) && W:twoeared)
					if (target.client)
						target.client.screen -= target.r_ear
					target.u_equip(target.l_ear)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
			else
				if(!item) return
				if (istype(item, /obj/item/clothing/ears) || istype(item, /obj/item/device/radio/headset) || item.w_class == 1)
					source.drop_item()
					if(istype(item, /obj/item/clothing/ears) && item:twoeared && target.r_ear)
						loc = target.loc
					else
						loc = target
						item.layer = 20
						target.r_ear = item
						item.loc = target
						if(istype(item, /obj/item/clothing/ears) && item:twoeared)
							var/obj/item/clothing/ears/offear/O = new/obj/item/clothing/ears/offear(item)
							O.loc = target
							target.equip_if_possible(O, target.slot_ears)
		if("shoes")
			if (target.shoes)
				if(istype(target.shoes, /obj/item/clothing)&& !target.shoes:canremove)
					return
				var/obj/item/W = target.shoes
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
			else
				if(!item) return
				if (istype(item, /obj/item/clothing/shoes))
					source.drop_item()
					loc = target
					item.layer = 20
					target.shoes = item
					item.loc = target
		if("l_hand")
			if (istype(target, /obj/item/clothing/suit/straight_jacket))
				//SN src = null
				del(src)
				return
			if (target.l_hand)
				var/obj/item/W = target.l_hand
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
					W.dropped(target)			//dropped sometimes deletes src so put it last
			else
				if(!item) return
				if(istype(item, /obj/item))
					source.drop_item()
					if(item)
						loc = target
						item.layer = 20
						target.l_hand = item
						item.loc = target
						item.add_fingerprint(target)
		if("r_hand")
			if (istype(target, /obj/item/clothing/suit/straight_jacket))
				//SN src = null
				del(src)
				return
			if (target.r_hand)
				var/obj/item/W = target.r_hand
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
					W.dropped(target)			//dropped sometimes deletes src so put it last
			else
				if(!item) return
				if (istype(item, /obj/item))
					source.drop_item()
					loc = target
					if (item)
						item.layer = 20
						target.r_hand = item
						item.loc = target
						item.add_fingerprint(target)
		if("uniform")
			if (target.w_uniform)
				if(istype(target.w_uniform, /obj/item/clothing)&& !target.w_uniform:canremove)
					return
				var/obj/item/W = target.w_uniform
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
				W = target.l_store
				if (W)
					target.u_equip(W)
					if (target.client)
						target.client.screen -= W
					if (W)
						W.loc = target.loc
						W.dropped(target)
						W.layer = initial(W.layer)
				W = target.r_store
				if (W)
					target.u_equip(W)
					if (target.client)
						target.client.screen -= W
					if (W)
						W.loc = target.loc
						W.dropped(target)
						W.layer = initial(W.layer)
				W = target.wear_id
				if (W)
					target.u_equip(W)
					if (target.client)
						target.client.screen -= W
					if (W)
						W.loc = target.loc
						W.dropped(target)
						W.layer = initial(W.layer)
			else
				if(!item) return
				if (istype(item, /obj/item/clothing/under))
					source.drop_item()
					loc = target
					item.layer = 20
					target.w_uniform = item
					item.loc = target
		if("suit")
			if(target.wear_suit)
				var/obj/item/W = target.wear_suit
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
			else
				if(!item) return
				if (istype(item, /obj/item/clothing/suit))
					source.drop_item()
					loc = target
					item.layer = 20
					target.wear_suit = item
					item.loc = target
		if("id")
			if (target.wear_id)
				var/obj/item/W = target.wear_id
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
			else
				if(!item) return
				if (((istype(item, /obj/item/weapon/card/id)||istype(item, /obj/item/device/pda)) && target.w_uniform))
					source.drop_item()
					loc = target
					item.layer = 20
					target.wear_id = item
					item.loc = target
		if("back")
			if (target.back)
				var/obj/item/W = target.back
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
			else
				if(!item) return
				if ((istype(item, /obj/item) && item.flags & 1))
					source.drop_item()
					loc = target
					item.layer = 20
					target.back = item
					item.loc = target
		if("handcuff")
			if (target.handcuffed)
				var/obj/item/W = target.handcuffed
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
			else
				if(!item) return
				if (istype(item, /obj/item/weapon/handcuffs))
					target.drop_from_slot(target.r_hand)
					target.drop_from_slot(target.l_hand)
					source.drop_item()
					target.handcuffed = item
					item.loc = target
		if("CPR")
			if (target.cpr_time + 30 >= world.time)
				//SN src = null
				del(src)
				return
			if ((target.health >= -99.0 && target.stat == 1))
				target.cpr_time = world.time
				var/suff = min(target.getOxyLoss(), 7)
				target.adjustOxyLoss(-suff)
				target.losebreath = 0
				target.updatehealth()
				for(var/mob/O in viewers(source, null))
					O.show_message(text("\red [] performs CPR on []!", source, target), 1)
				target << "\blue <b>You feel a breath of fresh air enter your lungs. It feels good.</b>"
				source << "\red Repeat every 7 seconds AT LEAST."
		if("fuel")
			var/obj/item/weapon/fuel/S = item
			if (!( istype(S, /obj/item/weapon/fuel) ))
				//SN src = null
				del(src)
				return
			if (S.s_time >= world.time + 30)
				//SN src = null
				del(src)
				return
			S.s_time = world.time
			var/a = S.content
			for(var/mob/O in viewers(source, null))
				O.show_message(text("\red [source] forced [target] to eat the [a]!"), 1)
			S.injest(target)
		if("dnainjector")
			var/obj/item/weapon/dnainjector/S = item
			if(item)
				item.add_fingerprint(source)
				item:inject(target, null)
				if (!( istype(S, /obj/item/weapon/dnainjector) ))
					//SN src = null
					del(src)
					return
				if (S.s_time >= world.time + 30)
					//SN src = null
					del(src)
					return
				S.s_time = world.time
				for(var/mob/O in viewers(source, null))
					O.show_message(text("\red [] injects [] with the DNA Injector!", source, target), 1)
		if("pockets")
			if (target.l_store)
				var/obj/item/W = target.l_store
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
			if (target.r_store)
				var/obj/item/W = target.r_store
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
		if("internal")
			if (target.internal)
				target.internal.add_fingerprint(source)
				target.internal = null
				if (target.internals)
					target.internals.icon_state = "internal0"
			else
				if (!( istype(target.wear_mask, /obj/item/clothing/mask) ))
					return
				else
					if (istype(target.back, /obj/item/weapon/tank) && (internalloc == "back" || !internalloc))
						target.internal = target.back
					else if (istype(target.s_store, /obj/item/weapon/tank) && (internalloc == "store" || !internalloc))
						target.internal = target.s_store
					else if (istype(target.belt, /obj/item/weapon/tank) && (internalloc == "belt" || !internalloc))
						target.internal = target.belt
					if (target.internal)
						for(var/mob/M in viewers(target, 1))
							M.show_message(text("[] is now running on internals.", target), 1)
						target.internal.add_fingerprint(source)
						if (target.internals)
							target.internals.icon_state = "internal1"
		else
	if(source)
		source.update_clothing()
		spawn(0)
			if(source.machine == target)
				target.show_inv(source)
	if(target)
		target.update_clothing()
	//SN src = null
	for(var/mob/living/carbon/M in oview(1,target))
		if(M.machine == target)
			target.interact(M)
	del(src)
	return

/mob/living/carbon/human/show_inv(mob/user as mob)
	interact(user)

/mob/living/carbon/human/proc/interact(mob/user as mob)

	user.machine = src
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR>
	<BR><B>Head(Mask):</B> <A href='?src=\ref[src];item=mask'>[(wear_mask ? wear_mask : "Nothing")]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>[(l_hand ? l_hand  : "Nothing")]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>[(r_hand ? r_hand : "Nothing")]</A>
	<BR><B>Gloves:</B> <A href='?src=\ref[src];item=gloves'>[(gloves ? gloves : "Nothing")]</A>
	<BR><B>Eyes:</B> <A href='?src=\ref[src];item=eyes'>[(glasses ? glasses : "Nothing")]</A>
	<BR><B>Left Ear:</B> <A href='?src=\ref[src];item=l_ear'>[(l_ear ? l_ear : "Nothing")]</A>
	<BR><B>Right Ear:</B> <A href='?src=\ref[src];item=r_ear'>[(r_ear ? r_ear : "Nothing")]</A>
	<BR><B>Head:</B> <A href='?src=\ref[src];item=head'>[(head ? head : "Nothing")]</A>
	<BR><B>Shoes:</B> <A href='?src=\ref[src];item=shoes'>[(shoes ? shoes : "Nothing")]</A>
	<BR><B>Belt:</B> <A href='?src=\ref[src];item=belt'>[(belt ? belt : "Nothing")]</A> [(istype(wear_mask, /obj/item/clothing/mask) && istype(belt, /obj/item/weapon/tank) && !( internal )) ? text(" <A href='?src=\ref[];item=internal;loc=belt'>Set Internal</A>", src) : ""]
	<BR><B>Uniform:</B> <A href='?src=\ref[src];item=uniform'>[(w_uniform ? w_uniform : "Nothing")]</A>
	<BR><B>(Exo)Suit:</B> <A href='?src=\ref[src];item=suit'>[(wear_suit ? wear_suit : "Nothing")]</A>
	<BR><B>Back:</B> <A href='?src=\ref[src];item=back'>[(back ? back : "Nothing")]</A>[(istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/weapon/tank) && !( internal )) ? text(" <A href='?src=\ref[];item=internal;loc=back'>Set Internal</A>", src) : ""]
	<BR><B>ID:</B> <A href='?src=\ref[src];item=id'>[(wear_id ? wear_id : "Nothing")]</A>
	<BR><B>Suit Storage:</B> <A href='?src=\ref[src];item=s_store'>[(s_store ? s_store : "Nothing")]</A> [(istype(wear_mask, /obj/item/clothing/mask) && istype(s_store, /obj/item/weapon/tank) && !( internal )) ? text(" <A href='?src=\ref[];item=internal;loc=store'>Set Internal</A>", src) : ""]
	<BR>[(handcuffed ? text("<A href='?src=\ref[src];item=handcuff'>Handcuffed</A>") : text("<A href='?src=\ref[src];item=handcuff'>Not Handcuffed</A>"))]
	<BR>[(internal ? text("<A href='?src=\ref[src];item=internal'>Remove Internal</A>") : "")]
	<BR><A href='?src=\ref[src];item=pockets'>Empty Pockets</A>
	<BR><A href='?src=\ref[user];refresh=1'>Refresh</A>
	<BR><A href='?src=\ref[user];mach_close=mob[name]'>Close</A>
	<BR>"}
	user << browse(dat, text("window=mob[name];size=340x480"))
	onclose(user, "mob[name]")
	return

// called when something steps onto a human
// this could be made more general, but for now just handle mulebot
/mob/living/carbon/human/HasEntered(var/atom/movable/AM)
	var/obj/machinery/bot/mulebot/MB = AM
	if(istype(MB))
		MB.RunOver(src)

//gets assignment from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_assignment(var/if_no_id = "No id", var/if_no_job = "No job")
	var/obj/item/device/pda/pda = wear_id
	var/obj/item/weapon/card/id/id = wear_id
	if (istype(pda))
		if (pda.id && istype(pda.id, /obj/item/weapon/card/id))
			. = pda.id.assignment
		else
			. = pda.ownjob
	else if (istype(id))
		. = id.assignment
	else
		return if_no_id
	if (!.)
		. = if_no_job
	return

//gets name from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_authentification_name(var/if_no_id = "Unknown")
	var/obj/item/device/pda/pda = wear_id
	var/obj/item/weapon/card/id/id = wear_id
	if (istype(pda))
		if (pda.id)
			. = pda.id.registered_name
		else
			. = pda.owner
	else if (istype(id))
		. = id.registered_name
	else
		return if_no_id
	return

//repurposed proc. Now it combines get_id_name() and get_face_name() to determine a mob's name variable. Made into a seperate proc as it'll be useful elsewhere
/mob/living/carbon/human/proc/get_visible_name()
	if ((wear_mask && !(wear_mask.see_face)) || (head && !(head.see_face))) // can't see their face
		return get_id_name("Unknown")
	else
		var/face_name = get_face_name()
		var/id_name = get_id_name("")
		if(id_name && (id_name != face_name))
			return "[face_name] as ([id_name])"
		return face_name

//Returns "Unknown" if facially disfigured and real_name if not. Useful for setting name when polyacided or when updating a human's name variable
/mob/living/carbon/human/proc/get_face_name()
	var/datum/organ/external/head/head = get_organ("head")
	if(!head || head.disfigured)	//no face!
		return "Unknown"
	else
		return "[real_name]"

//gets name from ID or PDA itself, ID inside PDA doesn't matter
//Useful when player is being seen by other mobs
/mob/living/carbon/human/proc/get_id_name(var/if_no_id = "Unknown")
	var/obj/item/device/pda/pda = wear_id
	var/obj/item/weapon/card/id/id = wear_id
	if(istype(pda))		return pda.owner
	if(istype(id))		return id.registered_name
	return if_no_id

//gets ID card object from special clothes slot or null.
/mob/living/carbon/human/proc/get_idcard()
	var/obj/item/weapon/card/id/id = wear_id
	var/obj/item/device/pda/pda = wear_id
	if (istype(pda) && pda.id)
		id = pda.id
	if (istype(id))
		return id

//Added a safety check in case you want to shock a human mob directly through electrocute_act.
/mob/living/carbon/human/electrocute_act(var/shock_damage, var/obj/source, var/siemens_coeff = 1.0, var/safety = 0)
	if(!safety)
		if(gloves)
			var/obj/item/clothing/gloves/G = gloves
			siemens_coeff = G.siemens_coefficient
	return ..(shock_damage,source,siemens_coeff)


/mob/living/carbon/human/proc/get_damaged_organs(var/brute, var/burn)
	var/list/datum/organ/external/parts = list()
	for(var/name in organs)
		var/datum/organ/external/organ = organs[name]
		if((brute && organ.brute_dam) || (burn && organ.burn_dam))
			parts += organ
	return parts

/mob/living/carbon/human/proc/get_damageable_organs()
	var/list/datum/organ/external/parts = list()
	for(var/name in organs)
		var/datum/organ/external/organ = organs[name]
		if(organ.brute_dam + organ.burn_dam < organ.max_damage)
			parts += organ
	return parts

// heal ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/carbon/human/heal_organ_damage(var/brute, var/burn)
	var/list/datum/organ/external/parts = get_damaged_organs(brute,burn)
	if(!parts.len)
		return
	var/datum/organ/external/picked = pick(parts)
	picked.heal_damage(brute,burn)
	updatehealth()
	UpdateDamageIcon()

// damage ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/carbon/human/take_organ_damage(var/brute, var/burn)
	var/list/datum/organ/external/parts = get_damageable_organs()
	if(!parts.len)
		return
	var/datum/organ/external/picked = pick(parts)
	picked.take_damage(brute,burn)
	updatehealth()
	UpdateDamageIcon()

// heal MANY external organs, in random order
/mob/living/carbon/human/heal_overall_damage(var/brute, var/burn)
	var/list/datum/organ/external/parts = get_damaged_organs(brute,burn)

	while(parts.len && (brute>0 || burn>0) )
		var/datum/organ/external/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam

		picked.heal_damage(brute,burn)

		brute -= (brute_was-picked.brute_dam)
		burn -= (burn_was-picked.burn_dam)

		parts -= picked
	updatehealth()
	UpdateDamageIcon()

// damage MANY external organs, in random order
/mob/living/carbon/human/take_overall_damage(var/brute, var/burn, var/used_weapon = null)
	var/list/datum/organ/external/parts = get_damageable_organs()

	while(parts.len && (brute>0 || burn>0) )
		var/datum/organ/external/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam

		picked.take_damage(brute,burn, 0, used_weapon)

		brute -= (picked.brute_dam-brute_was)
		burn -= (picked.burn_dam-burn_was)

		parts -= picked
	updatehealth()
	UpdateDamageIcon()

/mob/living/carbon/human/Topic(href, href_list)
	if (href_list["refresh"])
		if((machine)&&(in_range(src, usr)))
			show_inv(machine)

	if (href_list["mach_close"])
		var/t1 = text("window=[]", href_list["mach_close"])
		machine = null
		src << browse(null, t1)

	if ((href_list["item"] && !( usr.stat ) && usr.canmove && !( usr.restrained() ) && in_range(src, usr) && ticker)) //if game hasn't started, can't make an equip_e
		var/obj/effect/equip_e/human/O = new /obj/effect/equip_e/human(  )
		O.source = usr
		O.target = src
		O.item = usr.equipped()
		O.s_loc = usr.loc
		O.t_loc = loc
		O.place = href_list["item"]
		if(href_list["loc"])
			O.internalloc = href_list["loc"]
		requests += O
		spawn( 0 )
			O.process()
			return

	if (href_list["criminal"])
		if(istype(usr, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = usr
			if(istype(H.glasses, /obj/item/clothing/glasses/hud/security) || istype(H.glasses, /obj/item/clothing/glasses/sunglasses/sechud))
				var/perpname = "wot"
				var/modified = 0

				if(wear_id)
					if(istype(wear_id,/obj/item/weapon/card/id))
						perpname = wear_id:registered_name
					else if(istype(wear_id,/obj/item/device/pda))
						var/obj/item/device/pda/tempPda = wear_id
						perpname = tempPda.owner
				else
					perpname = src.name

				for (var/datum/data/record/E in data_core.general)
					if (E.fields["name"] == perpname)
						for (var/datum/data/record/R in data_core.security)
							if (R.fields["id"] == E.fields["id"])

								var/setcriminal = input(usr, "Specify a new criminal status for this person.", "Security HUD", R.fields["criminal"]) in list("None", "*Arrest*", "Incarcerated", "Parolled", "Released", "Cancel")

								if(istype(H.glasses, /obj/item/clothing/glasses/hud/security) || istype(H.glasses, /obj/item/clothing/glasses/sunglasses/sechud))
									if(setcriminal != "Cancel")
										R.fields["criminal"] = setcriminal
										modified = 1

										spawn()
											H.handle_regular_hud_updates()

				if(!modified)
					usr << "\red Unable to locate a data core entry for this person."
	..()
	return


///eyecheck()
///Returns a number between -1 to 2
/mob/living/carbon/human/eyecheck()
	var/number = 0
	if(istype(src.head, /obj/item/clothing/head/helmet/welding))
		if(!src.head:up)
			number += 2
	if(istype(src.head, /obj/item/clothing/head/helmet/space))
		number += 2
	if(istype(src.glasses, /obj/item/clothing/glasses/sunglasses))
		number += 1
	if(istype(src.glasses, /obj/item/clothing/glasses/thermal))
		number -= 1
	return number


/mob/living/carbon/human/IsAdvancedToolUser()
	return 1//Humans can use guns and such


/mob/living/carbon/human/updatehealth()
	if(src.nodamage)
		src.health = 100
		src.stat = 0
		return
	src.health = 100 - src.getOxyLoss() - src.getToxLoss() - src.getFireLoss() - src.getBruteLoss() - src.getCloneLoss() -src.halloss
	if(getFireLoss() > (100 - config.health_threshold_dead) && stat == DEAD) //100 only being used as the magic human max health number, feel free to change it if you add a var for it -- Urist
		ChangeToHusk()
	return

/mob/living/carbon/human/abiotic(var/full_body = 0)
	if(full_body && ((src.l_hand && !( src.l_hand.abstract )) || (src.r_hand && !( src.r_hand.abstract )) || (src.back || src.wear_mask)))
		return 1

	if((src.l_hand && !( src.l_hand.abstract )) || (src.r_hand && !( src.r_hand.abstract )))
		return 1

	return 0

/mob/living/carbon/human/abiotic2(var/full_body2 = 0)
	if(full_body2 && ((src.l_hand && !( src.l_hand.abstract )) || (src.r_hand && !( src.r_hand.abstract )) || (src.back || src.wear_mask || src.head || src.shoes || src.w_uniform || src.wear_suit || src.glasses || src.l_ear || src.r_ear || src.gloves || src.handcuffed)))
		return 1

	if((src.l_hand && !( src.l_hand.abstract )) || (src.r_hand && !( src.r_hand.abstract )) || (src.back || src.wear_mask || src.head || src.shoes || src.w_uniform || src.wear_suit || src.glasses || src.l_ear || src.r_ear || src.gloves || src.handcuffed))
		return 1

	return 0

/mob/living/carbon/human/getBruteLoss()
	var/amount = 0.0
	for(var/name in organs)
		var/datum/organ/external/O = organs[name]
		if(!O.robot) amount+= O.brute_dam
	return amount

/mob/living/carbon/human/adjustBruteLoss(var/amount, var/used_weapon = null)
	if(amount > 0)
		take_overall_damage(amount, 0, used_weapon)
	else
		heal_overall_damage(-amount, 0)

/mob/living/carbon/human/getFireLoss()
	var/amount = 0.0
	for(var/name in organs)
		var/datum/organ/external/O = organs[name]
		if(!O.robot) amount+= O.burn_dam
	return amount

/mob/living/carbon/human/adjustFireLoss(var/amount,var/used_weapon = null)
	if(amount > 0)
		take_overall_damage(0, amount, used_weapon)
	else
		heal_overall_damage(0, -amount)

/mob/living/carbon/human/Stun(amount)
	if(mutations & HULK)
		return
	..()

/mob/living/carbon/human/Weaken(amount)
	if(mutations & HULK)
		return
	..()

/mob/living/carbon/human/Paralyse(amount)
	if(mutations & HULK)
		return
	..()

/mob/living/carbon/human/proc/morph()
	set name = "Morph"
	set category = "Superpower"
	if(!(src.mutations & mMorph))
		src.verbs -= /mob/living/carbon/human/proc/morph
		return

	var/new_facial = input("Please select facial hair color.", "Character Generation") as color
	if(new_facial)
		r_facial = hex2num(copytext(new_facial, 2, 4))
		g_facial = hex2num(copytext(new_facial, 4, 6))
		b_facial = hex2num(copytext(new_facial, 6, 8))

	var/new_hair = input("Please select hair color.", "Character Generation") as color
	if(new_facial)
		r_hair = hex2num(copytext(new_hair, 2, 4))
		g_hair = hex2num(copytext(new_hair, 4, 6))
		b_hair = hex2num(copytext(new_hair, 6, 8))

	var/new_eyes = input("Please select eye color.", "Character Generation") as color
	if(new_eyes)
		r_eyes = hex2num(copytext(new_eyes, 2, 4))
		g_eyes = hex2num(copytext(new_eyes, 4, 6))
		b_eyes = hex2num(copytext(new_eyes, 6, 8))

	var/new_tone = input("Please select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", "Character Generation")  as text

	if (!new_tone)
		new_tone = 35
	s_tone = max(min(round(text2num(new_tone)), 220), 1)
	s_tone =  -s_tone + 35

	// hair
	var/list/all_hairs = typesof(/datum/sprite_accessory/hair) - /datum/sprite_accessory/hair
	var/list/hairs = list()

	// loop through potential hairs
	for(var/x in all_hairs)
		var/datum/sprite_accessory/hair/H = new x // create new hair datum based on type x
		hairs.Add(H.name) // add hair name to hairs
		del(H) // delete the hair after it's all done

	var/new_style = input("Please select hair style", "Character Generation")  as null|anything in hairs

	// if new style selected (not cancel)
	if (new_style)
		h_style = new_style

		for(var/x in all_hairs) // loop through all_hairs again. Might be slightly CPU expensive, but not significantly.
			var/datum/sprite_accessory/hair/H = new x // create new hair datum
			if(H.name == new_style)
				hair_style = H // assign the hair_style variable a new hair datum
				break
			else
				del(H) // if hair H not used, delete. BYOND can garbage collect, but better safe than sorry

	// facial hair
	var/list/all_fhairs = typesof(/datum/sprite_accessory/facial_hair) - /datum/sprite_accessory/facial_hair
	var/list/fhairs = list()

	for(var/x in all_fhairs)
		var/datum/sprite_accessory/facial_hair/H = new x
		fhairs.Add(H.name)
		del(H)

	new_style = input("Please select facial style", "Character Generation")  as null|anything in fhairs

	if(new_style)
		f_style = new_style
		for(var/x in all_fhairs)
			var/datum/sprite_accessory/facial_hair/H = new x
			if(H.name == new_style)
				facial_hair_style = H
				break
			else
				del(H)

	var/new_gender = alert(usr, "Please select gender.", "Character Generation", "Male", "Female")
	if (new_gender)
		if(new_gender == "Male")
			gender = MALE
		else
			gender = FEMALE
	rebuild_appearance()
	check_dna()

	for(var/mob/M in view())
		M.show_message("[src.name] just morphed!")

/mob/living/carbon/human/proc/remotesay()
	set name = "Project mind"
	set category = "Superpower"
	if(!(src.mutations & mRemotetalk))
		src.verbs -= /mob/living/carbon/human/proc/remotesay
		return
	var/list/creatures = list()
	for(var/mob/living/carbon/h in world)
		creatures += h
	var/mob/target = input ("Who do you want to project your mind to ?") as mob in creatures

	var/say = input ("What do you wish to say")
	if(target.mutations & mRemotetalk)
		target.show_message("\blue You hear [src.real_name]'s voice: [say]")
	else
		target.show_message("\blue You hear a voice that seems to echo around the room: [say]")
	usr.show_message("\blue You project your mind into [target.real_name]: [say]")
	for(var/mob/dead/observer/G in world)
		G.show_message("<i>Telepathic message from <b>[src]</b> to <b>[target]</b>: [say]</i>")
/mob/living/carbon/human
	var/mob/remoteobserve

/mob/living/carbon/human/proc/remoteobserve()
	set name = "Remote View"
	set category = "Superpower"

	if(!(src.mutations & mRemote))
		reset_view(0)
		remoteobserve = null
		src.verbs -= /mob/living/carbon/human/proc/remoteobserve
		src.tkdisable = 0
		return

	if(client.eye != client.mob)
		reset_view(0)
		remoteobserve = null
		src.tkdisable = 0
		return

	var/list/mob/creatures = list()

	for(var/mob/living/carbon/h in world)
		var/turf/temp_turf = get_turf(h)
		if(temp_turf.z != 1 && temp_turf.z != 5) //Not on mining or the station.
			continue
		creatures += h

	var/mob/target = input ("Who do you want to project your mind to ?") as mob in creatures

	if (target)
		reset_view(target)
		remoteobserve = target
		src.tkdisable = 1
	else
		reset_view(0)
		remoteobserve = null
		src.tkdisable = 0

/mob/living/carbon/human/get_visible_gender()
	var/skip_gender = (wear_suit && wear_suit.flags_inv & HIDEJUMPSUIT && ((head && head.flags_inv & HIDEMASK) || wear_mask))

	if( !skip_gender ) //big suits/masks make it hard to tell their gender
		switch(gender)
			if(MALE)
				return list("It" = "He", "its" = "his", "it" = "he", "has" = "has", "is" = "is", "itself" = "himself")
			if(FEMALE)
				return list("It" = "She", "its" = "her", "it" = "she", "has" = "has", "is" = "is", "itself" = "herself")
	return list("It" = "They", "its" = "their", "it" = "them", "has" = "have", "is" = "are", "itself" = "themselves")
