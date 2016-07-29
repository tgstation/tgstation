// The lighting system
//
// consists of light fixtures (/obj/machinery/light) and light tube/bulb items (/obj/item/weapon/light)

<<<<<<< HEAD

// status values shared between lighting fixtures and items
#define LIGHT_OK 0
#define LIGHT_EMPTY 1
=======
// status values shared between lighting fixtures and items
#define LIGHT_OK     0
#define LIGHT_EMPTY  1
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3


<<<<<<< HEAD

/obj/item/wallframe/light_fixture
	name = "light fixture frame"
	desc = "Used for building lights."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-item"
	result_path = /obj/machinery/light_construct
	inverse = 1

/obj/item/wallframe/light_fixture/small
	name = "small light fixture frame"
	icon_state = "bulb-construct-item"
	result_path = /obj/machinery/light_construct/small
	materials = list(MAT_METAL=MINERAL_MATERIAL_AMOUNT)


=======
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
/obj/machinery/light_construct
	name = "light fixture frame"
	desc = "A light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-stage1"
	anchored = 1
<<<<<<< HEAD
	layer = WALL_OBJ_LAYER
=======
	layer = 5
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/stage = 1
	var/fixture_type = "tube"
	var/sheets_refunded = 2
	var/obj/machinery/light/newlight = null

<<<<<<< HEAD
/obj/machinery/light_construct/New(loc, ndir, building)
	..()
	if(building)
		setDir(ndir)

/obj/machinery/light_construct/examine(mob/user)
	..()
	switch(src.stage)
		if(1)
			user << "It's an empty frame."
		if(2)
			user << "It's wired."
		if(3)
			user << "The casing is closed."

/obj/machinery/light_construct/attackby(obj/item/weapon/W, mob/user, params)
	add_fingerprint(user)
	switch(stage)
		if(1)
			if(istype(W, /obj/item/weapon/wrench))
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				usr << "<span class='notice'>You begin deconstructing [src]...</span>"
				if (!do_after(usr, 30/W.toolspeed, target = src))
					return
				new /obj/item/stack/sheet/metal( get_turf(src.loc), sheets_refunded )
				user.visible_message("[user.name] deconstructs [src].", \
					"<span class='notice'>You deconstruct [src].</span>", "<span class='italics'>You hear a ratchet.</span>")
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 75, 1)
				qdel(src)
				return

			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/coil = W
				if(coil.use(1))
					switch(fixture_type)
						if ("tube")
							icon_state = "tube-construct-stage2"
						if("bulb")
							icon_state = "bulb-construct-stage2"
					stage = 2
					user.visible_message("[user.name] adds wires to [src].", \
						"<span class='notice'>You add wires to [src].</span>")
				else
					user << "<span class='warning'>You need one length of cable to wire [src]!</span>"
				return
		if(2)
			if(istype(W, /obj/item/weapon/wrench))
				usr << "<span class='warning'>You have to remove the wires first!</span>"
				return

			if(istype(W, /obj/item/weapon/wirecutters))
				stage = 1
				switch(fixture_type)
					if ("tube")
						icon_state = "tube-construct-stage1"
					if("bulb")
						icon_state = "bulb-construct-stage1"
				new /obj/item/stack/cable_coil(get_turf(loc), 1, "red")
				user.visible_message("[user.name] removes the wiring from [src].", \
					"<span class='notice'>You remove the wiring from [src].</span>", "<span class='italics'>You hear clicking.</span>")
				playsound(loc, 'sound/items/Wirecutter.ogg', 100, 1)
				return

			if(istype(W, /obj/item/weapon/screwdriver))
				user.visible_message("[user.name] closes [src]'s casing.", \
					"<span class='notice'>You close [src]'s casing.</span>", "<span class='italics'>You hear screwing.</span>")
				playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
				switch(fixture_type)
					if("tube")
						newlight = new /obj/machinery/light/built(loc)
					if ("bulb")
						newlight = new /obj/machinery/light/small/built(loc)
				newlight.setDir(dir)
				transfer_fingerprints_to(newlight)
				qdel(src)
				return
	return ..()
=======
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
	if (iswrench(W))
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

