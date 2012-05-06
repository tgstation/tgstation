/*
CONTAINS:
MATCHES
MATCHBOXES
CIGARETTES
CIGARS
CIG PACKET
ZIPPO
*/

///////////
//MATCHES//
///////////
/obj/item/weapon/match
	name = "Match"
	desc = "A simple match stick, used for lighting tobacco"
	icon = 'cigarettes.dmi'
	icon_state = "match_unlit"
	var/lit = 0
	var/smoketime = 5
	w_class = 1.0
	origin_tech = "materials=1"


	process()
		var/turf/location = get_turf(src)
		if(src.lit == 1)
			if(location)
				location.hotspot_expose(700, 5)
			src.smoketime--
			sleep(10)
			if(src.smoketime < 1)
				src.icon_state = "match_burnt"
				src.lit = -1
				processing_objects.Remove(src)
				return


	dropped(mob/user as mob)
		if(src.lit == 1)
			spawn(10)
				var/turf/location = get_turf(src)
				location.hotspot_expose(700, 5)
				src.lit = -1
				src.damtype = "brute"
				src.icon_state = "match_burnt"
				src.item_state = "cigoff"
				src.name = "Burnt match"
				src.desc = "A match that has been burnt"
				processing_objects.Remove(src)
		return ..()



//////////////
//MATCHBOXES//
//////////////
/obj/item/weapon/matchbox
	name = "Matchbox"
	desc = "A small box of Almost But Not Quite Plasma Premium Matches."
	icon = 'cigarettes.dmi'
	icon_state = "matchbox"
	item_state = "zippo"
	w_class = 1
	flags = ONBELT | TABLEPASS
	var/matchcount = 10
	w_class = 1.0


	attack_hand(mob/user as mob)
		if(user.r_hand == src || user.l_hand == src)
			if(src.matchcount <= 0)
				user << "\red You're out of matches. Shouldn't have wasted so many..."
				return
			else
				src.matchcount--
				var/obj/item/weapon/match/W = new /obj/item/weapon/match(user)
				user.put_in_hand(W)
		else
			return ..()
		if(src.matchcount <= 0)
			src.icon_state = "matchbox_empty"
		else if(src.matchcount <= 3)
			src.icon_state = "matchbox_almostempty"
		else if(src.matchcount <= 6)
			src.icon_state = "matchbox_almostfull"
		else
			src.icon_state = "matchbox"
		src.update_icon()
		return


	attackby(obj/item/weapon/match/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/match) && W.lit == 0)
			W.lit = 1
			W.icon_state = "match_lit"
			processing_objects.Add(W)
		W.update_icon()
		return



///////////////////////
//CIGARETTES + CIGARS//
///////////////////////

/obj/item/clothing/mask/cigarette
	name = "Cigarette"
	desc = "A roll of tobacco and nicotine."
	icon_state = "cigoff"
	throw_speed = 0.5
	item_state = "cigoff"
	w_class = 1
	body_parts_covered = null
	var
		lit = 0
		icon_on = "cigon"  //Note - these are in masks.dmi not in cigarette.dmi
		icon_off = "cigoff"
		icon_butt = "cigbutt"
		lastHolder = null
		smoketime = 300
		butt_count = 5  //count of butt sprite variations
	proc
		light(var/flavor_text = "[usr] lights the [name].")

		put_out()
			if (src.lit == -1)
				return
			src.lit = -1
			src.damtype = "brute"
			src.icon_state = icon_butt + "[rand(0,butt_count)]"
			src.item_state = icon_off
			src.desc = "A [src.name] butt."
			src.name = "[src.name] butt"

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		..()
		if(istype(W, /obj/item/weapon/weldingtool) && W:welding)
			light("\red [user] casually lights the [name] with [W], what a badass.")

		else if(istype(W, /obj/item/weapon/lighter/zippo) && (W:lit > 0))
			light("\red With a single flick of their wrist, [user] smoothly lights their [name] with their [W]. Damn they're cool.")

		else if(istype(W, /obj/item/weapon/lighter) && (W:lit > 0))
			light("\red After some fiddling, [user] manages to light their [name] with [W].")

		else if(istype(W, /obj/item/weapon/match) && (W:lit > 0))
			light("\red [user] lights their [name] with their [W].")
		return


	light(var/flavor_text = "[usr] lights the [name].")
		if(!src.lit)
			src.lit = 1
			src.damtype = "fire"
			src.icon_state = icon_on
			src.item_state = icon_on
			for(var/mob/O in viewers(usr, null))
				O.show_message(flavor_text, 1)
			processing_objects.Add(src)



	process()
		var/turf/location = get_turf(src)
		src.smoketime--
		if(src.smoketime < 1)
			if(ismob(src.loc))
				var/mob/living/M = src.loc
				M << "\red Your [src.name] goes out."
				put_out()
				M.update_clothing()
			else
				put_out()
			processing_objects.Remove(src)
			return
		if(location)
			location.hotspot_expose(700, 5)
		return


	dropped(mob/user as mob)
		if(src.lit == 1)
			src.visible_message("\red [user] calmly drops and treads on the lit [src], putting it out instantly.")
			put_out()
		return ..()



