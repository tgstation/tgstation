// The lighting system
//
// consists of light fixtures (/obj/machinery/light) and light tube/bulb items (/obj/item/weapon/light)


// status values shared between lighting fixtures and items
#define LIGHT_OK 0
#define LIGHT_EMPTY 1
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3

// the standard tube light fixture

/obj/machinery/light
	name = "light fixture"
	icon = 'lighting.dmi'
	var/base_state = "tube"		// base description and icon_state
	icon_state = "tube1"
	desc = "A lighting fixture."
	anchored = 1
	layer = 5  					// They were appearing under mobs which is a little weird - Ostaf
	use_power = 2
	idle_power_usage = 2
	active_power_usage = 20
	power_channel = LIGHT //Lights are calc'd via area so they dont need to be in the machine list
	var/on = 0					// 1 if on, 0 if off
	var/on_gs = 0
	var/brightness = 8			// luminosity when on, also used in power calculation
	var/status = LIGHT_OK		// LIGHT_OK, _EMPTY, _BURNED or _BROKEN

	var/light_type = /obj/item/weapon/light/tube		// the type of light item
	var/fitting = "tube"
	var/switchcount = 0			// count of number of times switched on/off
								// this is used to calc the probability the light burns out

	var/rigged = 0				// true if rigged to explode

// the smaller bulb light fixture

/obj/machinery/light/small
	icon_state = "bulb1"
	base_state = "bulb"
	fitting = "bulb"
	brightness = 3
	desc = "A small lighting fixture."
	light_type = /obj/item/weapon/light/bulb

/obj/machinery/light/small/spot
	brightness = 5

/obj/machinery/light/spot
	name = "spotlight"
	fitting = "large tube"
	light_type = /obj/item/weapon/light/tube/large
	brightness = 15

// the desk lamp
/obj/machinery/light/lamp
	name = "desk lamp"
	icon_state = "lamp1"
	base_state = "lamp"
	fitting = "bulb"
	brightness = 7
	desc = "A desk lamp"
	light_type = /obj/item/weapon/light/bulb
	var/switchon = 0		// independent switching for lamps - not controlled by area lightswitch

// green-shaded desk lamp
/obj/machinery/light/lamp/green
	icon_state = "green1"
	base_state = "green"
	desc = "A green-shaded desk lamp"


// create a new lighting fixture
/obj/machinery/light/New()
	..()

	spawn(2)
		switch(fitting)
			if("tube")
				if(src.loc && src.loc.loc && isarea(src.loc.loc))
					var/area/A = src.loc.loc
					brightness = A.area_lights_luminosity
				else
					brightness = rand(6,7)
				if(prob(5))
					broken(1)
			if("bulb")
				brightness = rand(4,5)
				if(prob(15))
					broken(1)
		spawn(1)
			update()

/obj/machinery/light/Del()
	var/area/A = get_area(src)
	if(A)
		on = 0
//		A.update_lights()
	..()


// update the icon_state and luminosity of the light depending on its state
/obj/machinery/light/proc/update()

	switch(status)		// set icon_states
		if(LIGHT_OK)
			icon_state = "[base_state][on]"
		if(LIGHT_EMPTY)
			icon_state = "[base_state]-empty"
			on = 0
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
			on = 0
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"
			on = 0
	if(!on)
		use_power = 1
	else
		use_power = 2
	var/oldlum = luminosity

	//luminosity = on * brightness
	ul_SetLuminosity(on * brightness, on * brightness, ( fitting != "bulb" ? on * brightness  : round(on*brightness/2) ) )		// *DAL*

	// if the state changed, inc the switching counter
	if(oldlum != luminosity)
		switchcount++

		// now check to see if the bulb is burned out
		if(status == LIGHT_OK)
			if(on && rigged)
				explode()
			if( prob( min(60, switchcount*switchcount*0.01) ) )
				status = LIGHT_BURNED
				icon_state = "[base_state]-burned"
				on = 0
				ul_SetLuminosity(0)
	active_power_usage = (luminosity * 20)
	if(on != on_gs)
		on_gs = on
