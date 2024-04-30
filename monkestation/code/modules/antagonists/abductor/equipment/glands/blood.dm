/obj/item/organ/internal/heart/gland/blood
	/// The mob's original blood type, to be reverted to when the organ is removed.
	var/original_blood_type

/obj/item/organ/internal/heart/gland/blood/on_insert(mob/living/carbon/human/organ_owner, special)
	. = ..()
	if(!ishuman(owner) || !owner.dna.species)
		return
	original_blood_type = owner.dna.species.exotic_blood

/obj/item/organ/internal/heart/gland/blood/on_remove(mob/living/carbon/human/organ_owner, special)
	. = ..()
	if(!ishuman(owner) || !owner.dna.species)
		return
	owner.dna.species.exotic_blood = original_blood_type
