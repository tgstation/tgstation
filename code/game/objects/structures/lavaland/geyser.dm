//If you look at the "geyser_soup" overlay icon_state, you'll see that the first frame has 25 ticks.
//That's because the first 18~ ticks are completely skipped for some ungodly weird fucking byond reason

///A lavaland geyser that spawns chems and can be mining scanned for points. Made to work with the plumbing pump to extract that sweet rare nectar
/obj/structure/geyser
	name = "geyser"
	icon = 'icons/obj/mining_zones/terrain.dmi'
	icon_state = "geyser"
	anchored = TRUE

	///set to null to get it greyscaled from "[icon_state]_soup". Not very usable with the whole random thing, but more types can be added if you change the spawn prob
	var/erupting_state = null
	///what chem do we produce?
	var/datum/reagent/reagent_id = /datum/reagent/fuel/oil
	///how much reagents we add every process (2 seconds)
	var/potency = 2
	///maximum volume
	var/max_volume = 500

	///Have we been discovered with a mining scanner?
	var/discovered = FALSE
	///How many points we grant to whoever discovers us
	var/point_value = 100
	///what's our real name that will show upon discovery? null to do nothing
	var/true_name
	///the message given when you discover this geyser.
	var/discovery_message = null

/obj/structure/geyser/Initialize(mapload) //if xenobio wants to bother, nethermobs are around geysers.
	. = ..()

	AddElement(/datum/element/swabable, CELL_LINE_TABLE_NETHER, CELL_VIRUS_TABLE_GENERIC, 1, 5)

	create_reagents(max_volume, DRAINABLE)
	reagents.add_reagent(reagent_id, max_volume)

	RegisterSignal(reagents, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(start_chemming))

	if(erupting_state)
		icon_state = erupting_state
	else
		var/mutable_appearance/I = mutable_appearance('icons/obj/mining_zones/terrain.dmi', "[icon_state]_soup")
		I.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(I)

///start making those CHHHHHEEEEEEMS. Called whenever chems are removed
/obj/structure/geyser/proc/start_chemming()
	SIGNAL_HANDLER

	UnregisterSignal(reagents, COMSIG_REAGENTS_HOLDER_UPDATED)

	START_PROCESSING(SSplumbing, src) //Its main function is to be plumbed, so use SSplumbing

///Add reagents until we are full
/obj/structure/geyser/process()
	//create more
	if(reagents.total_volume <= reagents.maximum_volume)
		reagents.add_reagent(reagent_id, potency)
		return

	//we're full
	RegisterSignal(reagents, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(start_chemming))
	return PROCESS_KILL

/obj/structure/geyser/attackby(obj/item/item, mob/user, list/modifiers, list/attack_modifiers)
	if(!istype(item, /obj/item/mining_scanner) && !istype(item, /obj/item/t_scanner/adv_mining_scanner))
		playsound(src, SFX_INDUSTRIAL_SCAN, 20, TRUE, -2, TRUE, FALSE)
		return ..() //this runs the plunger code

	if(discovered)
		to_chat(user, span_warning("This geyser has already been discovered!"))
		return

	to_chat(user, span_notice("You discovered the geyser and mark it on the GPS system!"))
	SEND_SIGNAL(user, COMSIG_LIVING_DISCOVERED_GEYSER, src)
	if(discovery_message)
		to_chat(user, discovery_message)

	discovered = TRUE
	if(true_name)
		name = true_name

	AddComponent(/datum/component/gps, true_name) //put it on the gps so miners can mark it and chemists can profit off of it

	if(isliving(user))
		var/mob/living/living = user

		var/obj/item/card/id/card = living.get_idcard()
		if(card)
			to_chat(user, span_notice("[point_value] mining points have been paid out!"))
			card.registered_account.mining_points += point_value

/obj/structure/geyser/wittel
	reagent_id = /datum/reagent/wittel
	point_value = 250
	true_name = "wittel geyser"
	discovery_message = "It's a rare wittel geyser! This could be very powerful in the right hands... "

