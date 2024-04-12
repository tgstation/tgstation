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
	greyscale_colors = "#21211f"

/obj/item/clothing/gloves/boxing/golden
	name = "golden gloves"
	desc = "The reigning champ of the station!"
	greyscale_colors = "#E6BB45"
	equip_delay_other = 120

/obj/item/clothing/gloves/boxing/golden/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/skill_reward, /datum/skill/athletics)