/obj/machinery/light_construct/kick_act(mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] attempts to kick \the [src].</span>", "<span class='danger'>You attempt to kick \the [src].</span>")
	to_chat(H, "<span class='danger'>Dumb move! You strain a muscle.</span>")

	H.apply_damage(rand(1,2), BRUTE, pick(LIMB_RIGHT_LEG, LIMB_LEFT_LEG, LIMB_RIGHT_FOOT, LIMB_LEFT_FOOT))
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488


/obj/machinery/light_construct/small
	name = "small light fixture frame"
<<<<<<< HEAD
	icon_state = "bulb-construct-stage1"
	fixture_type = "bulb"
	sheets_refunded = 1

=======
	desc = "A small light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "bulb-construct-stage1"
	anchored = 1
	layer = 5
	stage = 1
	fixture_type = "bulb"
	sheets_refunded = 1

var/global/list/obj/machinery/light/alllights = list()

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
// the standard tube light fixture
/obj/machinery/light
	name = "light fixture"
	icon = 'icons/obj/lighting.dmi'
	var/base_state = "tube"		// base description and icon_state
<<<<<<< HEAD
	icon_state = "tube1"
	desc = "A lighting fixture."
	anchored = 1
	layer = WALL_OBJ_LAYER
=======
	icon_state = "ltube1"
	desc = "A lighting fixture."
	anchored = 1
	layer = 5  					// They were appearing under mobs which is a little weird - Ostaf
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	use_power = 2
	idle_power_usage = 2
	active_power_usage = 20
	power_channel = LIGHT //Lights are calc'd via area so they dont need to be in the machine list
<<<<<<< HEAD
	var/on = 0					// 1 if on, 0 if off
	var/on_gs = 0
	var/static_power_used = 0
	var/brightness = 8			// luminosity when on, also used in power calculation
=======
	var/cost = 8
	var/on = 0					// 1 if on, 0 if off
	var/on_gs = 0
	var/static_power_used = 0
	var/brightness_range = 8	// luminosity when on, also used in power calculation
	var/brightness_power = 1
	var/brightness_color = null
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/status = LIGHT_OK		// LIGHT_OK, _EMPTY, _BURNED or _BROKEN
	var/flickering = 0
	var/light_type = /obj/item/weapon/light/tube		// the type of light item
	var/fitting = "tube"
	var/switchcount = 0			// count of number of times switched on/off
								// this is used to calc the probability the light burns out

	var/rigged = 0				// true if rigged to explode
<<<<<<< HEAD
	var/health = 20

// the smaller bulb light fixture

/obj/machinery/light/small
	icon_state = "bulb1"
	base_state = "bulb"
	fitting = "bulb"
	brightness = 4
	desc = "A small lighting fixture."
	light_type = /obj/item/weapon/light/bulb
	health = 15


/obj/machinery/light/Move()
	if(status != LIGHT_BROKEN)
		broken(1)
	return ..()
=======

	// No ghost interaction.
	ghost_read=0
	ghost_write=0

	var/idle = 0 // For process().

	holomap = TRUE
	auto_holomap = TRUE

/obj/machinery/light/spook()
	if(..())
		flicker()

// the smaller bulb light fixture

/obj/machinery/light/cultify()
	new /obj/structure/cult/pylon(loc)
	qdel(src)

/obj/machinery/light/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet)||istype(Proj,/obj/item/projectile/ricochet))
		if(!istype(Proj ,/obj/item/projectile/beam/lasertag) && !istype(Proj ,/obj/item/projectile/beam/practice) )
			broken()

/obj/machinery/light/kick_act(mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] attempts to kick \the [src].</span>", "<span class='danger'>You attempt to kick \the [src].</span>")
	to_chat(H, "<span class='danger'>Dumb move! You strain a muscle.</span>")

	H.apply_damage(rand(1,2), BRUTE, pick(LIMB_RIGHT_LEG, LIMB_LEFT_LEG, LIMB_RIGHT_FOOT, LIMB_LEFT_FOOT))


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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/machinery/light/built/New()
	status = LIGHT_EMPTY
	update(0)
	..()

/obj/machinery/light/small/built/New()
	status = LIGHT_EMPTY
	update(0)
	..()

<<<<<<< HEAD

