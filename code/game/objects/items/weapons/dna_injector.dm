/obj/item/weapon/dnainjector
	name = "\improper DNA injector"
	desc = "This injects the person with DNA."
	icon = 'icons/obj/items.dmi'
	icon_state = "dnainjector"
	throw_speed = 3
	throw_range = 5
	w_class = 1
	origin_tech = "biotech=1"

	var/damage_coeff  = 1
	var/list/fields
	var/list/add_mutations = list()
	var/list/remove_mutations = list()
	var/used = 0

/obj/item/weapon/dnainjector/attack_paw(mob/user)
	return attack_hand(user)


/obj/item/weapon/dnainjector/proc/inject(mob/living/carbon/M, mob/user)
	if(M.has_dna() && !(M.disabilities & NOCLONE))
		M.radiation += rand(20/(damage_coeff  ** 2),50/(damage_coeff  ** 2))
		var/log_msg = "[key_name(user)] injected [key_name(M)] with the [name]"
		for(var/datum/mutation/human/HM in remove_mutations)
			HM.force_lose(M)
		for(var/datum/mutation/human/HM in add_mutations)
			if(HM.name == RACEMUT)
				message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [name] <span class='danger'>(MONKEY)</span>")
				log_msg += " (MONKEY)"
			HM.force_give(M)
		if(fields)
			if(fields["name"] && fields["UE"] && fields["blood_type"])
				M.real_name = fields["name"]
				M.dna.unique_enzymes = fields["UE"]
				M.name = M.real_name
				M.dna.blood_type = fields["blood_type"]
			if(fields["UI"])	//UI+UE
				M.dna.uni_identity = merge_text(M.dna.uni_identity, fields["UI"])
				M.updateappearance(mutations_overlay_update=1)
		log_attack(log_msg)
	else
		user << "<span class='notice'>It appears that [M] does not have compatible DNA.</span>"
		return

/obj/item/weapon/dnainjector/attack(mob/target, mob/user)
	if(!user.IsAdvancedToolUser())
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return
	if(used)
		user << "<span class='warning'>This injector is used up!</span>"
		return
	if(ishuman(target))
		var/mob/living/carbon/human/humantarget = target
		if (!humantarget.can_inject(user, 1))
			return
	add_logs(user, target, "attempted to inject", src)

	if(target != user)
		target.visible_message("<span class='danger'>[user] is trying to inject [target] with [src]!</span>", "<span class='userdanger'>[user] is trying to inject [target] with [src]!</span>")
		if(!do_mob(user, target))	return
		target.visible_message("<span class='danger'>[user] injects [target] with the syringe with [src]!", \
						"<span class='userdanger'>[user] injects [target] with the syringe with [src]!")

	else
		user << "<span class='notice'>You inject yourself with [src].</span>"

	add_logs(user, target, "injected", src)

	inject(target, user)	//Now we actually do the heavy lifting.
	used = 1
	icon_state = "dnainjector0"
	desc += " This one is used up."


/obj/item/weapon/dnainjector/antihulk
	name = "\improper DNA injector (Anti-Hulk)"
	desc = "Cures green skin."
	New()
		..()
		remove_mutations.Add(mutations_list[HULK])

/obj/item/weapon/dnainjector/hulkmut
	name = "\improper DNA injector (Hulk)"
	desc = "This will make you big and strong, but give you a bad skin condition."
	New()
		..()
		add_mutations.Add(mutations_list[HULK])
/obj/item/weapon/dnainjector/xraymut
	name = "\improper DNA injector (Xray)"
	desc = "Finally you can see what the Captain does."
	New()
		..()
		add_mutations.Add(mutations_list[XRAY])

/obj/item/weapon/dnainjector/antixray
	name = "\improper DNA injector (Anti-Xray)"
	desc = "It will make you see harder."
	New()
		..()
		remove_mutations.Add(mutations_list[XRAY])

/////////////////////////////////////
/obj/item/weapon/dnainjector/antiglasses
	name = "\improper DNA injector (Anti-Glasses)"
	desc = "Toss away those glasses!"
	New()
		..()
		remove_mutations.Add(mutations_list[BADSIGHT])

