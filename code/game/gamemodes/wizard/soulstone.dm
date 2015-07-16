/obj/item/device/soulstone
	name = "soulstone shard"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "soulstone"
	item_state = "electronic"
	desc = "A fragment of the legendary treasure known simply as the 'Soul Stone'. The shard still flickers with a fraction of the full artefacts power."
	w_class = 1.0
	slot_flags = SLOT_BELT
	origin_tech = "bluespace=4;materials=4"
	var/imprinted = "empty"
	var/usability = 0

/obj/item/device/soulstone/anybody
	usability = 1

/obj/item/device/soulstone/pickup(mob/living/user as mob)
	if(!iscultist(user) && !iswizard(user) && !usability)
		user << "<span class='danger'>An overwhelming feeling of dread comes over you as you pick up the soulstone. It would be wise to be rid of this quickly.</span>"
		user.Dizzy(120)

//////////////////////////////Capturing////////////////////////////////////////////////////////

/obj/item/device/soulstone/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	if(!iscultist(user) && !iswizard(user) && !usability)
		user.Paralyse(5)
		user << "<span class='userdanger'>Your body is wracked with debilitating pain!</span>"
		return
	if(!istype(M, /mob/living/carbon/human))//If target is not a human.
		return ..()
	if(istype(M, /mob/living/carbon/human/dummy))
		return..()
	add_logs(user, M, "captured [M.name]'s soul", object=src)

	transfer_soul("VICTIM", M, user)
	return

///////////////////Options for using captured souls///////////////////////////////////////

/obj/item/device/soulstone/attack_self(mob/user)
	if (!in_range(src, user))
		return
	if(!iscultist(user) && !iswizard(user) && !usability)
		user.Paralyse(5)
		user << "<span class='userdanger'>Your body is wracked with debilitating pain!</span>"
		return
	user.set_machine(src)
	var/dat = "<TT><B>Soul Stone</B><BR>"
	for(var/mob/living/simple_animal/shade/A in src)
		dat += "Captured Soul: [A.name]<br>"
		dat += {"<A href='byond://?src=\ref[src];choice=Summon'>Summon Shade</A>"}
		dat += "<br>"
		dat += {"<a href='byond://?src=\ref[src];choice=Close'>Close</a>"}
	user << browse(dat, "window=aicard")
	onclose(user, "aicard")
	return


/obj/item/device/soulstone/Topic(href, href_list)
	var/mob/U = usr
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
				A.status_flags &= ~GODMODE
				A.canmove = 1
				A.loc = U.loc
				A.cancel_camera()
				src.icon_state = "soulstone"
				if(iswizard(U) || usability)
					A << "<b>You have been released from your prison, but you are still bound to [U.name]'s will. Help them suceed in their goals at all costs.</b>"
				else if(iscultist(U))
					A << "<b>You have been released from your prison, but you are still bound to the cult's will. Help them suceed in their goals at all costs.</b>"

	attack_self(U)

///////////////////////////Transferring to constructs/////////////////////////////////////////////////////
/obj/structure/constructshell
	name = "empty shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	desc = "A wicked machine used by those skilled in magical arts. It is inactive"

/obj/structure/constructshell/attackby(obj/item/O as obj, mob/user as mob, params)
	if(istype(O, /obj/item/device/soulstone))
		var/obj/item/device/soulstone/SS = O
		SS.transfer_soul("CONSTRUCT",src,user)


////////////////////////////Proc for moving soul in and out off stone//////////////////////////////////////


