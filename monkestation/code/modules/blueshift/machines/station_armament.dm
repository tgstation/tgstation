/**
 * Armament Station
 *
 * These are the stations designed to be used by players to outfit themselves.
 * They are a container for the armament component, which must be supplied with a type path of armament entries, and optionally a list of required accesses to use the vendor.
 *
 * If you plan on making your own station, it is strongly recommended you use your own armament entries for whatever it is you're doing.
 *
 * Never directly edit an armament entry as this will be carried through all other vendors.
 *
 * @author Gandalf2k15
 */
/obj/machinery/armament_station
	name = "Armament Outfitting Station"
	desc = "A versatile station for equipping your weapons."
	icon = 'icons/obj/vending.dmi'
	icon_state = "liberationstation"
	density = TRUE
	/// The armament entry type path that will fill the armament station's list.
	var/armament_type
	/// The access needed to use the vendor
	var/list/required_access = list(ACCESS_SYNDICATE)

/obj/machinery/armament_station/Initialize(mapload)
	. = ..()
	if(!armament_type)
		return
	AddComponent(/datum/component/armament, subtypesof(armament_type), required_access)


/**
 * Armament points card
 *
 * To be used with the armaments vendor.
 */
/obj/item/armament_points_card
	name = "armament points card"
	desc = "A points card that can be used at an Armaments Station or Armaments Dealer."
	icon = 'monkestation/code/modules/blueshift/icons/armaments.dmi'
	icon_state = "armament_card"
	w_class = WEIGHT_CLASS_TINY
	/// How many points does this card have to use at the vendor?
	var/points = 10

/obj/item/armament_points_card/Initialize(mapload)
	. = ..()
	maptext = span_maptext("<div align='center' valign='middle' style='position:relative'>[points]</div>")

/obj/item/armament_points_card/examine(mob/user)
	. = ..()
	. += span_notice("It has [points] points left.")

/obj/item/armament_points_card/proc/use_points(points_to_use)
	if(points_to_use > points)
		return FALSE

	points -= points_to_use

	update_maptext()

	return TRUE

/obj/item/armament_points_card/proc/update_maptext()
	maptext = span_maptext("<div align='center' valign='middle' style='position:relative'>[points]</div>")

/obj/item/armament_points_card/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(istype(attacking_item, /obj/item/armament_points_card))
		var/obj/item/armament_points_card/attacking_card = attacking_item
		if(!attacking_card.points)
			to_chat(user, span_warning("No points left on [attacking_card]!"))
			return
		var/points_to_transfer = clamp(tgui_input_number(user, "How many points do you want to transfer?", "Transfer Points", 1, attacking_card.points, 1), 0, attacking_card.points)

		if(!points_to_transfer)
			return

		if(attacking_card.loc != user) // Preventing exploits.
			return

		if(attacking_card.use_points(points_to_transfer))
			points += points_to_transfer
			update_maptext()
			to_chat(user, span_notice("You transfer [points_to_transfer] onto [src]!"))
