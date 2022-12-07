//This file is for innate station traits, which are applied from the map!

#define TREK_VARIATION_TOS "tos"
#define TREK_VARIATION_TNG "next"
#define TREK_VARIATION_VOY "voy"
#define TREK_VARIATION_ENT "ent"

/datum/station_trait/trek
	name = ""
	trait_type = STATION_TRAIT_ABSTRACT
	weight = 0
	show_in_report = TRUE
	report_message = "We've issued some spaceworthy outifts for the crew."
	/// Variation of jumpsuit we're using.
	var/variation
	var/static/list/variation_to_dept = list(
		TREK_VARIATION_TOS = list(
			"[DEPARTMENT_BITFLAG_ASSISTANT]" = /obj/item/clothing/under/trek/assistant,
			"[DEPARTMENT_BITFLAG_SERVICE|DEPARTMENT_BITFLAG_CARGO]" = /obj/item/clothing/under/trek/srvcar,
			"[DEPARTMENT_BITFLAG_MEDICAL|DEPARTMENT_BITFLAG_SCIENCE]" = /obj/item/clothing/under/trek/medsci,
			"[DEPARTMENT_BITFLAG_ENGINEERING|DEPARTMENT_BITFLAG_SECURITY]" = /obj/item/clothing/under/trek/engsec,
			"[DEPARTMENT_BITFLAG_COMMAND]" = /obj/item/clothing/under/trek/command,
		),
		TREK_VARIATION_TNG = list(
			"[DEPARTMENT_BITFLAG_ASSISTANT]" = /obj/item/clothing/under/trek/assistant/next,
			"[DEPARTMENT_BITFLAG_SERVICE|DEPARTMENT_BITFLAG_CARGO]" = /obj/item/clothing/under/trek/srvcar/next,
			"[DEPARTMENT_BITFLAG_MEDICAL|DEPARTMENT_BITFLAG_SCIENCE]" = /obj/item/clothing/under/trek/medsci/next,
			"[DEPARTMENT_BITFLAG_ENGINEERING|DEPARTMENT_BITFLAG_SECURITY]" = /obj/item/clothing/under/trek/engsec/next,
			"[DEPARTMENT_BITFLAG_COMMAND]" = /obj/item/clothing/under/trek/command/next,
		),
		TREK_VARIATION_VOY = list(
			"[DEPARTMENT_BITFLAG_ASSISTANT]" = /obj/item/clothing/under/trek/assistant/voy,
			"[DEPARTMENT_BITFLAG_SERVICE|DEPARTMENT_BITFLAG_CARGO]" = /obj/item/clothing/under/trek/srvcar/voy,
			"[DEPARTMENT_BITFLAG_MEDICAL|DEPARTMENT_BITFLAG_SCIENCE]" = /obj/item/clothing/under/trek/medsci/voy,
			"[DEPARTMENT_BITFLAG_ENGINEERING|DEPARTMENT_BITFLAG_SECURITY]" = /obj/item/clothing/under/trek/engsec/voy,
			"[DEPARTMENT_BITFLAG_COMMAND]" = /obj/item/clothing/under/trek/command/voy,
		),
		TREK_VARIATION_ENT = list(
			"[DEPARTMENT_BITFLAG_ASSISTANT]" = /obj/item/clothing/under/trek/assistant/ent,
			"[DEPARTMENT_BITFLAG_SERVICE|DEPARTMENT_BITFLAG_CARGO]" = /obj/item/clothing/under/trek/srvcar/ent,
			"[DEPARTMENT_BITFLAG_MEDICAL|DEPARTMENT_BITFLAG_SCIENCE]" = /obj/item/clothing/under/trek/medsci/ent,
			"[DEPARTMENT_BITFLAG_ENGINEERING|DEPARTMENT_BITFLAG_SECURITY]" = /obj/item/clothing/under/trek/engsec/ent,
			"[DEPARTMENT_BITFLAG_COMMAND]" = /obj/item/clothing/under/trek/command/ent,
		),
	)


/datum/station_trait/trek/New()
	. = ..()
	variation = pick(TREK_VARIATION_TOS, TREK_VARIATION_TNG, TREK_VARIATION_VOY, TREK_VARIATION_ENT)
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/datum/station_trait/trek/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER

	if(!ishuman(spawned)) //only humans wear stuff
		return
	var/mob/living/carbon/human/crewmember = spawned
	var/list/department_to_jumpsuit = variation_to_dept[variation]
	if(!department_to_jumpsuit)
		return
	var/obj/item/clothing/uniform
	var/obj/item/clothing/shoes/laceup/laceups
	var/list/departments = job.departments_list.Copy()
	if(job.department_for_prefs)
		departments += job.department_for_prefs
	for(var/datum/job_department/department as anything in list() + job.departments_list)
		for(var/departmental_bitflag in department_to_jumpsuit)
			if(initial(department.department_bitflags) & text2num(departmental_bitflag))
				uniform = department_to_jumpsuit[departmental_bitflag]
	if(!uniform)
		return
	uniform = new uniform()
	laceups = new laceups()
	var/old_shoes = crewmember.shoes
	if(old_shoes)
		qdel(old_shoes)
		crewmember.equip_to_slot_if_possible(laceups, ITEM_SLOT_FEET, disable_warning = TRUE)
	var/old_uniform = crewmember.w_uniform
	if(old_uniform)
		crewmember.w_uniform = null //to prevent side effects like dropping items, this is a temporary removal
		qdel(old_uniform)
		crewmember.equip_to_slot_if_possible(uniform, ITEM_SLOT_ICLOTHING, disable_warning = TRUE)


#undef TREK_VARIATION_TOS
#undef TREK_VARIATION_TNG
#undef TREK_VARIATION_VOY
#undef TREK_VARIATION_ENT
