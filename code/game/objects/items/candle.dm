/obj/item/candle
	name = "red candle"
	desc = "A candle made out of wax, used for moody lighting and solar flares"
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle1"
	item_state = "candle1"
	w_class = 1

	var/wax = 200
	var/lit = 0
	var/flavor_text

/obj/item/candle/update_icon()
	var/i
	if(wax > 150)
		i = 1
	else if(wax > 80)
		i = 2
	else i = 3
	icon_state = "candle[i][lit ? "_lit" : ""]"

/obj/item/candle/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(W.is_hot())
		light("<span class='notice'>[user] lights [src] with [W].</span>")

/obj/item/candle/proc/light(var/flavor_text = "<span class='notice'>[usr] lights [src].</span>")
	if(!src.lit)
		src.lit = 1
		visible_message(flavor_text)
		SetLuminosity(CANDLE_LUM)
		processing_objects.Add(src)

/obj/item/candle/process()
	if(!lit)
		return
	wax--
	if(!wax)
		new/obj/item/trash/candle(src.loc)
		if(istype(src.loc, /mob))
			src.dropped()
		del(src)
	update_icon()
	if(istype(loc, /turf)) //Start a fire if possible
		var/turf/T = loc
		T.hotspot_expose(700, 5, surfaces = 0)

/obj/item/candle/attack_self(mob/user as mob)
	if(lit)
		lit = 0
		update_icon()
		SetLuminosity(0)
		user.SetLuminosity(user.luminosity - CANDLE_LUM)

/obj/item/candle/pickup(mob/user)
	if(lit)
		SetLuminosity(0)
		user.SetLuminosity(user.luminosity + CANDLE_LUM)

/obj/item/candle/dropped(mob/user)
	if(lit && !luminosity)
		user.SetLuminosity(user.luminosity - CANDLE_LUM)
		SetLuminosity(CANDLE_LUM)
