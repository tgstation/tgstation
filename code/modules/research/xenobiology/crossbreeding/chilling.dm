/*
Chilling extracts:
	Have a unique, primarily defensive effect when
	filled with 10u plasma and activated in-hand.
*/
/obj/item/slimecross/chilling
	name = "chilling extract"
	desc = "It's cold to the touch, as if frozen solid."
	effect = "chilling"
	container_type = INJECTABLE | DRAWABLE
	icon_state = "chilling"

/obj/item/slimecross/chilling/Initialize()
	..()
	create_reagents(10)

/obj/item/slimecross/chilling/attack_self(mob/user)
	if(!reagents.has_reagent("plasma",10))
		to_chat(user, "<span class='warning'>This extract needs to be full of plasma to activate!</span>")
		return
	reagents.remove_reagent("plasma",10)
	to_chat(user, "<span class='notice'>You squeeze the extract, and it absorbs the plasma!</span>")
	playsound(src, 'sound/effects/bubbles.ogg', 50, 1)
	playsound(src, 'sound/effects/glassbr1.ogg', 50, 1)
	do_effect(user)

/obj/item/slimecross/chilling/proc/do_effect(mob/user) //If, for whatever reason, you don't want to delete the extract, don't do ..()
	qdel(src)
	return

/obj/item/slimecross/chilling/grey
	colour = "grey"

/obj/item/slimecross/chilling/grey/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] produces a few small, grey cubes</span>")
	for(var/i in 1 to 3)
		new /obj/item/barriercube(get_turf(user))
	..()

/obj/item/slimecross/chilling/orange
	colour = "orange"

/obj/item/slimecross/chilling/orange/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] shatters, and lets out a jet of heat!</span>")
	for(var/turf/T in range(get_turf(user),2))
		if(get_dist(get_turf(user), T) > 1)
			new /obj/effect/hotspot(T)
	..()

/obj/item/slimecross/chilling/purple
	colour = "purple"

/obj/item/slimecross/chilling/purple/do_effect(mob/user)
	var/area/A = get_area(get_turf(user))
	if(A.outdoors)
		to_chat(user, "<span class='warning'>[src] can't effect such a large area.</span>")
		return
	user.visible_message("<span class='notice'>[src] shatters, and a healing aura fills the room briefly.</span>")
	for(var/mob/living/carbon/C in A)
		C.reagents.add_reagent("regen_jelly",10)
	..()

/obj/item/slimecross/chilling/blue
	colour = "blue"

/obj/item/slimecross/chilling/blue/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] cracks, and spills out a liquid goo, which reforms into a mask!</span>")
	new /obj/item/clothing/mask/nobreath(get_turf(user))
	..()

/obj/item/slimecross/chilling/metal
	colour = "metal"

/obj/item/slimecross/chilling/metal/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] melts like quicksilver, and surrounds [user] in a wall!</span>")
	for(var/turf/T in range(get_turf(user),1))
		if(get_dist(get_turf(user), T) > 0)
			new /obj/effect/forcefield/slimewall(T)
	..()

/obj/item/slimecross/chilling/yellow
	colour = "yellow"

/obj/item/slimecross/chilling/yellow/do_effect(mob/user)
	var/area/A = get_area(get_turf(user))
	user.visible_message("<span class='notice'>[src] shatters, and a the air suddenly feels charged for a moment.</span>")
	for(var/obj/machinery/power/apc/C in A)
		if(C.cell)
			C.cell.charge = min(C.cell.charge + C.cell.maxcharge/2, C.cell.maxcharge)
	..()

/obj/item/slimecross/chilling/darkpurple
	colour = "dark purple"

/obj/item/slimecross/chilling/darkpurple/do_effect(mob/user)
	var/area/A = get_area(get_turf(user))
	if(A.outdoors)
		to_chat(user, "<span class='warning'>[src] can't effect such a large area.</span>")
		return
	var/filtered = FALSE
	for(var/turf/open/T in A)
		var/datum/gas_mixture/G = T.air
		if(istype(G))
			G.assert_gas(/datum/gas/plasma)
			G.gases[/datum/gas/plasma][MOLES] = 0
			filtered = TRUE
			G.garbage_collect()
			T.air_update_turf()
	if(filtered)
		user.visible_message("<span class='notice'>Cracks spread throughout [src], and some air is sucked in!</span>")
	else
		user.visible_message("<span class='notice'>[src] cracks, but nothing happens.</span>")
	..()

/obj/item/slimecross/chilling/darkblue
	colour = "dark blue"

