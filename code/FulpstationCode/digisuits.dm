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



/obj/item/clothing/under/proc/digisuit_var_update() //Updates vars for all the above items - seems cleaner than having a huge list of redefines and less invasive than manually adding
	if(src.type in GLOB.digisuits)
		fulp_digisuit = TRUE
		mutantrace_variation = MUTANTRACE_VARIATION

/datum/species/proc/digisuit_icon_check(var/obj/item/clothing/under/U) //checks for digi variant
	if(U.mutantrace_variation == !MUTANTRACE_VARIATION)
		return TRUE
	else
		return FALSE

/mob/living/carbon/human/proc/digisuit_icon_update(var/obj/item/clothing/under/U)
	if(U.fulp_digisuit)
		U.mob_overlay_icon = 'icons/fulpicons/mith_stash/clothing/under_worn.dmi'
