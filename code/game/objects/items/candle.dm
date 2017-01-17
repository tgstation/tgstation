#define CANDLE_LUMINOSITY	2
/obj/item/candle
	name = "red candle"
	desc = "In Greek myth, Prometheus stole fire from the Gods and gave it to \
		humankind. The jewelry he kept for himself."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle1"
	item_state = "candle1"
	w_class = WEIGHT_CLASS_TINY
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

/obj/item/candle/fire_act(exposed_temperature, exposed_volume)
	if(!src.lit)
		light() //honk
	..()

/obj/item/candle/proc/light(show_message)
	if(!src.lit)
		src.lit = TRUE
		//src.damtype = "fire"
		if(show_message)
			usr.visible_message(show_message)
		set_light(CANDLE_LUMINOSITY)
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
		set_light(0)

/obj/item/candle/is_hot()
	return lit * heat


/obj/item/candle/infinite
	infinite = TRUE
	start_lit = TRUE

#undef CANDLE_LUMINOSITY
