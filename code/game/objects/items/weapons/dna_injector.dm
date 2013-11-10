/obj/item/weapon/dnainjector
	name = "\improper DNA injector"
	desc = "This injects the person with DNA."
	icon = 'icons/obj/items.dmi'
	icon_state = "dnainjector"
	throw_speed = 1
	throw_range = 5
	w_class = 1.0

	var/list/fields

/obj/item/weapon/dnainjector/attack_paw(mob/user)
	return attack_hand(user)


/obj/item/weapon/dnainjector/proc/inject(mob/living/carbon/M, mob/user)
	if(check_dna_integrity(M) && !(NOCLONE in M.mutations))
		if(M.stat == DEAD)	//prevents dead people from having their DNA changed
			user << "<span class='notice'>You can't modify [M]'s DNA while \he's dead.</span>"
			return
		M.radiation += rand(20, 50)
		if(fields)
			var/log_msg = "[key_name(user)] injected [key_name(M)] with the [name]"
			if(fields["name"] && fields["UE"] && fields["blood_type"])
				M.real_name = fields["name"]
				M.dna.unique_enzymes = fields["UE"]
				M.name = M.real_name
				M.dna.blood_type = fields["blood_type"]
			if(fields["UI"])	//UI+UE
				M.dna.uni_identity = merge_text(M.dna.uni_identity, fields["UI"])
				updateappearance(M)
			if(fields["SE"])
				M.dna.struc_enzymes = merge_text(M.dna.struc_enzymes, fields["SE"])
				if(ishuman(M) && (deconstruct_block(getblock(M.dna.struc_enzymes, RACEBLOCK), BAD_MUTATION_DIFFICULTY) == BAD_MUTATION_DIFFICULTY))	//check for monkeying people.
					message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [name] \red(MONKEY)")
					log_msg += " (MONKEY)"
				domutcheck(M, null,(type != /obj/item/weapon/dnainjector))	//admin-spawnable-injectors always work
			log_attack(log_msg)
	else
		user << "<span class='notice'>It appears that [M] does not have compatible DNA.</span>"
		return

/obj/item/weapon/dnainjector/attack(mob/target, mob/user)
	if(!ishuman(user))
		user << "<span class='notice'>You don't have the dexterity to do this!</span>"
		return

	target.attack_log += "\[[time_stamp()]\] <font color='orange'>[user.name] ([user.ckey]) attempted to inject with [name]</font>"
	user.attack_log += "\[[time_stamp()]\] <font color='red'>Used the [name] to attempt to inject [target.name] ([target.ckey])</font>"
	log_attack("<font color='red'>[user.name] ([user.ckey]) used the [name] to attempt to inject [target.name] ([target.ckey])</font>")

	if(target != user)
		target.visible_message("<span class='danger'>[user] is trying to inject [target] with [src]!</span>", "<span class='userdanger'>[user] is trying to inject [target] with [src]!</span>")
		if(!do_mob(user, target))	return
		target.visible_message("<span class='danger'>[user] injects [target] with the syringe with [src]!", \
						"<span class='userdanger'>[user] injects [target] with the syringe with [src]!")

	else
		user << "<span class='notice'>You inject yourself with [src].</span>"

	target.attack_log += "\[[time_stamp()]\] <font color='orange'>Has been injected with [name] by [user.name] ([user.ckey])</font>"
	user.attack_log += "\[[time_stamp()]\] <font color='red'>Used the [name] to inject [target.name] ([target.ckey])</font>"
	log_attack("<font color='red'>[user.name] ([user.ckey]) used the [name] to inject [target.name] ([target.ckey])</font>")

	user.drop_item()
	inject(target, user)	//Now we actually do the heavy lifting.
	loc = null				//garbage collect


/obj/item/weapon/dnainjector/antihulk
	name = "\improper DNA injector (Anti-Hulk)"
	desc = "Cures green skin."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, HULKBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))

/obj/item/weapon/dnainjector/hulkmut
	name = "\improper DNA injector (Hulk)"
	desc = "This will make you big and strong, but give you a bad skin condition."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, HULKBLOCK, repeat_string(DNA_BLOCK_SIZE,"f")))

/obj/item/weapon/dnainjector/xraymut
	name = "\improper DNA injector (Xray)"
	desc = "Finally you can see what the Captain does."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, XRAYBLOCK, repeat_string(DNA_BLOCK_SIZE,"f")))

/obj/item/weapon/dnainjector/antixray
	name = "\improper DNA injector (Anti-Xray)"
	desc = "It will make you see harder."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, XRAYBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))

/////////////////////////////////////
/obj/item/weapon/dnainjector/antiglasses
	name = "\improper DNA injector (Anti-Glasses)"
	desc = "Toss away those glasses!"
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, NEARSIGHTEDBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))

