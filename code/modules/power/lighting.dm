// The lighting system
//
// consists of light fixtures (/obj/machinery/light) and light tube/bulb items (/obj/item/weapon/light)

#define LIGHT_TUBE "tube"
#define LIGHT_BULB "bulb"

#define LIGHT_TUBE_BREAK_CHANCE 2
#define LIGHT_BULB_BREAK_CHANCE 5

#define LIGHT_ON "light_on"
#define LIGHT_OFF "light_ok"
#define LIGHT_EMPTY "light_empty"
#define LIGHT_BROKEN "light_broken"
#define LIGHT_BURNED "light_burned"



/obj/item/wallframe/light_fixture
	name = "light fixture frame"
	desc = "Used for building lights."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-item"
	result_path = /obj/structure/light_construct
	inverse = 1

/obj/item/wallframe/light_fixture/small
	name = "small light fixture frame"
	icon_state = "bulb-construct-item"
	result_path = /obj/structure/light_construct/small
	materials = list(MAT_METAL=MINERAL_MATERIAL_AMOUNT)


/obj/structure/light_construct
	name = "light fixture frame"
	desc = "A light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-stage1"
	anchored = 1
	layer = WALL_OBJ_LAYER
	obj_integrity = 200
	max_integrity = 200
	armor = list(melee = 50, bullet = 10, laser = 10, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 80, acid = 50)

	var/stage = 1
	var/fixture_type = LIGHT_TUBE
	var/sheets_refunded = 2
	var/obj/machinery/light/newlight = null

/obj/structure/light_construct/New(loc, ndir, building)
	..()
	if(building)
		setDir(ndir)

/obj/structure/light_construct/examine(mob/user)
	..()
	switch(src.stage)
		if(1)
			to_chat(user, "It's an empty frame.")
		if(2)
			to_chat(user, "It's wired.")
		if(3)
			to_chat(user, "The casing is closed.")

/obj/structure/light_construct/attackby(obj/item/weapon/W, mob/user, params)
	add_fingerprint(user)
	switch(stage)
		if(1)
			if(istype(W, /obj/item/weapon/wrench))
				playsound(src.loc, W.usesound, 75, 1)
				to_chat(usr, "<span class='notice'>You begin deconstructing [src]...</span>")
				if (!do_after(usr, 30*W.toolspeed, target = src))
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
						if(LIGHT_TUBE)
							icon_state = "tube-construct-stage2"
						if(LIGHT_BULB)
							icon_state = "bulb-construct-stage2"
					stage = 2
					user.visible_message("[user.name] adds wires to [src].", \
						"<span class='notice'>You add wires to [src].</span>")
				else
					to_chat(user, "<span class='warning'>You need one length of cable to wire [src]!</span>")
				return
		if(2)
			if(istype(W, /obj/item/weapon/wrench))
				to_chat(usr, "<span class='warning'>You have to remove the wires first!</span>")
				return

			if(istype(W, /obj/item/weapon/wirecutters))
				stage = 1
				switch(fixture_type)
					if(LIGHT_TUBE)
						icon_state = "tube-construct-stage1"
					if(LIGHT_BULB)
						icon_state = "bulb-construct-stage1"
				new /obj/item/stack/cable_coil(get_turf(loc), 1, "red")
				user.visible_message("[user.name] removes the wiring from [src].", \
					"<span class='notice'>You remove the wiring from [src].</span>", "<span class='italics'>You hear clicking.</span>")
				playsound(loc, W.usesound, 100, 1)
				return

			if(istype(W, /obj/item/weapon/screwdriver))
				user.visible_message("[user.name] closes [src]'s casing.", \
					"<span class='notice'>You close [src]'s casing.</span>", "<span class='italics'>You hear screwing.</span>")
				playsound(loc, W.usesound, 75, 1)
				switch(fixture_type)
					if(LIGHT_TUBE)
						newlight = new /obj/machinery/light/built(loc)
					if(LIGHT_BULB)
						newlight = new /obj/machinery/light/small/built(loc)
				newlight.setDir(dir)
				transfer_fingerprints_to(newlight)
				qdel(src)
				return
	return ..()

