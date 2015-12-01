// The lighting system
//
// consists of light fixtures (/obj/machinery/light) and light tube/bulb items (/obj/item/weapon/light)

// status values shared between lighting fixtures and items
#define LIGHT_OK     0
#define LIGHT_EMPTY  1
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3


/obj/machinery/light_construct
	name = "light fixture frame"
	desc = "A light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-stage1"
	anchored = 1
	layer = 5
	var/stage = 1
	var/fixture_type = "tube"
	var/sheets_refunded = 2
	var/obj/machinery/light/newlight = null

/obj/machinery/light_construct/New()
	..()
	if (fixture_type == "bulb")
		icon_state = "bulb-construct-stage1"

/obj/machinery/light_construct/examine(mob/user)
	..()
	var/mode
	switch(src.stage)
		if(1)
			mode = "It's empty and lacks wiring."
		if(2)
			mode = "It's wired."
	to_chat(user, "<span class='info'>[mode]</span>")

/obj/machinery/light_construct/attackby(obj/item/weapon/W as obj, mob/user as mob)
	src.add_fingerprint(user)
	if (istype(W, /obj/item/weapon/wrench))
		if (src.stage == 1)
			playsound(get_turf(src), 'sound/items/Ratchet.ogg', 75, 1)
			to_chat(usr, "You begin deconstructing [src].")
			if (!do_after(usr, src, 30))
				return
			var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
			M.amount = sheets_refunded
			user.visible_message("[user.name] deconstructs [src].", \
				"You deconstruct [src].", "You hear a noise.")
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 75, 1)
			qdel(src)
		if (src.stage == 2)
			to_chat(usr, "You have to remove the wires first.")
			return

	if(istype(W, /obj/item/stack/cable_coil))
		if (src.stage == 1)
			var/obj/item/stack/cable_coil/coil = W
			coil.use(1)
			switch(fixture_type)
				if ("tube")
					src.icon_state = "tube-empty"
				if("bulb")
					src.icon_state = "bulb-empty"
			src.stage = 2
			user.visible_message("[user.name] adds wires to \the [src].", \
				"You add wires to \the [src]")

			switch(fixture_type)
				if("tube")
					newlight = new /obj/machinery/light/built(src.loc)
				if ("bulb")
					newlight = new /obj/machinery/light/small/built(src.loc)

			newlight.dir = src.dir
			src.transfer_fingerprints_to(newlight)
			qdel(src)
			return
	..()

/obj/machinery/light_construct/small
	name = "small light fixture frame"
	desc = "A small light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "bulb-construct-stage1"
	anchored = 1
	layer = 5
	stage = 1
	fixture_type = "bulb"
	sheets_refunded = 1

var/global/list/obj/machinery/light/alllights = list()

// the standard tube light fixture
/obj/machinery/light
	name = "light fixture"
	icon = 'icons/obj/lighting.dmi'
	var/base_state = "tube"		// base description and icon_state
	icon_state = "ltube1"
	desc = "A lighting fixture."
	anchored = 1
	layer = 5  					// They were appearing under mobs which is a little weird - Ostaf
	use_power = 2
	idle_power_usage = 2
	active_power_usage = 20
	power_channel = LIGHT //Lights are calc'd via area so they dont need to be in the machine list
	var/cost = 8
	var/on = 0					// 1 if on, 0 if off
	var/on_gs = 0
	var/static_power_used = 0
	var/brightness_range = 8	// luminosity when on, also used in power calculation
	var/brightness_power = 1
	var/brightness_color = null
	var/status = LIGHT_OK		// LIGHT_OK, _EMPTY, _BURNED or _BROKEN
	var/flickering = 0
	var/light_type = /obj/item/weapon/light/tube		// the type of light item
	var/fitting = "tube"
	var/switchcount = 0			// count of number of times switched on/off
								// this is used to calc the probability the light burns out

	var/rigged = 0				// true if rigged to explode

	// No ghost interaction.
	ghost_read=0
	ghost_write=0

	var/idle = 0 // For process().

/obj/machinery/light/spook()
	if(..())
		flicker()

// the smaller bulb light fixture

/obj/machinery/light/cultify()
	new /obj/structure/cult/pylon(loc)
	qdel(src)

