/*
A new subsystem for hydroponics, as a way to share specific traits into plants, as a way to phase out the DNA manipulator.
*/
/obj/item/graft
	name = "plant graft"
	desc = "A carefully cut graft off of a freshly grown plant. Can be grafted onto a plant in order to share unique plant traits onto a plant."
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "graft_plant"
	attack_verb = list("planted", "vegitized", "cropped", "reaped", "farmed")
	///This stored the trait taken from the parent plant. Defaults to perenial growth.
	var/datum/plant_gene/trait/stored_trait
	///Determines the appearance of the graft. Rudimentary right now so it just picks randomly.
	var/graft_appearance
	///Seed type that the graft was taken from, used for applying parent stats.
	var/obj/item/seeds/parent_seed = null

/obj/item/graft/Initialize()
	. = ..()
	stored_trait = new /datum/plant_gene/trait/repeated_harvest //Default gene is repeated harvest.

	graft_appearance = rand(100)
	if(0 <= graft_appearance < 25)
		icon_state = "graft_plant"
	else if (25 <= graft_appearance < 50)
		icon_state = "graft_flower"
	else if (50 <= graft_appearance <= 95)
		icon_state = "graft_mushroom"
	else
		icon_state = "graft_doom"