/obj/structure/light_construct/blob_act(obj/structure/blob/B)
	if(B && B.loc == loc)
		qdel(src)


/obj/structure/light_construct/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, sheets_refunded)
	qdel(src)

/obj/structure/light_construct/small
	name = "small light fixture frame"
	icon_state = "bulb-construct-stage1"
	fixture_type = LIGHT_BULB
	sheets_refunded = 1



// the standard tube light fixture
/obj/machinery/light
	name = "light fixture"
	icon = 'icons/obj/lighting.dmi'
	var/base_state = "tube"		// base description and icon_state
	icon_state = "tube1"
	desc = "A lighting fixture."
	anchored = 1
	layer = WALL_OBJ_LAYER
	obj_integrity = 100
	max_integrity = 100
	use_power = 2
	idle_power_usage = 2
	active_power_usage = 20
	power_channel = LIGHT //Lights are calc'd via area so they dont need to be in the machine list

	var/static_power_used = 0
	var/obj/item/weapon/light/light_type = /obj/item/weapon/light/tube
	var/obj/item/weapon/light/bulb
	var/fitting = LIGHT_TUBE

	var/on = TRUE // is the fixture itself powered?


/obj/machinery/light/Move()
	if(bulb && bulb.status != LIGHT_BROKEN)
		break_light_tube(1)
	. = ..()


// create a new lighting fixture
/obj/machinery/light/Initialize(mapload, initial_status=LIGHT_ON)
	..()
	if(initial_status)
		bulb = new light_type(src)
		bulb.set_status(initial_status)
	if(mapload)
		if(fitting == LIGHT_TUBE && prob(LIGHT_TUBE_BREAK_CHANCE))
			break_light_tube(skip_sound_and_sparks=TRUE)
		if(fitting == LIGHT_BULB && prob(LIGHT_BULB_BREAK_CHANCE))
			break_light_tube(skip_sound_and_sparks=TRUE)

	update(0)

/obj/machinery/light/update_icon()
	if(!bulb)
		icon_state = "[base_state]-empty"
		return
	switch(bulb.status)
		if(LIGHT_ON)
			icon_state = "[base_state]1"
		if(LIGHT_OFF)
			icon_state = "[base_state]0"
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"

// update the icon_state and luminosity of the light depending on its state
/obj/machinery/light/proc/update()
	update_icon()

	if(on && bulb.status == LIGHT_OFF)
		bulb.set_status(LIGHT_ON)
	if(!on && bulb.status == LIGHT_ON)
		bulb.set_status(LIGHT_OFF)

	var/bulb_on = (bulb && bulb.status == LIGHT_ON)

	// XXX You may wish to change the power consumption based on l_power
	// as well.
	active_power_usage = (bulb.lon_range * 10)
	var/old_static_power_used = static_power_used
	if(bulb_on)
		static_power_used = bulb.lon_range * 20
	else
		static_power_used = 0

	removeStaticPower(old_static_power_used)
	addStaticPower(static_power_used)

/obj/machinery/light/proc/burn_out()
	if(bulb && (bulb.status == LIGHT_ON || bulb.status == LIGHT_OFF))
		bulb.set_status(LIGHT_BURNED)
		update()

// attempt to set the light's on/off status
// will not switch on if broken/burned/empty
/obj/machinery/light/proc/seton(state)
	if(!bulb || bulb.status == LIGHT_BURNED || bulb.status == LIGHT_BROKEN)
		return
	if(state)
		bulb.set_status(LIGHT_ON)
	else
		bulb.set_status(LIGHT_OFF)
	update()

// examine verb
/obj/machinery/light/examine(mob/user)
	..()
	if(!bulb)
		to_chat(user, "The [fitting] has been removed.")
	switch(bulb.status)
		if(LIGHT_ON)
			to_chat(user, "It is turned on.")
		if(LIGHT_OFF)
			to_chat(user, "It is turned off.")
		if(LIGHT_BURNED)
			to_chat(user, "The [fitting] is burnt out.")
		if(LIGHT_BROKEN)
			to_chat(user, "The [fitting] has been smashed.")