/obj/item/weapon/dnainjector/glassesmut
	name = "\improper DNA injector (Glasses)"
	desc = "Will make you need dorkish glasses."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, NEARSIGHTEDBLOCK, repeat_string(DNA_BLOCK_SIZE,"f")))

/obj/item/weapon/dnainjector/epimut
	name = "\improper DNA injector (Epi.)"
	desc = "Shake shake shake the room!"
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, EPILEPSYBLOCK, repeat_string(DNA_BLOCK_SIZE,"f")))

/obj/item/weapon/dnainjector/antiepi
	name = "\improper DNA injector (Anti-Epi.)"
	desc = "Will fix you up from shaking the room."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, EPILEPSYBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))
////////////////////////////////////
/obj/item/weapon/dnainjector/anticough
	name = "\improper DNA injector (Anti-Cough)"
	desc = "Will stop that aweful noise."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, COUGHBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))

/obj/item/weapon/dnainjector/coughmut
	name = "\improper DNA injector (Cough)"
	desc = "Will bring forth a sound of horror from your throat."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, COUGHBLOCK, repeat_string(DNA_BLOCK_SIZE,"f")))


/obj/item/weapon/dnainjector/clumsymut
	name = "\improper DNA injector (Clumsy)"
	desc = "Makes clown minions."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, CLUMSYBLOCK, repeat_string(DNA_BLOCK_SIZE,"f")))


/obj/item/weapon/dnainjector/anticlumsy
	name = "\improper DNA injector (Anti-Clumy)"
	desc = "Apply this for Security Clown."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, CLUMSYBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))

/obj/item/weapon/dnainjector/antitour
	name = "\improper DNA injector (Anti-Tour.)"
	desc = "Will cure tourrets."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, TOURETTESBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))

/obj/item/weapon/dnainjector/tourmut
	name = "\improper DNA injector (Tour.)"
	desc = "Gives you a nasty case off tourrets."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, TOURETTESBLOCK, repeat_string(DNA_BLOCK_SIZE,"f")))

/obj/item/weapon/dnainjector/stuttmut
	name = "\improper DNA injector (Stutt.)"
	desc = "Makes you s-s-stuttterrr"
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, NERVOUSBLOCK, repeat_string(DNA_BLOCK_SIZE,"f")))

/obj/item/weapon/dnainjector/antistutt
	name = "\improper DNA injector (Anti-Stutt.)"
	desc = "Fixes that speaking impairment."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, NERVOUSBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))

/obj/item/weapon/dnainjector/antifire
	name = "\improper DNA injector (Anti-Fire)"
	desc = "Cures fire."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, FIREBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))

/obj/item/weapon/dnainjector/firemut
	name = "\improper DNA injector (Fire)"
	desc = "Gives you fire."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, FIREBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))

/obj/item/weapon/dnainjector/blindmut
	name = "\improper DNA injector (Blind)"
	desc = "Makes you not see anything."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, BLINDBLOCK, repeat_string(DNA_BLOCK_SIZE,"f")))

/obj/item/weapon/dnainjector/antiblind
	name = "\improper DNA injector (Anti-Blind)"
	desc = "ITS A MIRACLE!!!"
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, BLINDBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))

/obj/item/weapon/dnainjector/antitele
	name = "\improper DNA injector (Anti-Tele.)"
	desc = "Will make you not able to control your mind."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, TELEBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))

/obj/item/weapon/dnainjector/telemut
	name = "\improper DNA injector (Tele.)"
	desc = "Super brain man!"
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, TELEBLOCK, repeat_string(DNA_BLOCK_SIZE,"f")))

/obj/item/weapon/dnainjector/telemut/darkbundle
	name = "\improper DNA injector"
	desc = "Good. Let the hate flow through you."

/obj/item/weapon/dnainjector/deafmut
	name = "\improper DNA injector (Deaf)"
	desc = "Sorry, what did you say?"
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, DEAFBLOCK, repeat_string(DNA_BLOCK_SIZE,"f")))

/obj/item/weapon/dnainjector/antideaf
	name = "\improper DNA injector (Anti-Deaf)"
	desc = "Will make you hear once more."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, DEAFBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))

/obj/item/weapon/dnainjector/h2m
	name = "\improper DNA injector (Human > Monkey)"
	desc = "Will make you a flea bag."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, RACEBLOCK, repeat_string(DNA_BLOCK_SIZE,"f")))

/obj/item/weapon/dnainjector/m2h
	name = "\improper DNA injector (Monkey > Human)"
	desc = "Will make you...less hairy."
	New()
		..()
		fields = list("SE"=setblock(NULLED_SE, RACEBLOCK, repeat_string(DNA_BLOCK_SIZE,"0")))