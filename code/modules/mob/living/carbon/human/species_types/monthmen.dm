/datum/species/monthmen
	//an exotic species that arrives once a year to remove the worst species, mothpeople.
	name = "Monthman"
	id = "month"
	//visuals
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,NO_UNDERWEAR,NOBLOOD,ABSTRACT_HEAD)
	fixed_mut_color = "FFF"
	damage_overlay_type = "" //no blood
	missing_eye_state = "montheyes_missing"
	offset_features = list(OFFSET_UNIFORM = list(0,0), OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,0), OFFSET_EARS = list(0,-7), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(0,0), OFFSET_HEAD = list(0,-6), OFFSET_FACE = list(0,0), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), OFFSET_SUIT = list(0,0), OFFSET_NECK = list(0,0))
	//organs
	mutantbrain = /obj/item/organ/brain/monthmen
	mutanteyes = /obj/item/organ/eyes/monthmen
	mutanttongue = /obj/item/organ/tongue/monthmen
	mutantears = /obj/item/organ/ears/monthmen
	//other traits
	no_equip = list(ITEM_SLOT_MASK, ITEM_SLOT_EYES)
	siemens_coeff = 0 //not very good at conducting electricity
	sexes = FALSE
	inherent_traits = list(TRAIT_NOHUNGER,TRAIT_NOBREATH)
	meat = /obj/item/stack/sheet/cardboard
	skinned_type = /obj/item/paper

	var/chest_covered = FALSE

/datum/species/monthmen/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		return TRUE
	return ..()

/datum/species/monthmen/random_name(gender,unique,lastname)
	var/month = pick(list("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"))
	var/days_in_that_month = 31
	switch(month)
		if("February")
			days_in_that_month = 29
		if("April", "June", "September", "November")
			days_in_that_month = 30

	var/day_chosen = rand(1, days_in_that_month)
	var/append
	switch(day_chosen)
		if(1)
			append = "st"
		if(2)
			append = "nd"
		if(3)
			append = "rd"

	return "[day_chosen][append] of [month]"

/datum/species/monthmen/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.gib_butchering = TRUE
	//get rid of anything that may delete with the head
	H.dropItemToGround(H.head, TRUE)
	H.dropItemToGround(H.wear_mask, TRUE)
	H.dropItemToGround(H.ears, TRUE)
	var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		head.drop_limb()
		qdel(head)
	H.regenerate_limbs()
	if(!get_location_accessible(H, BODY_ZONE_CHEST))
		H.become_blind("blocked vision")

/datum/species/monthmen/on_species_loss(mob/living/carbon/human/H)
	H.gib_butchering = FALSE
	H.regenerate_limb(BODY_ZONE_HEAD,FALSE)
	H.cure_blind("blocked vision")
	H.remove_client_colour(/datum/client_colour/monochrome/blind)
	..()

/datum/species/monthmen/spec_life(mob/living/carbon/human/H)
	if(H.fire_stacks < 1)
		H.adjust_fire_stacks(1) //always prone to burning
	..()

/datum/species/monthmen/body_coverage_changed(obj/item/I, mob/living/carbon/human/H)
	if(istype(I, /obj/item/clothing/head))
		var/obj/item/clothing/head/hat = I
		if(hat.flags_cover) //needs to block nothing to be allowed, doesn't take into account hair so stuff like beanies is okay
			to_chat(H, "<span class='warning'>The [I] is too shapely to wear on your flat head! It simply tumbles to the ground.</span>")
			H.dropItemToGround(H.head, TRUE)
			return
	if(!get_location_accessible(H, BODY_ZONE_CHEST))
		if(!chest_covered)//already covered, don't send this
			to_chat(H, "<span class='warning'>The [I] is blocking you from seeing anything!</span>")
			chest_covered = TRUE
		H.become_blind("blocked vision") //not eyes covered because that is for tints and other things, which are for GLASSES level blinding
	else
		if(chest_covered)//already uncovered, don't send this
			to_chat(H, "<span class='notice'>You can see again!</span>")
			chest_covered = FALSE
		H.cure_blind("blocked vision")
		H.remove_client_colour(/datum/client_colour/monochrome/blind) //i fucking hate blindcode so i'm adding this to make ABSOLUTELY sure it's gone.

//all the organs, now in the chest.
/obj/item/organ/brain/monthmen
	zone = BODY_ZONE_CHEST

/obj/item/organ/tongue/monthmen
	zone = BODY_ZONE_CHEST

/obj/item/organ/ears/monthmen
	zone = BODY_ZONE_CHEST

/obj/item/organ/eyes/monthmen
	name = "monthmen eyes"
	desc = "Turns out googly eyes in real life are horrifying."
	zone = BODY_ZONE_CHEST
	icon_state = "montheyeballs"
	eye_icon_state = "montheyes"
