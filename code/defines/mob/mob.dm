/mob
	density = 1
	layer = 4.0
	animate_movement = 2
	flags = NOREACT
	var/datum/mind/mind




	//MOB overhaul

	//Not in use yet
//	var/obj/organstructure/organStructure = null

	//Vars that have been relocated.

//	var/uses_hud = 0
	var/bruteloss = 0.0//Living
	var/oxyloss = 0.0//Living
	var/toxloss = 0.0//Living
	var/fireloss = 0.0//Living
	var/cloneloss = 0//Carbon
	var/brainloss = 0//Carbon

	var/obj/screen/pain = null
	var/obj/screen/flash = null
	var/obj/screen/blind = null
	var/obj/screen/hands = null
	var/obj/screen/mach = null
	var/obj/screen/sleep = null
	var/obj/screen/rest = null
	var/obj/screen/pullin = null
	var/obj/screen/internals = null
	var/obj/screen/oxygen = null
	var/obj/screen/i_select = null
	var/obj/screen/m_select = null
	var/obj/screen/toxin = null
	var/obj/screen/fire = null
	var/obj/screen/bodytemp = null
	var/obj/screen/healths = null
	var/obj/screen/throw_icon = null
	var/obj/screen/nutrition_icon = null
	var/obj/screen/gun/item/item_use_icon = null
	var/obj/screen/gun/move/gun_move_icon = null
	var/obj/screen/gun/run/gun_run_icon = null
	var/obj/screen/gun/mode/gun_setting_icon = null

	var/total_luminosity = 0 //This controls luminosity for mobs, when you pick up lights and such this is edited.  If you want the mob to use lights it must update its lum in its life proc or such.  Note clamp this value around 7 or such to prevent massive light lag.
	var/last_luminosity = 0

	/*A bunch of this stuff really needs to go under their own defines instead of being globally attached to mob.
	A variable should only be globally attached to turfs/objects/whatever, when it is in fact needed as such.
	The current method unnecessarily clusters up the variable list, especially for humans (although rearranging won't really clean it up a lot but the difference will be noticable for other mobs).
	I'll make some notes on where certain variable defines should probably go.
	Changing this around would probably require a good look-over the pre-existing code.
	*/
	var/midis = 1 //Check if midis should be played for someone
	var/alien_egg_flag = 0//Have you been infected?
	var/last_special = 0
	var/obj/screen/zone_sel/zone_sel = null

	var/emote_allowed = 1
	var/computer_id = null
	var/lastattacker = null
	var/lastattacked = null
	var/attack_log = list( )
	var/already_placed = 0.0
	var/obj/machinery/machine = null
	var/other_mobs = null
	var/memory = ""
	var/poll_answer = 0.0
	var/disabilities = 0//Carbon
	var/atom/movable/pulling = null
	var/stat = 0.0
	var/next_move = null
	var/prev_move = null
	var/monkeyizing = null//Carbon
	var/other = 0.0
	var/hand = null
	var/eye_blind = null//Carbon
	var/eye_blurry = null//Carbon
	var/ear_deaf = null//Carbon
	var/ear_damage = null//Carbon
	var/stuttering = null//Carbon
	var/slurring = null
	var/real_name = null
	var/flavor_text = ""
	var/blinded = null
	var/bhunger = 0//Carbon
	var/ajourn = 0
	var/rejuv = null
	var/druggy = 0//Carbon
	var/confused = 0//Carbon
	var/antitoxs = null
	var/plasma = null
	var/sleeping = 0.0//Carbon
	var/sleeping_willingly = 0.0 //Carbon, allows people to sleep forever if desired
	var/admin_observing = 0.0
	var/resting = 0.0//Carbon
	var/lying = 0.0
	var/canmove = 1.0
	var/eye_stat = null//Living, potentially Carbon

	var/name_archive //For admin things like possession

	var/timeofdeath = 0.0//Living
	var/cpr_time = 1.0//Carbon
	var/health = 100//Living
	var/bodytemperature = 310.055	//98.7 F
	var/drowsyness = 0.0//Carbon
	var/dizziness = 0//Carbon
	var/is_dizzy = 0
	var/is_jittery = 0
	var/jitteriness = 0//Carbon
	var/charges = 0.0
	var/nutrition = 400.0//Carbon
	var/overeatduration = 0		// How long this guy is overeating //Carbon
	var/paralysis = 0.0
	var/stunned = 0.0
	var/weakened = 0.0
	var/losebreath = 0.0//Carbon
	var/intent = null//Living
	var/shakecamera = 0
	var/a_intent = "help"//Living
	var/m_int = null//Living
	var/m_intent = "run"//Living
	var/lastDblClick = 0
	var/lastKnownIP = null
	var/obj/structure/stool/buckled = null//Living
	var/obj/item/weapon/handcuffs/handcuffed = null//Living
	var/obj/item/l_hand = null//Living
	var/obj/item/r_hand = null//Living
	var/obj/item/weapon/back = null//Human/Monkey
	var/obj/item/weapon/tank/internal = null//Human/Monkey
	var/obj/item/weapon/storage/s_active = null//Carbon
	var/obj/item/clothing/mask/wear_mask = null//Carbon
	var/r_epil = 0
	var/r_ch_cou = 0
	var/r_Tourette = 0//Carbon

	var/seer = 0 //for cult//Carbon, probably Human

	var/miming = null //checks if the guy is a mime//Human
	var/silent = null //Can't talk. Value goes down every life proc.//Human

	var/obj/hud/hud_used = null

	//var/list/organs = list(  ) //moved to human.
	var/list/grabbed_by = list(  )
	var/list/requests = list(  )

	var/list/mapobjs = list()

	var/in_throw_mode = 0

	var/coughedtime = null

	var/inertia_dir = 0
	var/footstep = 1

	var/music_lastplayed = "null"

	var/job = null//Living

	var/nodamage = 0
	var/logged_in = 0

	var/underwear = 1//Human
	var/be_syndicate = 0 //This really should be a client variable.  EDIT: Hijacked for my own nefarious purposes!  --SkyMarshal
	var/be_random_name = 0
	var/const/blindness = 1//Carbon
	var/const/deafness = 2//Carbon
	var/const/muteness = 4//Carbon


	var/datum/dna/dna = null//Carbon
	var/radiation = 0.0//Carbon

	var/mutations = 0//Carbon
	var/mutations2 = 0//Carbon
	//telekinesis = 1
	//firemut = 2
	//xray = 4
	//hulk = 8
	//clumsy = 16
	//obese = 32
	//husk = 64

	var/voice_name = "unidentifiable voice"
	var/voice_message = null // When you are not understood by others (replaced with just screeches, hisses, chimpers etc.)
	var/say_message = null // When you are understood by others. Currently only used by aliens and monkeys in their say_quote procs