// attack with item - insert light (if right type), otherwise try to break the light

/obj/machinery/light/attackby(obj/item/W, mob/living/user, params)

	//Light replacer code
	if(istype(W, /obj/item/device/lightreplacer))
		var/obj/item/device/lightreplacer/LR = W
		LR.ReplaceLight(src, user)

	// attempt to insert light
	else if(istype(W, /obj/item/weapon/light))
		if(bulb && bulb.status == LIGHT_ON || bulb.status == LIGHT_OFF)
			to_chat(user, "<span class='warning'>There is a [fitting] already inserted!</span>")
		else
			src.add_fingerprint(user)
			var/obj/item/weapon/light/L = W
			if(istype(L, light_type))
				if(!user.drop_item())
					return

				src.add_fingerprint(user)
				if(bulb)
					drop_light_tube(user)
					to_chat(user, "<span class='notice'>You replace [L].</span>")
				else
					to_chat(user, "<span class='notice'>You insert [L].</span>")
				L.forceMove(src)
				update()
			else
				to_chat(user, "<span class='warning'>This type of light requires a [fitting]!</span>")

	// attempt to stick weapon into light socket
	else if(!bulb)
		if(istype(W, /obj/item/weapon/screwdriver)) //If it's a screwdriver open it.
			playsound(src.loc, W.usesound, 75, 1)
			user.visible_message("[user.name] opens [src]'s casing.", \
				"<span class='notice'>You open [src]'s casing.</span>", "<span class='italics'>You hear a noise.</span>")
			deconstruct()
		else
			to_chat(user, "<span class='userdanger'>You stick \the [W] into the light socket!</span>")
			if(has_power() && (W.flags & CONDUCT))
				var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
				s.set_up(3, 1, src)
				s.start()
				if (prob(75))
					electrocute_mob(user, get_area(src), src, rand(0.7,1.0), TRUE)
	else
		. = ..()

/obj/machinery/light/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		var/obj/structure/light_construct/newlight = null
		var/cur_stage = 2
		if(!disassembled)
			cur_stage = 1
		switch(fitting)
			if(LIGHT_TUBE)
				newlight = new /obj/structure/light_construct(src.loc)
				newlight.icon_state = "tube-construct-stage[cur_stage]"

			if(LIGHT_BULB)
				newlight = new /obj/structure/light_construct/small(src.loc)
				newlight.icon_state = "bulb-construct-stage[cur_stage]"
		newlight.setDir(src.dir)
		newlight.stage = cur_stage
		if(!disassembled)
			newlight.obj_integrity = newlight.max_integrity * 0.5
			if(bulb && bulb.status != LIGHT_BROKEN)
				break_light_tube()
			if(bulb)
				drop_light_tube()
			new /obj/item/stack/cable_coil(loc, 1, "red")
		transfer_fingerprints_to(newlight)
	qdel(src)

/obj/machinery/light/attacked_by(obj/item/I, mob/living/user)
	..()
	if(!bulb || bulb.status == LIGHT_BROKEN)
		if(on && (I.flags & CONDUCT))
			if(prob(12))
				electrocute_mob(user, get_area(src), src, 0.3, TRUE)

/obj/machinery/light/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	. = ..()
	if(. && !QDELETED(src))
		if(prob(damage_amount * 5))
			break_light_tube()

/obj/machinery/light/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(!bulb)
				playsound(loc, 'sound/weapons/smash.ogg', 50, 1)
			else
				switch(bulb.status)
					if(LIGHT_BROKEN)
						playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 90, 1)
					else
						playsound(loc, 'sound/effects/Glasshit.ogg', 90, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)


// returns whether this light has power
// true if area has power and lightswitch is on
/obj/machinery/light/proc/has_power()
	var/area/A = get_area(src)
	return A.lightswitch && A.power_light

// ai attack - make lights flicker, because why not

/obj/machinery/light/attack_ai(mob/user)
	if(bulb && (bulb.status == LIGHT_OFF || bulb.status == LIGHT_ON))
		bulb.flicker(1)

// attack with hand - remove tube/bulb
// if hands aren't protected and the light is on, burn the player

