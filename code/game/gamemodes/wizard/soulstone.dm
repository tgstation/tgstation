/obj/item/device/soulstone
	name = "Soul Stone Shard"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "soulstone"
	item_state = "shard-soulstone"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/shards.dmi', "right_hand" = 'icons/mob/in-hand/right/shards.dmi')
	desc = "A fragment of the legendary treasure known simply as the 'Soul Stone'. The shard still flickers with a fraction of the full artefacts power."
	w_class = 1.0
	flags = FPRINT
	slot_flags = SLOT_BELT
	origin_tech = "bluespace=4;materials=4"

/obj/item/device/soulstone/Destroy()
	eject_shade()
	..()
//////////////////////////////Capturing////////////////////////////////////////////////////////

/obj/item/device/soulstone/attack(var/mob/living/M, mob/user as mob)
	if(!istype(M, /mob/living/carbon) && !istype(M, /mob/living/simple_animal))
		return ..()
	if(istype(M, /mob/living/carbon/human/manifested))
		to_chat(user, "The soul stone shard seems unable to pull the soul out of that poor manifested ghost back onto our plane.")
		return
	add_logs(user, M, "captured [M.name]'s soul", object=src)

	transfer_soul("VICTIM", M, user)
	return

/*attack(mob/living/simple_animal/shade/M as mob, mob/user as mob)//APPARENTLY THEY NEED THEIR OWN SPECIAL SNOWFLAKE CODE IN THE LIVING ANIMAL DEFINES
	if(!istype(M, /mob/living/simple_animal/shade))//If target is not a shade
		return ..()
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to capture the soul of [M.name] ([M.ckey])</font>")

	transfer_soul("SHADE", M, user)
	return*/
///////////////////Options for using captured souls///////////////////////////////////////

/obj/item/device/soulstone/attack_self(mob/user)
	if (!in_range(src, user))
		return
	user.set_machine(src)
	var/dat = "<TT><B>Soul Stone</B><BR>"
	for(var/mob/living/simple_animal/shade/A in src)
		dat += "Captured Soul: [A.name]<br>"
		dat += {"<A href='byond://?src=\ref[src];choice=Summon'>Summon Shade</A>"}
		dat += "<br>"
		dat += {"<a href='byond://?src=\ref[src];choice=Close'> Close</a>"}
	user << browse(dat, "window=aicard")
	onclose(user, "aicard")
	return




/obj/item/device/soulstone/Topic(href, href_list)
	var/mob/living/carbon/U = usr
	if (!in_range(src, U)||U.machine!=src)
		U << browse(null, "window=aicard")
		U.unset_machine()
		return

	add_fingerprint(U)
	U.set_machine(src)

	switch(href_list["choice"])//Now we switch based on choice.
		if ("Close")
			U << browse(null, "window=aicard")
			U.unset_machine()
			return

		if ("Summon")
			for(var/mob/living/simple_animal/shade/A in src)
				eject_shade(U)
				src.icon_state = "soulstone"
				src.item_state = "shard-soulstone"
				U.update_inv_l_hand()
				U.update_inv_r_hand()
				src.name = "Soul Stone Shard"

	attack_self(U)

/obj/item/device/soulstone/cultify()
	return

///////////////////////////Transferring to constructs/////////////////////////////////////////////////////
/obj/structure/constructshell
	name = "empty shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	desc = "A wicked machine used by those skilled in magical arts. It is inactive."
	flags = FPRINT

/obj/structure/constructshell/cultify()
	return

/obj/structure/constructshell/cult
	icon_state = "construct-cult"
	desc = "This eerie contraption looks like it would come alive if supplied with a missing ingredient."

/obj/structure/constructshell/attackby(obj/item/O as obj, mob/user as mob)
	if(istype(O, /obj/item/device/soulstone))
		O.transfer_soul("CONSTRUCT",src,user)


////////////////////////////Proc for moving soul in and out off stone//////////////////////////////////////

