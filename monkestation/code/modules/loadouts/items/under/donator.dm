/datum/loadout_item/under/jumpsuit/donator
	donator_only = TRUE
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/donator/tacticoolengineeringuniform
	requires_purchase = FALSE
	name = "Tacticool engineering uniform"
	item_path = /obj/item/clothing/under/rank/centcom/military/eng
	restricted_roles = list(JOB_CHIEF_ENGINEER,JOB_STATION_ENGINEER)

/datum/loadout_item/under/jumpsuit/donator/tacticoolsecuniform
	requires_purchase = FALSE
	name = "Tacticool security uniform"
	item_path = /obj/item/clothing/under/rank/centcom/military
	restricted_roles = list(JOB_CAPTAIN,JOB_HEAD_OF_SECURITY,JOB_WARDEN,JOB_SECURITY_OFFICER,JOB_QUARTERMASTER,JOB_CARGO_TECHNICIAN)
