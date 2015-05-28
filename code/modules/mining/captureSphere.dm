//CAPTURE SPHERE: Captures a monster for later use. Gotta catch 'em all.
/obj/item/device/captureSphere
	name = "capture sphere"
	desc = "An odd device that can be used to entrap a creature for later release."
	w_class = 2
	icon = 'icons/obj/mining.dmi'
	icon_state = "captureSphere"
	item_state = "electronic"
	throw_speed = 3
	throw_range = 7
	slot_flags = SLOT_BELT
	var/mob/living/simple_animal/capturedMob = null
	var/capturing = 0
	var/newlyCaught = 0

/obj/item/device/captureSphere/attack_hand(mob/user)
	if(capturing)
		return 0
	if(newlyCaught)
		capturedMob.name = stripped_input(usr, "Give a name to the newly-caught monster?", "Monster Capture", "")
		newlyCaught = 0
		name = "[initial(name)] ([capturedMob.name])"
	..()

/obj/item/device/captureSphere/attack_self(mob/user)
	if(capturedMob && capturedMob.loc != src)
		if(!in_range(user, capturedMob))
			return
		capturedMob.visible_message("<span class='warning'>[capturedMob] is sucked into [src]!</span>")
		capturedMob.loc = src
		user.say("[pick("That's enough", "Come back", "Retreat")], [capturedMob.name]!")
		capturedMob.revive() //todo: replace
	..()

/obj/item/device/captureSphere/throw_impact(atom/hitAtom)
	..()
	if(!capturedMob)
		if(ismob(hitAtom))
			Capture(hitAtom)
		return
	if(capturedMob)
		Release(usr)

/obj/item/device/captureSphere/proc/Capture(var/mob/living/simple_animal/M)
	if(M.client || M.key || !istype(M) || !M || capturedMob || capturing)
		return 0
	capturing = 1
	src.visible_message("<span class='warning'>[M] is sucked into [src]!</span>")
	anchored = 1
	M.loc = src
	for(var/i = 0; i < 3; i++)
		sleep(10)
		src.visible_message("<span class='danger'>[src] [pick("jiggles", "wiggles", "spins", "rolls", "bounces")]...</span>")
		playsound(get_turf(src), 'sound/effects/stealthoff.ogg', 50, 1, 5)
		if(prob(M.health))
			playsound(get_turf(src), 'sound/effects/bang.ogg', 50, 1, 5)
			src.visible_message("<span class='warning'>[M] broke free!</span>")
			M.loc = get_turf(src)
			anchored = 0
			capturing = 0
			return 0
	capturedMob = M
	src.visible_message("<span class='notice'>[M] was caught!</span>")
	capturing = 0
	anchored = 0
	newlyCaught = 1
	capturedMob.faction = list("neutral")
	name = "[initial(name)] ([capturedMob.name])"
	return

/obj/item/device/captureSphere/proc/Release(var/mob/user)
	if(!capturedMob)
		return
	if(capturedMob && capturedMob.loc != src)
		return
	user.say("[pick("Go", "Get 'em")], [capturedMob.name]!")
	capturedMob.loc = get_turf(src)
	capturedMob.say("[capturedMob.name]!")

/*
HELP ME EI- ZAERS

//known issues
//captured mobs hp resets when released
//mobs previously captured can been stolen by other trainers, every ball is a snag ball
//captured mobs do not stay in the ball upon being captured and instead pop out immediately

		if(malfunctioning)
			var/mob/living/simple_animal/hostile/H = M
			H.faction |= list("capturesphere", "\ref[user]") // needs var/mob/user defined
			H.robust_searching = 1
			H.friends += user
			H.attack_same = 1
			log_game("[user] has captured hostile mob [M] with a malfunctioning capture sphere!")
			return

/obj/item/device/captureSphere/proc/Healing
	health ++ 10
	spawn(50)

/obj/item/device/captureSphere/emp_act()
    if(!malfunctioning)
        malfunctioning = 1

/obj/item/device/captureSphere/examine(mob/user)
    ..()
    if(malfunctioning)
        user << "<span class='info'>The display on [src] seems to be flickering.</span>"
*/
