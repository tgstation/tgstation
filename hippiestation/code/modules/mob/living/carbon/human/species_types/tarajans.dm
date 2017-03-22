/datum/species/tarajan
	name = "Catbeast"
	id = "tarajan"
	say_mod = "meows"
	blacklisted = 0
	sexes = 1
	species_traits = list(MUTCOLORS,EYECOLOR,NOTRANSSTING)
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	mutant_bodyparts = list("tail_human")
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/meatproduct
	skinned_type = /obj/item/stack/sheet/animalhide/cat
	exotic_bloodtype = "O-" //universal donor, more reason to drain their blood
	burnmod = 1.25
	brutemod = 1.25
	teeth_type = /obj/item/stack/teeth/cat

/datum/species/tarajan/qualifies_for_rank(rank, list/features)
	if(rank in command_positions) //even if you turn off humans only
		return 0
	if(rank in security_positions) //This list does not include lawyers.
		return 0
	if(rank in science_positions)
		return 0
	if(rank in medical_positions)
		return 0
	if(rank in engineering_positions)
		return 0
	if(rank == "Quartermaster") //QM is not contained in command_positions but we still want to bar mutants from it.
		return 0
	return 1

/datum/species/tarajan/on_species_gain(mob/living/carbon/human/C)
	C.draw_hippie_parts()
	C.dna.features["tail_human"] = "TCat"
	. = ..()

/datum/species/tarajan/on_species_loss(mob/living/carbon/human/C)
	C.draw_hippie_parts(TRUE)
	C.dna.features["tail_human"] = null
	. = ..()

/obj/item/bodypart/var/should_draw_hippie = FALSE

/mob/living/carbon/proc/draw_hippie_parts(undo = FALSE)
	if(!undo)
		for(var/O in bodyparts)
			var/obj/item/bodypart/B = O
			B.should_draw_hippie = TRUE
	else
		for(var/O in bodyparts)
			var/obj/item/bodypart/B = O
			B.should_draw_hippie = FALSE