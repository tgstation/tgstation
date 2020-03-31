#define FRAME_TIER_0	"0"
#define FRAME_TIER_1	"1"
#define FRAME_TIER_2	"2"
#define CANISTER_TIER_1					1
#define CANISTER_TIER_2					2
#define CANISTER_TIER_3					3
//Canister Frames
/obj/structure/canister_frame
	name = "frame"
	icon = 'icons/obj/atmos.dmi'
	icon_state = "frame_0"
	density = TRUE
	var/mode_frame = FRAME_TIER_0

/obj/structure/canister_frame/examine(user)
	. = ..()

/obj/structure/canister_frame/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/metal(loc, 5)
	qdel(src)

/obj/structure/canister_frame/machine
	name = "canister frame"
	desc = "A frame to build different kind of canisters"

/obj/structure/canister_frame/machine/examine(user)
	. = ..()
	if(mode_frame)
		. += "A canister frame of tier [mode_frame]"

/obj/structure/canister_frame/machine/update_icon_state()
	if (mode_frame == FRAME_TIER_0)
		icon_state = "frame_0"
	else if (mode_frame == FRAME_TIER_1)
		icon_state = "frame_1"
	else if (mode_frame == FRAME_TIER_2)
		icon_state = "frame_2"

/obj/structure/canister_frame/machine/attackby(obj/item/S, mob/user, params)
	var/is_metal_sheet = istype(S, /obj/item/stack/sheet/metal)
	var/is_plasteel_sheet = istype(S, /obj/item/stack/sheet/plasteel)
	var/is_titanium_sheet = istype(S, /obj/item/stack/sheet/mineral/titanium)
	var/is_bscrystal_sheet = istype(S, /obj/item/stack/sheet/bluespace_crystal)
	var/is_plastitanium_sheet = istype(S, /obj/item/stack/sheet/mineral/plastitanium)
	var/obj/item/stack/ST = S
	if (ST.get_amount() < 5)
		to_chat(user, "<span class='warning'>You need at least five sheets for that!</span>")
		return
	if(is_metal_sheet && mode_frame != FRAME_TIER_1 && mode_frame != FRAME_TIER_2)
		if(do_after(user,15, target = src))
			var/obj/machinery/portable_atmospherics/canister/tier_1 = new /obj/machinery/portable_atmospherics/canister(drop_location())
			if (tier_1.mode != CANISTER_TIER_1)
				tier_1.mode = CANISTER_TIER_1
				tier_1.update_overlays()
			qdel(src)
			ST.use(5)
	else if(is_plasteel_sheet && mode_frame != FRAME_TIER_1 && mode_frame != FRAME_TIER_2)
		if(do_after(user,15, target = src))
			var/obj/structure/canister_frame/machine/frame_1 = new /obj/structure/canister_frame/machine(drop_location())
			if (frame_1.mode_frame != FRAME_TIER_1)
				frame_1.mode_frame = FRAME_TIER_1
				frame_1.update_icon_state()
			qdel(src)
			ST.use(5)
	else if (is_titanium_sheet && mode_frame == FRAME_TIER_1)
		if(do_after(user,15, target = src))
			var/obj/machinery/portable_atmospherics/canister/tier_2 = new /obj/machinery/portable_atmospherics/canister(drop_location())
			if (tier_2.mode != CANISTER_TIER_2)
				tier_2.mode = CANISTER_TIER_2
				tier_2.update_overlays()
			qdel(src)
			ST.use(5)
	else if (is_bscrystal_sheet && mode_frame == FRAME_TIER_1)
		if(do_after(user,15, target = src))
			var/obj/structure/canister_frame/machine/frame_2 = new /obj/structure/canister_frame/machine(drop_location())
			if (frame_2.mode_frame != FRAME_TIER_2)
				frame_2.mode_frame = FRAME_TIER_2
				frame_2.update_icon_state()
			qdel(src)
			ST.use(5)
	else if (is_plastitanium_sheet && mode_frame == FRAME_TIER_2)
		if(do_after(user,15, target = src))
			var/obj/machinery/portable_atmospherics/canister/tier_3 = new /obj/machinery/portable_atmospherics/canister(drop_location())
			if (tier_3.mode != CANISTER_TIER_3)
				tier_3.mode = CANISTER_TIER_3
				tier_3.update_overlays()
			qdel(src)
			ST.use(5)
	else
		to_chat(user, "<span class='warning'>Those are no the right sheets!</span>")
		return
