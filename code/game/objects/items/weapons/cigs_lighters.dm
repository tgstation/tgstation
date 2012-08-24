//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/*
CONTAINS:
MATCHES
CIGARETTES
CIGARS
SMOKING PIPES
CIG PACKET
ZIPPO
*/

///////////
//MATCHES//
///////////
/obj/item/weapon/match
	name = "Match"
	desc = "A simple match stick, used for lighting tobacco"
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "match_unlit"
	var/lit = 0
	var/smoketime = 5
	w_class = 1.0
	origin_tech = "materials=1"
	attack_verb = list("burnt", "singed")


	process()
		var/turf/location = get_turf(src)
		src.smoketime--
		if(src.smoketime < 1)
			src.icon_state = "match_burnt"
			src.lit = -1
			processing_objects.Remove(src)
			return
		if(location)
			location.hotspot_expose(700, 5)
			return


	dropped(mob/user as mob)
		if(src.lit == 1)
			src.lit = -1
			src.damtype = "brute"
			src.icon_state = "match_burnt"
			src.item_state = "cigoff"
			src.name = "Burnt match"
			src.desc = "A match that has been burnt"
		return ..()


///////////////////////
//CIGARETTES + CIGARS//
///////////////////////

/obj/item/clothing/mask/cigarette
	name = "cigarette"
	desc = "A roll of tobacco and nicotine."
	icon_state = "cigoff"
	throw_speed = 0.5
	item_state = "cigoff"
	w_class = 1
	body_parts_covered = null
	attack_verb = list("burnt", "singed")
	var/lit = 0
	var/icon_on = "cigon"  //Note - these are in masks.dmi not in cigarette.dmi
	var/icon_off = "cigoff"
	var/type_butt = /obj/item/weapon/cigbutt
	var/lastHolder = null
	var/smoketime = 300
	var/chem_volume = 15

/obj/item/clothing/mask/cigarette/New()
	..()
	flags |= NOREACT // so it doesn't react until you light it
	create_reagents(chem_volume) // making the cigarrete a chemical holder with a maximum volume of 15

/obj/item/clothing/mask/cigarette/Del()
	..()
	del(reagents)

/obj/item/clothing/mask/cigarette/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.isOn())//Badasses dont get blinded while lighting their cig with a welding tool
			light("\red [user] casually lights the [name] with [W], what a badass.")

	else if(istype(W, /obj/item/weapon/lighter/zippo))
		var/obj/item/weapon/lighter/zippo/Z = W
		if(Z.lit > 0)
			light("\red With a single flick of their wrist, [user] smoothly lights their [name] with their [W]. Damn they're cool.")

	else if(istype(W, /obj/item/weapon/lighter))
		var/obj/item/weapon/lighter/L = W
		if(L.lit > 0)
			light("\red After some fiddling, [user] manages to light their [name] with [W].")

	else if(istype(W, /obj/item/weapon/melee/energy/sword))
		var/obj/item/weapon/melee/energy/sword/S = W
		if(S.active)
			light("\red [user] swings their [W], barely missing their nose. They light their [name] in the process.")

	else if(istype(W, /obj/item/weapon/match))
		var/obj/item/weapon/match/M = W
		if(M.lit > 0)
			light("\red [user] lights their [name] with their [W].")

	else if(istype(W, /obj/item/device/assembly/igniter))
		light("\red [user] fiddles with [W], and manages to light their [name].")

	//can't think of any other way to update the overlays :<
	user.update_inv_wear_mask(0)
	user.update_inv_l_hand(0)
	user.update_inv_r_hand(1)
	return


/obj/item/clothing/mask/cigarette/afterattack(obj/item/weapon/reagent_containers/glass/glass, mob/user as mob)
	..()
	if(istype(glass)) // you can dip cigarettes into beakers
		var/transfered = glass.reagents.trans_to(src, chem_volume)
		if(transfered) // if reagents were transfered, show the message
			user << "\blue You dip \the [src] into \the [glass]."
		else // if not, either the beaker was empty, or the cigarette was full
			if(!glass.reagents.total_volume)
				user << "\red [glass] is empty."
			else
				user << "\red [src] is full."


