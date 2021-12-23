/**
 *A new subsystem for hydroponics, as a way to share specific traits into plants, as a way to phase out the DNA manipulator.
 */
/obj/item/graft
	name = "plant graft"
	desc = "A carefully cut graft off of a freshly grown plant. Can be grafted onto a plant in order to share unique plant traits onto a plant."
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "graft_plant"
	worn_icon_state = "graft"
	attack_verb_continuous = list("plants", "vegitizes", "crops", "reaps", "farms")
	attack_verb_simple = list("plant", "vegitize", "crop", "reap", "farm")
	///The stored trait taken from the parent plant. Defaults to perenial growth.
	var/datum/plant_gene/stored_trait
	///Determines the appearance of the graft. Rudimentary right now so it just picks randomly.
	var/graft_appearance
	///Seed that the graft was taken from, used for applying parent stats. Can be unexpectedly nulled by the parent plant getting deleted.
	var/obj/item/seeds/parent_seed = null
	/// The name of the plant this was taken from.
	var/parent_name = ""
	///The lifespan stat of the parent seed when the graft was taken.
	var/lifespan
	///The endurance stat of the parent seed when the graft was taken.
	var/endurance
	///The production stat of the parent seed when the graft was taken.
	var/production
	///The weed_rate stat of the parent seed when the graft was taken.
	var/weed_rate
	///The weed_chance stat of the parent seed when the graft was taken.
	var/weed_chance
	///The yield stat of the parent seed when the graft was taken.
	var/yield


/obj/item/graft/Initialize(mapload, datum/plant_gene/trait/trait_path)
	. = ..()
	//Default gene is repeated harvest.
	if(trait_path)
		stored_trait = new trait_path
	else
		stored_trait = new /datum/plant_gene/trait/repeated_harvest
	icon_state = pick(
		10 ; "graft_plant" , \
		5 ; "graft_flower" , \
		4 ; "graft_mushroom" , \
		1 ; "graft_doom" )

/obj/item/graft/Destroy()
	QDEL_NULL(stored_trait)
	return ..()

/obj/item/graft/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/plant_analyzer) && user.a_intent == INTENT_HELP)
		to_chat(user, get_graft_text())
	return ..()

/**
 *Adds text to the plant analyzer which describes the graft's parent plant and any stored trait it has, if any.
 */
/obj/item/graft/proc/get_graft_text()
	var/text = "- Plant Graft -\n"
	if(parent_name)
		text += "- Parent Plant: [parent_name] -\n"
	if(stored_trait)
		text += "- Graftable Traits: [stored_trait.get_name()] -\n"
	return text
