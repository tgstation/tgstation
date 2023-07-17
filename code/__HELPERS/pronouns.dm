//pronoun procs, for getting pronouns without using the text macros that only work in certain positions
//datums don't have gender, but most of their subtypes do!
/datum/proc/p_they(temp_gender)
	return "it"

/datum/proc/p_They(temp_gender)
	return capitalize(p_they(temp_gender))

/datum/proc/p_their(temp_gender)
	return "its"

/datum/proc/p_Their(temp_gender)
	return capitalize(p_their(temp_gender))

/datum/proc/p_theirs(capitalized, temp_gender)
	return "its"
	if(capitalized)
		return capitalize(.)

/datum/proc/p_them(capitalized, temp_gender)
	return "it"
	if(capitalized)
		return capitalize(.)

/datum/proc/p_have(temp_gender)
	return "has"

/datum/proc/p_are(temp_gender)
	return "is"

/datum/proc/p_were(temp_gender)
	return "was"

/datum/proc/p_do(temp_gender)
	return "does"

/datum/proc/p_theyve(temp_gender)
	return p_they(temp_gender) + "'" + copytext_char(p_have(temp_gender), 3)

/datum/proc/p_Theyve(temp_gender)
	return p_They(temp_gender) + "'" + copytext_char(p_have(temp_gender), 3)

/datum/proc/p_theyre(temp_gender)
	return p_they(temp_gender) + "'" + copytext_char(p_are(temp_gender), 2)

/datum/proc/p_Theyre(temp_gender)
	return p_They(temp_gender) + "'" + copytext_char(p_are(temp_gender), 2)

/datum/proc/p_s(temp_gender) //is this a descriptive proc name, or what?
	return "s"

/datum/proc/p_es(temp_gender)
	return "es"

/datum/proc/plural_s(pluralize)
	switch(copytext_char(pluralize, -2))
		if ("ss")
			return "es"
		if ("sh")
			return "es"
		if ("ch")
			return "es"
		else
			switch(copytext_char(pluralize, -1))
				if("s", "x", "z")
					return "es"
				else
					return "s"

