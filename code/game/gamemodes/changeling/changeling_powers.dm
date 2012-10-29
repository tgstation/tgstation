//Restores our verbs. It will only restore verbs allowed during lesser (monkey) form if we are not human
/mob/proc/make_changeling()
	if(!mind)				return
	if(!mind.changeling)	mind.changeling = new /datum/changeling(gender)
	verbs += /datum/changeling/proc/EvolutionMenu

	var/lesser_form = !ishuman(src)

	if(!powerinstances.len)
		for(var/P in powers)
			powerinstances += new P()

	// Code to auto-purchase free powers.
	for(var/datum/power/changeling/P in powerinstances)
		if(!P.genomecost) // Is it free?
			if(!(P in mind.changeling.purchasedpowers)) // Do we not have it already?
				mind.changeling.purchasePower(mind, P.name, 0)// Purchase it. Don't remake our verbs, we're doing it after this.

	for(var/datum/power/changeling/P in mind.changeling.purchasedpowers)
		if(P.isVerb)
			if(lesser_form && !P.allowduringlesserform)	continue
			if(!(P in src.verbs))
				src.verbs += P.verbpath

	mind.changeling.absorbed_dna |= dna
	return 1

//removes our changeling verbs
/mob/proc/remove_changeling_powers()
	if(!mind || !mind.changeling)	return
	for(var/datum/power/changeling/P in mind.changeling.purchasedpowers)
		if(P.isVerb)
			verbs -= P.verbpath


//Helper proc. Does all the checks and stuff for us to avoid copypasta
/mob/proc/changeling_power(var/required_chems=0, var/required_dna=0, var/max_genetic_damage=100, var/max_stat=0)
	if(!usr)			return
	if(!usr.mind)		return
	if(!iscarbon(usr))	return

	var/datum/changeling/changeling = usr.mind.changeling
	if(!changeling)
		world.log << "[usr] has the changeling_transform() verb but is not a changeling."
		return

	if(usr.stat > max_stat)
		usr << "<span class='warning'>We are incapacitated.</span>"
		return

	if(changeling.absorbed_dna.len < required_dna)
		usr << "<span class='warning'>We require at least [required_dna] samples of compatible DNA.</span>"
		return

	if(changeling.chem_charges < required_chems)
		usr << "<span class='warning'>We require at least [required_chems] units of chemicals to do that!</span>"
		return

	if(changeling.geneticdamage > max_genetic_damage)
		usr << "<span class='warning'>Our geneomes are still reassembling. We need time to recover first.</span>"
		return

	return changeling


