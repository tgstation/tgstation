//All mutative extracts result in items so let's just put them in a single file for the ease of readability.
/obj/item/slimecross/mutative
	name = "mutated"
	effect = "mutative"

/obj/item/slimecross/mutative/darkpurple
	colour = "dark purple"
	effect_desc = "Fully stocks up any pacman type generator with fuel."

/obj/item/slimecross/mutative/darkblue
	colour = "dark blue"
	effect_desc = "Turns 50u of water into single stack of snow."

/obj/item/slimecross/mutative/darkblue/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!target.reagents)
		return
	var/datum/reagents/reggies = target.reagents
	var/datum/reagent/water = reggies.has_reagent(/datum/reagent/water)
	if(!water)
		return
	var/sheet_num = FLOOR(water.volume / 50,1)
	if(!sheet_num)
		return
	reggies.remove_reagent(/datum/reagent/water,sheet_num*50)
	var/locc = drop_location()
	for(var/num in 1 to sheet_num)
		new /obj/item/stack/sheet/mineral/snow(locc)

