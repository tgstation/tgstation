/datum/id_trim/away
	access = list(ACCESS_AWAY_GENERAL)

/datum/id_trim/away/hotel
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINT)

/datum/id_trim/away/hotel/security
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINT, ACCESS_AWAY_SEC)

/datum/id_trim/away/old/sec
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_SEC)
	assignment = "Charlie Station Security Officer"

/datum/id_trim/away/old/sci
	access = list(ACCESS_AWAY_GENERAL)
	assignment = "Charlie Station Scientist"

/datum/id_trim/away/old/eng
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_ENGINE)
	assignment = "Charlie Station Engineer"

/datum/id_trim/away/old/apc
	access = list(ACCESS_ENGINE_EQUIP)
