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
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.isOn()) //Badasses dont get blinded by lighting their candle with a welding tool
			light("<span class='danger'>[user] casually lights the [name] with [W], what a badass.</span>")
	else if(istype(W, /obj/item/weapon/lighter))
		var/obj/item/weapon/lighter/L = W
		if(L.lit)
			light()
	else if(istype(W, /obj/item/weapon/match))
		var/obj/item/weapon/match/M = W
		if(M.lit)
			light()
	else if(istype(W, /obj/item/candle))
		var/obj/item/candle/C = W
		if(C.lit)
			light()
	else if(istype(W, /obj/item/clothing/mask/cigarette))
		var/obj/item/clothing/mask/cigarette/M = W
		if(M.lit)
			light()

/obj/item/candle/fire_act()
	if(!src.lit)
		light() //honk
	return

/obj/item/candle/proc/light(show_message)
	if(!src.lit)
		src.lit = TRUE
		//src.damtype = "fire"
		if(show_message)
			usr.visible_message(
				"<span class='danger'>[usr] lights the [name].</span>")
		SetLuminosity(CANDLE_LUMINOSITY)
		SSobj.processing |= src
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