/obj/item/weapon/dnainjector/glassesmut
	name = "\improper DNA injector (Glasses)"
	desc = "Will make you need dorkish glasses."
	New()
		..()
		add_mutations.Add(mutations_list[BADSIGHT])

/obj/item/weapon/dnainjector/epimut
	name = "\improper DNA injector (Epi.)"
	desc = "Shake shake shake the room!"
	New()
		..()
		add_mutations.Add(mutations_list[EPILEPSY])

/obj/item/weapon/dnainjector/antiepi
	name = "\improper DNA injector (Anti-Epi.)"
	desc = "Will fix you up from shaking the room."
	New()
		..()
		remove_mutations.Add(mutations_list[EPILEPSY])
////////////////////////////////////
/obj/item/weapon/dnainjector/anticough
	name = "\improper DNA injector (Anti-Cough)"
	desc = "Will stop that aweful noise."
	New()
		..()
		remove_mutations.Add(mutations_list[COUGH])

/obj/item/weapon/dnainjector/coughmut
	name = "\improper DNA injector (Cough)"
	desc = "Will bring forth a sound of horror from your throat."
	New()
		..()
		add_mutations.Add(mutations_list[COUGH])

/obj/item/weapon/dnainjector/antidwarf
	name = "\improper DNA injector (Anti-Dwarfism)"
	desc = "Helps you grow big and strong."
	New()
		..()
		remove_mutations.Add(mutations_list[DWARFISM])

/obj/item/weapon/dnainjector/dwarf
	name = "\improper DNA injector (Dwarfism)"
	desc = "Its a small world after all."
	New()
		..()
		add_mutations.Add(mutations_list[DWARFISM])

/obj/item/weapon/dnainjector/clumsymut
	name = "\improper DNA injector (Clumsy)"
	desc = "Makes clown minions."
	New()
		..()
		add_mutations.Add(mutations_list[CLOWNMUT])

/obj/item/weapon/dnainjector/anticlumsy
	name = "\improper DNA injector (Anti-Clumy)"
	desc = "Apply this for Security Clown."
	New()
		..()
		remove_mutations.Add(mutations_list[CLOWNMUT])

/obj/item/weapon/dnainjector/antitour
	name = "\improper DNA injector (Anti-Tour.)"
	desc = "Will cure tourrets."
	New()
		..()
		remove_mutations.Add(mutations_list[TOURETTES])

/obj/item/weapon/dnainjector/tourmut
	name = "\improper DNA injector (Tour.)"
	desc = "Gives you a nasty case off tourrets."
	New()
		..()
		add_mutations.Add(mutations_list[TOURETTES])

/obj/item/weapon/dnainjector/stuttmut
	name = "\improper DNA injector (Stutt.)"
	desc = "Makes you s-s-stuttterrr"
	New()
		..()
		add_mutations.Add(mutations_list[NERVOUS])

/obj/item/weapon/dnainjector/antistutt
	name = "\improper DNA injector (Anti-Stutt.)"
	desc = "Fixes that speaking impairment."
	New()
		..()
		remove_mutations.Add(mutations_list[NERVOUS])

/obj/item/weapon/dnainjector/antifire
	name = "\improper DNA injector (Anti-Fire)"
	desc = "Cures fire."
	New()
		..()
		remove_mutations.Add(mutations_list[COLDRES])

/obj/item/weapon/dnainjector/firemut
	name = "\improper DNA injector (Fire)"
	desc = "Gives you fire."
	New()
		..()
		add_mutations.Add(mutations_list[COLDRES])

/obj/item/weapon/dnainjector/blindmut
	name = "\improper DNA injector (Blind)"
	desc = "Makes you not see anything."
	New()
		..()
		add_mutations.Add(mutations_list[BLINDMUT])

/obj/item/weapon/dnainjector/antiblind
	name = "\improper DNA injector (Anti-Blind)"
	desc = "ITS A MIRACLE!!!"
	New()
		..()
		remove_mutations.Add(mutations_list[BLINDMUT])

/obj/item/weapon/dnainjector/antitele
	name = "\improper DNA injector (Anti-Tele.)"
	desc = "Will make you not able to control your mind."
	New()
		..()
		remove_mutations.Add(mutations_list[TK])

