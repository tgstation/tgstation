//Restores our verbs. It will only restore verbs allowed during lesser (monkey) form if we are not human
/mob/proc/make_changeling()
	if(!mind)				return
	if(!mind.changeling)	mind.changeling = new /datum/changeling(gender)
	if(!iscarbon(src))		return

	verbs += /datum/changeling/proc/EvolutionMenu

	var/lesser_form = !ishuman(src)

	if(!powerinstances)
		powerinstances = init_subtypes(/datum/power/changeling)

	// Code to auto-purchase free powers.
	for(var/datum/power/changeling/P in powerinstances)
		if(!P.genomecost) // Is it free?
			if(!(P in mind.changeling.purchasedpowers)) // Do we not have it already?
				mind.changeling.purchasePower(mind, P.name, 0)// Purchase it. Don't remake our verbs, we're doing it after this.

	for(var/datum/power/changeling/P in mind.changeling.purchasedpowers)
		if(P.isVerb)
			if(lesser_form && !P.allowduringlesserform)	continue
			verbs += P.verbpath			//byond won't allow two of the same verb to be added to the verbs list. No additional checks necessary

	var/mob/living/carbon/C = src		//only carbons have dna now, so we have to typecaste
	mind.changeling.absorbed_dna |= C.dna
	return 1

//removes our changeling verbs
/mob/proc/remove_changeling_powers()
	for(var/datum/power/changeling/P in powerinstances)
		if(P.isVerb)
			verbs -= P.verbpath

//Helper proc. Does all the checks and stuff for us to avoid copypasta
//includes a check to see if we're a carbon mob. This means that you can't use powers (even with the verbs) unless you're a carbon-based mob.
/mob/proc/changeling_power(var/required_chems=0, var/required_dna=0, var/max_genetic_damage=3, var/max_stat=0)
	if(!src.mind)		return
	if(!iscarbon(src))	return

	var/datum/changeling/changeling = src.mind.changeling
	if(!changeling)		return

	if(src.stat > max_stat)
		src << "<span class='warning'>We are incapacitated.</span>"
		return

	if(changeling.absorbedcount < required_dna)
		src << "<span class='warning'>We require at least [required_dna] sample\s of compatible DNA.</span>"
		return

	if(changeling.chem_charges < required_chems)
		src << "<span class='warning'>We require at least [required_chems] unit\s of chemicals to do that!</span>"
		return

	if(changeling.geneticdamage > max_genetic_damage)
		src << "<span class='warning'>Our genomes are still reassembling. We need time to recover first.</span>"
		return

	return changeling




//Absorbs the victim's DNA making them uncloneable. Requires a strong grip on the victim.
//Doesn't cost anything as it's the most basic ability.
/mob/living/carbon/proc/changeling_absorb_dna()
	set category = "Changeling"
	set name = "Absorb DNA"

	var/datum/changeling/changeling = changeling_power(0,0,100)
	if(!changeling)	return

	var/obj/item/weapon/grab/G = src.get_active_hand()
	if(!istype(G))
		src << "<span class='warning'>We must be grabbing a creature in our active hand to absorb them.</span>"
		return

	if(G.state <= GRAB_NECK)
		src << "<span class='warning'>We must have a tighter grip to absorb this creature.</span>"
		return
	if(changeling.isabsorbing)
		src << "<span class='warning'>We are already absorbing!</span>"
		return

	var/mob/living/carbon/T = G.affecting
	if(changeling.can_absorb_dna(T, usr))
		changeling.isabsorbing = 1
	else
		return

	for(var/stage = 1, stage<=3, stage++)
		switch(stage)
			if(1)
				src << "<span class='notice'>This creature is compatible. We must hold still...</span>"
			if(2)
				src << "<span class='notice'>We extend a proboscis.</span>"
				src.visible_message("<span class='warning'>[src] extends a proboscis!</span>")
			if(3)
				src << "<span class='notice'>We stab [T] with the proboscis.</span>"
				src.visible_message("<span class='danger'>[src] stabs [T] with the proboscis!</span>")
				T << "<span class='danger'>You feel a sharp stabbing pain!</span>"
				T.take_overall_damage(40)

		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(src, T, 150))
			src << "<span class='warning'>Our absorption of [T] has been interrupted!</span>"
			changeling.isabsorbing = 0
			return

	src << "<span class='notice'>We have absorbed [T]!</span>"
	src.visible_message("<span class='danger'>[src] sucks the fluids from [T]!</span>")
	T << "<span class='danger'>You have been absorbed by the changeling!</span>"

	changeling.absorb_dna(T)

	if(src.nutrition < 400) src.nutrition = min((src.nutrition + T.nutrition), 400)
	if(T.mind && T.mind.changeling)//If the target was a changeling, suck out their extra juice and objective points!
		changeling.chem_charges += min(T.mind.changeling.chem_charges, changeling.chem_storage)
		changeling.absorbedcount += T.mind.changeling.absorbedcount

		T.mind.changeling.absorbed_dna.len = 1
		T.mind.changeling.absorbedcount = 0
	else
		changeling.chem_charges += 10

	changeling.isabsorbing = 0
	changeling.canrespec = 1

	T.death(0)
	T.Drain()
	return 1


