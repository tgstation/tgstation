#define MEESEEKS_TICKS_STAGE_TWO	200
#define MEESEEKS_TICKS_STAGE_THREE	300

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
	punchmod = 1
	species_traits = list(RESISTHOT,RESISTCOLD,RESISTPRESSURE,RADIMMUNE,NOBREATH,NOBLOOD,NOFIRE,VIRUSIMMUNE,PIERCEIMMUNE,NOTRANSSTING,NOHUNGER,NOCRITDAMAGE,NOZOMBIE,NO_UNDERWEAR,EASYDISMEMBER)
	teeth_type = /obj/item/stack/teeth/meeseeks
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/meeseeks
	damage_overlay_type = ""
	var/mob/living/carbon/master
	var/stage_ticks = 1

/datum/species/meeseeks/on_species_gain(mob/living/carbon/human/C)
	C.draw_hippie_parts()
	. = ..()

/datum/species/meeseeks/on_species_loss(mob/living/carbon/human/C)
	C.draw_hippie_parts(TRUE)
	. = ..()

/datum/species/meeseeks/handle_speech(message)
	if(copytext(message, 1, 2) != "*")
		switch (stage)
			if(1)
				if(prob(20))
					message = pick("HI! I'M MR MEESEEKS! LOOK AT ME!",
									"Ooohhh can do!")
			if(2)
				if(prob(30))
					message = pick("He roped me into this!",
								"Meeseeks don't usually have to exist for this long. It's gettin' weeeiiird...")
			if(3)
				message = pick("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHHHHHHHHHHH!!!!!!!!!",
								"I JUST WANNA DIE!","Existence is pain to a meeseeks, and we will do anything to alleviate that pain.!",
								"KILL ME, LET ME DIE!",
								"We are created to serve a singular purpose, for which we will go to any lengths to fulfill!")
	return message