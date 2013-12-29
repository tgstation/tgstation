/obj/effect/organstructure //used obj for the "contents" var
	name = "organs"

	var/species = "mob" //for speaking in unknown languages purposes

	var/obj/effect/organ/limb/arms/arms = null
	var/obj/effect/organ/limb/legs/legs = null
	var/obj/effect/organ/torso/torso = null
	var/obj/effect/organ/head/head = null


	proc/GetSpeciesName()
		var/list/speciesPresent = list()

		for(var/obj/effect/organ/organ in src) //only external organs count, since it's judging by the appearance
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

		arms = locate(/obj/effect/organ/limb/arms) in organs
		legs = locate(/obj/effect/organ/limb/legs) in organs
		torso = locate(/obj/effect/organ/torso) in organs
		head = locate(/obj/effect/organ/head) in organs

		GetSpeciesName()

		return

	proc/ProcessOrgans()
		set background = 1

		var/list/organs = GetAllContents()
		for(var/obj/effect/organ/organ in organs)
			organ.ProcessOrgan()

		return

	New()
		..()
		RecalculateStructure()

/obj/effect/organstructure/human
	name = "human organs"

	New()
		new /obj/effect/organ/torso/human(src)
		..()

/obj/effect/organstructure/alien
	name = "alien organs"

	New()
		new /obj/effect/organ/torso/alien(src)
		..()

/obj/effect/organ
	name = "organ"

	//All types
	var/organType = 0 //CYBER and SPELL go here
	var/species = "mob"
	var/obj/effect/organstructure/rootOrganStructure = null

	New(location)
		..()

		rootOrganStructure = FindRootStructure()

	proc/FindRootStructure()
		if(istype(loc,/obj/effect/organ))
			var/obj/effect/organ/parent = loc
			return parent.FindRootStructure()
		else if(istype(loc,/obj/effect/organstructure))
			return loc
		return null

	proc/ProcessOrgan()
		return

/obj/effect/organ/torso
	name = "torso"
	var/maxHealth = 50 //right now, the mob's (only humans for now) health depends only on it. Will be fixed later

/obj/effect/organ/torso/human
	name = "human torso"
	species = "human"
	maxHealth = 100

	New()
		..()
		new /obj/effect/organ/limb/arms/human(src)
		new /obj/effect/organ/limb/legs/human(src)
		new /obj/effect/organ/head/human(src)
/obj/effect/organ/torso/alien
	name = "alien torso"
	species = "alien"
	maxHealth = 100

	New()
		..()
		new /obj/effect/organ/limb/arms/alien(src)
		new /obj/effect/organ/limb/legs/alien(src)
		new /obj/effect/organ/head/alien(src)


/obj/effect/organ/limb
	name = "limb"

/obj/effect/organ/limb/arms
	name = "arms"

	var/minDamage = 5 //punching damage
	var/maxDamage = 5

/obj/effect/organ/limb/arms/alien
	name = "alien arms"
	species = "alien"
	minDamage = 5
	maxDamage = 15


/obj/effect/organ/limb/arms/human
	name = "human arms"
	species = "human"
	minDamage = 1
	maxDamage = 9

/obj/effect/organ/limb/legs
	name = "legs"

/obj/effect/organ/limb/legs/human
	name = "human legs"
	species = "human"

/obj/effect/organ/limb/legs/alien
	name = "alien legs"
	species = "alien"


/obj/effect/organ/head
	name = "head"

/obj/effect/organ/head/human
	name = "human head"
	species = "human"

/obj/effect/organ/head/alien
	name = "alien head"
	species = "alien"

/obj/effect/organ/limb/arms/alien
	name = "alien arms"
	species = "alien"
	minDamage = 5
	maxDamage = 15

/obj/effect/organ/limb/legs/alien
	name = "alien legs"
	species = "alien"

/obj/effect/organ/head/alien
	name = "alien head"
	species = "alien"

