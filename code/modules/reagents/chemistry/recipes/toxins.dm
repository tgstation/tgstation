
/datum/chemical_reaction/formaldehyde
	id = "Formaldehyde"
	results = list("formaldehyde" = 3)
	required_reagents = list("ethanol" = 1, "oxygen" = 1, "silver" = 1)
	required_temp = 420

/datum/chemical_reaction/neurotoxin2
	id = "neurotoxin2"
	results = list("neurotoxin2" = 1)
	required_reagents = list("space_drugs" = 1)
	required_temp = 674

/datum/chemical_reaction/cyanide
	id = "cyanide"
	results = list("cyanide" = 3)
	required_reagents = list("oil" = 1, "ammonia" = 1, "oxygen" = 1)
	required_temp = 380

/datum/chemical_reaction/itching_powder
	id = "itching_powder"
	results = list("itching_powder" = 3)
	required_reagents = list("welding_fuel" = 1, "ammonia" = 1, "charcoal" = 1)

/datum/chemical_reaction/facid
	id = "facid"
	results = list("facid" = 4)
	required_reagents = list("sacid" = 1, "fluorine" = 1, "hydrogen" = 1, "potassium" = 1)
	required_temp = 380

/datum/chemical_reaction/sulfonal
	id = "sulfonal"
	results = list("sulfonal" = 3)
	required_reagents = list("acetone" = 1, "diethylamine" = 1, "sulfur" = 1)

/datum/chemical_reaction/lipolicide
	id = "lipolicide"
	results = list("lipolicide" = 3)
	required_reagents = list("mercury" = 1, "diethylamine" = 1, "ephedrine" = 1)

/datum/chemical_reaction/mutagen
	id = "mutagen"
	results = list("mutagen" = 3)
	required_reagents = list("radium" = 1, "phosphorus" = 1, "chlorine" = 1)

/datum/chemical_reaction/lexorin
	id = "lexorin"
	results = list("lexorin" = 3)
	required_reagents = list("plasma" = 1, "hydrogen" = 1, "nitrogen" = 1)

/datum/chemical_reaction/chloralhydrate
	id = "chloralhydrate"
	results = list("chloralhydrate" = 1)
	required_reagents = list("ethanol" = 1, "chlorine" = 3, "water" = 1)

/datum/chemical_reaction/mutetoxin //i'll just fit this in here snugly between other unfun chemicals :v
	id = "mutetoxin"
	results = list("mutetoxin" = 2)
	required_reagents = list("uranium" = 2, "water" = 1, "carbon" = 1)

/datum/chemical_reaction/zombiepowder
	id = "zombiepowder"
	results = list("zombiepowder" = 2)
	required_reagents = list("carpotoxin" = 5, "morphine" = 5, "copper" = 5)

/datum/chemical_reaction/mindbreaker
	id = "mindbreaker"
	results = list("mindbreaker" = 5)
	required_reagents = list("silicon" = 1, "hydrogen" = 1, "charcoal" = 1)

/datum/chemical_reaction/teslium
	id = "teslium"
	results = list("teslium" = 3)
	required_reagents = list("plasma" = 1, "silver" = 1, "blackpowder" = 1)
	mix_message = "<span class='danger'>A jet of sparks flies from the mixture as it merges into a flickering slurry.</span>"
	required_temp = 400

/datum/chemical_reaction/teslium/react(datum/reagents/holder)
	simple_react(holder, mix_message = "<span class='danger'>A jet of sparks flies from the mixture as it merges into a flickering slurry.</span>")

/datum/chemical_reaction/heparin
	id = "Heparin"
	results = list("heparin" = 4)
	required_reagents = list("formaldehyde" = 1, "sodium" = 1, "chlorine" = 1, "lithium" = 1)
	mix_message = "<span class='danger'>The mixture thins and loses all color.</span>"

/datum/chemical_reaction/heparin/react(datum/reagents/holder)
	simple_react(holder, mix_message = "<span class='danger'>The mixture thins and loses all color.</span>")