//Generic list for proc holders. Only way I can see to enable certain verbs/procs. Should be modified if needed.
	var/proc_holder_list[] = list()//Right now unused.
	//Also unlike the spell list, this would only store the object in contents, not an object in itself.

	/* Add this line to whatever stat module you need in order to use the proc holder list.
	Unlike the object spell system, it's also possible to attach verb procs from these objects to right-click menus.
	This requires creating a verb for the object proc holder.

	if (proc_holder_list.len)//Generic list for proc_holder objects.
		for(var/obj/effect/proc_holder/P in proc_holder_list)
			statpanel("[P.panel]","",P)
	*/

//The last mob/living/carbon to push/drag/grab this mob (mostly used by Metroids friend recognition)
	var/mob/living/carbon/LAssailant = null

//Wizard mode, but can be used in other modes thanks to the brand new "Give Spell" badmin button
	var/obj/effect/proc_holder/spell/list/spell_list = list()

//List of active diseases

	var/viruses = list() // replaces var/datum/disease/virus

//Monkey/infected mode
	var/list/resistances = list()
	var/datum/disease/virus = null

	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

/*
//Changeling mode stuff//Carbon
	var/changeling_level = 0
	var/list/absorbed_dna = list()
	var/changeling_fakedeath = 0
	var/chem_charges = 20.00
	var/sting_range = 1
*/
	var/datum/changeling/changeling = null

	var/universal_speak = 0 // Set to 1 to enable the mob to speak to everyone -- TLE
	var/obj/control_object // Hacking in to control objects -- TLE

	var/robot_talk_understand = 0
	var/alien_talk_understand = 0
	var/taj_talk_understand = 0