//Absorbs the victim's DNA making them uncloneable. Requires a strong grip on the victim.
//Doesn't cost anything as it's the most basic ability.
/mob/proc/changeling_absorb_dna()
	set category = "Changeling"
	set name = "Absorb DNA"

	var/datum/changeling/changeling = changeling_power(0,0,100)
	if(!changeling)	return

	var/obj/item/weapon/grab/G = usr.get_active_hand()
	if(!istype(G))
		usr << "<span class='warning'>We must be grabbing a creature in our active hand to absorb them.</span>"
		return

	var/mob/living/carbon/human/T = G.affecting
	if(!istype(T))
		usr << "<span class='warning'>[T] is not compatible with our biology.</span>"
		return

	if(NOCLONE in T.mutations)
		usr << "<span class='warning'>This creature's DNA is ruined beyond useability!</span>"
		return

	if(!G.killing)
		usr << "<span class='warning'>We must have a tighter grip to absorb this creature.</span>"
		return

	if(changeling.isabsorbing)
		usr << "<span class='warning'>We are already absorbing!</span>"
		return

	changeling.isabsorbing = 1
	for(var/stage = 1, stage<=3, stage++)
		switch(stage)
			if(1)
				usr << "<span class='notice'>This creature is compatible. We must hold still...</span>"
			if(2)
				usr << "<span class='notice'>We extend a proboscis.</span>"
				usr.visible_message("<span class='warning'>[usr] extends a proboscis!</span>")
			if(3)
				usr << "<span class='notice'>We stab [T] with the proboscis.</span>"
				usr.visible_message("<span class='danger'>[usr] stabs [T] with the proboscis!</span>")
				T << "<span class='danger'>You feel a sharp stabbing pain!</span>"
				T.take_overall_damage(40)

		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(usr, T, 150))
			usr << "<span class='warning'>Our absorption of [T] has been interrupted!</span>"
			changeling.isabsorbing = 0
			return

	usr << "<span class='notice'>We have absorbed [T]!</span>"
	usr.visible_message("<span class='danger'>[usr] sucks the fluids from [T]!</span>")
	T << "<span class='danger'>You have been absorbed by the changeling!</span>"

	T.dna.real_name = T.real_name //Set this again, just to be sure that it's properly set.
	changeling.absorbed_dna |= T.dna
	if(usr.nutrition < 400) usr.nutrition = min((usr.nutrition + T.nutrition), 400)
	changeling.chem_charges += 10
	changeling.geneticpoints += 2

	if(T.mind && T.mind.changeling)
		if(T.mind.changeling.absorbed_dna)
			for(var/dna_data in T.mind.changeling.absorbed_dna)	//steal all their loot
				if(dna_data in changeling.absorbed_dna)
					continue
				changeling.absorbed_dna += dna_data
				changeling.absorbedcount++
			T.mind.changeling.absorbed_dna.len = 1

		if(T.mind.changeling.purchasedpowers)
			for(var/datum/power/changeling/Tp in T.mind.changeling.purchasedpowers)
				if(Tp in changeling.purchasedpowers)
					continue
				else
					changeling.purchasedpowers += Tp

					if(!Tp.isVerb)
						call(Tp.verbpath)()
					else
						usr.make_changeling()

		changeling.chem_charges += T.mind.changeling.chem_charges
		changeling.geneticpoints += T.mind.changeling.geneticpoints
		T.mind.changeling.chem_charges = 0
		T.mind.changeling.geneticpoints = 0
		T.mind.changeling.absorbedcount = 0

	changeling.absorbedcount++
	changeling.isabsorbing = 0

	T.death(0)
	T.Drain()
	return 1


//Change our DNA to that of somebody we've absorbed.
/mob/proc/changeling_transform()
	set category = "Changeling"
	set name = "Transform (5)"

	var/datum/changeling/changeling = changeling_power(5,1,0)
	if(!changeling)	return

	var/list/names = list()
	for(var/datum/dna/DNA in changeling.absorbed_dna)
		names += "[DNA.real_name]"

	var/S = input("Select the target DNA: ", "Target DNA", null) as null|anything in names
	if(!S)	return

	var/datum/dna/chosen_dna = changeling.GetDNA(S)
	if(!chosen_dna)
		return

	changeling.chem_charges -= 5
	usr.visible_message("<span class='warning'>[usr] transforms!</span>")
	changeling.geneticdamage = 30
	usr.dna = chosen_dna
	usr.real_name = chosen_dna.real_name
	updateappearance(usr, usr.dna.uni_identity)
	domutcheck(usr, null)

	usr.verbs -= /mob/proc/changeling_transform
	spawn(10)	usr.verbs += /mob/proc/changeling_transform

	feedback_add_details("changeling_powers","TR")
	return 1


