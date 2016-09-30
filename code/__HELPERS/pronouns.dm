//pronoun procs, for getting pronouns without using the text macros that only work in certain positions
//datums don't have gender, but most of their subtypes do!
/datum/proc/they_pronoun(capitalized, temp_gender)
	. = "it"
	if(capitalized)
		. = capitalize(.)

/datum/proc/their_pronoun(capitalized, temp_gender)
	. = "its"
	if(capitalized)
		. = capitalize(.)

/datum/proc/them_pronoun(capitalized, temp_gender)
	. = "it"
	if(capitalized)
		. = capitalize(.)

/datum/proc/get_has(temp_gender)
	. = "has"

/datum/proc/get_is(temp_gender)
	. = "is"

//like clients, which do have gender.
/client/they_pronoun(capitalized, temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "they"
	switch(temp_gender)
		if(FEMALE)
			. = "she"
		if(MALE)
			. = "he"
	if(capitalized)
		. = capitalize(.)

/client/their_pronoun(capitalized, temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "their"
	switch(temp_gender)
		if(FEMALE)
			. = "her"
		if(MALE)
			. = "his"
	if(capitalized)
		. = capitalize(.)

/client/them_pronoun(capitalized, temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "them"
	switch(temp_gender)
		if(FEMALE)
			. = "her"
		if(MALE)
			. = "him"
	if(capitalized)
		. = capitalize(.)

/client/get_has(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "has"
	if(temp_gender == PLURAL || temp_gender == NEUTER)
		. = "have"

/client/get_is(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "is"
	if(temp_gender == PLURAL || temp_gender == NEUTER)
		. = "are"

//mobs(and atoms but atoms don't really matter write your own proc overrides) also have gender!
/mob/they_pronoun(capitalized, temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "it"
	switch(temp_gender)
		if(FEMALE)
			. = "she"
		if(MALE)
			. = "he"
		if(PLURAL)
			. = "they"
	if(capitalized)
		. = capitalize(.)

/mob/their_pronoun(capitalized, temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "its"
	switch(temp_gender)
		if(FEMALE)
			. = "her"
		if(MALE)
			. = "his"
		if(PLURAL)
			. = "their"
	if(capitalized)
		. = capitalize(.)

/mob/them_pronoun(capitalized, temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "it"
	switch(temp_gender)
		if(FEMALE)
			. = "her"
		if(MALE)
			. = "him"
		if(PLURAL)
			. = "them"
	if(capitalized)
		. = capitalize(.)

/mob/get_has(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "has"
	if(temp_gender == PLURAL)
		. = "have"

/mob/get_is(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "is"
	if(temp_gender == PLURAL)
		. = "are"

//humans need special handling, because they can have their gender hidden
/mob/living/carbon/human/they_pronoun(capitalized, temp_gender)
	var/list/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if((slot_w_uniform in obscured) && skipface)
		temp_gender = PLURAL
	return ..()

/mob/living/carbon/human/their_pronoun(capitalized, temp_gender)
	var/list/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if((slot_w_uniform in obscured) && skipface)
		temp_gender = PLURAL
	return ..()

/mob/living/carbon/human/them_pronoun(capitalized, temp_gender)
	var/list/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if((slot_w_uniform in obscured) && skipface)
		temp_gender = PLURAL
	return ..()

/mob/living/carbon/human/get_has(temp_gender)
	var/list/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if((slot_w_uniform in obscured) && skipface)
		temp_gender = PLURAL
	return ..()

/mob/living/carbon/human/get_is(temp_gender)
	var/list/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if((slot_w_uniform in obscured) && skipface)
		temp_gender = PLURAL
	return ..()
