
/obj/machinery/gibber
	name = "gibber"
	desc = "The name isn't descriptive enough?"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	density = 1
	anchored = 1
	var/operating = 0 //Is it on?
	var/dirty = 0 // Does it need cleaning?
	var/gibtime = 40 // Time from starting until meat appears
	var/mob/living/carbon/occupant // Mob who has been put inside
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 500

	var/require_aggressive_grab = 0
	var/allow_abiotic = 0
	var/eject_meat = 1
	var/xDir=1 // which direction do the meatslabs fly to? 1=west, -1=east
	var/yDir=0 // recommended values {-1,0,1}
	var/gibbing_sound='sound/effects/splat.ogg'
	var/gib_message="<span class='danger'>You hear a loud squelchy grinding sound.</span>"

//auto-gibs anything that bumps into it
/obj/machinery/gibber/autogibber
	var/turf/input_plate

	New()
		..()
		spawn(5)
			for(var/i in cardinal)
				var/obj/machinery/mineral/input/input_obj = locate( /obj/machinery/mineral/input, get_step(src.loc, i) )
				if(input_obj)
					if(isturf(input_obj.loc))
						input_plate = input_obj.loc
						del(input_obj)
						break

			if(!input_plate)
				diary << "a [src] didn't find an input plate."
				return

	Bumped(var/atom/A)
		if(!input_plate) return

		if(ismob(A))
			var/mob/M = A

			if(M.loc == input_plate
			)
				M.loc = src
				M.gib()


/obj/machinery/gibber/New()
	..()
	src.overlays += image('icons/obj/kitchen.dmi', "grjam")

/obj/machinery/gibber/update_icon()
	overlays.Cut()
	if (dirty)
		src.overlays += image('icons/obj/kitchen.dmi', "grbloody")
	if(stat & (NOPOWER|BROKEN))
		return
	if (!occupant)
		src.overlays += image('icons/obj/kitchen.dmi', "grjam")
	else if (operating)
		src.overlays += image('icons/obj/kitchen.dmi', "gruse")
	else
		src.overlays += image('icons/obj/kitchen.dmi', "gridle")

/obj/machinery/gibber/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/gibber/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	if(operating)
		user << "<span class='danger'>It's locked and running</span>"
		return
	else
		src.start_gibbing(user)

/obj/machinery/gibber/attackby(obj/item/weapon/grab/G as obj, mob/user as mob, var/location=src)
	if(src.occupant)
		user << "<span class='danger'>[src] is full, empty it first!</span>"
		return

	if(!(istype(G, /obj/item/weapon/grab) && (ismonkey(G.affecting) || ishuman(G.affecting))))
		user << "<span class='danger'>This item is not suitable for [src]!</span>"
		return

	if(G.affecting.abiotic(1) && allow_abiotic==0)
		user << "<span class='danger'>Subject may not have abiotic items on.</span>"
		return

	if(require_aggressive_grab && G.state<GRAB_AGGRESSIVE)
		user << "<span class='danger'>You must have a tighter grab on [G.affecting] to do that.</span>"
		return

	user.visible_message("<span class='danger'>[user] starts to put [G.affecting] into [src]!</span>")
	src.add_fingerprint(user)
	if(do_after(user, 30) && G && G.affecting && !occupant)
		user.visible_message("<span class='danger'>[user] stuffs [G.affecting] into [src]!</span>")
		put_in_gibber(G.affecting, location)
		del(G)
		update_icon()
		return 1


/obj/machinery/gibber/proc/put_in_gibber(var/mob/living/carbon/M, var/location=src) // this is used in hisgrace/proc/eat()
	if(M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = location
	M.loc = location
	src.occupant = M
	return



/obj/machinery/gibber/proc/start_gibbing(mob/user as mob, var/location=src.loc)
	if(!src) // This was for debugging but it started working when I put this here so I guess I'll keep it. I don't even.
		return
	if(src.operating) //runtime error at this line: no variable null.operating. eh?
		return
	if(!src.occupant)
		visible_message("<span class='danger'>You hear a loud metallic grinding sound.</span>")
		return
	if(use_power)
		use_power(1000)
	if(gib_message)
		visible_message(gib_message)
	src.operating = 1
	update_icon()

	var/total_slabs = 3

	spawn(gibtime)
		playsound(location, gibbing_sound, 50, 1)
		if(allow_abiotic)
			visible_message("<span class='danger'>[src] spits out the items it could not consume.</danger>")
			src.occupant.drop_all_items(get_turf(location))
		if(eject_meat)
			eject_meat(create_meat(total_slabs))
		if(user)
			src.occupant.attack_log += "\[[time_stamp()]\] Was gibbed by <b>[user]/[user.ckey]</b>" //One shall not simply gib a mob unnoticed!
			user.attack_log += "\[[time_stamp()]\] Gibbed <b>[src.occupant]/[src.occupant.ckey]</b>"
			log_attack("\[[time_stamp()]\] <b>[user]/[user.ckey]</b> gibbed <b>[src.occupant]/[src.occupant.ckey]</b>")
		src.occupant.death(1)
		src.occupant.ghostize()
		del(src.occupant)
		src.operating = 0
		update_icon()

/obj/machinery/gibber/proc/create_meat(var/total_slabs)

	var/obj/item/weapon/reagent_containers/food/snacks/meat/human/all_meat[total_slabs]
	for(var/i=1 to total_slabs)
		var/obj/item/weapon/reagent_containers/food/snacks/meat/human/new_meat
		if(ishuman(src.occupant))
			new_meat = new(src, src.occupant, total_slabs)
		else
			var/obj/item/weapon/reagent_containers/food/snacks/meat/other=new(src, src.occupant, total_slabs)
			new_meat = other
		all_meat[i] = new_meat
	return all_meat

/obj/machinery/gibber/proc/eject_meat(var/list/allmeat)
	for (var/i=1 to allmeat.len)
		var/obj/item/meatslab = allmeat[i]
		var/turf/Tx = locate(src.x - i*xDir, src.y-i*yDir, src.z)
		meatslab.loc = src.loc
		meatslab.throw_at(Tx,i,3)
		if (!Tx.density)
			new /obj/effect/decal/cleanable/blood/gibs(Tx,i)

/obj/machinery/gibber/container_resist()
	src.go_out()
	return

/obj/machinery/gibber/verb/eject()
	set category = "Object"
	set name = "empty gibber"
	set src in oview(1)

	if (usr.stat != 0)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/gibber/proc/go_out()
	if (!src.occupant || src.operating)
		return
	for(var/obj/O in src)
		O.loc = src.loc
	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.occupant = null
	update_icon()
	return