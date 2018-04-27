

/datum/unit_test/reagent_id_typos

/datum/unit_test/reagent_id_typos/Run()
	for(var/I in SSreagents.reactions_by_reagent_id)
		for(var/V in SSreagents.reactions_by_reagent_id[I])
			var/datum/chemical_reaction/R = V
			for(var/id in (R.required_reagents + R.required_catalysts))
				if(!SSreagents.reagents_by_id[id])
					Fail("Unknown chemical id \"[id]\" in recipe [R.type]")