/obj/item/clothing/mask/cigarette/proc/light(var/flavor_text = "[usr] lights the [name].")
	if(!src.lit)
		src.lit = 1
		src.damtype = "fire"
		if(reagents.get_reagent_amount("plasma")) // the plasma explodes when exposed to fire
			var/datum/effect/effect/system/reagents_explosion/e = new()
			e.set_up(round (src.reagents.get_reagent_amount("plasma")/2.5, 1), get_turf(src), 0, 0)
			e.start()
			del(src)
			return
		if(reagents.get_reagent_amount("fuel")) // the fuel explodes, too, but much less violently
			var/datum/effect/effect/system/reagents_explosion/e = new()
			e.set_up(round (src.reagents.get_reagent_amount("fuel")/5, 1), get_turf(src), 0, 0)
			e.start()
			del(src)
			return
		src.flags &= ~NOREACT // allowing reagents to react after being lit
		src.reagents.handle_reactions()
		src.icon_state = icon_on
		src.item_state = icon_on
		for(var/mob/O in viewers(usr, null))
			O.show_message(flavor_text, 1)
		processing_objects.Add(src)


/obj/item/clothing/mask/cigarette/process()
	var/turf/location = get_turf(src)
	src.smoketime--
	if(src.smoketime < 1)
		new type_butt(location)
		processing_objects.Remove(src)
		if(ismob(src.loc))
			var/mob/living/M = src.loc
			M << "\red Your [src.name] goes out."
			M.u_equip(src)	//un-equip it so the overlays can update
			M.update_icons()
		del(src)
		return
	if(location)
		location.hotspot_expose(700, 5)
	if(reagents && reagents.total_volume)	//	check if it has any reagents at all
		if( iscarbon(src.loc) && (src == loc:wear_mask) ) // if it's in the human/monkey mouth, transfer reagents to the mob
			var/mob/living/carbon/C = loc
			if(prob(15)) // so it's not an instarape in case of acid
				reagents.reaction(C, INGEST)
			reagents.trans_to(C, REAGENTS_METABOLISM)
		else // else just remove some of the reagents
			reagents.remove_any(REAGENTS_METABOLISM)
	return


/obj/item/clothing/mask/cigarette/dropped(mob/user as mob)
	if(src.lit == 1)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red [] calmly drops and treads on the lit [], putting it out instantly.", user,src.name), 1)
			new type_butt(loc)
			processing_objects.Remove(src)
			del(src)
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
	type_butt = /obj/item/weapon/cigbutt
	throw_speed = 0.5
	item_state = "cigaroff"
	smoketime = 1500
	chem_volume = 20

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
	chem_volume = 30

/obj/item/weapon/cigbutt
	name = "cigarette butt"
	desc = "A manky old cigarette butt."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "cigbutt"
	w_class = 1
	throwforce = 1

/obj/item/weapon/cigbutt/cigarbutt
	name = "cigar butt"
	desc = "A manky old cigar butt."
	icon_state = "cigarbutt"


/obj/item/clothing/mask/cigarette/cigar/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/match))
		..()
	else
		user << "\red The [src] straight out REFUSES to be lit by such uncivilized means."

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
	var/lit = 0
	var/icon_on = "cobpipeon"  //Note - these are in masks.dmi
	var/icon_off = "cobpipeoff"
	var/lastHolder = null
	var/smoketime = 100
	var/maxsmoketime = 100 //make sure this is equal to your smoketime
	proc
		light(var/flavor_text = "[usr] lights the [name].")

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		..()
		if(istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.isOn())
				light("\red [user] casually lights the [name] with [W], what a badass.")

		else if(istype(W, /obj/item/weapon/lighter/zippo))
			var/obj/item/weapon/lighter/zippo/Z = W
			if(Z.lit > 0)
				light("\red With a single flick of their wrist, [user] smoothly lights their [name] with their [W]. Damn they're cool.")

		else if(istype(W, /obj/item/weapon/lighter))
			var/obj/item/weapon/lighter/L = W
			if(L.lit > 0)
				light("\red After some fiddling, [user] manages to light their [name] with [W].")

		else if(istype(W, /obj/item/weapon/match))
			var/obj/item/weapon/match/M = W
			if(M.lit > 0)
				light("\red [user] lights their [name] with their [W].")

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
			new /obj/effect/decal/cleanable/ash(location)
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