//		var/area/A = get_area(src)
//		if(A)
//			A.update_lights()


// attempt to set the light's on/off status
// will not switch on if broken/burned/empty
/obj/machinery/light/proc/seton(var/s)
	on = (s && status == LIGHT_OK)
	update()

// examine verb
/obj/machinery/light/examine()
	set src in oview(1)
	if(usr && !usr.stat)
		switch(status)
			if(LIGHT_OK)
				usr << "[desc] It is turned [on? "on" : "off"]."
			if(LIGHT_EMPTY)
				usr << "[desc] The [fitting] has been removed."
			if(LIGHT_BURNED)
				usr << "[desc] The [fitting] is burnt out."
			if(LIGHT_BROKEN)
				usr << "[desc] The [fitting] has been smashed."



// attack with item - insert light (if right type), otherwise try to break the light

/obj/machinery/light/attackby(obj/item/W, mob/user)

	// attempt to insert light
	if(istype(W, /obj/item/weapon/light))
		if(status != LIGHT_EMPTY)
			user << "There is a [fitting] already inserted."
			return
		else
			src.add_fingerprint(user)
			var/obj/item/weapon/light/L = W
			if(istype(L, light_type))
				status = L.status
				user << "You insert the [L.name]."
				switchcount = L.switchcount
				rigged = L.rigged
				brightness = L.brightness
				del(L)

				on = has_power()
				update()
				user.update_clothing()
				if(on && rigged)
					explode()
			else
				user << "This type of light requires a [fitting]."
				return

	// attempt to take light apart
	else if(istype(W, /obj/item/weapon/wirecutters))
		if(status == LIGHT_EMPTY)
			playsound(src.loc, 'Wirecutter.ogg', 100, 1)
			var/turf/T = get_turf(user)
			user.visible_message("[user] cuts the light's wiring.", "You start to cut the light's wiring.")
			sleep(40)
			if(get_turf(user) == T)
				usr << "\blue You cut the light's wiring."
				var/obj/structure/light_frame/F = new(loc)
				F.anchored = 1
				F.name = "Secured Light Fixture Frame"
				F.dir = dir
				F.light_type = type
				F.icon_state = icon_state
				del(src)
		else
			user << "\blue You need to remove the [fitting] first!"

		// attempt to break the light
		//If xenos decide they want to smash a light bulb with a toolbox, who am I to stop them? /N

	else if(status != LIGHT_BROKEN && status != LIGHT_EMPTY)


		if(prob(1+W.force * 5))

			user << "You hit the light, and it smashes!"
			for(var/mob/M in viewers(src))
				if(M == user)
					continue
				M.show_message("[user.name] smashed the light!", 3, "You hear a tinkle of breaking glass", 2)
			if(on && (W.flags & CONDUCT))
				//if(!(COLD_RESISTANCE in user.mutations))
				if (prob(12))
					electrocute_mob(user, get_area(src), src, 0.3)
			broken()

		else
			user << "You hit the light!"

	// attempt to stick weapon into light socket
	else if(status == LIGHT_EMPTY)
		user << "You stick \the [W] into the light socket!"
		if(has_power() && (W.flags & CONDUCT))
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			//if(!(COLD_RESISTANCE in user.mutations))
			if (prob(75))
				electrocute_mob(user, get_area(src), src, rand(0.7,1.0))


// returns whether this light has power
// true if area has power and lightswitch is on
/obj/machinery/light/proc/has_power()
	var/area/A = src.loc.loc
	return A.master.lightswitch && A.master.power_light


// ai attack - do nothing

/obj/machinery/light/attack_ai(mob/user)
	return

// Aliens smash the bulb but do not get electrocuted./N
/obj/machinery/light/attack_alien(mob/living/carbon/alien/humanoid/user)//So larva don't go breaking light bulbs.
	if(status == LIGHT_EMPTY||status == LIGHT_BROKEN)
		user << "\green That object is useless to you."
		return
	else if (status == LIGHT_OK||status == LIGHT_BURNED)
		for(var/mob/M in viewers(src))
			M.show_message("\red [user.name] smashed the light!", 3, "You hear a tinkle of breaking glass", 2)
		broken()
	return