// create a new lighting fixture
/obj/machinery/light/New()
	..()
	spawn(2)
		switch(fitting)
			if("tube")
				brightness = 8
				if(prob(2))
					broken(1)
			if("bulb")
				brightness = 4
=======
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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
				if(prob(5))
					broken(1)
		spawn(1)
			update(0)

/obj/machinery/light/Destroy()
<<<<<<< HEAD
	var/area/A = get_area(src)
	if(A)
		on = 0
//		A.update_lights()
	return ..()
=======
	seton(0)
	..()
	alllights -= src
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/machinery/light/update_icon()

	switch(status)		// set icon_states
		if(LIGHT_OK)
<<<<<<< HEAD
			icon_state = "[base_state][on]"
		if(LIGHT_EMPTY)
			icon_state = "[base_state]-empty"
			on = 0
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
			on = 0
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"
=======
			icon_state = "l[base_state][on]"
		if(LIGHT_EMPTY)
			icon_state = "l[base_state]-empty"
			on = 0
		if(LIGHT_BURNED)
			icon_state = "l[base_state]-burned"
			on = 0
		if(LIGHT_BROKEN)
			icon_state = "l[base_state]-broken"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
			on = 0
	return

// update the icon_state and luminosity of the light depending on its state
<<<<<<< HEAD
/obj/machinery/light/proc/update(trigger = 1)

	update_icon()
	if(on)
		if(!light || light.luminosity != brightness)
			switchcount++
			if(rigged)
				if(status == LIGHT_OK && trigger)
=======
/obj/machinery/light/proc/update(var/trigger = 1)


	update_icon()
	if(on)
		if(light_range != brightness_range || light_power != brightness_power || light_color != brightness_color)
			switchcount++
			if(rigged)
				if(status == LIGHT_OK && trigger)

					log_admin("LOG: Rigged light explosion, last touched by [fingerprintslast]")
					message_admins("LOG: Rigged light explosion, last touched by [fingerprintslast]")

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
					explode()
			else if( prob( min(60, switchcount*switchcount*0.01) ) )
				if(status == LIGHT_OK && trigger)
					status = LIGHT_BURNED
<<<<<<< HEAD
					icon_state = "[base_state]-burned"
					on = 0
					SetLuminosity(0)
			else
				use_power = 2
				SetLuminosity(brightness)
	else
		use_power = 1
		SetLuminosity(0)

	active_power_usage = (brightness * 10)
	if(on != on_gs)
		on_gs = on
		if(on)
			static_power_used = brightness * 20 //20W per unit luminosity
=======
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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
			addStaticPower(static_power_used, STATIC_LIGHT)
		else
			removeStaticPower(static_power_used, STATIC_LIGHT)


<<<<<<< HEAD
// attempt to set the light's on/off status
// will not switch on if broken/burned/empty
/obj/machinery/light/proc/seton(s)
	on = (s && status == LIGHT_OK)
=======
/*
 * Attempt to set the light's on/off status.
 * Will not switch on if broken/burned/empty.
 */
/obj/machinery/light/proc/seton(const/s)
	on = (s && LIGHT_OK == status)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	update()

// examine verb
/obj/machinery/light/examine(mob/user)
	..()
	switch(status)
		if(LIGHT_OK)
<<<<<<< HEAD
			user << "It is turned [on? "on" : "off"]."
		if(LIGHT_EMPTY)
			user << "The [fitting] has been removed."
		if(LIGHT_BURNED)
			user << "The [fitting] is burnt out."
		if(LIGHT_BROKEN)
			user << "The [fitting] has been smashed."

=======
			to_chat(user, "<span class='info'>[desc] It is turned [on? "on" : "off"].</span>")
		if(LIGHT_EMPTY)
			to_chat(user, "<span class='info'>[desc] The [fitting] has been removed.</span>")
		if(LIGHT_BURNED)
			to_chat(user, "<span class='info'>[desc] The [fitting] is burnt out.</span>")
		if(LIGHT_BROKEN)
			to_chat(user, "<span class='info'>[desc] The [fitting] has been smashed.</span>")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488


// attack with item - insert light (if right type), otherwise try to break the light

