/obj/item/device/soulstone
	name = "Soul Stone Shard"
	icon = 'wizard.dmi'
	icon_state = "soulstone"
	item_state = "electronic"
	desc = "A fragment of the legendary treasure known simply as the 'Soul Stone'. The shard still flickers with a fraction of the full artefacts power."
	w_class = 1.0
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	origin_tech = "bluespace=4;materials=4"
	var/imprinted = "empty"


//////////////////////////////Capturing////////////////////////////////////////////////////////

	attack(mob/living/carbon/human/M as mob, mob/user as mob)
		if(!istype(M, /mob/living/carbon/human))//If target is not a human.
			return ..()
		if(istype(M, /mob/living/carbon/human/dummy))
			return..()
		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their soul captured with [src.name] by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to capture the soul of [M.name] ([M.ckey])</font>")

		log_attack("<font color='red'>[user.name] ([user.ckey]) used the [src.name] to capture the soul of [M.name] ([M.ckey])</font>")
		log_admin("ATTACK: [user] ([user.ckey]) captured the soul of [M] ([M.ckey]).")
		message_admins("ATTACK: [user] ([user.ckey]) captured the soul of [M] ([M.ckey]).")


		transfer_soul("VICTIM", M, user)
		return

	/*attack(mob/living/simple_animal/shade/M as mob, mob/user as mob)//APPARENTLY THEY NEED THEIR OWN SPECIAL SNOWFLAKE CODE IN THE LIVING ANIMAL DEFINES
		if(!istype(M, /mob/living/simple_animal/shade))//If target is not a shade
			return ..()
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to capture the soul of [M.name] ([M.ckey])</font>")

		transfer_soul("SHADE", M, user)
		return*/
///////////////////Options for using captured souls///////////////////////////////////////

	attack_self(mob/user)
		if (!in_range(src, user))
			return
		user.machine = src
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
			U.machine = null
			return

		add_fingerprint(U)
		U.machine = src

		switch(href_list["choice"])//Now we switch based on choice.
			if ("Close")
				U << browse(null, "window=aicard")
				U.machine = null
				return

			if ("Summon")
				for(var/mob/living/simple_animal/shade/A in src)
					A.nodamage = 0
					A.canmove = 1
					A << "<b>You have been released from your prison, but you are still bound to [U.name]'s will. Help them suceed in their goals at all costs.</b>"
					A.loc = U.loc
					A.cancel_camera()
					src.icon_state = "soulstone"
		attack_self(U)

///////////////////////////Transferring to constructs/////////////////////////////////////////////////////
/obj/structure/constructshell
	name = "empty shell"
	icon = 'wizard.dmi'
	icon_state = "construct"
	desc = "A wicked machine used by those skilled in magical arts. It is inactive"
	flags = FPRINT | TABLEPASS

/obj/structure/constructshell/attackby(obj/item/O as obj, mob/user as mob)
	if(istype(O, /obj/item/device/soulstone))
		O.transfer_soul("CONSTRUCT",src,user)


////////////////////////////Proc for moving soul in and out off stone//////////////////////////////////////


