/mob/proc/make_lesser_changeling()
	src.verbs += /client/proc/changeling_lesser_transform
	src.verbs += /client/proc/changeling_fakedeath

	spawn(600)
		src.verbs += /client/proc/changeling_neurotoxic_sting
		src.verbs += /client/proc/changeling_hallucinogenic_sting

	src.changeling_level = 1
	return

/mob/proc/make_changeling()
	src.verbs += /client/proc/changeling_absorb_dna
	src.verbs += /client/proc/changeling_transform
	src.verbs += /client/proc/changeling_lesser_form
	src.verbs += /client/proc/changeling_fakedeath

	spawn(600)
		src.verbs += /client/proc/changeling_neurotoxic_sting
		src.verbs += /client/proc/changeling_hallucinogenic_sting

	src.changeling_level = 2
	return

/mob/proc/remove_changeling_powers()
	src.verbs -= /client/proc/changeling_absorb_dna
	src.verbs -= /client/proc/changeling_transform
	src.verbs -= /client/proc/changeling_lesser_form
	src.verbs -= /client/proc/changeling_lesser_transform
	src.verbs -= /client/proc/changeling_fakedeath
	src.verbs -= /client/proc/changeling_neurotoxic_sting
	src.verbs -= /client/proc/changeling_hallucinogenic_sting

/client/proc/changeling_absorb_dna()
	set category = "Changeling"
	set name = "Absorb DNA"

	if(usr.stat)
		usr << "\red Not when we are incapacitated."
		return

	if (!istype(usr.equipped(), /obj/item/weapon/grab))
		usr << "\red We must be grabbing a creature in our active hand to absorb them."
		return

	var/obj/item/weapon/grab/G = usr.equipped()
	var/mob/M = G.affecting

	if (!ishuman(M))
		usr << "\red This creature is not compatible with our biology."
		return

	if (!G.killing)
		usr << "\red We must have a tighter grip to absorb this creature."
		return

	var/mob/living/carbon/human/T = M

	usr << "\blue This creature is compatible. We must hold still..."

	if (!do_mob(usr, T, 200))
		usr << "\red Our absorption of [T] has been interrupted!"
		return

	usr << "\blue We extend a proboscis."
	usr.visible_message(text("\red <B>[usr] extends a proboscis!</B>"))

	if (!do_mob(usr, T, 200))
		usr << "\red Our absorption of [T] has been interrupted!"
		return

	usr << "\blue We stab [T] with the proboscis."
	usr.visible_message(text("\red <B>[usr] stabs [T] with the proboscis!</B>"))
	T << "\red <B>You feel a sharp stabbing pain!</B>"
	T.bruteloss += 40

	if (!do_mob(usr, T, 200))
		usr << "\red Our absorption of [T] has been interrupted!"
		return

	usr << "\blue We have absorbed [T]!"
	usr.visible_message(text("\red <B>[usr] sucks the fluids from [T]!</B>"))
	T << "\red <B>You have been absorbed by the changeling!</B>"

	usr.absorbed_dna[T.real_name] = T.dna

	T.death(0)
	T.real_name = "Unknown"
	T.mutations |= 64
	T.update_body()

	return

/client/proc/changeling_transform()
	set category = "Changeling"
	set name = "Transform"
	if(usr.stat)
		usr << "\red Not when we are incapacitated."
		return

	if (usr.absorbed_dna.len <= 0)
		usr << "\red We have not yet absorbed any compatible DNA."
		return

	var/S = input("Select the target DNA: ", "Target DNA", null) in usr.absorbed_dna

	if (S == null)
		return

	usr.visible_message(text("\red <B>[usr] transforms!</B>"))

	usr.dna = usr.absorbed_dna[S]
	usr.real_name = S
	updateappearance(usr, usr.dna.uni_identity)
	domutcheck(usr, null)
	return

/client/proc/changeling_lesser_form()
	set category = "Changeling"
	set name = "Lesser Form"

	if(usr.stat)
		usr << "\red Not when we are incapacitated."
		return

	usr.remove_changeling_powers()

	usr.visible_message(text("\red <B>[usr] transforms!</B>"))

	var/list/implants = list() //Try to preserve implants.
	for(var/obj/item/weapon/W in usr)
		if (istype(W, /obj/item/weapon/implant))
			implants += W

	for(var/obj/item/W in usr)
		usr.u_equip(W)
		if (usr.client)
			usr.client.screen -= W
		if (W)
			W.loc = usr.loc
			W.dropped(usr)
			W.layer = initial(W.layer)

	usr.update_clothing()
	usr.monkeyizing = 1
	usr.canmove = 0
	usr.icon = null
	usr.invisibility = 101
	var/atom/movable/overlay/animation = new /atom/movable/overlay( usr.loc )
	animation.icon_state = "blank"
	animation.icon = 'mob.dmi'
	animation.master = src
	flick("h2monkey", animation)
	sleep(48)
	del(animation)

	var/mob/living/carbon/monkey/O = new /mob/living/carbon/monkey(src)
	O.dna = usr.dna
	usr.dna = null
	O.absorbed_dna = usr.absorbed_dna

	for(var/obj/T in usr)
		del(T)
	for(var/R in usr.organs)
		del(usr.organs[text("[]", R)])

	O.loc = usr.loc

	O.name = text("monkey ([])",copytext(md5(usr.real_name), 2, 6))
	O.toxloss = usr.toxloss
	O.bruteloss = usr.bruteloss
	O.oxyloss = usr.oxyloss
	O.fireloss = usr.fireloss
	O.stat = usr.stat
	O.a_intent = "hurt"
	for (var/obj/item/weapon/implant/I in implants)
		I.loc = O
		I.implanted = O
		continue

	if(usr.mind)
		usr.mind.transfer_to(O)

	O.make_lesser_changeling()

	del(usr)
	return