/obj/machinery/light/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet)||istype(Proj,/obj/item/projectile/ricochet))
		if(!istype(Proj ,/obj/item/projectile/beam/lastertag) && !istype(Proj ,/obj/item/projectile/beam/practice) )
			broken()

/obj/machinery/light/small
	icon_state = "lbulb1"
	base_state = "bulb"
	fitting = "bulb"
	brightness_range = 4
	brightness_power = 1
	brightness_color = LIGHT_COLOR_TUNGSTEN
	cost = 4
	desc = "A small lighting fixture."
	light_type = /obj/item/weapon/light/bulb


/obj/machinery/light/spot
	name = "spotlight"
	fitting = "large tube"
	light_type = /obj/item/weapon/light/tube/large
	brightness_range = 8
	brightness_power = 1
	cost = 8

/obj/machinery/light/built/New()
	status = LIGHT_EMPTY
	update(0)
	..()

/obj/machinery/light/small/built/New()
	status = LIGHT_EMPTY
	update(0)
	..()

// create a new lighting fixture
/obj/machinery/light/New()
	..()
	alllights += src

	spawn(2)
		var/area/A = get_area(src)
		if(A && !A.requires_power)
			on = 1

		switch(fitting)
			if("tube")
				if(prob(2))
					broken(1)
			if("bulb")
				if(prob(5))
					broken(1)
		spawn(1)
			update(0)

/obj/machinery/light/Destroy()
	seton(0)
	..()
	alllights -= src

/obj/machinery/light/update_icon()

	switch(status)		// set icon_states
		if(LIGHT_OK)
			icon_state = "l[base_state][on]"
		if(LIGHT_EMPTY)
			icon_state = "l[base_state]-empty"
			on = 0
		if(LIGHT_BURNED)
			icon_state = "l[base_state]-burned"
			on = 0
		if(LIGHT_BROKEN)
			icon_state = "l[base_state]-broken"
			on = 0
	return

// update the icon_state and luminosity of the light depending on its state
/obj/machinery/light/proc/update(var/trigger = 1)


	update_icon()
	if(on)
		if(light_range != brightness_range || light_power != brightness_power || light_color != brightness_color)
			switchcount++
			if(rigged)
				if(status == LIGHT_OK && trigger)

					log_admin("LOG: Rigged light explosion, last touched by [fingerprintslast]")
					message_admins("LOG: Rigged light explosion, last touched by [fingerprintslast]")

					explode()
			else if( prob( min(60, switchcount*switchcount*0.01) ) )
				if(status == LIGHT_OK && trigger)
					status = LIGHT_BURNED
					icon_state = "l[base_state]-burned"
					on = 0
					set_light(0)
			else
				use_power = 2
				set_light(brightness_range, brightness_power, brightness_color)
	else
		use_power = 1
		set_light(0)

	active_power_usage = (cost * 10)
	if(on != on_gs)
		on_gs = on
		if(on)
			static_power_used = cost * 20 //20W per unit luminosity
			addStaticPower(static_power_used, STATIC_LIGHT)
		else
			removeStaticPower(static_power_used, STATIC_LIGHT)


/*
 * Attempt to set the light's on/off status.
 * Will not switch on if broken/burned/empty.
 */
/obj/machinery/light/proc/seton(const/s)
	on = (s && LIGHT_OK == status)
	update()

// examine verb
/obj/machinery/light/examine(mob/user)
	..()
	switch(status)
		if(LIGHT_OK)
			to_chat(user, "<span class='info'>[desc] It is turned [on? "on" : "off"].</span>")
		if(LIGHT_EMPTY)
			to_chat(user, "<span class='info'>[desc] The [fitting] has been removed.</span>")
		if(LIGHT_BURNED)
			to_chat(user, "<span class='info'>[desc] The [fitting] is burnt out.</span>")
		if(LIGHT_BROKEN)
			to_chat(user, "<span class='info'>[desc] The [fitting] has been smashed.</span>")


// attack with item - insert light (if right type), otherwise try to break the light

