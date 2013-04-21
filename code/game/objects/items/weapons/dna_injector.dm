/obj/item/weapon/dnainjector
	name = "DNA-Injector"
	desc = "This injects the person with DNA."
	icon = 'icons/obj/items.dmi'
	icon_state = "dnainjector"
	
	var/list/fields

/*	var/dnatype = null
	var/dna = null
	var/block = null
	var/owner = null
	var/ue = null	*/
	
	var/s_time = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	var/uses = 1
	var/nofail
	var/is_bullet = 0
	var/inuse = 0

/obj/item/weapon/dnainjector/attack_paw(mob/user as mob)
	return attack_hand(user)


/obj/item/weapon/dnainjector/proc/inject(mob/living/carbon/M, mob/user)
	if(check_dna_integrity(M))
		M.radiation += rand(20,50)
		if(!(NOCLONE in M.mutations) && fields) // prevents drained people from having their DNA changed
			if(fields["UI"] && fields["name"] && fields["UE"] && fields["b_type"])	//UI+UE
				M.dna.uni_identity = merge_text(M.dna.uni_identity, fields["UI"])
				M.dna.b_type = fields["b_type"]
				M.real_name = fields["name"]
				M.name = M.real_name
				M.dna.unique_enzymes = fields["UE"]
				updateappearance(M)
			
			if(fields["SE"])														//SE
				M.dna.struc_enzymes = merge_text(M.dna.struc_enzymes, fields["SE"])
				domutcheck(M, null)
			uses--
	if(user)
		user.drop_from_inventory(src)
	. = uses
	del(src)

/obj/item/weapon/dnainjector/attack(mob/M as mob, mob/user as mob)
	if(!istype(user, /mob/living/carbon/human))
		user << "\red You don't have opposable thumbs!"
		return
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been injected with [name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [name] to inject [M.name] ([M.ckey])</font>")
	log_attack("<font color='red'>[user.name] ([user.ckey]) used the [name] to inject [M.name] ([M.ckey])</font>")

	if(!fields || !check_dna_integrity(M))	return
	if(istype(M, /mob/living/carbon/human))
		if(!inuse)
			var/obj/effect/equip_e/human/O = new /obj/effect/equip_e/human()
			O.source = user
			O.target = M
			O.item = src
			O.s_loc = user.loc
			O.t_loc = M.loc
			O.place = "dnainjector"
			inuse = 1
			spawn(50) // Not the best fix. There should be an failure proc, for /effect/equip_e/, which is called when the first initital checks fail
				inuse = 0
			M.requests += O
			
			if(fields["SE"] && (deconstruct_block(getblock(fields["SE"], RACEBLOCK), BAD_MUTATION_DIFFICULTY) == BAD_MUTATION_DIFFICULTY))
				message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [name] \red(MONKEY)")
				log_attack("[key_name(user)] injected [key_name(M)] with the [name] (MONKEY)")
			else
				log_attack("[key_name(user)] injected [key_name(M)] with the [name]")

			spawn(0)
				O.process()
				return
	else
		if(!inuse)
			for(var/mob/O in viewers(M, null))
				O.show_message("\red [M] has been injected with [src] by [user].", 1)
			
			if(fields["SE"] && (deconstruct_block(getblock(fields["SE"], RACEBLOCK), BAD_MUTATION_DIFFICULTY) == BAD_MUTATION_DIFFICULTY))
				message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [name] \red(MONKEY)")
				log_attack("[key_name(user)] injected [key_name(M)] with the [name] (MONKEY)")
			else
				log_attack("[key_name(user)] injected [key_name(M)] with the [name]")
			
			inuse = 1
			inject(M, user)//Now we actually do the heavy lifting.
			spawn(50)
				inuse = 0
			/*
			A user injecting themselves could mean their own transformation and deletion of mob.
			I don't have the time to figure out how this code works so this will do for now.
			I did rearrange things a bit.
			*/
			if(user)//If the user still exists. Their mob may not.
				if(M)//Runtime fix: If the mob doesn't exist, mob.name doesnt work. - Nodrak
					user.show_message("\red You inject [M.name]")
				else
					user.show_message("\red You finish the injection.")
	return



/obj/item/weapon/dnainjector/antihulk
	name = "DNA-Injector (Anti-Hulk)"
	desc = "Cures green skin."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, HULKBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))

/obj/item/weapon/dnainjector/hulkmut
	name = "DNA-Injector (Hulk)"
	desc = "This will make you big and strong, but give you a bad skin condition."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, HULKBLOCK, repeat_string(DNA_BLOCK_SIZE,"f")))

/obj/item/weapon/dnainjector/xraymut
	name = "DNA-Injector (Xray)"
	desc = "Finally you can see what the Captain does."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, XRAYBLOCK, repeat_string(DNA_BLOCK_SIZE,"f")))

/obj/item/weapon/dnainjector/antixray
	name = "DNA-Injector (Anti-Xray)"
	desc = "It will make you see harder."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, XRAYBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))

