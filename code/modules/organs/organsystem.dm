//This is the second part to organdata, but not as important as the organ datums.
//An organsystem is really just a convenient way to define different structures of organs, so you don't have to define them in every mob's constructor individually.
//Creating an organsystem is easy, just look at the examples.
//By the way, remember that these are just the datums, the "reservations" of organ spaces.
//You'll still need to fill them up with actual physical organs in the mob constructor.

//Also, please remember that this system is OPTIONAL. If you don't give a mob an organsystem, it will use the old system with list/organs and list/internal_organs.


/datum/organsystem
	var/list/organlist = new/list()
	var/mob/owner = null
	var/obj/item/organ/coreitem = null		//The item that forms the core of this organsystem. Will usually be the chest.
	var/datum/organ/limb/core = null	//The data associated with the core item. Of lesser importance, given that the core item cannot be removed from an organsystem.

	New(var/mob/O)
		owner = O

/datum/organsystem/proc/getorgan(var/name)
	return organlist[name]

/**
  * Set the owner of this organsystem and all organs contained in it.
  * This will recursively go through all organs to ensure their owners are all properly set.
  * @input O: The new owner. Has to be a mob.
 **/
/datum/organsystem/proc/set_owner(var/mob/O)
	owner = O
	core.set_owner(O)

/**
  * Override the DNA of all organs in this organsystem.
  *	For example when user injects themselves with a syringe.
  * Note that this proc works iteratively rather than recursively, and changes only the DNA of the organlist.
  *	@input D: The DNA to base the overwrite on.
 **/
/datum/organsystem/proc/set_dna(var/datum/dna/D)
	for(var/limbname in organlist)
		var/datum/organ/organdata = organlist[limbname]
		organdata.set_dna(D)

//Pretty hacky, but it will have to do. This proc is only used for inserting suborgans already inside other organs, eg. brains already inside heads. Returns success
/datum/organsystem/proc/add_organ(var/datum/organ/O)
	var/obj/item/organ/P = O.parent
	var/datum/organ/newparent = organlist[P.hardpoint]
	if(newparent && newparent.exists())	//If the organlist contains the organ's parent...
		organlist[O.name] = O	//We insert the new organ datum
		O.set_owner(owner)		//We need to do this here because set_owner is called for the parent before inserting all the suborgans
		return 1
	else return 0

/datum/organsystem/proc/remove_organ(var/list_name)
/*	world << "Test: remove_organ([list_name])."
	var/obj/OR = organlist[list_name]
	world << "Test: [OR]."*/
	if(list_name)
		return organlist.Remove(list_name)
	else return null

/datum/organsystem/Destroy()
	for(var/datum/organ/O in organlist)
		if(O.organitem)
			qdel(O.organitem)
		qdel(O)
	..()

/datum/organsystem/humanoid //All humanoids have the following basic structure.

	New(var/mob/O)
		..(O)
		coreitem = new/obj/item/organ/limb/chest()
		core = new/datum/organ/limb/chest(null, coreitem) //The coredata has no parent, and its item is of course the coreitem.
		organlist["chest"]	= core
		organlist["head"]	= new/datum/organ/limb/head(coreitem, new/obj/item/organ/limb/head())
		organlist["l_arm"]	= new/datum/organ/limb/l_arm(coreitem, new/obj/item/organ/limb/l_arm())
		organlist["r_arm"]	= new/datum/organ/limb/r_arm(coreitem, new/obj/item/organ/limb/r_arm())
		organlist["l_leg"]	= new/datum/organ/limb/l_leg(coreitem, new/obj/item/organ/limb/l_leg())
		organlist["r_leg"]	= new/datum/organ/limb/r_leg(coreitem, new/obj/item/organ/limb/r_leg())

		var/datum/organ/limb/head/H = getorgan("head")
		var/obj/item/organ/limb/head/head = H.organitem
		organlist["eyes"]	= new/datum/organ/internal/eyes(head, new/obj/item/organ/internal/eyes())
		organlist["brain"]	= new/datum/organ/internal/brain(head, new/obj/item/organ/internal/brain())

		organlist["cavity"]	= new/datum/organ/cavity(coreitem, null)

/datum/organsystem/humanoid/human //Only humans have appendices, hearts, implants etc.

	New(var/mob/O)
		..(O)
		organlist["heart"]					= new/datum/organ/internal/heart(coreitem, new/obj/item/organ/internal/heart())
		organlist["nutriment_implant"] 		= new/datum/organ/internal/cyberimp/chest/nutriment(coreitem, null)
		organlist["reviver_implant"] 		= new/datum/organ/internal/cyberimp/chest/reviver(coreitem, null)

		organlist["groin"]					= new/datum/organ/abstract/groin(coreitem, new/obj/item/organ/abstract/groin())
		var/datum/organ/abstract/groin/G 	= getorgan("groin")
		var/obj/item/organ/abstract/groin 	= G.organitem
		organlist["butt"]					= new/datum/organ/butt(groin, new/obj/item/organ/butt())
		organlist["appendix"]				= new/datum/organ/internal/appendix(groin, new/obj/item/organ/internal/appendix())

		var/datum/organ/limb/head/H = getorgan("head")
		var/obj/item/organ/limb/head/head = H.organitem

		organlist["antidrop_implant"]		= new/datum/organ/internal/cyberimp/brain/anti_drop(head, null)
		organlist["antistun_implant"]		= new/datum/organ/internal/cyberimp/brain/anti_stun(head, null)