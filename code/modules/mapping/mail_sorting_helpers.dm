/obj/effect/mapping_helpers/mail_sorting
	icon_state = "sort_type_helper"
	late = TRUE
	var/sort_type = SORT_TYPE_WASTE

/obj/effect/mapping_helpers/mail_sorting/LateInitialize()
	var/obj/structure/disposalpipe/sorting/mail/mail_sorter = locate(/obj/structure/disposalpipe/sorting/mail) in loc
	if(mail_sorter)
		mail_sorter.sortTypes |= sort_type
	else
		log_mapping("[src] failed to find a mail sorting disposal pipe at [AREACOORD(src)]")
	qdel(src)

/obj/effect/mapping_helpers/mail_sorting/supply
	icon_state = "sort_type_helper_sup"

/obj/effect/mapping_helpers/mail_sorting/supply/disposals
	sort_type = SORT_TYPE_DISPOSALS

/obj/effect/mapping_helpers/mail_sorting/supply/cargo_bay
	sort_type = SORT_TYPE_CARGO_BAY

/obj/effect/mapping_helpers/mail_sorting/supply/qm_office
	sort_type = SORT_TYPE_QM_OFFICE

/obj/effect/mapping_helpers/mail_sorting/engineering
	icon_state = "sort_type_helper_eng"

/obj/effect/mapping_helpers/mail_sorting/engineering/general
	sort_type = SORT_TYPE_ENGINEERING

/obj/effect/mapping_helpers/mail_sorting/engineering/ce_office
	sort_type = SORT_TYPE_CE_OFFICE

/obj/effect/mapping_helpers/mail_sorting/engineering/atmospherics
	sort_type = SORT_TYPE_ATMOSPHERICS

/obj/effect/mapping_helpers/mail_sorting/security
	icon_state = "sort_type_helper_sec"

/obj/effect/mapping_helpers/mail_sorting/security/general
	sort_type = SORT_TYPE_SECURITY

/obj/effect/mapping_helpers/mail_sorting/security/hos_office
	sort_type = SORT_TYPE_HOS_OFFICE

/obj/effect/mapping_helpers/mail_sorting/security/detectives_office
	sort_type = SORT_TYPE_DETECTIVES_OFFICE

/obj/effect/mapping_helpers/mail_sorting/medbay
	icon_state = "sort_type_helper_med"

/obj/effect/mapping_helpers/mail_sorting/medbay/general
	sort_type = SORT_TYPE_MEDBAY

/obj/effect/mapping_helpers/mail_sorting/medbay/cmo_office
	sort_type = SORT_TYPE_CMO_OFFICE

/obj/effect/mapping_helpers/mail_sorting/medbay/chemistry
	sort_type = SORT_TYPE_CHEMISTRY

/obj/effect/mapping_helpers/mail_sorting/medbay/virology
	sort_type = SORT_TYPE_VIROLOGY

/obj/effect/mapping_helpers/mail_sorting/science
	icon_state = "sort_type_helper_sci"

/obj/effect/mapping_helpers/mail_sorting/science/research
	sort_type = SORT_TYPE_RESEARCH

/obj/effect/mapping_helpers/mail_sorting/science/rd_office
	sort_type = SORT_TYPE_RD_OFFICE

/obj/effect/mapping_helpers/mail_sorting/science/robotics
	sort_type = SORT_TYPE_ROBOTICS

/obj/effect/mapping_helpers/mail_sorting/science/genetics
	sort_type = SORT_TYPE_GENETICS

/obj/effect/mapping_helpers/mail_sorting/science/experimentor_lab
	sort_type = SORT_TYPE_EXPERIMENTOR_LAB

/obj/effect/mapping_helpers/mail_sorting/science/ordnance
	sort_type = SORT_TYPE_ORDNANCE

/obj/effect/mapping_helpers/mail_sorting/science/xenobiology
	sort_type = SORT_TYPE_XENOBIOLOGY

/obj/effect/mapping_helpers/mail_sorting/service
	icon_state = "sort_type_helper_serv"

/obj/effect/mapping_helpers/mail_sorting/service/hop_office
	sort_type = SORT_TYPE_HOP_OFFICE

/obj/effect/mapping_helpers/mail_sorting/service/library
	sort_type = SORT_TYPE_LIBRARY

/obj/effect/mapping_helpers/mail_sorting/service/chapel
	sort_type = SORT_TYPE_CHAPEL

/obj/effect/mapping_helpers/mail_sorting/service/theater
	sort_type = SORT_TYPE_THEATER

/obj/effect/mapping_helpers/mail_sorting/service/bar
	sort_type = SORT_TYPE_BAR

/obj/effect/mapping_helpers/mail_sorting/service/kitchen
	sort_type = SORT_TYPE_KITCHEN

/obj/effect/mapping_helpers/mail_sorting/service/hydroponics
	sort_type = SORT_TYPE_HYDROPONICS

/obj/effect/mapping_helpers/mail_sorting/service/janitor_closet
	sort_type = SORT_TYPE_JANITOR_CLOSET

/obj/effect/mapping_helpers/mail_sorting/service/dormitories
	sort_type = SORT_TYPE_DORMITORIES

/obj/effect/mapping_helpers/mail_sorting/service/law_office
	sort_type = SORT_TYPE_LAW_OFFICE
