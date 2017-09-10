


/obj/structure/statue
	name = "statue"
	desc = "Placeholder. Yell at Firecage if you SOMEHOW see this."
	icon = 'icons/obj/statue.dmi'
	icon_state = ""
	density = TRUE
	anchored = FALSE
	max_integrity = 100
	var/oreAmount = 5
	var/material_drop_type = /obj/item/stack/sheet/metal
	CanAtmosPass = ATMOS_PASS_DENSITY

/obj/structure/statue/attackby(obj/item/W, mob/living/user, params)
	add_fingerprint(user)
	user.changeNext_move(CLICK_CD_MELEE)
	if(istype(W, /obj/item/wrench))
		if(anchored)
			playsound(src.loc, W.usesound, 100, 1)
			user.visible_message("[user] is loosening the [name]'s bolts.", \
								 "<span class='notice'>You are loosening the [name]'s bolts...</span>")
			if(do_after(user,40*W.toolspeed, target = src))
				if(!src.loc || !anchored)
					return
				user.visible_message("[user] loosened the [name]'s bolts!", \
									 "<span class='notice'>You loosen the [name]'s bolts!</span>")
				anchored = FALSE
		else
			if(!isfloorturf(src.loc))
				user.visible_message("<span class='warning'>A floor must be present to secure the [name]!</span>")
				return
			playsound(src.loc, W.usesound, 100, 1)
			user.visible_message("[user] is securing the [name]'s bolts...", \
								 "<span class='notice'>You are securing the [name]'s bolts...</span>")
			if(do_after(user, 40*W.toolspeed, target = src))
				if(!src.loc || anchored)
					return
				user.visible_message("[user] has secured the [name]'s bolts.", \
									 "<span class='notice'>You have secured the [name]'s bolts.</span>")
				anchored = TRUE

	else if(istype(W, /obj/item/gun/energy/plasmacutter))
		playsound(src, 'sound/items/welder.ogg', 100, 1)
		user.visible_message("[user] is slicing apart the [name]...", \
							 "<span class='notice'>You are slicing apart the [name]...</span>")
		if(do_after(user,40*W.toolspeed, target = src))
			if(!src.loc)
				return
			user.visible_message("[user] slices apart the [name].", \
								 "<span class='notice'>You slice apart the [name].</span>")
			deconstruct(TRUE)

	else if(istype(W, /obj/item/pickaxe/drill/jackhammer))
		var/obj/item/pickaxe/drill/jackhammer/D = W
		if(!src.loc)
			return
		user.visible_message("[user] destroys the [name]!", \
							 "<span class='notice'>You destroy the [name].</span>")
		D.playDigSound()
		qdel(src)

	else if(istype(W, /obj/item/weldingtool) && !anchored)
		playsound(loc, W.usesound, 40, 1)
		user.visible_message("[user] is slicing apart the [name].", \
							 "<span class='notice'>You are slicing apart the [name]...</span>")
		if(do_after(user, 40*W.toolspeed, target = src))
			if(!src.loc)
				return
			playsound(loc, 'sound/items/welder2.ogg', 50, 1)
			user.visible_message("[user] slices apart the [name].", \
								 "<span class='notice'>You slice apart the [name]!</span>")
			deconstruct(TRUE)
	else
		return ..()

/obj/structure/statue/attack_hand(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)
	user.visible_message("[user] rubs some dust off from the [name]'s surface.", \
						 "<span class='notice'>You rub some dust off from the [name]'s surface.</span>")

/obj/structure/statue/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(material_drop_type)
			var/drop_amt = oreAmount
			if(!disassembled)
				drop_amt -= 2
			if(drop_amt > 0)
				new material_drop_type(get_turf(src), drop_amt)
	qdel(src)

//////////////////////////////////////STATUES/////////////////////////////////////////////////////////////
////////////////////////uranium///////////////////////////////////

/obj/structure/statue/uranium
	max_integrity = 300
	light_range = 2
	material_drop_type = /obj/item/stack/sheet/mineral/uranium
	var/last_event = 0
	var/active = null

/obj/structure/statue/uranium/nuke
	name = "statue of a nuclear fission explosive"
	desc = "This is a grand statue of a Nuclear Explosive. It has a sickening green colour."
	icon_state = "nuke"

/obj/structure/statue/uranium/eng
	name = "Statue of an engineer"
	desc = "This statue has a sickening green colour."
	icon_state = "eng"

/obj/structure/statue/uranium/attackby(obj/item/W, mob/user, params)
	radiate()
	return ..()

/obj/structure/statue/uranium/CollidedWith(atom/movable/AM)
	radiate()
	..()

/obj/structure/statue/uranium/attack_hand(mob/user)
	radiate()
	..()

/obj/structure/statue/uranium/attack_paw(mob/user)
	radiate()
	..()

/obj/structure/statue/uranium/proc/radiate()
	if(!active)
		if(world.time > last_event+15)
			active = 1
			radiation_pulse(get_turf(src), 3, 3, 12, 0)
			last_event = world.time
			active = null
			return
	return

////////////////////////////plasma///////////////////////////////////////////////////////////////////////

/obj/structure/statue/plasma
	max_integrity = 200
	material_drop_type = /obj/item/stack/sheet/mineral/plasma
	desc = "This statue is suitably made from plasma."

/obj/structure/statue/plasma/scientist
	name = "statue of a scientist"
	icon_state = "sci"

/obj/structure/statue/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)


