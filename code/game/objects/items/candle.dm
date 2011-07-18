#define CANDLE_LUM 3

/obj/item/candle
	name = "red candle"
	desc = "a candle"
	icon = 'candle.dmi'
	icon_state = "candle1"
	item_state = "candle1"

	var/wax = 100
	var/lit = 0

/obj/item/candle/update_icon()
	var/i
	if(wax>75)
		i = 1
	else if(wax>40)
		i = 2
	else i = 3
	icon_state = "candle[i][lit ? "_lit" : ""]"

/obj/item/candle/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/weldingtool)  && W:welding)
		light("\red [user] casually lights the [name] with [W], what a badass.")
	else if(istype(W, /obj/item/weapon/zippo) && W:lit)
		light()
	else if(istype(W, /obj/item/weapon/match) && W:lit)
		light()



/obj/item/candle/proc/light(var/flavor_text = "\red [usr] lights the [name].")
	if(!lit)
		lit = 1
		//src.damtype = "fire"
		for(var/mob/O in viewers(usr, null))
			O.show_message(flavor_text, 1)
		sd_SetLuminosity(CANDLE_LUM)
		spawn()
			src.process()

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

	if(istype(loc, /turf)) //start a fire if possible
		var/turf/T = loc
		T.hotspot_expose(700, 5)

	spawn(60)
		process()

/obj/item/candle/attack_self(mob/user as mob)
	if(lit)
		lit = 0
		update_icon()
		sd_SetLuminosity(0)

/obj/item/candle/pickup(mob/user)
	if(lit)
		src.sd_SetLuminosity(0)
		user.sd_SetLuminosity(user.luminosity + CANDLE_LUM)

/obj/item/candle/dropped(mob/user)
	if(lit)
		user.sd_SetLuminosity(user.luminosity - CANDLE_LUM)
		src.sd_SetLuminosity(CANDLE_LUM)


///////////////
//CANDLE PACK//
///////////////
/obj/item/weapon/candlepack
	name = "Candle pack"
	//desc = "The most popular brand of Space Cigarettes, sponsors of the Space Olympics."
	icon = 'candle.dmi'
	icon_state = "pack5"
	item_state = "pack5"
	w_class = 1
	throwforce = 2
	var/candlecount = 5
	flags = ONBELT | TABLEPASS


/obj/item/weapon/candlepack/update_icon()
	src.icon_state = text("pack[]", src.candlecount)
	src.desc = text("There are [] candles left!", src.candlecount)
	return

/obj/item/weapon/candlepack/attack_hand(mob/user as mob)
	if(user.r_hand == src || user.l_hand == src)
		if(src.candlecount == 0)
			//user << "\red You're out of cigs, shit! How you gonna get through the rest of the day..."
			return
		else
			src.candlecount--
			var/obj/item/candle/W = new /obj/item/candle(user)
			if(user.hand)
				user.l_hand = W
			else
				user.r_hand = W
			W.layer = 20
	else
		return ..()
	src.update_icon()
	return