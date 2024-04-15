/obj/item/clothing/gloves/boxing
	name = "boxing gloves"
	desc = "Because you really needed another excuse to punch your crewmates."
	icon_state = "boxing"
	greyscale_colors = "#f32110"
	equip_delay_other = 60
	species_exception = list(/datum/species/golem) // now you too can be a golem boxing champion
	clothing_traits = list(TRAIT_CHUNKYFINGERS)
	var/datum/martial_art/boxing/style

/obj/item/clothing/gloves/boxing/Initialize(mapload)
	. = ..()
	var/static/list/slapcraft_recipe_list = list(/datum/crafting_recipe/extendohand_l, /datum/crafting_recipe/extendohand_r)

	AddComponent(
		/datum/component/slapcrafting,\
		slapcraft_recipes = slapcraft_recipe_list,\
	)

	style = new()
	style.allow_temp_override = FALSE

/obj/item/clothing/gloves/boxing/Destroy()
	QDEL_NULL(style)
	return ..()

/obj/item/clothing/gloves/boxing/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_GLOVES)
		style.teach(user, TRUE)

/obj/item/clothing/gloves/boxing/dropped(mob/user)
	. = ..()
	style.fully_remove(user)

/obj/item/clothing/gloves/boxing/evil
	name = "evil boxing gloves"
	desc = "These strange gloves radiate an unsually evil aura."
	greyscale_colors = "#21211f"
	style = /datum/martial_art/boxing/evil

/obj/item/clothing/gloves/boxing/green
	icon_state = "boxinggreen"
	greyscale_colors = "#00a500"

/obj/item/clothing/gloves/boxing/blue
	icon_state = "boxingblue"
	greyscale_colors = "#0074fa"

/obj/item/clothing/gloves/boxing/yellow
	icon_state = "boxingyellow"
	greyscale_colors = "#d2a800"

/obj/item/clothing/gloves/boxing/golden
	name = "golden gloves"
	desc = "The reigning champ of the station!"
	icon_state = "boxinggold"
	custom_materials = list(/datum/material/gold = SHEET_MATERIAL_AMOUNT*1)  //LITERALLY GOLD
	material_flags = MATERIAL_EFFECTS | MATERIAL_AFFECT_STATISTICS
	equip_delay_other = 120
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE

/obj/item/clothing/gloves/boxing/golden/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/skill_reward, /datum/skill/athletics)
