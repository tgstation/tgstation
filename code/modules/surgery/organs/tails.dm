// Note: tails only work in humans. They use human-specific parameters and rely on human code for displaying.

/obj/item/organ/tail
	name = "tail"
	desc = "A severed tail. What did you cut this off of?"
	icon_state = "severedtail"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_TAIL
	var/tail_type = "None"

/obj/item/organ/tail/Insert(mob/living/carbon/human/tail_owner, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	tail_owner?.dna?.species?.on_tail_regain(tail_owner, src, special)

/obj/item/organ/tail/Remove(mob/living/carbon/human/tail_owner, special = FALSE)
	. = ..()
	tail_owner?.dna?.species?.on_tail_lost(tail_owner, src, special)

/obj/item/organ/tail/cat
	name = "cat tail"
	desc = "A severed cat tail. Who's wagging now?"
	tail_type = "Cat"

/obj/item/organ/tail/cat/Insert(mob/living/carbon/human/tail_owner, special = FALSE, drop_if_replaced = TRUE)
	..()
	if(istype(tail_owner))
		var/default_part = tail_owner.dna.species.mutant_bodyparts["tail_human"]
		if(!default_part || default_part == "None")
			tail_owner.dna.features["tail_human"] = tail_owner.dna.species.mutant_bodyparts["tail_human"] = tail_type
			tail_owner.update_body()

/obj/item/organ/tail/cat/Remove(mob/living/carbon/human/tail_owner, special = FALSE)
	..()
	if(istype(tail_owner))
		tail_owner.dna.features["tail_human"] = "None"
		tail_owner.dna.species.mutant_bodyparts -= "tail_human"
		color = tail_owner.hair_color
		tail_owner.update_body()

/obj/item/organ/tail/lizard
	name = "lizard tail"
	desc = "A severed lizard tail. Somewhere, no doubt, a lizard hater is very pleased with themselves."
	color = "#116611"
	tail_type = "Smooth"
	var/spines = "None"

/obj/item/organ/tail/lizard/Initialize()
	. = ..()
	color = "#"+ random_color()

/obj/item/organ/tail/lizard/Insert(mob/living/carbon/human/tail_owner, special = FALSE, drop_if_replaced = TRUE)
	..()
	if(istype(tail_owner))
		// Checks here are necessary so it wouldn't overwrite the tail of a lizard it spawned in
		var/default_part = tail_owner.dna.species.mutant_bodyparts["tail_lizard"]
		if(!default_part || default_part == "None")
			tail_owner.dna.features["tail_lizard"] = tail_owner.dna.species.mutant_bodyparts["tail_lizard"] = tail_type

		default_part = tail_owner.dna.species.mutant_bodyparts["spines"]
		if(!default_part || default_part == "None")
			tail_owner.dna.features["spines"] = tail_owner.dna.species.mutant_bodyparts["spines"] = spines
		tail_owner.update_body()

/obj/item/organ/tail/lizard/Remove(mob/living/carbon/human/tail_owner, special = FALSE)
	..()
	if(istype(tail_owner))
		tail_owner.dna.species.mutant_bodyparts -= "tail_lizard"
		tail_owner.dna.species.mutant_bodyparts -= "spines"
		color = "#" + tail_owner.dna.features["mcolor"]
		tail_type = tail_owner.dna.features["tail_lizard"]
		spines = tail_owner.dna.features["spines"]
		tail_owner.update_body()

/obj/item/organ/tail/lizard/before_organ_replacement(obj/item/organ/replacement)
	. = ..()
	var/obj/item/organ/tail/lizard/new_tail = replacement

	if(!istype(new_tail))
		return

	new_tail.tail_type = tail_type
	new_tail.spines = spines

/obj/item/organ/tail/lizard/fake
	name = "fabricated lizard tail"
	desc = "A fabricated severed lizard tail. This one's made of synthflesh. Probably not usable for lizard wine."

/obj/item/organ/tail/monkey
	name = "monkey tail"
	desc = "A severed monkey tail. Does not look like a banana."
	tail_type = "Monkey"
	icon_state = "severedmonkeytail"

/obj/item/organ/tail/monkey/Insert(mob/living/carbon/human/tail_owner, special = FALSE, drop_if_replaced = TRUE)
	..()
	if(istype(tail_owner))
		if(!("tail_monkey" in tail_owner.dna.species.mutant_bodyparts))
			tail_owner.dna.species.mutant_bodyparts |= "tail_monkey"
			tail_owner.dna.features["tail_monkey"] = tail_type
			tail_owner.update_body()

/obj/item/organ/tail/monkey/Remove(mob/living/carbon/human/tail_owner, special = FALSE)
	..()
	if(istype(tail_owner))
		tail_owner.dna.features["tail_monkey"] = "None"
		tail_owner.dna.species.mutant_bodyparts -= "tail_monkey"
		tail_owner.update_body()
