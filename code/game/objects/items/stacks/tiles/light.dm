var/global/list/lightfloor_colors = list(
	"white" = rgb(255,255,255), \
	"red" = rgb(255,0,0), \
	"orange" = rgb(255,106,0), \
	"yellow" = rgb(255,216,0), \
	"green" = rgb(0,255,0), \
	"dark green" = rgb(60,215,0), \
	"teal" = rgb(0,234,234), \
	"light blue" = rgb(0,148,255), \
	"dark blue" = rgb(0,38,255), \
	"purple" = rgb(178,0,255), \
	"pink" = rgb(255,135,255), \
	)

#define LIGHTFLOOR_OPTION_CUSTOM "Custom"

/obj/item/stack/tile/light
	name = "light tile"
	singular_name = "light floor tile"
	desc = "A floor tile made out of glass. Use a multitool on it to change its color."
	icon_state = "light_tile_broken"
	w_class = 3.0
	force = 3.0
	throwforce = 5.0
	throw_speed = 5
	throw_range = 20
	flags = FPRINT
	siemens_coefficient = 1
	max_amount = 60
	attack_verb = list("bashes", "batters", "bludgeons", "thrashes", "smashes")

	material = "glass"

	var/on = 1

	var/color_r = 255
	var/color_g = 255
	var/color_b = 255

	var/image/color_overlay

/obj/item/stack/tile/light/New()
	.=..()
	update_icon()
	overlays += color_overlay

/obj/item/stack/tile/light/update_icon(var/new_color)
	.=..()
	overlays = list()
	color_overlay = image('icons/obj/items.dmi', icon_state = "light_tile_overlay")
	color_overlay.color = rgb(color_r,color_g,color_b)
	overlays += color_overlay

/obj/item/stack/tile/light/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O,/obj/item/weapon/crowbar))
		var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
		M.amount = 1
		amount--
		new/obj/item/stack/light_w(user.loc)
		if(amount <= 0)
			user.drop_from_inventory(src)
			qdel(src)
		return 1
	else if(istype(O,/obj/item/device/multitool))
		var/list/choice_list = list(LIGHTFLOOR_OPTION_CUSTOM) + lightfloor_colors

		var/choice = input(user,"Select a colour to set [src] to.","[src]") in choice_list
		if(!Adjacent(user)) return

		var/new_color
		if(choice == LIGHTFLOOR_OPTION_CUSTOM)
			new_color = input("Please select a color for the tile.", "[src]",rgb(color_r,color_g,color_b)) as color
			if(new_color)
				color_r = hex2num(copytext(new_color, 2, 4))
				color_g = hex2num(copytext(new_color, 4, 6))
				color_b = hex2num(copytext(new_color, 6, 8))
		else
			new_color = choice_list[choice]
			color_r = hex2num(copytext(new_color, 2, 4))
			color_g = hex2num(copytext(new_color, 4, 6))
			color_b = hex2num(copytext(new_color, 6, 8))

		update_icon()

	return ..()

/obj/item/stack/tile/light/proc/get_turf_image()

	var/image/I = image('icons/turf/floors.dmi',icon_state = "light_overlay")
	I.color = rgb(color_r,color_g,color_b)
	return I