/obj/item/slimecross/chilling/darkblue/do_effect(mob/user)
	if(isliving(user))
		user.visible_message("<span class='notice'>[src] freezes over [user]'s entire body!</span>")
		var/mob/living/M = user
		M.apply_status_effect(/datum/status_effect/frozenstasis)
	..()

/obj/item/slimecross/chilling/silver
	colour = "silver"

/obj/item/slimecross/chilling/silver/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] crumbles into icy powder, leaving behind several emergency food supplies!</span>")
	var/amount = rand(5, 10)
	for(var/i in 1 to amount)
		new /obj/item/reagent_containers/food/snacks/rationpack(get_turf(user.loc))
	..()

/obj/item/slimecross/chilling/bluespace
	colour = "bluespace"
	var/list/allies = list()
	var/active = FALSE

/obj/item/slimecross/chilling/bluespace/afterattack(atom/O, mob/user, proximity)
	if(!proximity || !isliving(O) || active)
		return
	if(O in allies)
		allies -= O
		to_chat(user, "<span class='notice'>You unlink [src] with [O].</span>")
	else
		allies |= O
		to_chat(user, "<span class='notice'>You link [src] with [O].</span>")
	return

/obj/item/slimecross/chilling/bluespace/do_effect(mob/user)
	if(allies.len <= 0)
		to_chat(user, "<span class='warning'>[src] is not linked to anyone!</span>")
		return
	to_chat(user, "<span class='notice'>You feel [src] pulse as it begins charging bluespace energies...</span>")
	active = TRUE
	for(var/mob/living/M in allies)
		var/datum/status_effect/slimerecall/S = M.apply_status_effect(/datum/status_effect/slimerecall)
		S.target = user
	if(do_after(user, 100, target=src))
		to_chat(user, "<span class='notice'>[src] shatters as it tears a hole in reality, snatching the linked individuals from the void!</span>")
		for(var/mob/living/M in allies)
			var/datum/status_effect/slimerecall/S = M.has_status_effect(/datum/status_effect/slimerecall)
			M.remove_status_effect(S)
	else
		to_chat(user, "<span class='warning'>[src] falls dark, dissolving into nothing as the energies fade away.</span>")
		for(var/mob/living/M in allies)
			var/datum/status_effect/slimerecall/S = M.has_status_effect(/datum/status_effect/slimerecall)
			if(istype(S))
				S.interrupted = TRUE
				M.remove_status_effect(S)
	..()

/obj/item/slimecross/chilling/sepia
	colour = "sepia"
	var/list/allies = list()

/obj/item/slimecross/chilling/sepia/afterattack(atom/O, mob/user, proximity)
	if(!proximity || !isliving(O))
		return
	if(O in allies)
		allies -= O
		to_chat(user, "<span class='notice'>You unlink [src] with [O].</span>")
	else
		allies |= O
		to_chat(user, "<span class='notice'>You link [src] with [O].</span>")
	return

/obj/item/slimecross/chilling/sepia/do_effect(mob/user)
	user.visible_message("<span class='warning'>[src] shatters, freezing time itself!</span>")
	new /obj/effect/timestop(get_turf(user), 2, 300, allies)

/obj/item/slimecross/chilling/cerulean
	colour = "cerulean"

/obj/item/slimecross/chilling/cerulean/do_effect(mob/user)
	if(isliving(user))
		user.visible_message("<span class='warning'>[src] creaks and shifts into a clone of [user]!</span>")
		var/mob/living/M = user
		M.apply_status_effect(/datum/status_effect/slime_clone)
	..()

/obj/item/slimecross/chilling/pyrite
	colour = "pyrite"

/obj/item/slimecross/chilling/pyrite/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] crystallizes into a pair of spectacles!</span>")
	new /obj/item/clothing/glasses/prism_glasses(get_turf(user.loc))
	..()

/obj/item/slimecross/chilling/red
	colour = "red"

/obj/item/slimecross/chilling/red/do_effect(mob/user)
	var/slimesfound = FALSE
	for(var/mob/living/simple_animal/slime/S in view(get_turf(user), 7))
		slimesfound = TRUE
		S.docile = TRUE
	if(slimesfound)
		user.visible_message("<span class='notice'>[src] lets out a peaceful ring as it shatters, and nearby slimes seem calm.</span>")
	else
		user.visible_message("<span class='notice'>[src] lets out a peaceful ring as it shatters, but nothing happens...</span>")
	..()

/obj/item/slimecross/chilling/green
	colour = "green"

