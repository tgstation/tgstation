/obj/organstructure //used obj for the "contents" var
	name = "organs"

	var/species = "mob" //for speaking in unknown languages purposes

	var/obj/organ/limb/arms/arms = null
	var/obj/organ/limb/legs/legs = null
	var/obj/organ/torso/torso = null
	var/obj/organ/head/head = null


	proc/GetSpeciesName()
		var/list/speciesPresent = list()

		for(var/obj/organ/organ in src) //only external organs count, since it's judging by the appearance
			if(speciesPresent[organ.species])
				speciesPresent[organ.species]++
			else
				speciesPresent[organ.species] = 1 //not sure, but I think it's not initialised before that, so can't ++

		var/list/dominantSpecies = list()

		for(var/speciesName in speciesPresent)
			if(!dominantSpecies.len)
				dominantSpecies += speciesName
			else
				if(speciesPresent[dominantSpecies[1]] == speciesPresent[speciesName])
					dominantSpecies += speciesName
				else if(speciesPresent[dominantSpecies[1]] < speciesPresent[speciesName])
					dominantSpecies = list(speciesName)

		if(!dominantSpecies.len)
			species = "mob"
		else
			species = pick(dominantSpecies)

		return species

	proc/RecalculateStructure()
		var/list/organs = GetAllContents()

		arms = locate(/obj/organ/limb/arms) in organs
		legs = locate(/obj/organ/limb/legs) in organs
		torso = locate(/obj/organ/torso) in organs
		head = locate(/obj/organ/head) in organs

		GetSpeciesName()

		return

	proc/ProcessOrgans()
		set background = 1

		var/list/organs = GetAllContents()
		for(var/name in organs)
			var/obj/organ/organ = organs[name]
			organ.ProcessOrgan()

		return

	New()
		..()
		RecalculateStructure()

/obj/organstructure/human
	name = "human organs"

	New()
		new /obj/organ/torso/human(src)
		..()

/obj/organstructure/alien
	name = "alien organs"

	New()
		new /obj/organ/torso/alien(src)
		..()

/obj/organ
	name = "organ"

	//All types
	var/organType = 0 //CYBER and SPELL go here
	var/species = "mob"
	var/obj/organstructure/rootOrganStructure = null

	New(location)
		..()

		rootOrganStructure = FindRootStructure()

	proc/FindRootStructure()
		if(istype(loc,/obj/organ))
			var/obj/organ/parent = loc
			return parent.FindRootStructure()
		else if(istype(loc,/obj/organstructure))
			return loc
		return null

	proc/ProcessOrgan()
		return

/obj/organ/torso
	name = "torso"
	var/maxHealth = 50 //right now, the mob's (only humans for now) health depends only on it. Will be fixed later

/obj/organ/torso/human
	name = "human torso"
	species = "human"
	maxHealth = 100

	New()
		..()
		new /obj/organ/limb/arms/human(src)
		new /obj/organ/limb/legs/human(src)
		new /obj/organ/head/human(src)
/obj/organ/torso/alien
	name = "alien torso"
	species = "alien"
	maxHealth = 100

	New()
		..()
		new /obj/organ/limb/arms/alien(src)
		new /obj/organ/limb/legs/alien(src)
		new /obj/organ/head/alien(src)


/obj/organ/limb
	name = "limb"

/obj/organ/limb/arms
	name = "arms"

	var/minDamage = 5 //punching damage
	var/maxDamage = 5

/obj/organ/limb/arms/alien
	name = "alien arms"
	species = "alien"
	minDamage = 5
	maxDamage = 15


/obj/organ/limb/arms/human
	name = "human arms"
	species = "human"
	minDamage = 1
	maxDamage = 9

/obj/organ/limb/legs
	name = "legs"

/obj/organ/limb/legs/human
	name = "human legs"
	species = "human"

/obj/organ/limb/legs/alien
	name = "alien legs"
	species = "alien"


/obj/organ/head
	name = "head"

/obj/organ/head/human
	name = "human head"
	species = "human"

