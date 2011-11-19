/mob/proc/make_lesser_changeling()
	if(!changeling) changeling = new
	changeling.host = src

	src.verbs += /client/proc/changeling_lesser_transform
	src.verbs += /client/proc/changeling_fakedeath

	src.verbs += /client/proc/changeling_blind_sting
	src.verbs += /client/proc/changeling_deaf_sting
	src.verbs += /client/proc/changeling_silence_sting
	src.verbs += /client/proc/changeling_unfat_sting

	changeling.changeling_level = 1
	return

/mob/proc/make_changeling()
	if(!changeling) changeling = new
	changeling.host = src

	src.verbs += /client/proc/changeling_absorb_dna
	src.verbs += /client/proc/changeling_transform
	src.verbs += /client/proc/changeling_lesser_form
	src.verbs += /client/proc/changeling_fakedeath

	src.verbs += /client/proc/changeling_deaf_sting
	src.verbs += /client/proc/changeling_blind_sting
	src.verbs += /client/proc/changeling_paralysis_sting
	src.verbs += /client/proc/changeling_silence_sting
	src.verbs += /client/proc/changeling_transformation_sting
	src.verbs += /client/proc/changeling_unfat_sting
	src.verbs += /client/proc/changeling_boost_range

	changeling.changeling_level = 2
	if (!changeling.absorbed_dna)
		changeling.absorbed_dna = list()
	if (changeling.absorbed_dna.len == 0)
		changeling.absorbed_dna[src.real_name] = src.dna
	return

/mob/proc/make_greater_changeling()
	src.make_changeling()
	//This is a test function for the new changeling powers.  Grants all of them.
	return

/mob/proc/remove_changeling_powers()
	src.verbs -= /client/proc/changeling_absorb_dna
	src.verbs -= /client/proc/changeling_transform
	src.verbs -= /client/proc/changeling_lesser_form
	src.verbs -= /client/proc/changeling_lesser_transform
	src.verbs -= /client/proc/changeling_fakedeath
	src.verbs -= /client/proc/changeling_deaf_sting
	src.verbs -= /client/proc/changeling_blind_sting
	src.verbs -= /client/proc/changeling_paralysis_sting
	src.verbs -= /client/proc/changeling_silence_sting
	src.verbs -= /client/proc/changeling_boost_range
	src.verbs -= /client/proc/changeling_transformation_sting
	src.verbs -= /client/proc/changeling_unfat_sting

/client/proc/changeling_absorb_dna()
	set category = "Changeling"
	set name = "Absorb DNA"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

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

	if (M.mutations & HUSK)
		usr << "\red This creature has already been drained!"
		return

	if (!G.killing)
		usr << "\red We must have a tighter grip to absorb this creature."
		return

	usr.changeling.chem_charges += 5

	var/mob/living/carbon/human/T = M

	usr << "\blue This creature is compatible. We must hold still..."

	if (!do_mob(usr, T, 150))
		usr << "\red Our absorption of [T] has been interrupted!"
		return

	usr << "\blue We extend a proboscis."
	usr.visible_message(text("\red <B>[usr] extends a proboscis!</B>"))

	if (!do_mob(usr, T, 150))
		usr << "\red Our absorption of [T] has been interrupted!"
		return

	usr << "\blue We stab [T] with the proboscis."
	usr.visible_message(text("\red <B>[usr] stabs [T] with the proboscis!</B>"))
	T << "\red <B>You feel a sharp stabbing pain!</B>"
	T.take_overall_damage(40)

	if (!do_mob(usr, T, 150))
		usr << "\red Our absorption of [T] has been interrupted!"
		return

	usr << "\blue We have absorbed [T]!"
	usr.visible_message(text("\red <B>[usr] sucks the fluids from [T]!</B>"))
	T << "\red <B>You have been absorbed by the changeling!</B>"

	usr.changeling.absorbed_dna[T.real_name] = T.dna
	if(usr.nutrition < 400) usr.nutrition = min((usr.nutrition + T.nutrition), 400)
	usr.changeling.chem_charges += 5
	if(T.changeling)
		if(T.changeling.absorbed_dna)
			usr.changeling.absorbed_dna |= T.changeling.absorbed_dna //steal all their loot
			T.changeling.absorbed_dna = list()
			T.changeling.absorbed_dna[T.real_name] = T.dna
		usr.changeling.chem_charges += T.changeling.chem_charges
		T.changeling.chem_charges = 0

	T.death(0)
	T.real_name = "Unknown"
	T.mutations |= HUSK
	T.update_body()

	return