/obj/item/device/soulstone/proc/transfer_soul(var/choice as text, var/target, var/mob/U as mob).
	switch(choice)
		if("FORCE")
			if(!iscarbon(target))		//TO-DO: Add sacrifice stoning for non-organics, just because you have no body doesnt mean you dont have a soul
				return 0
			var/mob/living/carbon/T = target
			var/obj/item/device/soulstone/C = src
			if(T.client != null)
				if(C.contents.len)
					return 0
				else
					for(var/obj/item/W in T)
						T.unEquip(W)
				init_shade(C, T, U)
				//qdel T		//Gib instead
				return 1
			return 0
		if("VICTIM")
			var/mob/living/carbon/human/T = target
			var/obj/item/device/soulstone/C = src
			if(ticker.mode.name == "cult" && T.mind == ticker.mode:sacrifice_target)
				if(iscultist(U))
					U << "<span class='danger'>The Geometer of blood wants this mortal sacrificed with the rune.</span>"
				else
					U << "<span class='danger'>The soul stone doesn't work for no apparent reason.</span>"
				return 0
			if(C.imprinted != "empty")
				U << "<span class='userdanger'>Capture failed!</span>: The soul stone has already been imprinted with [C.imprinted]'s mind!"
			else
				if (T.stat == 0)
					U << "<span class='userdanger'>Capture failed!</span>: Kill or maim the victim first!"
				else
					if(T.client == null)
						U << "<span class='userdanger'>Capture failed!</span>: The soul has already fled it's mortal frame."
					else
						if(C.contents.len)
							U << "<span class='userdanger'>Capture failed!</span>: The soul stone is full! Use or free an existing soul to make room."
						else
							for(var/obj/item/W in T)
								T.unEquip(W)
							init_shade(C, T, U, vic = 1)
							qdel(T)
		if("SHADE")
			var/mob/living/simple_animal/shade/T = target
			var/obj/item/device/soulstone/C = src
			if (T.stat == DEAD)
				U << "<span class='userdanger'>Capture failed!</span>: The shade has already been banished!"
			else
				if(C.contents.len)
					U << "<span class='userdanger'>Capture failed!</span>: The soul stone is full! Use or free an existing soul to make room."
				else
					if(T.name != C.imprinted)
						U << "<span class='userdanger'>Capture failed!</span>: The soul stone has already been imprinted with [C.imprinted]'s mind!"
					else
						T.loc = C //put shade in stone
						T.status_flags |= GODMODE
						T.canmove = 0
						T.health = T.maxHealth
						C.icon_state = "soulstone2"
						T << "Your soul has been recaptured by the soul stone, its arcane energies are reknitting your ethereal form"
						if(U != T)
							U << "<span class='info'><b>Capture successful!</b>:</span> [T.name]'s has been recaptured and stored within the soul stone."
		if("CONSTRUCT")
			var/obj/structure/constructshell/T = target
			var/obj/item/device/soulstone/C = src
			var/mob/living/simple_animal/shade/A = locate() in C
			if(A)
				var/construct_class = alert(U, "Please choose which type of construct you wish to create.",,"Juggernaut","Wraith","Artificer")
				if(!T || !T.loc)
					return
				switch(construct_class)
					if("Juggernaut")
						makeNewConstruct(/mob/living/simple_animal/construct/armored, A, U)

					if("Wraith")
						makeNewConstruct(/mob/living/simple_animal/construct/wraith, A, U)

					if("Artificer")
						makeNewConstruct(/mob/living/simple_animal/construct/builder, A, U)

				qdel(T)
				qdel(C)
			else
				U << "<span class='userdanger'>Creation failed!</span>: The soul stone is empty! Go kill someone!"
	return


/proc/makeNewConstruct(var/mob/living/simple_animal/construct/ctype, var/mob/target, var/mob/stoner = null, cultoverride = 0)
	var/mob/living/simple_animal/construct/newstruct = new ctype(get_turf(target))
	newstruct.faction |= "\ref[stoner]"
	newstruct.key = target.key
	if(stoner && iscultist(stoner) || cultoverride)
		if(ticker.mode.name == "cult")
			ticker.mode:add_cultist(newstruct.mind)
		else
			ticker.mode.cult+=newstruct.mind
		ticker.mode.update_cult_icons_added(newstruct.mind)
	newstruct << newstruct.playstyle_string
	if(stoner && iswizard(stoner))
		newstruct << "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>"
	else if(stoner && iscultist(stoner))
		newstruct << "<B>You are still bound to serve the cult, follow their orders and help them complete their goals at all costs.</B>"
	else newstruct << "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>"
	newstruct.cancel_camera()


/obj/item/device/soulstone/proc/init_shade(var/obj/item/device/soulstone/C, var/mob/living/carbon/human/T, var/mob/U as mob, var/vic = 0)
	new /obj/effect/decal/remains/human(T.loc) //Spawns a skeleton
	T.invisibility = 101
	var/atom/movable/overlay/animation = new /atom/movable/overlay( T.loc )
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = T
	flick("dust-h", animation)
	qdel(animation)
	var/mob/living/simple_animal/shade/S = new /mob/living/simple_animal/shade( T.loc )
	S.loc = C //put shade in stone
	S.status_flags |= GODMODE //So they won't die inside the stone somehow
	S.canmove = 0//Can't move out of the soul stone
	S.name = "Shade of [T.real_name]"
	S.real_name = "Shade of [T.real_name]"
	S.key = T.key
	S.faction |= "\ref[U]" //Add the master as a faction, allowing inter-mob cooperation
	if(iscultist(U))
		ticker.mode.add_cultist(S.mind,2)
	S.cancel_camera()
	C.icon_state = "soulstone2"
	C.name = "Soul Stone: [S.real_name]"
	if(iswizard(U) || usability)
		S << "Your soul has been captured! You are now bound to [U.name]'s will, help them suceed in their goals at all costs."
	else if(iscultist(U))
		S << "Your soul has been captured! You are now bound to the cult's will, help them suceed in their goals at all costs."
	C.imprinted = "[S.name]"
	if(vic)
		U << "<span class='info'><b>Capture successful!</b>:</span> [T.real_name]'s soul has been ripped from their body and stored within the soul stone."
		U << "The soulstone has been imprinted with [S.real_name]'s mind, it will no longer react to other souls."
