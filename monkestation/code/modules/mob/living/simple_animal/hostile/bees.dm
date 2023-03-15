/mob/living/simple_animal/hostile/poison/bees/friendly
	name = "friendly maintenance bee"
	desc = "Aww, look at this lil fella!"
	response_help  = "hugs"
	attacktext = "nuzzles"
	a_intent = INTENT_HELP
	melee_damage = 0


/mob/living/simple_animal/hostile/poison/bees/friendly/Initialize()
	. = ..()
	var/datum/reagent/R = pick(typesof(/datum/reagent/drug)) //if it's from maint, it's probably drugs
	assign_reagent(GLOB.chemical_reagents_list[R])

/mob/living/simple_animal/hostile/poison/bees/friendly/AttackingTarget() //these guys are too high to do anything, no pollinating
		visible_message("[src] nuzzles \the [target].")
		return TRUE
