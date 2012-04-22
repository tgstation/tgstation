/atom/proc/MouseDrop_T()
	return

/atom/proc/attack_hand(mob/user as mob)
	if(ishuman(user) || ismonkey(user))
		if (user.hand)
			var/datum/organ/external/temp = user:organs["l_hand"]
			if(temp.destroyed)
				user << "\red Yo- wait a minute."
				return
		else
			var/datum/organ/external/temp = user:organs["r_hand"]
			if(temp.destroyed)
				user << "\red Yo- wait a minute."
				return
	return

/atom/proc/attack_paw(mob/user as mob)
	return

/atom/proc/attack_ai(mob/user as mob)
	return

/atom/proc/attack_robot(mob/user as mob)
	attack_ai(user)
	return

/atom/proc/attack_animal(mob/user as mob)
	return

/atom/proc/attack_ghost(mob/user as mob)
	src.examine()
	return

/atom/proc/attack_admin(mob/user as mob)
	if(!user || !user.client || !user.client.holder)
		return
	attack_hand(user)

//for aliens, it works the same as monkeys except for alien-> mob interactions which will be defined in the
//appropiate mob files
/atom/proc/attack_alien(mob/user as mob)
	src.attack_paw(user)
	return


// for metroids
/atom/proc/attack_metroid(mob/user as mob)
	return

/atom/proc/hand_h(mob/user as mob)			//human (hand) - restrained
	return

/atom/proc/hand_p(mob/user as mob)			//monkey (paw) - restrained
	return

/atom/proc/hand_a(mob/user as mob)			//AI - restrained
	return

/atom/proc/hand_r(mob/user as mob)			//Cyborg (robot) - restrained
	src.hand_a(user)
	return

/atom/proc/hand_al(mob/user as mob)			//alien - restrained
	src.hand_p(user)
	return

/atom/proc/hand_m(mob/user as mob)			//metroid - restrained
	return


/atom/proc/hitby(atom/movable/AM as mob|obj)
	return

/atom/proc/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/device/detective_scanner))
		for(var/mob/O in viewers(src, null))
			if ((O.client && !( O.blinded )))
				O << text("\red [src] has been scanned by [user] with the [W]")
	else
		if (!( istype(W, /obj/item/weapon/grab) ) && !(istype(W, /obj/item/weapon/plastique)) &&!(istype(W, /obj/item/weapon/cleaner)) &&!(istype(W, /obj/item/weapon/chemsprayer)) &&!(istype(W, /obj/item/weapon/pepperspray)) && !(istype(W, /obj/item/weapon/plantbgone)) )
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O << text("\red <B>[] has been hit by [] with []</B>", src, user, W)
	return

/atom/proc/add_hiddenprint(mob/living/M as mob)
	if(isnull(M)) return
	if(isnull(M.key)) return
	if (!( src.flags ) & 256)
		return
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		if (!istype(H.dna, /datum/dna))
			return 0
		if (H.gloves)
			if(src.fingerprintslast != H.key)
				src.fingerprintshidden += text("\[[time_stamp()]\] (Wearing gloves). Real name: [], Key: []",H.real_name, H.key)
				src.fingerprintslast = H.key
			return 0
		if (!( src.fingerprints ))
			if(src.fingerprintslast != H.key)
				src.fingerprintshidden += text("\[[time_stamp()]\] Real name: [], Key: []",H.real_name, H.key)
				src.fingerprintslast = H.key
			return 1
	else
		if(src.fingerprintslast != M.key)
			src.fingerprintshidden += text("\[[time_stamp()]\] Real name: [], Key: []",M.real_name, M.key)
			src.fingerprintslast = M.key
	return

/atom/proc/add_fingerprint(mob/living/M as mob)
	if(isnull(M)) return
	if(isnull(M.key)) return
	if (!( flags ) & 256)
		return
	if (ishuman(M))
		if(!fingerprintshidden)
			fingerprintshidden = list()
		add_fibers(M)
		if (M.mutations2 & mFingerprints)
			if(fingerprintslast != M.key)
				fingerprintshidden += "(Has no fingerprints) Real name: [M.real_name], Key: [M.key]"
				fingerprintslast = M.key
			return 0
		var/mob/living/carbon/human/H = M
		if (!istype(H.dna, /datum/dna) || !H.dna.uni_identity || (length(H.dna.uni_identity) != 32))
			if(!istype(H.dna, /datum/dna))
				H.dna = new /datum/dna(null)
			H.check_dna()
		if (H.gloves && H.gloves != src)
			if(fingerprintslast != H.key)
				fingerprintshidden += text("(Wearing gloves). Real name: [], Key: []",H.real_name, H.key)
				fingerprintslast = H.key
			H.gloves.add_fingerprint(M)
		if(H.gloves != src)
			if(prob(75) && istype(H.gloves, /obj/item/clothing/gloves/latex))
				return 0
			else if(H.gloves && !istype(H.gloves, /obj/item/clothing/gloves/latex))
				return 0
		if(fingerprintslast != H.key)
			fingerprintshidden += text("Real name: [], Key: []",H.real_name, H.key)
			fingerprintslast = H.key
		if(!fingerprints)
			fingerprints = list()
		var/new_prints = 0
		var/prints
		for(var/i = 1, i <= fingerprints.len, i++)
			var/list/L = params2list(fingerprints[i])
			if(L[num2text(1)] == md5(H.dna.uni_identity))
				new_prints = i
				prints = L[num2text(2)]
				break
			else
				var/test_print = stars(L[num2text(2)], rand(80,90))
				if(stringpercent(test_print) == 32)
					if(fingerprints.len == 1)
						fingerprints = list()
					else
						fingerprints.Cut(i,i+1)
				else
					fingerprints[i] = "1=[L[num2text(1)]]&2=[test_print]"
		if(new_prints)
			fingerprints[new_prints] = text("1=[]&2=[]", md5(H.dna.uni_identity), stringmerge(prints,stars(md5(H.dna.uni_identity), (H.gloves ? rand(10,20) : rand(25,40)))))
		else
			if(!fingerprints || !fingerprints.len)
				fingerprints = list(text("1=[]&2=[]", md5(H.dna.uni_identity), stars(md5(H.dna.uni_identity), H.gloves ? rand(10,20) : rand(25,40))))
			else
				fingerprints += text("1=[]&2=[]", md5(H.dna.uni_identity), stars(md5(H.dna.uni_identity), H.gloves ? rand(10,20) : rand(25,40)))
		for(var/i = 1, i <= fingerprints.len, i++)
			if(length(fingerprints[i]) != 69)
				fingerprints.Remove(fingerprints[i])
		if(fingerprints && !fingerprints.len)	del(fingerprints)
		return 1
	else
		if(fingerprintslast != M.key)
			fingerprintshidden += text("Real name: [], Key: []",M.real_name, M.key)
			fingerprintslast = M.key
	return

