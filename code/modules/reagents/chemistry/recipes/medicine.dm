
/datum/chemical_reaction/leporazine
	name = "Leporazine"
	id = "leporazine"
	results = list("leporazine" = 2)
	required_reagents = list(/datum/reagent/silicon = 1, /datum/reagent/copper = 1)
	required_catalysts = list("plasma" = 5)

/datum/chemical_reaction/rezadone
	name = "Rezadone"
	id = "rezadone"
	results = list("rezadone" = 3)
	required_reagents = list(/datum/reagent/toxin/carpotoxin = 1, /datum/reagent/cryptobiolin = 1, /datum/reagent/copper = 1)

/datum/chemical_reaction/spaceacillin
	name = "Spaceacillin"
	id = "spaceacillin"
	results = list("spaceacillin" = 2)
	required_reagents = list(/datum/reagent/cryptobiolin = 1, "epinephrine" = 1)

/datum/chemical_reaction/inacusiate
	name = "inacusiate"
	id = "inacusiate"
	results = list("inacusiate" = 2)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/carbon = 1, "charcoal" = 1)

/datum/chemical_reaction/synaptizine
	name = "Synaptizine"
	id = "synaptizine"
	results = list("synaptizine" = 3)
	required_reagents = list("sugar" = 1, /datum/reagent/lithium = 1, /datum/reagent/water = 1)

/datum/chemical_reaction/charcoal
	name = "Charcoal"
	id = "charcoal"
	results = list("charcoal" = 2)
	required_reagents = list("ash" = 1, /datum/reagent/consumable/sodiumchloride = 1)
	mix_message = "The mixture yields a fine black powder."
	required_temp = 380

/datum/chemical_reaction/silver_sulfadiazine
	name = "Silver Sulfadiazine"
	id = "silver_sulfadiazine"
	results = list("silver_sulfadiazine" = 5)
	required_reagents = list(/datum/reagent/ammonia = 1, /datum/reagent/silver = 1, /datum/reagent/sulfur = 1, /datum/reagent/oxygen = 1, /datum/reagent/chlorine = 1)

/datum/chemical_reaction/salglu_solution
	name = "Saline-Glucose Solution"
	id = "salglu_solution"
	results = list("salglu_solution" = 3)
	required_reagents = list(/datum/reagent/consumable/sodiumchloride = 1, /datum/reagent/water = 1, "sugar" = 1)

/datum/chemical_reaction/mine_salve
	name = "Miner's Salve"
	id = "mine_salve"
	results = list("mine_salve" = 3)
	required_reagents = list("oil" = 1, /datum/reagent/water = 1, /datum/reagent/iron = 1)

/datum/chemical_reaction/mine_salve2
	name = "Miner's Salve"
	id = "mine_salve"
	results = list("mine_salve" = 15)
	required_reagents = list("plasma" = 5, /datum/reagent/iron = 5, "sugar" = 1) // A sheet of plasma, a twinkie and a sheet of metal makes four of these

/datum/chemical_reaction/synthflesh
	name = "Synthflesh"
	id = /datum/reagent/medicine/synthflesh
	results = list(/datum/reagent/medicine/synthflesh = 3)
	required_reagents = list(/datum/reagent/blood = 1, /datum/reagent/carbon = 1, "styptic_powder" = 1)

/datum/chemical_reaction/styptic_powder
	name = "Styptic Powder"
	id = "styptic_powder"
	results = list("styptic_powder" = 4)
	required_reagents = list(/datum/reagent/aluminium = 1, /datum/reagent/hydrogen = 1, /datum/reagent/oxygen = 1, /datum/reagent/toxin/acid = 1)
	mix_message = "The solution yields an astringent powder."

/datum/chemical_reaction/calomel
	name = "Calomel"
	id = "calomel"
	results = list("calomel" = 2)
	required_reagents = list(/datum/reagent/mercury = 1, /datum/reagent/chlorine = 1)
	required_temp = 374

/datum/chemical_reaction/potass_iodide
	name = "Potassium Iodide"
	id = "potass_iodide"
	results = list("potass_iodide" = 2)
	required_reagents = list(/datum/reagent/potassium = 1, "iodine" = 1)