/obj/item/device/soulstone/proc/eject_shade(var/mob/user=null)
	for(var/mob/living/L in src)
		L.loc = get_turf(src)
		L.status_flags &= ~GODMODE
		if(user)
			to_chat(L, "<b>You have been released from your prison, but you are still bound to [user.name]'s will. Help them suceed in their goals at all costs.</b>")
		L.canmove = 1
		L.cancel_camera()

/obj/item/proc/capture_soul(var/target, var/mob/user as mob)
	if(istype(target, /mob/living/carbon))//humans, monkeys, aliens
		var/mob/living/carbon/carbonMob = target
		//first of all, let's check that our target has a soul, somewhere

		if(!carbonMob.client)
			//no client? the target could be either braindead, decapitated, or catatonic, let's check which
			var/mob/living/carbon/human/humanTarget = null
			var/datum/organ/internal/brain/humanBrain = null
			if(ishuman(target))
				humanTarget = target
				humanBrain = humanTarget.internal_organs_by_name["brain"]

			if(!humanTarget || (humanTarget && humanBrain))
				//our target either is a monkey or alien, or is a human with their head. Did they have a soul in the first place? if so, where is it right now
				if(!carbonMob.mind)
					//if a mob doesn't have a mind, that means it never had a player controlling him
					to_chat(user, "<span class='warning'>The soul stone isn't reacting, looks like this target doesn't have much of a soul.</span>")
					return
				else
					//otherwise, that means the player either disconnected or ghosted. we can track their key from their mind,
					//but first let's make sure that they are dead or in crit
					var/mob/new_target = null
					for(var/mob/M in player_list)
						if(M.key == carbonMob.mind.key)
							new_target = M
					if(!new_target)
						to_chat(user, "<span class='warning'>The soul stone isn't reacting, looks like this target's soul went far, far away.</span>")
						return
					else if(!istype(new_target,/mob/dead/observer))
						to_chat(user, "<span class='warning'>The soul stone isn't reacting, looks like this target's soul already reincarnated.</span>")
						return
					else
						//if the player ghosted, you don't need to put his body into crit to successfully soulstone them.
						to_chat(new_target, "<span class='danger'>You feel your soul getting sucked into the soul stone.</span>")
						to_chat(user, "<span class='rose'>The soul stone reacts to the corpse and starts glowing.</span>")
						capture_soul_process(user,new_target.client,carbonMob)
			else if(humanTarget)
				//aw shit, our target is a brain/headless human, let's try and locate the head.
				if(!humanTarget.decapitated || (humanTarget.decapitated.loc == null))
					to_chat(user, "<span class='warning'>The soul stone isn't reacting, looks like their brain has been removed or head has been destroyed.</span>")
					return
				else if(istype(humanTarget.decapitated.loc,/mob/living/carbon/human))
					to_chat(user, "<span class='warning'>The soul stone isn't reacting, looks like their head has been grafted on another body.</span>")
					return
				else
					var/obj/item/weapon/organ/head/humanHead = humanTarget.decapitated
					if((humanHead.z != humanTarget.z) || (get_dist(humanTarget,humanHead) > 5))//F I V E   T I L E S
						to_chat(user, "<span class='warning'>The soul stone isn't reacting, the head needs to be closer from the body.</span>")
						return
					else
						capture_soul_head(humanHead, user)
						return

		else
			//if the body still has a client, then all we have to make sure of is that he's dead or in crit
			if (carbonMob.stat == CONSCIOUS)
				to_chat(user, "<span class='warning'>Kill or maim the victim first!</span>")
			else if(!carbonMob.isInCrit() && carbonMob.stat != DEAD)
				to_chat(user, "<span class='warning'>The victim is holding on, weaken them further!</span>")
			else
				to_chat(carbonMob, "<span class='danger'>You feel your soul getting sucked into the soul stone.</span>")
				to_chat(user, "<span class='rose'>The soul stone reacts to the corpse and starts glowing.</span>")
				capture_soul_process(user,carbonMob.client,carbonMob)
	else
		to_chat(user, "<span class='warning'>The soul stone doesn't seem compatible with that creature's soul.</span>")
		//TODO: add a few snowflake checks to specific simple_animals that could be soulstoned.

