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

/obj/item/graft/examine(mob/user)
	. = ..()
	if(user.stat == DEAD)
		var/text = "[span_info("*---------*")]\n<span class='info'>- Plant Graft -\n"
		if(parent_name)
			text += "- Parent Plant: [span_notice("[parent_name]")] -\n"
		if(stored_trait)
			text += "- Graftable Traits: [span_notice("[stored_trait.get_name()]")] -\n"
		text += "*---------*\n"
		text += "- Yield: [span_notice("[yield]")]\n"
		text += "- Production speed: [span_notice("[production]")]\n"
		text += "- Endurance: [span_notice("[endurance]")]\n"
		text += "- Lifespan: [span_notice("[lifespan]")]\n"
		text += "- Weed Growth Rate: [span_notice("[weed_rate]")]\n"
		text += "- Weed Vulnerability: [span_notice("[weed_chance]")]\n"
		text += "*---------*</span>"
		. += text