/obj/item/slimecross/chilling/green/do_effect(mob/user)
	var/which_hand = "l_hand"
	if(!(user.active_hand_index % 2))
		which_hand = "r_hand"
	var/mob/living/L = user
	if(!istype(user))
		return
	var/obj/item/held = L.get_active_held_item() //This should be itself, but just in case...
	L.dropItemToGround(held)
	var/obj/item/gun/magic/bloodchill/gun = new(user)
	if(!L.put_in_hands(gun))
		qdel(gun)
		user.visible_message("<span class='warning'>[src] flash-freezes [user]'s arm, cracking the flesh horribly!</span>")
	else
		user.visible_message("<span class='danger'>[src] chills and snaps off the front of the bone on [user]'s arm, leaving behind a strange, gun-like structure!</span>")
	user.emote("scream")
	L.apply_damage(30,BURN,which_hand)
	..()

/obj/item/slimecross/chilling/pink
	colour = "pink"

/obj/item/slimecross/chilling/pink/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] cracks like an egg, and an adorable puppy comes tumbling out!</span>")
	new /mob/living/simple_animal/pet/dog/corgi/puppy/slime(get_turf(user.loc))
	..()

/obj/item/slimecross/chilling/gold
	colour = "gold"

/obj/item/slimecross/chilling/gold/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] lets off golden light as it melts and reforms into an egg-like device!</span>")
	new /obj/item/capturedevice(get_turf(user.loc))
	..()

/obj/item/slimecross/chilling/oil
	colour = "oil"

/obj/item/slimecross/chilling/oil/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] begins to shake with muted intensity!</span>")
	addtimer(CALLBACK(src, .proc/boom), 50)

/obj/item/slimecross/chilling/oil/proc/boom()
	explosion(get_turf(src), -1, -1, 3, 10) //Large radius, but mostly light damage.
	qdel(src)

/obj/item/slimecross/chilling/black
	colour = "black"

/obj/item/slimecross/chilling/black/do_effect(mob/user)
	if(ishuman(user))
		user.visible_message("<span class='notice'>[src] crystallizes along [user]'s skin, turning into metallic scales!</span>")
		var/mob/living/carbon/human/H = user
		H.set_species(/datum/species/golem/random)
	..()

/obj/item/slimecross/chilling/lightpink
	colour = "light pink"

/obj/item/slimecross/chilling/lightpink/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] blooms into a beautiful flower!</span>")
	new /obj/item/clothing/head/peaceflower(get_turf(user.loc))
	..()

/obj/item/slimecross/chilling/adamantine
	colour = "adamantine"

/obj/item/slimecross/chilling/adamantine/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] creaks and breaks as it shifts into a heavy set of armor!</span>")
	new /obj/item/clothing/suit/armor/heavy/adamantine(get_turf(user.loc))
	..()

/obj/item/slimecross/chilling/rainbow
	colour = "rainbow"

/obj/item/slimecross/chilling/rainbow/do_effect(mob/user)
	var/area/A = get_area(get_turf(user))
	if(A.outdoors)
		to_chat(user, "<span class='warning'>[src] can't effect such a large area.</span>")
		return
	user.visible_message("<span class='warning'>[src] reflects an array of dazzling colors and light, energy rushing to nearby doors!</span>")
	for(var/obj/machinery/door/airlock/door in A)
		new /obj/effect/forcefield/slimewall/rainbow(door.loc)
	..()

/////////////////////////////////////
///////		MISC STUFF		/////////
/////////////////////////////////////

/obj/item/barriercube
	name = "barrier cube"
	desc = "A compressed cube of slime. When squeezed, it grows to massive size!"
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "barriercube"
	w_class = WEIGHT_CLASS_TINY

/obj/item/barriercube/attack_self(mob/user)
	if(locate(/obj/structure/barricade/slime) in get_turf(src.loc))
		to_chat(user, "<span class='warning'>You can't fit more than one barrier in the same space!</span>")
		return
	to_chat(user, "<span class='notice'>You squeeze [src].</span>")
	var/obj/B = new /obj/structure/barricade/slime(get_turf(src.loc))
	B.visible_message("<span class='warning'>[src] suddenly grows into a large, gelatinous barrier!</span>")
	qdel(src)

/obj/structure/barricade/slime
	name = "gelatinous barrier"
	desc = "A huge chunk of grey slime. Bullets might get stuck in it."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "slimebarrier"
	proj_pass_rate = 40
	max_integrity = 60