/client/proc/changeling_transform()
	set category = "Changeling"
	set name = "Transform (5)"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	if(usr.stat)
		usr << "\red Not when we are incapacitated."
		return

	if (usr.changeling.absorbed_dna.len <= 0)
		usr << "\red We have not yet absorbed any compatible DNA."
		return

	if(usr.changeling.chem_charges < 5)
		usr << "\red We don't have enough stored chemicals to do that!"
		return

	var/S = input("Select the target DNA: ", "Target DNA", null) in usr.changeling.absorbed_dna

	if (S == null)
		return

	usr.changeling.chem_charges -= 5

	usr.visible_message(text("\red <B>[usr] transforms!</B>"))

	usr.dna = usr.changeling.absorbed_dna[S]
	usr.real_name = S
	updateappearance(usr, usr.dna.uni_identity)
	domutcheck(usr, null)

	usr.verbs -= /client/proc/changeling_transform

	spawn(10)
		usr.verbs += /client/proc/changeling_transform

	return

/client/proc/changeling_lesser_form()
	set category = "Changeling"
	set name = "Lesser Form (1)"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	if(usr.stat)
		usr << "\red Not when we are incapacitated."
		return

	if(usr.changeling.chem_charges < 1)
		usr << "\red We don't have enough stored chemicals to do that!"
		return

	usr.changeling.chem_charges--

	usr.remove_changeling_powers()

	usr.visible_message(text("\red <B>[usr] transforms!</B>"))

	var/list/implants = list() //Try to preserve implants.
	for(var/obj/item/weapon/W in usr)
		if (istype(W, /obj/item/weapon/implant))
			implants += W

	for(var/obj/item/W in usr)
		usr.drop_from_slot(W)

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
	O.changeling = usr.changeling

	for(var/obj/T in usr)
		del(T)
	//for(var/R in usr.organs) //redundant, let's give garbage collector work to do --rastaf0
	//	del(usr.organs[text("[]", R)])

	O.loc = usr.loc

	O.name = text("monkey ([])",copytext(md5(usr.real_name), 2, 6))
	O.toxloss = usr.getToxLoss()
	O.bruteloss = usr.getBruteLoss()
	O.oxyloss = usr.getOxyLoss()
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
	set name = "Transform (1)"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	if(usr.stat)
		usr << "\red Not when we are incapacitated."
		return

	if (usr.changeling.absorbed_dna.len <= 0)
		usr << "\red We have not yet absorbed any compatible DNA."
		return

	if(usr.changeling.chem_charges < 1)
		usr << "\red We don't have enough stored chemicals to do that!"
		return

	var/S = input("Select the target DNA: ", "Target DNA", null) in usr.changeling.absorbed_dna

	if (S == null)
		return

	usr.changeling.chem_charges -= 1

	usr.remove_changeling_powers()

	usr.visible_message(text("\red <B>[usr] transforms!</B>"))

	usr.dna = usr.changeling.absorbed_dna[S]

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
	O.changeling = usr.changeling
	O.real_name = S

	for(var/obj/T in usr)
		del(T)

	O.loc = usr.loc

	updateappearance(O,O.dna.uni_identity)
	domutcheck(O, null)
	O.toxloss = usr.getToxLoss()
	O.bruteloss = usr.getBruteLoss()
	O.oxyloss = usr.getOxyLoss()
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
	set name = "Regenerative Stasis (20)"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	if(usr.changeling.chem_charges < 20)
		usr << "\red We don't have enough stored chemicals to do that!"
		return

	usr.changeling.chem_charges -= 20

	usr << "\blue We will regenerate our form."

	usr.lying = 1
	usr.canmove = 0
	usr.changeling.changeling_fakedeath = 1
	usr.remove_changeling_powers()

	usr.emote("gasp")

	spawn(1200)
		usr.stat = 0
		//usr.fireloss = 0
		usr.toxloss = 0
		//usr.bruteloss = 0
		usr.oxyloss = 0
		usr.paralysis = 0
		usr.stunned = 0
		usr.weakened = 0
		usr.radiation = 0
		//usr.health = 100
		//usr.updatehealth()
		var/mob/living/M = src
		M.heal_overall_damage(1000, 1000)
		usr.reagents.clear_reagents()
		usr.lying = 0
		usr.canmove = 1
		usr << "\blue We have regenerated."
		usr.visible_message(text("\red <B>[usr] appears to wake from the dead, having healed all wounds.</B>"))

		usr.changeling.changeling_fakedeath = 0
		if (usr.changeling.changeling_level == 1)
			usr.make_lesser_changeling()
		else if (usr.changeling.changeling_level == 2)
			usr.make_changeling()

	return

