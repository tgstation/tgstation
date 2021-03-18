//If you look at the "geyser_soup" overlay icon_state, you'll see that the first frame has 25 ticks.
//That's because the first 18~ ticks are completely skipped for some ungodly weird fucking byond reason

/obj/structure/geyser
	name = "geyser"
	icon = 'icons/obj/lavaland/terrain.dmi'
	icon_state = "geyser"
	anchored = TRUE

	var/erupting_state = null //set to null to get it greyscaled from "[icon_state]_soup". Not very usable with the whole random thing, but more types can be added if you change the spawn prob
	var/activated = FALSE //whether we are active and generating chems
	var/reagent_id = /datum/reagent/fuel/oil
	var/potency = 2 //how much reagents we add every process (2 seconds)
	var/max_volume = 500
	var/start_volume = 50

/obj/structure/geyser/Initialize(mapload) //if xenobio wants to bother, nethermobs are around geysers.
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_NETHER, CELL_VIRUS_TABLE_GENERIC, 1, 5)

/obj/structure/geyser/proc/start_chemming()
	activated = TRUE
	create_reagents(max_volume, DRAINABLE)
	reagents.add_reagent(reagent_id, start_volume)
	START_PROCESSING(SSfluids, src) //It's main function is to be plumbed, so use SSfluids
	if(erupting_state)
		icon_state = erupting_state
	else
		var/mutable_appearance/I = mutable_appearance('icons/obj/lavaland/terrain.dmi', "[icon_state]_soup")
		I.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(I)

/obj/structure/geyser/process()
	if(activated && reagents.total_volume <= reagents.maximum_volume) //this is also evaluated in add_reagent, but from my understanding proc calls are expensive
		reagents.add_reagent(reagent_id, potency)

/obj/structure/geyser/plunger_act(obj/item/plunger/P, mob/living/user, _reinforced)
	if(!_reinforced)
		to_chat(user, "<span class='warning'>The [P.name] isn't strong enough!</span>")
		return
	if(activated)
		to_chat(user, "<span class='warning'>The [name] is already active!</span>")
		return

	to_chat(user, "<span class='notice'>You start vigorously plunging [src]!</span>")
	if(do_after(user, 50 * P.plunge_mod, target = src) && !activated)
		start_chemming()

/obj/structure/geyser/random
	erupting_state = null
	var/list/options = list(/datum/reagent/clf3 = 10, /datum/reagent/water/hollowwater = 10,/datum/reagent/plasma_oxide = 8, /datum/reagent/medicine/omnizine/protozine = 6, /datum/reagent/wittel = 1)

/obj/structure/geyser/random/Initialize()
	. = ..()
	reagent_id = pickweight(options)

/obj/item/plunger
	name = "plunger"
	desc = "It's a plunger for plunging."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "plunger"
	worn_icon_state = "plunger"

	slot_flags = ITEM_SLOT_MASK
	flags_inv = HIDESNOUT

	///time*plunge_mod = total time we take to plunge an object
	var/plunge_mod = 1
	///whether we do heavy duty stuff like geysers
	var/reinforced = FALSE
	///alt sprite for the toggleable layer change mode
	var/layer_mode_sprite = "plunger_layer"
	///Wheter we're in layer mode
	var/layer_mode = FALSE
	///What layer we set it to
	var/target_layer = DUCT_LAYER_DEFAULT

	///Assoc list for possible layers
	var/list/layers = list("Alternate Layer" = SECOND_DUCT_LAYER, "Default Layer" = DUCT_LAYER_DEFAULT)

/obj/item/plunger/attack_obj(obj/O, mob/living/user, params)
	if(layer_mode)
		SEND_SIGNAL(O, COMSIG_MOVABLE_CHANGE_DUCT_LAYER, O, target_layer)
		return ..()
	else
		if(!O.plunger_act(src, user, reinforced))
			return ..()

/obj/item/plunger/throw_impact(atom/hit_atom, datum/thrownthing/tt)
	. = ..()
	if(tt.target_zone != BODY_ZONE_HEAD)
		return
	if(iscarbon(hit_atom))
		var/mob/living/carbon/H = hit_atom
		if(!H.wear_mask)
			H.equip_to_slot_if_possible(src, ITEM_SLOT_MASK)
			H.visible_message("<span class='warning'>The plunger slams into [H]'s face!</span>", "<span class='warning'>The plunger suctions to your face!</span>")

/obj/item/plunger/attack_self(mob/user)
	. = ..()

	layer_mode = !layer_mode

	if(!layer_mode)
		icon_state = initial(icon_state)
		to_chat(user, "<span class='notice'>You set the plunger to 'Plunger Mode'.</span>")
	else
		icon_state = layer_mode_sprite
		to_chat(user, "<span class='notice'>You set the plunger to 'Layer Mode'.</span>")

	playsound(src, 'sound/machines/click.ogg', 10, TRUE)

/obj/item/plunger/AltClick(mob/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE))
		return

	var/new_layer = input("Select a layer", "Layer") as null|anything in layers
	if(new_layer)
		target_layer = layers[new_layer]

/obj/item/plunger/reinforced
	name = "reinforced plunger"
	desc = "It's an M. 7 Reinforced Plunger© for heavy duty plunging."
	icon_state = "reinforced_plunger"
	worn_icon_state = "reinforced_plunger"
	reinforced = TRUE
	plunge_mod = 0.8
	layer_mode_sprite = "reinforced_plunger_layer"

	custom_premium_price = PAYCHECK_MEDIUM * 8
