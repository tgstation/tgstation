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
	var/ear_damage = null//Carbon
	var/cloneloss = 0//Carbon
	var/nodamage = 0
//	flags = NOREACT //uncomment this out later
	var/viruses = list() // replaces var/datum/disease/virus
	var/list/resistances = list()
	var/datum/disease/virus = null
	var/emote_allowed = 1
	var/sdisabilities = 0//Carbon
	var/disabilities = 0//Carbon
	var/monkeyizing = null//Carbon
	var/lying = 0.0
	var/resting = 0.0//Carbon
	var/sleeping = 0.0//Carbon
	var/oxyloss = 0.0//Living
	var/toxloss = 0.0//Living
	var/fireloss = 0.0//Living
	var/bruteloss = 0.0//Living
	var/timeofdeath = 0.0//Living
	var/rejuv = null
	var/antitoxs = null
	var/plasma = null
	var/cpr_time = 1.0//Carbon
	var/health = 100//Living
	var/bodytemperature = 310.055	//98.7 F
	var/bhunger = 0//Carbon
	var/nutrition = 400.0//Carbon
	var/overeatduration = 0		// How long this guy is overeating //Carbon
	var/paralysis = 0.0
	var/stunned = 0.0
	var/weakened = 0.0
	var/losebreath = 0.0//Carbon

	var/obj/item/weapon/storage/s_active = null//Carbon
	var/inertia_dir = 0
	var/datum/dna/dna = null//Carbon
	var/radiation = 0.0//Carbon
	var/mutations = 0//Carbon
	//telekinesis = 1
	//firemut = 2
	//xray = 4
	//hulk = 8
	//clumsy = 16
	//obese = 32
	//husk = 64
/*For ninjas and others. This variable is checked when a mob moves and I guess it was supposed to allow the mob to move
through dense areas, such as walls. Setting density to 0 does the same thing. The difference here is that
the mob is also allowed to move without any sort of restriction. For instance, in space or out of holder objects.*/
//0 is off, 1 is normal, 2 is for ninjas.
	var/incorporeal_move = 0
//The last mob/living/carbon to push/drag/grab this mob (mostly used by Metroids friend recognition)
	var/mob/living/carbon/LAssailant = null





/obj/organ/torso/human
	name = "human torso"
	species = "human"
	maxHealth = 100
	var/underwear = 1//Human
	var/obj/item/weapon/back = null//Human/Monkey
	var/obj/item/weapon/tank/internal = null//Human/Monkey
	var/alien_egg_flag = 0//Have you been infected?
	var/last_special = 0

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

	var/atom/movable/pulling = null
	var/hand = null
	var/obj/item/weapon/handcuffs/handcuffed = null//Living
	var/obj/item/l_hand = null//Living
	var/obj/item/r_hand = null//Living
	var/in_throw_mode = 0
//	var/strangleDelay = 1 //The code is a bit too complicated for that right now

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

	var/moveRunDelay = 1 //not sure about how that works
	var/moveWalkDelay = 7
	//var/knockdownResist = 0
	var/next_move = null
	var/prev_move = null
	var/canmove = 1.0
	var/obj/structure/stool/buckled = null//Living
	var/footstep = 1

/obj/organ/limb/legs/human
	name = "human legs"
	species = "human"

/obj/organ/limb/legs/alien
	name = "alien legs"
	species = "alien"


/obj/organ/head
	name = "head"

	var/stuttering = null//Carbon
	var/druggy = 0//Carbon
	var/confused = 0//Carbon
	var/drowsyness = 0.0//Carbon
	var/dizziness = 0//Carbon
	var/is_dizzy = 0
	var/is_jittery = 0
	var/jitteriness = 0//Carbon
	var/r_epil = 0
	var/r_ch_cou = 0
	var/r_Tourette = 0//Carbon
	var/miming = null //checks if the guy is a mime//Human
	var/silent = null //Can't talk. Value goes down every life proc.//Human
	var/voice_name = "unidentifiable voice"
	var/voice_message = null // When you are not understood by others (replaced with just screeches, hisses, chimpers etc.)
	var/say_message = null // When you are understood by others. Currently only used by aliens and monkeys in their say_quote procs
	var/coughedtime = null
	var/job = null//Living
	var/const/blindness = 1//Carbon
	var/const/deafness = 2//Carbon
	var/const/muteness = 4//Carbon
	var/brainloss = 0//Carbon
	var/robot_talk_understand = 0
	var/alien_talk_understand = 0
	var/universal_speak = 0 // Set to 1 to enable the mob to speak to everyone -- TLE
	var/ear_deaf = null//Carbon
	var/eye_blind = null//Carbon
	var/eye_blurry = null//Carbon
	var/eye_stat = null//Living, potentially Carbon
	var/blinded = null
	var/shakecamera = 0
//Wizard mode, but can be used in other modes thanks to the brand new "Give Spell" badmin button
	var/obj/proc_holder/spell/list/spell_list = list()



/obj/organ/head/human
	name = "human head"
	species = "human"
	var/obj/item/clothing/mask/wear_mask = null//Carbon

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