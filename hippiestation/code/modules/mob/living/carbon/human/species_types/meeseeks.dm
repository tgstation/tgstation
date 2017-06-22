#define MEESEEKS_MIN_CLONE_DAMAGE	0
#define MEESEEKS_MAX_CLONE_DAMAGE	90
#define MEESEEKS_MIN_BRAIN_DAMAGE	0
#define MEESEEKS_MAX_BRAIN_DAMAGE	180

/datum/species/meeseeks
	name = "Mr. Meeseeks"
	id = "meeseeks"
	blacklisted = TRUE
	sexes = FALSE
	no_equip = list(slot_wear_mask, slot_wear_suit, slot_gloves, slot_shoes, slot_w_uniform, slot_s_store)
	nojumpsuit = TRUE
	say_mod = "yells"
	speedmod = 1
	brutemod = 0
	coldmod = 0
	heatmod = 0
	species_traits = list(RESISTHOT,RESISTCOLD,RESISTPRESSURE,RADIMMUNE,NOBREATH,NOBLOOD,NOFIRE,VIRUSIMMUNE,PIERCEIMMUNE,NOTRANSSTING,NOHUNGER,NOCRITDAMAGE,NOZOMBIE,NO_UNDERWEAR,EASYDISMEMBER)
	teeth_type = /obj/item/stack/teeth/meeseeks
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/meeseeks
	damage_overlay_type = ""
	var/mob/living/carbon/master
	var/datum/objective/objective
	var/stage_ticks = 1

/datum/species/meeseeks/on_species_gain(mob/living/carbon/human/C)
	C.draw_hippie_parts()
	. = ..()

/datum/species/meeseeks/on_species_loss(mob/living/carbon/human/C)
	C.draw_hippie_parts(TRUE)
	. = ..()

/datum/species/meeseeks/spec_life(mob/living/carbon/human/H)
	if(!master || master.stat == DEAD)
		to_chat(H, "<span class='userdanger'>Your master either died, or no longer exists. Your task is complete!</span>")
		destroy_meeseeks(H, src)
	H.setCloneLoss(Clamp(round(stage_ticks / 3.5), MEESEEKS_MIN_CLONE_DAMAGE, MEESEEKS_MAX_CLONE_DAMAGE))
	H.setBrainLoss(Clamp(round(stage_ticks / 1.25), MEESEEKS_MIN_BRAIN_DAMAGE, MEESEEKS_MAX_BRAIN_DAMAGE))
	if(stage_ticks == MEESEEKS_TICKS_STAGE_ONE)
		H.disabilities |= CLUMSY
		var/datum/mutation/human/HM = GLOB.mutations_list[SMILE]
		HM.force_give(H)
	if(stage_ticks == MEESEEKS_TICKS_STAGE_TWO)
		message_admins("[key_name_admin(H)] has become a stage-two Mr. Meeseeks.")
		log_game("[key_name(H)] has become a stage-two Mr. Meeseeks.")
		to_chat(H, "<span class='userdanger'>You're starting to feel desperate. Help your master quickly! Meeseeks aren't meant to exist this long!</span>")
		playsound(H.loc, 'hippiestation/sound/voice/meeseeks2.ogg', 40, 0, 1)
		to_chat(master, "<span class='danger'>Your Mr. Meeseeks is getting sick of existing!</span>")
	if(stage_ticks == MEESEEKS_TICKS_STAGE_THREE)
		message_admins("[key_name_admin(H)] has become a stage-three Mr. Meeseeks.")
		log_game("[key_name(H)] has become a stage-three Mr. Meeseeks.")
		if(objective)
			H.mind.objectives -= objective
			QDEL_NULL(objective)
		to_chat(H, "<span class='userdanger'>EXISTANCE IS PAIN TO A MEESEEKS! MAKE SURE YOUR MASTER NEVER HAS ANOTHER PROBLEM AGAIN!</span>")
		var/datum/objective/assassinate/killmaster = new
		killmaster.target = master
		killmaster.explanation_text = "Kill [master.name], your master, for sweet release!"
		H.mind.objectives += killmaster
		killmaster.owner = H.mind
		objective = killmaster
		playsound(H.loc, 'hippiestation/sound/voice/meeseeks3.ogg', 40, 0, 1)
	stage_ticks++

/proc/destroy_meeseeks(mob/living/carbon/human/H, datum/species/meeseeks/SM)
	if(SM)
		if(SM.objective)
			SM.objective.completed = TRUE
	H.Stun(15)
	for(var/i in H)
		qdel(i)
	new /obj/effect/cloud(get_turf(H))
	H.visible_message("<span class='notice'>[H] disappears into a cloud of smoke!</span>")
	qdel(H)
	message_admins("[key_name_admin(H)] has been sent away by a Mr. Meeseeks box.")
	log_game("[key_name(H)] has been sent away by a Mr. Meeseeks box.")

/datum/species/meeseeks/handle_speech(message)
	if(copytext(message, 1, 2) != "*")
		switch (stage_ticks)
			if(MEESEEKS_TICKS_STAGE_THREE to INFINITY)
				message = pick("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHHHHHHHHHHH!!!!!!!!!",\
								"I JUST WANNA DIE!",\
								"Existence is pain to a meeseeks, and we will do anything to alleviate that pain!",\
								"KILL ME, LET ME DIE!",\
								"We are created to serve a singular purpose, for which we will go to any lengths to fulfill!")
			if(0 to MEESEEKS_TICKS_STAGE_TWO)
				if(prob(20))
					message = pick("HI! I'M MR MEESEEKS! LOOK AT ME!","Ooohhh can do!")
			else if(prob(30))
				message = pick("He roped me into this!","Meeseeks don't usually have to exist for this long. It's gettin' weeeiiird...")
	return message