// attack with hand - remove tube/bulb
// if hands aren't protected and the light is on, burn the player

/obj/machinery/light/attack_hand(mob/user)

	add_fingerprint(user)

	if(status == LIGHT_EMPTY)
		user << "There is no [fitting] in this light."
		return

	// make it burn hands if not wearing fire-insulated gloves
	if(on)
		var/prot = 0
		var/mob/living/carbon/human/H = user

		if(istype(H))

			if(H.gloves)
				var/obj/item/clothing/gloves/G = H.gloves

				prot = (G.heat_transfer_coefficient < 0.5)	// *** TODO: better handling of glove heat protection
		else
			prot = 1

		if(prot > 0 || (COLD_RESISTANCE in user.mutations))
			user << "You remove the light [fitting]"
		else
			user << "You try to remove the light [fitting], but you burn your hand on it!"

			var/datum/organ/external/affecting = H.get_organ("[user.hand ? "l" : "r" ]_arm")

			affecting.take_damage( 0, 5 )		// 5 burn damage

			H.updatehealth()
			H.UpdateDamageIcon()
			return				// if burned, don't remove the light

	// create a light tube/bulb item and put it in the user's hand
	var/obj/item/weapon/light/L = new light_type()
	L.status = status
	L.rigged = rigged
	L.brightness = src.brightness
	L.loc = usr
	L.layer = 20
	if(user.hand)
		user.l_hand = L
	else
		user.r_hand = L

	// light item inherits the switchcount, then zero it
	L.switchcount = switchcount
	switchcount = 0


	L.update()
	L.add_fingerprint(user)

	status = LIGHT_EMPTY
	update()
	user.update_clothing()

// break the light and make sparks if was on

/obj/machinery/light/proc/broken(var/skip_sound_and_sparks = 0)
	if(status == LIGHT_EMPTY)
		return

	if(!skip_sound_and_sparks)
		if(status == LIGHT_OK || status == LIGHT_BURNED)
			playsound(src.loc, 'Glasshit.ogg', 75, 1)
		if(on)
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, src)
			s.start()
	status = LIGHT_BROKEN
	update()

// explosion effect
// destroy the whole light fixture or just shatter it

/obj/machinery/light/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(75))
				broken()
		if(3.0)
			if (prob(50))
				broken()
	return

//blob effect

/obj/machinery/light/blob_act()
	if(prob(75))
		broken()


// timed process
// use power

#define LIGHTING_POWER_FACTOR 20		//20W per unit luminosity

/obj/machinery/light/process()
	return
//	if(on)
//		use_power(luminosity * LIGHTING_POWER_FACTOR, LIGHT)

// called when area power state changes
/obj/machinery/light/power_change()
	spawn(10)
		var/area/A = src.loc.loc
		A = A.master
		seton(A.lightswitch && A.power_light)

// called when on fire

/obj/machinery/light/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(prob(max(0, exposed_temperature - 673)))   //0% at <400C, 100% at >500C
		broken()

// explode the light

/obj/machinery/light/proc/explode()
	var/turf/T = get_turf(src)
	spawn(0)
		broken()	// break it first to give a warning
		sleep(2)
		explosion(T, 0, 1, 2, 2)
		sleep(1)
		del(src)




// special handling for desk lamps


// if attack with hand, only "grab" attacks are an attempt to remove bulb
// otherwise, switch the lamp on/off

/obj/machinery/light/lamp/attack_hand(mob/user)

	if(user.a_intent == "grab")
		..()	// do standard hand attack
	else
		switchon = !switchon
		user << "You switch [switchon ? "on" : "off"] the [name]."
		seton(switchon && powered(LIGHT))


// called when area power state changes
// override since lamp does not use area lightswitch

/obj/machinery/light/lamp/power_change()
	spawn(rand(0,15))
		var/area/A = src.loc.loc
		A = A.master
		seton(switchon && A.power_light)

// returns whether this lamp has power
// true if area has power and lamp switch is on

