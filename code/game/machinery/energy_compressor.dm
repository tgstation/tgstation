/obj/machinery/compressor
	name = "Energy Compressor"
	desc = "Turns controlled explosion energy into usable form."
	density = 1
	anchored = 1
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "furnace"
	var/exploding = FALSE //prevents secondary explosions

/obj/machinery/compressor/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.physical_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "compressor", name, 400, 305, master_ui, state)
		ui.open()

/obj/machinery/compressor/ui_act(action,params)
	if(..())
		return
	switch(action)
		if("eject")
			dropContents()
			. = TRUE

/obj/machinery/compressor/ui_data()
	var/list/data = list()
	data["items"] = list()
	for(var/obj/item/I in src)
		data["items"] += I.name
	data["emagged"] = emagged
	return data

/obj/machinery/compressor/attackby(obj/item/I, mob/user, params)
	if(user.a_intent != INTENT_HARM)
		if(!user.transferItemToLoc(I, src))
			to_chat(user, "<span class='warning'>\the [I] is stuck to your hand, you cannot put it in \the [src]!</span>")
			return
	else
		return ..()

/obj/machinery/compressor/handle_explosion(atom/source, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog = TRUE, ignorecap = FALSE, flame_range = 0 , silent = FALSE, smoke = FALSE, target_turf = null)
	if(emagged)//just a prank
		return FALSE
	if(exploding)
		return TRUE // secondary explosions are ignored
	var/internal_explosion_force = 3
	if(devastation_range)
		internal_explosion_force = 1
	else if(heavy_impact_range)
		internal_explosion_force = 2
	
	exploding = TRUE
	for(var/obj/item/I in src)
		if(I == source)
			continue
		I.ex_act(internal_explosion_force)
	exploding = FALSE
	
	if(devastation_range > 0)
		var/obj/item/fusion_cell/F = new(get_turf(src))
		F.rating = devastation_range
		say("Energy isolated: [devastation_range]/[heavy_impact_range]/[light_impact_range]")
	
	playsound(src,"explosion",100,1)
	Shake(pixelshiftx = 5,pixelshifty = 5,duration=50)
	return TRUE 

/obj/machinery/compressor/emag_act(mob/user)
	if(emagged)
		return
	emagged = TRUE
	to_chat(user, "<span class='notice'>You disable [src] safeties.</span>")

/obj/item/fusion_cell
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "fusion"
	name = "fusion cell"
	desc = "Industrial grade battery used to jumpstart fusion process."
	var/rating = 1

/obj/item/fusion_cell/examine(user)
	..()
	to_chat(user,"Has engraved [rating] at the bottom.")