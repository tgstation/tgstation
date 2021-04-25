
/datum/award/achievement/jobs
	category = "Jobs"
	icon = "basemisc"

//chemistry

/datum/award/achievement/jobs/chemistry_tut
	name = "Perfect chemistry blossom"
	desc = "Passed the chemistry tutorial with perfect purity!"
	database_id = MEDAL_CHEM_TUT
	icon = "chem_tut"

//service members related to serving food! hip hip!

/datum/award/achievement/jobs/service_bad
	name = "Centcom Grade: Shitty Service"
	desc = "You earned less than 2000 credits from tourists. Pretty bad job, but you at least tried!"
	database_id = MEDAL_BAD_SERVICE

/datum/award/achievement/jobs/service_okay
	name = "Centcom Grade: Acceptable Service"
	desc = "More than 2000 makes for a decent day of service! You and your department did just fine."
	database_id = MEDAL_OKAY_SERVICE

/datum/award/achievement/jobs/service_good
	name = "Centcom Grade: Exemplary Service"
	desc = "More than 5000 credits, wow! Centcom is very impressed with your department!"
	database_id = MEDAL_GOOD_SERVICE

//for cargo techies, and the quartermaster!
//note, the achievement for bad supply will only be given if you got any signatures at all (aka tried) and enough requests were made (look we got 100%! >only one request made)

/datum/award/achievement/jobs/supply_bad
	name = "Centcom Grade: Shitty Supply"
	desc = "Less than half of your delivered requests got a signature. Very lackluster delivery!"
	database_id = MEDAL_BAD_SUPPLY

/datum/award/achievement/jobs/supply_okay
	name = "Centcom Grade: Acceptable Supply"
	desc = "At least half of your delivered requests collected signatures. Centcom is satisfied!"
	database_id = MEDAL_OKAY_SUPPLY

/datum/award/achievement/jobs/supply_good
	name = "Centcom Grade: Exemplary Supply"
	desc = "Every requested item was delivered WITH a signature! Amazing!"
	database_id = MEDAL_GOOD_SUPPLY
