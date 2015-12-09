//This is the second part to organdata, but not as important as the organ datums.
//An organsystem is really just a convenient way to define different structures of organs, so you don't have to define them in every mob's constructor individually.
//Creating an organsystem is easy, just look at the examples.
//By the way, remember that these are just the datums, the "reservations" of organ spaces.
//You'll still need to fill them up with actual physical organs in the mob constructor.

/datum/organsystem
	var/list/organlist = new/list()
	var/mob/owner = null
	var/obj/item/organ/coreitem = null		//The item that forms the core of this organsystem. Will usually be the chest.
	var/datum/organ/limb/core = null	//The data associated with the core item. Of lesser importance, given that the core item cannot be removed from an organsystem.

	New(var/mob/O)
		owner = O

/datum/organsystem/proc/get_organ(var/name)
	return organlist[name]

/**
  * Set the owner of this organsystem and all organs contained in it.
  * This will recursively go through all organs to ensure their owners are all properly set.
  * @input O: The new owner. Has to be a mob.
 **/
/datum/organsystem/proc/set_owner(var/mob/O)
	owner = O
	if(core)
		core.set_owner(O)
	else
		for (var/organname in organlist)
			var/datum/organ/OR = organlist[organname]
			OR.set_owner(O)

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
	if(list_name)
		var/datum/organ/OR = get_organ(list_name)
		var/obj/item/organ/OI = OR.organitem
		if(isorgan(OI))
			for(var/i in OI.suborgans)
				remove_organ(i)	//RECURSION
		return organlist.Remove(list_name)
	else return null

/datum/organsystem/Destroy()
	for(var/datum/organ/O in organlist)
		if(O.organitem)
			qdel(O.organitem)
		qdel(O)
	..()

/datum/organsystem/humanoid //All humanoids have the following basic structure. They also have brains but monkey/human and alium brains are different

	New(var/mob/O)
		..(O)
		coreitem = new/obj/item/organ/limb/chest()
		core = new/datum/organ/limb/chest(null, coreitem) //The coredata has no parent, and its item is of course the coreitem.
		organlist["chest"]	= core
		organlist["head"]	= new/datum/organ/limb/head(coreitem, new/obj/item/organ/limb/head())
		organlist["l_arm"]	= new/datum/organ/limb/arm/l_arm(coreitem, new/obj/item/organ/limb/arm/l_arm())
		organlist["r_arm"]	= new/datum/organ/limb/arm/r_arm(coreitem, new/obj/item/organ/limb/arm/r_arm())
		organlist["l_leg"]	= new/datum/organ/limb/leg/l_leg(coreitem, new/obj/item/organ/limb/leg/l_leg())
		organlist["r_leg"]	= new/datum/organ/limb/leg/r_leg(coreitem, new/obj/item/organ/limb/leg/r_leg())

		organlist["groin"]	= new/datum/organ/abstract/groin(coreitem, new/obj/item/organ/abstract/groin())

		var/datum/organ/limb/head/HE = organlist["head"]
		var/obj/item/organ/limb/head/head = HE.organitem
		organlist["mouth"]	= new/datum/organ/abstract/mouth(head, new/obj/item/organ/abstract/mouth())

		organlist["cavity"]	= new/datum/organ/cavity(coreitem, null)

/datum/organsystem/humanoid/monkey	//And also human. Kinda want to make monkey organs have defects to prevent easy transplants

	New(var/mob/O)
		..(O)

		organlist["heart"]					= new/datum/organ/internal/heart(coreitem, new/obj/item/organ/internal/heart())
		organlist["cyberimp_chest"] 		= new/datum/organ/internal/cyberimp/chest(coreitem, null)

		var/datum/organ/limb/head/H = get_organ("head")
		var/obj/item/organ/limb/head/head = H.organitem
		organlist["eyes"]	= new/datum/organ/internal/eyes(head, new/obj/item/organ/internal/eyes())
		organlist["brain"]	= new/datum/organ/internal/brain(head, new/obj/item/organ/internal/brain())
		organlist["cyberimp_brain"]		= new/datum/organ/internal/cyberimp/brain(head, null)

		var/datum/organ/abstract/groin/G = organlist["groin"]
		var/obj/item/organ/abstract/groin 	= G.organitem
		organlist["butt"]					= new/datum/organ/butt(groin, new/obj/item/organ/butt())
		organlist["appendix"]				= new/datum/organ/internal/appendix(groin, new/obj/item/organ/internal/appendix())

		organlist["egg"]	= new/datum/organ/internal/body_egg/(coreitem, null)

		var/datum/organ/abstract/M = get_organ("mouth")
		var/obj/item/organ/abstract/mouth/mouth = M.organitem
		organlist["hivenode"]		= new/datum/organ/internal/alien/hivenode(head, null)
		organlist["plasmavessel"]	= new/datum/organ/internal/alien/plasmavessel(coreitem, null)
		organlist["resinspinner"]		= new/datum/organ/internal/alien/resinspinner(mouth, null)
		organlist["acidgland"]			= new/datum/organ/internal/alien/acidgland(mouth, null)
		organlist["toxingland"]			= new/datum/organ/internal/alien/toxingland(mouth, null)
		organlist["eggsac"]					= new/datum/organ/internal/alien/eggsac(groin, null)