/client/proc/changeling_lesser_transform()
	set category = "Changeling"
	set name = "Transform"

	if(usr.stat)
		usr << "\red Not when we are incapacitated."
		return

	if (usr.absorbed_dna.len <= 0)
		usr << "\red We have not yet absorbed any compatible DNA."
		return

	var/S = input("Select the target DNA: ", "Target DNA", null) in usr.absorbed_dna

	if (S == null)
		return

	usr.remove_changeling_powers()

	usr.visible_message(text("\red <B>[usr] transforms!</B>"))

	usr.dna = usr.absorbed_dna[S]

	var/list/implants = list()
	for (var/obj/item/weapon/implant/I in usr) //Still preserving implants
		implants += I

	for(var/obj/item/W in usr)
		usr.u_equip(W)
		if (usr.client)
			usr.client.screen -= W
		if (W)
			W.loc = usr.loc
			W.dropped(usr)
			W.layer = initial(W.layer)

	usr.update_clothing()
	usr.monkeyizing = 1
	usr.canmove = 0
	usr.icon = null
	usr.invisibility = 101
	var/atom/movable/overlay/animation = new /atom/movable/overlay( usr.loc )
	animation.icon_state = "blank"
	animation.icon = 'mob.dmi'
	animation.master = src
	flick("monkey2h", animation)
	sleep(48)
	del(animation)

	var/mob/living/carbon/human/O = new /mob/living/carbon/human( src )
	if (isblockon(getblock(usr.dna.uni_identity, 11,3),11))
		O.gender = FEMALE
	else
		O.gender = MALE
	O.dna = usr.dna
	usr.dna = null
	O.absorbed_dna = usr.absorbed_dna
	O.real_name = S

	for(var/obj/T in usr)
		del(T)

	O.loc = usr.loc

	updateappearance(O,O.dna.uni_identity)
	domutcheck(O, null)
	O.toxloss = usr.toxloss
	O.bruteloss = usr.bruteloss
	O.oxyloss = usr.oxyloss
	O.fireloss = usr.fireloss
	O.stat = usr.stat
	for (var/obj/item/weapon/implant/I in implants)
		I.loc = O
		I.implanted = O
		continue

	if(usr.mind)
		usr.mind.transfer_to(O)

	O.make_changeling()

	del(usr)
	return

/client/proc/changeling_fakedeath()
	set category = "Changeling"
	set name = "Regenerative Stasis"

	if(usr.stat == 2)
		usr << "\red We are dead."
		return

	usr << "\blue We will regenerate our form."

	usr.lying = 1
	usr.canmove = 0
	usr.changeling_fakedeath = 1
	usr.remove_changeling_powers()

	usr.emote("gasp")

	spawn(600)
		if (usr.stat != 2)
			if(istype(usr, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = usr
				for(var/A in H.organs)
					var/datum/organ/external/affecting = null
					if(!H.organs[A])    continue
					affecting = H.organs[A]
					if(!istype(affecting, /datum/organ/external))    continue
					affecting.heal_damage(1000, 1000)    //fixes getting hit after ingestion, killing you when game updates organ health
				H.UpdateDamageIcon()
			usr.fireloss = 0
			usr.toxloss = 0
			usr.bruteloss = 0
			usr.oxyloss = 0
			usr.paralysis = 0
			usr.stunned = 0
			usr.weakened = 0
			usr.radiation = 0
			usr.health = 100
			usr.updatehealth()
			usr.reagents.clear_reagents()
			usr.lying = 0
			usr.canmove = 1
			usr << "\blue We have regenerated."
			usr.visible_message(text("\red <B>[usr] appears to wake from the dead, having healed all wounds.</B>"))

		usr.changeling_fakedeath = 0
		if (usr.changeling_level == 1)
			usr.make_lesser_changeling()
		else if (usr.changeling_level == 2)
			usr.make_changeling()

	return

/client/proc/changeling_neurotoxic_sting(mob/T as mob in oview(1))
	set category = "Changeling"
	set name = "Neurotoxic Venom"
	set desc="Sting target:"

	if(usr.stat)
		usr << "\red Not when we are incapacitated."
		return

	usr << "\blue We stealthily sting [T]."
	T << "You feel a small prick and a burning sensation."

	/* These are the normal sting, commented out for testing upgraded sting

	T.reagents.add_reagent("toxin", 10)
	T.reagents.add_reagent("stoxin", 20)

	*/

	// These reagents are copied from the sleepy-pen, testing for the changeling super-sting bio upgrade

	T.reagents.add_reagent("stoxin", 100)
	T.reagents.add_reagent("impedrezene", 100)
	T.reagents.add_reagent("cryptobiolin", 100)

	usr.verbs -= /client/proc/changeling_neurotoxic_sting

	spawn(600)
		usr.verbs += /client/proc/changeling_neurotoxic_sting

	return

/client/proc/changeling_hallucinogenic_sting(mob/T as mob in oview(1))
	set category = "Changeling"
	set name = "Hallucinogenic Venom"
	set desc="Sting target:"

	if(usr.stat)
		usr << "\red Not when we are incapacitated."
		return

	usr << "\blue We stealthily sting [T]."

	spawn(50) //Give the changeling a chance to calmly walk away before the target FREAKS THE FUCK OUT
		T.reagents.add_reagent("space_drugs", 5)

	usr.verbs -= /client/proc/changeling_hallucinogenic_sting

	spawn(600)
		usr.verbs += /client/proc/changeling_hallucinogenic_sting

	return