/datum/chemical_reaction/pen_acid
	name = "Pentetic Acid"
	id = "pen_acid"
	results = list("pen_acid" = 6)
	required_reagents = list(/datum/reagent/fuel = 1, /datum/reagent/chlorine = 1, /datum/reagent/ammonia = 1, /datum/reagent/toxin/formaldehyde = 1, /datum/reagent/sodium = 1, /datum/reagent/toxin/cyanide = 1)

/datum/chemical_reaction/sal_acid
	name = "Salicyclic Acid"
	id = "sal_acid"
	results = list("sal_acid" = 5)
	required_reagents = list(/datum/reagent/sodium = 1, "phenol" = 1, /datum/reagent/carbon = 1, /datum/reagent/oxygen = 1, /datum/reagent/toxin/acid = 1)

/datum/chemical_reaction/oxandrolone
	name = "Oxandrolone"
	id = "oxandrolone"
	results = list("oxandrolone" = 6)
	required_reagents = list(/datum/reagent/carbon = 3, "phenol" = 1, /datum/reagent/hydrogen = 1, /datum/reagent/oxygen = 1)

/datum/chemical_reaction/salbutamol
	name = "Salbutamol"
	id = "salbutamol"
	results = list("salbutamol" = 5)
	required_reagents = list("sal_acid" = 1, /datum/reagent/lithium = 1, /datum/reagent/aluminium = 1, "bromine" = 1, /datum/reagent/ammonia = 1)

/datum/chemical_reaction/perfluorodecalin
	name = "Perfluorodecalin"
	id = "perfluorodecalin"
	results = list("perfluorodecalin" = 3)
	required_reagents = list(/datum/reagent/hydrogen = 1, /datum/reagent/fluorine = 1, "oil" = 1)
	required_temp = 370
	mix_message = "The mixture rapidly turns into a dense pink liquid."

/datum/chemical_reaction/ephedrine
	name = "Ephedrine"
	id = "ephedrine"
	results = list("ephedrine" = 4)
	required_reagents = list("sugar" = 1, "oil" = 1, /datum/reagent/hydrogen = 1, /datum/reagent/diethylamine = 1)
	mix_message = "The solution fizzes and gives off toxic fumes."

/datum/chemical_reaction/diphenhydramine
	name = "Diphenhydramine"
	id = "diphenhydramine"
	results = list("diphenhydramine" = 4)
	required_reagents = list("oil" = 1, /datum/reagent/carbon = 1, "bromine" = 1, /datum/reagent/diethylamine = 1, "ethanol" = 1)
	mix_message = "The mixture dries into a pale blue powder."

/datum/chemical_reaction/oculine
	name = "Oculine"
	id = "oculine"
	results = list("oculine" = 3)
	required_reagents = list("charcoal" = 1, /datum/reagent/carbon = 1, /datum/reagent/hydrogen = 1)
	mix_message = "The mixture sputters loudly and becomes a pale pink color."

/datum/chemical_reaction/atropine
	name = "Atropine"
	id = "atropine"
	results = list("atropine" = 5)
	required_reagents = list("ethanol" = 1, "acetone" = 1, /datum/reagent/diethylamine = 1, "phenol" = 1, /datum/reagent/toxin/acid = 1)

/datum/chemical_reaction/epinephrine
	name = "Epinephrine"
	id = "epinephrine"
	results = list("epinephrine" = 6)
	required_reagents = list("phenol" = 1, "acetone" = 1, /datum/reagent/diethylamine = 1, /datum/reagent/oxygen = 1, /datum/reagent/chlorine = 1, /datum/reagent/hydrogen = 1)

/datum/chemical_reaction/strange_reagent
	name = "Strange Reagent"
	id = "strange_reagent"
	results = list("strange_reagent" = 3)
	required_reagents = list("omnizine" = 1, /datum/reagent/water/holywater = 1, /datum/reagent/toxin/mutagen = 1)

/datum/chemical_reaction/mannitol
	name = "Mannitol"
	id = "mannitol"
	results = list("mannitol" = 3)
	required_reagents = list("sugar" = 1, /datum/reagent/hydrogen = 1, /datum/reagent/water = 1)
	mix_message = "The solution slightly bubbles, becoming thicker."

/datum/chemical_reaction/neurine
	name = "Neurine"
	id = "neurine"
	results = list("neurine" = 3)
	required_reagents = list("mannitol" = 1, "acetone" = 1, /datum/reagent/oxygen = 1)