/obj/machinery/light/attack_hand(mob/living/carbon/human/user)
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)

	if(!bulb)
		to_chat(user, "There is no [fitting] in this light.")
		return

	// make it burn hands if not wearing fire-insulated gloves
	if(bulb.status == LIGHT_ON)
		var/prot = FALSE
		var/mob/living/carbon/human/H = user

		if(ishuman(H))
			if(H.gloves)
				var/obj/item/clothing/gloves/G = H.gloves
				if(G.max_heat_protection_temperature)
					prot = (G.max_heat_protection_temperature > 360)
		else
			prot = TRUE

		if(prot)
			to_chat(user, "<span class='notice'>You remove the light [fitting].</span>")
		else if(istype(user) && user.dna.check_mutation(TK))
			to_chat(user, "<span class='notice'>You telekinetically remove the light [fitting].</span>")
		else
			to_chat(user, "<span class='warning'>You try to remove the light [fitting], but you burn your hand on it!</span>")

			var/obj/item/bodypart/affecting = H.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
			if(affecting && affecting.receive_damage( 0, 5 ))		// 5 burn damage
				H.update_damage_overlays()
			return				// if burned, don't remove the light
	else
		to_chat(user, "<span class='notice'>You remove the light [fitting].</span>")
	// create a light tube/bulb item and put it in the user's hand
	drop_light_tube(user)

/obj/machinery/light/proc/drop_light_tube(mob/user)
	if(!bulb)
		return

	bulb.forceMove(loc)

	if(user) //puts it in our active hand
		bulb.add_fingerprint(user)
		user.put_in_active_hand(bulb)

	bulb = null
	update()

/obj/machinery/light/attack_tk(mob/user)
	if(!bulb)
		to_chat(user, "There is no [fitting] in this light.")
		return

	to_chat(user, "<span class='notice'>You telekinetically remove the light [fitting].</span>")
	// create a light tube/bulb item and drop it on the floor
	drop_light_tube()


// break the light and make sparks if was on
/obj/machinery/light/proc/break_light_tube(skip_sound_and_sparks = 0)
	bulb.set_status(LIGHT_BROKEN, !skip_sound_and_sparks)

/obj/machinery/light/proc/fix()
	if(bulb && bulb.status == LIGHT_ON)
		return

	if(!bulb)
		bulb = new light_type(src)

	bulb.set_status(LIGHT_ON)
	update()

/obj/machinery/light/tesla_act(power, explosive = FALSE)
	if(explosive)
		explosion(src.loc,0,0,0,flame_range = 5, adminlog = FALSE)
	qdel(src)

// called when area power state changes
/obj/machinery/light/power_change()
	var/area/A = get_area(src)
	seton(A.lightswitch && A.power_light)

// called when on fire

/obj/machinery/light/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(bulb && bulb.status != LIGHT_BROKEN && prob(max(0, exposed_temperature - 673)))   //0% at <400C, 100% at >500C
		bulb.set_status(LIGHT_BROKEN)

// Different sorts of light fixtures

/obj/machinery/light/small
	icon_state = "bulb1"
	base_state = "bulb"
	fitting = LIGHT_BULB
	desc = "A small lighting fixture."
	light_type = /obj/item/weapon/light/bulb

/obj/machinery/light/built/Initialize(mapload)
	..(mapload, LIGHT_EMPTY)

/obj/machinery/light/small/built/Initialize(mapload)
	..(mapload, LIGHT_EMPTY)


// the light item
// can be tube or bulb subtypes
// will fit into empty /obj/machinery/light of the corresponding type

/obj/item/weapon/light
	icon = 'icons/obj/lighting.dmi'
	force = 2
	var/broken_force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_TINY
	var/status = LIGHT_OFF
	var/base_state
	var/switchcount = 0	// number of times switched
	materials = list(MAT_GLASS=100)
	var/rigged = FALSE		// true if rigged to explode
	var/flickering = FALSE

	var/lon_range = 2
	light_power = 1

/obj/item/weapon/light/Initialize(mapload)
	..()
	set_status(status)

