//Canister Frames
/obj/structure/canister_frame
	name = "canister frame"
	icon = 'icons/obj/atmos.dmi'
	icon_state = "frame_0"
	density = TRUE

/obj/structure/canister_frame/examine(user)
	. = ..()

/obj/structure/canister_frame/machine
	name = "canister frame"
	desc = "A frame used to build different kinds of canisters."

	/// The previous canister frame tier path
	var/obj/structure/canister_frame/machine/prev_tier
	/// The next canister frame tier path
	var/obj/structure/canister_frame/machine/next_tier
	/// The required item for going to next tier. Must be set if next_tier is set.
	var/obj/item/stack/next_tier_reqitem
	/// The amount of items required in the stack of the required item. Must be set if next_tier is set.
	var/next_tier_reqitem_am
	/// The finished usable canister path
	var/atom/finished_obj

/obj/structure/canister_frame/machine/deconstruct(disassembled = TRUE)
	if (!(flags_1 & NODECONSTRUCT_1))
		// Spawn 5 sheets for the tier 0 frame
		new /obj/item/stack/sheet/iron(loc, 5)

		// Loop backwards in the tiers and spawn the requirement for each tier
		var/obj/structure/canister_frame/machine/i_prev = prev_tier
		while(ispath(i_prev))
			var/obj/item/stack/prev_tier_reqitem = initial(i_prev.next_tier_reqitem)
			var/prev_tier_reqitem_am = initial(i_prev.next_tier_reqitem_am)
			new prev_tier_reqitem(loc, prev_tier_reqitem_am)
			i_prev = initial(i_prev.prev_tier)
	qdel(src)

/obj/structure/canister_frame/machine/frame_tier_0
	name = "tier 0 canister frame"
	icon_state = "frame_0"

	next_tier = /obj/structure/canister_frame/machine/frame_tier_1
	next_tier_reqitem = /obj/item/stack/sheet/iron
	next_tier_reqitem_am = 5

/obj/structure/canister_frame/machine/frame_tier_1
	name = "tier 1 canister frame"
	icon_state = "frame_1"

	prev_tier = /obj/structure/canister_frame/machine/frame_tier_0
	next_tier = /obj/structure/canister_frame/machine/frame_tier_2
	next_tier_reqitem = /obj/item/stack/sheet/plasteel
	next_tier_reqitem_am = 5
	finished_obj = /obj/machinery/portable_atmospherics/canister/tier_1

/obj/structure/canister_frame/machine/frame_tier_2
	name = "tier 2 canister frame"
	icon_state = "frame_2"

	prev_tier = /obj/structure/canister_frame/machine/frame_tier_1
	next_tier = /obj/structure/canister_frame/machine/frame_tier_3
	next_tier_reqitem = /obj/item/stack/sheet/bluespace_crystal
	next_tier_reqitem_am = 1
	finished_obj = /obj/machinery/portable_atmospherics/canister/tier_2

/obj/structure/canister_frame/machine/frame_tier_3
	name = "tier 3 canister frame"
	icon_state = "frame_3"

	prev_tier = /obj/structure/canister_frame/machine/frame_tier_2
	finished_obj = /obj/machinery/portable_atmospherics/canister/tier_3

/obj/structure/canister_frame/machine/examine(user)
	. = ..()
	. += "<span class='notice'>It can be dismantled by removing the <b>bolts</b>.</span>"

	if(ispath(next_tier))
		var/item_name = initial(next_tier_reqitem.singular_name)
		if(!item_name)
			item_name = initial(next_tier_reqitem.name)
		if(next_tier_reqitem_am > 1)
			. += "<span class='notice'>It can be improved using [next_tier_reqitem_am] [item_name]\s.</span>"
		else
			. += "<span class='notice'>It can be improved using \a [item_name].</span>"

	if(ispath(finished_obj))
		. += "<span class='notice'>It can be finished off by <b>screwing</b> it together.</span>"

/obj/structure/canister_frame/machine/attackby(obj/item/S, mob/user, params)
	if (ispath(next_tier) && istype(S, next_tier_reqitem))
		var/obj/item/stack/ST = S
		var/reqitem_name = ST.singular_name ? ST.singular_name : ST.name
		to_chat(user, "<span class='notice'>You start adding [next_tier_reqitem_am] [reqitem_name]\s to the frame...</span>")
		if (ST.use_tool(src, user, 2 SECONDS, amount=next_tier_reqitem_am, volume=50))
			to_chat(user, "<span class='notice'>You added [next_tier_reqitem_am] [reqitem_name]\s to the frame, turning it into \a [initial(next_tier.name)].</span>")
			new next_tier(drop_location())
			qdel(src)
		return
	return ..()

/obj/structure/canister_frame/machine/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(..())
		return
	if(ispath(finished_obj))
		to_chat(user, "<span class='notice'>You start tightening the screws on \the [src].</span>")
		if (I.use_tool(src, user, 2 SECONDS, volume=50))
			to_chat(user, "<span class='notice'>You tighten the last screws on \the [src].</span>")
			new finished_obj(drop_location())
			qdel(src)
		return
	return FALSE

/obj/structure/canister_frame/machine/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(..())
		return
	to_chat(user, "<span class='notice'>You start to dismantle \the [src]...</span>")
	if (I.use_tool(src, user, 2 SECONDS, volume=50))
		to_chat(user, "<span class='notice'>You dismantle \the [src].</span>")
		deconstruct()
