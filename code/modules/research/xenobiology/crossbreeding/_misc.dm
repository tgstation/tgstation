/*
Slimecrossing Items
	General items added by the slimecrossing system.
	Collected here for clarity.
*/

//Timefreeze camera - Burning Sepia
/obj/item/camera/timefreeze
	name = "sepia-tinted camera"
	desc = "They say a picture is like a moment stopped in time."
	pictures_left = 1
	pictures_max = 1

/obj/item/camera/timefreeze/afterattack(atom/target, mob/user, flag)
	if(!on || !pictures_left || !isturf(target.loc))
		return
	new /obj/effect/timestop(get_turf(target), 2, 50, list(user))
	. = ..()
	var/text = "The camera fades away"
	if(disk)
		text += ", leaving the disk behind!"
		if(!user.put_in_hands(disk))
			disk.forceMove(user.drop_location())
	else
		text += "!"
	to_chat(user,"<span class='notice'>[text]</span>")
	qdel(src)

//Hypercharged slime cell - Charged Yellow
/obj/item/stock_parts/cell/high/slime/hypercharged
	name = "hypercharged slime core"
	desc = "A charged yellow slime extract, infused with even more plasma. It almost hurts to touch."
	rating = 7 //Roughly 1.5 times the original.
	maxcharge = 20000 //2 times the normal one.
	chargerate = 2250 //1.5 times the normal rate.

//Barrier cube - Chilling Grey
/obj/item/barriercube
	name = "barrier cube"
	desc = "A compressed cube of slime. When squeezed, it grows to massive size!"
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "barriercube"
	w_class = WEIGHT_CLASS_TINY

/obj/item/barriercube/attack_self(mob/user)
	if(locate(/obj/structure/barricade/slime) in get_turf(loc))
		to_chat(user, "<span class='warning'>You can't fit more than one barrier in the same space!</span>")
		return
	to_chat(user, "<span class='notice'>You squeeze [src].</span>")
	var/obj/B = new /obj/structure/barricade/slime(get_turf(loc))
	B.visible_message("<span class='warning'>[src] suddenly grows into a large, gelatinous barrier!</span>")
	qdel(src)

//Slime barricade - Chilling Grey
/obj/structure/barricade/slime
	name = "gelatinous barrier"
	desc = "A huge chunk of grey slime. Bullets might get stuck in it."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "slimebarrier"
	proj_pass_rate = 40
	max_integrity = 60

//Melting Gel Wall - Chilling Metal
/obj/effect/forcefield/slimewall
	name = "solidified gel"
	desc = "A mass of solidified slime gel - completely impenetrable, but it's melting away!"
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "slimebarrier_thick"
	CanAtmosPass = ATMOS_PASS_NO
	opacity = TRUE
	timeleft = 100

//Rainbow barrier - Chilling Rainbow
/obj/effect/forcefield/slimewall/rainbow
	name = "rainbow barrier"
	desc = "Despite others' urgings, you probably shouldn't taste this."
	icon_state = "rainbowbarrier"

//Ration pack - Chilling Silver
/obj/item/reagent_containers/food/snacks/rationpack
	name = "ration pack"
	desc = "A square bar that sadly <i>looks</i> like chocolate, packaged in a nondescript grey wrapper. Has saved soldiers' lives before - usually by stopping bullets."
	icon_state = "rationpack"
	bitesize = 3
	junkiness = 15
	filling_color = "#964B00"
	tastes = list("cardboard" = 3, "sadness" = 3)
	foodtype = null //Don't ask what went into them. You're better off not knowing.
	list_reagents = list("stabilizednutriment" = 10, "nutriment" = 2) //Won't make you fat. Will make you question your sanity.

/obj/item/reagent_containers/food/snacks/rationpack/checkLiked(fraction, mob/M)	//Nobody likes rationpacks. Nobody.
	if(last_check_time + 50 < world.time)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.mind && !H.has_trait(TRAIT_AGEUSIA))
				to_chat(H,"<span class='notice'>That didn't taste very good...</span>") //No disgust, though. It's just not good tasting.
				GET_COMPONENT_FROM(mood, /datum/component/mood, H)
				if(mood)
					mood.add_event(null,"gross_food", /datum/mood_event/gross_food)
				last_check_time = world.time
				return
	..()

//Ice stasis block - Chilling Dark Blue
/obj/structure/ice_stasis
	name = "ice block"
	desc = "A massive block of ice. You can see something vaguely humanoid inside."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "frozen"
	density = TRUE
	max_integrity = 100
	armor = list("melee" = 30, "bullet" = 50, "laser" = -50, "energy" = -50, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = -80, "acid" = 30)

/obj/structure/ice_stasis/Initialize()
	. = ..()
	playsound(src, 'sound/magic/ethereal_exit.ogg', 50, 1)

/obj/structure/ice_stasis/Destroy()
	for(var/atom/movable/M in contents)
		M.forceMove(loc)
	playsound(src, 'sound/effects/glassbr3.ogg', 50, 1)
	return ..()

//Gold capture device - Chilling Gold
/obj/item/capturedevice
	name = "gold capture device"
	desc = "Bluespace technology packed into a roughly egg-shaped device, used to store nonhuman creatures. Can't catch them all, though - it only fits one."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "capturedevice"

/obj/item/capturedevice/attack(mob/living/M, mob/user)
	if(length(contents))
		to_chat(user, "<span class='warning'>The device already has something inside.</span>")
		return
	if(!isanimal(M))
		to_chat(user, "<span class='warning'>The capture device only works on simple creatures.</span>")
		return
	if(M.mind)
		to_chat(user, "<span class='notice'>You offer the device to [M].</span>")
		if(alert(M, "Would you like to enter [user]'s capture device?", "Gold Capture Device", "Yes", "No") == "Yes")
			if(user.canUseTopic(src, BE_CLOSE) && user.canUseTopic(M, BE_CLOSE))
				to_chat(user, "<span class='notice'>You store [M] in the capture device.</span>")
				to_chat(M, "<span class='notice'>The world warps around you, and you're suddenly in an endless void, with a window to the outside floating in front of you.</span>")
				store(M, user)
			else
				to_chat(user, "<span class='warning'>You were too far away from [M].</span>")
				to_chat(M, "<span class='warning'>You were too far away from [user].</span>")
		else
			to_chat(user, "<span class='warning'>[M] refused to enter the device.</span>")
			return
	else
		if(istype(M, /mob/living/simple_animal/hostile) && !("neutral" in M.faction))
			to_chat(user, "<span class='warning'>This creature is too aggressive to capture.</span>")
			return
	to_chat(user, "<span class='notice'>You store [M] in the capture device.</span>")
	store(M)

/obj/item/capturedevice/attack_self(mob/user)
	if(contents.len)
		to_chat(user, "<span class='notice'>You open the capture device!</span>")
		release()
	else
		to_chat(user, "<span class='warning'>The device is empty...</span>")

/obj/item/capturedevice/proc/store(var/mob/living/M)
	M.forceMove(src)

/obj/item/capturedevice/proc/release()
	for(var/atom/movable/M in contents)
		M.forceMove(get_turf(loc))
