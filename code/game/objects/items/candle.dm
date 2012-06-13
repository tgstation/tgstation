//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

#define CANDLE_LUM 3

/obj/item/candle
	name = "red candle"
	desc = "a candle"
	icon = 'candle.dmi'
	icon_state = "candle1"
	item_state = "candle1"

	var/wax = 200
	var/lit = 0
	proc
		light(var/flavor_text = "\red [usr] lights the [name].")


	update_icon()
		var/i
		if(wax>150)
			i = 1
		else if(wax>80)
			i = 2
		else i = 3
		icon_state = "candle[i][lit ? "_lit" : ""]"


	attackby(obj/item/weapon/W as obj, mob/user as mob)
		..()
		if(istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.isOn()) //Badasses dont get blinded by lighting their candle with a welding tool
				light("\red [user] casually lights the [name] with [W], what a badass.")
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


	light(var/flavor_text = "\red [usr] lights the [name].")
		if(!src.lit)
			src.lit = 1
			//src.damtype = "fire"
			for(var/mob/O in viewers(usr, null))
				O.show_message(flavor_text, 1)
			sd_SetLuminosity(CANDLE_LUM)
			processing_objects.Add(src)


	process()
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


	attack_self(mob/user as mob)
		if(lit)
			lit = 0
			update_icon()
			sd_SetLuminosity(0)
			user.total_luminosity -= CANDLE_LUM


	pickup(mob/user)
		if(lit)
			src.sd_SetLuminosity(0)
			user.total_luminosity += CANDLE_LUM


	dropped(mob/user)
		if(lit)
			user.total_luminosity -= CANDLE_LUM
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
	flags = TABLEPASS
	slot_flags = SLOT_BELT


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
				user.update_inv_l_hand()
			else
				user.r_hand = W
				user.update_inv_r_hand()
			W.layer = 20
	else
		return ..()
	src.update_icon()
	return
