//TODO: Move cyber organs active/inactive stats to vars.

//flags for organType
#define CYBER 1
#define SPELL 2

/obj/effects/organstructure //used obj for the "contents" var
	name = "organs"

	var/obj/item/weapon/cell/mainPowerCell = null //for ease of refernce for installed c. implants
	var/species = "mob" //for speaking in unknown languages purposes

	var/obj/effects/organ/limb/arms/arms = null
	var/obj/effects/organ/limb/legs/legs = null
	var/obj/effects/organ/chest/chest = null

	proc/FindMainPowercell()
		if(chest) //priority goes to chest implant, if there is one
			if((chest.organType & CYBER) && chest.canExportPower && chest.cell)
				mainPowerCell = chest.cell
				return
		var/list/organs = GetAllContents()
		for(var/obj/effects/organ/otherOrgan in organs) //otherwise, maybe some other organ fits the criteria?
			if((otherOrgan.organType & CYBER) && otherOrgan.canExportPower && otherOrgan.cell)
				mainPowerCell = otherOrgan:cell
				return
		mainPowerCell = null //otherwise, seems there's no main cell
		return

	proc/GetSpeciesName()
		var/list/speciesPresent = list()

		for(var/obj/effects/organ/organ in src) //only external organs count, since it's judging by the appearance
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

		return

	proc/RecalculateStructure()
		var/list/organs = GetAllContents()

		arms = locate(/obj/effects/organ/limb/arms) in organs
		legs = locate(/obj/effects/organ/limb/legs) in organs
		chest = locate(/obj/effects/organ/chest) in organs

		GetSpeciesName()
		FindMainPowercell()

		return

	proc/ProcessOrgans()
		set background = 1

		var/list/organs = GetAllContents()
		for(var/obj/effects/organ/organ in organs)
			organ.ProcessOrgan()

		return

	New()
		..()
		RecalculateStructure()

/obj/effects/organstructure/human
	name = "human organs"

	New()
		//new /obj/effects/organ/limb/arms/human(src)
		//new /obj/effects/organ/limb/legs/human(src)
		new /obj/effects/organ/chest/human(src)
		..()

/obj/effects/organstructure/cyber
	name = "cyborg organs"

	New()
		//new /obj/effects/organ/limb/arms/cyber(src)
		//new /obj/effects/organ/limb/legs/cyber(src)
		new /obj/effects/organ/chest/cyber(src)
		..()

/obj/effects/organ
	name = "organ"

	//All types
	var/organType = 0 //CYBER and SPELL go here
	var/species = "mob"
	var/obj/effects/organstructure/rootOrganStructure = null

	New(location)
		..()

		rootOrganStructure = FindRootStructure()

	proc/FindRootStructure()
		if(istype(loc,/obj/effects/organ))
			var/obj/effects/organ/parent = loc
			return parent.FindRootStructure()
		else if(istype(loc,/obj/effects/organstructure))
			return loc
		return null

	proc/ProcessOrgan()
		set background = 1

		if(organType & CYBER)
			var/hasPower = DrainPower()
			if(!hasPower && active)
				Deactivate()
			else if(hasPower && !active)
				Activate()

	//CYBORG type
	var/obj/item/weapon/cell/cell = null
	var/canExportPower = 0 //only comes in play if it has a cell
	var/active = 0
	var/powerDrainPerTick = 0

	proc/DrainPower()
		set background = 1

		if(!powerDrainPerTick)
			return 1
		if(cell)
			if(cell.charge >= powerDrainPerTick)
				cell.charge -= powerDrainPerTick
				return 1
		if(rootOrganStructure.mainPowerCell)
			if(rootOrganStructure.mainPowerCell.charge >= powerDrainPerTick)
				rootOrganStructure.mainPowerCell.charge -= powerDrainPerTick
				return 1
		return 0

	proc/Activate() //depends on the organ, involves setting active to 1 and changing the organ's vars to reflect its "activated" state
		rootOrganStructure.loc << "\blue Your [name] powers up!"
		active = 1
		return

	proc/Deactivate() //depends on the organ, involves setting active to 0 and changing the organ's vars to reflect its "deactivated" state
		rootOrganStructure.loc << "\red Your [name] powers down."
		active = 0
		return

/obj/effects/organ/limb
	name = "limb"

/obj/effects/organ/limb/arms
	name = "arms"

	var/minDamage = 5 //punching damage
	var/maxDamage = 5
//	var/strangleDelay = 1 //The code is a bit too complicated for that right now

/obj/effects/organ/limb/arms/human
	name = "human arms"
	species = "human"
	minDamage = 1
	maxDamage = 9

/obj/effects/organ/limb/arms/cyber
	name = "cyborg arms"
	species = "cyborg"
	organType = CYBER
	powerDrainPerTick = 5

	Activate()
		..()
		minDamage = 3
		maxDamage = 14

	Deactivate()
		..()
		minDamage = 0
		maxDamage = 3


/obj/effects/organ/limb/legs
	name = "legs"

	var/moveRunDelay = 1 //not sure about how that works
	var/moveWalkDelay = 7
	//var/knockdownResist = 0

/obj/effects/organ/limb/legs/human
	name = "human legs"
	species = "human"

/obj/effects/organ/limb/legs/cyber
	name = "cyborg legs"
	species = "cyborg"
	organType = CYBER
	powerDrainPerTick = 5

	Activate()
		..()
		moveRunDelay = 0
		moveWalkDelay = 3

	Deactivate()
		..()
		moveRunDelay = 2
		moveWalkDelay = 10


/obj/effects/organ/chest
	name = "chest"
	var/maxHealth = 50 //right now, the mob's (only humans for now) health depends only on it. Will be fixed later

/obj/effects/organ/chest/human
	name = "human chest"
	species = "human"
	maxHealth = 100

	New()
		..()
		new /obj/effects/organ/limb/arms/human(src)
		new /obj/effects/organ/limb/legs/human(src)

/obj/effects/organ/chest/cyber
	name = "cyborg chest"
	species = "cyborg"
	organType = CYBER
	canExportPower = 1
	maxHealth = 150

	New()
		..()
		cell = new /obj/item/weapon/cell/high(src)
		cell.charge = cell.maxcharge
		new /obj/effects/organ/limb/arms/cyber(src)
		new /obj/effects/organ/limb/legs/cyber(src)

	Activate()
		..()
		canExportPower = 1
		maxHealth = 150
		if(rootOrganStructure.loc && istype(rootOrganStructure.loc,/mob/living))
			var/mob/living/holder = rootOrganStructure.loc
			holder.updatehealth()

	Deactivate()
		..()
		canExportPower = 0
		maxHealth = 120
		if(rootOrganStructure.loc && istype(rootOrganStructure.loc,/mob/living))
			var/mob/living/holder = rootOrganStructure.loc
			holder.updatehealth()