//Transform into a monkey.
/mob/proc/changeling_lesser_form()
	set category = "Changeling"
	set name = "Lesser Form (1)"

	var/datum/changeling/changeling = changeling_power(1,0,0)
	if(!changeling)	return

	var/mob/living/carbon/C = usr
	changeling.chem_charges--
	C.remove_changeling_powers()
	C.visible_message("<span class='warning'>[C] transforms!</span>")
	changeling.geneticdamage = 30
	C << "<span class='warning'>Our genes cry out!</span>"

	//TODO replace with monkeyize proc
	var/list/implants = list() //Try to preserve implants.
	for(var/obj/item/weapon/implant/W in C)
		implants += W

	C.monkeyizing = 1
	C.canmove = 0
	C.icon = null
	C.overlays = null
	C.invisibility = 101

	var/atom/movable/overlay/animation = new /atom/movable/overlay( C.loc )
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src
	flick("h2monkey", animation)
	sleep(48)
	del(animation)

	var/mob/living/carbon/monkey/O = new /mob/living/carbon/monkey(src)
	O.dna = C.dna
	C.dna = null

	for(var/obj/item/W in C)
		C.drop_from_inventory(W)
	for(var/obj/T in C)
		del(T)

	O.loc = C.loc
	O.name = "monkey ([copytext(md5(C.real_name), 2, 6)])"
	O.setToxLoss(C.getToxLoss())
	O.adjustBruteLoss(C.getBruteLoss())
	O.setOxyLoss(C.getOxyLoss())
	O.adjustFireLoss(C.getFireLoss())
	O.stat = C.stat
	O.a_intent = "hurt"
	for(var/obj/item/weapon/implant/I in implants)
		I.loc = O
		I.implanted = O

	C.mind.transfer_to(O)

	O.make_changeling(1)
	O.verbs += /mob/proc/changeling_lesser_transform
	feedback_add_details("changeling_powers","LF")
	del(C)
	return 1


//Transform into a human
/mob/proc/changeling_lesser_transform()
	set category = "Changeling"
	set name = "Transform (1)"

	var/datum/changeling/changeling = changeling_power(1,1,0)
	if(!changeling)	return

	var/list/names = list()
	for(var/datum/dna/DNA in changeling.absorbed_dna)
		names += "[DNA.real_name]"

	var/S = input("Select the target DNA: ", "Target DNA", null) as null|anything in names
	if(!S)	return

	var/datum/dna/chosen_dna = changeling.GetDNA(S)
	if(!chosen_dna)
		return

	var/mob/living/carbon/C = usr

	changeling.chem_charges--
	C.remove_changeling_powers()
	C.visible_message("<span class='warning'>[C] transforms!</span>")
	C.dna = chosen_dna

	var/list/implants = list()
	for (var/obj/item/weapon/implant/I in C) //Still preserving implants
		implants += I

	C.monkeyizing = 1
	C.canmove = 0
	C.icon = null
	C.overlays = null
	C.invisibility = 101
	var/atom/movable/overlay/animation = new /atom/movable/overlay( C.loc )
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src
	flick("monkey2h", animation)
	sleep(48)
	del(animation)

	for(var/obj/item/W in usr)
		C.u_equip(W)
		if (C.client)
			C.client.screen -= W
		if (W)
			W.loc = C.loc
			W.dropped(C)
			W.layer = initial(W.layer)

	var/mob/living/carbon/human/O = new /mob/living/carbon/human( src )
	if (isblockon(getblock(C.dna.uni_identity, 11,3),11))
		O.gender = FEMALE
	else
		O.gender = MALE
	O.dna = C.dna
	C.dna = null
	O.real_name = chosen_dna.real_name

	for(var/obj/T in C)
		del(T)

	O.loc = C.loc

	updateappearance(O,O.dna.uni_identity)
	domutcheck(O, null)
	O.setToxLoss(C.getToxLoss())
	O.adjustBruteLoss(C.getBruteLoss())
	O.setOxyLoss(C.getOxyLoss())
	O.adjustFireLoss(C.getFireLoss())
	O.stat = C.stat
	for (var/obj/item/weapon/implant/I in implants)
		I.loc = O
		I.implanted = O

	C.mind.transfer_to(O)
	O.make_changeling()

	feedback_add_details("changeling_powers","LFT")
	del(C)
	return 1


