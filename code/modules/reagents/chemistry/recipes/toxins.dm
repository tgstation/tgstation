
/datum/chemical_reaction/formaldehyde
	name = /datum/reagent/toxin/formaldehyde
	id = "Formaldehyde"
	results = list(/datum/reagent/toxin/formaldehyde = 3)
	required_reagents = list("ethanol" = 1, "oxygen" = 1, "silver" = 1)
	required_temp = 420

/datum/chemical_reaction/fentanyl
	name = /datum/reagent/toxin/fentanyl
	id = /datum/reagent/toxin/fentanyl
	results = list(/datum/reagent/toxin/fentanyl = 1)
	required_reagents = list("space_drugs" = 1)
	required_temp = 674

/datum/chemical_reaction/cyanide
	name = "Cyanide"
	id = /datum/reagent/toxin/cyanide
	results = list(/datum/reagent/toxin/cyanide = 3)
	required_reagents = list("oil" = 1, "ammonia" = 1, "oxygen" = 1)
	required_temp = 380

/datum/chemical_reaction/itching_powder
	name = "Itching Powder"
	id = /datum/reagent/toxin/itching_powder
	results = list(/datum/reagent/toxin/itching_powder = 3)
	required_reagents = list("welding_fuel" = 1, "ammonia" = 1, "charcoal" = 1)

/datum/chemical_reaction/facid
	name = "Fluorosulfuric acid"
	id = /datum/reagent/toxin/acid/fluacid
	results = list(/datum/reagent/toxin/acid/fluacid = 4)
	required_reagents = list(/datum/reagent/toxin/acid = 1, "fluorine" = 1, "hydrogen" = 1, "potassium" = 1)
	required_temp = 380

/datum/chemical_reaction/sulfonal
	name = /datum/reagent/toxin/sulfonal
	id = /datum/reagent/toxin/sulfonal
	results = list(/datum/reagent/toxin/sulfonal = 3)
	required_reagents = list("acetone" = 1, "diethylamine" = 1, "sulfur" = 1)

/datum/chemical_reaction/lipolicide
	name = /datum/reagent/toxin/lipolicide
	id = /datum/reagent/toxin/lipolicide
	results = list(/datum/reagent/toxin/lipolicide = 3)
	required_reagents = list("mercury" = 1, "diethylamine" = 1, "ephedrine" = 1)

/datum/chemical_reaction/mutagen
	name = "Unstable mutagen"
	id = /datum/reagent/toxin/mutagen
	results = list(/datum/reagent/toxin/mutagen = 3)
	required_reagents = list("radium" = 1, "phosphorus" = 1, "chlorine" = 1)

/datum/chemical_reaction/lexorin
	name = "Lexorin"
	id = /datum/reagent/toxin/lexorin
	results = list(/datum/reagent/toxin/lexorin = 3)
	required_reagents = list("plasma" = 1, "hydrogen" = 1, "oxygen" = 1)

/datum/chemical_reaction/chloralhydrate
	name = "Chloral Hydrate"
	id = /datum/reagent/toxin/chloralhydrate
	results = list(/datum/reagent/toxin/chloralhydrate = 1)
	required_reagents = list("ethanol" = 1, "chlorine" = 3, "water" = 1)

/datum/chemical_reaction/mutetoxin //i'll just fit this in here snugly between other unfun chemicals :v
	name = "Mute Toxin"
	id = /datum/reagent/toxin/mutetoxin
	results = list(/datum/reagent/toxin/mutetoxin = 2)
	required_reagents = list("uranium" = 2, "water" = 1, "carbon" = 1)

/datum/chemical_reaction/zombiepowder
	name = "Zombie Powder"
	id = /datum/reagent/toxin/zombiepowder
	results = list(/datum/reagent/toxin/zombiepowder = 2)
	required_reagents = list(/datum/reagent/toxin/carpotoxin = 5, "morphine" = 5, "copper" = 5)

/datum/chemical_reaction/ghoulpowder
	name = "Ghoul Powder"
	id = /datum/reagent/toxin/ghoulpowder
	results = list(/datum/reagent/toxin/ghoulpowder = 2)
	required_reagents = list(/datum/reagent/toxin/zombiepowder = 1, "epinephrine" = 1)

/datum/chemical_reaction/mindbreaker
	name = "Mindbreaker Toxin"
	id = /datum/reagent/toxin/mindbreaker
	results = list(/datum/reagent/toxin/mindbreaker = 5)
	required_reagents = list("silicon" = 1, "hydrogen" = 1, "charcoal" = 1)

/datum/chemical_reaction/heparin
	name = "Heparin"
	id = "Heparin"
	results = list(/datum/reagent/toxin/heparin = 4)
	required_reagents = list(/datum/reagent/toxin/formaldehyde = 1, "sodium" = 1, "chlorine" = 1, "lithium" = 1)
	mix_message = "<span class='danger'>The mixture thins and loses all color.</span>"

/datum/chemical_reaction/rotatium
	name = "Rotatium"
	id = "Rotatium"
	results = list(/datum/reagent/toxin/rotatium = 3)
	required_reagents = list(/datum/reagent/toxin/mindbreaker = 1, "teslium" = 1, /datum/reagent/toxin/fentanyl = 1)
	mix_message = "<span class='danger'>After sparks, fire, and the smell of mindbreaker, the mix is constantly spinning with no stop in sight.</span>"

/datum/chemical_reaction/skewium
	name = "Skewium"
	id = "Skewium"
	results = list(/datum/reagent/toxin/skewium = 5)
	required_reagents = list(/datum/reagent/toxin/rotatium = 2, "plasma" = 2, /datum/reagent/toxin/acid = 1)
	mix_message = "<span class='danger'>Wow! it turns out if you mix rotatium with some plasma and sulphuric acid, it gets even worse!</span>"

/datum/chemical_reaction/anacea
	name = "Anacea"
	id = /datum/reagent/toxin/anacea
	results = list(/datum/reagent/toxin/anacea = 3)
	required_reagents = list("haloperidol" = 1, "impedrezene" = 1, "radium" = 1)

/datum/chemical_reaction/mimesbane
	name = "Mime's Bane"
	id = /datum/reagent/toxin/mimesbane
	results = list(/datum/reagent/toxin/mimesbane = 3)
	required_reagents = list("radium" = 1, /datum/reagent/toxin/mutetoxin = 1, "nothing" = 1)

/datum/chemical_reaction/bonehurtingjuice
	name = "Bone Hurting Juice"
	id = /datum/reagent/toxin/bonehurtingjuice
	results = list(/datum/reagent/toxin/bonehurtingjuice = 5)
	required_reagents = list(/datum/reagent/toxin/mutagen = 1, /datum/reagent/toxin/itching_powder = 3, "milk" = 1)
	mix_message = "<span class='danger'>The mixture suddenly becomes clear and looks a lot like water. You feel a strong urge to drink it.</span>"
