//*************************
//***Box Pushing Puzzles***
//*************************
//We're working off a subtype of pressureplates, which should work just a BIT better now.
/obj/structure/holobox
	name = "holobox"
	desc = "A hard-light box, containing a secure decryption key."
	icon = 'icons/obj/puzzle_small.dmi'
	icon_state = "laserbox"
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF

//Uses the pressure_plate settings for a pretty basic custom pattern that waits for a specific item to trigger. Easy enough to retool for mapping purposes or subtypes.
/obj/item/pressure_plate/hologrid
	name = "hologrid"
	desc = "A high power, electronic input port for a holobox, which can unlock the hologrid's storage compartment. Safe to stand on."
	icon = 'icons/obj/puzzle_small.dmi'
	icon_state = "lasergrid"
	anchored = TRUE
	trigger_mob = FALSE
	trigger_item = TRUE
	specific_item = /obj/structure/holobox
	removable_signaller = FALSE //Being a pressure plate subtype, this can also use signals.
	roundstart_signaller_freq = FREQ_HOLOGRID_SOLUTION //Frequency is kept on it's own default channel however.
	active = TRUE
	trigger_delay = 10
	protected = TRUE
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	undertile_pressureplate = FALSE
	var/reward = /obj/item/food/cookie
	var/claimed = FALSE

/obj/item/pressure_plate/hologrid/Initialize(mapload)
	. = ..()
	if(undertile_pressureplate)
		AddElement(/datum/element/undertile, tile_overlay = tile_overlay, use_anchor = FALSE) //we remove use_anchor here, so it ALWAYS stays anchored

/obj/item/pressure_plate/hologrid/examine(mob/user)
	. = ..()
	if(claimed)
		. += span_notice("This one appears to be spent already.")

/obj/item/pressure_plate/hologrid/trigger()
	if(!claimed)
		new reward(loc)
	flick("lasergrid_a",src)
	icon_state = "lasergrid_full"
	claimed = TRUE

/obj/item/pressure_plate/hologrid/on_entered(datum/source, atom/movable/AM)
	. = ..()
	if(trigger_item && istype(AM, specific_item) && !claimed)
		AM.set_anchored(TRUE)
		flick("laserbox_burn", AM)
		trigger()
		QDEL_IN(AM, 15)