/*For ninjas and others. This variable is checked when a mob moves and I guess it was supposed to allow the mob to move
through dense areas, such as walls. Setting density to 0 does the same thing. The difference here is that
the mob is also allowed to move without any sort of restriction. For instance, in space or out of holder objects.*/
//0 is off, 1 is normal, 2 is for ninjas.
	var/incorporeal_move = 0


	var/update_icon = 1 // Set to 0 if you want that the mob's icon doesn't update when it moves -- Skie
						// This can be used if you want to change the icon on the fly and want it to stay

	var/UI = 'screen1_old.dmi' // For changing the UI from preferences

//	var/obj/effect/organstructure/organStructure = null //for dem organs
	var/list/organs = list(  )	//List of organs.

//Yes, yes I did.  --SkyMarshal
	var/list/atom/hallucinations = list()
	var/halloss = 0
	var/hallucination = 0
//Singularity wants you!
	var/grav_delay = 0
	var/being_strangled = 0

	var/original_name = null //Original name is only used in ghost chat! It is not to be edited by anything!

/mob/proc/contract_disease(var/datum/disease/virus, var/skip_this = 0, var/force_species_check=1)
//	world << "Contract_disease called by [src] with virus [virus]"
	if(stat >=2) return
	if(virus.type in resistances)
		if(prob(99.9)) return
		resistances.Remove(virus.type)//the resistance is futile

	for(var/datum/disease/D in viruses)
		if(istype(D, virus.type))
			return // two viruses of the same kind can't infect a body at once!!


	if(force_species_check)
		var/fail = 1
		for(var/name in virus.affected_species)
			var/mob_type = text2path("/mob/living/carbon/[lowertext(name)]")
			if(mob_type && istype(src, mob_type))
				fail = 0
				break
		if(fail) return

	if(skip_this == 1)
		//if(src.virus)				< -- this used to replace the current disease. Not anymore!
			//src.virus.cure(0)

		var/datum/disease/v = new virus.type
		src.viruses += v
		v.affected_mob = src
		v.strain_data = v.strain_data.Copy()
		v.holder = src
		if(prob(5))
			v.carrier = 1
		return

	//if(src.virus) //
		//return //