//Fake our own death and fully heal. You will appear to be dead but regenerate fully after a short delay.
/mob/proc/changeling_fakedeath()
	set category = "Changeling"
	set name = "Regenerative Stasis (20)"

	var/datum/changeling/changeling = changeling_power(20,1,100,DEAD)
	if(!changeling)	return

	var/mob/living/carbon/C = usr
	if(!C.stat && alert("Are we sure we wish to fake our death?",,"Yes","No") == "No")//Confirmation for living changelings if they want to fake their death
		return
	C << "<span class='notice'>We will attempt to regenerate our form.</span>"

	C.status_flags |= FAKEDEATH		//play dead
	C.update_canmove()
	C.remove_changeling_powers()

	C.emote("gasp")
	C.tod = worldtime2text()

	spawn(rand(800,2000))
		if(changeling_power(20,1,100,DEAD))
			changeling.chem_charges -= 20
			if(C.stat == DEAD)
				dead_mob_list -= C
				living_mob_list += C
			C.stat = CONSCIOUS
			C.tod = null
			C.setToxLoss(0)
			C.setOxyLoss(0)
			C.setCloneLoss(0)
			C.SetParalysis(0)
			C.SetStunned(0)
			C.SetWeakened(0)
			C.radiation = 0
			C.heal_overall_damage(C.getBruteLoss(), C.getFireLoss())
			C.reagents.clear_reagents()
			C << "<span class='notice'>We have regenerated.</span>"
			C.visible_message("<span class='warning'>[usr] appears to wake from the dead, having healed all wounds.</span>")

			C.status_flags &= ~(FAKEDEATH)
			C.update_canmove()
			C.make_changeling()
	feedback_add_details("changeling_powers","FD")
	return 1


//Boosts the range of your next sting attack by 1
/mob/proc/changeling_boost_range()
	set category = "Changeling"
	set name = "Ranged Sting (10)"
	set desc="Your next sting ability can be used against targets 2 squares away."

	var/datum/changeling/changeling = changeling_power(10,0,100)
	if(!changeling)	return 0
	changeling.chem_charges -= 10
	usr << "<span class='notice'>Your throat adjusts to launch the sting.</span>"
	changeling.sting_range = 2
	usr.verbs -= /mob/proc/changeling_boost_range
	spawn(5)	usr.verbs += /mob/proc/changeling_boost_range
	feedback_add_details("changeling_powers","RS")
	return 1


//Recover from stuns.
/mob/proc/changeling_unstun()
	set category = "Changeling"
	set name = "Epinephrine Sacs (45)"
	set desc = "Removes all stuns"

	var/datum/changeling/changeling = changeling_power(45,0,100,UNCONSCIOUS)
	if(!changeling)	return 0
	changeling.chem_charges -= 45

	var/mob/living/carbon/human/C = usr
	C.stat = 0
	C.SetParalysis(0)
	C.SetStunned(0)
	C.SetWeakened(0)
	C.lying = 0
	C.update_canmove()

	usr.verbs -= /mob/proc/changeling_unstun
	spawn(5)	usr.verbs += /mob/proc/changeling_unstun
	feedback_add_details("changeling_powers","UNS")
	return 1


//Speeds up chemical regeneration
/mob/proc/changeling_fastchemical()
	usr.mind.changeling.chem_recharge_rate *= 2
	return 1

//Increases macimum chemical storage
/mob/proc/changeling_engorgedglands()
	usr.mind.changeling.chem_storage += 25
	return 1


//Prevents AIs tracking you but makes you easily detectable to the human-eye.
/mob/proc/changeling_digitalcamo()
	set category = "Changeling"
	set name = "Toggle Digital Camoflague (10)"
	set desc = "The AI can no longer track us, but we will look different if examined.  Has a constant cost while active."

	var/datum/changeling/changeling = changeling_power(10)
	if(!changeling)	return 0
	usr.mind.changeling.chem_charges -= 10

	var/mob/living/carbon/human/C = usr
	if(C.digitalcamo)	C << "<span class='notice'>We return to normal.</span>"
	else				C << "<span class='notice'>We distort our form to prevent AI-tracking.</span>"
	C.digitalcamo = !C.digitalcamo

	spawn(0)
		while(C && C.digitalcamo)
			C.mind.changeling.chem_charges -= 1
			sleep(40)

	usr.verbs -= /mob/proc/changeling_digitalcamo
	spawn(5)	usr.verbs += /mob/proc/changeling_digitalcamo
	feedback_add_details("changeling_powers","CAM")
	return 1


