/*
CONTAINS:
PAINT
DNA INJECTOR

*/
/obj/item/weapon/paint/attack_self(mob/user as mob)

	var/t1 = input(user, "Please select a color:", "Locking Computer", null) in list( "red", "blue", "green", "yellow", "black", "white", "neutral" )
	if ((user.equipped() != src || user.stat || user.restrained()))
		return
	src.color = t1
	src.icon_state = text("paint_[]", t1)
	add_fingerprint(user)
	return








/obj/item/weapon/dnainjector/attack_paw(mob/user as mob)
	return src.attack_hand(user)


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
					message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [src.name] \red(MONKEY)")
				else
					message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [src.name]")
			else
				message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [src.name]")

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
			inject(M)
			if (dnatype == "se")
				if (isblockon(getblock(dna, 14,3),14) && istype(M, /mob/living/carbon/human))
					message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [src.name] \red(MONKEY)")
				else
					message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [src.name]")
			else
				message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [src.name]")
			user.show_message(text("\red You inject [M]"))
	return
