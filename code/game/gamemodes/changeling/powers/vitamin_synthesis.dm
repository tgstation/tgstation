//Vitamin Synthesis: Allows the changeling to shift their vitamin levels at will.
/obj/effect/proc_holder/changeling/vitamins
	name = "Vitamin Synthesis"
	desc = "Allows us to shift our blood nutrient levels at will. Higher vitamin concentrations supplement the body's natural healing ability and allow faster recuperation of conventional wounds."
	helptext = "Malnutrition occurs at -10% vitamin concentration, and hypervitaminitosis at 100% or above."
	chemical_cost = 10
	dna_cost = 0
	req_stat = UNCONSCIOUS
	req_human = TRUE

/obj/effect/proc_holder/changeling/vitamins/sting_action(mob/living/user)
	var/new_vitamin_level = input(user, "What vitamin concentration do we want?", "Vitamin Synthesis", user.vitamins) as null|num
	if(isnull(new_vitamin_level))
		return
	to_chat(user, "<span class='notice'>We [new_vitamin_level < user.vitamins ? "reabsorb excess vitamins from" : "synthesize vitamins into"] our bloodstream.</span>")
	user.vitamins = new_vitamin_level
	user.vitamins = Clamp(user.vitamins, -VITAMIN_CLAMP, VITAMIN_CLAMP)
	return TRUE