<<<<<<< HEAD
/obj/machinery/light/attackby(obj/item/W, mob/living/user, params)

	//Light replacer code
	if(istype(W, /obj/item/device/lightreplacer))
		var/obj/item/device/lightreplacer/LR = W
		LR.ReplaceLight(src, user)

	// attempt to insert light
	else if(istype(W, /obj/item/weapon/light))
		if(status != LIGHT_EMPTY)
			user << "<span class='warning'>There is a [fitting] already inserted!</span>"
		else
			src.add_fingerprint(user)
			var/obj/item/weapon/light/L = W
			if(istype(L, light_type))
				if(!user.drop_item())
					return
				status = L.status
				user << "<span class='notice'>You insert the [L.name].</span>"
				switchcount = L.switchcount
				rigged = L.rigged
				brightness = L.brightness
=======
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
				if(!user.drop_item(L))
					user << "<span class='warning'>You can't let go of \the [L]!</span>"
					return

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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
				on = has_power()
				update()

				qdel(L)

				if(on && rigged)
<<<<<<< HEAD
					explode()
			else
				user << "<span class='warning'>This type of light requires a [fitting]!</span>"

	// attempt to stick weapon into light socket
	else if(status == LIGHT_EMPTY)
		if(istype(W, /obj/item/weapon/screwdriver)) //If it's a screwdriver open it.
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 75, 1)
			user.visible_message("[user.name] opens [src]'s casing.", \
				"<span class='notice'>You open [src]'s casing.</span>", "<span class='italics'>You hear a noise.</span>")
=======

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
				M.show_message("[user.name] smashed the light!", 1, "You hear a tinkle of breaking glass", 2)
			if(on && (W.is_conductor()))
				//if(!user.mutations & M_RESIST_COLD)
				if (prob(12))
					electrocute_mob(user, get_area(src), src, 0.3)
			broken()

		else
			to_chat(user, "You hit the light!")
	// attempt to deconstruct / stick weapon into light socket
	else if(status == LIGHT_EMPTY)
		if(iswirecutter(W)) //If it's a wirecutter take out the wires
			playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 75, 1)
			user.visible_message("[user.name] removes \the [src]'s wires.", \
				"You remove \the [src]'s wires.", "You hear a noise.")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
			var/obj/machinery/light_construct/newlight = null
			switch(fitting)
				if("tube")
					newlight = new /obj/machinery/light_construct(src.loc)
<<<<<<< HEAD
					newlight.icon_state = "tube-construct-stage2"

				if("bulb")
					newlight = new /obj/machinery/light_construct/small(src.loc)
					newlight.icon_state = "bulb-construct-stage2"
			newlight.setDir(src.dir)
			newlight.stage = 2
			transfer_fingerprints_to(newlight)
			qdel(src)
		else
			user << "<span class='userdanger'>You stick \the [W] into the light socket!</span>"
			if(has_power() && (W.flags & CONDUCT))
				var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
				s.set_up(3, 1, src)
				s.start()
				if (prob(75))
					electrocute_mob(user, get_area(src), src, rand(0.7,1.0))
	else
		return ..()

/obj/machinery/light/attacked_by(obj/item/I, mob/living/user)
	..()
	if(status == LIGHT_BROKEN || status == LIGHT_EMPTY)
		if(on && (I.flags & CONDUCT))
			if(prob(12))
				electrocute_mob(user, get_area(src), src, 0.3)

/obj/machinery/light/take_damage(damage, damage_type = BRUTE, sound_effect = 1)
	switch(damage_type)
		if(BRUTE)
			if(sound_effect)
				switch(status)
					if(LIGHT_EMPTY)
						playsound(loc, 'sound/weapons/smash.ogg', 50, 1)
					if(LIGHT_BROKEN)
						playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 90, 1)
					else
						playsound(loc, 'sound/effects/Glasshit.ogg', 90, 1)
		if(BURN)
			if(sound_effect)
				playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)
		else
			return
	health -= damage
	if(health <= 0)
		broken()


// returns whether this light has power
// true if area has power and lightswitch is on
/obj/machinery/light/proc/has_power()
	var/area/A = src.loc.loc
	return A.master.lightswitch && A.master.power_light