//Starts healing you every second for 10 seconds. Can be used whilst unconscious.
/mob/proc/changeling_rapidregen()
	set category = "Changeling"
	set name = "Rapid Regeneration (30)"
	set desc = "Begins rapidly regenerating.  Does not effect stuns or chemicals."

	var/datum/changeling/changeling = changeling_power(30,0,100,UNCONSCIOUS)
	if(!changeling)	return 0
	usr.mind.changeling.chem_charges -= 30

	var/mob/living/carbon/human/C = usr
	spawn(0)
		for(var/i = 0, i<10,i++)
			if(C)
				C.adjustBruteLoss(-10)
				C.adjustToxLoss(-10)
				C.adjustOxyLoss(-10)
				C.adjustFireLoss(-10)
				sleep(10)

	usr.verbs -= /mob/proc/changeling_rapidregen
	spawn(5)	usr.verbs += /mob/proc/changeling_rapidregen
	feedback_add_details("changeling_powers","RR")
	return 1

// HIVE MIND UPLOAD/DOWNLOAD DNA

var/list/datum/dna/hivemind_bank = list()

/mob/proc/changeling_hiveupload()
	set category = "Changeling"
	set name = "Hive Channel (10)"
	set desc = "Allows you to channel DNA in the airwaves to allow other changelings to absorb it."

	var/datum/changeling/changeling = changeling_power(10,1)
	if(!changeling)	return

	var/list/names = list()
	for(var/datum/dna/DNA in changeling.absorbed_dna)
		if(!(DNA in hivemind_bank))
			names += DNA.real_name

	if(names.len <= 0)
		usr << "<span class='notice'>The airwaves already have all of our DNA.</span>"
		return

	var/S = input("Select a DNA to channel: ", "Channel DNA", null) as null|anything in names
	if(!S)	return

	var/datum/dna/chosen_dna = changeling.GetDNA(S)
	if(!chosen_dna)
		return

	changeling.chem_charges -= 10
	hivemind_bank += chosen_dna
	usr << "<span class='notice'>We channel the DNA of [S] to the air.</span>"
	feedback_add_details("changeling_powers","HU")
	return 1

/mob/proc/changeling_hivedownload()
	set category = "Changeling"
	set name = "Hive Absorb (40)"
	set desc = "Allows you to absorb DNA that is being channeled in the airwaves."

	var/datum/changeling/changeling = changeling_power(40,1)
	if(!changeling)	return

	var/list/names = list()
	for(var/datum/dna/DNA in hivemind_bank)
		if(!(DNA in changeling.absorbed_dna))
			names[DNA.real_name] = DNA

	if(names.len <= 0)
		usr << "<span class='notice'>There's no new DNA to absorb from the air.</span>"
		return

	var/S = input("Select a DNA absorb from the air: ", "Absorb DNA", null) as null|anything in names
	if(!S)	return
	var/datum/dna/chosen_dna = names[S]
	if(!chosen_dna)
		return

	changeling.chem_charges -= 40
	changeling.absorbed_dna += chosen_dna
	usr << "<span class='notice'>We absorb the DNA of [S] from the air.</span>"
	feedback_add_details("changeling_powers","HD")
	return 1

// Fake Voice

