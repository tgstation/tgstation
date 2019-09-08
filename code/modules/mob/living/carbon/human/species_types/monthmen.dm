/datum/species/monthmen
	//an exotic species that arrives once a year to remove the worst species, mothpeople.
	name = "Monthman"
	id = "month"
	//visuals
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,NO_UNDERWEAR,NOBLOOD,ABSTRACT_HEAD)
	default_features = list("mcolor" = "FFF")
	skinned_type = /obj/item/paper
	changesource_flags = VARDROPDOWN | EVENTRACE //absolutely no way to get the race even for admins, it's completely out of theme of ss13
	damage_overlay_type = "" //no blood
	missing_eye_state = "montheyes_missing"
	offset_features = list(OFFSET_UNIFORM = list(0,0), OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,0), OFFSET_EARS = list(0,-7), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(0,0), OFFSET_HEAD = list(0,-6), OFFSET_FACE = list(0,0), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), OFFSET_SUIT = list(0,0), OFFSET_NECK = list(0,0))
	//organs
	mutant_brain = /obj/item/organ/brain/monthmen
	mutanteyes = /obj/item/organ/eyes/monthmen
	mutanttongue = /obj/item/organ/tongue/monthmen
	mutantears = /obj/item/organ/ears/monthmen
	//other traits
	no_equip = list(SLOT_WEAR_MASK, SLOT_GLASSES)
	siemens_coeff = 0 //not very good at conducting electricity
	sexes = FALSE
	inherent_traits = list(TRAIT_NOHUNGER,TRAIT_NOBREATH)
	meat = /obj/item/stack/sheet/cardboard

/datum/species/monthmen/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		return TRUE
	return ..()

/datum/species/monthmen/random_name(gender,unique,lastname)
	var/month = pick(list("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"))
	var/days_in_that_month = 31
	switch(month)
		if("February")//hey look the FUCK month where i have to calculate leap years
			if(isLeap(text2num(time2text(world.timeofday, "YY"))))
				days_in_that_month = 29
			else
				days_in_that_month = 28
		if("April", "June", "September", "November")
			days_in_that_month = 30

	return "[capitalize(thtotext(rand(1, days_in_that_month)))] of [month]"

/datum/species/monthmen/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		head.drop_limb()
		qdel(head)
	H.regenerate_limbs()

/datum/species/monthmen/on_species_loss(mob/living/carbon/human/H)
	H.regenerate_limb(BODY_ZONE_HEAD,FALSE)
	..()

/datum/species/monthmen/spec_life(mob/living/carbon/human/H)
	if(H.fire_stacks < 1)
		H.adjust_fire_stacks(1) //always prone to burning
	..()

/datum/species/monthmen/equipped_something(obj/item/I, mob/living/carbon/human/H, just_adjust = FALSE)
	var/blocked = FALSE
	if(istype(I, /obj/item/storage/backpack))
		blocked = TRUE //straps go over eyes, ouch
		if(istype(I, /obj/item/storage/backpack/satchel) || istype(I, /obj/item/storage/backpack/duffelbag))
			blocked = FALSE //we're good again these don't do that. we put the check down here so we don't have to do this for every item equipped
	if(!get_location_accessible(H, BODY_ZONE_CHEST))
		blocked = TRUE
	if(blocked)//you put something over your eyes
		to_chat(H, "<span class='warning'>The [I] is blocking you from seeing anything!</span>")
		become_blind("blocked vision") //not eyes covered because that is for tints and other things, which are for GLASSES level blinding

/datum/species/monthmen/unequipped_something(obj/item/I, mob/living/carbon/human/H, just_adjust = FALSE)
	var/blocked = FALSE
	if(istype(I, /obj/item/storage/backpack))
		blocked = TRUE
		if(istype(I, /obj/item/storage/backpack/satchel) || istype(I, /obj/item/storage/backpack/duffelbag))
			blocked = FALSE
	if(!get_location_accessible(H, BODY_ZONE_CHEST))
		blocked = TRUE
	if(!blocked)//you took off whatever was covering your eyes
		to_chat(H, "<span class='notice'>You can see again!</span>")
		cure_blind("blocked vision")

//all the organs, just abstract copies (may change?)
/obj/item/organ/brain/monthmen
	decoy_override = TRUE
	organ_flags = 0

/obj/item/organ/tongue/monthmen
	zone = "abstract"

/obj/item/organ/ears/monthmen
	zone = "abstract"

/obj/item/organ/eyes/monthmen
	name = "monthmen eyes"
	desc = "Turns out googly eyes in real life are horrifying."
	zone = BODY_ZONE_CHEST
	icon_state = "montheyeballs"
	eye_icon_state = "montheyes"
