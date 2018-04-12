/datum/chemical_reaction/slime/slimelizard //Hopefully this overrides the mutation toxin that comes out of the green slimes
	name = "Unstable Mutation Toxin"
	id = "unstablemuttoxin"
	results = list("unstablemutationtoxin" = 1)
	required_reagents = list("radium" = 1)
	required_other = 1
	required_container = /obj/item/slime_extract/green