/obj/item/proc/capture_soul_head(var/target, var/mob/user as mob)//called either when using a soulstone on a head, or on a decapitated body
	if(istype(target, /obj/item/weapon/organ/head))
		var/obj/item/weapon/organ/head/humanHead = target
		if(!humanHead.organ_data)
			to_chat(user, "<span class='rose'>The soul stone isn't reacting, looks like their brain was separated from their head.</span>")
			return
		var/mob/living/carbon/brain/humanBrainMob = humanHead.brainmob
		if(!humanBrainMob.client)
			if(!humanBrainMob.mind)
				to_chat(user, "<span class='warning'>The soul stone isn't reacting, looks like this target doesn't have much of a soul.</span>")
				return
			else
				var/mob/new_target = null
				for(var/mob/M in player_list)
					if(M.key == humanBrainMob.mind.key)
						new_target = M
				if(!new_target)
					to_chat(user, "<span class='warning'>The soul stone isn't reacting, looks like this target's soul went far, far away.</span>")
					return
				else if(!istype(new_target,/mob/dead/observer))
					to_chat(user, "<span class='warning'>The soul stone isn't reacting, looks like this target's soul already reincarnated.</span>")
					return
				else
					to_chat(new_target, "<span class='danger'>You feel your soul getting sucked into the soulstone.</span>")
					to_chat(user, "<span class='rose'>The soul stone reacts to the corpse and starts glowing.</span>")
					capture_soul_process(user,new_target.client,humanHead,humanHead.origin_body)
		else
			to_chat(humanBrainMob, "<span class='danger'>You feel your soul getting sucked into the soul stone.</span>")
			to_chat(user, "<span class='rose'>The soul stone reacts to the corpse and starts glowing.</span>")
			capture_soul_process(user,humanBrainMob.client,humanHead,humanHead.origin_body)


