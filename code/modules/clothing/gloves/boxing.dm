/obj/item/clothing/gloves/boxing
	name = "boxing gloves"
	desc = "Because you really needed another excuse to punch your crewmates."
	icon_state = "boxing"
	greyscale_colors = "#f32110"
	equip_delay_other = 60
	species_exception = list(/datum/species/golem) // now you too can be a golem boxing champion
	clothing_traits = list(TRAIT_CHUNKYFINGERS)

/obj/item/clothing/gloves/boxing/green
	icon_state = "boxinggreen"
	greyscale_colors = "#00a500"

/obj/item/clothing/gloves/boxing/blue
	icon_state = "boxingblue"
	greyscale_colors = "#0074fa"

/obj/item/clothing/gloves/boxing/yellow
	icon_state = "boxingyellow"
	greyscale_colors = "#d2a800"

/obj/item/clothing/gloves/boxing/evil
	name = "evil boxing gloves"
	desc = "These strange gloves radiate an unsually evil aura."
	greyscale_colors = "#21211f"

/obj/item/clothing/gloves/boxing/golden
	name = "golden gloves"
	desc = "The reigning champ of the station!"
	icon_state = "boxinggreyscale"
	greyscale_config = /datum/greyscale_config/golden_gloves
	greyscale_config_worn = /datum/greyscale_config/golden_gloves__worn
	custom_materials = list(/datum/material/gold = SHEET_MATERIAL_AMOUNT*1)  //LITERALLY GOLD
	material_flags = MATERIAL_EFFECTS | MATERIAL_GREYSCALE | MATERIAL_AFFECT_STATISTICS //Makes our gloves inherit the golden color
	equip_delay_other = 120
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE

/obj/item/clothing/gloves/boxing/golden/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/skill_reward, /datum/skill/athletics)