/obj/structure/geyser/plasma_oxide
	reagent_id = /datum/reagent/plasma_oxide
	true_name = "plasma-oxide geyser"

/obj/structure/geyser/protozine
	reagent_id = /datum/reagent/medicine/omnizine/protozine
	true_name = "protozine geyser"

/obj/structure/geyser/hollowwater
	reagent_id = /datum/reagent/water/hollowwater
	true_name = "hollow water geyser"

/obj/structure/geyser/chiral_buffer
	reagent_id = /datum/reagent/reaction_agent/inversing_buffer
	point_value = 250
	true_name = "chiral inversing geyser"
	discovery_message = "It's a rare chiral inversing geyser! This could be very powerful in the right hands... "

/obj/structure/geyser/random
	point_value = 500

/obj/structure/geyser/random/Initialize(mapload)
	reagent_id = get_random_reagent_id()

	true_name = "[initial(reagent_id.name)] geyser"

	discovery_message = "It's a [true_name]! How does any of this even work?" //it doesnt

	return ..()

///A wearable tool that lets you empty plumbing machinery and some other stuff
/obj/item/plunger
	name = "plunger"
	desc = "It's a plunger for plunging."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "plunger"
	worn_icon_state = "plunger"
	icon_angle = 90

	slot_flags = ITEM_SLOT_MASK
	flags_inv = HIDESNOUT

	///time*plunge_mod = total time we take to plunge an object
	var/plunge_mod = 1
	///whether we do heavy duty stuff like geysers
	var/reinforced = TRUE
	///alt sprite for the toggleable layer change mode
	var/layer_mode_sprite = "plunger_layer"
	///Wheter we're in layer mode
	var/layer_mode = FALSE
	///What layer we set it to
	var/target_layer = DUCT_LAYER_DEFAULT

/obj/item/plunger/attack_atom(obj/attacked_obj, mob/living/user, list/modifiers, list/attack_modifiers)
	if(layer_mode)
		SEND_SIGNAL(attacked_obj, COMSIG_MOVABLE_CHANGE_DUCT_LAYER, attacked_obj, target_layer)
		return ..()
	else
		if(!attacked_obj.plunger_act(src, user, reinforced))
			return ..()

/obj/item/plunger/throw_impact(atom/hit_atom, datum/thrownthing/tt)
	. = ..()
	if(tt.target_zone != BODY_ZONE_HEAD)
		return
	if(iscarbon(hit_atom))
		var/mob/living/carbon/H = hit_atom
		if(!H.wear_mask)
			H.equip_to_slot_if_possible(src, ITEM_SLOT_MASK)
			H.visible_message(span_warning("The plunger slams into [H]'s face!"), span_warning("The plunger suctions to your face!"))

/obj/item/plunger/attack_self(mob/user)
	. = ..()

	layer_mode = !layer_mode

	if(!layer_mode)
		icon_state = initial(icon_state)
		to_chat(user, span_notice("You set the plunger to 'Plunger Mode'."))
	else
		icon_state = layer_mode_sprite
		to_chat(user, span_notice("You set the plunger to 'Layer Mode'."))

	playsound(src, 'sound/machines/click.ogg', 10, TRUE)

/obj/item/plunger/click_alt(mob/user)
	var/new_layer = tgui_input_list(user, "Select a layer", "Layer", GLOB.plumbing_layers)
	if(isnull(new_layer) || !user.can_perform_action(src))
		return CLICK_ACTION_BLOCKING
	target_layer = GLOB.plumbing_layers[new_layer]
	return CLICK_ACTION_SUCCESS

///A faster reinforced plunger
/obj/item/plunger/reinforced
	name = "reinforced plunger"
	desc = "It's an M. 7 Reinforced Plunger© for heavy duty plunging."
	icon_state = "reinforced_plunger"
	worn_icon_state = "reinforced_plunger"
	reinforced = TRUE
	plunge_mod = 0.5
	layer_mode_sprite = "reinforced_plunger_layer"

	custom_premium_price = PAYCHECK_CREW * 8
