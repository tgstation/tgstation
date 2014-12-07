//cleansed 9/15/2012 17:48

/*
CONTAINS:
MATCHES
CIGARETTES
CIGARS
SMOKING PIPES
CHEAP LIGHTERS
ZIPPO

CIGARETTE PACKETS ARE IN FANCY.DM
*/

///////////
//MATCHES//
///////////
/obj/item/weapon/match
	name = "match"
	desc = "A simple match stick, used for lighting fine smokables."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "match_unlit"
	var/lit = 0
	var/smoketime = 5
	w_class = 1.0
	origin_tech = "materials=1"
	attack_verb = list("burnt", "singed")

/obj/item/weapon/match/process()
	var/turf/location = get_turf(src)
	smoketime--
	if(smoketime < 1)
		icon_state = "match_burnt"
		lit = -1
		processing_objects.Remove(src)
		return
	if(location)
		location.hotspot_expose(700, 5,surfaces=istype(loc,/turf))
		return

/obj/item/weapon/match/dropped(mob/user as mob)
	if(lit == 1)
		lit = -1
		damtype = "brute"
		icon_state = "match_burnt"
		item_state = "cigoff"
		name = "burnt match"
		desc = "A match. This one has seen better days."
	return ..()

/obj/item/weapon/match/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(istype(M.wear_mask, /obj/item/clothing/mask/cigarette) && user.zone_sel.selecting == "mouth" && lit)
		var/obj/item/clothing/mask/cigarette/cig = M.wear_mask
		if(M == user)
			cig.attackby(src, user)
		else
			cig.light("<span class='notice'>[user] holds the [name] out for [M], and lights the [cig.name].</span>")
	else
		return ..()

//////////////////
//FINE SMOKABLES//
//////////////////
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
	var/icon_on = "cigon"
	var/overlay_on = "ciglit"
	var/icon_off = "cigoff"
	var/type_butt = /obj/item/weapon/cigbutt
	var/lastHolder = null
	var/lit_brightness = 1
	var/smoketime = 300
	var/chem_volume = 15

/obj/item/clothing/mask/cigarette/New()
	..()
	flags |= NOREACT // so it doesn't react until you light it
	create_reagents(chem_volume) // making the cigarrete a chemical holder with a maximum volume of 15

/obj/item/clothing/mask/cigarette/pickup(mob/user)
	if (lit)
		if(user && loc == user)
			user.SetLuminosity(user.luminosity + lit_brightness)
		else if(isturf(loc))
			SetLuminosity(lit_brightness)

/obj/item/clothing/mask/cigarette/dropped(mob/user)
	if(lit)
		if(user && loc == user)
			user.SetLuminosity(user.luminosity - lit_brightness)
		else if(isturf(loc))
			SetLuminosity(0)

/obj/item/clothing/mask/cigarette/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.isOn())//Badasses dont get blinded while lighting their cig with a welding tool
			light("<span class='notice'>[user] casually lights the [name] with [W], what a badass.</span>")

	else if(istype(W, /obj/item/weapon/lighter/zippo))
		var/obj/item/weapon/lighter/zippo/Z = W
		if(Z.lit)
			light("<span class='rose'>With a single flick of their wrist, [user] smoothly lights their [name] with their [W]. Damn they're cool.</span>")

	else if(istype(W, /obj/item/weapon/lighter))
		var/obj/item/weapon/lighter/L = W
		if(L.lit)
			light("<span class='notice'>After some fiddling, [user] manages to light their [name] with [W].</span>")

	else if(istype(W, /obj/item/weapon/match))
		var/obj/item/weapon/match/M = W
		if(M.lit == 1)
			light("<span class='notice'>[user] lights their [name] with their [W].</span>")

	else if(istype(W, /obj/item/weapon/melee/energy/sword))
		var/obj/item/weapon/melee/energy/sword/S = W
		if(S.active)
			light("<span class='warning'>[user] raises their [W], lighting their [name]. Holy fucking shit.</span>")

	else if(istype(W, /obj/item/device/assembly/igniter))
		light("<span class='notice'>[user] fiddles with [W], and manages to light their [name].</span>")

	else if(istype(W, /obj/item/clothing/mask/cigarette))
		var/obj/item/clothing/mask/cigarette/M = W
		if(M.lit)
			light("<span class='notice'>[user] lights their [name] with their [W].</span>")
	else if(istype(W, /obj/item/candle))
		var/obj/item/candle/C = W
		if(C.lit)
			light("<span class='notice'>[user] lights their [name] with the [W].</span>")
	return