/mob/proc/changeling_mimicvoice()
	set category = "Changeling"
	set name = "Mimic Voice (10)"
	set desc = "Shape our vocal glands to form a voice of someone we choose."

	var/datum/changeling/changeling = changeling_power(10,1)
	if(!changeling)	return

	if(changeling.mimicing)
		changeling.mimicing = ""
		usr << "<span class='notice'>We return our vocal glands to their original location.</span>"
		return

	var/mimic_voice = input("Enter a name to mimic.", "Mimic Voice", null) as text
	if(!mimic_voice)
		return

	changeling.chem_charges -= 10
	changeling.mimicing = mimic_voice

	usr << "<span class='notice'>We shape our glands to take the voice of <b>[mimic_voice]</b>, this will stop us from regenerating chemicals while active.</span>"
	usr << "<span class='notice'>Use this power again to return to our original voice and reproduce chemicals again.</span>"

	feedback_add_details("changeling_powers","MV")

	spawn(0)
		while(src && src.mind && src.mind.changeling && src.mind.changeling.mimicing)
			src.mind.changeling.chem_charges -= 1
			sleep(40)
		if(src && src.mind && src.mind.changeling)
			src.mind.changeling.mimicing = ""
	//////////
	//STINGS//	//They get a pretty header because there's just so fucking many of them ;_;
	//////////

/mob/proc/sting_can_reach(mob/M as mob, sting_range = 1)
	if(M.loc == src.loc) return 1 //target and source are in the same thing
	if(!isturf(src.loc) || !isturf(M.loc)) return 0 //One is inside, the other is outside something.
	if(AStar(src.loc, M.loc, /turf/proc/AdjacentTurfs, /turf/proc/Distance, sting_range)) //If a path exists, good!
		return 1
	return 0

//Handles the general sting code to reduce on copypasta (seeming as somebody decided to make SO MANY dumb abilities)
/mob/proc/changeling_sting(var/required_chems=0, var/verb_path)
	var/datum/changeling/changeling = changeling_power(required_chems)
	if(!changeling)								return

	var/list/victims = list()
	for(var/mob/living/carbon/C in oview(changeling.sting_range))
		victims += C
	var/mob/living/carbon/T = input(usr, "Who will we sting?") as null|anything in victims

	if(!T) return
	if(!(T in view(changeling.sting_range))) return
	if(!sting_can_reach(T, changeling.sting_range)) return
	if(!changeling_power(required_chems)) return

	changeling.chem_charges -= required_chems
	changeling.sting_range = 1
	usr.verbs -= verb_path
	spawn(10)	usr.verbs += verb_path

	usr << "<span class='notice'>We stealthily sting [T].</span>"
	if(!T.mind || !T.mind.changeling)	return T	//T will be affected by the sting
	T << "<span class='warning'>You feel a tiny prick.</span>"
	return


/mob/proc/changeling_lsdsting()
	set category = "Changeling"
	set name = "Hallucination Sting (15)"
	set desc = "Causes terror in the target."

	var/mob/living/carbon/T = changeling_sting(15,/mob/proc/changeling_lsdsting)
	if(!T)	return 0
	spawn(rand(300,600))
		if(T)	T.hallucination += 400
	feedback_add_details("changeling_powers","HS")
	return 1

/mob/proc/changeling_silence_sting()
	set category = "Changeling"
	set name = "Silence sting (10)"
	set desc="Sting target"

	var/mob/living/carbon/T = changeling_sting(10,/mob/proc/changeling_silence_sting)
	if(!T)	return 0
	T.silent += 30
	feedback_add_details("changeling_powers","SS")
	return 1

/mob/proc/changeling_blind_sting()
	set category = "Changeling"
	set name = "Blind sting (20)"
	set desc="Sting target"

	var/mob/living/carbon/T = changeling_sting(20,/mob/proc/changeling_blind_sting)
	if(!T)	return 0
	T << "<span class='danger'>Your eyes burn horrificly!</span>"
	T.disabilities |= NEARSIGHTED
	spawn(300)	T.disabilities &= ~NEARSIGHTED
	T.eye_blind = 10
	T.eye_blurry = 20
	feedback_add_details("changeling_powers","BS")
	return 1