/obj/item/weapon/dnainjector/telemut
	name = "\improper DNA injector (Tele.)"
	desc = "Super brain man!"
	New()
		..()
		add_mutations.Add(mutations_list[TK])

/obj/item/weapon/dnainjector/telemut/darkbundle
	name = "\improper DNA injector"
	desc = "Good. Let the hate flow through you."

/obj/item/weapon/dnainjector/deafmut
	name = "\improper DNA injector (Deaf)"
	desc = "Sorry, what did you say?"
	New()
		..()
		add_mutations.Add(mutations_list[DEAFMUT])

/obj/item/weapon/dnainjector/antideaf
	name = "\improper DNA injector (Anti-Deaf)"
	desc = "Will make you hear once more."
	New()
		..()
		remove_mutations.Add(mutations_list[DEAFMUT])

/obj/item/weapon/dnainjector/h2m
	name = "\improper DNA injector (Human > Monkey)"
	desc = "Will make you a flea bag."
	New()
		..()
		add_mutations.Add(mutations_list[RACEMUT])

/obj/item/weapon/dnainjector/m2h
	name = "\improper DNA injector (Monkey > Human)"
	desc = "Will make you...less hairy."
	New()
		..()
		remove_mutations.Add(mutations_list[RACEMUT])

/obj/item/weapon/dnainjector/antistealth
	name = "\improper DNA injector (Anti-Cloak Of Darkness)"
	New()
		..()
		remove_mutations.Add(mutations_list[STEALTH])

/obj/item/weapon/dnainjector/stealthmut
	name = "\improper DNA injector (Cloak of Darkness)"
	desc = "Enables the subject to bend low levels of light around themselves, creating a cloaking effect."
	New()
		..()
		add_mutations.Add(mutations_list[STEALTH])

/obj/item/weapon/dnainjector/antichameleon
	name = "\improper DNA injector (Anti-Chameleon)"
	New()
		..()
		remove_mutations.Add(mutations_list[CHAMELEON])

/obj/item/weapon/dnainjector/chameleonmut
	name = "\improper DNA injector (Chameleon)"
	New()
		..()
		add_mutations.Add(mutations_list[CHAMELEON])

/obj/item/weapon/dnainjector/antiwacky
	name = "\improper DNA injector (Anti-Wacky)"
	New()
		..()
		remove_mutations.Add(mutations_list[WACKY])

/obj/item/weapon/dnainjector/wackymut
	name = "\improper DNA injector (Wacky)"
	New()
		..()
		add_mutations.Add(mutations_list[WACKY])

/obj/item/weapon/dnainjector/antimute
	name = "\improper DNA injector (Anti-Mute)"
	New()
		..()
		remove_mutations.Add(mutations_list[MUT_MUTE])

/obj/item/weapon/dnainjector/mutemut
	name = "\improper DNA injector (Mute)"
	New()
		..()
		add_mutations.Add(mutations_list[MUT_MUTE])

/obj/item/weapon/dnainjector/antismile
	name = "\improper DNA injector (Anti-Smile)"
	New()
		..()
		remove_mutations.Add(mutations_list[SMILE])

/obj/item/weapon/dnainjector/smilemut
	name = "\improper DNA injector (Smile)"
	New()
		..()
		add_mutations.Add(mutations_list[SMILE])

/obj/item/weapon/dnainjector/unintelligablemut
	name = "\improper DNA injector (Unintelligable)"
	New()
		..()
		add_mutations.Add(mutations_list[UNINTELLIGABLE])

/obj/item/weapon/dnainjector/antiunintelligable
	name = "\improper DNA injector (Anti-Unintelligable)"
	New()
		..()
		remove_mutations.Add(mutations_list[UNINTELLIGABLE])

/obj/item/weapon/dnainjector/swedishmut
	name = "\improper DNA injector (Swedish)"
	New()
		..()
		add_mutations.Add(mutations_list[SWEDISH])

/obj/item/weapon/dnainjector/antiswedish
	name = "\improper DNA injector (Anti-Swedish)"
	New()
		..()
		remove_mutations.Add(mutations_list[SWEDISH])

