#define CANDLE_LUMINOSITY	2
/obj/item/candle
	name = "red candle"
	desc = "a candle"
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle1"
	item_state = "candle1"
	w_class = 1

	var/wax = 200
	var/lit = 0
	proc
		light(var/flavor_text = "<span class='danger'>[usr] lights the [name].</span>")


/obj/item/candle/update_icon()
	var/i
	if(wax>150)
		i = 1
	else if(wax>80)
		i = 2
	else i = 3
	icon_state = "candle[i][lit ? "_lit" : ""]"


/obj/item/candle/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
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


/obj/item/candle/light(var/flavor_text = "<span class='danger'>[usr] lights the [name].</span>")
	if(!src.lit)
		src.lit = 1
		//src.damtype = "fire"
		for(var/mob/O in viewers(usr, null))
			O.show_message(flavor_text, 1)
		SetLuminosity(CANDLE_LUMINOSITY)
		SSobj.processing |= src


/obj/item/candle/process()
	if(!lit)
		return
	wax--
	if(!wax)
		new/obj/item/trash/candle(src.loc)
		if(istype(src.loc, /mob))
			var/mob/M = src.loc
			M.unEquip(src, 1) //src is being deleted anyway
		qdel(src)
	update_icon()
	if(istype(loc, /turf)) //start a fire if possible
		var/turf/T = loc
		T.hotspot_expose(700, 5)


/obj/item/candle/attack_self(mob/user as mob)
	if(lit)
		lit = 0
		update_icon()
		SetLuminosity(0)
		user.AddLuminosity(-CANDLE_LUMINOSITY)


/obj/item/candle/pickup(mob/user)
	if(lit)
		SetLuminosity(0)
		user.AddLuminosity(CANDLE_LUMINOSITY)


/obj/item/candle/dropped(mob/user)
	if(lit)
		user.AddLuminosity(-CANDLE_LUMINOSITY)
		SetLuminosity(CANDLE_LUMINOSITY)

#undef CANDLE_LUMINOSITY