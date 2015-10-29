//IMPORTANT: Think of organdata as a "reservation" for organ spaces in a mob.
//It gives a container type that can stay constant while the actual organ itself changes.
//This system is based on Bay's, so thanks to whichever coder originally designed it.
//But unlike Bay's system, we store most of the organ-related data in physical organs. These datums really are nothing more than "reservations".
// |- Ricotez

//ALSO IMPORTANT: If you want to actually do anything with an organ, check if it exists with exists() first,
//then access the organitem to perform the operations on. Organdata should not actually store most organ-related data.
//You can think of it like this: if you cut open your arm, and then rip it off, the cut is still on your arm even though it
//is no longer a part of your body. |- Ricotez

/datum/organ
	var/name = "organ"
	var/mob/living/carbon/owner = null
	var/status = ORGAN_REMOVED		//Status of organ. 0 is a normal, human organ, but it starts out at ORGAN_REMOVED in case you want to add empty organ slots to an organsystem. See _DEFINES/organ.dm for possible statuses..
	var/vital = 0					//Whether this organ is vital. Doesn't do anything right now, if it stays that way this can be removed. |- Ricotez
	var/destroyed_dam = 0 			//Amount of (brute) damage to count in damage checks if status of this organ is set to ORGAN_DESTROYED. Only applies to limbs right now. |- Ricotez
	var/can_be_damaged = 0 			//Whether this organ can take damage. Keep this 0 for anything that is not a limb, unless you want to extend the damage system to all organs. |- Ricotez

	var/datum/organ/parent			//The organ this organ is a part of. For example, of this is the brain, its parent will be the head.
	var/list/datum/organ/children	//The organs that are a part of this organ. For example, if this is the chest, its children will contain arms, legs and probably also a heart and appendix.

	var/organitem_type = /obj/item/organ	//Typepath of the organ item(s) this datum may be associated with.
	var/obj/item/organ/organitem			//The actual physical organ item this datum is associated with.

/datum/organ/proc/get_icon(var/icon/race_icon, var/icon/deform_icon)
	return icon('icons/mob/human.dmi',"blank")


/datum/organ/New(var/datum/organ/P)
	if(P)
		parent = P
		if(!parent.children)
			parent.children = list()
		parent.children.Add(src)
	return ..()

/datum/organ/proc/regenerate_organitem()
	var/obj/item/organ/neworgan = new organitem_type
	set_organitem(neworgan)

/datum/organ/proc/set_organitem(var/obj/item/organ/O) //Sets this organ's organitem, but only if it does not already have an organitem.
	if(O && !organitem && istype(O, organitem_type))
		organitem = O
		status = organitem.status
		organitem.owner = owner
		organitem.organdatum = src

/datum/organ/proc/exists() //Decide whether this organ has a pysical representation in the body right now.
	return organitem && !(status & ORGAN_DESTROYED) && !(status & ORGAN_REMOVED) && !(status & ORGAN_NOBLEED)
	//Usually it's enough to just check if an organitem is there, because it should be removed iff any of these are true.
	//But in case you want to test something, you can also just set a limb's status to one of these flags by varediting it without removing the physical item.
	//As far as the code is concerned, the limb is missing if any of those are true. The damage won't even be counted.

//Call this proc with the type of dismemberment that happens and it will send the organitem to the ground below the target.
/datum/organ/proc/dismember(var/dism_type)
	if(exists())
		status = dism_type
		organitem.status = dism_type
		organitem.owner = null
		organitem.organdatum = null
		organitem.loc = owner.loc
		var/obj/item/organ/O = organitem //We save the organ to a separate var...
		organitem = null //...so we can delete its reference here.
		O.organdatum = null
		owner.update_body_parts() //Obviously we need to update the icon.
		return O //We return the organ object in case we want some information from it.
	else
		return null //If dismemberment failed because the limb does not exist, we return null.

/datum/organ/butt
	name = "butt"
	organitem_type = /obj/item/organ/butt

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


