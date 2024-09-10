/obj/item/weaponcrafting/silkstring
	name = "string"
	desc = "A long piece of string that looks like a cable coil."
	icon = 'modular_doppler/hearthkin/tribal_extended/icons/crafting.dmi'
	icon_state = "silkstring"

/obj/item/dice/d6/bone
	name = "bone die"
	desc = "A die carved from a creature's bone. Dried blood marks the indented pits."
	icon = 'modular_doppler/hearthkin/tribal_extended/icons/dice.dmi'
	icon_state = "db6"
	microwave_riggable = FALSE // You can't melt bone in the microwave

/obj/item/reagent_containers/cup/bowl/wood_bowl
	name = "wooden bowl"
	desc = "A bowl made out of wood. Primitive, but effective."
	icon = 'modular_doppler/hearthkin/tribal_extended/icons/crafting.dmi'
	icon_state = "wood_bowl"
	fill_icon_state = "fullbowl"
	fill_icon = 'icons/obj/mining_zones/ash_flora.dmi'

/obj/item/reagent_containers/cup/bowl/mushroom_bowl/update_icon_state()
	if(!reagents.total_volume)
		icon_state = "wood_bowl"
	return ..()
