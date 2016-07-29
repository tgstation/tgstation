<<<<<<< HEAD
#define CANDLE_LUMINOSITY	2
/obj/item/candle
	name = "red candle"
	desc = "In Greek myth, Prometheus stole fire from the Gods and gave it to \
		humankind. The jewelry he kept for himself."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle1"
	item_state = "candle1"
	w_class = 1
	var/wax = 200
	var/lit = FALSE
	var/infinite = FALSE
	var/start_lit = FALSE
	heat = 1000

/obj/item/candle/New()
	..()
	if(start_lit)
		// No visible message
		light(show_message = FALSE)

/obj/item/candle/update_icon()
	var/i
	if(wax>150)
		i = 1
	else if(wax>80)
		i = 2
	else i = 3
	icon_state = "candle[i][lit ? "_lit" : ""]"


/obj/item/candle/attackby(obj/item/weapon/W, mob/user, params)
	..()
	var/msg = W.ignition_effect(src, user)
	if(msg)
		light(msg)

/obj/item/candle/fire_act()
	if(!src.lit)
		light() //honk

/obj/item/candle/proc/light(show_message)
	if(!src.lit)
		src.lit = TRUE
		//src.damtype = "fire"
		if(show_message)
			usr.visible_message(show_message)
		SetLuminosity(CANDLE_LUMINOSITY)
		START_PROCESSING(SSobj, src)
		update_icon()


/obj/item/candle/process()
	if(!lit)
		return
	if(!infinite)
		wax--
	if(!wax)
		new/obj/item/trash/candle(src.loc)
		if(istype(src.loc, /mob))
			var/mob/M = src.loc
			M.unEquip(src, 1) //src is being deleted anyway
		qdel(src)
	update_icon()
	open_flame()

/obj/item/candle/attack_self(mob/user)
	if(lit)
		user.visible_message(
			"<span class='notice'>[user] snuffs [src].</span>")
		lit = FALSE
		update_icon()
		SetLuminosity(0)
		user.AddLuminosity(-CANDLE_LUMINOSITY)


/obj/item/candle/pickup(mob/user)
	..()
	if(lit)
		SetLuminosity(0)
		user.AddLuminosity(CANDLE_LUMINOSITY)


/obj/item/candle/dropped(mob/user)
	..()
	if(lit)
		user.AddLuminosity(-CANDLE_LUMINOSITY)
		SetLuminosity(CANDLE_LUMINOSITY)

/obj/item/candle/is_hot()
	return lit * heat


/obj/item/candle/infinite
	infinite = TRUE
	start_lit = TRUE

#undef CANDLE_LUMINOSITY
=======
/obj/item/candle
	name = "red candle"
	desc = "A candle made out of wax, used for moody lighting and solar flares"
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle1"
	item_state = "candle1"
	w_class = W_CLASS_TINY
	heat_production = 1000
	light_color = LIGHT_COLOR_FIRE

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
		set_light(CANDLE_LUM)
		processing_objects.Add(src)

/obj/item/candle/process()
	if(!lit)
		return
	wax--
	if(!wax)
		new/obj/item/trash/candle(src.loc)
		if(istype(src.loc, /mob))
			src.dropped()
		qdel(src)
		return
	update_icon()
	if(istype(loc, /turf)) //Start a fire if possible
		var/turf/T = loc
		T.hotspot_expose(700, 5, surfaces = 0)

/obj/item/candle/attack_self(mob/user as mob)
	if(lit)
		lit = 0
		update_icon()
		set_light(0)

/obj/item/candle/is_hot()
	if(lit)
		return heat_production
	return 0

/obj/item/weapon/match/is_hot()
	if(lit)
		return heat_production
	return 0
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