////////////
// CIGARS //
////////////
/obj/item/clothing/mask/cigarette/cigar
	name = "Premium Cigar"
	desc = "A brown roll of tobacco and... well, you're not quite sure. This thing's huge!"
	icon_state = "cigaroff"
	icon_on = "cigaron"
	icon_off = "cigaroff"
	icon_butt = "cigarbutt"
	throw_speed = 0.5
	item_state = "cigaroff"
	smoketime = 1500
	butt_count = 0

/obj/item/clothing/mask/cigarette/cigar/cohiba
	name = "Cohiba Robusto Cigar"
	desc = "There's little more you could want from a cigar."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"

/obj/item/clothing/mask/cigarette/cigar/havana
	name = "Premium Havanian Cigar"
	desc = "A cigar fit for only the best for the best."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"
	smoketime = 7200

/obj/item/weapon/cigbutt
	name = "cigarette butt"
	desc = "A manky old cigarette butt."
	icon = 'masks.dmi'
	icon_state = "cigbutt"
	w_class = 1
	throwforce = 1

/obj/item/weapon/cigbutt/cigarbutt
	name = "cigar butt"
	desc = "A manky old cigar butt."
	icon_state = "cigarbutt"


/////////////////
//SMOKING PIPES//
/////////////////

/obj/item/clothing/mask/pipe
	name = "smoking pipe"
	desc = "A pipe, for smoking. Probably made of meershaum or something."
	icon_state = "cobpipeoff"
	throw_speed = 0.5
	item_state = "cobpipeoff"
	w_class = 1
	body_parts_covered = null
	var
		lit = 0
		icon_on = "cobpipeon"  //Note - these are in masks.dmi
		icon_off = "cobpipeoff"
		lastHolder = null
		smoketime = 100
		maxsmoketime = 100 //make sure this is equal to your smoketime
	proc
		light(var/flavor_text = "[usr] lights the [name].")

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		..()
		if(istype(W, /obj/item/weapon/weldingtool) && W:welding)
			light("\red [user] casually lights the [name] with [W], what a badass.")

		else if(istype(W, /obj/item/weapon/lighter/zippo) && (W:lit > 0))
			light("\red With a single flick of their wrist, [user] smoothly lights their [name] with their [W]. Damn they're cool.")

		else if(istype(W, /obj/item/weapon/lighter) && (W:lit > 0))
			light("\red After some fiddling, [user] manages to light their [name] with [W].")

		else if(istype(W, /obj/item/weapon/match) && (W:lit > 0))
			light("\red [user] lights \his [name] with \his [W].")
		return

	light(var/flavor_text = "[usr] lights the [name].")
		if(!src.lit)
			src.lit = 1
			src.damtype = "fire"
			src.icon_state = icon_on
			src.item_state = icon_on
			for(var/mob/O in viewers(usr, null))
				O.show_message(flavor_text, 1)
			processing_objects.Add(src)

	process()
		var/turf/location = get_turf(src)
		src.smoketime--
		if(src.smoketime < 1)
			new /obj/effect/decal/ash(location)
			if(ismob(src.loc))
				var/mob/living/M = src.loc
				M << "\red Your [src.name] goes out, and you empty the ash."
				src.lit = 0
				src.icon_state = icon_off
				src.item_state = icon_off
			processing_objects.Remove(src)
			return
		if(location)
			location.hotspot_expose(700, 5)
		return

	dropped(mob/user as mob)
		if(src.lit == 1)
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red [] puts out the [].", user,src.name), 1)
				src.lit = 0
				src.icon_state = icon_off
				src.item_state = icon_off
			processing_objects.Remove(src)
		return ..()

/obj/item/clothing/mask/pipe/attack_self(mob/user as mob) //Refills the pipe. Can be changed to an attackby later, if loose tobacco is added to vendors or something.
	if(src.smoketime <= 0)
		user << "\blue You refill the pipe with tobacco."
		smoketime = maxsmoketime
	return
/*
/obj/item/clothing/mask/pipe/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/match))
		..()
	else
		user << "\red The [src] straight out REFUSES to be lit by such means."
*/// Yeah no. DMTG


