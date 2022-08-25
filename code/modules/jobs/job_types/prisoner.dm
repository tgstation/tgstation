/datum/job/prisoner
	title = JOB_PRISONER
	description = "Keep yourself occupied in permabrig."
	department_head = list("The Security Team")
	faction = FACTION_STATION
	total_positions = 0
	spawn_positions = 2
	supervisors = "the security team"
	selection_color = "#ffe1c3"
	exp_granted_type = EXP_TYPE_CREW
	paycheck = PAYCHECK_LOWER

	outfit = /datum/outfit/job/prisoner
	plasmaman_outfit = /datum/outfit/plasmaman/prisoner

	display_order = JOB_DISPLAY_ORDER_PRISONER
	department_for_prefs = /datum/job_department/security

	exclusive_mail_goodies = TRUE
	mail_goodies = list (
		/obj/effect/spawner/random/contraband/prison = 1
	)

	family_heirlooms = list(/obj/item/pen/blue)
	rpg_title = "Defeated Miniboss"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/job/prisoner/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	RegisterSignal(GLOB.data_core, COMSIG_MANIFEST_INJECTED(REF(spawned)), .proc/add_pref_crime)

/datum/job/prisoner/proc/add_pref_crime(datum/datacore/source, mob/living/carbon/human/injected_human, list/new_records)
	UnregisterSignal(source, COMSIG_MANIFEST_INJECTED(REF(injected_human)))
	var/crime_name = injected_human.client?.prefs?.read_preference(/datum/preference/choiced/prisoner_crime)
	if(!crime_name)
		return
	var/datum/data/record/target_record = new_records["sec"]
	var/crime_description = GLOB.crimename2desc[crime_name]
	var/datum/data/crime/past_crime = source.createCrimeEntry(crime_name, crime_description, "Central Command", "Consult Legal.")
	source.addCrime(target_record.fields["id"], past_crime)

/datum/outfit/job/prisoner
	name = "Prisoner"
	jobtype = /datum/job/prisoner

	id = /obj/item/card/id/advanced/prisoner
	id_trim = /datum/id_trim/job/prisoner
	uniform = /obj/item/clothing/under/rank/prisoner
	belt = null
	ears = null
	shoes = /obj/item/clothing/shoes/sneakers/orange

/datum/outfit/job/prisoner/pre_equip(mob/living/carbon/human/H)
	..()
	if(prob(1)) // D BOYYYYSSSSS
		head = /obj/item/clothing/head/beanie/black/dboy

/datum/outfit/job/prisoner/post_equip(mob/living/carbon/human/new_prisoner, visualsOnly)
	. = ..()
	if(!length(SSpersistence.prison_tattoos_to_use) || visualsOnly)
		return
	var/obj/item/bodypart/tatted_limb = pick(new_prisoner.bodyparts)
	var/list/tattoo = pick(SSpersistence.prison_tattoos_to_use)
	tatted_limb.AddComponent(/datum/component/tattoo, tattoo["story"])
	SSpersistence.prison_tattoos_to_use -= tattoo
