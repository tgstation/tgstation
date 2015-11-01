/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'
	var/hardpoint = "error"	//The name used to save this organ to associative lists. The default is error, to make it easier to spot when an organ does not set this value properly.
	var/mob/living/carbon/owner = null
	var/status = 0
	var/organtype = ORGAN_ORGANIC
	var/status_flags	//Any special status flags set for this organ. Different from var/status in that status is used exclusively for organ-related statuses.
	var/datum/organ/organdatum	//The organdatum this organ is associated with.
	var/list/suborgans = list()	//A list of organ hardpoints (Your head contains your eyesockets, skull etc.)
	var/datum/dna/dna = null //The DNA stored in this organ.



//////////// START OF PROCS

//The proc for inserting organs. Inserts the organ and adds all its suborgans to the organsystem
/obj/item/organ/proc/Insert(mob/living/carbon/M)
	world << "Called Insert([M])"
	if(!iscarbon(M) || owner == M)
		return 0

	var/datum/organ/OR = M.getorgan(hardpoint)
	world << "Hardpoint is [OR]"
	if(OR && !OR.exists())
		world << "[OR] [OR.exists()]"
		if(OR.set_organitem(src))
			world << "Organitem set!"
			for (var/i in suborgans)
				M.add_organ(suborgans[i])
		else return 0
	else return 0
	return 1

/**
  * Overwrite the DNA stored in this organ.
  * Uses copy_dna to accomplishes this, so nothing will happen to the original DNA.
  * Note that we do not modify the DNA of the suborgans in this proc.
  * @input D: The target DNA to base the overwrite on.
 **/
/obj/item/organ/proc/set_dna(var/datum/dna/D)
	if(!dna)
		dna = new /datum/dna(owner)
		dna.holder_organ = src
	dna.copy_dna(D)

/**
  * Set the owner of this organ and call set_owner on all of its suborgans.
  * Also updates the organsystem.
  * This proc is recursive because if the owner of an organ changes, it also changes for all suborgans.
  * (Cutting off a head also cuts off the brain.)
  *
  * @param O	The new organ owner. Can be null if the organ has no owner.
 **/
/obj/item/organ/proc/set_owner(var/mob/O)
	owner = O
	for(var/i in suborgans)
		var/datum/organ/OR = suborgans[i]
		OR.set_owner(O)

/**
  * Adds a suborgan to the organdatum that corresponds with its hardpoint, but only if there actually exists an organdatum for that hardpoint.
  *
  * @param O	The new organ to be added.
  * @return		Whether the organ was succesfully added. It won't be if the datum doens't exist, or already contains an organ.
 **/
/obj/item/organ/proc/add_suborgan(var/datum/organ/O)
	if(O && !suborgans[O.name])
		suborgans[O.name] = O
		return 1
	return 0

/obj/item/organ/proc/remove_suborgan(var/name, var/special = 1)	//Usually special=0 affects the owner
	var/datum/organ/O = suborgans[name]
	if(O.exists())
		var/obj/item/organ/OI = O.organitem
		if(O.remove(ORGAN_REMOVED, loc, special))
			return OI
	return null

/obj/item/organ/proc/set_suborgan(var/obj/item/organ/O)
	var/datum/organ/OD = suborgans[O.hardpoint]
	if(!OD.exists())
		OD.set_organitem(O)
		O.loc = src
		return 1
	else return null

//returns suborgans[name].organitem
/obj/item/organ/proc/getsuborgan(var/name)
	var/datum/organ/SO = suborgans[name]
	return SO.organitem

/obj/item/organ/proc/create_suborgan_slots()
	return 0