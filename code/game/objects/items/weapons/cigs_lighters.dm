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
MATCHBOXES ARE ALSO IN FANCY.DM
*/

///////////
//MATCHES//
///////////

/obj/item/weapon/match
	name = "match"
	desc = "A budget match stick, used to start fires easily, preferably at the end of a smoke."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "match"
	item_state = "cig"
	var/lit = 0
	var/smoketime = 10
	var/brightness_on = 1 //Barely enough to see where you're standing, it's a shitty discount match
	heat_production = 1000
	w_class = 1.0
	origin_tech = "materials=1"
	attack_verb = list("burnt", "singed")
	light_color = LIGHT_COLOR_FIRE

/obj/item/weapon/match/New()

	..()
	update_brightness() //Useful if you want to spawn burnt matches, or burning ones you maniac

/obj/item/weapon/match/examine(mob/user)

	..()
	switch(lit)
		if(1)
			to_chat(user, "The match is lit.")
		if(0)
			to_chat(user, "The match is unlit and ready to be used.")
		if(-1)
			to_chat(user, "The match is burnt.")

//Also updates the name, the damage and item_state for good measure
/obj/item/weapon/match/update_icon()

	switch(lit)
		if(1)
			name = "lit [initial(name)]"
			item_state = "[initial(item_state)]on"
			icon_state = "[initial(icon_state)]_lit"
			damtype = BURN
		if(0)
			name = "[initial(name)]"
			item_state = "[initial(item_state)]off"
			icon_state = "[initial(icon_state)]_unlit"
			damtype = BRUTE
		if(-1)
			name = "burnt [initial(name)]"
			item_state = "[initial(item_state)]off"
			icon_state = "[initial(icon_state)]_burnt"
			damtype = BRUTE

/obj/item/weapon/match/proc/update_brightness()


	if(lit == 1) //I wish I didn't need the == 1 part, but Dreamkamer is a dumb puppy
		processing_objects.Add(src)
		set_light(brightness_on)
	else
		processing_objects.Remove(src)
		set_light(0)
	update_icon()

/obj/item/weapon/match/process()
	var/turf/location = get_turf(src)
	smoketime--
	if(smoketime <= 0)
		lit = -1
		update_brightness()
		return
	if(location)
		location.hotspot_expose(heat_production, 5, surfaces = istype(loc, /turf))
		return

/obj/item/weapon/match/is_hot()
	if(lit == 1)
		return heat_production
	return 0

/obj/item/weapon/match/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(istype(M.wear_mask, /obj/item/clothing/mask/cigarette) && user.zone_sel.selecting == "mouth" && lit == 1)
		var/obj/item/clothing/mask/cigarette/cig = M.wear_mask
		if(M == user)
			cig.attackby(src, user)
		else
			cig.light("<span class='notice'>[user] holds \the [name] out for [M], and lights \his [cig.name].</span>")
	else
		return ..()

/*
/obj/item/weapon/match/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(W.is_hot())
		lit = 1
		update_brightness()
		user.visible_message("[user] lights \the [src] with \the [W].", \
		"You light \the [src] with \the [W].")
	..()
*/

/obj/item/weapon/match/strike_anywhere
	name = "strike-anywhere match"
	desc = "An improved match stick, used to start fires easily, preferably at the end of a smoke. Can be lit against any surface"

/obj/item/weapon/match/strike_anywhere/afterattack(atom/target, mob/user, prox_flags)
	if(!prox_flags == 1)
		return

	if(!(get_turf(src) == get_turf(user)))
		return

	if(lit)
		return

	if(istype(target, /obj) || istype(target, /turf))
		lit = 1
		update_brightness()
		user.visible_message("[user] strikes \the [src] on \the [target].", \
		"You strike \the [src] on \the [target].")

//////////////////
//FINE SMOKABLES//
//////////////////