/client/proc/changeling_boost_range()
	set category = "Changeling"
	set name = "Ranged Sting (10)"
	set desc="Your next sting ability can be used against targets 3 squares away."

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	if(usr.stat)
		usr << "\red Not when we are incapacitated."
		return

	if(usr.changeling.chem_charges < 10)
		usr << "\red We don't have enough stored chemicals to do that!"
		return

	usr.changeling.chem_charges -= 10

	usr << "\blue Your throat adjusts to launch the sting."
	usr.changeling.sting_range = 3

	usr.verbs -= /client/proc/changeling_boost_range

	spawn(5)
		usr.verbs += /client/proc/changeling_boost_range

	return

/client/proc/changeling_silence_sting()
	set category = "Changeling"
	set name = "Silence sting (10)"
	set desc="Sting target"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	var/list/victims = list()
	for(var/mob/living/carbon/C in oview(usr.changeling.sting_range))
		victims += C
	var/mob/T = input(usr, "Who do you wish to sting?") as null | anything in victims
	if(T)

		if(usr.stat)
			usr << "\red Not when we are incapacitated."
			return

		if(usr.changeling.chem_charges < 10)
			usr << "\red We don't have enough stored chemicals to do that!"
			return

		usr.changeling.chem_charges -= 10
		usr.changeling.sting_range = 1

		usr << "\blue We stealthily sting [T]."

		if(!T.changeling)
			T << "You feel a small prick and a burning sensation in your throat."
			T.silent += 30
		else
			T << "You feel a small prick."

		usr.verbs -= /client/proc/changeling_silence_sting

		spawn(5)
			usr.verbs += /client/proc/changeling_silence_sting

		return

/client/proc/changeling_blind_sting()
	set category = "Changeling"
	set name = "Blind sting (20)"
	set desc="Sting target"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	var/list/victims = list()
	for(var/mob/living/carbon/C in oview(usr.changeling.sting_range))
		victims += C
	var/mob/T = input(usr, "Who do you wish to sting?") as null | anything in victims
	if(T)
		if(usr.stat)
			usr << "\red Not when we are incapacitated."
			return

		if(usr.changeling.chem_charges < 20)
			usr << "\red We don't have enough stored chemicals to do that!"
			return

		usr.changeling.chem_charges -= 20
		usr.changeling.sting_range = 1

		usr << "\blue We stealthily sting [T]."

		var/obj/effect/overlay/B = new /obj/effect/overlay( T.loc )
		B.icon_state = "blspell"
		B.icon = 'wizard.dmi'
		B.name = "spell"
		B.anchored = 1
		B.density = 0
		B.layer = 4
		T.canmove = 0
		spawn(5)
			del(B)
			T.canmove = 1

		if(!T.changeling)
			T << text("\blue Your eyes cry out in pain!")
			T.disabilities |= 1
			spawn(300)
				T.disabilities &= ~1
			T.eye_blind = 10
			T.eye_blurry = 20

		usr.verbs -= /client/proc/changeling_blind_sting

		spawn(5)
			usr.verbs += /client/proc/changeling_blind_sting

		return