/obj/item/clothing/mask/pipe/cobpipe
	name = "corn cob pipe"
	desc = "A nicotine delivery system popularized by folksy backwoodsmen and kept popular in the modern age and beyond by space hipsters."
	smoketime = 400
	maxsmoketime = 400

////////////
//CIG PACK//
////////////
/obj/item/weapon/cigpacket
	name = "Cigarette packet"
	desc = "The most popular brand of Space Cigarettes, sponsors of the Space Olympics."
	icon = 'cigarettes.dmi'
	icon_state = "cigpacket"
	item_state = "cigpacket"
	w_class = 1
	throwforce = 2
	flags = ONBELT | TABLEPASS
	var
		cigcount = 6


	update_icon()
		src.icon_state = text("cigpacket[]", src.cigcount)
		src.desc = text("There are [] cigs\s left!", src.cigcount)
		return


	attack_hand(mob/user as mob)
		if(user.r_hand == src || user.l_hand == src)
			if(src.cigcount == 0)
				user << "\red You're out of cigs, shit! How you gonna get through the rest of the day..."
				return
			else
				src.cigcount--
				var/obj/item/clothing/mask/cigarette/W = new /obj/item/clothing/mask/cigarette(user)
				user.put_in_hand(W)
		else
			return ..()
		src.update_icon()
		return



/////////
//ZIPPO//
/////////

/obj/item/weapon/lighter
	name = "cheap lighter"
	desc = "A cheap-as-free lighter."
	icon = 'items.dmi'
	icon_state = "lighter-g"
	item_state = "lighter-g"
	var/icon_on = "lighter-g-on"
	var/icon_off = "lighter-g"
	w_class = 1
	throwforce = 4
	flags = ONBELT | TABLEPASS | CONDUCT
	var/lit = 0

/obj/item/weapon/lighter/zippo
	name = "Zippo lighter"
	desc = "The zippo."
	icon_state = "zippo"
	item_state = "zippo"
	icon_on = "zippoon"
	icon_off = "zippo"

/obj/item/weapon/lighter/random
	New()
		var/color = pick("r","c","y","g")
		icon_on = "lighter-[color]-on"
		icon_off = "lighter-[color]"
		icon_state = icon_off

/obj/item/weapon/lighter

	attack_self(mob/user)
		if(user.r_hand == src || user.l_hand == src)
			if(!src.lit)
				src.lit = 1
				src.icon_state = icon_on
				src.item_state = icon_on
				if( istype(src,/obj/item/weapon/lighter/zippo) )
					for(var/mob/O in viewers(user, null))
						O.show_message(text("\red Without even breaking stride, [] flips open and lights [] in one smooth movement.", user, src), 1)
				else
					if(prob(75))
						for(var/mob/O in viewers(user, null))
							O.show_message("\red After a few attempts, [user] manages to light [src].", 1)
					else
						user << "\red <b>You burn yourself while lighting the lighter.</b>"
						user.adjustFireLoss(5)
						for(var/mob/O in viewers(user, null))
							O.show_message("\red After a few attempts, [user] manages to light [src], they however burn their finger in the process.", 1)

				user.total_luminosity += 2
				processing_objects.Add(src)
			else
				src.lit = 0
				src.icon_state = icon_off
				src.item_state = icon_off
				if( istype(src,/obj/item/weapon/lighter/zippo) )
					for(var/mob/O in viewers(user, null))
						O.show_message(text("\red You hear a quiet click, as [] shuts off the [] without even looking at what they're doing. Wow.", user, src), 1)
				else
					for(var/mob/O in viewers(user, null))
						O.show_message("\red [user] quietly shuts off the [src].", 1)

				user.total_luminosity -= 2
				processing_objects.Remove(src)
		else
			return ..()
		return


	attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
		if(!istype(M, /mob))
			return

		if(istype(M.wear_mask,/obj/item/clothing/mask/cigarette) && user.zone_sel.selecting == "mouth" && src.lit)
			if(M == user)
				M.wear_mask:light("\red With a single flick of their wrist, [user] smoothly lights their [M.wear_mask.name] with their [src.name]. Damn they're cool.")
			else
				M.wear_mask:light("\red [user] whips the [src.name] out and holds it for [M]. Their arm is as steady as the unflickering flame they light the [M.wear_mask.name] with.")
		else
			..()


	process()
		var/turf/location = get_turf(src)
		if(location)
			location.hotspot_expose(700, 5)
		return


	pickup(mob/user)
		if(lit)
			src.sd_SetLuminosity(0)
			user.total_luminosity += 2
		return


	dropped(mob/user)
		if(lit)
			user.total_luminosity -= 2
			src.sd_SetLuminosity(2)
		return