/datum/chemical_reaction/cryogenic_fluid
	name = "cryogenic_fluid"
	id = "cryogenic_fluid"
	results = list("cryogenic_fluid" = 4)
	required_reagents = list("cryostylane" = 2, "lube" = 1, "pyrosium" = 2) //kinda difficult
	required_catalysts = list("plasma" = 1)
	required_temp = 100
	is_cold_recipe = TRUE
	mob_react = FALSE
	mix_message = "<span class='danger'>In a sudden explosion of vapour, the container begins to rapidly freeze and a frothing fluid begins to creep up the edges!</span>"

/datum/chemical_reaction/cryogenic_fluid/on_reaction(datum/reagents/holder, created_volume)
	holder.chem_temp = 0 // cools the fuck down
	return