/mob/proc/changeling_deaf_sting()
	set category = "Changeling"
	set name = "Deaf sting (5)"
	set desc="Sting target:"

	var/mob/living/carbon/T = changeling_sting(5,/mob/proc/changeling_deaf_sting)
	if(!T)	return 0
	T << "<span class='danger'>Your ears pop and begin ringing loudly!</span>"
	T.sdisabilities |= DEAF
	spawn(300)	T.sdisabilities &= ~DEAF
	feedback_add_details("changeling_powers","DS")
	return 1

/mob/proc/changeling_paralysis_sting()
	set category = "Changeling"
	set name = "Paralysis sting (30)"
	set desc="Sting target"

	var/mob/living/carbon/T = changeling_sting(30,/mob/proc/changeling_paralysis_sting)
	if(!T)	return 0
	T << "<span class='danger'>Your muscles begin to painfully tighten.</span>"
	T.Weaken(20)
	feedback_add_details("changeling_powers","PS")
	return 1

/mob/proc/changeling_transformation_sting()
	set category = "Changeling"
	set name = "Transformation sting (40)"
	set desc="Sting target"

	var/datum/changeling/changeling = changeling_power(40)
	if(!changeling)	return 0



	var/list/names = list()
	for(var/datum/dna/DNA in changeling.absorbed_dna)
		names += "[DNA.real_name]"

	var/S = input("Select the target DNA: ", "Target DNA", null) as null|anything in names
	if(!S)	return

	var/datum/dna/chosen_dna = changeling.GetDNA(S)
	if(!chosen_dna)
		return

	var/mob/living/carbon/T = changeling_sting(40,/mob/proc/changeling_transformation_sting)
	if(!T)	return 0
	if((HUSK in T.mutations) || (!ishuman(T) && !ismonkey(T)))
		usr << "<span class='warning'>Our sting appears ineffective against its DNA.</span>"
		return 0
	T.visible_message("<span class='warning'>[T] transforms!</span>")
	T.dna = chosen_dna
	T.real_name = chosen_dna.real_name
	updateappearance(T, T.dna.uni_identity)
	domutcheck(T, null)
	feedback_add_details("changeling_powers","TS")
	return 1

/mob/proc/changeling_unfat_sting()
	set category = "Changeling"
	set name = "Unfat sting (5)"
	set desc = "Sting target"

	var/mob/living/carbon/T = changeling_sting(5,/mob/proc/changeling_unfat_sting)
	if(!T)	return 0
	T << "<span class='danger'>you feel a small prick as stomach churns violently and you become to feel skinnier.</span>"
	T.overeatduration = 0
	T.nutrition -= 100
	feedback_add_details("changeling_powers","US")
	return 1

/mob/proc/changeling_DEATHsting()
	set category = "Changeling"
	set name = "Death Sting (40)"
	set desc = "Causes spasms onto death."

	var/mob/living/carbon/T = changeling_sting(40,/mob/proc/changeling_DEATHsting)
	if(!T)	return 0
	T << "<span class='danger'>You feel a small prick and your chest becomes tight.</span>"
	T.silent = 10
	T.Paralyse(10)
	T.make_jittery(1000)
	if(T.reagents)	T.reagents.add_reagent("lexorin", 40)
	feedback_add_details("changeling_powers","DTHS")
	return 1

/mob/proc/changeling_extract_dna_sting()
	set category = "Changeling"
	set name = "Extract DNA Sting (40)"
	set desc="Stealthily sting a target to extract their DNA."

	var/datum/changeling/changeling = null
	if(usr.mind && usr.mind.changeling)
		changeling = usr.mind.changeling
	if(!changeling)
		return 0

	var/mob/living/carbon/T = changeling_sting(40, /mob/proc/changeling_extract_dna_sting)
	if(!T)	return 0

	T.dna.real_name = T.real_name
	changeling.absorbed_dna |= T.dna

	feedback_add_details("changeling_powers","ED")
	return 1