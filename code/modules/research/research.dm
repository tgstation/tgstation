/*
General Explination:
The research datum is the "folder" where all the research information is stored in a R&D console. It's also a holder for all the
various procs used to manipulate it. It has four variables and seven procs:

Variables:
- possible_tech is a list of all the /datum/tech that can potentially be researched by the player. The RefreshResearch() proc
(explained later) only goes through those when refreshing what you know. Generally, possible_tech contains ALL of the existing tech
but it is possible to add tech to the game that DON'T start in it (example: Xeno tech). Generally speaking, you don't want to mess
with these since they should be the default version of the datums. They're actually stored in a list rather then using typesof to
refer to them since it makes it a bit easier to search through them for specific information.
- know_tech is the companion list to possible_tech. It's the tech you can actually research and improve. Until it's added to this
list, it can't be improved. All the tech in this list are visible to the player.
- possible_designs is functionally identical to possbile_tech except it's for /datum/design.
- known_designs is functionally identical to known_tech except it's for /datum/design

Procs:
- TechHasReqs: Used by other procs (specifically RefreshResearch) to see whether all of a tech's requirements are currently in
known_tech and at a high enough level.
- DesignHasReqs: Same as TechHasReqs but for /datum/design and known_design.
- AddTech2Known: Adds a /datum/tech to known_tech. It checks to see whether it already has that tech (if so, it just replaces it). If
it doesn't have it, it adds it. Note: It does NOT check possible_tech at all. So if you want to add something strange to it (like
a player made tech?) you can.
- AddDesign2Known: Same as AddTech2Known except for /datum/design and known_designs.
- RefreshResearch: This is the workhorse of the R&D system. It updates the /datum/research holder and adds any unlocked tech paths
and designs you have reached the requirements for. It only checks through possible_tech and possible_designs, however, so it won't
accidentally add "secret" tech to it.
- UpdateTech is used as part of the actual researching process. It takes an ID and finds techs with that same ID in known_tech. When
it finds it, it checks to see whether it can improve it at all. If the known_tech's level is less then or equal to
the inputted level, it increases the known tech's level to the inputted level -1 or know tech's level +1 (whichever is higher).

The tech datums are the actual "tech trees" that you improve through researching. Each one has five variables:
- Name:		Pretty obvious. This is often viewable to the players.
- Desc:		Pretty obvious. Also player viewable.
- ID:		This is the unique ID of the tech that is used by the various procs to find and/or maniuplate it.
- Level:	This is the current level of the tech. All techs start at 1 and have a max of 20. Devices and some techs require a certain
level in specific techs before you can produce them.
- Req_tech:	This is a list of the techs required to unlock this tech path. If left blank, it'll automatically be loaded into the
research holder datum.

*/
/***************************************************************
**						Master Types						  **
**	Includes all the helper procs and basic tech processing.  **
***************************************************************/

/datum/research								//Holder for all the existing, archived, and known tech. Individual to console.

											//Datum/tech go here.
	var/list/possible_tech = list()			//List of all tech in the game that players have access to (barring special events).
	var/list/known_tech = list()			//List of locally known tech.
	var/list/possible_designs = list()		//List of all designs.
	var/list/known_designs = list()			//List of available designs.

/datum/research/New()		//Insert techs into possible_tech here. Known_tech automatically updated.
	for(var/T in subtypesof(/datum/tech))
		possible_tech += new T(src)
	for(var/D in subtypesof(/datum/design))
		possible_designs += new D(src)
	RefreshResearch()

//Checks to see if tech has all the required pre-reqs.
//Input: datum/tech; Output: 0/1 (false/true)
/datum/research/proc/TechHasReqs(datum/tech/T)
	if(T.req_tech.len == 0)
		return TRUE
	for(var/req in T.req_tech)
		var/datum/tech/known = known_tech[req]
		if(!known || known.level < T.req_tech[req])
			return FALSE
	return TRUE

//Checks to see if design has all the required pre-reqs.
//Input: datum/design; Output: 0/1 (false/true)
/datum/research/proc/DesignHasReqs(datum/design/D)//Heavily optimized -Sieve
	if(D.req_tech.len == 0)
		return TRUE
	for(var/req in D.req_tech)
		var/datum/tech/known = known_tech[req]
		if(!known || known.level < D.req_tech[req])
			return FALSE
	return TRUE