/obj/machinery/light/proc/flicker(var/amount = rand(10, 20))
	set waitfor = 0
	if(flickering) return
	flickering = 1
	if(on && status == LIGHT_OK)
		for(var/i = 0; i < amount; i++)
			if(status != LIGHT_OK) break
			on = !on
			update(0)
			sleep(rand(5, 15))
		on = (status == LIGHT_OK)
		update(0)
	flickering = 0

// ai attack - make lights flicker, because why not

/obj/machinery/light/attack_ai(mob/user)
	src.flicker(1)
	return

/obj/machinery/light/bullet_act(obj/item/projectile/P)
	. = ..()
	take_damage(P.damage, P.damage_type, 0)

/obj/machinery/light/hitby(AM as mob|obj)
	..()
	var/tforce = 0
	if(ismob(AM))
		tforce = 40
	else if(isobj(AM))
		var/obj/item/I = AM
		tforce = I.throwforce
	take_damage(tforce)

// attack with hand - remove tube/bulb
// if hands aren't protected and the light is on, burn the player

/obj/machinery/light/attack_hand(mob/living/carbon/human/user)
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)

	if(status == LIGHT_EMPTY)
		user << "There is no [fitting] in this light."
=======
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
		update(0)

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
			M.show_message("<span class='attack'>[user.name] smashed the light!</span>", 1, "You hear a tinkle of breaking glass", 2)
		broken()
	return

/obj/machinery/light/attack_animal(mob/living/simple_animal/M)
	if(M.melee_damage_upper == 0)	return
	if(status == LIGHT_EMPTY||status == LIGHT_BROKEN)
		to_chat(M, "<span class='warning'>That object is useless to you.</span>")
		return
	else if (status == LIGHT_OK||status == LIGHT_BURNED)
		for(var/mob/O in viewers(src))
			O.show_message("<span class='attack'>[M.name] smashed the light!</span>", 1, "You hear a tinkle of breaking glass", 2)
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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		return

	// make it burn hands if not wearing fire-insulated gloves
	if(on)
		var/prot = 0
<<<<<<< HEAD
		var/mob/living/carbon/human/H = user

		if(istype(H))

=======

		if(ishuman(user))
			var/mob/living/carbon/human/H = user
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
			if(H.gloves)
				var/obj/item/clothing/gloves/G = H.gloves
				if(G.max_heat_protection_temperature)
					prot = (G.max_heat_protection_temperature > 360)
		else
			prot = 1

<<<<<<< HEAD
		if(prot > 0)
			user << "<span class='notice'>You remove the light [fitting].</span>"
		else if(istype(user) && user.dna.check_mutation(TK))
			user << "<span class='notice'>You telekinetically remove the light [fitting].</span>"
		else
			user << "<span class='warning'>You try to remove the light [fitting], but you burn your hand on it!</span>"

			var/obj/item/bodypart/affecting = H.get_bodypart("[user.hand ? "l" : "r" ]_arm")
			if(affecting && affecting.take_damage( 0, 5 ))		// 5 burn damage
				H.update_damage_overlays(0)
			H.updatehealth()
			return				// if burned, don't remove the light
	else
		user << "<span class='notice'>You remove the light [fitting].</span>"
=======
		if(prot > 0 || (M_RESIST_HEAT in user.mutations))
			to_chat(user, "You remove the light [fitting]")
		else
			to_chat(user, "You try to remove the light [fitting], but it's too hot and you don't want to burn your hand.")
			return				// if burned, don't remove the light

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	// create a light tube/bulb item and put it in the user's hand
	var/obj/item/weapon/light/L = new light_type()
	L.status = status
	L.rigged = rigged
<<<<<<< HEAD
	L.brightness = brightness
=======
	L.brightness_range = brightness_range
	L.brightness_power = brightness_power
	L.brightness_color = brightness_color
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

	// light item inherits the switchcount, then zero it
	L.switchcount = switchcount
	switchcount = 0

	L.update()
	L.add_fingerprint(user)
<<<<<<< HEAD
	L.loc = loc
=======
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

	user.put_in_active_hand(L)	//puts it in our active hand

	status = LIGHT_EMPTY
	update()