/client/proc/changeling_deaf_sting()
	set category = "Changeling"
	set name = "Deaf sting (5)"
	set desc="Sting target:"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	var/list/victims = list()
	for(var/mob/living/carbon/C in oview(usr.changeling.sting_range))
		victims += C
	var/mob/T = input(usr, "Who do you wish to sting?") as null | anything in victims

	if(T)
		if(usr.stat)
			usr << "\red Not when we are incapacitated."
			return

		if(usr.changeling.chem_charges < 5)
			usr << "\red We don't have enough stored chemicals to do that!"
			return

		usr.changeling.chem_charges -= 5
		usr.changeling.sting_range = 1

		usr << "\blue We stealthily sting [T]."

		if(!T.changeling)
			T.sdisabilities |= 4
			spawn(300)
				T.sdisabilities &= ~4

		usr.verbs -= /client/proc/changeling_deaf_sting

		spawn(5)
			usr.verbs += /client/proc/changeling_deaf_sting

		return

/client/proc/changeling_paralysis_sting()
	set category = "Changeling"
	set name = "Paralysis sting (30)"
	set desc="Sting target"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	var/list/victims = list()
	for(var/mob/living/carbon/C in oview(usr.changeling.sting_range))
		victims += C
	var/mob/T = input(usr, "Who do you wish to sting?") as null | anything in victims

	if(T)

		if(usr.stat)
			usr << "\red Not when we are incapacitated."
			return

		if(usr.changeling.chem_charges < 30)
			usr << "\red We don't have enough stored chemicals to do that!"
			return

		usr.changeling.chem_charges -= 30
		usr.changeling.sting_range = 1

		usr << "\blue We stealthily sting [T]."

		if(!T.changeling)
			T << "You feel a small prick and a burning sensation."

			if (T.reagents)
				T.reagents.add_reagent("zombiepowder", 20)
		else
			T << "You feel a small prick."

		usr.verbs -= /client/proc/changeling_paralysis_sting

		spawn(5)
			usr.verbs += /client/proc/changeling_paralysis_sting

		return

/client/proc/changeling_transformation_sting()
	set category = "Changeling"
	set name = "Transformation sting (30)"
	set desc="Sting target"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	var/list/victims = list()
	for(var/mob/living/carbon/C in oview(usr.changeling.sting_range))
		victims += C
	var/mob/T = input(usr, "Who do you wish to sting?") as null | anything in victims

	if(T)
		if(usr.stat)
			usr << "\red Not when we are incapacitated."
			return

		if(usr.changeling.chem_charges < 30)
			usr << "\red We don't have enough stored chemicals to do that!"
			return

		if(T.stat != 2 || (T.mutations & HUSK) || (!ishuman(T) && !ismonkey(T)))
			usr << "\red We can't transform that target!"
			return

		var/S = input("Select the target DNA: ", "Target DNA", null) in usr.changeling.absorbed_dna

		if (S == null)
			return

		usr.changeling.chem_charges -= 30
		usr.changeling.sting_range = 1

		usr << "\blue We stealthily sting [T]."

		if(!T.changeling)
			T.visible_message(text("\red <B>[T] transforms!</B>"))

			T.dna = usr.changeling.absorbed_dna[S]
			T.real_name = S
			updateappearance(T, T.dna.uni_identity)
			domutcheck(T, null)

		usr.verbs -= /client/proc/changeling_transformation_sting

		spawn(5)
			usr.verbs += /client/proc/changeling_transformation_sting

		return

/client/proc/changeling_unfat_sting()
	set category = "Changeling"
	set name = "Unfat sting (5)"
	set desc = "Sting target"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	var/list/victims = list()
	for(var/mob/living/carbon/C in oview(usr.changeling.sting_range))
		victims += C
	var/mob/T = input(usr, "Who do you wish to sting?") as null | anything in victims

	if(T)
		if(usr.stat)
			usr << "\red Not when we are incapacitated."
			return

		if(usr.changeling.chem_charges < 5)
			usr << "\red We don't have enough stored chemicals to do that!"
			return

		usr.changeling.chem_charges -= 5
		usr.changeling.sting_range = 1

		usr << "\blue We stealthily sting [T]."

		if(!T.changeling)
			T << "You feel a small prick and a burning sensation."
			T.overeatduration = 0
			T.nutrition -= 100
		else
			T << "You feel a small prick."

		usr.verbs -= /client/proc/changeling_unfat_sting

		spawn(5)
			usr.verbs += /client/proc/changeling_unfat_sting

	return