//Adds a tech to known_tech list. Checks to make sure there aren't duplicates and updates existing tech's levels if needed.
//Input: datum/tech; Output: Null
/datum/research/proc/AddTech2Known(datum/tech/T)
	if(!T)
		return
	if(known_tech[T.id])
		var/datum/tech/known = known_tech[T.id]
		if(T.level > known.level)
			known.level = T.level
		return
	known_tech[T.id] = T.copy()

/datum/research/proc/AddDesign2Known(datum/design/D)
	if(known_designs[D.id])
		return
	known_designs[D.id] = D

//Refreshes known_tech and known_designs list.
//Input/Output: n/a
/datum/research/proc/RefreshResearch()
	for(var/datum/tech/PT in possible_tech)
		if(TechHasReqs(PT))
			AddTech2Known(PT)

	for(var/datum/design/PD in possible_designs)
		if(DesignHasReqs(PD))
			AddDesign2Known(PD)

	for(var/v in known_tech)
		var/datum/tech/T = known_tech[v]
		T.level = Clamp(T.level, 0, 20)
	return

//Refreshes the levels of a given tech.
//Input: Tech's ID and Level; Output: null
/datum/research/proc/UpdateTech(ID, level)
	var/datum/tech/KT = known_tech[ID]
	if(KT && KT.level <= level)
		KT.level = max(KT.level + 1, level)

//Checks if the origin level can raise current tech levels
//Input: Tech's ID and Level; Output: TRUE for yes, FALSE for no
/datum/research/proc/IsTechHigher(ID, level)
	var/datum/tech/KT = known_tech[ID]
	if(KT)
		if(KT.level <= level)
			return TRUE
		else
			return FALSE

/datum/research/proc/FindDesignByID(id)
	return known_designs[id]


//Autolathe files
/datum/research/autolathe/New()
	for(var/T in (subtypesof(/datum/tech)))
		possible_tech += new T(src)
	for(var/path in subtypesof(/datum/design))
		var/datum/design/D = new path(src)
		possible_designs += D
		if((D.build_type & AUTOLATHE) && ("initial" in D.category))  //autolathe starts without hacked designs
			AddDesign2Known(D)

//Limb Grower files
/datum/research/limbgrower/New()
	for(var/T in (subtypesof(/datum/tech)))
		possible_tech += new T(src)
	for(var/path in subtypesof(/datum/design))
		var/datum/design/D = new path(src)
		possible_designs += D
		if((D.build_type & LIMBGROWER) && ("initial" in D.category))
			AddDesign2Known(D)

/datum/research/autolathe/AddDesign2Known(datum/design/D)
	if(!(D.build_type & AUTOLATHE))
		return
	..()

//Biogenerator files
/datum/research/biogenerator/New()
	for(var/T in (subtypesof(/datum/tech)))
		possible_tech += new T(src)
	for(var/path in subtypesof(/datum/design))
		var/datum/design/D = new path(src)
		possible_designs += D
		if((D.build_type & BIOGENERATOR) && ("initial" in D.category))
			AddDesign2Known(D)

/datum/research/biogenerator/AddDesign2Known(datum/design/D)
	if(!(D.build_type & BIOGENERATOR))
		return
	..()


/***************************************************************
**						Technology Datums					  **
**	Includes all the various technoliges and what they make.  **
***************************************************************/

/datum/tech	//Datum of individual technologies.
	var/name = "name"					//Name of the technology.
	var/desc = "description"			//General description of what it does and what it makes.
	var/id = "id"						//An easily referenced ID. Must be alphanumeric, lower-case, and no symbols.
	var/level = 1						//A simple number scale of the research level. Level 0 = Secret tech.
	var/rare = 1						//How much CentCom wants to get that tech. Used in supply shuttle tech cost calculation.
	var/list/req_tech = list()			//List of ids associated values of techs required to research this tech. "id" = #


//Trunk Technologies (don't require any other techs and you start knowning them).

/datum/tech/materials
	name = "Materials Research"
	desc = "Development of new and improved materials."
	id = "materials"

/datum/tech/engineering
	name = "Engineering Research"
	desc = "Development of new and improved engineering parts and tools."
	id = "engineering"

