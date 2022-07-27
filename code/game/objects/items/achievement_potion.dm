/obj/item/achievement_potion
	name = "midas potion"
	desc = "A potion turning job equipment to gold!"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "achievement_potion"
	custom_materials = list(/datum/material/glass=500, /datum/material/gold=1200)
		///Achievement items.
	var/golden_knife = FALSE
	var/golden_shaker = FALSE
	var/golden_wheelchair = FALSE

/obj/item/achievement_potion/bartender
	name = "bartender's midas potion"
	desc = "A reward for Nanotrasen's most prolific batenders!"
	golden_shaker = TRUE

/obj/item/achievement_potion/cook
	name = "chef's midas potion"
	desc = "A reward for Nanotrasen's most prolific chefs!"
	golden_knife = TRUE

/obj/item/achievement_potion/hardcore
	name = "martyr's midas potion"
	desc = "You must've seen some shit to get a hold of this."
	golden_wheelchair = TRUE