/obj/item/proc/capture_soul_process(var/mob/living/carbon/user, var/client/targetClient, var/atom/movable/target, var/atom/movable/add_target = null)
	//user is the guy using the soulstone
	//C is the client of the guy we're soulstoning, so we don't lose track of him between the beginning and the end of the soulstoning.
	//target is the source of the guy's soul (his body, or his head if decapitated)
	//add_target is his body if he has been decapitated, for cosmetic purposes (and so it dusts)

	if(!targetClient)
		return

	var/mob/living/carbon/human/body = null

	if(istype(target,/mob/living/carbon/human))
		body = target
	else if(istype(add_target,/mob/living/carbon/human))
		body = add_target

	var/true_name = "Unknown"

	if(body)
		true_name = body.real_name

		for(var/obj/item/W in body)
			body.drop_from_inventory(W)

		body.dropBorers(1)

		var/turf/T = get_turf(body)

		body.invisibility = 101

		var/datum/organ/external/head_organ = body.get_organ("head")
		if(head_organ.status & ORGAN_DESTROYED)
			new /obj/effect/decal/remains/human/noskull(T)
			anim(target = T, a_icon = 'icons/mob/mob.dmi', flick_anim = "dust-h2-nohead", sleeptime = 26)
		else
			new /obj/effect/decal/remains/human(T)
			if(body.lying)
				anim(target = T, a_icon = 'icons/mob/mob.dmi', flick_anim = "dust-h2", sleeptime = 26)
			else
				anim(target = T, a_icon = 'icons/mob/mob.dmi', flick_anim = "dust-h", sleeptime = 26)

		if(body.decapitated && (body.decapitated == target))//just making sure we're dealing with the right head
			target.invisibility = 101
			new /obj/item/weapon/skull(get_turf(target))
	else
		target.invisibility = 101

		if(ismob(target))
			var/mob/M = target
			true_name = M.real_name
			new /obj/effect/decal/cleanable/ash(get_turf(target))
		else if(istype(target,/obj/item/weapon/organ/head))
			var/obj/item/weapon/organ/head/H = target
			var/mob/living/carbon/brain/BM = H.brainmob
			true_name = BM.real_name
			new /obj/item/weapon/skull(get_turf(target))

	//Scary sound
	playsound(get_turf(src), get_sfx("soulstone"), 50,1)

	//Creating a shade inside the stone and putting the victim in control
	var/mob/living/simple_animal/shade/shadeMob = new(src)//put shade in stone
	shadeMob.status_flags |= GODMODE //So they won't die inside the stone somehow
	shadeMob.canmove = 0//Can't move out of the soul stone
	shadeMob.name = "Shade of [true_name]"
	shadeMob.real_name = "Shade of [true_name]"
	shadeMob.ckey = targetClient.ckey
	shadeMob.cancel_camera()

	//Changing the soulstone's icon and description
	icon_state = "soulstone2"
	item_state = "shard-soulstone2"
	user.update_inv_l_hand()
	user.update_inv_r_hand()
	name = "Soul Stone: [true_name]"
	to_chat(shadeMob, "Your soul has been captured! You are now bound to [user.name]'s will, help them suceed in their goals at all costs.")
	to_chat(user, "<span class='notice'>[true_name]'s soul has been ripped from their body and stored within the soul stone.</span>")

	//Necromancer stuff
	var/ref = "\ref[user.mind]"
	var/list/necromancers
	if(!(user.mind in ticker.mode.necromancer))
		ticker.mode:necromancer[ref] = list()
	necromancers = ticker.mode:necromancer[ref]
	necromancers.Add(shadeMob.mind)
	ticker.mode:necromancer[ref] = necromancers
	ticker.mode.update_necro_icons_added(user.mind)
	ticker.mode.update_necro_icons_added(shadeMob.mind)
	ticker.mode.risen.Add(shadeMob.mind)

	//Pretty particles
	var/turf/T1 = get_turf(target)
	var/turf/T2 = null

	if(add_target && add_target.loc)
		T2 = get_turf(add_target)

	spawn()
		for(var/i = 0;i < 10;i++)
			var/obj/effect/tracker/soul/Tr = getFromPool(/obj/effect/tracker/soul, T1)
			Tr.target = user
			Tr.icon_state = pick("soul1","soul2","soul3")
			if(T2)
				var/obj/effect/tracker/soul/Tr2 = getFromPool(/obj/effect/tracker/soul, T2)
				Tr2.target = user
				Tr2.icon_state = pick("soul1","soul2","soul3")
			sleep(1)


	//Cleaning up the corpse
	qdel(target)
	if(add_target)
		qdel(add_target)


