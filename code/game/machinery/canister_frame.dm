//Canister Frames
/obj/structure/canister_frame
	name = "canister frame"
	icon = 'icons/obj/atmos.dmi'
	icon_state = "frame_0"
	density = TRUE

/obj/structure/canister_frame/examine(user)
	. = ..()

/obj/structure/canister_frame/deconstruct(disassembled = TRUE)
	if (!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/metal(loc, 5)
	qdel(src)

/obj/structure/canister_frame/machine
	name = "canister frame"
	desc = "A frame used to build different kinds of canisters."

/obj/structure/canister_frame/machine/frame_tier_0
	name = "Tier 0 canister frame"
	icon_state = "frame_0"

/obj/structure/canister_frame/machine/frame_tier_1
	name = "Tier 1 canister frame"
	icon_state = "frame_1"


/obj/structure/canister_frame/machine/frame_tier_2
	name = "Tier 2 canister frame"
	icon_state = "frame_2"

/obj/structure/canister_frame/machine/frame_tier_3
	name = "Tier 3 canister frame"
	icon_state = "frame_3"

///Proc to build the different tiers, if the sheet used is right, it will upgrade the frame or build the respective canister tier
/obj/structure/canister_frame/machine/frame_tier_0/attackby(obj/item/S, mob/user, params)
	if (istype(S, /obj/item/stack/sheet/metal))
		var/obj/item/stack/ST = S
		if (ST.get_amount() < 5)
			to_chat(user, "<span class='warning'>You need at least five sheets for that!</span>")
			return
		if(do_after(user, 15, target = src))
			new /obj/structure/canister_frame/machine/frame_tier_1(drop_location())
			qdel(src)
			ST.use(5)
		return
	return ..()

///Proc to build the different tiers, if the sheet used is right, it will upgrade the frame or build the respective canister tier
/obj/structure/canister_frame/machine/frame_tier_1/attackby(obj/item/S, mob/user, params)
	if (istype(S, /obj/item/screwdriver))
		if (do_after(user, 6, target = src))
			new /obj/machinery/portable_atmospherics/canister/tier_1(drop_location())
			qdel(src)
	else if (istype(S, /obj/item/stack/sheet/plasteel))
		var/obj/item/stack/ST = S
		if (ST.get_amount() < 5)
			to_chat(user, "<span class='warning'>You need at least five sheets for that!</span>")
			return
		if (do_after(user, 15, target = src))
			new /obj/structure/canister_frame/machine/frame_tier_2(drop_location())
			qdel(src)
			ST.use(5)
	else
		return ..()

///Proc to build the different tiers, if the sheet used is right, it will upgrade the frame or build the respective canister tier
/obj/structure/canister_frame/machine/frame_tier_2/attackby(obj/item/S, mob/user, params)
	if (istype(S, /obj/item/screwdriver))
		if (do_after(user, 6, target = src))
			new /obj/machinery/portable_atmospherics/canister/tier_2(drop_location())
			qdel(src)
	else if (istype(S, /obj/item/stack/sheet/bluespace_crystal))
		var/obj/item/stack/ST = S
		if (ST.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need at least one bluespace crystal for that!</span>")
			return
		if (do_after(user,15, target = src))
			new /obj/structure/canister_frame/machine/frame_tier_3(drop_location())
			qdel(src)
			ST.use(1)
	else
		return ..()

///Proc to build the different tiers, if the sheet used is right, it will upgrade the frame or build the respective canister tier
/obj/structure/canister_frame/machine/frame_tier_3/attackby(obj/item/S, mob/user, params)
	if (istype(S, /obj/item/screwdriver))
		if (do_after(user, 6, target = src))
			new /obj/machinery/portable_atmospherics/canister/tier_3(drop_location())
			qdel(src)
	else
		return ..()