/obj/item/weapon/light/tube
	name = "light tube"
	desc = "A replacement light tube."
	icon_state = "ltube"
	base_state = "ltube"
	item_state = "c_tube"
	lon_range = 8

/obj/item/weapon/light/bulb
	name = "light bulb"
	desc = "A replacement light bulb."
	icon_state = "lbulb"
	base_state = "lbulb"
	item_state = "contvapour"
	lon_range = 4

/obj/item/weapon/light/throw_impact(atom/hit_atom)
	if(!..()) //not caught by a mob
		shatter()

// update the icon state and description of the light

/obj/item/weapon/light/proc/set_status(new_status, trigger_effects=TRUE)
	var/old_status = status
	status = new_status

	if(status == LIGHT_OFF || status == LIGHT_ON)
		icon_state = base_state
		desc = "A replacement [name]."
		force = initial(force)

		if(status == LIGHT_OFF)
			set_light(0)
		else
			set_light(lon_range)
			desc += " It is on."
			if(trigger_effects)
				if(rigged)
					rigged_explode()
				if(old_status == LIGHT_OFF)
					switchcount++
				if(prob(min(60, switchcount*switchcount*0.01)))
					set_status(LIGHT_BURNED)

	else if(status == LIGHT_BURNED)
		icon_state = "[base_state]-burned"
		desc = "A burnt-out [name]."
		force = initial(force)
		set_light(0)

	else if(status == LIGHT_BROKEN)
		icon_state = "[base_state]-broken"
		desc = "A broken [name]."
		force = broken_force
		set_light(0)

		if(trigger_effects && old_status != new_status)
			if(old_status == LIGHT_ON || old_status == LIGHT_OFF || old_status == LIGHT_BURNED)
				playsound(src.loc, 'sound/effects/Glasshit.ogg', 75, 1)
			if(old_status == LIGHT_ON)
				var/datum/effect_system/spark_spread/s = new
				s.set_up(3, 1, src)
				s.start()

/obj/item/weapon/light/proc/rigged_explode()
	set waitfor = 0
	set_status(LIGHT_BROKEN)

	sleep(2)
	explosion(get_turf(src), 0, 0, 2, 2)
	sleep(1)
	qdel(src)

// attack bulb/tube with object
// if a syringe, can inject plasma to make it explode
/obj/item/weapon/light/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/reagent_containers/syringe))
		var/obj/item/weapon/reagent_containers/syringe/S = I

		to_chat(user, "<span class='notice'>You inject the solution into \the [src].</span>")

		if(S.reagents.has_reagent("plasma", 5))
			rigged = TRUE
			set_status(status) // explode if on.

		S.reagents.clear_reagents()
	else
		. = ..()

/obj/item/weapon/light/attack(mob/living/M, mob/living/user, def_zone)
	..()
	shatter()

/obj/item/weapon/light/attack_obj(obj/O, mob/living/user)
	..()
	shatter()

/obj/item/weapon/light/proc/shatter()
	if(status != LIGHT_BROKEN)
		src.visible_message("<span class='danger'>[name] shatters.</span>","<span class='italics'>You hear a small glass object shatter.</span>")
		set_status(LIGHT_BROKEN)
		playsound(src.loc, 'sound/effects/Glasshit.ogg', 75, 1)

/obj/item/weapon/light/proc/flicker(var/amount = rand(10, 20))
	set waitfor = 0
	if(flickering)
		return
	flickering = TRUE
	if(status == LIGHT_ON)
		for(var/i = 0; i < amount; i++)
			if(!(status == LIGHT_ON || status == LIGHT_OFF))
				break
			if(status == LIGHT_ON)
				set_status(LIGHT_OFF)
			else
				set_status(LIGHT_ON)
			sleep(rand(5, 15))
		set_status(LIGHT_ON)
	flickering = FALSE


#undef LIGHT_TUBE
#undef LIGHT_BULB

#undef LIGHT_TUBE_BREAK_CHANCE
#undef LIGHT_BULB_BREAK_CHANCE

#undef LIGHT_OK
#undef LIGHT_EMPTY
#undef LIGHT_BROKEN
#undef LIGHT_BURNED
