/obj/structure/geyser
	name = "geyser"
	icon = 'icons/obj/lavaland/terrain.dmi'
	icon_state = "geyser"

	var/erupting_state = "geyser_oil" //set to null to get it greyscaled from "[icon_state]_soup". Not very usable with the whole random thing, but more types can be added if you change the spawn prob
	var/activated = FALSE //whether we are active and generating chems
	var/reagent_id = /datum/reagent/oil
	var/max_volume = 500

/obj/structure/geyser/proc/start_chemming()
	activated = TRUE
	create_reagents(max_volume, DRAINABLE)
	reagents.add_reagent(reagent_id, max_volume)
	if(erupting_state)
		icon_state = erupting_state
	else
		var/image/I = image(icon_state = "[icon_state]_soup")
		I.color = mix_color_from_reagents(reagents.reagent_list)
		overlays += I

/obj/structure/geyser/plunger_act(obj/item/plunger/P, mob/living/user, _reinforced)
	if(!_reinforced)
		to_chat(user, "<span class='warning'>The [P.name] isn't strong enough!</span>")
		return
	if(activated)
		to_chat(user, "<span class'warning'>The [name] is already active!")

	to_chat(user, "<span class='notice'>You start vigorously plunging [src]!")
	if(do_after(user, 50*P.plunge_mod, target = src) && !activated)
		start_chemming()

/obj/structure/geyser/random
	erupting_state = FALSE
	var/list/options = list(/datum/reagent/oil = 2, /datum/reagent/clf3 = 1) //fucking add more

/obj/structure/geyser/random/Initialize()
	. = ..()
	reagent_id = pickweight(options)


/obj/item/plunger
	name = "plunger"
	desc = "It's a plunger for plunging."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "plunger"

	var/plunge_mod = 1 //time*plunge_mod = total time we take to plunge an object
	var/reinforced = FALSE //whether we do heavy duty stuff like geysers

/obj/item/plunger/attack_obj(obj/O, mob/living/user)
	if(!O.plunger_act(src, user, reinforced))
		return ..()

/obj/item/plunger/reinforced
	name = "reinforced plunger"
	desc = " It's an M. 7 Reinforced Plunger© for heavy duty plunging."
	icon_state = "reinforced_plunger"

	reinforced = TRUE
	plunge_mod = 0.8