/datum/tech/plasmatech
	name = "Plasma Research"
	desc = "Research into the mysterious substance colloqually known as \"plasma\"."
	id = "plasmatech"
	rare = 3

/datum/tech/powerstorage
	name = "Power Manipulation Technology"
	desc = "The various technologies behind the storage and generation of electicity."
	id = "powerstorage"

/datum/tech/bluespace
	name = "\"Blue-space\" Research"
	desc = "Research into the sub-reality known as \"blue-space\"."
	id = "bluespace"
	rare = 2

/datum/tech/biotech
	name = "Biological Technology"
	desc = "Research into the deeper mysteries of life and organic substances."
	id = "biotech"

/datum/tech/combat
	name = "Combat Systems Research"
	desc = "The development of offensive and defensive systems."
	id = "combat"

/datum/tech/magnets
	name = "Electromagnetic Spectrum Research"
	desc = "Research into the electromagnetic spectrum. No clue how they actually work, though."
	id = "magnets"

/datum/tech/programming
	name = "Data Theory Research"
	desc = "The development of new computer and artificial intelligence and data storage systems."
	id = "programming"

/datum/tech/syndicate
	name = "Illegal Technologies Research"
	desc = "The study of technologies that violate Nanotrassen regulations."
	id = "syndicate"
	rare = 4


//Secret Technologies (hidden by default, require rare items to reveal)

/datum/tech/abductor
	name = "Alien Technologies Research"
	desc = "The study of technologies used by the advanced alien race known as Abductors."
	id = "abductor"
	rare = 5
	level = 0

/datum/tech/arcane
	name = "Arcane Research"
	desc = "When sufficiently analyzed, any magic becomes indistinguishable from technology."
	id = "arcane"
	rare = 5
	level = 0

/*
//Branch Techs
/datum/tech/explosives
	name = "Explosives Research"
	desc = "The creation and application of explosive materials."
	id = "explosives"
	req_tech = list("materials" = 3)

/datum/tech/generators
	name = "Power Generation Technology"
	desc = "Research into more powerful and more reliable sources."
	id = "generators"
	req_tech = list("powerstorage" = 2)

/datum/tech/robotics
	name = "Robotics Technology"
	desc = "The development of advanced automated, autonomous machines."
	id = "robotics"
	req_tech = list("materials" = 3, "programming" = 3)
*/


/datum/tech/proc/getCost(var/current_level = null)
	// Calculates tech disk's supply points sell cost
	if(!current_level)
		current_level = initial(level)

	if(current_level >= level)
		return 0

	var/cost = 0
	for(var/i=current_level+1, i<=level, i++)
		if(i == initial(level))
			continue
		cost += i*rare

	return cost

/datum/tech/proc/copy()
	var/datum/tech/T = new type()
	T.level = level
	return T

/obj/item/weapon/disk/tech_disk
	name = "technology disk"
	desc = "A disk for storing technology data for further research."
	icon_state = "datadisk0"
	materials = list(MAT_METAL=300, MAT_GLASS=100)
	var/list/tech_stored = list()
	var/max_tech_stored = 1

/obj/item/weapon/disk/tech_disk/New()
	..()
	src.pixel_x = rand(-5, 5)
	src.pixel_y = rand(-5, 5)
	for(var/i in 1 to max_tech_stored)
		tech_stored += null


/obj/item/weapon/disk/tech_disk/adv
	name = "advanced technology disk"
	desc = "A disk for storing technology data for further research. This one has extra storage space."
	materials = list(MAT_METAL=300, MAT_GLASS=100, MAT_SILVER=50)
	max_tech_stored = 5

/obj/item/weapon/disk/tech_disk/super_adv
	name = "quantum technology disk"
	desc = "A disk for storing technology data for further research. This one has extremely large storage space."
	materials = list(MAT_METAL=300, MAT_GLASS=100, MAT_SILVER=100, MAT_GOLD=100)
	max_tech_stored = 10

/obj/item/weapon/disk/tech_disk/debug
	name = "centcomm technology disk"
	desc = "A debug item for research"
	materials = list()
	max_tech_stored = 0

/obj/item/weapon/disk/tech_disk/debug/New()
	..()
	var/list/techs = subtypesof(/datum/tech)
	max_tech_stored = techs.len
	for(var/V in techs)
		var/datum/tech/T = new V()
		tech_stored += T
		T.level = 8
