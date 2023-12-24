/datum/component/artifact/smoke
	associated_object = /obj/structure/artifact/smoke
	weight = ARTIFACT_UNCOMMON
	type_name = "Smoke Machine"
	activation_message = "starts spewing out smoke!"
	deactivation_message = "becomes silent."

	var/list/valid_chemicals = list(
		/datum/reagent/colorful_reagent,
		/datum/reagent/colorful_reagent/powder/black,
		/datum/reagent/colorful_reagent/powder/blue,
		/datum/reagent/colorful_reagent/powder/purple,
		/datum/reagent/colorful_reagent/powder/orange,
		/datum/reagent/colorful_reagent/powder/red,
		/datum/reagent/colorful_reagent/powder/yellow,
	)
	var/per_chemical_amount	= 5
	var/chemicals_chosen = 2
	var/list/chemicals = list()
	var/smoke_range = 3

/datum/component/artifact/smoke/setup()
	per_chemical_amount = rand(5, 10)
	chemicals_chosen = rand(1, 5)
	smoke_range = rand(1, 5)
	potency += per_chemical_amount * 3 + chemicals_chosen * 3 + smoke_range * 2

	for(var/i = 1 to chemicals_chosen)
		chemicals += pick(valid_chemicals)

/datum/component/artifact/smoke/effect_activate(silent)
	for(var/chemical in chemicals)
		do_chem_smoke(smoke_range, holder = holder, location = get_turf(holder), reagent_type = chemical, reagent_volume = per_chemical_amount, log = TRUE)
	artifact_deactivate()

/datum/component/artifact/smoke/toxin
	associated_object = /obj/structure/artifact/smoke/toxin
	weight = ARTIFACT_RARE
	activation_message = "starts spewing out toxic smoke!"
	valid_chemicals = list(
		/datum/reagent/toxin/bonehurtingjuice,
		/datum/reagent/toxin/itching_powder,
		/datum/reagent/toxin/mindbreaker,
		/datum/reagent/toxin/spewium,
	)

/datum/component/artifact/smoke/flesh
	associated_object = /obj/structure/artifact/smoke/flesh
	weight = ARTIFACT_RARE
	activation_message = "starts spewing out flesh mending smoke!"
	valid_chemicals = list(
		/datum/reagent/medicine/c2/synthflesh
	)

/datum/component/artifact/smoke/exotic
	associated_object = /obj/structure/artifact/smoke/exotic
	weight = ARTIFACT_RARE
	activation_message = "starts spewing out exotic smoke!"
	valid_chemicals = list(
		/datum/reagent/wittel,
		/datum/reagent/medicine/omnizine/protozine,
		/datum/reagent/water/hollowwater,
		/datum/reagent/plasma_oxide,
		/datum/reagent/australium,
		/datum/reagent/shakeium,
	)