//Change our DNA to that of somebody we've absorbed.
/mob/living/carbon/proc/changeling_transform()
	set category = "Changeling"
	set name = "Transform (5)"

	var/datum/changeling/changeling = changeling_power(5, 0, 3)
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
	changeling.geneticdamage = 3
	src.dna = chosen_dna
	src.real_name = chosen_dna.real_name
	updateappearance(src)
	domutcheck(src, null)

	feedback_add_details("changeling_powers","TR")
	return 1


//Transform into a monkey.
/mob/living/carbon/proc/changeling_lesser_form()
	set category = "Changeling"
	set name = "Lesser Form (5)"

	var/datum/changeling/changeling = changeling_power(5,0,3)
	if(!changeling)	return

	changeling.chem_charges -= 5
	remove_changeling_powers()
	changeling.geneticdamage = 3
	src << "<span class='warning'>Our genes cry out!</span>"

	var/mob/living/carbon/monkey/O = monkeyize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPDAMAGE | TR_KEEPSE | TR_KEEPSRC)

	O.make_changeling(1)
	O.verbs += /mob/living/carbon/proc/changeling_human_form
	feedback_add_details("changeling_powers","LF")
	. = 1
	del(src)
	return


//Transform into a human
/mob/living/carbon/proc/changeling_human_form()

	set category = "Changeling"
	set name = "Human Form (5)"

	var/datum/changeling/changeling = changeling_power(5,0,3)

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
	remove_changeling_powers()
	src << "<span class='notice'>We transform our appearance.</span>"
	dna = chosen_dna

	var/mob/living/carbon/human/O = humanize((TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPDAMAGE | TR_KEEPSRC),chosen_dna.real_name)

	if(O)
		O.make_changeling()
	feedback_add_details("changeling_powers","LFT")
	. = 1
	del(src)
	return


//Fake our own death and fully heal. You will appear to be dead but regenerate fully after a short delay.
/mob/living/carbon/proc/changeling_fakedeath()
	set category = "Changeling"
	set name = "Regenerative Stasis (10)"
	set desc = "Begin stasis, allowing us to regenerate."

	var/datum/changeling/changeling = changeling_power(10,1,100,DEAD)
	if(!changeling)	return
	if(status_flags & FAKEDEATH) return //Make sure we can't stack regenerations and such.
	changeling.chem_charges -= 10

	if(!stat && alert("Are we sure we wish to fake our death?",,"Yes","No") == "No")//Confirmation for living changelings if they want to fake their death
		return
	src << "<span class='notice'>We begin our stasis, preparing energy to arise once more.</span>"

	status_flags |= FAKEDEATH		//play dead
	update_canmove()
	remove_changeling_powers()

	emote("deathgasp")
	tod = worldtime2text()

	spawn(800)
		src << "<span class='notice'>We have now stored enough power to regenerate.</span>"
		verbs -= /mob/living/carbon/proc/changeling_fakedeath
		verbs += /mob/living/carbon/proc/changeling_revive

	feedback_add_details("changeling_powers","FD")
	return 1