/obj/machinery/light/attackby(obj/item/W, mob/user)
	user.delayNextAttack(8)
	//Light replacer code
	if(istype(W, /obj/item/device/lightreplacer))
		var/obj/item/device/lightreplacer/LR = W
		if(isliving(user))
			var/mob/living/U = user
			LR.ReplaceLight(src, U)
			return

	// attempt to insert light
	if(istype(W, /obj/item/weapon/light))
		if(status != LIGHT_EMPTY)
			to_chat(user, "There is a [fitting] already inserted.")
			return
		else
			src.add_fingerprint(user)
			var/obj/item/weapon/light/L = W
			if(L.fitting == fitting)
				status = L.status
				to_chat(user, "You insert \the [L.name].")
				switchcount = L.switchcount
				rigged = L.rigged
				brightness_range = L.brightness_range
				brightness_power = L.brightness_power
				brightness_color = L.brightness_color
				cost = L.cost
				base_state = L.base_state
				light_type = L.type
				on = has_power()
				update()

				user.drop_item(L)	//drop the item to update overlays and such
				qdel(L)

				if(on && rigged)

					log_admin("LOG: Rigged light explosion, last touched by [fingerprintslast]")
					message_admins("LOG: Rigged light explosion, last touched by [fingerprintslast]")

					explode()
			else
				to_chat(user, "This type of light requires a [fitting].")
				return

		// attempt to break the light
		//If xenos decide they want to smash a light bulb with a toolbox, who am I to stop them? /N

	else if(status != LIGHT_BROKEN && status != LIGHT_EMPTY)


		if(prob(1+W.force * 5))

			to_chat(user, "You hit the light, and it smashes!")
			for(var/mob/M in viewers(src))
				if(M == user)
					continue
				M.show_message("[user.name] smashed the light!", 3, "You hear a tinkle of breaking glass", 2)
			if(on && (W.is_conductor()))
				//if(!user.mutations & M_RESIST_COLD)
				if (prob(12))
					electrocute_mob(user, get_area(src), src, 0.3)
			broken()

		else
			to_chat(user, "You hit the light!")
	// attempt to deconstruct / stick weapon into light socket
	else if(status == LIGHT_EMPTY)
		if(istype(W, /obj/item/weapon/wirecutters)) //If it's a wirecutter take out the wires
			playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 75, 1)
			user.visible_message("[user.name] removes \the [src]'s wires.", \
				"You remove \the [src]'s wires.", "You hear a noise.")
			var/obj/machinery/light_construct/newlight = null
			switch(fitting)
				if("tube")
					newlight = new /obj/machinery/light_construct(src.loc)
					newlight.icon_state = "tube-construct-stage1"

				if("bulb")
					newlight = new /obj/machinery/light_construct/small(src.loc)
					newlight.icon_state = "bulb-construct-stage1"
			new /obj/item/stack/cable_coil(get_turf(src.loc), 1, "red")
			newlight.dir = src.dir
			newlight.stage = 1
			newlight.fingerprints = src.fingerprints
			newlight.fingerprintshidden = src.fingerprintshidden
			newlight.fingerprintslast = src.fingerprintslast
			qdel(src)
			return

		to_chat(user, "You stick \the [W] into the light socket!")//If not stick it in the socket.

		if(has_power() && (W.is_conductor()))
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			//if(!user.mutations & M_RESIST_COLD)
			if (prob(75))
				electrocute_mob(user, get_area(src), src, rand(0.7,1.0))

/*
 * Returns whether this light has power
 * TRUE if area has power and lightswitch is on otherwise FALSE.
 */
/obj/machinery/light/proc/has_power()
	return areaMaster.lightswitch && areaMaster.power_light

/obj/machinery/light/proc/flicker(var/amount = rand(10, 20))
	if(flickering) return
	flickering = 1
	spawn(0)
		if(on && status == LIGHT_OK)
			for(var/i = 0; i < amount; i++)
				if(status != LIGHT_OK) break
				on = !on
				update(0)
				sleep(rand(5, 15))
			on = (status == LIGHT_OK)
			update(0)
		flickering = 0
		on = has_power()

/obj/machinery/light/attack_ghost(mob/user)
	if(blessed) return
	src.add_hiddenprint(user)
	src.flicker(1)
	return

// ai attack - make lights flicker, because why not
/obj/machinery/light/attack_ai(mob/user)
	// attack_robot is flaky.
	if(isMoMMI(user))
		return attack_hand(user)
	src.add_hiddenprint(user)
	src.flicker(1)
	return