/obj/item/weapon/dnainjector/chavmut
	name = "\improper DNA injector (Chav)"
	New()
		..()
		add_mutations.Add(mutations_list[CHAV])

/obj/item/weapon/dnainjector/antichav
	name = "\improper DNA injector (Anti-Chav)"
	New()
		..()
		remove_mutations.Add(mutations_list[CHAV])

/obj/item/weapon/dnainjector/elvismut
	name = "\improper DNA injector (Elvis)"
	New()
		..()
		add_mutations.Add(mutations_list[ELVIS])

/obj/item/weapon/dnainjector/antielvis
	name = "\improper DNA injector (Anti-Elvis)"
	New()
		..()
		remove_mutations.Add(mutations_list[ELVIS])

/obj/item/weapon/dnainjector/lasereyesmut
	name = "\improper DNA injector (Laser Eyes)"
	New()
		..()
		add_mutations.Add(mutations_list[LASEREYES])

/obj/item/weapon/dnainjector/antilasereyes
	name = "\improper DNA injector (Anti-Laser Eyes)"
	New()
		..()
		remove_mutations.Add(mutations_list[LASEREYES])

/obj/item/weapon/dnainjector/timed
	var/duration = 600

/obj/item/weapon/dnainjector/timed/inject(mob/living/carbon/M, mob/user)
	if(M.has_dna() && !(M.disabilities & NOCLONE))
		if(M.stat == DEAD)	//prevents dead people from having their DNA changed
			user << "<span class='notice'>You can't modify [M]'s DNA while \he's dead.</span>"
			return
		M.radiation += rand(20/(damage_coeff  ** 2),50/(damage_coeff  ** 2))
		var/log_msg = "[key_name(user)] injected [key_name(M)] with the [name]"
		var/endtime = world.time+duration
		for(var/datum/mutation/human/HM in remove_mutations)
			if(HM.name == RACEMUT)
				if(ishuman(M))
					continue
				M = HM.force_lose(M)
			else
				HM.force_lose(M)
		for(var/datum/mutation/human/HM in add_mutations)
			if((HM in M.dna.mutations) && !(M.dna.temporary_mutations[HM.name]))
				continue //Skip permanent mutations we already have.
			if(HM.name == RACEMUT && ishuman(M))
				message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [name] <span class='danger'>(MONKEY)</span>")
				log_msg += " (MONKEY)"
				M = HM.force_give(M)
			else
				HM.force_give(M)
			M.dna.temporary_mutations[HM.name] = endtime
		if(fields)
			if(fields["name"] && fields["UE"] && fields["blood_type"])
				if(!M.dna.previous["name"])
					M.dna.previous["name"] = M.real_name
				if(!M.dna.previous["UE"])
					M.dna.previous["UE"] = M.dna.unique_enzymes
				if(!M.dna.previous["blood_type"])
					M.dna.previous["blood_type"] = M.dna.blood_type
				M.real_name = fields["name"]
				M.dna.unique_enzymes = fields["UE"]
				M.name = M.real_name
				M.dna.blood_type = fields["blood_type"]
				M.dna.temporary_mutations[UE_CHANGED] = endtime
			if(fields["UI"])	//UI+UE
				if(!M.dna.previous["UI"])
					M.dna.previous["UI"] = M.dna.uni_identity
				M.dna.uni_identity = merge_text(M.dna.uni_identity, fields["UI"])
				M.updateappearance(mutations_overlay_update=1)
				M.dna.temporary_mutations[UI_CHANGED] = endtime
		log_attack(log_msg)
	else
		user << "<span class='notice'>It appears that [M] does not have compatible DNA.</span>"
		return

/obj/item/weapon/dnainjector/timed/hulk
	name = "\improper DNA injector (Hulk)"
	desc = "This will make you big and strong, but give you a bad skin condition."
	New()
		..()
		add_mutations.Add(mutations_list[HULK])

/obj/item/weapon/dnainjector/timed/h2m
	name = "\improper DNA injector (Human > Monkey)"
	desc = "Will make you a flea bag."
	New()
		..()
		add_mutations.Add(mutations_list[RACEMUT])
