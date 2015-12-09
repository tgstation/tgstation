/datum/organ/butt
	name = "butt"
	organitem_type = /obj/item/organ/butt

//For cavity implants, obviously
/datum/organ/cavity
	name = "cavity"
	organitem_type = /obj/item

/datum/organ/internal
	var/vital = 0	//Whether this organ is vital. Doesn't do anything right now, if it stays that way this can be removed. |- Ricotez


/datum/organ/internal/dismember(var/dism_type, var/special = 0)
	return remove(dism_type, owner.loc, special)

/datum/organ/internal/remove(var/dism_type, var/newloc, var/special = 0)
	var/obj/item/O = ..(dism_type, newloc, special)
	if(O)
		if(owner && vital && !special)
			owner.death()
	return O

/datum/organ/internal/brain
	name = "brain"
	vital = 1
	organitem_type = /obj/item/organ/internal/brain

/datum/organ/internal/heart
	name = "heart"
	vital = 1
	organitem_type = /obj/item/organ/internal/heart

/datum/organ/internal/appendix
	name = "appendix"
	organitem_type = /obj/item/organ/internal/appendix

/datum/organ/internal/eyes
	name = "eyes"

/datum/organ/internal/cyberimp
	organitem_type = /obj/item/organ/internal/cyberimp

/datum/organ/internal/cyberimp/brain
	name = "cyberimp_brain"
	organitem_type = /obj/item/organ/internal/cyberimp/brain

/datum/organ/internal/cyberimp/chest
	name = "cyberimp_chest"
	organitem_type = /obj/item/organ/internal/cyberimp/chest