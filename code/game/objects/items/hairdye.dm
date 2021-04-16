//A lot of this is lifted from crayons.dm, specifically the spraycan bit.
/obj/item/toy/hairdye
	name = "universal hairdye canister"
	desc = "A can of Nanotrasen Instant Hair Dye, ready for use. Made of special color-changing chemicals."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "dyecan"
	worn_icon_state = "spraycan"
	inhand_icon_state = "spraycan"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	attack_verb_continuous = list("attacks", "colours")
	attack_verb_simple = list("attack", "colour")
	w_class = WEIGHT_CLASS_SMALL
	force = 1
	var/list/reagent_contents = list(/datum/reagent/hair_dye = 1, /datum/reagent/consumable/ethanol = 1)
	var/can_change_colour = TRUE
	var/hairdye_color =	"#FF0000" //RGB
	var/charges = 5

/obj/item/toy/hairdye/examine(mob/user)
	. = ..()
	if(can_change_colour)
		. += "<span class='notice'>Ctrl-click [src] while it's on your person to quickly recolour it.</span>"
	if(!charges)
		.+= "<span class='notice'>It's empty.</span>"

/obj/item/toy/hairdye/CtrlClick(mob/user)
	if(can_change_colour && !isturf(loc) && user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		select_colour(user)
	else
		return ..()

/obj/item/toy/hairdye/proc/select_colour(mob/user)
	var/chosen_colour = input(user, "", "Choose Color", hairdye_color) as color|null
	if (!isnull(chosen_colour) && user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		hairdye_color = chosen_colour
		return TRUE
	return FALSE

/obj/item/toy/hairdye/attack(mob/M, mob/user)
	if(iscarbon(M) && !(user.a_intent == INTENT_HARM))
		if(do_after(user, 25, TRUE, M) && charges)
			var/mob/living/carbon/human/H = M
			H.haircolor_origin = H.hair_color
			H.beardcolor_origin = H.facial_hair_color
			H.hair_color = sanitize_hexcolor(hairdye_color)
			H.facial_hair_color = sanitize_hexcolor(hairdye_color)
			if(H != user)
				user.visible_message("<span class='notice'>[user] sprays some dye into [H]'s hair, changing its color.</span>")
			else
				user.visible_message("<span class='notice'>[user] sprays some dye into [user.p_their()] hair, changing its color.</span>")
			playsound(user.loc, 'sound/effects/spray.ogg', 25, TRUE, 5)
			charges -= 1
			H.hair_dyed = TRUE
			H.update_hair()
			H.regenerate_icons()
		else if(!charges)
			to_chat(user, "<span class='warning'>There is no more of [src] left!</span>")
	else
		..()

/obj/item/toy/hairdye/red
	name = "red hairdye canister"
	desc = "A can of Nanotrasen Instant Hair Dye, ready for use. This one's red."
	icon_state = "dyecan_red"
	can_change_colour = FALSE
	hairdye_color = "#DA0000"

/obj/item/toy/hairdye/blue
	name = "blue hairdye canister"
	desc = "A can of Nanotrasen Instant Hair Dye, ready for use. This one's blue."
	icon_state = "dyecan_blue"
	can_change_colour = FALSE
	hairdye_color = "#0077AA"

/obj/item/toy/hairdye/white
	name = "white hairdye canister"
	desc = "A can of Nanotrasen Instant Hair Dye, ready for use. This one's white."
	icon_state = "dyecan_white"
	can_change_colour = FALSE
	hairdye_color = "#F1F1F1"

/obj/item/toy/hairdye/black
	name = "black hairdye canister"
	desc = "A can of Nanotrasen Instant Hair Dye, ready for use. This one's black."
	icon_state = "dyecan_black"
	can_change_colour = FALSE
	hairdye_color = "#111111"

/obj/item/toy/hairdye/yellow
	name = "yellow hairdye canister"
	desc = "A can of Nanotrasen Instant Hair Dye, ready for use. This one's yellow."
	icon_state = "dyecan_yellow"
	can_change_colour = FALSE
	hairdye_color = "#f2e833"

/obj/item/toy/hairdye/orange
	name = "orange hairdye canister"
	desc = "A can of Nanotrasen Instant Hair Dye, ready for use. This one's orange."
	icon_state = "dyecan_orange"
	can_change_colour = FALSE
	hairdye_color = "#ee9721"

/obj/item/toy/hairdye/green
	name = "green hairdye canister"
	desc = "A can of Nanotrasen Instant Hair Dye, ready for use. This one's green."
	icon_state = "dyecan_green"
	can_change_colour = FALSE
	hairdye_color = "#a9e12b"

/obj/item/toy/hairdye/purple
	name = "purple hairdye canister"
	desc = "A can of Nanotrasen Instant Hair Dye, ready for use. This one's purple."
	icon_state = "dyecan_purple"
	can_change_colour = FALSE
	hairdye_color = "#c924e5"

/*
 * Dye Box
 */

/obj/item/storage/hairdye
	name = "box of dye cans"
	desc = "A box of hairdye cans for all your styling needs."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "dyebox"
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/cardboard = 2000)

/obj/item/storage/hairdye/Initialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 8
	STR.set_holdable(list(/obj/item/toy/hairdye))
	STR.max_combined_w_class = 30

/obj/item/storage/hairdye/PopulateContents()
	new /obj/item/toy/hairdye/red(src)
	new /obj/item/toy/hairdye/orange(src)
	new /obj/item/toy/hairdye/yellow(src)
	new /obj/item/toy/hairdye/green(src)
	new /obj/item/toy/hairdye/blue(src)
	new /obj/item/toy/hairdye/purple(src)
	new /obj/item/toy/hairdye/black(src)
	new /obj/item/toy/hairdye/white(src)
