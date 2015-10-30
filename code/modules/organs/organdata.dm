	//IMPORTANT: Think of organdata as "hardpoints" for organs in a mob.
//It gives a container type that can stay constant while the actual organ itself changes.
//Well constant and constant, removing your head removes your brain container, for example
//This system is based on Bay's, so thanks to whichever coder originally designed it.
//But unlike Bay's system, we store most of the organ-related data in physical organs. These datums really are nothing more than hardpoints.
// |- Ricotez

//ALSO IMPORTANT: If you want to actually do anything with an organ, check if it exists with exists() first,
//then access the organitem to perform the operations on. Organdata should not actually store most organ-related data.
//You can think of it like this: if you cut open your arm, and then rip it off, the cut is still on your arm even though it
//is no longer a part of your body. |- Ricotez

/datum/organ
	var/name = "organ"
	var/mob/living/carbon/owner = null
	var/status = ORGAN_REMOVED		//Status of organ. 0 is a normal, human organ, but it starts out at ORGAN_REMOVED in case you want to add empty organ hardpoints to an organ. See _DEFINES/organ.dm for possible statuses..
	var/destroyed_dam = 0 			//Amount of (brute) damage to count in damage checks if status of this organ is set to ORGAN_DESTROYED. Only applies to limbs right now. |- Ricotez
	var/can_be_damaged = 0 			//Whether this organ can take damage. Keep this 0 for anything that is not a limb, unless you want to extend the damage system to all organs. |- Ricotez

	var/obj/item/organ/parent						//The organ this organ is a part of. For example, of this is the brain, its parent will be the head.
	var/organitem_type = /obj/item/organ	//Typepath of the organ item(s) this datum may be associated with.
	var/obj/item/organ/organitem			//The actual physical organ item this datum is associated with.
//	var/datum/organsystem/organsystem		//The organsystem this organdatum is associated with. Doesn't get set now, ever

/**
  * Constructor.
  * @param P	Parent organ item. Should only be null if this datum is the core of an organsystem.
  * @param I	Organ item associated with this datum. If this is null, the datum is an empty organ hardpoint (missing organ).
 **/
/datum/organ/New(var/obj/item/organ/P, var/obj/item/organ/I)
	set_parent(P)
	set_organitem(I)
	return ..()


//////////// START OF PROCS

/**
  * Set the parent organ containing this datum.
  * Will essentially add a "hardpoint" for this type of organ to the parent.
  *
  *	@param P	Parent organ item. Should only be null if this datum is the core of an organsystem.
 **/
/datum/organ/proc/set_parent(var/obj/item/organ/P)
	if(P)
		parent = P
		parent.add_suborgan(src)
		owner = parent.owner

/**
  *
 **/
/datum/organ/proc/get_icon(var/icon/race_icon, var/icon/deform_icon)
	return icon('icons/mob/human.dmi',"blank")

/**
  * Calls set_organitem with a new organ of whatever most general type this organdatum is associated with.
  * Use for easy regeneration of lost organs, for example changeling fleshmend.
  *
  * @return	Whether regeneration was succesful.
 **/
/datum/organ/proc/regenerate_organitem(var/datum/dna/D)
	var/obj/item/organ/neworgan = new organitem_type()
	set_dna(D)
	return set_organitem(neworgan)

/**
  * Set this organdatum's organitem, but only if it does not already have an organitem.
  *
  * @param O	A reference to the new organitem.
  * @return		Whether the new organitem was succesfully set.
 **/
/datum/organ/proc/set_organitem(var/obj/item/organ/O) //Sets this organ's organitem, but only if it does not already have an organitem.
	if(O && !organitem && istype(O, organitem_type))	//Verify that O is not null, that there is not already an organ and that O is of the right type.
		organitem = O
		status = organitem.status
		organitem.owner = owner
		organitem.organdatum = src
		return 1
	return 0

/**
  * Set the DNA of the organitem associated with this organdatum.
  * This proc is not recursive and will only change the DNA of this one organ.
  *
  * @param D	The new DNA.to set this organ to.
  * @return		Whether DNA was succesfully changed.
 **/
/datum/organ/proc/set_dna(var/datum/dna/D) //Set this organ's DNA.
	if(organitem)
		organitem.set_dna(D)
		return 1
	return 0

