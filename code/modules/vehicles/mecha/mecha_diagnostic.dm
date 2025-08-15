/obj/item/mecha_diagnostic
	name = "mecha holodiagnostic"
	desc = "A holographic datasheet of unique data related to the mecha's construction and any production differences between the published designs to increment improvements."
	icon = 'icons/obj/devices/scanner.dmi'
	icon_state = "holosheet"
	w_class = WEIGHT_CLASS_SMALL
	layer = ABOVE_MOB_LAYER
	light_system = OVERLAY_LIGHT
	light_range = 1
	light_power = 2
	light_color = "#79aeeb"
	/// What mech was this diagnostic sheet generated from? Used for applicability in bounties.
	var/obj/vehicle/sealed/mecha/mech_data

/obj/item/mecha_diagnostic/Initialize(mapload)
	. = ..()
	set_light_on(TRUE)

/obj/item/mecha_diagnostic/Destroy(force)
	. = ..()
	mech_data = null

/obj/item/mecha_diagnostic/examine(mob/user)
	. = ..()
	if(mech_data)
		. += "This holodata sheet consists of data from a <b>[initial(mech_data.name)]</b>."
