/datum/wiki_template/botany/proc/generate_output(datum/hydroponics/plant_mutation/mutation)
	var/datum/hydroponics/plant_mutation/generated_mutation = new mutation

	var/name_string = capitalize(initial(generated_mutation.created_product.name))
	var/mutates_from_string = ""
	for(var/obj/item/seeds/any_seed as anything in generated_mutation.mutates_from)
		mutates_from_string += "!\[wrench.png\](/wrench.png)\[[initial(any_seed.plantname)]\](https://wiki.monkestation.com/en/jobs/service/botanist#[initial(any_seed.species)])"

	var/generated_requirements = ""
	if(length(generated_mutation.required_potency))
		generated_requirements += "**Required Potency:** [generated_mutation.required_potency[1]] - [generated_mutation.required_potency[2]]<br>"

	if(length(generated_mutation.required_yield))
		generated_requirements += "**Required Yield:** [generated_mutation.required_yield[1]] - [generated_mutation.required_yield[2]]<br>"

	if(length(generated_mutation.required_production))
		generated_requirements += "**Required Production:** [generated_mutation.required_production[1]] - [generated_mutation.required_production[2]]<br>"

	if(length(generated_mutation.required_endurance))
		generated_requirements += "**Required Endurance:** [generated_mutation.required_endurance[1]] - [generated_mutation.required_endurance[2]]<br>"

	if(length(generated_mutation.required_lifespan))
		generated_requirements += "**Required Lifespan:** [generated_mutation.required_lifespan[1]] - [generated_mutation.required_lifespan[2]]<br>"

	var/created_template = "## [name_string] \n"
	created_template += "| --- | --- | --- | \n"
	created_template += "<a name=\"[initial(generated_mutation.created_seed.species)]\"></a><td rowspan=2 width = 300px height=150px> <center> <img src =\"/wrench.png\" width = 96 height = 96> <br>[name_string] <td width=225> <center> Mutates From <td width=450> <center>Mutates Into | \n"
	created_template += "| | [mutates_from_string] |None \n"
	created_template += " <td colspan=2> <center> Food Information | <center> Mutation Requirements | \n"
	created_template += " | | <center> Base Chemicals  | <center> Traits <td rowspan = 2 colspan=1> [generated_requirements] \n"
	created_template += "| | !\[wrench.png\](/wrench.png) TBA| !\[wrench.png\](/wrench.png) TBA|"

	return created_template
