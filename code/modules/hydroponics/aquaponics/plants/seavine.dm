/datum/aquaponics_plant/seavine //Seavines: A common kelp found almost everywhere. Slightly nourishing when eaten.
	name = "Seavines"
	desc = "A common kelp found across Deorsum. It's a good source of nourishment."
	genetic_desc = "Turbulent genetic history across generations implies constant mutation. Traditional mutagens should accelerate mutation."
	fluff_desc = "Seavines are among the oldest life on Deorsum; its ability to easily mutate makes them prime specimens for research."
	icon = "seavine"
	mutation_catalysts = list("radium", "uranium", "mutagen")
	possible_mutations = list(/datum/aquaponics_plant/seavine/seevine = 60, /datum/aquaponics_plant/seavine/reevine = 40)

/datum/aquaponics_plant/seavine/seevine //Seevines: Mutated seavines. Causes moderate invisibility when eaten.
	name = "Seevines"
	desc = "A mutation of seavines that's evolved chameleon cells. Ingestion causes translucency."
	genetic_desc = "Further chameleon capabilities may be possible. Potential mutagen unknown."
	fluff_desc = "This strain of seavine is natural and likely died out due to its hefty nutrient consumption."
	icon = "seevine"
	nutrient_consumption = 1
	mutation_catalysts = list("smoke_powder")
	possible_mutations = list(/datum/aquaponics_plant/seavine/seevine/darkvine = 100)

/datum/aquaponics_plant/seavine/seevine/darkvine //Darkvines: Mutated seevines. Causes complete invisibility when eaten... at a price.
	name = "Darkvines"
	desc = "A mutation of seevines with enhanced chameleon abilities. Ingestion causes complete invisibility."
	genetic_desc = "Improvement and multiplication of chameleon cells induced volatility. Further mutation impossible."
	fluff_desc = "Darkvines are believed by many religious folk to be possessed by the Wish Granter."
	icon = "darkvine"
	nutrient_consumption = 2.5
	mutation_catalysts = list()
	possible_mutations = list()

/datum/aquaponics_plant/seavine/reevine //Reevines: Mutated seavines. Causes intense anger (red tint and stun reduction) when eaten.
	name = "Reevines"
	desc = "A mutation of seavines with strange chemical compounds that induce intense anger when ingested."
	genetic_desc = "Genes appear much more resistant to outside influence. Further mutation impossible."
	fluff_desc = "Reevines are consumed by some daredevil scientists to improve their combat capabilities."
	icon = "reevine"
	mutation_catalysts = list()
	possible_mutations = list()



/obj/item/plant_sample/seavine
	name = "seavine sample"
	desc = "An uprooted sample of juvenile seavines."
	sample = /datum/aquaponics_plant/seavine
