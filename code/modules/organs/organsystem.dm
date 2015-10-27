//This is the second part to organdata, but not as important as the organ datums.
//An organsystem is really just a convenient way to define different structures of organs, so you don't have to define them in every mob's constructor individually.
//Creating an organsystem is easy, just look at the examples.
//By the way, remember that these are just the datums, the "reservations" of organ spaces.
//You'll still need to fill them up with actual physical organs in the mob constructor.

//Also, please remember that this system is OPTIONAL. If you don't give a mob an organsystem, it will use the old system with list/organs and list/internal_organs.


/datum/organsystem
	var/list/organlist = new/list()

/datum/organsystem/proc/getorgan(name)
	return organlist["[name]"]

/datum/organsystem/Destroy()
	for(var/datum/organ/O in organlist)
		if(O.organitem)
			qdel(O.organitem)
		qdel(O)
	..()

/datum/organsystem/humanoid //All humanoids have the following basic structure.

	New()
		organlist["chest"]	= new/datum/organ/limb/chest/()
		organlist["head"]	= new/datum/organ/limb/head/(getorgan("chest"))
		organlist["l_arm"]	= new/datum/organ/limb/l_arm/(getorgan("chest"))
		organlist["r_arm"]	= new/datum/organ/limb/r_arm/(getorgan("chest"))
		organlist["l_leg"]	= new/datum/organ/limb/l_leg/(getorgan("chest"))
		organlist["r_leg"]	= new/datum/organ/limb/r_leg/(getorgan("chest"))
		organlist["brain"]	= new/datum/organ/brain/(getorgan("head"))

/datum/organsystem/humanoid/human //Only humans have appendices and hearts.

	New()
		..()
		organlist["appendix"]	= new/datum/organ/appendix/(getorgan("chest"))
		organlist["heart"]		= new/datum/organ/heart/(getorgan("chest"))