// ++++STUB ORGAN STRUCTURE. THIS IS THE DEFAULT STRUCTURE. USED TO PREVENT EXCEPTIONS++++
/obj/effect/organstructure/stub
	name = "stub organs"

	New()
		new /obj/effect/organ/torso/stub(src)
		..()

/obj/effect/organ/torso/stub
	name = "stub torso"
	species = "stub"
	maxHealth = 100

	New()
		..()
		new /obj/effect/organ/limb/arms/stub(src)
		new /obj/effect/organ/limb/legs/stub(src)
		new /obj/effect/organ/head/stub(src)

/obj/effect/organ/limb/arms/stub
	name = "stub arms"
	species = "stub"

/obj/effect/organ/limb/legs/stub
	name = "stub legs"
	species = "stub"

/obj/effect/organ/head/stub
	name = "stub head"
	species = "stub"

// ++++STUB ORGAN STRUCTURE. END++++


// ++++MONKEY++++

/obj/effect/organstructure/monkey
	name = "monkey organs"

	New()
		new /obj/effect/organ/torso/monkey(src)
		..()

/obj/effect/organ/torso/monkey
	name = "monkey torso"
	species = "monkey"
	maxHealth = 100

	New()
		..()
		new /obj/effect/organ/limb/arms/monkey(src)
		new /obj/effect/organ/limb/legs/monkey(src)
		new /obj/effect/organ/head/monkey(src)

/obj/effect/organ/limb/arms/monkey
	name = "monkey arms"
	species = "monkey"

/obj/effect/organ/limb/legs/monkey
	name = "monkey legs"
	species = "monkey"

/obj/effect/organ/head/monkey
	name = "monkey head"
	species = "monkey"


// +++++CYBORG+++++
/obj/effect/organstructure/cyborg
	name = "cyborg organs"

	New()
		new /obj/effect/organ/torso/cyborg(src)
		..()

/obj/effect/organ/torso/cyborg
	name = "cyborg torso"
	species = "cyborg"
	maxHealth = 100

	New()
		..()
		new /obj/effect/organ/limb/arms/cyborg(src)
		new /obj/effect/organ/limb/legs/cyborg(src)
		new /obj/effect/organ/head/cyborg(src)

/obj/effect/organ/limb/arms/cyborg
	name = "cyborg arms"
	species = "cyborg"

/obj/effect/organ/limb/legs/cyborg
	name = "cyborg legs"
	species = "cyborg"

/obj/effect/organ/head/cyborg
	name = "cyborg head"
	species = "cyborg"

// +++++AI++++++
/obj/effect/organstructure/AI
	name = "AI organs"

	New()
		new /obj/effect/organ/torso/AI(src)
		..()

/obj/effect/organ/torso/AI
	name = "AI torso"
	species = "AI"
	maxHealth = 100

	New()
		..()
		new /obj/effect/organ/limb/arms/AI(src)
		new /obj/effect/organ/limb/legs/AI(src)
		new /obj/effect/organ/head/AI(src)

/obj/effect/organ/limb/arms/AI
	name = "AI arms"
	species = "AI"

/obj/effect/organ/limb/legs/AI
	name = "AI legs"
	species = "AI"

/obj/effect/organ/head/AI
	name = "AI head"
	species = "AI"

/* New organ structure template


/obj/effect/organstructure/template
	name = "template organs"

	New()
		new /obj/effect/organ/torso/template(src)
		..()

/obj/effect/organ/torso/template
	name = "template torso"
	species = "template"
	maxHealth = 100

	New()
		..()
		new /obj/effect/organ/limb/arms/template(src)
		new /obj/effect/organ/limb/legs/template(src)
		new /obj/effect/organ/head/template(src)

/obj/effect/organ/limb/arms/template
	name = "template arms"
	species = "template"

/obj/effect/organ/limb/legs/template
	name = "template legs"
	species = "template"

/obj/effect/organ/head/template
	name = "template head"
	species = "template"

*/