/datum/chemical_reaction/aluminiumf
	name = "Aluminium fluorate"
	id = "aluminiumf"
	results = list("aluminiumf" = 4, "goop" = 2)
	required_reagents = list("carbonf" = 2, "oxygen" = 2,"aluminium" = 2)
	required_temp = 230
	pressure_required = 25
	is_cold_recipe = TRUE

/datum/chemical_reaction/sodiumf
	name = "Sodium fluoride"
	id = "sodiumf"
	results = list("sodiumf" = 4, "goop" = 3)
	required_reagents = list("carbonf" = 2, "sodium" = 4)
	required_temp = 470

/datum/chemical_reaction/virogone
	name = "Cyclo-bromazine"
	id = "virogone"
	results = list("virogone" = 2, "mutagen" = 2)
	required_reagents = list("aluminiumf" = 2, "sodiumf" = 3)
	pressure_required = 76

/datum/chemical_reaction/over_reactible/superzine//no longer requires heat due to annoying meth explosions
	name = "Superzine"
	id = "superzine"
	results = list("superzine" = 6, "dizinc" = 2)
	required_catalysts = list("mutagen" = 5)
	required_reagents = list("methamphetamine" = 2, "hexamine" = 2,"virogone" = 2)
	pressure_required = 78
	can_overpressure = TRUE
	overpressure_threshold = 90

/datum/chemical_reaction/defib
	name = "Exstatic mixture"
	id = "defib"
	results = list("defib" = 4, "radgoop" = 4)
	required_reagents = list("sparky" = 2, "carbonf" = 2,"virogone" = 2)
	pressure_required = 70

/datum/chemical_reaction/liquid_life
	name = "Liquid life"
	id = "liquid_life"
	results = list("liquid_life" = 3, "methpos" = 2)
	required_reagents = list("superzine" = 1, "virogone" = 1,"defib" = 1)
	bluespace_recipe = TRUE

/datum/chemical_reaction/kelotane
	name = "Kelotane"
	id = "kelotane"
	results = list("kelotane" = 3)
	required_reagents = list("carbon" = 1, "silicon" = 1)