//returns 1 if made bloody, returns 0 otherwise
/atom/proc/add_blood(mob/living/carbon/human/M as mob)
	if (!( istype(M, /mob/living/carbon/human) ))
		return 0
	if (!istype(M.dna, /datum/dna))
		M.dna = new /datum/dna(null)
	M.check_dna()
	if (!( src.flags ) & 256)
		return 0
	if(!blood_DNA || !istype(blood_DNA, /list))	//if our list of DNA doesn't exist yet (or isn't a list) initialise it.
		blood_DNA = list()

	//adding blood to items
	if (istype(src, /obj/item)&&!istype(src, /obj/item/weapon/melee/energy))//Only regular items. Energy melee weapon are not affected.
		var/obj/item/O = src

		//if we haven't made our blood_overlay already
		if( !O.blood_overlay )
			var/icon/I = new /icon(O.icon, O.icon_state)
			I.Blend(new /icon('blood.dmi', rgb(255,255,255)),ICON_ADD) //fills the icon_state with white (except where it's transparent)
			I.Blend(new /icon('blood.dmi', "itemblood"),ICON_MULTIPLY) //adds blood and the remaining white areas become transparant

			//not sure if this is worth it. It attaches the blood_overlay to every item of the same type if they don't have one already made.
			for(var/obj/item/A in world)
				if(A.type == O.type && !A.blood_overlay)
					A.blood_overlay = I

		//apply the blood-splatter overlay if it isn't already in there
		if(!blood_DNA.len)
			O.overlays += O.blood_overlay

		//if this blood isn't already in the list, add it
		for(var/i = 1, i <= O.blood_DNA.len, i++)
			if((O.blood_DNA[i][1] == M.dna.unique_enzymes) && (O.blood_DNA[i][2] == M.dna.b_type))
				return 0 //already bloodied with this blood. Cannot add more.
		O.blood_DNA.len++
		O.blood_DNA[O.blood_DNA.len] = list(M.dna.unique_enzymes,M.dna.b_type)
		return 1 //we applied blood to the item

	//adding blood to turfs
	else if (istype(src, /turf/simulated))
		var/turf/simulated/T = src

		//get one blood decal and infect it with virus from M.viruses
		for(var/obj/effect/decal/cleanable/blood/B in T.contents)
			B.blood_DNA.len++
			B.blood_DNA[B.blood_DNA.len] = list(M.dna.unique_enzymes,M.dna.b_type)
			B.virus2 += M.virus2
			for(var/datum/disease/D in M.viruses)
				var/datum/disease/newDisease = new D.type
				B.viruses += newDisease
				newDisease.holder = B
			return 1 //we bloodied the floor

		//if there isn't a blood decal already, make one.
		var/obj/effect/decal/cleanable/blood/newblood = new /obj/effect/decal/cleanable/blood(T)
		newblood.blood_DNA =  list(list(M.dna.unique_enzymes, M.dna.b_type))
		newblood.blood_owner = M
		newblood.virus2 = M.virus2
		for(var/datum/disease/D in M.viruses)
			var/datum/disease/newDisease = new D.type
			newblood.viruses += newDisease
			newDisease.holder = newblood
		return 1 //we bloodied the floor

	//adding blood to humans
	else if (istype(src, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		//if this blood isn't already in the list, add it
		for(var/i = 1, i <= H.blood_DNA.len, i++)
			if((H.blood_DNA[i][1] == M.dna.unique_enzymes) && (H.blood_DNA[i][2] == M.dna.b_type))
				return 0 //already bloodied with this blood. Cannot add more.
		H.blood_DNA.len++
		H.blood_DNA[H.blood_DNA.len] = list(M.dna.unique_enzymes,M.dna.b_type)
		return 1 //we applied blood to the item
	return

/atom/proc/add_vomit_floor(mob/living/carbon/M as mob, var/toxvomit = 0)
	if( istype(src, /turf/simulated) )
		var/obj/effect/decal/cleanable/vomit/this = new /obj/effect/decal/cleanable/vomit(src)

		// Make toxins vomit look different
		if(toxvomit)
			this.icon_state = "vomittox_[pick(1,4)]"

		for(var/datum/disease/D in M.viruses)
			var/datum/disease/newDisease = new D.type
			this.viruses += newDisease
			newDisease.holder = this

// Only adds blood on the floor -- Skie
/atom/proc/add_blood_floor(mob/living/carbon/M as mob)
	if( istype(M, /mob/living/carbon/monkey) )
		if( istype(src, /turf/simulated) )
			var/turf/simulated/source1 = src
			var/obj/effect/decal/cleanable/blood/this = new /obj/effect/decal/cleanable/blood(source1)
			this.blood_DNA = list(M.dna.unique_enzymes, M.dna.b_type)
			this.OriginalMob = M.dna.original_name
			for(var/datum/disease/D in M.viruses)
				var/datum/disease/newDisease = new D.type
				this.viruses += newDisease
				newDisease.holder = this

	else if( istype(M, /mob/living/carbon/alien ))
		if( istype(src, /turf/simulated) )
			var/turf/simulated/source2 = src
			var/obj/effect/decal/cleanable/xenoblood/this = new /obj/effect/decal/cleanable/xenoblood(source2)
			this.blood_DNA = list(list("UNKNOWN BLOOD","X*"))
			for(var/datum/disease/D in M.viruses)
				var/datum/disease/newDisease = new D.type
				this.viruses += newDisease
				newDisease.holder = this

	else if( istype(M, /mob/living/silicon/robot ))
		if( istype(src, /turf/simulated) )
			var/turf/simulated/source2 = src
			var/obj/effect/decal/cleanable/oil/this = new /obj/effect/decal/cleanable/oil(source2)
			for(var/datum/disease/D in M.viruses)
				var/datum/disease/newDisease = new D.type
				this.viruses += newDisease
				newDisease.holder = this



/atom/proc/clean_blood()

	if (!( src.flags ) & 256)
		return
	if ( src.blood_DNA )

		//Cleaning blood off of mobs
		if (istype (src, /mob/living/carbon))
			var/mob/living/carbon/M = src
			del(M.blood_DNA)
			if(ishuman(src))
				var/mob/living/carbon/human/H = src
				H.bloody_hands = 0

		//Cleaning blood off of items
		else if (istype (src, /obj/item))
			var/obj/item/O = src
			del(O.blood_DNA)
			if(O.blood_overlay)
				O.overlays.Remove(O.blood_overlay)

			if(istype(src, /obj/item/clothing/gloves))
				var/obj/item/clothing/gloves/G = src
				G.transfer_blood = 0

		//Cleaning blood off of turfs
		else if (istype(src, /turf/simulated))
			var/turf/simulated/T = src
			del(T.blood_DNA)
			if(T.icon_old)
				var/icon/I = new /icon(T.icon_old, T.icon_state)
				T.icon = I
			else
				T.icon = initial(icon)

	if(blood_DNA && !blood_DNA.len)
		del(blood_DNA)
	if(src.fingerprints && src.fingerprints.len)
		var/done = 0
		while(!done)
			done = 1
			for(var/i = 1, i < (src.fingerprints.len + 1), i++)
				var/list/prints = params2list(src.fingerprints[i])
				var/test_print = prints["2"]
				var/new_print = stars(test_print, rand(1,20))
				if(stringpercent(new_print) == 32)
					if(src.fingerprints.len == 1)
						src.fingerprints = list()
					else
						for(var/j = (i + 1), j < (src.fingerprints.len), j++)
							src.fingerprints[j-1] = src.fingerprints[j]
						src.fingerprints.len--
						done = 0
					break
				else
					src.fingerprints[i] = "1=" + prints["1"] + "&2=" + new_print
	if(fingerprints && !fingerprints.len)
		del(fingerprints)
	if(istype(src, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = src
		M.update_clothing()
	return

/atom/MouseDrop(atom/over_object as mob|obj|turf|area)
	spawn( 0 )
		if (istype(over_object, /atom))
			over_object.MouseDrop_T(src, usr)
		return
	..()
	return

/atom/Click(location,control,params)
	//world << "atom.Click() on [src] by [usr] : src.type is [src.type]"
	if(!istype(src,/obj/item/weapon/gun))
		usr.last_target_click = world.time
	if(usr.client.buildmode)
		build_click(usr, usr.client.buildmode, location, control, params, src)
		return

	if(using_new_click_proc)  //TODO ERRORAGE (see message below)
		return DblClickNew()
	return DblClick(location, control, params)

var/using_new_click_proc = 0 //TODO ERRORAGE (This is temporary, while the DblClickNew() proc is being tested)

/atom/proc/DblClickNew()

// TODO DOOHL: Intergrate params to new proc. Saved for another time because var/valid_place is a fucking brainfuck

	//Spamclick server-overloading prevention delay... THING
	if (world.time <= usr:lastDblClick+1)
		return
	else
		usr:lastDblClick = world.time

	//paralysis and critical condition
	if(usr.stat == 1)	//Death is handled in attack_ghost()
		return

	if(!istype(usr, /mob/living/silicon/ai))
		if (usr.paralysis || usr.stunned || usr.weakened)
			return

	//handle the hud separately
	if(istype(src,/obj/screen))
		if( usr.restrained() )
			if(ishuman(usr))
				src.attack_hand(usr)
			else if(isAI(usr))
				src.attack_ai(usr)
			else if(isrobot(usr))
				src.attack_ai(usr)
			else if(isobserver(usr))
				src.attack_ghost(usr)
			else if(ismonkey(usr))
				src.attack_paw(usr)
			else if(isalienadult(usr))
				src.attack_alien(usr)
			else if(ismetroid(usr))
				src.attack_metroid(usr)
			else if(isanimal(usr))
				src.attack_animal(usr)
			else
				usr << "This mob type does not support clicks to the HUD. Contact a coder."
		else
			if(ishuman(usr))
				src.hand_h(usr, usr.hand)
			else if(isAI(usr))
				src.hand_a(usr, usr.hand)
			else if(isrobot(usr))
				src.hand_a(usr, usr.hand)
			else if(isobserver(usr))
				return
			else if(ismonkey(usr))
				src.hand_p(usr, usr.hand)
			else if(isalienadult(usr))
				src.hand_al(usr, usr.hand)
			else if(ismetroid(usr))
				return
			else if(isanimal(usr))
				return
			else
				usr << "This mob type does not support restrained clicks to the HUD. Contact a coder."
		return

	//Gets equipped item or used module of robots
	var/obj/item/W = usr.equipped()

	//Attack self
	if (W == src && usr.stat == 0)
		spawn (0)
			W.attack_self(usr)
		return

	//Attackby, attack_hand, afterattack, etc. can only be done once every 1 second, unless an object has the NODELAY or USEDELAY flags set
	//This segment of code determins this.
	if(W)
		if( !( (src.loc && src.loc == usr) || (src.loc.loc && src.loc.loc == usr) ) )
			//The check above checks that you are not targeting an item which you are holding.
			//If you are, (example clicking a backpack), the delays are ignored.
			if(W.flags & USEDELAY)
				//Objects that use the USEDELAY flag can only attack once every 2 seconds
				if (usr.next_move < world.time)
					usr.prev_move = usr.next_move
					usr.next_move = world.time + 20
				else
					return	//A click has recently been handled already, you need to wait until the anti-spam delay between clicks passes
			else if(!(W.flags & NODELAY))
				//Objects with NODELAY don't have a delay between uses, while most objects have the standard 1 second delay.
				if (usr.next_move < world.time)
					usr.prev_move = usr.next_move
					usr.next_move = world.time + 10
				else
					return	//A click has recently been handled already, you need to wait until the anti-spam delay between clicks passes
	else
		//Empty hand
		if (usr.next_move < world.time)
			usr.prev_move = usr.next_move
			usr.next_move = world.time + 10
		else
			return	//A click has recently been handled already, you need to wait until the anti-spam delay between clicks passes

	//Is the object in a valid place?
	var/valid_place = 0
	if ( isturf(src) || ( src.loc && isturf(src.loc) ) || ( src.loc.loc && isturf(src.loc.loc) ) )
		//Object is either a turf of placed on a turf, thus valid.
		//The third one is that it is in a container, which is on a turf, like a box,
		//which you mouse-drag opened. Also a valid location.
		valid_place = 1

	if ( ( src.loc && (src.loc == usr) ) || ( src.loc.loc && (src.loc.loc == usr) ) )
		//User has the object on them (in their inventory) and it is thus valid
		valid_place = 1

	//Afterattack gets performed every time you click, no matter if it's in range or not. It's used when
	//clicking targets for guns and such. If you are clicking on a target that's not in range
	//with an item in your hands only afterattack() needs to be performed.
	//If the range is valid, afterattack() will be handled in the separate mob-type
	//sections below, however only after attackby(). Attack_hand and simmilar procs are handled
	//in the mob-type sections below, as some require you to be in range to work (human, monkey..) while others don't (ai, cyborg)
	//Also note that afterattack does not differentiate between the holder/attacker's mob-type.
	if( W && !valid_place)
		W.afterattack(src, usr, (valid_place ? 1 : 0))
		return

	if(ishuman(usr))
		var/mob/living/carbon/human/human = usr
		//-human stuff-

		if(human.stat)
			return

		if(human.in_throw_mode)
			return human.throw_item(src)

		var/in_range = in_range(src, human) || src.loc == human

		if (in_range)
			if ( !human.restrained() )
				if (W)
					attackby(W,human)
					if (W)
						W.afterattack(src, human)
				else
					attack_hand(human)
			else
				hand_h(human, human.hand)
		else
			if ( (W) && !human.restrained() )
				W.afterattack(src, human)


	else if(isAI(usr))
		var/mob/living/silicon/ai/ai = usr
		//-ai stuff-

		if(ai.stat)
			return

		if (ai.control_disabled)
			return

		if( !ai.restrained() )
			attack_ai(ai)
		else
			hand_a(ai, ai.hand)

	else if(isrobot(usr))
		var/mob/living/silicon/robot/robot = usr
		//-cyborg stuff-

		if(robot.stat)
			return

		if (robot.lockcharge)
			return



		if(W)
			var/in_range = in_range(src, robot) || src.loc == robot
			if(in_range)
				attackby(W,robot)
			if (W)
				W.afterattack(src, robot)
		else
			if( !robot.restrained() )
				attack_robot(robot)
			else
				hand_r(robot, robot.hand)

	else if(isobserver(usr))
		var/mob/dead/observer/ghost = usr
		//-ghost stuff-

		if(ghost)
			if(W)
				if(usr.client && usr.client.holder)
					src.attackby(W, ghost)				//This is so admins can interact with things ingame.
				else
					src.attack_ghost(ghost)				//Something's gone wrong, non-admin ghosts shouldn't be able to hold things.
			else
				if(usr.client && usr.client.holder)
					src.attack_admin(ghost)				//This is so admins can interact with things ingame.
				else
					src.attack_ghost(ghost)				//Standard click as ghost


	else if(ismonkey(usr))
		var/mob/living/carbon/monkey/monkey = usr
		//-monkey stuff-

		if(monkey.stat)
			return

		if(monkey.in_throw_mode)
			return monkey.throw_item(src)

		var/in_range = in_range(src, monkey) || src.loc == monkey

		if (in_range)
			if ( !monkey.restrained() )
				if (W)
					attackby(W,monkey)
					if (W)
						W.afterattack(src, monkey)
				else
					attack_paw(monkey)
			else
				hand_p(monkey, monkey.hand)
		else
			if ( (W) && !monkey.restrained() )
				W.afterattack(src, monkey)

	else if(isalienadult(usr))
		var/mob/living/carbon/alien/humanoid/alien = usr
		//-alien stuff-

		if(alien.stat)
			return

		var/in_range = in_range(src, alien) || src.loc == alien

		if (in_range)
			if ( !alien.restrained() )
				if (W)
					attackby(W,alien)
					if (W)
						W.afterattack(src, alien)
				else
					attack_alien(alien)
			else
				hand_al(alien, alien.hand)
		else
			if ( (W) && !alien.restrained() )
				W.afterattack(src, alien)


	else if(ismetroid(usr))
		var/mob/living/carbon/metroid/metroid = usr
		//-metroid stuff-

		if(metroid.stat)
			return

		var/in_range = in_range(src, metroid) || src.loc == metroid

		if (in_range)
			if ( !metroid.restrained() )
				if (W)
					attackby(W,metroid)
					if (W)
						W.afterattack(src, metroid)
				else
					attack_metroid(metroid)
			else
				hand_m(metroid, metroid.hand)
		else
			if ( (W) && !metroid.restrained() )
				W.afterattack(src, metroid)


	else if(isanimal(usr))
		var/mob/living/simple_animal/animal = usr
		//-simple animal stuff-

		if(animal.stat)
			return

		var/in_range = in_range(src, animal) || src.loc == animal

		if (in_range)
			if ( !animal.restrained() )
				attack_animal(animal)

/atom/DblClick(location, control, params) //TODO: DEFERRED: REWRITE
//	world << "checking if this shit gets called at all"


	// ------- TIME SINCE LAST CLICK -------
	if (world.time <= usr:lastDblClick+1)
//		world << "BLOCKED atom.DblClick() on [src] by [usr] : src.type is [src.type]"
		return
	else
//		world << "atom.DblClick() on [src] by [usr] : src.type is [src.type]"
		usr:lastDblClick = world.time

	// ------- DIR CHANGING WHEN CLICKING (changes facting direction) ------

	if( usr && iscarbon(usr) && !usr.buckled )
		if( src.x && src.y && usr.x && usr.y )
			var/dx = src.x - usr.x
			var/dy = src.y - usr.y

			if( dy > 0 && abs(dx) < dy ) //North
				usr.dir = 1
			if( dy < 0 && abs(dx) < abs(dy) ) //South
				usr.dir = 2
			if( dx > 0 && abs(dy) <= dx ) //East
				usr.dir = 4
			if( dx < 0 && abs(dy) <= abs(dx) ) //West
				usr.dir = 8
			if( dx == 0 && dy == 0 )
				if(src.pixel_y > 16)
					usr.dir = 1
				if(src.pixel_y < -16)
					usr.dir = 2
				if(src.pixel_x > 16)
					usr.dir = 4
				if(src.pixel_x < -16)
					usr.dir = 8




	// ------- AI -------
	if (istype(usr, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/ai = usr
		if (ai.control_disabled)
			return

	// ------- CYBORG -------
	if (istype (usr, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/bot = usr
		if (bot.lockcharge) return
	..()






	// ------- SHIFT-CLICK -------

	var/parameters = params2list(params)

	if(parameters["shift"]){
		if(!isAI(usr))
			ShiftClick(usr)
		else
			AIShiftClick(usr)
		return
	}

	// ------- ALT-CLICK -------

	if(parameters["alt"]){
		if(!isAI(usr))
			AltClick(usr)
		else
			AIAltClick(usr)
		return
	}

	// ------- CTRL-CLICK -------

	if(parameters["ctrl"]){
		if(!isAI(usr))
			CtrlClick(usr)
		else
			AICtrlClick(usr)
		return
	}

	// ------- THROW -------
	if(usr.in_throw_mode)
		return usr:throw_item(src)

	// ------- ITEM IN HAND DEFINED -------
	var/obj/item/W = usr.equipped()

	// ------- ROBOT -------
	if(istype(usr, /mob/living/silicon/robot))
		if(!isnull(usr:module_active))
			W = usr:module_active
		else
			W = null

	// ------- ATTACK SELF -------
	if (W == src && usr.stat == 0)
		spawn (0)
			W.attack_self(usr)
		return

	// ------- PARALYSIS, STUN, WEAKENED, DEAD, (And not AI) -------
	if (((usr.paralysis || usr.stunned || usr.weakened) && !istype(usr, /mob/living/silicon/ai)) || usr.stat != 0)
		return

	// ------- CLICKING STUFF IN CONTAINERS -------
	if ((!( src in usr.contents ) && (((!( isturf(src) ) && (!( isturf(src.loc) ) && (src.loc && !( isturf(src.loc.loc) )))) || !( isturf(usr.loc) )) && (src.loc != usr.loc && (!( istype(src, /obj/screen) ) && !( usr.contents.Find(src.loc) ))))))
		if (istype(usr, /mob/living/silicon/ai))
			var/mob/living/silicon/ai/ai = usr
			if (ai.control_disabled || ai.malfhacking)
				return
		else
			return

	// ------- 1 TILE AWAY -------
	var/t5 = in_range(src, usr) || src.loc == usr

	// ------- AI CAN CLICK ANYTHING -------
	if (istype(usr, /mob/living/silicon/ai))
		t5 = 1

	// ------- CYBORG CAN CLICK ANYTHING WHEN NOT HOLDING STUFF -------
	if ((istype(usr, /mob/living/silicon/robot)) && W == null)
		t5 = 1

	// ------- CLICKING ON ORGANS -------
	if (istype(src, /datum/organ) && src in usr.contents)
		return

//	world << "according to dblclick(), t5 is [t5]"

	// ------- ACTUALLY DETERMINING STUFF -------
	if (((t5 || (W && (W.flags & 16))) && !( istype(src, /obj/screen) )))

		// ------- ( CAN USE ITEM OR HAS 1 SECOND USE DELAY ) AND NOT CLICKING ON SCREEN -------

		if (usr.next_move < world.time)
			usr.prev_move = usr.next_move
			usr.next_move = world.time + 10
		else
			// ------- ALREADY USED ONE ITEM WITH USE DELAY IN THE PREVIOUS SECOND -------
			return

		// ------- DELAY CHECK PASSED -------

		if ((src.loc && (get_dist(src, usr) < 2 || src.loc == usr.loc)))

			// ------- CLICKED OBJECT EXISTS IN GAME WORLD, DISTANCE FROM PERSON TO OBJECT IS 1 SQUARE OR THEY'RE ON THE SAME SQUARE -------

			var/direct = get_dir(usr, src)
			var/ok = 0
			if ( (direct - 1) & direct)

				// ------- CLICKED OBJECT IS LOCATED IN A DIAGONAL POSITION FROM THE PERSON -------

				var/turf/Step_1
				var/turf/Step_2
				switch(direct)
					if(5.0)
						Step_1 = get_step(usr, NORTH)
						Step_2 = get_step(usr, EAST)

					if(6.0)
						Step_1 = get_step(usr, SOUTH)
						Step_2 = get_step(usr, EAST)

					if(9.0)
						Step_1 = get_step(usr, NORTH)
						Step_2 = get_step(usr, WEST)

					if(10.0)
						Step_1 = get_step(usr, SOUTH)
						Step_2 = get_step(usr, WEST)

					else
				if(Step_1 && Step_2)

					// ------- BOTH CARDINAL DIRECTIONS OF THE DIAGONAL EXIST IN THE GAME WORLD -------

					var/check_1 = 0
					var/check_2 = 0
					check_1 = CanReachThrough(get_turf(usr), Step_1, src) && CanReachThrough(Step_1, get_turf(src), src)

					check_2 = CanReachThrough(get_turf(usr), Step_2, src) && CanReachThrough(Step_2, get_turf(src), src)

					ok = (check_1 || check_2)

						// ------- YOU CAN REACH THE ITEM THROUGH AT LEAST ONE OF THE TWO DIRECTIONS. GOOD. -------

					/*
						More info:
							If you're trying to click an item in the north-east of your mob, the above section of code will first check if tehre's a tile to the north or you and to the east of you
							These two tiles are Step_1 and Step_2. After this, a new dummy object is created on your location. It then tries to move to Step_1, If it succeeds, objects on the turf you're on and
							the turf that Step_1 is are checked for items which have the ON_BORDER flag set. These are itmes which limit you on only one tile border. Windows, for the most part.
							CheckExit() and CanPass() are use to determine this. The dummy object is then moved back to your location and it tries to move to Step_2. Same checks are performed here.
							If at least one of the two checks succeeds, it means you can reach the item and ok is set to 1.
					*/
			else
				// ------- OBJECT IS ON A CARDINAL TILE (NORTH, SOUTH, EAST OR WEST OR THE TILE YOU'RE ON) -------
				ok = CanReachThrough(get_turf(usr), get_turf(src), src)
				/*
					See the previous More info, for... more info...
				*/

			if (!( ok ))
				// ------- TESTS ABOVE DETERMINED YOU CANNOT REACH THE TILE -------
				return 0

		if (!( usr.restrained() ))
			// ------- YOU ARE NOT REASTRAINED -------

			if (W)
				// ------- YOU HAVE AN ITEM IN YOUR HAND - HANDLE ATTACKBY AND AFTERATTACK -------
				if (t5)
					src.attackby(W, usr)
				if (W)
					W.afterattack(src, usr, (t5 ? 1 : 0), params)

			else
				// ------- YOU DO NOT HAVE AN ITEM IN YOUR HAND -------
				if (istype(usr, /mob/living/carbon/human))
					// ------- YOU ARE HUMAN -------
					src.attack_hand(usr, usr.hand)
				else
					// ------- YOU ARE NOT HUMAN. WHAT ARE YOU - DETERMINED HERE AND PROPER ATTACK_MOBTYPE CALLED -------
					if (istype(usr, /mob/living/carbon/monkey))
						src.attack_paw(usr, usr.hand)
					else if (istype(usr, /mob/living/carbon/alien/humanoid))
						src.attack_alien(usr, usr.hand)
					else if (istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/living/silicon/robot))
						src.attack_ai(usr, usr.hand)
					else if(istype(usr, /mob/living/carbon/metroid))
						src.attack_metroid(usr)
					else if(istype(usr, /mob/living/simple_animal))
						src.attack_animal(usr)
		else
			// ------- YOU ARE RESTRAINED. DETERMINE WHAT YOU ARE AND ATTACK WITH THE PROPER HAND_X PROC -------
			if (istype(usr, /mob/living/carbon/human))
				src.hand_h(usr, usr.hand)
			else if (istype(usr, /mob/living/carbon/monkey))
				src.hand_p(usr, usr.hand)
			else if (istype(usr, /mob/living/carbon/alien/humanoid))
				src.hand_al(usr, usr.hand)
			else if (istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/living/silicon/robot))
				src.hand_a(usr, usr.hand)

	else
		// ------- ITEM INACESSIBLE OR CLICKING ON SCREEN -------
		if (istype(src, /obj/screen))
			// ------- IT'S THE HUD YOU'RE CLICKING ON -------
			usr.prev_move = usr.next_move
			usr:lastDblClick = world.time + 2
			if (usr.next_move < world.time)
				usr.next_move = world.time + 2
			else
				return

			// ------- 2 DECISECOND DELAY FOR CLICKING PASSED -------

			if (!( usr.restrained() ))

				// ------- YOU ARE NOT RESTRAINED -------
				if ((W && !( istype(src, /obj/screen) )))
					// ------- IT SHOULD NEVER GET TO HERE, DUE TO THE ISTYPE(SRC, /OBJ/SCREEN) FROM PREVIOUS IF-S - I TESTED IT WITH A DEBUG OUTPUT AND I COULDN'T GET THIST TO SHOW UP. -------
					src.attackby(W, usr)
					if (W)
						W.afterattack(src, usr,, params)
				else
					// ------- YOU ARE NOT RESTRAINED, AND ARE CLICKING A HUD OBJECT -------
					if (istype(usr, /mob/living/carbon/human))
						src.attack_hand(usr, usr.hand)
					else if (istype(usr, /mob/living/carbon/monkey))
						src.attack_paw(usr, usr.hand)
					else if (istype(usr, /mob/living/carbon/alien/humanoid))
						src.attack_alien(usr, usr.hand)
			else
				// ------- YOU ARE RESTRAINED CLICKING ON A HUD OBJECT -------
				if (istype(usr, /mob/living/carbon/human))
					src.hand_h(usr, usr.hand)
				else if (istype(usr, /mob/living/carbon/monkey))
					src.hand_p(usr, usr.hand)
				else if (istype(usr, /mob/living/carbon/alien/humanoid))
					src.hand_al(usr, usr.hand)
		else
			// ------- YOU ARE CLICKING ON AN OBJECT THAT'S INACCESSIBLE TO YOU AND IS NOT YOUR HUD -------
			if(usr:mutations & LASER && usr:a_intent == "hurt" && world.time >= usr.next_move)
				// ------- YOU HAVE THE LASER MUTATION, YOUR INTENT SET TO HURT AND IT'S BEEN MORE THAN A DECISECOND SINCE YOU LAS TATTACKED -------
				var/turf/oloc
				var/turf/T = get_turf(usr)
				var/turf/U = get_turf(src)
				if(istype(src, /turf)) oloc = src
				else
					oloc = loc

				if(istype(usr, /mob/living/carbon/human))
					usr:nutrition -= rand(1,5)
					usr:handle_regular_hud_updates()

				var/obj/item/projectile/beam/A = new /obj/item/projectile/beam( usr.loc )
				A.icon = 'genetics.dmi'
				A.icon_state = "eyelasers"
				playsound(usr.loc, 'taser2.ogg', 75, 1)

				A.firer = usr
				A.def_zone = usr:get_organ_target()
				A.original = oloc
				A.current = T
				A.yo = U.y - T.y
				A.xo = U.x - T.x
				spawn( 1 )
					A.process()

				usr.next_move = world.time + 6
	return


/proc/CanReachThrough(turf/srcturf, turf/targetturf, atom/target)
	var/obj/item/weapon/dummy/D = new /obj/item/weapon/dummy( srcturf )

	if(targetturf.density && targetturf != get_turf(target))
		return 0

	//Now, check objects to block exit that are on the border
	for(var/obj/border_obstacle in srcturf)
		if(border_obstacle.flags & ON_BORDER)
			if(!border_obstacle.CheckExit(D, targetturf))
				del D
				return 0

	//Next, check objects to block entry that are on the border
	for(var/obj/border_obstacle in targetturf)
		if((border_obstacle.flags & ON_BORDER) && (target != border_obstacle))
			if(!border_obstacle.CanPass(D, srcturf, 1, 0))
				del D
				return 0

	del D
	return 1

/atom/proc/CtrlClick(var/mob/M as mob)
	examine()
	return

/atom/proc/AltClick()
	if(hascall(src,"pull"))
		src:pull()
	return

/atom/proc/ShiftClick()
	if(hascall(src,"pull"))
		src:pull()
	return

/atom/proc/AIShiftClick() // Opens and closes doors!
	if(istype(src , /obj/machinery/door/airlock))
		if(src:density)
			var/nhref = "src=\ref[src];aiEnable=7"
			src.Topic(nhref, params2list(nhref), src, 1)
		else
			var/nhref = "src=\ref[src];aiDisable=7"
			src.Topic(nhref, params2list(nhref), src, 1)

	return

/atom/proc/AIAltClick() // Eletrifies doors.
	if(istype(src , /obj/machinery/door/airlock))
		if(!src:secondsElectrified)
			var/nhref = "src=\ref[src];aiEnable=6"
			src.Topic(nhref, params2list(nhref), src, 1)
		else
			var/nhref = "src=\ref[src];aiDisable=5"
			src.Topic(nhref, params2list(nhref), src, 1)
	return

/atom/proc/AICtrlClick() // Bolts doors.
	if(istype(src , /obj/machinery/door/airlock))
		if(src:locked)
			var/nhref = "src=\ref[src];aiEnable=4"
			src.Topic(nhref, params2list(nhref), src, 1)
		else
			var/nhref = "src=\ref[src];aiDisable=4"
			src.Topic(nhref, params2list(nhref), src, 1)
	return


/*/atom/proc/get_global_map_pos()
	if(!islist(global_map) || isemptylist(global_map)) return
	var/cur_x = null
	var/cur_y = null
	var/list/y_arr = null
	for(cur_x=1,cur_x<=global_map.len,cur_x++)
		y_arr = global_map[cur_x]
		cur_y = y_arr.Find(src.z)
		if(cur_y)
			break
//	world << "X = [cur_x]; Y = [cur_y]"
	if(cur_x && cur_y)
		return list("x"=cur_x,"y"=cur_y)
	else
		return 0	*/

/atom/proc/checkpass(passflag)
	return pass_flags&passflag


//Could not find object proc defines and this could almost be an atom level one.

/obj/proc/process()
	processing_objects.Remove(src)
	return 0


/*Really why was this in the click proc of all the places you could put it
					if (usr:a_intent == "help")
						// ------- YOU HAVE THE HELP INTENT SELECTED -------
						if(istype(src, /mob/living/carbon))
							// ------- YOUR TARGET IS LIVING CARBON CREATURE (NOT AI OR CYBORG OR SIMPLE ANIMAL) -------
							var/mob/living/carbon/C = src
							if(usr:mutations & HEAL)
								// ------- YOU ARE HUMAN, WITH THE HELP INTENT TARGETING A HUMAN AND HAVE THE 'HEAT' GENETIC MUTATION -------

								if(C.stat != 2)
									// ------- THE PERSON YOU'RE TOUCHING IS NOT DEAD -------

									var/t_him = "it"
									if (src.gender == MALE)
										t_him = "his"
									else if (src.gender == FEMALE)
										t_him = "her"
									var/u_him = "it"
									if (usr.gender == MALE)
										t_him = "him"
									else if (usr.gender == FEMALE)
										t_him = "her"

									if(src != usr)
										usr.visible_message( \
										"\blue <i>[usr] places [u_him] palms on [src], healing [t_him]!</i>", \
										"\blue You place your palms on [src] and heal [t_him].", \
										)
									else
										usr.visible_message( \
										"\blue <i>[usr] places [u_him] palms on [u_him]self and heals.</i>", \
										"\blue You place your palms on yourself and heal.", \
										)

									C.adjustOxyLoss(-25)
									C.adjustToxLoss(-25)

									if(istype(C, /mob/living/carbon/human))
										// ------- YOUR TARGET IS HUMAN -------
										var/mob/living/carbon/human/H = C
										var/datum/organ/external/affecting = H.get_organ(check_zone(usr:zone_sel:selecting))
										if(affecting && affecting.heal_damage(25, 25))
											H.UpdateDamageIcon()
									else
										C.heal_organ_damage(25, 25)
									C.adjustCloneLoss(-25)
									C.stunned = max(0, C.stunned-5)
									C.paralysis = max(0, C.paralysis-5)
									C.stuttering = max(0, C.stuttering-5)
									C.drowsyness = max(0, C.drowsyness-5)
									C.weakened = max(0, C.weakened-5)
									usr:nutrition -= rand(1,10)
									usr.next_move = world.time + 6
								else
									// ------- PERSON YOU'RE TOUCHING IS ALREADY DEAD -------
									usr << "\red [src] is dead and can't be healed."
								return

					// ------- IF YOU DON'T HAVE THE SILLY ABILITY ABOVE OR FAIL ON ANY OTHER CHECK, THEN YOU'RE CLICKING ON SOMETHING WITH AN EMPTY HAND. ATTACK_HAND IT IS THEN -------
*/