//Doubles as a mask entity, aka can be put to your mouth like a real cigarette
/obj/item/clothing/mask/cigarette
	name = "cigarette"
	desc = "A roll of tobacco and nicotine. Not the best thing to have on your face in the event of a plasma flood."
	icon_state = "cig"
	item_state = "cig"
	w_class = 1
	body_parts_covered = null
	attack_verb = list("burnt", "singed")
	heat_production = 1000
	light_color = LIGHT_COLOR_FIRE
	var/lit = 0
	var/overlay_on = "ciglit" //Apparently not used
	var/type_butt = /obj/item/weapon/cigbutt
	var/lastHolder = null
	var/brightness_on = 1 //Barely enough to see where you're standing, it's a boring old cigarette
	var/smoketime = 300
	var/chem_volume = 15

/obj/item/clothing/mask/cigarette/New()
	..()
	flags |= NOREACT // so it doesn't react until you light it
	create_reagents(chem_volume) // making the cigarrete a chemical holder with a maximum volume of 15
	update_brightness()

/obj/item/clothing/mask/cigarette/examine(mob/user)

	..()
	to_chat(user, "\The [src] is [lit ? "":"un"]lit")//Shared with all cigarette sub-types


//Also updates the name, the damage and item_state for good measure
/obj/item/clothing/mask/cigarette/update_icon()

	switch(lit)
		if(1)
			name = "lit [initial(name)]"
			item_state = "[initial(item_state)]on"
			icon_state = "[initial(icon_state)]on"
			damtype = BURN
		if(0)
			name = "[initial(name)]"
			item_state = "[initial(item_state)]off"
			icon_state = "[initial(icon_state)]off"
			damtype = BRUTE

/obj/item/clothing/mask/cigarette/proc/update_brightness()


	if(lit)
		processing_objects.Add(src)
		set_light(brightness_on)
	else
		processing_objects.Remove(src)
		set_light(0)
	update_icon()

/obj/item/clothing/mask/cigarette/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(lit)
		return
	light("<span class='danger'>The raging fire sets \the [src] alight.</span>")

/obj/item/clothing/mask/cigarette/is_hot()
	if(lit)
		return heat_production
	return 0

/obj/item/clothing/mask/cigarette/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	if(lit) //The cigarette is already lit
		to_chat(user, "<span class='warning'>\The [src] is already lit.</span>")
		return //Don't bother

	//Items with special messages go first
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.is_hot()) //Badasses dont get blinded while lighting their cig with a welding tool
			light("<span class='notice'>[user] casually lights \his [name] with \the [W], what a badass.</span>")

	else if(istype(W, /obj/item/weapon/lighter/zippo))
		var/obj/item/weapon/lighter/zippo/Z = W
		if(Z.is_hot())
			light("<span class='rose'>With a single flick of their wrist, [user] smoothly lights \his [name] with \the [W]. Damn, that's cool.</span>")

	else if(istype(W, /obj/item/weapon/lighter))
		var/obj/item/weapon/lighter/L = W
		if(L.is_hot())
			light("<span class='notice'>After some fiddling, [user] manages to light \his [name] with \the [W].</span>")

	else if(istype(W, /obj/item/weapon/melee/energy/sword))
		var/obj/item/weapon/melee/energy/sword/S = W
		if(S.is_hot())
			light("<span class='warning'>[user] raises \his [W.name], lighting \the [src]. Holy fucking shit.</span>")

	else if(istype(W, /obj/item/device/assembly/igniter))
		var/obj/item/device/assembly/igniter/I = W
		if(I.is_hot())
			light("<span class='notice'>[user] fiddles with \his [W.name], and manages to light their [name].</span>")

	//All other items are included here, any item that is hot can light the cigarette
	else if(W.is_hot())
		light("<span class='notice'>[user] lights \his [name] with \the [W].</span>")
	return


