/datum/design/hypovialsmall
	name = "Hypovial"
	id = "hypovial"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 500)
	build_path = /obj/item/reagent_containers/glass/bottle/vial/small
	category = list("initial","Medical","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/hypoviallarge
	name = "Large Hypovial"
	id = "large_hypovial"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 2500)
	build_path = /obj/item/reagent_containers/glass/bottle/vial/large
	category = list("initial","Medical","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
