/obj/structure/dresser
	name = "dresser"
	desc = "A nicely-crafted wooden dresser. It's filled with lots of undies."
	icon = 'icons/obj/fluff/general.dmi'
	icon_state = "dresser"
	resistance_flags = FLAMMABLE
	density = TRUE
	anchored = TRUE

/obj/structure/dresser/attackby(obj/item/I, mob/user, list/modifiers)
	if(I.tool_behaviour == TOOL_WRENCH)
		to_chat(user, span_notice("You begin to [anchored ? "unwrench" : "wrench"] [src]."))
		if(I.use_tool(src, user, 20, volume=50))
			to_chat(user, span_notice("You successfully [anchored ? "unwrench" : "wrench"] [src]."))
			set_anchored(!anchored)
	else
		return ..()

/obj/structure/dresser/atom_deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/mineral/wood(drop_location(), 10)

/obj/structure/dresser/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!Adjacent(user))//no tele-grooming
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/dressing_human = user
	if(HAS_TRAIT(dressing_human, TRAIT_NO_UNDERWEAR))
		to_chat(dressing_human, span_warning("You are not capable of wearing underwear."))
		return

	var/choice = tgui_input_list(user, "Underwear, Bra, Undershirt or Socks?", "Changing", list("Underwear", "Underwear Color", "Bra", "Bra Color", "Undershirt", "Undershirt Color", "Socks", "Socks Color")) //DOPPLER EDIT ADDITION - Colorable Undershirt/Socks/Bra
	if(isnull(choice))
		return

	if(!Adjacent(user))
		return
	switch(choice)
		if("Underwear")
			var/new_undies = tgui_input_list(user, "Select your underwear", "Changing", SSaccessories.underwear_list)
			if(new_undies)
				dressing_human.underwear = new_undies
		if("Underwear Color")
			var/new_underwear_color = input(dressing_human, "Choose your underwear color", "Underwear Color", dressing_human.underwear_color) as color|null
			if(new_underwear_color)
				dressing_human.underwear_color = sanitize_hexcolor(new_underwear_color)
		if("Undershirt")
			var/new_undershirt = tgui_input_list(user, "Select your undershirt", "Changing", SSaccessories.undershirt_list)
			if(new_undershirt)
				dressing_human.undershirt = new_undershirt
		if("Socks")
			var/new_socks = tgui_input_list(user, "Select your socks", "Changing", SSaccessories.socks_list)
			if(new_socks)
				dressing_human.socks = new_socks
		//DOPPLER EDIT ADDITION BEGIN - Colorable Undershirt/Socks/Bras
		if("Undershirt Color")
			var/new_undershirt_color = input(dressing_human, "Choose your undershirt color", "Undershirt Color", dressing_human.undershirt_color) as color|null
			if(new_undershirt_color)
				dressing_human.undershirt_color = sanitize_hexcolor(new_undershirt_color)
		if("Socks Color")
			var/new_socks_color = input(dressing_human, "Choose your socks color", "Socks Color", dressing_human.socks_color) as color|null
			if(new_socks_color)
				dressing_human.socks_color = sanitize_hexcolor(new_socks_color)
		if("Bra")
			var/new_bra = tgui_input_list(user, "Select your Bra", "Changing", SSaccessories.bra_list)
			if(new_bra)
				dressing_human.bra = new_bra
		if("Bra Color")
			var/new_bra_color = input(dressing_human, "Choose your Bra color", "Bra Color", dressing_human.bra_color) as color|null
			if(new_bra_color)
				dressing_human.bra_color = sanitize_hexcolor(new_bra_color)
		//DOPPLER EDIT ADDITION END - Colorable Undershirt/Socks/Bras

	add_fingerprint(dressing_human)
	dressing_human.update_body()
