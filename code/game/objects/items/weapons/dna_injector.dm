/obj/item/weapon/dnainjector
	name = "\improper DNA injector"
	desc = "This injects the person with DNA."
	icon = 'icons/obj/items.dmi'
	icon_state = "dnainjector"
	throw_speed = 3
	throw_range = 5
	w_class = 1.0

	var/damage_coeff  = 1
	var/list/fields
	var/list/add_mutations = list()
	var/list/remove_mutations = list()

/obj/item/weapon/dnainjector/attack_paw(mob/user)
	return attack_hand(user)


/obj/item/weapon/dnainjector/proc/inject(mob/living/carbon/M, mob/user)
	if(check_dna_integrity(M) && !(NOCLONE in M.mutations))
		if(M.stat == DEAD)	//prevents dead people from having their DNA changed
			user << "<span class='notice'>You can't modify [M]'s DNA while \he's dead.</span>"
			return
		M.radiation += rand(20/(damage_coeff  ** 2),50/(damage_coeff  ** 2))
		var/log_msg = "[key_name(user)] injected [key_name(M)] with the [name]"
		for(var/datum/mutation/human/HM in remove_mutations)
			HM.on_losing(M)
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
				updateappearance(M)
		log_attack(log_msg)
	else
		user << "<span class='notice'>It appears that [M] does not have compatible DNA.</span>"
		return

/obj/item/weapon/dnainjector/attack(mob/target, mob/user)
	if(!user.IsAdvancedToolUser())
		user << "<span class='notice'>You don't have the dexterity to do this!</span>"
		return
	add_logs(user, target, "attempted to inject", object="[name]")

	if(target != user)
		target.visible_message("<span class='danger'>[user] is trying to inject [target] with [src]!</span>", "<span class='userdanger'>[user] is trying to inject [target] with [src]!</span>")
		if(!do_mob(user, target))	return
		target.visible_message("<span class='danger'>[user] injects [target] with the syringe with [src]!", \
						"<span class='userdanger'>[user] injects [target] with the syringe with [src]!")

	else
		user << "<span class='notice'>You inject yourself with [src].</span>"

	add_logs(user, target, "injected", object="[name]")

	inject(target, user)	//Now we actually do the heavy lifting.
	qdel(src)


/obj/item/weapon/dnainjector/antihulk
	name = "\improper DNA injector (Anti-Hulk)"
	desc = "Cures green skin."

/obj/item/weapon/dnainjector/antihulk/New()
	..()
	remove_mutations.Add(mutations_list[HULK])

/obj/item/weapon/dnainjector/hulkmut
	name = "\improper DNA injector (Hulk)"
	desc = "This will make you big and strong, but give you a bad skin condition."

/obj/item/weapon/dnainjector/hulkmut/New()
	..()
	add_mutations.Add(mutations_list[HULK])

/obj/item/weapon/dnainjector/xraymut
	name = "\improper DNA injector (Xray)"
	desc = "Finally you can see what the Captain does."

/obj/item/weapon/dnainjector/xraymut/New()
	..()
	add_mutations.Add(mutations_list[XRAY])

/obj/item/weapon/dnainjector/antixray
	name = "\improper DNA injector (Anti-Xray)"
	desc = "It will make you see harder."

/obj/item/weapon/dnainjector/antixray/New()
	..()
	remove_mutations.Add(mutations_list[XRAY])

/////////////////////////////////////
/obj/item/weapon/dnainjector/antiglasses
	name = "\improper DNA injector (Anti-Glasses)"
	desc = "Toss away those glasses!"

/obj/item/weapon/dnainjector/antiglasses/New()
	..()
	remove_mutations.Add(mutations_list[BADSIGHT])

/obj/item/weapon/dnainjector/glassesmut
	name = "\improper DNA injector (Glasses)"
	desc = "Will make you need dorkish glasses."

/obj/item/weapon/dnainjector/glassesmut/New()
	..()
	add_mutations.Add(mutations_list[BADSIGHT])

/obj/item/weapon/dnainjector/epimut
	name = "\improper DNA injector (Epi.)"
	desc = "Shake shake shake the room!"

/obj/item/weapon/dnainjector/epimut/New()
	..()
	add_mutations.Add(mutations_list[EPILEPSY])

/obj/item/weapon/dnainjector/antiepi
	name = "\improper DNA injector (Anti-Epi.)"
	desc = "Will fix you up from shaking the room."

/obj/item/weapon/dnainjector/antiepi/New()
	..()
	remove_mutations.Add(mutations_list[EPILEPSY])

////////////////////////////////////
/obj/item/weapon/dnainjector/anticough
	name = "\improper DNA injector (Anti-Cough)"
	desc = "Will stop that aweful noise."

/obj/item/weapon/dnainjector/anticough/New()
	..()
	remove_mutations.Add(mutations_list[COUGH])

