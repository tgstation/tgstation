/obj/item/reagent_containers/food/drinks/soda_cans/slurm
	name = "Slurm"
	desc = "Is this even safe?"
	icon = 'icons/oldschool/items.dmi'
	icon_state = "slurm"
	list_reagents = list("slurm" = 30)

/datum/reagent/consumable/slurm
	name = "Slurm"
	id = "slurm"
	description = "Slightly radioactive green goop."
	color = "#66ff33"

/datum/reagent/consumable/slurm/on_mob_life(mob/living/M)
	M.Jitter(10)
	if(prob(15))
		M.emote("drool")
	if(current_cycle == 20)
		to_chat(M, "<span class='warning'>You start feeling strange...</span>")
	if(current_cycle > 20)
		M.adjustBrainLoss(0.25)
		M.set_light(max(M.luminosity, 4))
		if(M.color != color)
			M.add_atom_colour(color, TEMPORARY_COLOUR_PRIORITY)
	..()

/datum/reagent/consumable/slurm/on_mob_delete(mob/M)
	M.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, color)
	M.set_light(max(0,M.luminosity - 4))