/obj/item/clothing/mask/nobreath
	name = "rebreather mask"
	desc = "A transparent mask, resembling a conventional breath mask, but made of bluish slime. Seems to lack any air supply tube, though."
	icon_state = "slime"
	item_state = "slime"
	body_parts_covered = 0
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0
	permeability_coefficient = 0.5
	flags_cover = MASKCOVERSMOUTH
	resistance_flags = NONE

/obj/item/clothing/mask/nobreath/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot == slot_wear_mask)
		user.add_trait(TRAIT_NOBREATH, "breathmask_[REF(src)]")

/obj/item/clothing/mask/nobreath/dropped(mob/living/carbon/human/user)
	..()
	user.remove_trait(TRAIT_NOBREATH, "breathmask_[REF(src)]")

/obj/effect/forcefield/slimewall
	name = "solidified gel"
	desc = "A mass of solidified slime gel - completely impenetrable, but it's melting away!"
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "slimebarrier_thick"
	CanAtmosPass = ATMOS_PASS_NO
	opacity = TRUE
	timeleft = 100

/obj/effect/forcefield/slimewall/rainbow
	name = "rainbow barrier"
	desc = "Despite others' urgings, you probably shouldn't taste this."
	icon_state = "rainbowbarrier"

/obj/item/reagent_containers/food/snacks/rationpack
	name = "ration pack"
	desc = "A square bar that sadly <i>looks</i> like chocolate, packaged in a nondescript grey wrapper. Has saved soldiers' lives before - usually by stopping bullets."
	icon_state = "rationpack"
	bitesize = 3
	eatverb = "choke down"
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
					mood.add_event("gross_food", /datum/mood_event/gross_food)
				last_check_time = world.time
				return
	..()

/obj/structure/ice_stasis
	name = "ice block"
	desc = "A massive block of ice. You can see something vaguely humanoid inside."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "frozen"
	density = TRUE
	max_integrity = 100
	armor = list("melee" = 30, "bullet" = 50, "laser" = -50, "energy" = -50, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = -80, "acid" = 30)

/obj/structure/ice_stasis/Initialize()
	playsound(src, 'sound/magic/ethereal_exit.ogg', 50, 1)
	..()

/obj/structure/ice_stasis/Destroy()
	for(var/atom/movable/M in contents)
		M.forceMove(loc)
	playsound(src, 'sound/effects/glassbr3.ogg', 50, 1)
	..()

/obj/item/clothing/glasses/prism_glasses
	name = "prism glasses"
	desc = "The lenses seem to glow slightly, and reflect light into dazzling colors."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "prismglasses"
	var/colour = "#FFFFFF"
	actions_types = list(/datum/action/item_action/change_prism_colour, /datum/action/item_action/place_light_prism)

/obj/item/clothing/glasses/prism_glasses/item_action_slot_check(slot)
	if(slot == slot_glasses)
		return 1

/obj/structure/light_prism
	name = "light prism"
	desc = "A shining crystal of semi-solid light. Looks fragile."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "lightprism"
	density = FALSE
	anchored = TRUE
	max_integrity = 10

/obj/structure/light_prism/Initialize(var/colour)
	. = ..()
	color = colour
	light_color = colour
	set_light(5)

/obj/structure/light_prism/attack_hand(mob/user)
	to_chat(user, "<span class='notice'>You dispel [src]</span>")
	qdel(src)

/datum/action/item_action/change_prism_colour
	name = "Adjust Prismatic Lens"
	icon_icon = 'icons/obj/slimecrossing.dmi'
	button_icon_state = "prismcolor"

/datum/action/item_action/change_prism_colour/Trigger()
	var/obj/item/clothing/glasses/prism_glasses/glasses = target
	var/new_color = input(owner, "Choose the lens color:", "Color change",glasses.colour) as color|null
	if(!new_color)
		return
	glasses.colour = new_color

/datum/action/item_action/place_light_prism
	name = "Fabricate Light Prism"
	icon_icon = 'icons/obj/slimecrossing.dmi'
	button_icon_state = "lightprism"

/datum/action/item_action/place_light_prism/Trigger()
	var/obj/item/clothing/glasses/prism_glasses/glasses = target
	if(locate(/obj/structure/light_prism) in get_turf(owner))
		to_chat(owner, "<span class='warning'>There isn't enough ambient energy to fabricate another light prism here.</span>")
		return
	if(istype(glasses))
		if(!glasses.colour)
			to_chat(owner, "<span class='warning'>The lens is oddly opaque...</span>")
			return
		to_chat(owner, "<span class='notice'>You channel nearby light into a glowing, ethereal prism.</span>")
		new /obj/structure/light_prism(get_turf(owner), glasses.colour)