//Separated from regenerative stasis, so that they can choose when to pop up rather than having no control over it.
/mob/living/carbon/proc/changeling_revive()
	set category = "Changeling"
	set name = "Regenerate! (10)"
	set desc = "Regenerate, healing all damage from our form."

	var/datum/changeling/changeling = changeling_power(10,1,100,DEAD)
	if(!changeling)	return
	changeling.chem_charges -= 10

	if(stat == DEAD)
		dead_mob_list -= src
		living_mob_list += src
	stat = CONSCIOUS
	tod = null
	setToxLoss(0)
	setOxyLoss(0)
	setCloneLoss(0)
	SetParalysis(0)
	SetStunned(0)
	SetWeakened(0)
	radiation = 0
	heal_overall_damage(getBruteLoss(), getFireLoss())
	reagents.clear_reagents()
	src << "<span class='notice'>We have regenerated.</span>"

	status_flags &= ~(FAKEDEATH)
	update_canmove()
	make_changeling()

	verbs -= /mob/living/carbon/proc/changeling_revive
	verbs += /mob/living/carbon/proc/changeling_fakedeath

	feedback_add_details("changeling_powers","CR")
	return 1

//Recover from stuns.
/mob/living/carbon/proc/changeling_unstun()
	set category = "Changeling"
	set name = "Epinephrine Overdose (30)"
	set desc = "Removes all stuns instantly, and adds a short-term reduction in further stuns."

	var/datum/changeling/changeling = changeling_power(30,0,100,UNCONSCIOUS)
	if(!changeling)	return 0
	changeling.chem_charges -= 30

	src << "<span class='notice'>We arise.</span>"
	stat = 0
	SetParalysis(0)
	SetStunned(0)
	SetWeakened(0)
	lying = 0
	update_canmove()

	reagents.add_reagent("synaptizine", 20)

	feedback_add_details("changeling_powers","UNS")
	return 1


//Increases maximum chemical storage and regeneraton.
/mob/proc/changeling_advglands()
	src.mind.changeling.chem_storage += 25
	src.mind.changeling.chem_recharge_rate *= 2
	return 1


//A flashy ability, good for crowd control and sewing chaos.
/mob/living/carbon/proc/changeling_shriek()
	set category = "Changeling"
	set name = "Resonant Shriek (25)"
	set desc = "Deafen and confuse those around us."

	var/datum/changeling/changeling = changeling_power(25)
	if(!changeling)	return 0
	src.mind.changeling.chem_charges -= 25

	for(var/mob/living/M in hearers(4, usr))
		if(iscarbon(M))
			if(!M.mind || !M.mind.changeling)
				M.ear_deaf += 30
				M.confused += 20
				M.make_jittery(50)
			else
				M << sound('sound/effects/screech.ogg')

		if(issilicon(M))
			M << sound('sound/weapons/flash.ogg')
			M.Weaken(rand(5,10))


	for(var/obj/machinery/light/L in range(4, usr))
		L.on = 1
		L.broken()

	feedback_add_details("changeling_powers","RS")
	return 1


//Makes some spiderlings. Good for setting traps and causing general trouble.
/mob/living/carbon/proc/changeling_spiders()
	set category = "Changeling"
	set name = "Spread Infestation (50)"
	set desc = "Creates spiderlings."

	var/datum/changeling/changeling = changeling_power(50, 5)
	if(!changeling)	return 0
	src.mind.changeling.chem_charges -= 50

	for(var/i=0, i<2, i++)
		var/obj/effect/spider/spiderling/S = new(src.loc)
		S.grow_as = /mob/living/simple_animal/hostile/giant_spider/hunter

	feedback_add_details("changeling_powers","SI")
	return 1


//Heals the things that the other regenerative abilities don't.
/mob/living/carbon/proc/changeling_panacea()
	set category = "Changeling"
	set name = "Anatomic Panacea (25)"
	set desc = "Cures diseases, disabilities, toxins and radiation."

	var/datum/changeling/changeling = changeling_power(25,0,100,UNCONSCIOUS)
	if(!changeling)	return 0
	src.mind.changeling.chem_charges -= 25

	src << "<span class='notice'>We cleanse impurities from our form.</span>"
	reagents.add_reagent("ryetalyn", 10)
	reagents.add_reagent("hyronalin", 10)
	reagents.add_reagent("anti_toxin", 20)

	for(var/datum/disease/D in src.viruses)
		D.cure()

	feedback_add_details("changeling_powers","AP")
	return 1


//Prevents AIs tracking you but makes you easily detectable to the human-eye.
/mob/living/carbon/proc/changeling_digitalcamo()
	set category = "Changeling"
	set name = "Toggle Digital Camouflage"
	set desc = "The AI can no longer track us, but we will look different if examined."

	var/datum/changeling/changeling = changeling_power()
	if(!changeling)	return 0

	if(digitalcamo)	src << "<span class='notice'>We return to normal.</span>"
	else			src << "<span class='notice'>We distort our form to prevent AI-tracking.</span>"
	digitalcamo = !digitalcamo

	feedback_add_details("changeling_powers","CAM")
	return 1