/datum/organsystem/alienlarva/	//Ayy lmao

	New(var/mob/O)
		..(O)

		organlist["eyes"]			= new/datum/organ/internal/eyes(null, new/obj/item/organ/internal/eyes/alien())
		organlist["brain"]			= new/datum/organ/internal/brain(null, new/obj/item/organ/internal/brain/alien())
		organlist["hivenode"]		= new/datum/organ/internal/alien/hivenode(null, new/obj/item/organ/internal/alien/hivenode())
		organlist["plasmavessel"]	= new/datum/organ/internal/alien/plasmavessel(null, new/obj/item/organ/internal/alien/plasmavessel/small/tiny())

/datum/organsystem/humanoid/alien/

	New(var/mob/O, var/datum/organsystem/alienlarva/oldorgans = null)
		..(O)
		var/datum/organ/limb/head/H = get_organ("head")
		var/obj/item/organ/limb/head/head = H.organitem
		if(oldorgans)
			var/datum/organ/internal/eyes/E = oldorgans.get_organ("eyes")
			organlist["eyes"]			= new/datum/organ/internal/eyes(head, E.organitem)	//Regular old eyes, for now
			var/datum/organ/internal/brain/B = oldorgans.get_organ("brain")
			organlist["brain"]			= new/datum/organ/internal/brain(head, B.organitem)
			var/datum/organ/internal/alien/hivenode/HI = oldorgans.get_organ("hivenode")
			organlist["hivenode"]		= new/datum/organ/internal/alien/hivenode(head, HI.organitem)
		else
			organlist["eyes"]			= new/datum/organ/internal/eyes(head, new/obj/item/organ/internal/eyes/alien())	//Regular old eyes, for now
			organlist["brain"]			= new/datum/organ/internal/brain(head, new/obj/item/organ/internal/brain/alien())
			organlist["hivenode"]		= new/datum/organ/internal/alien/hivenode(head, new/obj/item/organ/internal/alien/hivenode())

/datum/organsystem/humanoid/alien/drone

	New(var/mob/O, var/datum/organsystem/alienlarva/oldorgans = null)
		..(O, oldorgans)
		organlist["plasmavessel"]		= new/datum/organ/internal/alien/plasmavessel(coreitem, new/obj/item/organ/internal/alien/plasmavessel/large())

		var/datum/organ/abstract/M = get_organ("mouth")
		var/obj/item/organ/abstract/mouth/mouth = M.organitem
		organlist["resinspinner"]		= new/datum/organ/internal/alien/resinspinner(mouth, new/obj/item/organ/internal/alien/resinspinner())
		organlist["acidgland"]			= new/datum/organ/internal/alien/acidgland(mouth, new/obj/item/organ/internal/alien/acid())

/datum/organsystem/humanoid/alien/hunter

	New(var/mob/O, var/datum/organsystem/alienlarva/oldorgans = null)
		..(O, oldorgans)
		organlist["plasmavessel"]		= new/datum/organ/internal/alien/plasmavessel(coreitem, new/obj/item/organ/internal/alien/plasmavessel/small())

/datum/organsystem/humanoid/alien/sentinel

	New(var/mob/O, var/datum/organsystem/alienlarva/oldorgans = null)
		..(O, oldorgans)
		organlist["plasmavessel"]		= new/datum/organ/internal/alien/plasmavessel(coreitem, new/obj/item/organ/internal/alien/plasmavessel())

		var/datum/organ/abstract/M = get_organ("mouth")
		var/obj/item/organ/abstract/mouth/mouth = M.organitem
		organlist["acidgland"]			= new/datum/organ/internal/alien/acidgland(mouth, new/obj/item/organ/internal/alien/acid())
		organlist["toxingland"]			= new/datum/organ/internal/alien/toxingland(mouth, new/obj/item/organ/internal/alien/neurotoxin())

/datum/organsystem/humanoid/alien/queen

	New(var/mob/O, var/datum/organsystem/humanoid/alien/drone/oldorgans = null)
		..(O, oldorgans)

		organlist["plasmavessel"] = new/datum/organ/internal/alien/plasmavessel(coreitem, new/obj/item/organ/internal/alien/plasmavessel/large/queen())

		var/datum/organ/abstract/M = get_organ("mouth")
		var/obj/item/organ/abstract/mouth/mouth = M.organitem
		if(oldorgans)
			var/datum/organ/internal/alien/resinspinner/RE = oldorgans.get_organ("resinspinner")
			organlist["resinspinner"]		= new/datum/organ/internal/alien/resinspinner(mouth, RE.organitem)
			var/datum/organ/internal/alien/acidgland/AC = oldorgans.get_organ("acidgland")
			organlist["acidgland"]			= new/datum/organ/internal/alien/acidgland(mouth, AC.organitem)
		else
			organlist["resinspinner"]		= new/datum/organ/internal/alien/resinspinner(mouth, new/obj/item/organ/internal/alien/resinspinner())
			organlist["acidgland"]			= new/datum/organ/internal/alien/acidgland(mouth, new/obj/item/organ/internal/alien/acid())

		organlist["toxingland"]				= new/datum/organ/internal/alien/toxingland(mouth, new/obj/item/organ/internal/alien/neurotoxin())

		var/datum/organ/abstract/groin/G 	= organlist["groin"]
		var/obj/item/organ/abstract/groin 	= G.organitem
		organlist["eggsac"]					= new/datum/organ/internal/alien/eggsac(groin, new/obj/item/organ/internal/alien/eggsac())