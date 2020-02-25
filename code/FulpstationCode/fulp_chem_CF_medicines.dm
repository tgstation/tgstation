////Fulp SalChems (T5 Trekkie Chems and Comebacks Rework)
//@Author: Saliferous

//**BRUTE**

/datum/chemical_reaction/bicaridine
	name = "Bicaridine"
	id = /datum/reagent/medicine/CF/bicaridine
	results = list(/datum/reagent/medicine/CF/bicaridine = 3)
	required_reagents = list(/datum/reagent/oxygen = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/carbon = 1, /datum/reagent/medicine/CF/trekamol = 1)
	mix_message = "The solution warps and turns into a red, space-worthy liquid."

//**BURN**

/datum/chemical_reaction/kelotane
	name = "Kelotane"
	id = /datum/reagent/medicine/CF/kelotane
	results = list(/datum/reagent/medicine/CF/kelotane = 3)
	required_reagents = list(/datum/reagent/carbon = 1, /datum/reagent/silicon = 1, /datum/reagent/medicine/CF/trekamol = 1)
	mix_message = "The solution warps and turns into a lime-colored, space-worthy liquid."

//**Toxin**

/datum/chemical_reaction/antitoxin
	name = "Anti-Toxin"
	id = /datum/reagent/medicine/CF/antitoxin
	results = list(/datum/reagent/medicine/CF/antitoxin = 3)
	required_reagents = list(/datum/reagent/nitrogen = 1, /datum/reagent/silicon = 1, /datum/reagent/potassium = 1, /datum/reagent/medicine/CF/trekamol = 1)
	mix_message = "The solution warps and turns into a green, space-worthy liquid."

//**OXY**
//Commented out as convermol is just perfluoro with a new name
/*/datum/chemical_reaction/perfluorodecalin
	name = "Perfluorodecalin"
	id = /datum/reagent/medicine/CF/perfluorodecalin
	results = list(/datum/reagent/medicine/CF/perfluorodecalin = 3)
	required_reagents = list(/datum/reagent/oil = 1, /datum/reagent/fluorine = 1, /datum/reagent/hydrogen = 1)
	required_temp = 370
	mix_message = "The solution boils into a thick, red liquid."
*/

//**ALL**

/datum/chemical_reaction/tricordrazine
	name = "Tricordrazine"
	id = /datum/reagent/medicine/CF/tricordrazine
	results = list(/datum/reagent/medicine/CF/tricordrazine = 3)
	required_reagents = list(/datum/reagent/medicine/CF/bicaridine = 1, /datum/reagent/medicine/CF/kelotane = 1, /datum/reagent/medicine/CF/antitoxin = 1, /datum/reagent/medicine/C2/convermol = 1, /datum/reagent/medicine/CF/trekamol = 1)
	mix_message = "The solution warps into a superior gold, space-worthy liquid."

//**Additional Chems (not T5)

/datum/chemical_reaction/charcoal
	name = "Charcoal"
	id = /datum/reagent/medicine/CF/charcoal
	results = list(/datum/reagent/medicine/CF/charcoal = 3)
	required_reagents = list(/datum/reagent/consumable/sodiumchloride = 1, /datum/reagent/ash = 1, /datum/reagent/carbon = 2)
	required_temp = 400
	mix_message = "The solution burns into a black, chalky substance.... oh it's just charcoal."

/datum/chemical_reaction/synthflesh
	name = "Synthflesh"
	id = /datum/reagent/medicine/CF/synthflesh
	results = list(/datum/reagent/medicine/CF/synthflesh = 3)
	required_reagents = list(/datum/reagent/blood = 1, /datum/reagent/medicine/CF/styptic = 1, /datum/reagent/medicine/CF/silver_sulfadiazine = 1)

/datum/chemical_reaction/styptic
	name = "Styptic Powder"
	id = /datum/reagent/medicine/CF/styptic
	results = list(/datum/reagent/medicine/CF/styptic = 4)
	required_reagents = list(/datum/reagent/aluminium = 1, /datum/reagent/hydrogen = 1, /datum/reagent/oxygen = 1, /datum/reagent/toxin/acid = 1)
	mix_message = "The solution yields an astringent powder"

/datum/chemical_reaction/silver_sulfadiazine
    name = "Silver Sulfadiazine"
    id = /datum/reagent/medicine/CF/silver_sulfadiazine
    results = list(/datum/reagent/medicine/CF/silver_sulfadiazine = 4)
    required_reagents = list(/datum/reagent/silver = 1, /datum/reagent/sulfur = 1, /datum/reagent/oxygen = 1, /datum/reagent/chlorine = 1)
