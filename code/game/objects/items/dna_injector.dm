/obj/item/dnainjector
	name = "\improper DNA injector"
	desc = "This injects the person with DNA."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "dnainjector"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY

	var/damage_coeff  = 1
	var/list/fields
	var/list/add_mutations = list()
	var/list/remove_mutations = list()

	var/used = 0

/obj/item/dnainjector/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/dnainjector/proc/inject(mob/living/carbon/M, mob/user)
	if(M.has_dna() && !M.has_trait(TRAIT_RADIMMUNE) && !M.has_trait(TRAIT_NOCLONE))
		M.radiation += rand(20/(damage_coeff  ** 2),50/(damage_coeff  ** 2))
		var/log_msg = "[key_name(user)] injected [key_name(M)] with the [name]"
		for(var/HM in remove_mutations)
			M.dna.remove_mutation(HM)
		for(var/HM in add_mutations)
			if(HM == RACEMUT)
				message_admins("[ADMIN_LOOKUPFLW(user)] injected [key_name_admin(M)] with the [name] <span class='danger'>(MONKEY)</span>")
				log_msg += " (MONKEY)"
			if(mutation_in_sequence(HM, M.dna))
				M.dna.activate_mutation(HM)
			else
				M.dna.add_mutation(HM, MUT_EXTRA)
		if(fields)
			if(fields["name"] && fields["UE"] && fields["blood_type"])
				M.real_name = fields["name"]
				M.dna.unique_enzymes = fields["UE"]
				M.name = M.real_name
				M.dna.blood_type = fields["blood_type"]
			if(fields["UI"])	//UI+UE
				M.dna.uni_identity = merge_text(M.dna.uni_identity, fields["UI"])
				M.updateappearance(mutations_overlay_update=1)
		log_attack("[log_msg] [loc_name(user)]")
		return TRUE
	return FALSE