/obj/machinery/light/lamp/has_power()
	var/area/A = src.loc.loc
	return switchon && A.master.power_light






// the light item
// can be tube or bulb subtypes
// will fit into empty /obj/machinery/light of the corresponding type

/obj/item/weapon/light
	icon = 'lighting.dmi'
	flags = FPRINT | TABLEPASS
	force = 2
	throwforce = 5
	w_class = 1
	var/status = 0		// LIGHT_OK, LIGHT_BURNED or LIGHT_BROKEN
	var/base_state
	var/switchcount = 0	// number of times switched
	m_amt = 60
	var/rigged = 0		// true if rigged to explode
	var/brightness = 2 //how much light it gives off
	var/repair_state = 0

/obj/item/weapon/light/tube
	name = "light tube"
	desc = "A replacement light tube."
	icon_state = "ltube"
	base_state = "ltube"
	item_state = "c_tube"
	g_amt = 200
	brightness = 8

	large
		w_class = 2
		name = "large light tube"
		brightness = 15

/obj/item/weapon/light/bulb
	name = "light bulb"
	desc = "A replacement light bulb."
	icon_state = "lbulb"
	base_state = "lbulb"
	item_state = "contvapour"
	g_amt = 100
	brightness = 5

// update the icon state and description of the light
/obj/item/weapon/light
	proc/update()
		switch(status)
			if(LIGHT_OK)
				icon_state = base_state
				desc = "A replacement [name]."
			if(LIGHT_BURNED)
				icon_state = "[base_state]-burned"
				desc = "A burnt-out [name]."
				if(repair_state == 1)
					desc += " It has some wires hanging out."
			if(LIGHT_BROKEN)
				icon_state = "[base_state]-broken"
				desc = "A broken [name]."
				if(repair_state == 1)
					desc += " It has some wires hanging out."
				else if(repair_state == 2)
					desc += " It has had new wires put in."


/obj/item/weapon/light/New()
	..()
	switch(name)
		if("light tube")
			brightness = rand(6,9)
		if("light bulb")
			brightness = rand(4,6)
	update()


// attack bulb/tube with object
// if a syringe, can inject plasma to make it explode
// also repairing them with wire and screwdriver
// and glass if it's broken
/obj/item/weapon/light/attackby(var/obj/item/I, var/mob/user)

	if(istype(I, /obj/item/weapon/reagent_containers/syringe))
		var/obj/item/weapon/reagent_containers/syringe/S = I

		user << "You inject the solution into the [src]."

		if(S.reagents.has_reagent("plasma", 5))

			log_attack("<font color='red'>[user.name] ([user.ckey]) injected a light with plasma.</font>")
			log_admin("ATTACK: [user] ([user.ckey]) injected a light with plasma.")
			message_admins("ATTACK: [user] ([user.ckey]) injected a light with plasma.")

			rigged = 1

		S.reagents.clear_reagents()
		return
	if(status != 0)
		if(istype(I, /obj/item/weapon/cable_coil) && repair_state == 0)
			user << "You put some new wiring into the [src]."
			I:use(1)
			repair_state = 1
			update()
			return
		if(istype(I, /obj/item/weapon/screwdriver) && repair_state == 1)
			user << "You attach the new wiring."
			playsound(src.loc, 'Screwdriver.ogg', 100, 1)
			if(status == LIGHT_BURNED)
				repair_state = 0
				status = LIGHT_OK
			else
				repair_state = 2
			update()
			return
		if(istype(I, /obj/item/stack/sheet/glass) && status == LIGHT_BROKEN)
			user << "You repair the glass of the [src]." //this is worded terribly
			I:use(1)
			force = 2 //because breaking it changes the force, this changes it back
			if(repair_state == 2)
				repair_state = 0
				status = LIGHT_OK
			else
				status = LIGHT_BURNED
			update()
			return
	..()
	return

// called after an attack with a light item
// shatter light, unless it was an attempt to put it in a light socket
// now only shatter if the intent was harm

