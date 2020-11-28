/datum/species/robotic
	say_mod = "beeps"
	default_color = "00FF00"
	inherent_biotypes = MOB_ROBOTIC|MOB_HUMANOID
	inherent_traits = list(TRAIT_RADIMMUNE,TRAIT_VIRUSIMMUNE,TRAIT_NOBREATH, TRAIT_TOXIMMUNE, TRAIT_NOCLONELOSS, TRAIT_GENELESS, TRAIT_STABLEHEART,TRAIT_LIMBATTACHMENT, TRAIT_NO_HUSK, TRAIT_OXYIMMUNE)
	mutant_bodyparts = list()
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	reagent_flags = PROCESS_SYNTHETIC
	coldmod = 0.5
	burnmod = 1.1
	heatmod = 1.2
	brutemod = 1.1
	siemens_coeff = 1.2 //Not more because some shocks will outright crit you, which is very unfun
	mutant_organs = list(/obj/item/organ/cyberimp/arm/power_cord)
	mutantbrain = /obj/item/organ/brain/ipc_positron
	mutantstomach = /obj/item/organ/stomach/robot_ipc
	mutantears = /obj/item/organ/ears/robot_ipc
	mutanttongue = /obj/item/organ/tongue/robot_ipc
	mutanteyes = /obj/item/organ/eyes/robot_ipc
	mutantlungs = /obj/item/organ/lungs/robot_ipc
	mutantheart = /obj/item/organ/heart/robot_ipc
	mutantliver = /obj/item/organ/liver/robot_ipc
	exotic_blood = /datum/reagent/fuel/oil

/datum/species/robotic/spec_life(mob/living/carbon/human/H)
	if(H.stat == SOFT_CRIT || H.stat == HARD_CRIT)
		H.adjustFireLoss(1) //Still deal some damage in case a cold environment would be preventing us from the sweet release to robot heaven
		H.adjust_bodytemperature(13) //We're overheating!!
		if(prob(10))
			to_chat(H, "<span class='warning'>Alert: Critical damage taken! Cooling systems failing!</span>")
			do_sparks(3, TRUE, H)

/datum/species/robotic/spec_revival(mob/living/carbon/human/H)
	playsound(H.loc, 'sound/machines/chime.ogg', 50, 1, -1)
	H.visible_message("<span class='notice'>[H]'s monitor lights up.</span>", "<span class='notice'>All systems nominal. You're back online!</span>")

/datum/species/robotic/on_species_gain(mob/living/carbon/human/C)
	. = ..()
	var/obj/item/organ/appendix/appendix = C.getorganslot(ORGAN_SLOT_APPENDIX)
	if(appendix)
		appendix.Remove(C)
		qdel(appendix)

/datum/species/robotic/random_name(gender,unique,lastname)
	var/randname = pick(GLOB.posibrain_names)
	randname = "[randname]-[rand(100, 999)]"
	return randname

/datum/species/robotic/ipc
	name = "I.P.C."
	id = "ipc"
	species_traits = list(ROBOTIC_DNA_ORGANS,MUTCOLORS_PARTSONLY,EYECOLOR,LIPS,HAIR,NOEYESPRITES,ROBOTIC_LIMBS,NOTRANSSTING,REVIVES_BY_HEALING)
	mutant_bodyparts = list()
	default_mutant_bodyparts = list("ipc_antenna" = ACC_RANDOM, "ipc_screen" = ACC_RANDOM, "ipc_chassis" = ACC_RANDOM)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	limbs_icon = 'modular_skyrat/modules/customization/icons/mob/species/ipc_parts.dmi'
	hair_alpha = 210
	sexes = 0
	var/datum/action/innate/monitor_change/screen
	var/saved_screen = "Blank"

/datum/species/robotic/ipc/spec_revival(mob/living/carbon/human/H)
	. = ..()
	//TODO: fix this
	/*H.dna.mutant_bodyparts["ipc_screen"][MUTANT_INDEX_NAME] = "BSOD"
	sleep(3 SECONDS)*/
	H.dna.mutant_bodyparts["ipc_screen"][MUTANT_INDEX_NAME] = saved_screen

/datum/species/robotic/ipc/spec_death(gibbed, mob/living/carbon/human/H)
	. = ..()
	saved_screen = H.dna.mutant_bodyparts["ipc_screen"][MUTANT_INDEX_NAME]
	//TODO: fix this
	/*H.dna.mutant_bodyparts["ipc_screen"][MUTANT_INDEX_NAME] = "BSOD"
	sleep(3 SECONDS)*/
	H.dna.mutant_bodyparts["ipc_screen"][MUTANT_INDEX_NAME] = "Blank"

/datum/species/robotic/ipc/on_species_gain(mob/living/carbon/human/C)
	. = ..()
	if(!screen)
		screen = new
		screen.Grant(C)
	var/chassis = C.dna.mutant_bodyparts["ipc_chassis"]
	if(!chassis)
		return
	var/datum/sprite_accessory/ipc_chassis/chassis_of_choice = GLOB.sprite_accessories["ipc_chassis"][chassis[MUTANT_INDEX_NAME]]
	if(chassis_of_choice)
		limbs_id = chassis_of_choice.icon_state
		if(chassis_of_choice.color_src)
			species_traits += MUTCOLORS
		C.update_body()

/datum/species/robotic/ipc/on_species_loss(mob/living/carbon/human/C)
	. = ..()
	if(screen)
		screen.Remove(C)
	..()

/datum/action/innate/monitor_change
	name = "Screen Change"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "drone_vision"

/datum/action/innate/monitor_change/Activate()
	var/mob/living/carbon/human/H = owner
	var/new_ipc_screen = input(usr, "Choose your character's screen:", "Monitor Display") as null|anything in GLOB.sprite_accessories["ipc_screen"]
	if(!new_ipc_screen)
		return
	H.dna.species.mutant_bodyparts["ipc_screen"][MUTANT_INDEX_NAME] = new_ipc_screen
	H.update_body()

/datum/species/robotic/synthliz
	name = "Synthetic Lizardperson"
	id = "synthliz"
	species_traits = list(ROBOTIC_DNA_ORGANS,MUTCOLORS,EYECOLOR,LIPS,HAIR,ROBOTIC_LIMBS,NOTRANSSTING,REVIVES_BY_HEALING)
	mutant_bodyparts = list()
	default_mutant_bodyparts = list("ipc_antenna" = ACC_RANDOM, "tail" = ACC_RANDOM, "snout" = ACC_RANDOM, "legs" = "Digitigrade Legs", "taur" = "None")
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	limbs_icon = 'modular_skyrat/modules/customization/icons/mob/species/synthliz_parts_greyscale.dmi'

/datum/species/robotic/synthliz/get_random_body_markings(list/passed_features)
	var/name = pick("Synth Pecs Lights", "Synth Scutes", "Synth Pecs")
	var/datum/body_marking_set/BMS = GLOB.body_marking_sets[name]
	var/list/markings = list()
	if(BMS)
		markings = assemble_body_markings_from_set(BMS, passed_features, src)
	return markings
