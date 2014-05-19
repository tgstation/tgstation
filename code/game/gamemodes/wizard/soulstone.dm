/obj/item/device/soulstone
	name = "Soul Stone Shard"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "soulstone"
	item_state = "electronic"
	desc = "A fragment of the legendary treasure known simply as the 'Soul Stone'. The shard still flickers with a fraction of the full artefacts power."
	w_class = 1.0
	slot_flags = SLOT_BELT
	origin_tech = "bluespace=4;materials=4"
	var/imprinted = "empty"


//////////////////////////////Capturing////////////////////////////////////////////////////////

	attack(mob/living/carbon/human/M as mob, mob/user as mob)
		if(!istype(M, /mob/living/carbon/human))//If target is not a human.
			return ..()
		if(istype(M, /mob/living/carbon/human/dummy))
			return..()
		add_logs(user, M, "captured [M.name]'s soul", object=src)

		transfer_soul("VICTIM", M, user)
		return

	/*attack(mob/living/simple_animal/shade/M as mob, mob/user as mob)//APPARENTLY THEY NEED THEIR OWN SPECIAL SNOWFLAKE CODE IN THE LIVING ANIMAL DEFINES
		if(!istype(M, /mob/living/simple_animal/shade))//If target is not a shade
			return ..()
		user.attack_log += text("\[[time_stamp()]\] <span class='danger'>Used the [src.name] to capture the soul of [M.name] ([M.ckey])</span>")

		transfer_soul("SHADE", M, user)
		return*/
///////////////////Options for using captured souls///////////////////////////////////////

	attack_self(mob/user)
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




	Topic(href, href_list)
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
					A << "<b>You have been released from your prison, but you are still bound to [U.name]'s will. Help them suceed in their goals at all costs.</b>"
					A.loc = U.loc
					A.cancel_camera()
					src.icon_state = "soulstone"
		attack_self(U)

///////////////////////////Transferring to constructs/////////////////////////////////////////////////////
/obj/structure/constructshell
	name = "empty shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	desc = "A wicked machine used by those skilled in magical arts. It is inactive"

/obj/structure/constructshell/attackby(obj/item/O as obj, mob/user as mob)
	if(istype(O, /obj/item/device/soulstone))
		O.transfer_soul("CONSTRUCT",src,user)


////////////////////////////Proc for moving soul in and out off stone//////////////////////////////////////


/obj/item/proc/transfer_soul(var/choice as text, var/target, var/mob/U as mob).
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
				switch(construct_class)
					if("Juggernaut")
						var/mob/living/simple_animal/construct/armoured/Z = new /mob/living/simple_animal/construct/armoured (get_turf(T.loc))
						Z.key = A.key
						if(iscultist(U))
							if(ticker.mode.name == "cult")
								ticker.mode:add_cultist(Z.mind)
							else
								ticker.mode.cult+=Z.mind
							ticker.mode.update_cult_icons_added(Z.mind)
						qdel(T)
						Z << "<B>You are a Juggernaut. Though slow, your shell can withstand extreme punishment, create shield walls and even deflect energy weapons, and rip apart enemies and walls alike.</B>"
						Z << "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>"
						Z.cancel_camera()
						qdel(C)

					if("Wraith")
						var/mob/living/simple_animal/construct/wraith/Z = new /mob/living/simple_animal/construct/wraith (get_turf(T.loc))
						Z.key = A.key
						if(iscultist(U))
							if(ticker.mode.name == "cult")
								ticker.mode:add_cultist(Z.mind)
							else
								ticker.mode.cult+=Z.mind
							ticker.mode.update_cult_icons_added(Z.mind)
						qdel(T)
						Z << "<B>You are a Wraith. Though relatively fragile, you are fast, deadly, and even able to phase through walls.</B>"
						Z << "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>"
						Z.cancel_camera()
						qdel(C)

					if("Artificer")
						var/mob/living/simple_animal/construct/builder/Z = new /mob/living/simple_animal/construct/builder (get_turf(T.loc))
						Z.key = A.key
						if(iscultist(U))
							if(ticker.mode.name == "cult")
								ticker.mode:add_cultist(Z.mind)
							else
								ticker.mode.cult+=Z.mind
							ticker.mode.update_cult_icons_added(Z.mind)
						qdel(T)
						Z << "<B>You are an Artificer. You are incredibly weak and fragile, but you are able to construct fortifications, use magic missile, repair allied constructs (by clicking on them), </B><I>and most important of all create new constructs</I><B> (Use your Artificer spell to summon a new construct shell and Summon Soulstone to create a new soulstone).</B>"
						Z << "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>"
						Z.cancel_camera()
						qdel(C)
			else
				U << "<span class='userdanger'>Creation failed!</span>: The soul stone is empty! Go kill someone!"
	return

obj/item/proc/init_shade(var/obj/item/device/soulstone/C, var/mob/living/carbon/human/T, var/mob/U as mob, var/vic = 0)
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
	if(iscultist(U))
		ticker.mode.add_cultist(S.mind,2)
	S.cancel_camera()
	C.icon_state = "soulstone2"
	C.name = "Soul Stone: [S.real_name]"
	S << "Your soul has been captured! You are now bound to [U.name]'s will, help them suceed in their goals at all costs."
	C.imprinted = "[S.name]"
	if(vic)
		U << "<span class='info'><b>Capture successful!</b>:</span> [T.real_name]'s soul has been ripped from their body and stored within the soul stone."
		U << "The soulstone has been imprinted with [S.real_name]'s mind, it will no longer react to other souls."
