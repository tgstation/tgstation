/datum/wound
	//Flags
	var/visibility_flags = 0
	var/disease_flags = CURABLE|CAN_CARRY|CAN_RESIST
	var/spread_flags = DISEASE_SPREAD_AIRBORNE | DISEASE_SPREAD_CONTACT_FLUIDS | DISEASE_SPREAD_CONTACT_SKIN

	//Fluff
	var/form = "injury"
	var/name = "ouchie"
	var/desc = ""
	var/agent = "some microbes"
	var/spread_text = ""
	var/cure_text = ""

	//Stages
	var/stage = 1
	var/max_stages = 0
	var/stage_prob = 4

	var/severity = WOUND_SEVERITY_MODERATE

	//Other
	var/list/viable_mobtypes = list(mob/living/carbon) //typepaths of viable mobs
	var/list/viable_zones = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG) //which body parts we can affect
	var/mob/living/carbon/victim = null
	var/process_dead = FALSE //if this ticks while the host is dead

/datum/wound/Destroy()
	. = ..()
	if(affected_mob)
		remove_disease()
	SSdisease.active_diseases.Remove(src)

//add this disease if the host does not already have too many
/datum/wound/proc/apply_wound(mob/living/carbon/C, zone)
	if(istype(C) && C.get_bodypart(zone) && (zone in viable_zones))
		return TRUE

//add the disease with no checks
/datum/wound/proc/infect(var/mob/living/infectee, make_copy = TRUE)
	var/datum/wound/D = make_copy ? Copy() : src
	infectee.diseases += D
	D.affected_mob = infectee
	SSdisease.active_diseases += D //Add it to the active diseases list, now that it's actually in a mob and being processed.

	D.after_add()
	infectee.med_hud_set_status()

	var/turf/source_turf = get_turf(infectee)
	log_virus("[key_name(infectee)] was infected by virus: [src.admin_details()] at [loc_name(source_turf)]")

//Return a string for admin logging uses, should describe the disease in detail

/datum/wound/proc/remove_wound()
	if(victim)
		LAZYREMOVE(victim.all_wounds, src)		//remove the datum from the list
	if(limb)
		LAZYREMOVE(limb.wound, src)		//remove the datum from the list
	victim = null
	limb = null
	qdel(src)

//mob/living/carbon/proc/generate_wound()