/obj/item/clothing/mask/cigarette/afterattack(obj/item/weapon/reagent_containers/glass/glass, mob/user as mob)
	..()
	if(istype(glass))	//You can dip cigarettes into beakers and beaker subtypes
		if(glass.reagents.has_reagent("sacid") || glass.reagents.has_reagent("pacid")) //Dumping into acid, a dumb idea
			new type_butt(get_turf(glass))
			processing_objects.Remove(src)
			to_chat(user, "<span class='warning'>Half of \the [src] dissolves with a nasty fizzle as you dip it into \the [glass].</span>")
			user.drop_item(src)
			qdel(src)
			return
		if(glass.reagents.has_reagent("water") && lit) //Dumping a lit cigarette into water, the result is obvious
			new type_butt(get_turf(glass))
			processing_objects.Remove(src)
			to_chat(user, "<span class='warning'>\The [src] fizzles as you dip it into \the [glass].</span>")
			user.drop_item(src)
			qdel(src)
			return
		var/transfered = glass.reagents.trans_to(src, chem_volume)
		if(transfered)	//If reagents were transfered, show the message
			to_chat(user, "<span class='notice'>You dip \the [src] into \the [glass].</span>")
		else	//If not, either the beaker was empty, or the cigarette was full
			if(!glass.reagents.total_volume) //Only show an explicit message if the beaker was empty, you can't tell a cigarette is "full"
				to_chat(user, "<span class='warning'>\The [glass] is empty.</span>")
				return

/obj/item/clothing/mask/cigarette/proc/light(var/flavor_text = "[usr] lights \the [src].")
	if(lit) //Failsafe
		return //"Normal" situations were already handled in attackby, don't show a message

	if(reagents.get_reagent_amount("water")) //The cigarette was dipped into water, it's useless now
		to_chat(usr, "<span class='warning'>You fail to light \the [src]. It appears to be wet.</span>")
		return

	if(reagents.get_reagent_amount("plasma")) //Plasma explodes when exposed to fire
		var/datum/effect/effect/system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount("plasma")/2.5, 1), get_turf(src), 0, 0)
		e.start()
		if(ismob(loc))
			var/mob/M = loc
			M.drop_from_inventory(src)
		qdel(src)
		return

	if(reagents.get_reagent_amount("fuel")) //Fuel explodes, too, but much less violently
		var/datum/effect/effect/system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount("fuel")/5, 1), get_turf(src), 0, 0)
		e.start()
		if(ismob(loc))
			var/mob/M = loc
			M.drop_from_inventory(src)
		qdel(src)
		return

	lit = 1 //All checks that could have stopped the cigarette are done, let us begin

	flags &= ~NOREACT //Allow reagents to react after being lit
	flags |= (MASKINTERNALS | BLOCK_GAS_SMOKE_EFFECT)

	reagents.handle_reactions()
	//This ain't ready yet.
	//overlays.len = 0
	//overlays += image('icons/mob/mask.dmi', overlay_on, LIGHTING_LAYER+1)
	var/turf/T = get_turf(src)
	T.visible_message(flavor_text)

	update_brightness()

	//can't think of any other way to update the overlays :< //Gee, thanks
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
	if(smoketime <= 0)
		new type_butt(location) //Spawn the cigarette butt
		lit = 0 //Actually unlight the cigarette so that the lighting can update correctly
		update_brightness()
		if(ismob(loc))
			to_chat(M, "<span class='notice'>Your [name] goes out.</span>")
			M.u_equip(src, 0)	//Un-equip it so the overlays can update
		qdel(src)
		return
	if(location)
		location.hotspot_expose(700, 5, surfaces = istype(loc, /turf))
	//Oddly specific and snowflakey reagent transfer system below
	if(reagents && reagents.total_volume)	//Check if it has any reagents at all
		if(iscarbon(M) && (src == M.wear_mask)) //If it's in the human/monkey mouth, transfer reagents to the mob
			if(M.reagents.has_reagent("lexorin") || M_NO_BREATH in M.mutations || istype(M.loc, /obj/machinery/atmospherics/unary/cryo_cell))
				reagents.remove_any(REAGENTS_METABOLISM)
			else
				if(prob(25)) //So it's not an instarape in case of acid
					reagents.reaction(M, INGEST)
				reagents.trans_to(M, 1)
		else //Else just remove some of the reagents
			reagents.remove_any(REAGENTS_METABOLISM)
	return

/obj/item/clothing/mask/cigarette/attack_self(mob/user as mob)
	if(lit)
		user.visible_message("<span class='notice'>[user] calmly drops and treads on the lit [name], putting it out.</span>")
		var/turf/T = get_turf(src)
		new type_butt(T)
		lit = 0 //Needed for proper update
		update_brightness()
		qdel(src)
	return ..()