//Starts healing you every second for 10 seconds. Can be used whilst unconscious.
/mob/living/carbon/proc/changeling_fleshmend()
	set category = "Changeling"
	set name = "Fleshmend (30)"
	set desc = "Begins rapidly regenerating.  Does not effect stuns or chemicals."

	var/datum/changeling/changeling = changeling_power(30,0,100,UNCONSCIOUS)
	if(!changeling)	return 0
	src.mind.changeling.chem_charges -= 30

	src << "<span class='notice'>We begin to heal rapidly.</span>"
	spawn(0)
		for(var/i = 0, i<10,i++)
			adjustBruteLoss(-10)
			adjustOxyLoss(-10)
			adjustFireLoss(-10)
			sleep(10)

	feedback_add_details("changeling_powers","RR")
	return 1

// HIVE MIND UPLOAD/DOWNLOAD DNA
var/list/datum/dna/hivemind_bank = list()

/mob/living/carbon/proc/changeling_hiveupload()
	set category = "Changeling"
	set name = "Hive Channel (10)"
	set desc = "Allows you to channel DNA in the airwaves to allow other changelings to absorb it."

	var/datum/changeling/changeling = changeling_power(10)
	if(!changeling)	return

	var/list/names = list()
	for(var/datum/dna/DNA in changeling.absorbed_dna)
		if(!(DNA in hivemind_bank))
			names += DNA.real_name

	if(names.len <= 0)
		src << "<span class='notice'>The airwaves already have all of our DNA.</span>"
		return

	var/S = input("Select a DNA to channel: ", "Channel DNA", null) as null|anything in names
	if(!S)	return

	var/datum/dna/chosen_dna = changeling.GetDNA(S)
	if(!chosen_dna)
		return

	changeling.chem_charges -= 10
	hivemind_bank += chosen_dna
	src << "<span class='notice'>We channel the DNA of [S] to the air.</span>"
	feedback_add_details("changeling_powers","HU")
	return 1

/mob/living/carbon/proc/changeling_hivedownload()
	set category = "Changeling"
	set name = "Hive Absorb (20)"
	set desc = "Allows you to absorb DNA that is being channeled in the airwaves."

	var/datum/changeling/changeling = changeling_power(20)
	if(!changeling)	return

	var/list/names = list()
	for(var/datum/dna/DNA in hivemind_bank)
		if(!(DNA in changeling.absorbed_dna))
			names[DNA.real_name] = DNA

	if(names.len <= 0)
		src << "<span class='notice'>There's no new DNA to absorb from the air.</span>"
		return

	var/S = input("Select a DNA absorb from the air: ", "Absorb DNA", null) as null|anything in names
	if(!S)	return
	var/datum/dna/chosen_dna = names[S]
	if(!chosen_dna)
		return

	if(changeling.can_absorb_dna(null, usr))
		changeling.chem_charges -= 20
		changeling.shuffle_dna()
		changeling.absorbed_dna |= chosen_dna
		src << "<span class='notice'>We absorb the DNA of [S] from the air.</span>"
		feedback_add_details("changeling_powers","HD")
	return 1

// Fake Voice
/mob/living/carbon/proc/changeling_mimicvoice()
	set category = "Changeling"
	set name = "Mimic Voice"
	set desc = "Shape our vocal glands to form a voice of someone we choose. We cannot regenerate chemicals when mimicing."


	var/datum/changeling/changeling = changeling_power()
	if(!changeling)	return

	if(changeling.mimicing)
		changeling.mimicing = ""
		src << "<span class='notice'>We return our vocal glands to their original location.</span>"
		return

	var/mimic_voice = input("Enter a name to mimic.", "Mimic Voice", null) as text
	if(!mimic_voice)
		return

	changeling.mimicing = mimic_voice

	src << "<span class='notice'>We shape our glands to take the voice of <b>[mimic_voice]</b>, this will stop us from regenerating chemicals while active.</span>"
	src << "<span class='notice'>Use this power again to return to our original voice and reproduce chemicals again.</span>"

	feedback_add_details("changeling_powers","MV")

	spawn(0)
		while(src && src.mind && src.mind.changeling && src.mind.changeling.mimicing)
			src.mind.changeling.chem_charges = max(src.mind.changeling.chem_charges - 1, 0)
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
	var/mob/living/carbon/T = input(src, "Who will we sting?") as null|anything in victims

	if(!T) return
	if(!(T in view(changeling.sting_range))) return
	if(!sting_can_reach(T, changeling.sting_range)) return
	if(!changeling_power(required_chems)) return

	changeling.chem_charges -= required_chems
	verbs -= verb_path
	spawn(5)	verbs += verb_path

	src << "<span class='notice'>We stealthily sting [T].</span>"
	if(!T.mind || !T.mind.changeling)	return T	//T will be affected by the sting
	T << "<span class='warning'>You feel a tiny prick.</span>"
	return


