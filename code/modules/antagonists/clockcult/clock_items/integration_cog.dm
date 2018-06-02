#define COG_MAX_SIPHON_THRESHOLD 0.25 //The cog will not siphon power if the APC's cell is at this % of power

//Can be used on an open APC to replace its guts with clockwork variants, and begin passively siphoning power from it
/obj/item/clockwork/integration_cog
	name = "integration cog"
	desc = "A small cogwheel that fits in the palm of your hand."
	clockwork_desc = "A small cogwheel that can be inserted into an open APC to siphon power from it passively.<br>\
	<span class='brass'>It can be used on a locked APC to open its cover!</span><br>\
	<span class='brass'>Siphons <b>5 W</b> of power per second while in an APC.</span>"
	icon_state = "wall_gear"
	w_class = WEIGHT_CLASS_TINY
	item_flags = NOBLUDGEON
	var/obj/machinery/power/apc/apc

/obj/item/clockwork/integration_cog/Initialize()
	. = ..()
	transform *= 0.5 //little cog!

/obj/item/clockwork/integration_cog/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()

/obj/item/clockwork/integration_cog/process()
	if(!apc)
		if(istype(loc, /obj/machinery/power/apc))
			apc = loc
		else
			STOP_PROCESSING(SSfastprocess, src)
	else
		var/obj/item/stock_parts/cell/cell = apc.cell
		if(cell && (cell.charge / cell.maxcharge > COG_MAX_SIPHON_THRESHOLD))
			cell.use(1)
			adjust_clockwork_power(2) //Power is shared, so only do it once; this runs very quickly so it's about 10 W/second
		else
			adjust_clockwork_power(1) //Continue generating power when the cell has run dry; 5 W/second

#undef COG_MAX_SIPHON_THRESHOLD
