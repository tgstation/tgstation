/* Clown Items
 * Contains:
 * 		Banana Peels
 *		Soap
 *		Bike Horns
 */

/*
 * Banana Peals
 */
/obj/item/weapon/bananapeel/Crossed(AM as mob|obj)
	if (istype(AM, /mob/living/carbon))
		var/mob/M =	AM
		if(!M.walking()) return

		if (M.CheckSlip() < 1)
			return

		M.stop_pulling()
		M.simple_message("<span class='notice'> You slipped on the [name]!</span>",
			"<span class='userdanger'>Something is scratching at your feet! Oh god!</span>")
		playsound(get_turf(src), 'sound/misc/slip.ogg', 50, 1, -3)
		M.Stun(2)
		M.Weaken(2)

/*
 * Soap
 */
/obj/item/weapon/soap/Crossed(AM as mob|obj) //EXACTLY the same as bananapeel for now, so it makes sense to put it in the same dm -- Urist
	if (istype(AM, /mob/living/carbon))
		var/mob/M =	AM
		if(!M.walking()) return

		if (M.CheckSlip() < 1)
			return

		M.stop_pulling()
		M.simple_message("<span class='notice'> You slipped on the [name]!</span>",
			"<span class='userdanger'>Something is scratching at your feet! Oh god!</span>")
		playsound(get_turf(src), 'sound/misc/slip.ogg', 50, 1, -3)
		M.Stun(3)
		M.Weaken(2)

/obj/item/weapon/soap/afterattack(atom/target, mob/user as mob)
	//I couldn't feasibly fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	//Overlay bugs can probably be fixed by updating the user's icon, see watercloset.dm
	if(!user.Adjacent(target))
		return

	if(user.client && (target in user.client.screen) && !(user.l_hand == target || user.r_hand == target))
		user.simple_message("<span class='notice'>You need to take that [target.name] off before cleaning it.</span>",
			"<span class='notice'>You need to take that [target.name] off before destroying it.</span>")

	else if(istype(target,/obj/effect/decal/cleanable))
		user.simple_message("<span class='notice'>You scrub \the [target.name] out.</span>",
			"<span class='warning'>You destroy [pick("an artwork","a valuable artwork","a rare piece of art","a rare piece of modern art")].</span>")
		returnToPool(target)

	else if(istype(target,/turf/simulated))
		var/turf/simulated/T = target
		var/list/cleanables = list()
		for(var/obj/effect/decal/cleanable/CC in T)
			if(!istype(CC) || !CC)
				continue
			cleanables += CC
		if(!cleanables.len)
			user.simple_message("<span class='notice'>You fail to clean anything.</span>",
				"<span class='notice'>There is nothing for you to vandalize.</span>")
			return
		cleanables = shuffle(cleanables)
		var/obj/effect/decal/cleanable/C
		for(var/obj/effect/decal/cleanable/d in cleanables)
			if(d && istype(d))
				C = d
				break
		user.simple_message("<span class='notice'>You scrub \the [C.name] out.</span>",
			"<span class='warning'>You destroy [pick("an artwork","a valuable artwork","a rare piece of art","a rare piece of modern art")].</span>")
		returnToPool(C)
	else
		user.simple_message("<span class='notice'>You clean \the [target.name].</span>",
			"<span class='warning'>You [pick("deface","ruin","stain")] \the [target.name].</span>")
		target.clean_blood()
	return

/obj/item/weapon/soap/attack(mob/target as mob, mob/user as mob)
	if(target && user && ishuman(target) && !target.stat && !user.stat && user.zone_sel &&user.zone_sel.selecting == "mouth" )
		user.visible_message("<span class='warning'>\the [user] washes \the [target]'s mouth out with soap!</span>")
		return
	..()

/*
 * Bike Horns
 */
/obj/item/weapon/bikehorn
	name = "bike horn"
	desc = "A horn off of a bicycle."
	icon = 'icons/obj/items.dmi'
	icon_state = "bike_horn"
	item_state = "bike_horn"
	throwforce = 3
	w_class = 1.0
	throw_speed = 3
	throw_range = 15
	attack_verb = list("HONKED")
	hitsound = 'sound/items/bikehorn.ogg'
	var/honk_delay = 20
	var/last_honk_time = 0

/obj/item/weapon/bikehorn/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] places the [src.name] into \his mouth and honks the horn. </span>")
	playsound(get_turf(user), hitsound, 100, 1)
	user.gib()

/obj/item/weapon/bikehorn/attack_self(mob/user as mob)
	if(honk())
		add_fingerprint(user)

/obj/item/weapon/bikehorn/afterattack(atom/target, mob/user as mob, proximity_flag)
	//hitsound takes care of that
	//if(proximity_flag && istype(target, /mob)) //for honking in the chest
		//honk()
		//return

	if(!proximity_flag && istype(target, /mob) && honk()) //for skilled honking at a range
		target.visible_message(\
			"<span class='notice'>[user] honks \the [src] at \the [target].</span>",\
			"[user] honks \the [src] at you.")

/obj/item/weapon/bikehorn/proc/honk()
	if(world.time - last_honk_time >= honk_delay)
		last_honk_time = world.time
		playsound(get_turf(src), hitsound, 50, 1)
		return 1
	return 0

/obj/item/weapon/bikehorn/rubberducky
	name = "rubber ducky"
	desc = "Rubber ducky, you're the one, you make bathtime lots of fuuun. Rubber ducky, I'm awfully fooooond of yooooouuuu~"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	item_state = "rubberducky"
	attack_verb = list("quacked")
	hitsound = 'sound/items/quack.ogg'
	honk_delay = 10