/datum/chemical_reaction/mutadone
	name = "Mutadone"
	id = "mutadone"
	results = list("mutadone" = 3)
	required_reagents = list(/datum/reagent/toxin/mutagen = 1, "acetone" = 1, "bromine" = 1)

/datum/chemical_reaction/antihol
	name = "antihol"
	id = "antihol"
	results = list("antihol" = 3)
	required_reagents = list("ethanol" = 1, "charcoal" = 1, /datum/reagent/copper = 1)

/datum/chemical_reaction/cryoxadone
	name = "Cryoxadone"
	id = "cryoxadone"
	results = list("cryoxadone" = 3)
	required_reagents = list("stable_plasma" = 1, "acetone" = 1, /datum/reagent/toxin/mutagen = 1)

/datum/chemical_reaction/pyroxadone
	name = "Pyroxadone"
	id = "pyroxadone"
	results = list("pyroxadone" = 2)
	required_reagents = list("cryoxadone" = 1, /datum/reagent/toxin/slimejelly = 1)

/datum/chemical_reaction/clonexadone
	name = "Clonexadone"
	id = "clonexadone"
	results = list("clonexadone" = 2)
	required_reagents = list("cryoxadone" = 1, /datum/reagent/sodium = 1)
	required_catalysts = list("plasma" = 5)

/datum/chemical_reaction/haloperidol
	name = "Haloperidol"
	id = "haloperidol"
	results = list("haloperidol" = 5)
	required_reagents = list(/datum/reagent/chlorine = 1, /datum/reagent/fluorine = 1, /datum/reagent/aluminium = 1, "potass_iodide" = 1, "oil" = 1)

/datum/chemical_reaction/bicaridine
	name = "Bicaridine"
	id = "bicaridine"
	results = list("bicaridine" = 3)
	required_reagents = list(/datum/reagent/carbon = 1, /datum/reagent/oxygen = 1, "sugar" = 1)

/datum/chemical_reaction/kelotane
	name = "Kelotane"
	id = "kelotane"
	results = list("kelotane" = 2)
	required_reagents = list(/datum/reagent/carbon = 1, /datum/reagent/silicon = 1)

/datum/chemical_reaction/antitoxin
	name = "Antitoxin"
	id = "antitoxin"
	results = list("antitoxin" = 3)
	required_reagents = list(/datum/reagent/nitrogen = 1, /datum/reagent/silicon = 1, /datum/reagent/potassium = 1)

/datum/chemical_reaction/tricordrazine
	name = "Tricordrazine"
	id = "tricordrazine"
	results = list("tricordrazine" = 3)
	required_reagents = list("bicaridine" = 1, "kelotane" = 1, "antitoxin" = 1)

/datum/chemical_reaction/regen_jelly
	name = "Regenerative Jelly"
	id = "regen_jelly"
	results = list("regen_jelly" = 2)
	required_reagents = list("tricordrazine" = 1, /datum/reagent/toxin/slimejelly = 1)

/datum/chemical_reaction/corazone
	name = "Corazone"
	id = "corazone"
	results = list("corazone" = 3)
	required_reagents = list("phenol" = 2, /datum/reagent/lithium = 1)

/datum/chemical_reaction/morphine
	name = "Morphine"
	id = "morphine"
	results = list("morphine" = 2)
	required_reagents = list(/datum/reagent/carbon = 2, /datum/reagent/hydrogen = 2, "ethanol" = 1, /datum/reagent/oxygen = 1)
	required_temp = 480

/datum/chemical_reaction/modafinil
	name = "Modafinil"
	id = "modafinil"
	results = list("modafinil" = 5)
	required_reagents = list(/datum/reagent/diethylamine = 1, /datum/reagent/ammonia = 1, "phenol" = 1, "acetone" = 1, /datum/reagent/toxin/acid = 1)
	required_catalysts = list("bromine" = 1) // as close to the real world synthesis as possible

/datum/chemical_reaction/psicodine
	name = "Psicodine"
	id = "psicodine"
	results = list("psicodine" = 5)
	required_reagents = list( "mannitol" = 2, /datum/reagent/water = 2, /datum/reagent/impedrezene = 1)