/*
	var/list/clothing_areas	= list()
	var/list/covers = list(UPPER_TORSO,LOWER_TORSO,LEGS,FEET,ARMS,HANDS)
	for(var/Covers in covers)
		clothing_areas[Covers] = list()

	for(var/obj/item/clothing/Clothing in src)
		if(Clothing)
			for(var/Covers in covers)
				if(Clothing&Covers)
					clothing_areas[Covers] += Clothing

*/
	if(prob(15/virus.permeability_mod)) return //the power of immunity compels this disease!

	var/obj/item/clothing/Cl = null
	var/passed = 1

	//chances to target this zone
	var/head_ch
	var/body_ch
	var/hands_ch
	var/feet_ch

	switch(virus.spread_type)
		if(CONTACT_HANDS)
			head_ch = 0
			body_ch = 0
			hands_ch = 100
			feet_ch = 0
		if(CONTACT_FEET)
			head_ch = 0
			body_ch = 0
			hands_ch = 0
			feet_ch = 100
		else
			head_ch = 100
			body_ch = 100
			hands_ch = 25
			feet_ch = 25


	var/target_zone = pick(head_ch;1,body_ch;2,hands_ch;3,feet_ch;4)//1 - head, 2 - body, 3 - hands, 4- feet

	if(istype(src, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src

		switch(target_zone)
			if(1)
				if(isobj(H.head))
					Cl = H.head
					passed = prob(Cl.permeability_coefficient*100*virus.permeability_mod)
//					world << "Head pass [passed]"
				if(passed && isobj(H.wear_mask))
					Cl = H.wear_mask
					passed = prob(Cl.permeability_coefficient*100*virus.permeability_mod)
//					world << "Mask pass [passed]"
			if(2)//arms and legs included
				if(isobj(H.wear_suit))
					Cl = H.wear_suit
					passed = prob(Cl.permeability_coefficient*100*virus.permeability_mod)
//					world << "Suit pass [passed]"
				if(passed && isobj(H.slot_w_uniform))
					Cl = H.slot_w_uniform
					passed = prob(Cl.permeability_coefficient*100*virus.permeability_mod)
//					world << "Uniform pass [passed]"
			if(3)
				if(isobj(H.wear_suit) && H.wear_suit.body_parts_covered&HANDS)
					Cl = H.wear_suit
					passed = prob(Cl.permeability_coefficient*100*virus.permeability_mod)
//					world << "Suit pass [passed]"

				if(passed && isobj(H.gloves))
					Cl = H.gloves
					passed = prob(Cl.permeability_coefficient*100*virus.permeability_mod)
//					world << "Gloves pass [passed]"
			if(4)
				if(isobj(H.wear_suit) && H.wear_suit.body_parts_covered&FEET)
					Cl = H.wear_suit
					passed = prob(Cl.permeability_coefficient*100*virus.permeability_mod)
//					world << "Suit pass [passed]"

				if(passed && isobj(H.shoes))
					Cl = H.shoes
					passed = prob(Cl.permeability_coefficient*100*virus.permeability_mod)
//					world << "Shoes pass [passed]"
			else
				src << "Something strange's going on, something's wrong."

			/*if("feet")
				if(H.shoes && istype(H.shoes, /obj/item/clothing/))
					Cl = H.shoes
					passed = prob(Cl.permeability_coefficient*100)
					//
					world << "Shoes pass [passed]"
			*/		//
	else if(istype(src, /mob/living/carbon/monkey))
		var/mob/living/carbon/monkey/M = src
		switch(target_zone)
			if(1)
				if(M.wear_mask && isobj(M.wear_mask))
					Cl = M.wear_mask
					passed = prob(Cl.permeability_coefficient*100+virus.permeability_mod)
					//world << "Mask pass [passed]"

	if(passed && virus.spread_type == AIRBORNE && internals)
		passed = (prob(50*virus.permeability_mod))

	if(passed)
		//world << "Infection in the mob [src]. YAY"


/*
	var/score = 0
	if(istype(src, /mob/living/carbon/human))
		if(src:gloves) score += 5
		if(istype(src:wear_suit, /obj/item/clothing/suit/space)) score += 10
		if(istype(src:wear_suit, /obj/item/clothing/suit/bio_suit)) score += 10
		if(istype(src:head, /obj/item/clothing/head/helmet/space)) score += 5
		if(istype(src:head, /obj/item/clothing/head/bio_hood)) score += 5
	if(wear_mask)
		score += 5
		if((istype(src:wear_mask, /obj/item/clothing/mask) || istype(src:wear_mask, /obj/item/clothing/mask/surgical)) && !internal)
			score += 5
		if(internal)
			score += 5
	if(score > 20)
		return
	else if(score == 20 && prob(95))
		return
	else if(score >= 15 && prob(75))
		return
	else if(score >= 10 && prob(55))
		return
	else if(score >= 5 && prob(35))
		return
	else if(prob(15))
		return
	else*/
		var/datum/disease/v = new virus.type
		src.viruses += v
		v.affected_mob = src
		v.strain_data = v.strain_data.Copy()
		v.holder = src
		if(prob(5))
			v.carrier = 1
		return
	return





// ++++ROCKDTBEN++++ MOB PROCS

/mob/proc/getBruteLoss()
	return bruteloss

/mob/proc/adjustBruteLoss(var/amount)
	bruteloss = max(bruteloss + amount, 0)

/mob/proc/getOxyLoss()
	return oxyloss

/mob/proc/adjustOxyLoss(var/amount)
	oxyloss = max(oxyloss + amount, 0)

/mob/proc/setOxyLoss(var/amount)
	oxyloss = amount

/mob/proc/getToxLoss()
	return toxloss

/mob/proc/adjustToxLoss(var/amount)
	toxloss = max(toxloss + amount, 0)

/mob/proc/setToxLoss(var/amount)
	toxloss = amount

/mob/proc/getFireLoss()
	return fireloss

/mob/proc/adjustFireLoss(var/amount)
	fireloss = max(fireloss + amount, 0)

/mob/proc/getCloneLoss()
	return cloneloss

/mob/proc/adjustCloneLoss(var/amount)
	cloneloss = max(cloneloss + amount, 0)

/mob/proc/setCloneLoss(var/amount)
	cloneloss = amount

/mob/proc/getBrainLoss()
	return brainloss

/mob/proc/adjustBrainLoss(var/amount)
	brainloss = max(brainloss + amount, 0)

/mob/proc/setBrainLoss(var/amount)
	brainloss = amount

// ++++ROCKDTBEN++++ MOB PROCS //END