/obj/item/proc/transfer_soul(var/choice as text, var/target, var/mob/U as mob).
	switch(choice)
		if("VICTIM")
			var/mob/living/carbon/human/T = target
			var/obj/item/device/soulstone/C = src
			if(C.imprinted != "empty")
				U << "\red <b>Capture failed!</b>: \black The soul stone has already been imprinted with [C.imprinted]'s mind!"
			else
				if (T.stat == 0)
					U << "\red <b>Capture failed!</b>: \black Kill or maim the victim first!"
				else
					if(T.client == null)
						U << "\red <b>Capture failed!</b>: \black The soul has already fled it's mortal frame."
					else
						if(C.contents.len)
							U << "\red <b>Capture failed!</b>: \black The soul stone is full! Use or free an existing soul to make room."
						else
							for(var/obj/item/W in T)
								T.drop_from_slot(W)
							new /obj/effect/decal/remains/human(T.loc) //Spawns a skeleton
							T.invisibility = 101
							var/atom/movable/overlay/animation = new /atom/movable/overlay( T.loc )
							animation.icon_state = "blank"
							animation.icon = 'mob.dmi'
							animation.master = T
							flick("dust-h", animation)
							del(animation)
							var/mob/living/simple_animal/shade/S = new /mob/living/simple_animal/shade( T.loc )
							S.loc = C //put shade in stone
							S.nodamage = 1 //So they won't die inside the stone somehow
							S.canmove = 0//Can't move out of the soul stone
							S.name = "Shade of [T.name]"
							if (T.client)
								T.client.mob = S
							S.cancel_camera()
							C.icon_state = "soulstone2"
							C.name = "Soul Stone: [S.name]"
							S << "Your soul has been captured! You are now bound to [U.name]'s will, help them suceed in their goals at all costs."
							U << "\blue <b>Capture successful!</b>: \black [T.name]'s soul has been ripped from their body and stored within the soul stone."
							U << "The soulstone has been imprinted with [S.name]'s mind, it will no longer react to other souls."
							C.imprinted = "[S.name]"
							del T
		if("SHADE")
			var/mob/living/simple_animal/shade/T = target
			var/obj/item/device/soulstone/C = src
			if (T.stat == DEAD)
				U << "\red <b>Capture failed!</b>: \black The shade has already been banished!"
			else
				if(C.contents.len)
					U << "\red <b>Capture failed!</b>: \black The soul stone is full! Use or free an existing soul to make room."
				else
					if(T.name != C.imprinted)
						U << "\red <b>Capture failed!</b>: \black The soul stone has already been imprinted with [C.imprinted]'s mind!"
					else
						T.loc = C //put shade in stone
						T.nodamage = 1
						T.canmove = 0
						T.health = T.maxHealth
						C.icon_state = "soulstone2"
						T << "Your soul has been recaptured by the soul stone, its arcane energies are reknitting your ethereal form"
						U << "\blue <b>Capture successful!</b>: \black [T.name]'s has been recaptured and stored within the soul stone."
		if("CONSTRUCT")
			var/obj/structure/constructshell/T = target
			var/obj/item/device/soulstone/C = src
			var/mob/living/simple_animal/shade/A = locate() in C
			if(A)
				var/construct_class = alert(U, "Please choose which type of construct you wish to create.",,"Juggernaut","Wraith","Artificer")
				switch(construct_class)
					if("Juggernaut")
						var/mob/living/simple_animal/constructarmoured/Z = new /mob/living/simple_animal/constructarmoured (get_turf(T.loc))
						if (A.client)
							A.client.mob = Z
							Z.mind_initialize(Z)
							if(iscultist(U))
								if (ticker.mode.name == "cult")
									ticker.mode:add_cultist(Z.mind)
									Z.mind.special_role = "Cultist"
									ticker.mode.update_cult_icons_added(Z.mind)
								else
									ticker.mode.cult+=Z.mind
									Z.mind.special_role = "Cultist"
									ticker.mode.update_cult_icons_added(Z.mind)
						del(T)
						Z << "<B>You are playing a Juggernaut. Though slow, you can withstand extreme punishment, and rip apart enemies and walls alike.</B>"
						Z << "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>"
						Z.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/lesserforcewall(Z)
						Z.cancel_camera()
						del(C)

					if("Wraith")
						var/mob/living/simple_animal/constructwraith/Z = new /mob/living/simple_animal/constructwraith (get_turf(T.loc))
						if (A.client)
							A.client.mob = Z
							Z.mind_initialize(Z)
							if(iscultist(U))
								if (ticker.mode.name == "cult")
									ticker.mode:add_cultist(Z.mind)
									Z.mind.special_role = "Cultist"
									ticker.mode.update_cult_icons_added(Z.mind)
								else
									ticker.mode.cult+=Z.mind
									Z.mind.special_role = "Cultist"
									ticker.mode.update_cult_icons_added(Z.mind)
						del(T)
						Z << "<B>You are playing a Wraith. Though relatively fragile, you are fast, deadly, and even able to phase through walls.</B>"
						Z << "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>"
						Z.spell_list += new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift(Z)
						Z.cancel_camera()
						del(C)

					if("Artificer")
						var/mob/living/simple_animal/constructbuilder/Z = new /mob/living/simple_animal/constructbuilder (get_turf(T.loc))
						if (A.client)
							A.client.mob = Z
							Z.mind_initialize(Z)
							if(iscultist(U))
								if (ticker.mode.name == "cult")
									ticker.mode:add_cultist(Z.mind)
									Z.mind.special_role = "Cultist"
									ticker.mode.update_cult_icons_added(Z.mind)
								else
									ticker.mode.cult+=Z.mind
									Z.mind.special_role = "Cultist"
									ticker.mode.update_cult_icons_added(Z.mind)
						del(T)
						Z << "<B>You are playing an Artificer. You are incredibly weak and fragile, but you are able to construct fortifications, repair allied constructs (by clicking on them), and even create new constructs</B>"
						Z << "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>"
						Z.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/construct/lesser(Z)
						Z.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/wall(Z)
						Z.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/floor(Z)
						Z.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/wall/reinforced(Z)
						Z.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone(Z)
						Z.cancel_camera()
						del(C)
			else
				U << "\red <b>Creation failed!</b>: \black The soul stone is empty! Go kill someone!"
	return
