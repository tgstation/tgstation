/***************************************************************
Science Research and Development System (Designed and Developed by the /tg/station crew)

*insert stuff here later*

*****************************************

Integrating Objects into the Science Research and Development System

First of all, the root /obj/ define has to have two variables added to it if it doesn't have them already:
	var/list/origin_tech = list()
	var/reliability = 100

* The origin_tech list is a list of all the technolgies (by ID) and their level at the time the object was created (format: "ID" = #).
If an object can't be reversed engineered, you're just going to leave this variable alone.
* The relability var is the reliability of an object before tech modifiers. Items that start spawned and items that aren't part of the
R&D system should just leave the reliability var at 100 and ignore it. Otherwise, you'll want to adjust it down based on the
pre-technology-modifier reliability you want for the object. You'd also want to add some sort of mechanic that deals with that
var as well.
*SPECIAL NOTE: For non-carriable objects that you can deconstruct into RE'able parts, make sure to include some way of passing on
the data from the components to the finished procuct and back again.

***************************************************************/

/*
To Do List:
- Need stuff to research!
- Add various vars to base /obj/ type to list what techs were required to make it. Also add malfuction variables.

*/

/***************************************************************
**						Master Types						  **
**	Includes all the helper procs and basic tech processing.  **
***************************************************************/

/datum/research								//Holder for all the existing, archived, and known tech. Individual to console.
	var
		list								//Datum/tech go here.
			possible_tech = list()			//List of all tech in the game that players have access to (barring special events).
			known_tech = list()				//List of locally known tech.
			possible_designs = list()		//List of all designs (at base reliability).
			known_designs = list()			//List of available designs (at base reliability).

	New()		//Insert techs into possible_tech here. Known_tech automatically updated.
		for(var/T in typesof(/datum/tech) - /datum/tech)
			possible_tech += new T(src)
		for(var/D in typesof(/datum/design) - /datum/design)
			possible_designs += new D(src)
		RefreshResearch()

	proc

		//Checks to see if tech has all the required pre-reqs.
		//Input: datum/tech; Output: 0/1 (false/true)
		TechHasReqs(var/datum/tech/T)
			if(T.req_tech.len == 0)
				return 1
			var/matches = 0
			for(var/req in T.req_tech)
				for(var/datum/tech/known in known_tech)
					if(req == known && T.req_tech[req] <= known_tech[known])
						matches++
			if(matches == T.req_tech.len)
				return 1
			else
				return 0

		//Checks to see if design has all the required pre-reqs.
		//Input: datum/design; Output: 0/1 (false/true)
		DesignHasReqs(var/datum/design/D)
			if(D.req_tech.len == 0)
				return 1
			var/matches
			for(var/req in D.req_tech)
				for(var/datum/tech/known in known_tech)
					if(req == known && D.req_tech[req] <= known_tech[known])
						matches++
			if(matches == D.req_tech.len)
				return 1
			else
				return 0

		//Adds a tech to known_tech list. Checks to make sure there aren't duplicates and updates existing tech's levels if needed.
		//Input: datum/tech; Output: Null
		AddTech2Known(var/datum/tech/T)
			for(var/datum/tech/known in known_tech)
				if(T.id == known.id)
					if(T.level > known.level)
						known.level = T.level
					return
			known_tech += T
			RefreshResearch()
			return

		AddDesign2Known(var/datum/design/D)
			for(var/datum/design/known in known_designs)
				if(D.id == known.id)
					if(D.reliability > known.reliability)
						known.reliability = D.reliability
					return
			known_designs += D
			RefreshResearch()
			return

		//Refreshes known_tech list with entries in archived and possible techs.
		//Input/Output: n/a
		RefreshResearch()
			for(var/datum/tech/PT in possible_tech - known_tech)
				if(TechHasReqs(PT))
					AddTech2Known(PT)
			for(var/datum/design/PD in possible_designs - known_designs)
				if(DesignHasReqs(PD))
					AddDesign2Known(PD)
			return

		//Finds the reliability of a given object based on it's base reliablity and related technologies.
		//Input: Object; Output: Number
		//CompositeReliability()	//Saving until I get a better idea of how reliability should calculate.



/***************************************************************
**						Technology Datums					  **
**	Includes all the various technoliges and what they make.  **
***************************************************************/

datum
	tech		//Datum of individual technologies.
		var
			name = "name"					//Name of the technology.
			desc = "description"			//General description of what it does and what it makes.
			id = "id"						//An easily referenced ID. Must be alphanumeric, lower-case, and no symbols.
			level = 1						//A simple number scale of the research level. Level 0 = Secret tech.
			list/req_tech = list()			//List of ids associated values of techs required to research this tech. "id" = #


//Trunk Technologies (don't actually build anything and don't require any other techs).

		materials
			name = "Materials Research"
			desc = "Development of new and improved materials."
			id = "materials"

		plasmatech
			name = "Plasma Research"
			desc = "Research into the mysterious substance colloqually known as 'plasma'"
			id = "plasmatech"

		powerstorage
			name = "Power Storage Technology"
			desc = "The various technologies behind the storage of electicity."
			id = "powerstorage"

		bluespace
			name = "'Blue-space' Research"
			desc = "Research into the sub-reality known as 'blue-space'"
			id = "bluespace"

		biotech
			name = "Biological Technology"
			desc = "Research into the deeper mysteries of life and organic substances."
			id = "biotech"

		magnets
			name = "Electromagnetic Spectrum Research"
			desc = "Research into the electromagnetic spectrum. No clue how they actually work, though."
			id = "magnets"

		programming
			name = "Data Theory Research"
			desc = "The development of new computer and artificial intelligence systems."
			id = "programming"

		syndicate
			name = "Illegal Technologies Research"
			desc = "The study of technologies that violate Nanotrassen regulations."
			id = "syndicate"

	//Branch Techs
		metaltech
			name = "Metallurgy Research"
			desc = "Development of new and improved metal alloys for different purposes."
			id = "metaltech"
			req_tech = list("materials" = 2)

		glasstech
			name = "Transparent Material Research"
			desc = "Development of new and stronger transparent materials (glass, crystal, transparent aluminum, etc)."
			id = "glasstech"
			req_tech = list("materials" = 2)

		explosives
			name = "Explosives Research"
			desc = "The creation and application of explosive materials."
			id = "explosives"
			req_tech = list("materials" = 3)

		generators
			name = "Power Generation Technology"
			desc = "Research into more powerful and more reliable sources."
			id = "generators"
			req_tech = list("powerstorage" = 2)

		smestech
			name = "Super-Magnetic Energy Storage Technology"
			desc = "Design better, stationary power storage devices."
			id = "smestech"
			req_tech = list("powerstorage" = 3, "magnets" = 3)

		cybernetics
			name = "Cybernetic Technology"
			desc = "The development of advanced man/machine interfaces."
			id = "cybernetics"
			req_tech = list("biotech" = 3, "programming" = 3)

/obj/item/weapon/disk/tech_disk
	name = "Technology Disk"
	desc = "A disk for storing technology data for further research."
	icon = 'cloning.dmi'
	icon_state = "datadisk2"
	item_state = "card-id"
	w_class = 1.0
	var/datum/tech/stored
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)