/obj/structure/statue/plasma/bullet_act(obj/item/projectile/Proj)
	var/burn = FALSE
	if(!(Proj.nodamage) && Proj.damage_type == BURN)
		PlasmaBurn(2500)
		burn = TRUE
	if(burn)
		var/turf/T = get_turf(src)
		if(Proj.firer)
			message_admins("Plasma statue ignited by [ADMIN_LOOKUPFLW(Proj.firer)] in [ADMIN_COORDJMP(T)]",0,1)
			log_game("Plasma statue ignited by [key_name(Proj.firer)] in [COORD(T)]")
		else
			message_admins("Plasma statue ignited by [Proj]. No known firer, in [ADMIN_COORDJMP(T)]",0,1)
			log_game("Plasma statue ignited by [Proj] in [COORD(T)]. No known firer.")
	..()

/obj/structure/statue/plasma/attackby(obj/item/W, mob/user, params)
	if(W.is_hot() > 300)//If the temperature of the object is over 300, then ignite
		var/turf/T = get_turf(src)
		message_admins("Plasma statue ignited by [ADMIN_LOOKUPFLW(user)] in [ADMIN_COORDJMP(T)]",0,1)
		log_game("Plasma statue ignited by [key_name(user)] in [COORD(T)]")
		ignite(W.is_hot())
	else
		return ..()

/obj/structure/statue/plasma/proc/PlasmaBurn()
	atmos_spawn_air("plasma=400;TEMP=1000")
	deconstruct(FALSE)

/obj/structure/statue/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

//////////////////////gold///////////////////////////////////////

/obj/structure/statue/gold
	max_integrity = 300
	material_drop_type = /obj/item/stack/sheet/mineral/gold
	desc = "This is a highly valuable statue made from gold."

/obj/structure/statue/gold/hos
	name = "statue of the head of security"
	icon_state = "hos"

/obj/structure/statue/gold/hop
	name = "statue of the head of personnel"
	icon_state = "hop"

/obj/structure/statue/gold/cmo
	name = "statue of the chief medical officer"
	icon_state = "cmo"

/obj/structure/statue/gold/ce
	name = "statue of the chief engineer"
	icon_state = "ce"

/obj/structure/statue/gold/rd
	name = "statue of the research director"
	icon_state = "rd"

//////////////////////////silver///////////////////////////////////////

/obj/structure/statue/silver
	max_integrity = 300
	material_drop_type = /obj/item/stack/sheet/mineral/silver
	desc = "This is a valuable statue made from silver."

/obj/structure/statue/silver/md
	name = "statue of a medical officer"
	icon_state = "md"

/obj/structure/statue/silver/janitor
	name = "statue of a janitor"
	icon_state = "jani"

/obj/structure/statue/silver/sec
	name = "statue of a security officer"
	icon_state = "sec"

/obj/structure/statue/silver/secborg
	name = "statue of a security cyborg"
	icon_state = "secborg"

/obj/structure/statue/silver/medborg
	name = "statue of a medical cyborg"
	icon_state = "medborg"

/////////////////////////diamond/////////////////////////////////////////

/obj/structure/statue/diamond
	max_integrity = 1000
	material_drop_type = /obj/item/stack/sheet/mineral/diamond
	desc = "This is a very expensive diamond statue"

/obj/structure/statue/diamond/captain
	name = "statue of THE captain."
	icon_state = "cap"

/obj/structure/statue/diamond/ai1
	name = "statue of the AI hologram."
	icon_state = "ai1"

/obj/structure/statue/diamond/ai2
	name = "statue of the AI core."
	icon_state = "ai2"

////////////////////////bananium///////////////////////////////////////

/obj/structure/statue/bananium
	max_integrity = 300
	material_drop_type = /obj/item/stack/sheet/mineral/bananium
	desc = "A bananium statue with a small engraving:'HOOOOOOONK'."
	var/spam_flag = 0

/obj/structure/statue/bananium/clown
	name = "statue of a clown"
	icon_state = "clown"

/obj/structure/statue/bananium/CollidedWith(atom/movable/AM)
	honk()
	..()

/obj/structure/statue/bananium/attackby(obj/item/W, mob/user, params)
	honk()
	return ..()

/obj/structure/statue/bananium/attack_hand(mob/user)
	honk()
	..()

/obj/structure/statue/bananium/attack_paw(mob/user)
	honk()
	..()

/obj/structure/statue/bananium/proc/honk()
	if(!spam_flag)
		spam_flag = 1
		playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)
		spawn(20)
			spam_flag = 0

/////////////////////sandstone/////////////////////////////////////////

/obj/structure/statue/sandstone
	max_integrity = 50
	material_drop_type = /obj/item/stack/sheet/mineral/sandstone

/obj/structure/statue/sandstone/assistant
	name = "statue of an assistant"
	desc = "A cheap statue of sandstone for a greyshirt."
	icon_state = "assist"


/obj/structure/statue/sandstone/venus //call me when we add marble i guess
	name = "statue of a pure maiden"
	desc = "An ancient marble statue. The subject is depicted with a floor-length braid and is wielding a toolbox. By Jove, it's easily the most gorgeous depiction of a woman you've ever seen. The artist must truly be a master of his craft. Shame about the broken arm, though."
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "venus"

/////////////////////snow/////////////////////////////////////////

/obj/structure/statue/snow
	max_integrity = 50
	material_drop_type = /obj/item/stack/sheet/mineral/snow

/obj/structure/statue/snow/snowman
	name = "snowman"
	desc = "Several lumps of snow put together to form a snowman."
	icon_state = "snowman"