/obj/machinery/light/attack_robot(mob/user)
	if(isMoMMI(user))
		return attack_hand(user)
	else
		return attack_ai(user)


// Aliens smash the bulb but do not get electrocuted./N
/obj/machinery/light/attack_alien(mob/living/carbon/alien/humanoid/user)//So larva don't go breaking light bulbs.
	if(status == LIGHT_EMPTY||status == LIGHT_BROKEN)
		to_chat(user, "<span class='good'>That object is useless to you.</span>")
		return
	else if (status == LIGHT_OK||status == LIGHT_BURNED)
		for(var/mob/M in viewers(src))
			M.show_message("<span class='attack'>[user.name] smashed the light!</span>", 3, "You hear a tinkle of breaking glass", 2)
		broken()
	return

/obj/machinery/light/attack_animal(mob/living/simple_animal/M)
	if(M.melee_damage_upper == 0)	return
	if(status == LIGHT_EMPTY||status == LIGHT_BROKEN)
		to_chat(M, "<span class='warning'>That object is useless to you.</span>")
		return
	else if (status == LIGHT_OK||status == LIGHT_BURNED)
		for(var/mob/O in viewers(src))
			O.show_message("<span class='attack'>[M.name] smashed the light!</span>", 3, "You hear a tinkle of breaking glass", 2)
		broken()
	return
// attack with hand - remove tube/bulb
// if hands aren't protected and the light is on, burn the player

/obj/machinery/light/attack_hand(mob/user)
	if(isobserver(user))
		return

	if(!Adjacent(user)) return

	add_fingerprint(user)

	if(status == LIGHT_EMPTY)
		to_chat(user, "There is no [fitting] in this light.")
		return

	// make it burn hands if not wearing fire-insulated gloves
	if(on)
		var/prot = 0

		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.gloves)
				var/obj/item/clothing/gloves/G = H.gloves
				if(G.max_heat_protection_temperature)
					prot = (G.max_heat_protection_temperature > 360)
		else
			prot = 1

		if(prot > 0 || (M_RESIST_HEAT in user.mutations))
			to_chat(user, "You remove the light [fitting]")
		else
			to_chat(user, "You try to remove the light [fitting], but it's too hot and you don't want to burn your hand.")
			return				// if burned, don't remove the light

	// create a light tube/bulb item and put it in the user's hand
	var/obj/item/weapon/light/L = new light_type()
	L.status = status
	L.rigged = rigged
	L.brightness_range = brightness_range
	L.brightness_power = brightness_power
	L.brightness_color = brightness_color

	// light item inherits the switchcount, then zero it
	L.switchcount = switchcount
	switchcount = 0

	L.update()
	L.add_fingerprint(user)

	user.put_in_active_hand(L)	//puts it in our active hand

	status = LIGHT_EMPTY
	update()

// break the light and make sparks if was on

/obj/machinery/light/proc/broken(var/skip_sound_and_sparks = 0)
	if(status == LIGHT_EMPTY)
		return

	if(!skip_sound_and_sparks)
		if(status == LIGHT_OK || status == LIGHT_BURNED)
			playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 75, 1)
		if(on)
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, src)
			s.start()
	status = LIGHT_BROKEN
	update()

/obj/machinery/light/proc/fix()
	if(status == LIGHT_OK)
		return
	status = LIGHT_OK
	on = 1
	update()

// explosion effect
// destroy the whole light fixture or just shatter it

/obj/machinery/light/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
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
/*
 * Called when area power state changes.
 */
/obj/machinery/light/power_change()
	spawn(10)
		seton(areaMaster.lightswitch && areaMaster.power_light)

// called when on fire

/obj/machinery/light/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(prob(max(0, exposed_temperature - 673)))   //0% at <400C, 100% at >500C
		broken()

/*
 * Explode the light.
 */
/obj/machinery/light/proc/explode()
	spawn(0)
		broken() // Break it first to give a warning.
		sleep(2)
		explosion(get_turf(src), 0, 0, 2, 2)
		sleep(1)
		qdel(src)

// the light item
// can be tube or bulb subtypes
// will fit into empty /obj/machinery/light of the corresponding type

