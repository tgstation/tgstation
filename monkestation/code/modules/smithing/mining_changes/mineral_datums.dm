//this is our base mineral sample we grab this, then using weights from here we create material stats and then bash names together a few times
/datum/mineral_sample_datum
	var/name = "???"
	var/list/base_traits = list()
	var/weight = 10
	var/icon_state = "mauxite"

/datum/mineral_sample_datum/miraclium
	name = "miraclium"
	base_traits = list(/datum/material_trait/rainbow)
	weight = 4
	icon_state = "miracle"

/datum/mineral_sample_datum/gorp
	name = "gorp"
	icon_state = "uqil"

/datum/mineral_sample_datum/glippy
	name = "glippy"
	icon_state = "martian"

/datum/mineral_sample_datum/starstone
	name = "starstone"
	base_traits = list(
		/datum/material_trait/chemical_injector,
		/datum.material_trait/weak_weapon,
		/datum/material_trait/stamina_draining
	)
	weight = 1
	icon_state = "starstone"

/datum/mineral_sample_datum/sploop
	name = "sploop"
	icon_state = "fibrilith"

/datum/mineral_sample_datum/bingus
	name = "bingus"
	icon_state = "cobryl"

/datum/mineral_sample_datum/scarium
	name = "scarium"
	/*
	base_traits = list(
		/datum/material_trait/haunted,
		/datum/material_trait/possessive,
	)
	*/
	weight = 3
	icon_state = "bohrum"