/obj/item/weapon/light/afterattack(atom/target, mob/user)
	if(istype(target, /obj/machinery/light))
		return
	if(user.a_intent != "hurt")
		return

	if(status == LIGHT_OK || status == LIGHT_BURNED)
		user << "The [name] shatters!"
		status = LIGHT_BROKEN
		force = 5
		playsound(src.loc, 'Glasshit.ogg', 75, 1)
		update()



// a box of replacement light items

/obj/item/weapon/storage/lightbox
	name = "replacement bulbs"
	icon = 'storage.dmi'
	icon_state = "light"
	desc = "This box is shaped on the inside so that only light tubes and bulbs fit."
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard //BubbleWrap
	storage_slots=21
	can_hold = list("/obj/item/weapon/light/tube", "/obj/item/weapon/light/bulb")
	max_combined_w_class = 21

/obj/item/weapon/storage/lightbox/bulbs/New()
	..()
	for(var/i = 0; i < 21; i++)
		new /obj/item/weapon/light/bulb(src)

/obj/item/weapon/storage/lightbox/tubes
	name = "replacement tubes"
	icon_state = "lighttube"

/obj/item/weapon/storage/lightbox/tubes/New()
	..()
	for(var/i = 0; i < 21; i++)
		new /obj/item/weapon/light/tube(src)

/obj/item/weapon/storage/lightbox/mixed
	name = "replacement lights"
	icon_state = "lightmixed"

/obj/item/weapon/storage/lightbox/mixed/New()
	..()
	for(var/i = 0; i < 14; i++)
		new /obj/item/weapon/light/tube(src)
	for(var/i = 0; i < 7; i++)
		new /obj/item/weapon/light/bulb(src)

/obj/structure/light_frame
	name = "Light Fixture Frame"
	icon = 'lighting.dmi'
	icon_state = "tube-empty"
	desc = "A lighting fixture frame."
	anchored = 0
	layer = 5
	var/light_type = /obj/machinery/light
	var/wired = 0
	m_amt = 1000

/obj/structure/light_frame/small
	light_type = /obj/machinery/light/small
	icon_state = "bulb-empty"

/obj/structure/light_frame/lamp
	light_type = /obj/machinery/light/lamp
	icon_state = "lamp-empty"

/obj/structure/light_frame/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench) && !anchored)
		playsound(src.loc, 'Ratchet.ogg', 100, 1)
		var/turf/T = get_turf(user)
		user.visible_message("[user] secures the light fixture.", "You start to secure the light fixture.")
		sleep(40)
		if(get_turf(user) == T)
			usr << "\blue You secure the light fixture."
			anchored = 1
			name = "Secured Light Fixture Frame"
	else if(istype(W, /obj/item/weapon/wrench) && anchored)
		playsound(src.loc, 'Ratchet.ogg', 100, 1)
		var/turf/T = get_turf(user)
		user.visible_message("[user] unsecures the light fixture.", "You start to unsecure the light fixture.")
		sleep(40)
		if(get_turf(user) == T)
			usr << "\blue You unsecure the light fixture."
			anchored = 0
			name = "Light Fixture Frame"
	else if(istype(W, /obj/item/weapon/cable_coil) && anchored)
		var/turf/T = get_turf(user)
		user.visible_message("[user] wires the light fixture.", "You start to wire the light fixture.")
		sleep(40)
		if(get_turf(user) == T)
			var/obj/item/weapon/cable_coil/C = W
			C.use(1)
			usr << "\blue You wire the light fixture."
			var/obj/machinery/light/L = new light_type(loc)
			L.dir = dir
			L.status = LIGHT_EMPTY
			L.update()
			del(src)
	else if(istype(W, /obj/item/weapon/screwdriver) && !anchored)
		playsound(src.loc, 'Screwdriver.ogg', 100, 1)
		usr << "\blue You take apart the light fixture."
		new /obj/item/stack/sheet/metal(loc)
		del(src)
	else
		..()

/obj/structure/light_frame/verb/rotate()
	set name = "Rotate Light"
	set category = "Object"
	set src in oview(1)

	if (src.anchored)
		usr << "It is fastened to the wall; therefore, you can't rotate it!"
		return 0

	src.dir = turn(src.dir, 90)
	return