/obj/item/weapon/light
	icon = 'icons/obj/lighting.dmi'
	flags = FPRINT
	force = 2
	throwforce = 5
	w_class = 1
	var/status = 0		// LIGHT_OK, LIGHT_BURNED or LIGHT_BROKEN
	var/base_state
	var/switchcount = 0	// number of times switched
	starting_materials = list(MAT_IRON = 60)
	var/rigged = 0		// true if rigged to explode
	var/brightness_range = 2 //how much light it gives off
	var/brightness_power = 1
	var/brightness_color = null
	var/cost = 2 //How much power does it consume in an idle state?
	var/fitting = "tube"

/obj/item/weapon/light/tube
	name = "light tube"
	desc = "A replacement light tube."
	icon_state = "tube"
	base_state = "tube"
	item_state = "c_tube"
	starting_materials = list(MAT_GLASS = 100)
	w_type = RECYK_GLASS
	brightness_range = 8
	brightness_power = 3
	cost = 8

/obj/item/weapon/light/tube/he
	name = "high efficiency light tube"
	desc = "An efficient light used to reduce strain on the station's power grid."
	base_state = "hetube"
	cost = 2

/obj/item/weapon/light/tube/large
	w_class = 2
	name = "large light tube"
	brightness_range = 15
	brightness_power = 4
	cost = 15

/obj/item/weapon/light/bulb
	name = "light bulb"
	desc = "A replacement light bulb."
	icon_state = "bulb"
	base_state = "bulb"
	item_state = "contvapour"
	fitting = "bulb"
	brightness_range = 5
	brightness_power = 2
	brightness_color = LIGHT_COLOR_TUNGSTEN
	starting_materials = list(MAT_GLASS = 100)
	cost = 5
	w_type = RECYK_GLASS

/obj/item/weapon/light/bulb/he
	name = "high efficiency light bulb"
	desc = "An efficient light used to reduce strain on the station's power grid."
	base_state = "hebulb"
	cost = 1
	brightness_color = null//These should be white

/obj/item/weapon/light/throw_impact(atom/hit_atom)
	..()
	shatter()

/obj/item/weapon/light/bulb/fire
	name = "fire bulb"
	desc = "A replacement fire bulb."
	icon_state = "fbulb"
	base_state = "fbulb"
	item_state = "egg4"
	brightness_range = 5
	brightness_power = 2
	starting_materials = list(MAT_GLASS = 100)

// update the icon state and description of the light

/obj/item/weapon/light/proc/update()
	switch(status)
		if(LIGHT_OK)
			icon_state = base_state
			desc = "A replacement [name]."
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
			desc = "A burnt-out [name]."
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"
			desc = "A broken [name]."


/obj/item/weapon/light/New()
	..()
	switch(name)
		if("light tube")
			brightness_range = rand(6,9)
		if("light bulb")
			brightness_range = rand(4,6)
	update()


// attack bulb/tube with object
// if a syringe, can inject plasma to make it explode
/obj/item/weapon/light/attackby(var/obj/item/I, var/mob/user)
	..()
	if(istype(I, /obj/item/weapon/reagent_containers/syringe))
		var/obj/item/weapon/reagent_containers/syringe/S = I

		to_chat(user, "You inject the solution into the [src].")

		if(S.reagents.has_reagent("plasma", 5))

			log_admin("LOG: [user.name] ([user.ckey]) injected a light with plasma, rigging it to explode.")
			message_admins("LOG: [user.name] ([user.ckey]) injected a light with plasma, rigging it to explode.")

			rigged = 1

		S.reagents.clear_reagents()
	else
		..()
	return

// called after an attack with a light item
// shatter light, unless it was an attempt to put it in a light socket
// now only shatter if the intent was harm

/obj/item/weapon/light/afterattack(atom/target, mob/user)
	if(istype(target, /obj/machinery/light))
		return
	if(user.a_intent != I_HURT)
		return

	shatter()

/obj/item/weapon/light/proc/shatter()
	if(status == LIGHT_OK || status == LIGHT_BURNED)
		src.visible_message("<span class='warning'>[name] shatters.</span>","<span class='warning'>You hear a small glass object shatter.</span>")
		status = LIGHT_BROKEN
		force = 5
		playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 75, 1)
		update()