/obj/item/dnainjector/attack(mob/target, mob/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(used)
		to_chat(user, "<span class='warning'>This injector is used up!</span>")
		return
	if(ishuman(target))
		var/mob/living/carbon/human/humantarget = target
		if (!humantarget.can_inject(user, 1))
			return
	log_combat(user, target, "attempted to inject", src)

	if(target != user)
		target.visible_message("<span class='danger'>[user] is trying to inject [target] with [src]!</span>", "<span class='userdanger'>[user] is trying to inject [target] with [src]!</span>")
		if(!do_mob(user, target) || used)
			return
		target.visible_message("<span class='danger'>[user] injects [target] with the syringe with [src]!", \
						"<span class='userdanger'>[user] injects [target] with the syringe with [src]!</span>")

	else
		to_chat(user, "<span class='notice'>You inject yourself with [src].</span>")

	log_combat(user, target, "injected", src)

	if(!inject(target, user))	//Now we actually do the heavy lifting.
		to_chat(user, "<span class='notice'>It appears that [target] does not have compatible DNA.</span>")

	used = 1
	icon_state = "dnainjector0"
	desc += " This one is used up."


/obj/item/dnainjector/antihulk
	name = "\improper DNA injector (Anti-Hulk)"
	desc = "Cures green skin."
	remove_mutations = list(HULK)

/obj/item/dnainjector/hulkmut
	name = "\improper DNA injector (Hulk)"
	desc = "This will make you big and strong, but give you a bad skin condition."
	add_mutations = list(HULK)

/obj/item/dnainjector/xraymut
	name = "\improper DNA injector (X-ray)"
	desc = "Finally you can see what the Captain does."
	add_mutations = list(XRAY)

/obj/item/dnainjector/antixray
	name = "\improper DNA injector (Anti-X-ray)"
	desc = "It will make you see harder."
	remove_mutations = list(XRAY)

/////////////////////////////////////
/obj/item/dnainjector/antiglasses
	name = "\improper DNA injector (Anti-Glasses)"
	desc = "Toss away those glasses!"
	remove_mutations = list(BADSIGHT)

/obj/item/dnainjector/glassesmut
	name = "\improper DNA injector (Glasses)"
	desc = "Will make you need dorkish glasses."
	add_mutations = list(BADSIGHT)

/obj/item/dnainjector/epimut
	name = "\improper DNA injector (Epi.)"
	desc = "Shake shake shake the room!"
	add_mutations = list(EPILEPSY)

/obj/item/dnainjector/antiepi
	name = "\improper DNA injector (Anti-Epi.)"
	desc = "Will fix you up from shaking the room."
	remove_mutations = list(EPILEPSY)
////////////////////////////////////
/obj/item/dnainjector/anticough
	name = "\improper DNA injector (Anti-Cough)"
	desc = "Will stop that awful noise."
	remove_mutations = list(COUGH)

/obj/item/dnainjector/coughmut
	name = "\improper DNA injector (Cough)"
	desc = "Will bring forth a sound of horror from your throat."
	add_mutations = list(COUGH)

/obj/item/dnainjector/antidwarf
	name = "\improper DNA injector (Anti-Dwarfism)"
	desc = "Helps you grow big and strong."
	remove_mutations = list(DWARFISM)

/obj/item/dnainjector/dwarf
	name = "\improper DNA injector (Dwarfism)"
	desc = "It's a small world after all."
	add_mutations = list(DWARFISM)

/obj/item/dnainjector/clumsymut
	name = "\improper DNA injector (Clumsy)"
	desc = "Makes clown minions."
	add_mutations = list(CLOWNMUT)

/obj/item/dnainjector/anticlumsy
	name = "\improper DNA injector (Anti-Clumsy)"
	desc = "Apply this for Security Clown."
	remove_mutations = list(CLOWNMUT)

/obj/item/dnainjector/antitour
	name = "\improper DNA injector (Anti-Tour.)"
	desc = "Will cure Tourette's."
	remove_mutations = list(TOURETTES)

/obj/item/dnainjector/tourmut
	name = "\improper DNA injector (Tour.)"
	desc = "Gives you a nasty case of Tourette's."
	add_mutations = list(TOURETTES)

/obj/item/dnainjector/stuttmut
	name = "\improper DNA injector (Stutt.)"
	desc = "Makes you s-s-stuttterrr."
	add_mutations = list(NERVOUS)

/obj/item/dnainjector/antistutt
	name = "\improper DNA injector (Anti-Stutt.)"
	desc = "Fixes that speaking impairment."
	remove_mutations = list(NERVOUS)

/obj/item/dnainjector/antifire
	name = "\improper DNA injector (Anti-Fire)"
	desc = "Cures fire."
	remove_mutations = list(SPACEMUT)

/obj/item/dnainjector/firemut
	name = "\improper DNA injector (Fire)"
	desc = "Gives you fire."
	add_mutations = list(SPACEMUT)

/obj/item/dnainjector/blindmut
	name = "\improper DNA injector (Blind)"
	desc = "Makes you not see anything."
	add_mutations = list(BLINDMUT)

/obj/item/dnainjector/antiblind
	name = "\improper DNA injector (Anti-Blind)"
	desc = "IT'S A MIRACLE!!!"
	remove_mutations = list(BLINDMUT)

/obj/item/dnainjector/antitele
	name = "\improper DNA injector (Anti-Tele.)"
	desc = "Will make you not able to control your mind."
	remove_mutations = list(TK)

/obj/item/dnainjector/telemut
	name = "\improper DNA injector (Tele.)"
	desc = "Super brain man!"
	add_mutations = list(TK)

/obj/item/dnainjector/telemut/darkbundle
	name = "\improper DNA injector"
	desc = "Good. Let the hate flow through you."

/obj/item/dnainjector/deafmut
	name = "\improper DNA injector (Deaf)"
	desc = "Sorry, what did you say?"
	add_mutations = list(DEAFMUT)

/obj/item/dnainjector/antideaf
	name = "\improper DNA injector (Anti-Deaf)"
	desc = "Will make you hear once more."
	remove_mutations = list(DEAFMUT)

/obj/item/dnainjector/h2m
	name = "\improper DNA injector (Human > Monkey)"
	desc = "Will make you a flea bag."
	add_mutations = list(RACEMUT)

/obj/item/dnainjector/m2h
	name = "\improper DNA injector (Monkey > Human)"
	desc = "Will make you...less hairy."
	remove_mutations = list(RACEMUT)

/obj/item/dnainjector/antichameleon
	name = "\improper DNA injector (Anti-Chameleon)"
	remove_mutations = list(CHAMELEON)

/obj/item/dnainjector/chameleonmut
	name = "\improper DNA injector (Chameleon)"
	add_mutations = list(CHAMELEON)

/obj/item/dnainjector/antiwacky
	name = "\improper DNA injector (Anti-Wacky)"
	remove_mutations = list(WACKY)

/obj/item/dnainjector/wackymut
	name = "\improper DNA injector (Wacky)"
	add_mutations = list(WACKY)

/obj/item/dnainjector/antimute
	name = "\improper DNA injector (Anti-Mute)"
	remove_mutations = list(MUT_MUTE)

/obj/item/dnainjector/mutemut
	name = "\improper DNA injector (Mute)"
	add_mutations = list(MUT_MUTE)

/obj/item/dnainjector/antismile
	name = "\improper DNA injector (Anti-Smile)"
	remove_mutations = list(SMILE)

/obj/item/dnainjector/smilemut
	name = "\improper DNA injector (Smile)"
	add_mutations = list(SMILE)

/obj/item/dnainjector/unintelligiblemut
	name = "\improper DNA injector (Unintelligible)"
	add_mutations = list(UNINTELLIGIBLE)

/obj/item/dnainjector/antiunintelligible
	name = "\improper DNA injector (Anti-Unintelligible)"
	remove_mutations = list(UNINTELLIGIBLE)

/obj/item/dnainjector/swedishmut
	name = "\improper DNA injector (Swedish)"
	add_mutations = list(SWEDISH)

/obj/item/dnainjector/antiswedish
	name = "\improper DNA injector (Anti-Swedish)"
	remove_mutations = list(SWEDISH)

/obj/item/dnainjector/chavmut
	name = "\improper DNA injector (Chav)"
	add_mutations = list(CHAV)

/obj/item/dnainjector/antichav
	name = "\improper DNA injector (Anti-Chav)"
	remove_mutations = list(CHAV)

/obj/item/dnainjector/elvismut
	name = "\improper DNA injector (Elvis)"
	add_mutations = list(ELVIS)

/obj/item/dnainjector/antielvis
	name = "\improper DNA injector (Anti-Elvis)"
	remove_mutations = list(ELVIS)

/obj/item/dnainjector/lasereyesmut
	name = "\improper DNA injector (Laser Eyes)"
	add_mutations = list(LASEREYES)

/obj/item/dnainjector/antilasereyes
	name = "\improper DNA injector (Anti-Laser Eyes)"
	remove_mutations = list(LASEREYES)

/obj/item/dnainjector/timed
	var/duration = 600

/obj/item/dnainjector/timed/inject(mob/living/carbon/M, mob/user)
	if(M.stat == DEAD)	//prevents dead people from having their DNA changed
		to_chat(user, "<span class='notice'>You can't modify [M]'s DNA while [M.p_theyre()] dead.</span>")
		return FALSE

	if(M.has_dna() && !(M.has_trait(TRAIT_NOCLONE)))
		M.radiation += rand(20/(damage_coeff  ** 2),50/(damage_coeff  ** 2))
		var/log_msg = "[key_name(user)] injected [key_name(M)] with the [name]"
		var/endtime = world.time+duration
		for(var/mutation in remove_mutations)
			if(mutation == RACEMUT)
				if(ishuman(M))
					continue
				M = M.dna.remove_mutation(mutation)
			else
				M.dna.remove_mutation(mutation)
		for(var/mutation in add_mutations)
			if(M.dna.get_mutation(mutation))
				continue //Skip permanent mutations we already have.
			if(mutation == RACEMUT && ishuman(M))
				message_admins("[ADMIN_LOOKUPFLW(user)] injected [key_name_admin(M)] with the [name] <span class='danger'>(MONKEY)</span>")
				log_msg += " (MONKEY)"
				M = M.dna.add_mutation(mutation, MUT_OTHER, endtime)
			else
				M.dna.add_mutation(mutation, MUT_OTHER, endtime)
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
		log_attack("[log_msg] [loc_name(user)]")
		return TRUE
	else
		return FALSE

/obj/item/dnainjector/timed/hulk
	name = "\improper DNA injector (Hulk)"
	desc = "This will make you big and strong, but give you a bad skin condition."
	add_mutations = list(HULK)

/obj/item/dnainjector/timed/h2m
	name = "\improper DNA injector (Human > Monkey)"
	desc = "Will make you a flea bag."
	add_mutations = list(RACEMUT)

/obj/item/dnainjector/activator
	name = "\improper DNA activator"
	desc = "Activates the current mutation on injection, if the subject has it."
	var/doitanyway = FALSE

/obj/item/dnainjector/activator/inject(mob/living/carbon/M, mob/user)
	if(M.has_dna() && !M.has_trait(TRAIT_RADIMMUNE) && !M.has_trait(TRAIT_NOCLONE))
		M.radiation += rand(20/(damage_coeff  ** 2),50/(damage_coeff  ** 2))
		var/log_msg = "[key_name(user)] injected [key_name(M)] with the [name]"
		for(var/mutation in add_mutations)
			if(!M.dna.activate_mutation(mutation) && !doitanyway)
				log_msg += "(FAILED)"
			else if(doitanyway)
				M.dna.add_mutation(mutation, MUT_EXTRA)
			log_msg += "([mutation])"
		log_attack("[log_msg] [loc_name(user)]")
		M.dna.update_instability(TRUE)
		return TRUE
	return FALSE