/obj/item/clothing/mask/cigarette/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!istype(M))
		return ..()

	if(!lit && M.on_fire) //Hit burning mobs with cigarettes to light it up.
		if(M == user)
			light("<span class='notice'>[user] uses \his burning body to light \the [src]. Smooth.</span>")
			return
		else
			light("<span class='notice'>[user] uses the flames on [M] to light \the [src]. How rude.</span>")
			return

	//Using another cigarette to light yours
	if(istype(M.wear_mask, /obj/item/clothing/mask/cigarette) && user.zone_sel && user.zone_sel.selecting == "mouth" && lit)
		var/obj/item/clothing/mask/cigarette/cig = M.wear_mask
		if(M == user)
			cig.attackby(src, user)
		else
			cig.light("<span class='notice'>[user] holds \his [name] out for [M], and lights \the [cig].</span>")

	else
		return ..()

////////////
// CIGARS //
////////////

/obj/item/clothing/mask/cigarette/cigar
	name = "Premium Cigar"
	desc = "A brown roll of tobacco and... well, you're not quite sure. This thing's huge!"
	icon_state = "cigar"
	overlay_on = "cigarlit"
	flags = FPRINT
	type_butt = /obj/item/weapon/cigbutt/cigarbutt
	item_state = "cigar"
	smoketime = 1500
	chem_volume = 20

/obj/item/clothing/mask/cigarette/cigar/cohiba
	name = "Cohiba Robusto Cigar"
	desc = "There's little more you could want from a cigar."
	icon_state = "cigar2"
	overlay_on = "cigar2lit"

/obj/item/clothing/mask/cigarette/cigar/havana
	name = "Premium Havanian Cigar"
	desc = "A cigar fit for only the best for the best."
	icon_state = "cigar2"
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

/*
//I'll light my cigar with an energy sword if I want to, thanks
/obj/item/clothing/mask/cigarette/cigar/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/match))
		..()
	else
		to_chat(user, "<span class='notice'>\The [src] straight out REFUSES to be lit by such uncivilized means.</span>")
*/

///////////////////
//AMBROSIA BLUNTS//
///////////////////

/obj/item/clothing/mask/cigarette/blunt
	name = "blunt"
	desc = "A special homemade cigar. Light it up and pass it around."
	icon_state = "blunt"
	overlay_on = "bluntlit"
	type_butt = /obj/item/weapon/cigbutt/bluntbutt
	item_state = "blunt"
	attack_verb = list("burnt", "singed", "blunted")
	smoketime = 420
	chem_volume = 50 //It's a fat blunt, a really fat blunt

/obj/item/clothing/mask/cigarette/blunt/rolled //grown.dm handles reagents for these

/obj/item/clothing/mask/cigarette/blunt/cruciatus

/obj/item/clothing/mask/cigarette/blunt/cruciatus/New()
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("space_drugs", 7)
	reagents.add_reagent("kelotane", 7)
	reagents.add_reagent("bicaridine", 5)
	reagents.add_reagent("toxin", 5)
	reagents.add_reagent("spiritbreaker", 10)
	update_brightness()

/obj/item/clothing/mask/cigarette/blunt/cruciatus/rolled

/obj/item/clothing/mask/cigarette/blunt/deus
	name = "godblunt"
	desc = "A fat ambrosia deus cigar. Smoke weed every day."
	icon_state = "dblunt"
	overlay_on = "dbluntlit"

/obj/item/clothing/mask/cigarette/blunt/deus/New()
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("bicaridine", 7)
	reagents.add_reagent("synaptizine", 7)
	reagents.add_reagent("hyperzine", 5)
	reagents.add_reagent("space_drugs", 5)
	update_brightness()

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
	flags = FPRINT
	icon_state = "pipe"
	item_state = "pipe"
	overlay_on = "pipelit"
	smoketime = 100

/obj/item/clothing/mask/cigarette/pipe/light(var/flavor_text = "[usr] lights the [name].")
	if(!src.lit)
		lit = 1
		damtype = BURN
		update_brightness()
		var/turf/T = get_turf(src)
		T.visible_message(flavor_text)
		if(istype(loc,/mob))
			var/mob/M = loc
			if(M.wear_mask == src)
				M.update_inv_wear_mask(0)