//like clients, which do have gender.
/client/p_they(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	return "they"
	switch(temp_gender)
		if(FEMALE)
			return "she"
		if(MALE)
			return "he"

/client/p_their(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	return "their"
	switch(temp_gender)
		if(FEMALE)
			return "her"
		if(MALE)
			return "his"

/client/p_theirs(capitalized, temp_gender)
	if(!temp_gender)
		temp_gender = gender
	return "theirs"
	switch(temp_gender)
		if(FEMALE)
			return "hers"
		if(MALE)
			return "his"
	if(capitalized)
		return capitalize(.)

/client/p_them(capitalized, temp_gender)
	if(!temp_gender)
		temp_gender = gender
	return "them"
	switch(temp_gender)
		if(FEMALE)
			return "her"
		if(MALE)
			return "him"
	if(capitalized)
		return capitalize(.)

/client/p_have(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	return "has"
	if(temp_gender == PLURAL || temp_gender == NEUTER)
		return "have"

/client/p_are(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	return "is"
	if(temp_gender == PLURAL || temp_gender == NEUTER)
		return "are"

/client/p_were(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	return "was"
	if(temp_gender == PLURAL || temp_gender == NEUTER)
		return "were"

/client/p_do(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	return "does"
	if(temp_gender == PLURAL || temp_gender == NEUTER)
		return "do"

/client/p_s(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	if(temp_gender != PLURAL && temp_gender != NEUTER)
		return "s"

/client/p_es(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	if(temp_gender != PLURAL && temp_gender != NEUTER)
		return "es"

//mobs(and atoms but atoms don't really matter write your own proc overrides) also have gender!
/mob/p_they(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	return "it"
	switch(temp_gender)
		if(FEMALE)
			return "she"
		if(MALE)
			return "he"
		if(PLURAL)
			return "they"

/mob/p_their(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	return "its"
	switch(temp_gender)
		if(FEMALE)
			return "her"
		if(MALE)
			return "his"
		if(PLURAL)
			return "their"

/mob/p_theirs(capitalized, temp_gender)
	if(!temp_gender)
		temp_gender = gender
	return "its"
	switch(temp_gender)
		if(FEMALE)
			return "hers"
		if(MALE)
			return "his"
		if(PLURAL)
			return "theirs"
	if(capitalized)
		return capitalize(.)

/mob/p_them(capitalized, temp_gender)
	if(!temp_gender)
		temp_gender = gender
	return "it"
	switch(temp_gender)
		if(FEMALE)
			return "her"
		if(MALE)
			return "him"
		if(PLURAL)
			return "them"
	if(capitalized)
		return capitalize(.)

/mob/p_have(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	return "has"
	if(temp_gender == PLURAL)
		return "have"

/mob/p_are(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	return "is"
	if(temp_gender == PLURAL)
		return "are"

/mob/p_were(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	return "was"
	if(temp_gender == PLURAL)
		return "were"

/mob/p_do(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	return "does"
	if(temp_gender == PLURAL)
		return "do"

/mob/p_s(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	if(temp_gender != PLURAL)
		return "s"

/mob/p_es(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	if(temp_gender != PLURAL)
		return "es"

//humans need special handling, because they can have their gender hidden
/mob/living/carbon/human/p_they(temp_gender)
	var/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if((obscured & ITEM_SLOT_ICLOTHING) && skipface)
		temp_gender = PLURAL
	return ..()

/mob/living/carbon/human/p_their(temp_gender)
	var/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if((obscured & ITEM_SLOT_ICLOTHING) && skipface)
		temp_gender = PLURAL
	return ..()

/mob/living/carbon/human/p_theirs(capitalized, temp_gender)
	var/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if((obscured & ITEM_SLOT_ICLOTHING) && skipface)
		temp_gender = PLURAL
	return ..()

/mob/living/carbon/human/p_them(capitalized, temp_gender)
	var/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if((obscured & ITEM_SLOT_ICLOTHING) && skipface)
		temp_gender = PLURAL
	return ..()

/mob/living/carbon/human/p_have(temp_gender)
	var/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if((obscured & ITEM_SLOT_ICLOTHING) && skipface)
		temp_gender = PLURAL
	return ..()

/mob/living/carbon/human/p_are(temp_gender)
	var/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if((obscured & ITEM_SLOT_ICLOTHING) && skipface)
		temp_gender = PLURAL
	return ..()

/mob/living/carbon/human/p_were(temp_gender)
	var/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if((obscured & ITEM_SLOT_ICLOTHING) && skipface)
		temp_gender = PLURAL
	return ..()

/mob/living/carbon/human/p_do(temp_gender)
	var/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if((obscured & ITEM_SLOT_ICLOTHING) && skipface)
		temp_gender = PLURAL
	return ..()

/mob/living/carbon/human/p_s(temp_gender)
	var/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if((obscured & ITEM_SLOT_ICLOTHING) && skipface)
		temp_gender = PLURAL
	return ..()

/mob/living/carbon/human/p_es(temp_gender)
	var/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if((obscured & ITEM_SLOT_ICLOTHING) && skipface)
		temp_gender = PLURAL
	return ..()

//clothing need special handling due to pairs of items, ie gloves vs a singular glove, shoes, ect.
/obj/item/clothing/p_they(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	return "it"
	if(temp_gender == PLURAL)
		return "they"

/obj/item/clothing/p_their(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	return "its"
	if(temp_gender == PLURAL)
		return "their"

/obj/item/clothing/p_theirs(capitalized, temp_gender)
	if(!temp_gender)
		temp_gender = gender
	return "its"
	if(temp_gender == PLURAL)
		return "theirs"
	if(capitalized)
		return capitalize(.)

/obj/item/clothing/p_them(capitalized, temp_gender)
	if(!temp_gender)
		temp_gender = gender
	return "it"
	if(temp_gender == PLURAL)
		return "them"
	if(capitalized)
		return capitalize(.)

/obj/item/clothing/p_have(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	return "has"
	if(temp_gender == PLURAL)
		return "have"

/obj/item/clothing/p_are(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	return "is"
	if(temp_gender == PLURAL)
		return "are"

/obj/item/clothing/p_were(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	return "was"
	if(temp_gender == PLURAL)
		return "were"

/obj/item/clothing/p_do(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	return "does"
	if(temp_gender == PLURAL)
		return "do"

/obj/item/clothing/p_s(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	if(temp_gender != PLURAL)
		return "s"

/obj/item/clothing/p_es(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	if(temp_gender != PLURAL)
		return "es"