<<<<<<< HEAD
/obj/machinery/light/attack_tk(mob/user)
	if(status == LIGHT_EMPTY)
		user << "There is no [fitting] in this light."
		return

	user << "<span class='notice'>You telekinetically remove the light [fitting].</span>"
	// create a light tube/bulb item and put it in the user's hand
	var/obj/item/weapon/light/L = new light_type()
	L.status = status
	L.rigged = rigged
	L.brightness = brightness

	// light item inherits the switchcount, then zero it
	L.switchcount = switchcount
	switchcount = 0

	L.update()
	L.add_fingerprint(user)
	L.loc = loc

	status = LIGHT_EMPTY
	update()

// break the light and make sparks if was on

/obj/machinery/light/proc/broken(skip_sound_and_sparks = 0)
=======
// break the light and make sparks if was on

/obj/machinery/light/proc/broken(var/skip_sound_and_sparks = 0)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	if(status == LIGHT_EMPTY)
		return

	if(!skip_sound_and_sparks)
		if(status == LIGHT_OK || status == LIGHT_BURNED)
<<<<<<< HEAD
			playsound(src.loc, 'sound/effects/Glasshit.ogg', 75, 1)
		if(on)
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
=======
			playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 75, 1)
		if(on)
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
			s.set_up(3, 1, src)
			s.start()
	status = LIGHT_BROKEN
	update()

/obj/machinery/light/proc/fix()
	if(status == LIGHT_OK)
		return
	status = LIGHT_OK
<<<<<<< HEAD
	brightness = initial(brightness)
=======
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	on = 1
	update()

// explosion effect
// destroy the whole light fixture or just shatter it

<<<<<<< HEAD
/obj/machinery/light/ex_act(severity, target)
	..()
	if(!qdeleted(src))
		switch(severity)
			if(2)
				if(prob(50))
					broken()
			if(3)
				if(prob(25))
					broken()

// called when area power state changes
/obj/machinery/light/power_change()
	var/area/A = get_area(src)
	A = A.master
	seton(A.lightswitch && A.power_light)

// called when on fire

/obj/machinery/light/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(prob(max(0, exposed_temperature - 673)))   //0% at <400C, 100% at >500C
		broken()

// explode the light

/obj/machinery/light/proc/explode()
	set waitfor = 0
	var/turf/T = get_turf(src.loc)
	broken()	// break it first to give a warning
	sleep(2)
	explosion(T, 0, 0, 2, 2)
	sleep(1)
	qdel(src)
=======
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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

// the light item
// can be tube or bulb subtypes
// will fit into empty /obj/machinery/light of the corresponding type

/obj/item/weapon/light
	icon = 'icons/obj/lighting.dmi'
<<<<<<< HEAD
	force = 2
	throwforce = 5
	w_class = 1
	var/status = 0		// LIGHT_OK, LIGHT_BURNED or LIGHT_BROKEN
	var/base_state
	var/switchcount = 0	// number of times switched
	materials = list(MAT_METAL=60)
	var/rigged = 0		// true if rigged to explode
	var/brightness = 2 //how much light it gives off
=======
	flags = FPRINT
	force = 2
	throwforce = 5
	w_class = W_CLASS_TINY
	var/status = 0		// LIGHT_OK, LIGHT_BURNED or LIGHT_BROKEN
	var/base_state
	var/switchcount = 0	// number of times switched
	//starting_materials = list(MAT_IRON = 60) //Not necessary, as this exact type should never appear and each subtype has its materials defined.
	var/rigged = 0		// true if rigged to explode
	var/brightness_range = 2 //how much light it gives off
	var/brightness_power = 1
	var/brightness_color = null
	var/cost = 2 //How much power does it consume in an idle state?
	var/fitting = "tube"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/item/weapon/light/tube
	name = "light tube"
	desc = "A replacement light tube."
<<<<<<< HEAD
	icon_state = "ltube"
	base_state = "ltube"
	item_state = "c_tube"
	materials = list(MAT_GLASS=100)
	brightness = 8
=======
	icon_state = "tube"
	base_state = "tube"
	item_state = "c_tube"
	starting_materials = list(MAT_GLASS = 100, MAT_IRON = 60)
	w_type = RECYK_GLASS
	brightness_range = 8
	brightness_power = 3
	cost = 8

