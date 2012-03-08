/obj/item/device/soulstone
	name = "Soul Stone Shard"
	icon = 'wizard.dmi'
	icon_state = "soulstone"
	item_state = "electronic"
	desc = "A fragment of the legendary treasure known simply as the 'Soul Stone'. The shard still flickers with a fraction of the full artefacts power."
	w_class = 1.0
	flags = FPRINT | TABLEPASS | ONBELT
	var/flush = null
	origin_tech = "bluespace=4;materials=4"



	attack(mob/living/carbon/human/M as mob, mob/user as mob)
		if(!istype(M, /mob/living/carbon/human))//If target is not a human.
			return ..()
		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their soul captured with [src.name] by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to capture the soul of [M.name] ([M.ckey])</font>")
		log_admin("ATTACK: [user] ([user.ckey]) captured the soul of [M] ([M.ckey]).")
		message_admins("ATTACK: [user] ([user.ckey]) captured the soul of [M] ([M.ckey]).")

		transfer_soul("VICTIM", M, user)
		return


	attack_self(mob/user)
		if (!in_range(src, user))
			return
		user.machine = src
		var/dat = "<TT><B>Soul Stone</B><BR>"
		for(var/mob/living/carbon/human/A in src)
			dat += "Captured Soul: [A.name]<br>"
		user << browse(dat, "window=aicard")
		onclose(user, "aicard")
		return




/obj/item/proc/transfer_soul(var/choice as text, var/target, var/mob/U as mob).
	switch(choice)
		if("VICTIM")
			var/mob/living/carbon/human/T = target
			var/obj/item/device/soulstone/C = src
			if (T.stat == 0)
				U << "\red <b>Capture failed!</b>: \black Kill or maim the victim first!"
			else
				if(T.ckey == null)
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
						T.nodamage = 1 //So they won't suffocate inside the stone
						T.canmove = 0//Can't move out of the soul stone
						T.loc = C//Throw "soul" into the stone.
						T.stat = 0//Revive the victim as a "soul"
						T.mutantrace = "trappedsoul" //To prevent suicide/maybe some other special effects later on
						T.setToxLoss(0)
						T.setOxyLoss(0)
						T.setCloneLoss(0)
						T.SetParalysis(0)
						T.SetStunned(0)
						T.SetWeakened(0)
						T.radiation = 0
						T.heal_overall_damage(T.getBruteLoss(), T.getFireLoss())
						T.cancel_camera()
						T.nodamage = 1 //So they won't suffocate inside the stone
						C.icon_state = "soulstone2"
						T << "Your soul has been captured!"
						U << "\blue <b>Capture successful!</b>: \black [T.name]'s soul has been ripped from their body and stored within the soul stone."
	return