/obj/item/clothing/mask/cigarette/pipe/process()
	var/turf/location = get_turf(src)
	smoketime--
	if(smoketime <= 0)
		new /obj/effect/decal/cleanable/ash(location)
		lit = 0
		if(ismob(loc))
			var/mob/living/M = loc
			M.visible_message("<span class='notice'>[M]'s [name] goes out.</span>", \
			"<span class='notice'>Your [name] goes out, and you empty the ash.</span>")
			if(M.wear_mask == src)
				M.update_inv_wear_mask(0)
		update_brightness()
		return
	if(location)
		location.hotspot_expose(700, 5, surfaces = istype(loc, /turf))
	return

/obj/item/clothing/mask/cigarette/pipe/attack_self(mob/user as mob) //Refills the pipe. Can be changed to an attackby later, if loose tobacco is added to vendors or something. //Later meaning never
	if(lit)
		user.visible_message("<span class='notice'>[user] puts out \the [src].</span>", \
							"<span class='notice'>You put out \the [src].</span>")
		lit = 0
		update_brightness()
		return
	if(smoketime < initial(smoketime)) //Warrants a refill
		user.visible_message("<span class='notice'>[user] refills \the [src].</span>", \
							"<span class='notice'>You refill \the [src].</span>")
		smoketime = initial(smoketime)
	return

/*
//Ditto above, only a ruffian would refuse to light his pipe with an energy sword
/obj/item/clothing/mask/cigarette/pipe/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/match))
		..()
	else
		to_chat(user, "<span class='notice'>\The [src] straight out REFUSES to be lit by such means.</span>")
*/

/obj/item/clothing/mask/cigarette/pipe/cobpipe
	name = "corn cob pipe"
	desc = "A nicotine delivery system popularized by folksy backwoodsmen and kept popular in the modern age and beyond by space hipsters."
	icon_state = "cobpipe"
	item_state = "cobpipe"
	smoketime = 400

/////////
//ZIPPO//
/////////

/obj/item/weapon/lighter
	name = "cheap lighter"
	desc = "A budget lighter. More likely lit more fingers than it did light smokes."
	icon = 'icons/obj/items.dmi'
	icon_state = "lighter-g"
	item_state = "lighter-g"
	w_class = 1
	throwforce = 4
	flags = null
	siemens_coefficient = 1
	var/brightness_on = 2 //Sensibly better than a match or a cigarette
	var/lightersound = list('sound/items/lighter1.ogg','sound/items/lighter2.ogg')
	var/fuel = 20
	var/fueltime
	heat_production = 1500
	slot_flags = SLOT_BELT
	attack_verb = list("burnt", "singed")
	light_color = LIGHT_COLOR_FIRE
	var/lit = 0

/obj/item/weapon/lighter/zippo
	name = "Zippo lighter"
	desc = "The Zippo lighter. Need to light a smoke ? Zippo !"
	icon_state = "zippo"
	item_state = "zippo"
	var/open_sound = list('sound/items/zippo_open.ogg')
	var/close_sound = list('sound/items/zippo_close.ogg')
	fuel = 100 //Zippos da bes

/obj/item/weapon/lighter/random/New()
	. = ..()
	var/color = pick("r","c","y","g")
	icon_state = "lighter-[color]"
	update_brightness()

/obj/item/weapon/lighter/examine(mob/user)

	..()
	to_chat(user, "The lighter is [lit ? "":"un"]lit")

//Also updates the name, the damage and item_state for good measure
/obj/item/weapon/lighter/update_icon()

	switch(lit)
		if(1)
			name = "lit [initial(name)]"
			item_state = "[initial(item_state)]on"
			icon_state = "[initial(icon_state)]-on"
			damtype = BURN
		if(0)
			name = "[initial(name)]"
			item_state = "[initial(item_state)]off"
			icon_state = "[initial(icon_state)]"
			damtype = BRUTE

/obj/item/weapon/lighter/proc/update_brightness()


	if(lit)
		processing_objects.Add(src)
		set_light(brightness_on)
	else
		processing_objects.Remove(src)
		set_light(0)
	update_icon()

