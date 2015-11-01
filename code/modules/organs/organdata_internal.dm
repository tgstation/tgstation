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
	if(exists())
		status = dism_type					//We change the organdatum status to the type of dismemberment (ORGAN_DESTROYED, ORGAN_REMOVED or ORGAN_NOBLEED).
		if(isorgan(organitem))
			var/obj/item/organ/internal/OI = organitem
			OI.Remove(special)	//Special stuff the organ needs done when removed
		if(owner && vital && !special)
			owner.death()
		var/obj/item/organ/O = prepare_organitem_for_removal()	//We use the convenient preparation proc to nullify the necessary variables.
		if(newloc)
			O.loc = newloc					//The organitem ends up at the new location. newloc
		else
			O.loc = owner.loc
		if(owner)
			owner.update_body_parts()			//Obviously we need to update the icon of the owner, else they will look like they still have the organ.
		return O							//We return the organ object in case we want some information from it.
	else
		return null							//If dismemberment failed because the limb does not exist, we return null.


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
	var/zone = null
	var/maximps = 0
	organitem_type = /obj/item/organ/internal/cyberimp

//Might redefine these so there's only cyberimp/brain and cyberimp/chest.
/datum/organ/internal/cyberimp/set_organitem(var/obj/item/organ/O)
	if(owner && owner.get_cyberimps(zone) >= maximps)
		return 0
	return ..()

/datum/organ/internal/cyberimp/brain
	organitem_type = /obj/item/organ/internal/cyberimp/brain
	maximps = MAX_BRAIN_IMPLANT

/datum/organ/internal/cyberimp/brain/anti_drop
	name = "antidrop_implant"
	organitem_type = /obj/item/organ/internal/cyberimp/brain/anti_drop

/datum/organ/internal/cyberimp/brain/anti_stun
	name = "antistun_implant"
	organitem_type = /obj/item/organ/internal/cyberimp/brain/anti_stun

/datum/organ/internal/cyberimp/chest
	organitem_type = /obj/item/organ/internal/cyberimp/chest
	maximps = MAX_CHEST_IMPLANT

/datum/organ/internal/cyberimp/chest/nutriment
	name = "nutriment_implant"
	organitem_type = /obj/item/organ/internal/cyberimp/chest/nutriment

/datum/organ/internal/cyberimp/chest/reviver
	name = "reviver_implant"
	organitem_type = /obj/item/organ/internal/cyberimp/chest/reviver

/datum/organ/internal/gland/
	name = "abductor_gland"