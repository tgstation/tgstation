/*
CONTAINS:
PAINT
DNA INJECTOR

*/
var/global/list/cached_icons = list()

/obj/item/weapon/paint/red
	name = "Red paint"
	color = "FF0000"
	icon_state = "paint_red"

/obj/item/weapon/paint/green
	name = "Green paint"
	color = "00FF00"
	icon_state = "paint_green"

/obj/item/weapon/paint/blue
	name = "Blue paint"
	color = "0000FF"
	icon_state = "paint_blue"

/obj/item/weapon/paint/yellow
	name = "Yellow paint"
	color = "FFFF00"
	icon_state = "paint_yellow"

/obj/item/weapon/paint/violet //no icon
	name = "Violet paint"
	color = "FF00FF"
	icon_state = "paint_neutral"

/obj/item/weapon/paint/black
	name = "Black paint"
	color = "333333"
	icon_state = "paint_black"

/obj/item/weapon/paint/white
	name = "White paint"
	color = "FFFFFF"
	icon_state = "paint_white"


/obj/item/weapon/paint/anycolor
	name = "Any color"
	icon_state = "paint_neutral"

	attack_self(mob/user as mob)
		var/t1 = input(user, "Please select a color:", "Locking Computer", null) in list( "red", "blue", "green", "yellow", "black", "white")
		if ((user.equipped() != src || user.stat || user.restrained()))
			return
		switch(t1)
			if("red")
				color = "FF0000"
			if("blue")
				color = "0000FF"
			if("green")
				color = "00FF00"
			if("yellow")
				color = "FFFF00"
	/*
			if("violet")
				color = "FF00FF"
	*/
			if("white")
				color = "FFFFFF"
			if("black")
				color = "333333"
		icon_state = "paint_[t1]"
		add_fingerprint(user)
		return


/obj/item/weapon/paint/afterattack(turf/target, mob/user as mob)
	if(!istype(target) || istype(target, /turf/space))
		return
	var/ind = "[initial(target.icon)][color]"
	if(!cached_icons[ind])
		var/icon/overlay = new/icon(initial(target.icon))
		overlay.Blend("#[color]",ICON_MULTIPLY)
		overlay.SetIntensity(1.4)
		target.icon = overlay
		cached_icons[ind] = target.icon
	else
		target.icon = cached_icons[ind]
	return

/obj/item/weapon/paint/paint_remover
	name = "Paint remover"
	icon_state = "paint_neutral"

	afterattack(turf/target, mob/user as mob)
		if(istype(target) && target.icon != initial(target.icon))
			target.icon = initial(target.icon)
		return


/obj/item/weapon/dnainjector/attack_paw(mob/user as mob)
	return attack_hand(user)


/obj/item/weapon/dnainjector/proc/inject(mob/M as mob)
	M.radiation += rand(20,50)
	if (dnatype == "ui")
		if (!block) //isolated block?
			if (ue) //unique enzymes? yes
				M.dna.uni_identity = dna
				updateappearance(M, M.dna.uni_identity)
				M.real_name = ue
				M.name = ue
				uses--
			else //unique enzymes? no
				M.dna.uni_identity = dna
				updateappearance(M, M.dna.uni_identity)
				uses--
		else
			M.dna.uni_identity = setblock(M.dna.uni_identity,block,dna,3)
			updateappearance(M, M.dna.uni_identity)
			uses--
	if (dnatype == "se")
		if (!block) //isolated block?
			M.dna.struc_enzymes = dna
			domutcheck(M, null)
			uses--
		else
			M.dna.struc_enzymes = setblock(M.dna.struc_enzymes,block,dna,3)
			domutcheck(M, null,1)
			uses--

	spawn(0)//this prevents the collapse of space-time continuum
		del(src)
	return uses

/obj/item/weapon/dnainjector/attack(mob/M as mob, mob/user as mob)
	if (!istype(M, /mob))
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		user << "\red You don't have the dexterity to do this!"
		return
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been injected with [name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [name] to inject [M.name] ([M.ckey])</font>")

	if (user)
		if (istype(M, /mob/living/carbon/human))
			var/obj/equip_e/human/O = new /obj/equip_e/human(  )
			O.source = user
			O.target = M
			O.item = src
			O.s_loc = user.loc
			O.t_loc = M.loc
			O.place = "dnainjector"
			M.requests += O
			if (dnatype == "se")
				if (isblockon(getblock(dna, 14,3),14) && istype(M, /mob/living/carbon/human))
					message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [name] \red(MONKEY)")
					log_game("[key_name(user)] injected [key_name(M)] with the [name] (MONKEY)")
				else
					message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [name]")
					log_game("[key_name(user)] injected [key_name(M)] with the [name]")
			else
				message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [name]")
				log_game("[key_name(user)] injected [key_name(M)] with the [name]")

			spawn( 0 )
				O.process()
				return
		else
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red [] has been injected with [] by [].", M, src, user), 1)
				//Foreach goto(192)
			if (!(istype(M, /mob/living/carbon/human) || istype(M, /mob/living/carbon/monkey)))
				user << "\red Apparently it didn't work."
				return
			if (dnatype == "se")
				if (isblockon(getblock(dna, 14,3),14) && istype(M, /mob/living/carbon/human))
					message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [name] \red(MONKEY)")
					log_game("[key_name(user)] injected [key_name(M)] with the [name] (MONKEY)")
				else
					message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [name]")
					log_game("[key_name(user)] injected [key_name(M)] with the [name]")
			else
				message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [name]")
				log_game("[key_name(user)] injected [key_name(M)] with the [name]")
			inject(M)//Now we actually do the heavy lifting.
			/*
			A user injecting themselves could mean their own transformation and deletion of mob.
			I don't have the time to figure out how this code works so this will do for now.
			I did rearrange things a bit.
			*/
			if(!isnull(user))//If the user still exists. Their mob may not.
				user.show_message(text("\red You inject [M]"))
	return