/obj/item/clothing/mask/pipe/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/match))
		..()
	else
		user << "\red The [src] straight out REFUSES to be lit by such means."


/obj/item/clothing/mask/pipe/cobpipe
	name = "corn cob pipe"
	desc = "A nicotine delivery system popularized by folksy backwoodsmen and kept popular in the modern age and beyond by space hipsters."
	smoketime = 400
	maxsmoketime = 400

////////////
//CIG PACK//
////////////
/obj/item/weapon/cigpacket
	name = "cigarette packet"
	desc = "The most popular brand of Space Cigarettes, sponsors of the Space Olympics."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cigpacket"
	item_state = "cigpacket"
	w_class = 1
	throwforce = 2
	flags = TABLEPASS
	slot_flags = SLOT_BELT
	var/cigcount = 6

	New()
		..()
		flags |= NOREACT
		create_reagents(15*cigcount)//so people can inject cigarettes without opening a packet, now with being able to inject the whole one

	Del()
		..()
		del(reagents)

	update_icon()
		icon_state = "[initial(icon_state)][cigcount]"
		desc = "There's [cigcount] cig\s left!"
		return


	attack_hand(mob/user as mob)
		if(user.r_hand == src || user.l_hand == src)
			if(cigcount == 0)
				user << "\red You're out of cigs, shit! How you gonna get through the rest of the day..."
				return
			else
				var/obj/item/clothing/mask/cigarette/W = new /obj/item/clothing/mask/cigarette(user)
				reagents.trans_to(W, (reagents.total_volume/cigcount))
				user.put_in_active_hand(W)
				src.reagents.maximum_volume = 15*cigcount
				cigcount--
		else
			return ..()
		update_icon()
		return

/obj/item/weapon/cigpacket/dromedaryco
	name = "DromedaryCo packet"
	desc = "A packet of six imported DromedaryCo cancer sticks. A label on the packaging reads, \"Wouldn't a slow death make a change?\""
	icon_state = "Dpacket"
	item_state = "Dpacket"

/////////
//ZIPPO//
/////////

/obj/item/weapon/lighter
	name = "cheap lighter"
	desc = "A cheap-as-free lighter."
	icon = 'icons/obj/items.dmi'
	icon_state = "lighter-g"
	item_state = "lighter-g"
	var/icon_on = "lighter-g-on"
	var/icon_off = "lighter-g"
	w_class = 1
	throwforce = 4
	flags = TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	attack_verb = list("burnt", "singed")
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

	attack_self(mob/living/user)
		if(user.r_hand == src || user.l_hand == src)
			if(!src.lit)
				src.lit = 1
				src.icon_state = icon_on
				src.item_state = icon_on
				if( istype(src,/obj/item/weapon/lighter/zippo) )
					for(var/mob/O in viewers(user, null))
						O.show_message(text("\red Without even breaking stride, [] flips open and lights the [] in one smooth movement.", user, src), 1)
				else
					if(prob(75))
						for(var/mob/O in viewers(user, null))
							O.show_message("\red After a few attempts, [user] manages to light the [src].", 1)
					else
						user << "\red <b>You burn yourself while lighting the lighter.</b>"
						user.adjustFireLoss(5)
						for(var/mob/O in viewers(user, null))
							O.show_message("\red After a few attempts, [user] manages to light the [src], they however burn their finger in the process.", 1)

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