/obj/item/clothing/mask/cigarette/afterattack(obj/item/weapon/reagent_containers/glass/glass, mob/user as mob)
	..()
	var/turf/location = get_turf(src)
	if(istype(glass))	//you can dip cigarettes into beakers
		if(glass.reagents.has_reagent("sacid") || glass.reagents.has_reagent("pacid"))
			new src.type_butt(location)
			processing_objects.Remove(src)
			user << "<span class='warning'>Half of the [name] dissolves with a nasty fizzle.</span>"
			user.drop_item()
			del(src)
			return
		var/transfered = glass.reagents.trans_to(src, chem_volume)
		if(transfered)	//if reagents were transfered, show the message
			user << "<span class='notice'>You dip \the [src] into \the [glass].</span>"
		else			//if not, either the beaker was empty, or the cigarette was full
			if(!glass.reagents.total_volume)
				user << "<span class='notice'>[glass] is empty.</span>"
			else
				user << "<span class='notice'>[src] is full.</span>"


/obj/item/clothing/mask/cigarette/proc/light(var/flavor_text = "[usr] lights the [name].")
	if(!src.lit)
		src.lit = 1
		damtype = "fire"
		if(reagents.get_reagent_amount("plasma")) // the plasma explodes when exposed to fire
			var/datum/effect/effect/system/reagents_explosion/e = new()
			e.set_up(round(reagents.get_reagent_amount("plasma") / 2.5, 1), get_turf(src), 0, 0)
			e.start()
			if(ismob(loc))
				var/mob/M = loc
				M.drop_from_inventory(src)
			del(src)
			return
		if(reagents.get_reagent_amount("fuel")) // the fuel explodes, too, but much less violently
			var/datum/effect/effect/system/reagents_explosion/e = new()
			e.set_up(round(reagents.get_reagent_amount("fuel") / 5, 1), get_turf(src), 0, 0)
			e.start()
			if(ismob(loc))
				var/mob/M = loc
				M.drop_from_inventory(src)
			del(src)
			return
		flags &= ~NOREACT // allowing reagents to react after being lit
		flags |= (MASKINTERNALS | BLOCK_GAS_SMOKE_EFFECT)

		reagents.handle_reactions()
		// This ain't ready yet.
		//overlays.Cut()
		//overlays += image('icons/mob/mask.dmi',overlay_on,LIGHTING_LAYER+1)
		icon_state = icon_on
		item_state = icon_on
		if(user && loc == user)
			user.SetLuminosity(user.luminosity + lit_brightness)
		else if(isturf(loc))
			SetLuminosity(lit_brightness)
		var/turf/T = get_turf(src)
		T.visible_message(flavor_text)
		processing_objects.Add(src)

		//can't think of any other way to update the overlays :<
		if(ismob(loc))
			var/mob/M = loc
			M.update_inv_wear_mask(0)
			M.update_inv_l_hand(0)
			M.update_inv_r_hand(1)


/obj/item/clothing/mask/cigarette/process()
	var/turf/location = get_turf(src)
	var/mob/living/M = loc
	if(isliving(loc))
		M.IgniteMob()
	smoketime--
	if(smoketime < 1)
		new type_butt(location)
		processing_objects.Remove(src)
		if(ismob(loc))
			M << "<span class='notice'>Your [name] goes out.</span>"
			M.u_equip(src)	//un-equip it so the overlays can update
			M.update_inv_wear_mask(0)
		del(src)
		return
	if(location)
		location.hotspot_expose(700, 5,surfaces=istype(loc,/turf))
	if(reagents && reagents.total_volume)	//	check if it has any reagents at all
		if(iscarbon(M) && (src == M:wear_mask)) // if it's in the human/monkey mouth, transfer reagents to the mob
			if(M.reagents.has_reagent("lexorin") || M_NO_BREATH in M.mutations || istype(M, /obj/machinery/atmospherics/unary/cryo_cell))
				reagents.remove_any(REAGENTS_METABOLISM)
			else
				if(prob(25)) // so it's not an instarape in case of acid
					reagents.reaction(M, INGEST)
				reagents.trans_to(M, 0.9)
		else // else just remove some of the reagents
			reagents.remove_any(REAGENTS_METABOLISM)
	return


/obj/item/clothing/mask/cigarette/attack_self(mob/user as mob)
	if(lit == 1)
		user.visible_message("<span class='notice'>[user] calmly drops and treads on the lit [src], putting it out instantly.</span>")
		var/turf/T = get_turf(src)
		new type_butt(T)
		processing_objects.Remove(src)
		del(src)
	return ..()