/obj/item/weapon/light/tube/he
	name = "high efficiency light tube"
	desc = "An efficient light used to reduce strain on the station's power grid."
	base_state = "hetube"
	starting_materials = list(MAT_GLASS = 300, MAT_IRON = 60)
	cost = 2

/obj/item/weapon/light/tube/large
	w_class = W_CLASS_SMALL
	name = "large light tube"
	brightness_range = 15
	brightness_power = 4
	starting_materials = list(MAT_GLASS = 200, MAT_IRON = 100)
	cost = 15
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/item/weapon/light/bulb
	name = "light bulb"
	desc = "A replacement light bulb."
<<<<<<< HEAD
	icon_state = "lbulb"
	base_state = "lbulb"
	item_state = "contvapour"
	materials = list(MAT_GLASS=100)
	brightness = 4

/obj/item/weapon/light/throw_impact(atom/hit_atom)
	if(!..()) //not caught by a mob
		shatter()
=======
	icon_state = "bulb"
	base_state = "bulb"
	item_state = "contvapour"
	fitting = "bulb"
	brightness_range = 5
	brightness_power = 2
	brightness_color = LIGHT_COLOR_TUNGSTEN
	starting_materials = list(MAT_GLASS = 50, MAT_IRON = 30)
	cost = 5
	w_type = RECYK_GLASS

/obj/item/weapon/light/bulb/he
	name = "high efficiency light bulb"
	desc = "An efficient light used to reduce strain on the station's power grid."
	base_state = "hebulb"
	cost = 1
	starting_materials = list(MAT_GLASS = 150, MAT_IRON = 30)
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
	starting_materials = list(MAT_GLASS = 300, MAT_IRON = 60)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

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
<<<<<<< HEAD
=======
	switch(name)
		if("light tube")
			brightness_range = rand(6,9)
		if("light bulb")
			brightness_range = rand(4,6)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	update()


// attack bulb/tube with object
// if a syringe, can inject plasma to make it explode
<<<<<<< HEAD
/obj/item/weapon/light/attackby(obj/item/I, mob/user, params)
=======
/obj/item/weapon/light/attackby(var/obj/item/I, var/mob/user)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	..()
	if(istype(I, /obj/item/weapon/reagent_containers/syringe))
		var/obj/item/weapon/reagent_containers/syringe/S = I

<<<<<<< HEAD
		user << "<span class='notice'>You inject the solution into \the [src].</span>"

		if(S.reagents.has_reagent("plasma", 5))
=======
		to_chat(user, "You inject the solution into the [src].")

		if(S.reagents.has_reagent(PLASMA, 5))

			log_admin("LOG: [user.name] ([user.ckey]) injected a light with plasma, rigging it to explode.")
			message_admins("LOG: [user.name] ([user.ckey]) injected a light with plasma, rigging it to explode.")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

			rigged = 1

		S.reagents.clear_reagents()
	else
		..()
	return

<<<<<<< HEAD
/obj/item/weapon/light/attack(mob/living/M, mob/living/user, def_zone)
	..()
	shatter()

/obj/item/weapon/light/attack_obj(obj/O, mob/living/user)
	..()
=======
// called after an attack with a light item
// shatter light, unless it was an attempt to put it in a light socket
// now only shatter if the intent was harm

/obj/item/weapon/light/afterattack(atom/target, mob/user)
	if(istype(target, /obj/machinery/light))
		return
	if(user.a_intent != I_HURT)
		return

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	shatter()

/obj/item/weapon/light/proc/shatter()
	if(status == LIGHT_OK || status == LIGHT_BURNED)
<<<<<<< HEAD
		src.visible_message("<span class='danger'>[name] shatters.</span>","<span class='italics'>You hear a small glass object shatter.</span>")
		status = LIGHT_BROKEN
		force = 5
		playsound(src.loc, 'sound/effects/Glasshit.ogg', 75, 1)
=======
		src.visible_message("<span class='warning'>[name] shatters.</span>","<span class='warning'>You hear a small glass object shatter.</span>")
		status = LIGHT_BROKEN
		force = 5
		playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 75, 1)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		update()