/obj/organ/head/alien
	name = "alien head"
	species = "alien"

/obj/organ/limb/arms/alien
	name = "alien arms"
	species = "alien"
	minDamage = 5
	maxDamage = 15

/obj/organ/limb/legs/alien
	name = "alien legs"
	species = "alien"

/obj/organ/head/alien
	name = "alien head"
	species = "alien"

// ++++STUB ORGAN STRUCTURE. THIS IS THE DEFAULT STRUCTURE. USED TO PREVENT EXCEPTIONS++++
/obj/organstructure/stub
	name = "stub organs"

	New()
		new /obj/organ/torso/stub(src)
		..()

/obj/organ/torso/stub
	name = "stub torso"
	species = "stub"
	maxHealth = 100

	New()
		..()
		new /obj/organ/limb/arms/stub(src)
		new /obj/organ/limb/legs/stub(src)
		new /obj/organ/head/stub(src)

/obj/organ/limb/arms/stub
	name = "stub arms"
	species = "stub"

/obj/organ/limb/legs/stub
	name = "stub legs"
	species = "stub"

/obj/organ/head/stub
	name = "stub head"
	species = "stub"

// ++++STUB ORGAN STRUCTURE. END++++


// ++++MONKEY++++

/obj/organstructure/monkey
	name = "monkey organs"

	New()
		new /obj/organ/torso/monkey(src)
		..()

/obj/organ/torso/monkey
	name = "monkey torso"
	species = "monkey"
	maxHealth = 100

	New()
		..()
		new /obj/organ/limb/arms/monkey(src)
		new /obj/organ/limb/legs/monkey(src)
		new /obj/organ/head/monkey(src)

/obj/organ/limb/arms/monkey
	name = "monkey arms"
	species = "monkey"

/obj/organ/limb/legs/monkey
	name = "monkey legs"
	species = "monkey"

/obj/organ/head/monkey
	name = "monkey head"
	species = "monkey"


// +++++CYBORG+++++
/obj/organstructure/cyborg
	name = "cyborg organs"

	New()
		new /obj/organ/torso/cyborg(src)
		..()

/obj/organ/torso/cyborg
	name = "cyborg torso"
	species = "cyborg"
	maxHealth = 100

	New()
		..()
		new /obj/organ/limb/arms/cyborg(src)
		new /obj/organ/limb/legs/cyborg(src)
		new /obj/organ/head/cyborg(src)

/obj/organ/limb/arms/cyborg
	name = "cyborg arms"
	species = "cyborg"

/obj/organ/limb/legs/cyborg
	name = "cyborg legs"
	species = "cyborg"

/obj/organ/head/cyborg
	name = "cyborg head"
	species = "cyborg"

// +++++AI++++++
/obj/organstructure/AI
	name = "AI organs"

	New()
		new /obj/organ/torso/AI(src)
		..()

/obj/organ/torso/AI
	name = "AI torso"
	species = "AI"
	maxHealth = 100

	New()
		..()
		new /obj/organ/limb/arms/AI(src)
		new /obj/organ/limb/legs/AI(src)
		new /obj/organ/head/AI(src)

/obj/organ/limb/arms/AI
	name = "AI arms"
	species = "AI"

/obj/organ/limb/legs/AI
	name = "AI legs"
	species = "AI"

/obj/organ/head/AI
	name = "AI head"
	species = "AI"

/* New organ structure template


/obj/organstructure/template
	name = "template organs"

	New()
		new /obj/organ/torso/template(src)
		..()

/obj/organ/torso/template
	name = "template torso"
	species = "template"
	maxHealth = 100

	New()
		..()
		new /obj/organ/limb/arms/template(src)
		new /obj/organ/limb/legs/template(src)
		new /obj/organ/head/template(src)

/obj/organ/limb/arms/template
	name = "template arms"
	species = "template"

/obj/organ/limb/legs/template
	name = "template legs"
	species = "template"

/obj/organ/head/template
	name = "template head"
	species = "template"

*/