/obj/item/clothing/mask/cigarette/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!istype(M))
		return ..()

	if(src.lit == 0 && M.on_fire) //Hit burning mobs with cigarettes to light it up.
		if(M == user)
			src.light("<span class='notice'>[user] uses his burning body to light the [src]. Smooth.</span>")
			return
		else
			src.light("<span class='notice'>[user] uses the flames on [M] to light the [src]. How rude.</span>")
			return

	if(istype(M.wear_mask, /obj/item/clothing/mask/cigarette) && user.zone_sel && user.zone_sel.selecting == "mouth" && lit)
		var/obj/item/clothing/mask/cigarette/cig = M.wear_mask
		if(M == user)
			cig.attackby(src, user)
		else
			cig.light("<span class='notice'>[user] holds the [name] out for [M], and lights the [cig.name].</span>")

	else
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
	overlay_on = "cigarlit"
	flags = FPRINT|TABLEPASS
	type_butt = /obj/item/weapon/cigbutt/cigarbutt
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
	overlay_on = "cigar2lit"

/obj/item/clothing/mask/cigarette/cigar/havana
	name = "Premium Havanian Cigar"
	desc = "A cigar fit for only the best for the best."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"
	overlay_on = "cigar2lit"
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
		user << "<span class='notice'>\The [src] straight out REFUSES to be lit by such uncivilized means.</span>"

///////////////////
//AMBROSIA BLUNTS//
///////////////////
/obj/item/clothing/mask/cigarette/blunt
	name = "blunt"
	desc = "A special homemade cigar. Light it up and pass it around."
	icon_state = "bluntoff"
	icon_on = "blunton"
	icon_off = "bluntoff"
	overlay_on = "bluntlit"
	type_butt = /obj/item/weapon/cigbutt/bluntbutt
	throw_speed = 0.5
	item_state = "bluntoff"
	attack_verb = list("burnt", "singed", "blunted")
	smoketime = 420
	chem_volume = 26

/obj/item/clothing/mask/cigarette/blunt/pickup(mob/user)

/obj/item/clothing/mask/cigarette/blunt/New()
	. = ..()
	for(var/reagent in src.reagents)
		reagents[reagent] *= 1.2

/obj/item/clothing/mask/cigarette/blunt/rolled //grown.dm handles reagents for these

/obj/item/clothing/mask/cigarette/blunt/cruciatus
	name = "blunt"
	desc = "A special homemade cigar. Light it up and pass it around."
	chem_volume = 36

/obj/item/clothing/mask/cigarette/blunt/cruciatus/New()
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("space_drugs", 7)
	reagents.add_reagent("kelotane", 7)
	reagents.add_reagent("bicaridine", 5)
	reagents.add_reagent("toxin", 5)
	reagents.add_reagent("spiritbreaker", 10)

/obj/item/clothing/mask/cigarette/blunt/cruciatus/rolled

/obj/item/clothing/mask/cigarette/blunt/deus
	name = "godblunt"
	desc = "A fat ambrosia deus cigar. Smoke weed every day."
	icon_state = "dbluntoff"
	icon_on = "dblunton"
	icon_off = "dbluntoff"
	overlay_on = "dbluntlit"

/obj/item/clothing/mask/cigarette/blunt/deus/New()
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("bicaridine", 7)
	reagents.add_reagent("synaptizine", 7)
	reagents.add_reagent("hyperzine", 5)
	reagents.add_reagent("space_drugs", 5)

/obj/item/clothing/mask/cigarette/blunt/deus/rolled

/obj/item/weapon/cigbutt/bluntbutt
	name = "blunt butt"
	desc = "A manky old blunt butt."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "bluntbutt"
	w_class = 1
	throwforce = 1

/////////////////
//SMOKING PIPES//
/////////////////
/obj/item/clothing/mask/cigarette/pipe
	name = "smoking pipe"
	desc = "A pipe, for smoking. Probably made of meershaum or something."
	flags = FPRINT|TABLEPASS
	icon_state = "pipeoff"
	item_state = "pipeoff"
	icon_on = "pipeon"  //Note - these are in masks.dmi
	icon_off = "pipeoff"
	overlay_on = "pipelit"
	smoketime = 100

/obj/item/clothing/mask/cigarette/pipe/light(var/flavor_text = "[usr] lights the [name].")
	if(!src.lit)
		src.lit = 1
		damtype = "fire"
		icon_state = icon_on
		item_state = icon_on
		var/turf/T = get_turf(src)
		T.visible_message(flavor_text)
		processing_objects.Add(src)