/obj/item/proc/transfer_soul(var/choice as text, var/target, var/mob/living/carbon/U as mob)
	var/deleteafter = 0
	switch(choice)
		if("VICTIM")
			if(src.contents.len)
				to_chat(U, "<span class='warning'>The soul stone is full! Use or free an existing soul to make room.</span>")
				return

			var/mob/living/T = target

			if(istype(ticker.mode, /datum/game_mode/cult))
				var/datum/game_mode/cult/mode_ticker = ticker.mode
				if(T.mind && (mode_ticker.sacrifice_target == T.mind))
					to_chat(U, "<span class='warning'>The soul stone is unable to rip this soul. Such a powerful soul, it must be coveted by some powerful being.</span>")
					return

			capture_soul(T,U)

		if("SHADE")
			var/mob/living/simple_animal/shade/T = target
			var/obj/item/device/soulstone/C = src
			if (T.stat == DEAD)
				to_chat(U, "<span class='danger'>Capture failed!: </span>The shade has already been banished!")
			else
				if(C.contents.len)
					to_chat(U, "<span class='danger'>Capture failed!: </span>The soul stone is full! Use or free an existing soul to make room.")
				else
					T.loc = C //put shade in stone
					T.status_flags |= GODMODE
					T.canmove = 0
					T.health = T.maxHealth
					C.icon_state = "soulstone2"
					C.item_state = "shard-soulstone2"
					U.update_inv_l_hand()
					U.update_inv_r_hand()
					C.name = "Soul Stone: [T.real_name]"
					to_chat(T, "Your soul has been recaptured by the soul stone, its arcane energies are reknitting your ethereal form")
					to_chat(U, "<span class='notice'><b>Capture successful!</b>: </span>[T.name]'s has been recaptured and stored within the soul stone.")
		if("CONSTRUCT")
			var/obj/structure/constructshell/T = target
			var/obj/item/device/soulstone/C = src
			var/mob/living/simple_animal/shade/A = locate() in C
			var/mob/living/simple_animal/construct/Z
			if(A)
				var/construct_class = alert(U, "Please choose which type of construct you wish to create.",,"Juggernaut","Wraith","Artificer")
				ticker.mode.update_necro_icons_removed(A.mind)
				switch(construct_class)
					if("Juggernaut")
						Z = new /mob/living/simple_animal/construct/armoured (get_turf(T.loc))
						Z.key = A.key
						if(iscultist(U))
							if(ticker.mode.name == "cult")
								ticker.mode:add_cultist(Z.mind)
							else
								ticker.mode.cult+=Z.mind
							ticker.mode.update_cult_icons_added(Z.mind)
						qdel(T)
						to_chat(Z, "<B>You are a Juggernaut. Though slow, your shell can withstand extreme punishment, your body can reflect energy and laser weapons, and you can create temporary shields that blocks pathing and projectiles. You fists can punch people and regular walls appart.</B>")
						to_chat(Z, "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>")
						Z.cancel_camera()
						deleteafter = 1

					if("Wraith")
						Z = new /mob/living/simple_animal/construct/wraith (get_turf(T.loc))
						Z.key = A.key
						if(iscultist(U))
							if(ticker.mode.name == "cult")
								ticker.mode:add_cultist(Z.mind)
							else
								ticker.mode.cult+=Z.mind
							ticker.mode.update_cult_icons_added(Z.mind)
						qdel(T)
						to_chat(Z, "<B>You are a Wraith. Though relatively fragile, you are fast, deadly, and even able to phase through walls for a few seconds. Use it both for surprise attacks and strategic retreats.</B>")
						to_chat(Z, "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>")
						Z.cancel_camera()
						deleteafter = 1

					if("Artificer")
						Z = new /mob/living/simple_animal/construct/builder (get_turf(T.loc))
						Z.key = A.key
						if(iscultist(U))
							if(ticker.mode.name == "cult")
								ticker.mode:add_cultist(Z.mind)
							else
								ticker.mode.cult+=Z.mind
							ticker.mode.update_cult_icons_added(Z.mind)
						qdel(T)
						to_chat(Z, "<B>You are an Artificer. You are incredibly weak and fragile, but you can heal both yourself and other constructs (by clicking on yourself/them). You can build (and deconstruct) new walls and floors, or replace existing ones by clicking on them, as well as place pylons that act as light source (these block paths but can be easily broken),</B><I>and most important of all you can produce the tools to create new constructs</I><B> (remember to periodically produce new soulstones for your master, and place empty shells in your hideout or when asked.).</B>")
						to_chat(Z, "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>")
						Z.cancel_camera()
						deleteafter = 1
				if(Z && Z.mind && !iscultist(Z))
					var/ref = "\ref[U.mind]"
					var/list/necromancers
					if(!(U.mind in ticker.mode.necromancer))
						ticker.mode:necromancer[ref] = list()
					necromancers = ticker.mode:necromancer[ref]
					necromancers.Add(Z.mind)
					ticker.mode:necromancer[ref] = necromancers
					ticker.mode.update_necro_icons_added(U.mind)
					ticker.mode.update_necro_icons_added(Z.mind)
					ticker.mode.risen.Add(Z.mind)
				name = "Soul Stone Shard"
			else
				to_chat(U, "<span class='warning'><b>Creation failed!</b>: The soul stone is empty! Go kill someone!</span>")
	ticker.mode.update_all_necro_icons()
	if(deleteafter)
		for(var/atom/A in src)//we get rid of the empty shade once we've transferred its mind to the construct, so it isn't dropped on the floor when the soulstone is destroyed.
			qdel(A)
		qdel(src)
	return
