







	//DIGISUITS//

/datum/species/proc/digisuit_icon_check(var/obj/item/clothing/under/U) //checks for digi variant
	return U.mutantrace_variation != MUTANTRACE_VARIATION


/mob/living/carbon/human/proc/digisuit_icon_update(var/obj/item/clothing/under/U)
	if(U.fulp_digisuit)
		U.worn_icon = 'icons/fulpicons/mith_stash/clothing/under_worn.dmi'


/obj/item/clothing/under
	var/fulp_digisuit = FALSE

// List of Clothing converted to use Digisuits (Make sure to turn fulp_diugisuit TRUE! and assign mob_overlay_icon)

/obj/item/clothing/under/rank/civilian/bartender
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/civilian/chaplain
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/civilian/chef
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/civilian/hydroponics
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/civilian/janitor
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/civilian/lawyer/black
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/civilian/lawyer/red
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/civilian/lawyer/blue
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/civilian/lawyer/bluesuit
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/civilian/lawyer/purpsuit
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/color/grey
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/civilian/mime
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/civilian/curator
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/engineering/chief_engineer
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/engineering/atmospheric_technician
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/engineering/engineer
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/medical/chief_medical_officer
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/medical/geneticist
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/medical/virologist
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/medical/doctor
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/medical/chemist
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/rnd/research_director
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/rnd/research_director/turtleneck
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/rnd/scientist
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/rnd/roboticist
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/security/officer
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/security/warden
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/security/detective
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/security/head_of_security
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/security/head_of_security/alt
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/prisoner
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/cargo/qm
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE
/obj/item/clothing/under/rank/cargo/miner/lavaland
	mutantrace_variation = MUTANTRACE_VARIATION
	fulp_digisuit = TRUE

/obj/item/clothing/under/rank/civilian/bartender/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/civilian/chaplain/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/civilian/chef/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/civilian/hydroponics/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/civilian/janitor/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/civilian/lawyer/black/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/civilian/lawyer/red/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/civilian/lawyer/blue/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/civilian/lawyer/bluesuit/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/civilian/lawyer/purpsuit/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/color/grey/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/civilian/mime/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/civilian/curator/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/engineering/chief_engineer/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/engineering/atmospheric_technician/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/engineering/engineer/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/medical/chief_medical_officer/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/medical/geneticist/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/medical/virologist/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/medical/doctor/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/medical/chemist/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/rnd/research_director/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/rnd/research_director/turtleneck/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/rnd/scientist/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/rnd/roboticist/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/security/officer/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/security/warden/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/security/detective/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/security/head_of_security/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/security/head_of_security/alt/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/prisoner/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/obj/item/clothing/under/rank/cargo/qm/skirt
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	fulp_digisuit = FALSE
/*
GLOBAL_LIST_INIT(digisuits, list(
	/obj/item/clothing/under/rank/civilian/bartender, /obj/item/clothing/under/rank/civilian/chaplain,
	/obj/item/clothing/under/rank/civilian/chef, /obj/item/clothing/under/rank/civilian/hydroponics,
	/obj/item/clothing/under/rank/civilian/janitor, /obj/item/clothing/under/rank/civilian/lawyer/black,
	/obj/item/clothing/under/rank/civilian/lawyer/red, /obj/item/clothing/under/rank/civilian/lawyer/blue,
	/obj/item/clothing/under/rank/civilian/lawyer/bluesuit, /obj/item/clothing/under/rank/civilian/lawyer/purpsuit,
	/obj/item/clothing/under/color/grey, /obj/item/clothing/under/rank/civilian/mime,
	/obj/item/clothing/under/rank/civilian/curator, /obj/item/clothing/under/rank/engineering/chief_engineer,
	/obj/item/clothing/under/rank/engineering/atmospheric_technician, /obj/item/clothing/under/rank/engineering/engineer,
	/obj/item/clothing/under/rank/medical/chief_medical_officer, /obj/item/clothing/under/rank/medical/geneticist,
	/obj/item/clothing/under/rank/medical/virologist, /obj/item/clothing/under/rank/medical/doctor,
	/obj/item/clothing/under/rank/medical/chemist, /obj/item/clothing/under/rank/rnd/research_director,
	/obj/item/clothing/under/rank/rnd/research_director/turtleneck, /obj/item/clothing/under/rank/rnd/scientist,
	/obj/item/clothing/under/rank/rnd/roboticist, /obj/item/clothing/under/rank/security/officer,
	/obj/item/clothing/under/rank/security/warden, /obj/item/clothing/under/rank/security/detective,
	/obj/item/clothing/under/rank/security/head_of_security, /obj/item/clothing/under/rank/security/head_of_security/alt,
	/obj/item/clothing/under/rank/prisoner, /obj/item/clothing/under/rank/cargo/qm,
	/obj/item/clothing/under/rank/cargo/miner/lavaland
	)) //Add any extra non-fulp items with digitigrade variant sprites to this list
*/


/*
/obj/item/clothing/under/proc/digisuit_var_update() //Updates vars for all the above items - seems cleaner than having a huge list of redefines and less invasive than manually adding
	if(src.type in GLOB.digisuits)
		fulp_digisuit = TRUE
		mutantrace_variation = MUTANTRACE_VARIATION
*/