/////////////////////////////////////
/obj/item/weapon/dnainjector/antiglasses
	name = "DNA-Injector (Anti-Glasses)"
	desc = "Toss away those glasses!"
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, NEARSIGHTEDBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))

/obj/item/weapon/dnainjector/glassesmut
	name = "DNA-Injector (Glasses)"
	desc = "Will make you need dorkish glasses."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, NEARSIGHTEDBLOCK, repeat_string(DNA_BLOCK_SIZE,"f")))

/obj/item/weapon/dnainjector/epimut
	name = "DNA-Injector (Epi.)"
	desc = "Shake shake shake the room!"
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, EPILEPSYBLOCK, repeat_string(DNA_BLOCK_SIZE,"f")))

/obj/item/weapon/dnainjector/antiepi
	name = "DNA-Injector (Anti-Epi.)"
	desc = "Will fix you up from shaking the room."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, EPILEPSYBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))
////////////////////////////////////
/obj/item/weapon/dnainjector/anticough
	name = "DNA-Injector (Anti-Cough)"
	desc = "Will stop that aweful noise."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, COUGHBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))

/obj/item/weapon/dnainjector/coughmut
	name = "DNA-Injector (Cough)"
	desc = "Will bring forth a sound of horror from your throat."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, COUGHBLOCK, repeat_string(DNA_BLOCK_SIZE,"f")))


/obj/item/weapon/dnainjector/clumsymut
	name = "DNA-Injector (Clumsy)"
	desc = "Makes clown minions."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, CLUMSYBLOCK, repeat_string(DNA_BLOCK_SIZE,"f")))


/obj/item/weapon/dnainjector/anticlumsy
	name = "DNA-Injector (Anti-Clumy)"
	desc = "Apply this for Security Clown."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, CLUMSYBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))

/obj/item/weapon/dnainjector/antitour
	name = "DNA-Injector (Anti-Tour.)"
	desc = "Will cure tourrets."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, TOURETTESBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))

/obj/item/weapon/dnainjector/tourmut
	name = "DNA-Injector (Tour.)"
	desc = "Gives you a nasty case off tourrets."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, TOURETTESBLOCK, repeat_string(DNA_BLOCK_SIZE,"f")))

/obj/item/weapon/dnainjector/stuttmut
	name = "DNA-Injector (Stutt.)"
	desc = "Makes you s-s-stuttterrr"
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, NERVOUSBLOCK, repeat_string(DNA_BLOCK_SIZE,"f")))

/obj/item/weapon/dnainjector/antistutt
	name = "DNA-Injector (Anti-Stutt.)"
	desc = "Fixes that speaking impairment."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, NERVOUSBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))

/obj/item/weapon/dnainjector/antifire
	name = "DNA-Injector (Anti-Fire)"
	desc = "Cures fire."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, FIREBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))

/obj/item/weapon/dnainjector/firemut
	name = "DNA-Injector (Fire)"
	desc = "Gives you fire."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, FIREBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))

/obj/item/weapon/dnainjector/blindmut
	name = "DNA-Injector (Blind)"
	desc = "Makes you not see anything."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, BLINDBLOCK, repeat_string(DNA_BLOCK_SIZE,"f")))

/obj/item/weapon/dnainjector/antiblind
	name = "DNA-Injector (Anti-Blind)"
	desc = "ITS A MIRACLE!!!"
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, BLINDBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))

/obj/item/weapon/dnainjector/antitele
	name = "DNA-Injector (Anti-Tele.)"
	desc = "Will make you not able to control your mind."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, TELEBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))

/obj/item/weapon/dnainjector/telemut
	name = "DNA-Injector (Tele.)"
	desc = "Super brain man!"
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, TELEBLOCK, repeat_string(DNA_BLOCK_SIZE,"f")))

/obj/item/weapon/dnainjector/telemut/darkbundle
	name = "DNA-Injector"
	desc = "Good. Let the hate flow through you."
/obj/item/weapon/dnainjector/telemut/darkbundle/attack(mob/M as mob, mob/user as mob)
	..()
	domutcheck(M,null) //guarantees that it works instead of getting a dud injector.

/obj/item/weapon/dnainjector/deafmut
	name = "DNA-Injector (Deaf)"
	desc = "Sorry, what did you say?"
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, DEAFBLOCK, repeat_string(DNA_BLOCK_SIZE,"f")))

/obj/item/weapon/dnainjector/antideaf
	name = "DNA-Injector (Anti-Deaf)"
	desc = "Will make you hear once more."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, DEAFBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))

/obj/item/weapon/dnainjector/h2m
	name = "DNA-Injector (Human > Monkey)"
	desc = "Will make you a flea bag."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, RACEBLOCK, repeat_string(DNA_BLOCK_SIZE,"f")))

/obj/item/weapon/dnainjector/m2h
	name = "DNA-Injector (Monkey > Human)"
	desc = "Will make you...less hairy."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, RACEBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))