/obj/item/weapon/lighter/afterattack(obj/O, mob/user, proximity)
	if(!proximity)
		return 0
	if(istype(O, /obj/structure/reagent_dispensers/fueltank))
		fuel += O.reagents.remove_any(initial(fuel) - fuel)
		user.visible_message("<span class='notice'>[user] refuels \the [src].</span>", \
		"<span class='notice'>You refuel \the [src].</span>")
		playsound(get_turf(src), 'sound/effects/refill.ogg', 50, 1, -6)
		return
/obj/item/weapon/lighter/attack_self(mob/living/user)

	user.delayNextAttack(5) //Hold on there cowboy
	if(!fuel)
		user.visible_message("<span class='rose'>[user] attempts to light \the [src] to no avail.</span>", \
		"<span class='notice'>\The [src] doesn't have enough fuel to ignite</span>")
		return
	if(!lit) //Lighting the lighter
		playsound(get_turf(src), pick(lightersound), 50, 1)
		if(fuel >= initial(fuel) - 5 || prob(100 * (fuel/initial(fuel)))) //Strike, but fail to light it
			user.visible_message("<span class='notice'>[user] manages to light \the [src].</span>", \
			"<span class='notice'>You manage to light \the [src].</span>")
			lit = !lit
			update_brightness()
			--fuel
			return
		else //Failure
			user.visible_message("<span class='notice'>[user] tries to light \the [src].</span>", \
			"<span class='notice'>You try to light \the [src].</span>")
			return
	else
		fueltime = null
		lit = !lit
		user.visible_message("<span class='notice'>[user] quietly shuts off \the [src].</span>", \
		"<span class='notice'>You quietly shut off \the [src].</span>")
		update_brightness()

/obj/item/weapon/lighter/zippo/attack_self(mob/living/user)
	user.delayNextAttack(5) //Hold on there cowboy
	if(!fuel)
		user.visible_message("<span class='rose'>[user] attempts to light \the [src] to no avail.</span>", \
		"<span class='notice'>\The [src] doesn't have enough fuel to ignite</span>")
		return
	lit = !lit
	if(lit) //Was lit
		playsound(get_turf(src), pick(open_sound), 50, 1)
		user.visible_message("<span class='rose'>Without even breaking stride, [user] flips open and lights \the [src] in one smooth movement.</span>", \
		"<span class='rose'>Without even breaking stride, you flip open and light \the [src] in one smooth movement.</span>")
		--fuel
	else //Was shut off
		fueltime = null
		playsound(get_turf(src), pick(close_sound), 50, 1)
		user.visible_message("<span class='rose'>You hear a quiet click as [user] shuts off \the [src] without even looking at what they're doing. Wow.</span>", \
		"<span class='rose'>You hear a quiet click as you shut off \the [src] without even looking at what you are doing.</span>")
	update_brightness()

/obj/item/weapon/lighter/is_hot()
	if(lit)
		return heat_production
	return 0

/obj/item/weapon/lighter/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(istype(M.wear_mask, /obj/item/clothing/mask/cigarette) && user.zone_sel.selecting == "mouth" && lit)
		var/obj/item/clothing/mask/cigarette/cig = M.wear_mask
		if(M == user)
			cig.attackby(src, user)
		else
			if(istype(src, /obj/item/weapon/lighter/zippo))
				cig.light("<span class='rose'>[user] whips \his [name] out and holds it for [M]. Their arm is as steady as the unflickering flame they light \the [cig] with.</span>")
			else
				cig.light("<span class='notice'>[user] holds \his [name] out for [M] and lights \the [cig].</span>")
	else
		return ..()

/obj/item/weapon/lighter/process()
	var/turf/location = get_turf(src)
	if(location)
		location.hotspot_expose(700, 5, surfaces = istype(loc, /turf))
	if(!fueltime)
		fueltime = world.time + 100
	if(world.time > fueltime)
		fueltime = world.time + 100
		--fuel
		if(!fuel)
			lit = 0
			update_brightness()
			visible_message("<span class='warning'>Without warning \the [src] suddenly shuts off</span>")
			fueltime = null
	return