/obj/item/weapon/dnainjector/coughmut
	name = "\improper DNA injector (Cough)"
	desc = "Will bring forth a sound of horror from your throat."

/obj/item/weapon/dnainjector/coughmut/New()
	..()
	add_mutations.Add(mutations_list[COUGH])

/obj/item/weapon/dnainjector/clumsymut
	name = "\improper DNA injector (Clumsy)"
	desc = "Makes clown minions."

/obj/item/weapon/dnainjector/clumsymut/New()
	..()
	add_mutations.Add(mutations_list[CLOWNMUT])

/obj/item/weapon/dnainjector/anticlumsy
	name = "\improper DNA injector (Anti-Clumy)"
	desc = "Apply this for Security Clown."

/obj/item/weapon/dnainjector/anticlumsy/New()
	..()
	remove_mutations.Add(mutations_list[CLOWNMUT])

/obj/item/weapon/dnainjector/antitour
	name = "\improper DNA injector (Anti-Tour.)"
	desc = "Will cure tourrets."

/obj/item/weapon/dnainjector/antitour/New()
	..()
	remove_mutations.Add(mutations_list[TOURETTES])

/obj/item/weapon/dnainjector/tourmut
	name = "\improper DNA injector (Tour.)"
	desc = "Gives you a nasty case off tourrets."

/obj/item/weapon/dnainjector/tourmut/New()
	..()
	add_mutations.Add(mutations_list[TOURETTES])

/obj/item/weapon/dnainjector/stuttmut
	name = "\improper DNA injector (Stutt.)"
	desc = "Makes you s-s-stuttterrr"

/obj/item/weapon/dnainjector/stuttmut/New()
	..()
	add_mutations.Add(mutations_list[NERVOUS])

/obj/item/weapon/dnainjector/antistutt
	name = "\improper DNA injector (Anti-Stutt.)"
	desc = "Fixes that speaking impairment."

/obj/item/weapon/dnainjector/antistutt/New()
	..()
	remove_mutations.Add(mutations_list[NERVOUS])

/obj/item/weapon/dnainjector/antifire
	name = "\improper DNA injector (Anti-Fire)"
	desc = "Cures fire."

/obj/item/weapon/dnainjector/antifire/New()
	..()
	remove_mutations.Add(mutations_list[COLDRES])

/obj/item/weapon/dnainjector/firemut
	name = "\improper DNA injector (Fire)"
	desc = "Gives you fire."

/obj/item/weapon/dnainjector/firemut/New()
	..()
	add_mutations.Add(mutations_list[COLDRES])

/obj/item/weapon/dnainjector/blindmut
	name = "\improper DNA injector (Blind)"
	desc = "Makes you not see anything."

/obj/item/weapon/dnainjector/blindmut/New()
	..()
	add_mutations.Add(mutations_list[BLINDMUT])

/obj/item/weapon/dnainjector/antiblind
	name = "\improper DNA injector (Anti-Blind)"
	desc = "ITS A MIRACLE!!!"

/obj/item/weapon/dnainjector/antiblind/New()
	..()
	remove_mutations.Add(mutations_list[BLINDMUT])

/obj/item/weapon/dnainjector/antitele
	name = "\improper DNA injector (Anti-Tele.)"
	desc = "Will make you not able to control your mind."

/obj/item/weapon/dnainjector/antitele/New()
	..()
	remove_mutations.Add(mutations_list[TK])

/obj/item/weapon/dnainjector/telemut
	name = "\improper DNA injector (Tele.)"
	desc = "Super brain man!"

/obj/item/weapon/dnainjector/telemut/New()
	..()
	add_mutations.Add(mutations_list[TK])

/obj/item/weapon/dnainjector/telemut/darkbundle
	name = "\improper DNA injector"
	desc = "Good. Let the hate flow through you."

/obj/item/weapon/dnainjector/deafmut
	name = "\improper DNA injector (Deaf)"
	desc = "Sorry, what did you say?"

/obj/item/weapon/dnainjector/deafmut/New()
	..()
	add_mutations.Add(mutations_list[DEAFMUT])

/obj/item/weapon/dnainjector/antideaf
	name = "\improper DNA injector (Anti-Deaf)"
	desc = "Will make you hear once more."

/obj/item/weapon/dnainjector/antideaf/New()
	..()
	remove_mutations.Add(mutations_list[DEAFMUT])

/obj/item/weapon/dnainjector/h2m
	name = "\improper DNA injector (Human > Monkey)"
	desc = "Will make you a flea bag."

/obj/item/weapon/dnainjector/h2m/New()
	..()
	add_mutations.Add(mutations_list[RACEMUT])

/obj/item/weapon/dnainjector/m2h
	name = "\improper DNA injector (Monkey > Human)"
	desc = "Will make you...less hairy."

/obj/item/weapon/dnainjector/m2h/New()
	..()
	remove_mutations.Add(mutations_list[RACEMUT])