/**
  * Set the owner of this datum and call set_owner on its organitem if it has one.
  * Also updates the organsystem, since this is associated with the owner.
  * This proc is recursive because if the owner of an organ changes, it also changes for all suborgans.
  * (Cutting off a head also cuts off the brain.)
  *
  * @param O	The new organ owner. Can be null if the organ has no owner.
 **/
/datum/organ/proc/set_owner(var/mob/O)
	owner = O
	if(organitem)
		organitem.set_owner(O)

/**
  * Decide whether this organ is physically represented in the body right now.
  * Generally it's enough to check if there's an organitem, but in case of variable fuckery we also check
  * if the status is set to ORGAN_DESTROYED, ORGAN_REMOVED or ORGAN_NOBLEED.
  *
  * @return		Whether the organ physically exists.
 **/
/datum/organ/proc/exists() //Decide whether this organ has a pysical representation in the body right now.
	return organitem && !(status & ORGAN_DESTROYED) && !(status & ORGAN_REMOVED) && !(status & ORGAN_NOBLEED)

/**
  * Properly dismember an organ, setting the status of this organdatum to dism_type.
  * The organ will be deposited to the floor below the owner.
  * Note that this proc just calls remove() with the location of the current owner as the location parameter.
  *
  * @param dism_type 	The type of dismemberment. Please only use ORGAN_DESTROYED, ORGAN_REMOVED or ORGAN_NOBLEED for this one.
  * @return 			A reference to the organ that got removed, in case there's something else we want to do with it.
 **/
/datum/organ/proc/dismember(var/dism_type)
	world << "Test: dismember() called."
	return remove(dism_type, owner.loc)

/**
  * Properly dismember an organ, setting the status of this organdatum to dism_type.
  * The organ will be deposited at the specified location.
  * Please always specify a location, or the organ could end up anywhere.
  *
  * @param dism_type 	The type of dismemberment. Please only use ORGAN_DESTROYED, ORGAN_REMOVED or ORGAN_NOBLEED for this one.
  * @param newloc 		The location the organ should end up at.
  * @return 			A reference to the organ that got removed, in case there's something else we want to do with it.
 **/
/datum/organ/proc/remove(var/dism_type, var/newloc)
	world << "Test: remove() called."
	if(exists())
		world << "Test: exists()."
		status = dism_type					//We change the organdatum status to the type of dismemberment (ORGAN_DESTROYED, ORGAN_REMOVED or ORGAN_NOBLEED).
		var/obj/item/organ/O = prepare_organitem_for_removal()	//We use the convenient preparation proc to nullify the necessary variables.
		O.loc = owner.loc					//The organitem ends up at the new location. newloc
		owner.update_body_parts()			//Obviously we need to update the icon of the owner, else they will look like they still have the organ.
		world << "Test: About to return O."
		return O							//We return the organ object in case we want some information from it.
	else
		return null							//If dismemberment failed because the limb does not exist, we return null.

/**
  * Performs the necessary operations on the variables of the organitem to prepare it for removal.
  * DO NOT USE THIS PROC UNLESS YOU ARE CERTAIN WHAT YOU ARE DOING. It doesn't update the organdata status so it can easily break everything.
  * Why doesn't BYOND have a Private declaration for procs anyway? |- Ricotez
  *
  * @return 	A reference to the organitem that was prepared. Necessary to continue operations, since it's no longer in the datum.
 **/
/datum/organ/proc/prepare_organitem_for_removal()
	world << "Test: prepare_organitem_for_removal() called."

	organitem.set_owner(null)			//We recursively nullify the owner (and with that, the organsystem) of this organ and all its suborgans.
	organitem.organdatum = null			//We also nullify the organdatum, we're no longer a part of it.

	world << "Test: about to remove suborgans from the organsystem."
	for(var/i in organitem.suborgans)	//Removing the suborgans from the organsystem
		world << "Test: [i]."
		owner.organsystem.remove_organ(i)

	var/obj/item/organ/O = organitem	//We save the organ to a separate var...
	organitem = null					//...so we can delete its reference here.
	return O							//We return the organ so we can finish whatever we were doing with it.

/datum/organ/proc/getDisplayName()
	switch(name)
		if("l_leg")		return "left leg"
		if("r_leg")		return "right leg"
		if("l_arm")		return "left arm"
		if("r_arm")		return "right arm"
		else			return name

//////////// END OF PROCS

/datum/organ/internal
	var/vital = 0	//Whether this organ is vital. Doesn't do anything right now, if it stays that way this can be removed. |- Ricotez

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