/obj/item/gun/magic/bloodchill
	name = "blood chiller"
	desc = "A horrifying weapon made of your own bone and blood vessels. It shoots slowing globules of your own blood. Ech."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "bloodgun"
	item_state = "bloodgun"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	flags_1 = ABSTRACT_1 | NODROP_1 | DROPDEL_1
	w_class = WEIGHT_CLASS_HUGE
	force = 5
	max_charges = 1 //Recharging costs blood.
	recharge_rate = 1
	ammo_type = /obj/item/ammo_casing/magic/bloodchill
	fire_sound = 'sound/effects/attackblob.ogg'

/obj/item/gun/magic/bloodchill/process()
	charge_tick++
	if(charge_tick < recharge_rate || charges >= max_charges)
		return 0
	charge_tick = 0
	var/mob/living/M = loc
	if(istype(M) && M.blood_volume >= 20)
		charges++
		M.blood_volume -= 20
	if(charges == 1)
		recharge_newshot()
	return 1

/obj/item/ammo_casing/magic/bloodchill
	projectile_type = /obj/item/projectile/magic/bloodchill

/obj/item/projectile/magic/bloodchill
	name = "blood ball"
	icon_state = "pulse0_bl"
	damage = 0
	damage_type = OXY
	nodamage = 1
	hitsound = 'sound/effects/splat.ogg'

/obj/item/projectile/magic/bloodchill/on_hit(mob/living/carbon/human/target)
	. = ..()
	if(ishuman(target))
		target.apply_status_effect(/datum/status_effect/bloodchill)

/mob/living/simple_animal/pet/dog/corgi/puppy/slime
	name = "\improper slime corgi puppy"
	real_name = "slime corgi puppy"
	desc = "An unbearably cute pink slime corgi puppy."
	icon_state = "slime_puppy"
	icon_living = "slime_puppy"
	icon_dead = "slime_puppy_dead"
	nofur = TRUE
	gold_core_spawnable = NO_SPAWN
	speak_emote = list("blorbles", "bubbles", "borks")
	emote_hear = list("bubbles!", "splorts.", "splops!")
	emote_see = list("gets goop everywhere.", "flops.", "jiggles!")

/obj/item/capturedevice
	name = "gold capture device"
	desc = "Bluespace technology packed into a roughly egg-shaped device, used to store nonhuman creatures. Can't catch them all, though - it only fits one."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "capturedevice"

/obj/item/capturedevice/attack(mob/living/M, mob/user)
	if(contents.len)
		to_chat(user, "<span class='warning'>The device already has something inside.</span>")
	if(!isanimal(M))
		to_chat(user, "<span class='warning'>The capture device only works on simple creatures.</span>")
		return
	if(M.mind)
		to_chat(user, "<span class='notice'>You offer the device to [M].</span>")
		if(alert(M, "Would you like to enter [user]'s capture device?", "Yes", "No") == "Yes")
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

/obj/item/clothing/head/peaceflower
	name = "heroine bud"
	desc = "You feel at peace. How could you ever want to feel any different?"
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "peaceflower"
	item_state = "peaceflower"

/obj/item/clothing/head/peaceflower/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot == slot_head)
		user.add_trait(TRAIT_PACIFISM, "peaceflower_[REF(src)]")

/obj/item/clothing/head/peaceflower/dropped(mob/living/carbon/human/user)
	..()
	user.remove_trait(TRAIT_PACIFISM, "peaceflower_[REF(src)]")

/obj/item/clothing/head/peaceflower/attack_hand(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(src == C.head)
			to_chat(user, "<span class='warning'>You feel at peace. <b style='color:pink'>Why would you want anything else?</b></span>")
			return
	return ..()

/obj/item/clothing/suit/armor/heavy/adamantine
	name = "adamantine armor"
	desc = "A full suit of adamantine plate armor. Impressively resistant to damage, but weighs about as much as you do."
	icon_state = "adamsuit"
	item_state = "adamsuit"
	flags_inv = list()
	var/hit_reflect_chance = 40
	slowdown = 4


/obj/item/clothing/suit/armor/heavy/adamantine/IsReflect(def_zone)
	if(def_zone in list(BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG) && prob(hit_reflect_chance))
		return TRUE
	else
		return FALSE

/obj/item/clothing/suit/armor/heavy/adamantine/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/clothing/suit/armor/heavy/adamantine/process()
	slowdown = 4

/obj/item/clothing/suit/armor/heavy/adamantine/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()
