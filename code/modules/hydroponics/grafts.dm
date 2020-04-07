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
	icon_state = pick(
		10 ; "graft_plant" , \
		5 ; "graft_flower" , \
		4 ; "graft_mushroom" , \
		1 ; "graft_doom" )

/obj/item/graft/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/plant_analyzer) && user.a_intent == INTENT_HELP)
		to_chat(user, get_graft_text())
	return ..()

/*
Adds text to the plant analyzer which describes the graft's parent plant and any stored trait it has, if any.
*/
/obj/item/graft/proc/get_graft_text()
	var/text = "- Plant Graft -\n"
	if(parent_seed)
		text += "- Parent Plant Name:[parent_seed.plantname] -\n"
	if(stored_trait)
		text += "- Graftable Traits:[stored_trait.get_name()] -\n"
	return text