/obj/item/clothing/mask/cigarette/pipe/process()
	var/turf/location = get_turf(src)
	smoketime--
	if(smoketime < 1)
		new /obj/effect/decal/cleanable/ash(location)
		if(ismob(loc))
			var/mob/living/M = loc
			M << "<span class='notice'>Your [name] goes out, and you empty the ash.</span>"
			lit = 0
			icon_state = icon_off
			item_state = icon_off
			M.update_inv_wear_mask(0)
		processing_objects.Remove(src)
		return
	if(location)
		location.hotspot_expose(700, 5,surfaces=istype(loc,/turf))
	return

/obj/item/clothing/mask/cigarette/pipe/attack_self(mob/user as mob) //Refills the pipe. Can be changed to an attackby later, if loose tobacco is added to vendors or something.
	if(lit == 1)
		user.visible_message("<span class='notice'>[user] puts out [src].</span>")
		lit = 0
		icon_state = icon_off
		item_state = icon_off
		processing_objects.Remove(src)
		return
	if(smoketime <= 0)
		user << "<span class='notice'>You refill the pipe with tobacco.</span>"
		smoketime = initial(smoketime)
	return

/obj/item/clothing/mask/cigarette/pipe/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/match))
		..()
	else
		user << "<span class='notice'>\The [src] straight out REFUSES to be lit by such means.</span>"

/obj/item/clothing/mask/cigarette/pipe/cobpipe
	name = "corn cob pipe"
	desc = "A nicotine delivery system popularized by folksy backwoodsmen and kept popular in the modern age and beyond by space hipsters."
	icon_state = "cobpipeoff"
	item_state = "cobpipeoff"
	icon_on = "cobpipeon"  //Note - these are in masks.dmi
	icon_off = "cobpipeoff"
	smoketime = 400



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

/obj/item/weapon/lighter/random/New()
	. = ..()
	var/color = pick("r","c","y","g")
	icon_on = "lighter-[color]-on"
	icon_off = "lighter-[color]"
	icon_state = icon_off

/obj/item/weapon/lighter/attack_self(mob/living/user)
	if(user.r_hand == src || user.l_hand == src)
		if(!lit)
			lit = 1
			icon_state = icon_on
			item_state = icon_on
			if(istype(src, /obj/item/weapon/lighter/zippo) )
				user.visible_message("<span class='rose'>Without even breaking stride, [user] flips open and lights [src] in one smooth movement.</span>")
			else
				if(prob(75))
					user.visible_message("<span class='notice'>After a few attempts, [user] manages to light the [src].</span>")
				else
					user << "<span class='warning'>You burn yourself while lighting the lighter.</span>"
					user.adjustFireLoss(5)
					user.visible_message("<span class='notice'>After a few attempts, [user] manages to light the [src], they however burn their finger in the process.</span>")

			user.SetLuminosity(user.luminosity + 2)
			processing_objects.Add(src)
		else
			lit = 0
			icon_state = icon_off
			item_state = icon_off
			if(istype(src, /obj/item/weapon/lighter/zippo) )
				user.visible_message("<span class='rose'>You hear a quiet click, as [user] shuts off [src] without even looking at what they're doing. Wow.")
			else
				user.visible_message("<span class='notice'>[user] quietly shuts off the [src].")

			user.SetLuminosity(user.luminosity - 2)
			processing_objects.Remove(src)
	else
		return ..()
	return


/obj/item/weapon/lighter/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(istype(M.wear_mask, /obj/item/clothing/mask/cigarette) && user.zone_sel.selecting == "mouth" && lit)
		var/obj/item/clothing/mask/cigarette/cig = M.wear_mask
		if(M == user)
			cig.attackby(src, user)
		else
			if(istype(src, /obj/item/weapon/lighter/zippo))
				cig.light("<span class='rose'>[user] whips the [name] out and holds it for [M]. Their arm is as steady as the unflickering flame they light \the [cig] with.</span>")
			else
				cig.light("<span class='notice'>[user] holds the [name] out for [M], and lights the [cig.name].</span>")
	else
		return ..()

/obj/item/weapon/lighter/process()
	var/turf/location = get_turf(src)
	if(location)
		location.hotspot_expose(700, 5,surfaces=istype(loc,/turf))
	return


/obj/item/weapon/lighter/pickup(mob/user)
	if(lit)
		SetLuminosity(0)
		user.SetLuminosity(user.luminosity+2)
	return


/obj/item/weapon/lighter/dropped(mob/user)
	if(lit)
		user.SetLuminosity(user.luminosity-2)
		SetLuminosity(2)
	return