/mob/living/carbon/proc/changeling_transformation_sting()
	set category = "Changeling"
	set name = "Transformation Sting (40)"
	set desc= "Transform the target to one of our stored DNAs"

	var/datum/changeling/changeling = changeling_power(40)
	if(!changeling)	return 0

	var/list/names = list()
	for(var/datum/dna/DNA in changeling.absorbed_dna)
		names += DNA.real_name

	var/S = input("Select the target DNA: ", "Target DNA", null) as null|anything in names
	if(!S)	return

	var/datum/dna/chosen_dna = changeling.GetDNA(S)
	if(!chosen_dna)
		return

	var/mob/living/carbon/T = changeling_sting(40,/mob/living/carbon/proc/changeling_transformation_sting)
	if(!T)	return 0
	if((HUSK in T.mutations) || !check_dna_integrity(T))
		src << "<span class='warning'>Our sting appears ineffective against its DNA.</span>"
		return 0
	T.dna = chosen_dna
	T.real_name = chosen_dna.real_name
	updateappearance(T)
	domutcheck(T, null)
	feedback_add_details("changeling_powers","TS")
	return 1


/mob/living/carbon/proc/changeling_extract_dna_sting()
	set category = "Changeling"
	set name = "Extract DNA Sting (25)"
	set desc="Stealthily sting a target to extract their DNA."

	var/datum/changeling/changeling = null
	if(src.mind && src.mind.changeling)
		changeling = src.mind.changeling
	if(!changeling)
		return 0

	var/mob/living/carbon/T = changeling_sting(25, /mob/living/carbon/proc/changeling_extract_dna_sting)
	if(!T)	return 0

	if(changeling.can_absorb_dna(T, usr))
		changeling.absorb_dna(T, usr)
	else//If the sting fails, give the guy most of his chems back.
		changeling.chem_charges += 20

	feedback_add_details("changeling_powers","ED")
	return 1


/mob/living/carbon/proc/changeling_mute_sting()
	set category = "Changeling"
	set name = "Mute sting (20)"
	set desc= "Temporarily mutes the target."

	var/mob/living/carbon/T = changeling_sting(20,/mob/living/carbon/proc/changeling_mute_sting)
	if(!T)	return 0
	T.silent += 30
	feedback_add_details("changeling_powers","MS")
	return 1


/mob/living/carbon/proc/changeling_blind_sting()
	set category = "Changeling"
	set name = "Blind Sting (25)"
	set desc= "Temporarily blinds the target."

	var/mob/living/carbon/T = changeling_sting(25,/mob/living/carbon/proc/changeling_blind_sting)
	if(!T)	return 0
	T << "<span class='danger'>Your eyes burn horrifically!</span>"
	T.disabilities |= NEARSIGHTED
	T.eye_blind = 20
	T.eye_blurry = 40
	feedback_add_details("changeling_powers","BS")
	return 1


/mob/living/carbon/proc/changeling_lsd_sting()
	set category = "Changeling"
	set name = "Hallucination Sting (5)"
	set desc = "Causes terror in the target."

	var/mob/living/carbon/T = changeling_sting(5,/mob/living/carbon/proc/changeling_lsd_sting)
	if(!T)	return 0
	spawn(rand(300,600))
		if(T)	T.hallucination += 400
	feedback_add_details("changeling_powers","HS")
	return 1


/mob/living/carbon/proc/changeling_cryo_sting()
	set category = "Changeling"
	set name = "Cryogenic Sting (15)"
	set desc = "Cools the target, slowing them."

	var/mob/living/carbon/T = changeling_sting(15,/mob/living/carbon/proc/changeling_cryo_sting)
	if(!T)	return 0

	if(T.reagents)
		T.reagents.add_reagent("frostoil", 30)
		T.reagents.add_reagent("ice", 30)

	feedback_add_details("changeling_powers","CS")
	return 1