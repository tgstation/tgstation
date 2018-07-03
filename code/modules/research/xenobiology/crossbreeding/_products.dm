////////////////////////
////	BURNING		////
////////////////////////

/obj/item/camera/timefreeze
	name = "sepia-tinted camera"
	desc = "They say a picture is like a moment stopped in time."
	pictures_left = 1
	pictures_max = 1

/obj/item/camera/timefreeze/afterattack(atom/target, mob/user, flag)
	if(!on || !pictures_left || !isturf(target.loc))
		return
	new /obj/effect/timestop(get_turf(target), 2, 50, list(user))
	..()
	var/text = "The camera fades away"
	if(disk)
		text += ", leaving the disk behind!"
		user.put_in_hands(disk)
	else
		text += "!"
	to_chat(user,"<span class='notice'>[text]</span>")
	qdel(src)

/obj/item/slimepotion/extract_cloner
	name = "extract cloning potion"
	desc = "An more powerful version of the extract enhancer potion, capable of cloning regular slime extracts."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potpurple"

/obj/item/slimepotion/extract_cloner/afterattack(obj/item/target, mob/user , proximity)
	if(!proximity)
		return
	if(istype(target, /obj/item/reagent_containers))
		return ..(target, user, proximity)
	if(istype(target, /obj/item/slimecross))
		to_chat(user, "<span class='warning'>[target] is too complex for the potion to clone!</span>")
		return
	if(!istype(target, /obj/item/slime_extract))
		return
	var/obj/item/slime_extract/S = target
	if(S.recurring)
		to_chat(user, "<span class='warning'>[target] is too complex for the potion to clone!</span>")
		return
	var/path = S.type
	var/obj/item/slime_extract/C = new path(get_turf(target))
	C.Uses = S.Uses
	to_chat(user, "<span class='notice'>You pour the potion onto [target], and the fluid solidifies into a copy of it!</span>")
	qdel(src)
	return

/obj/item/melee/arm_blade/slime
	name = "slimy boneblade"
	desc = "What remains of the bones in your arm. Incredibly sharp, and painful for both you and your opponents."
	force = 15
	force_string = "painful"

/obj/item/melee/arm_blade/slime/attack(mob/living/L, mob/user)
	. = ..()
	if(prob(20))
		user.emote("scream")

/obj/item/kitchen/knife/rainbowknife
	name = "rainbow knife"
	desc = "A strange, transparent knife which constantly shifts color. It hums slightly when moved."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "rainbowknife"
	force = 15
	throwforce = 15
	damtype = BRUTE

/obj/item/kitchen/knife/rainbowknife/afterattack(atom/target, mob/user, proximity)
	if(proximity && istype(target, /mob/living))
		damtype = pick(BRUTE, BURN, TOX, OXY, CLONE)
	switch(damtype)
		if(BRUTE)
			hitsound = 'sound/weapons/bladeslice.ogg'
			attack_verb = list("slashed","sliced","cut")
		if(BURN)
			hitsound = 'sound/weapons/sear.ogg'
			attack_verb = list("burned","singed","heated")
		if(TOX)
			hitsound = 'sound/weapons/pierce.ogg'
			attack_verb = list("poisoned","dosed","toxified")
		if(OXY)
			hitsound = 'sound/effects/space_wind.ogg'
			attack_verb = list("suffocated","winded","vacuumed")
		if(CLONE)
			hitsound = 'sound/items/geiger/ext1.ogg'
			attack_verb = list("irradiated","mutated","maligned")
	return ..()

/obj/item/twohanded/required/adamantineshield
	name = "adamantine shield"
	desc = "A gigantic shield made of solid adamantium."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "adamshield"
	item_state = "adamshield"
	w_class = WEIGHT_CLASS_HUGE
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 70)
	slot_flags = ITEM_SLOT_BACK
	block_chance = 75
	throw_range = 1 //How far do you think you're gonna throw a solid crystalline shield...?
	throw_speed = 2
	force = 15 //Heavy, but hard to wield.
	attack_verb = list("bashed","pounded","slammed")
	item_flags = SLOWS_WHILE_IN_HAND


/obj/effect/proc_holder/spell/targeted/shapeshift/slimeform
	name = "Slime Transformation"
	desc = "Transform from a human to a slime, or back again!"
	action_icon_state = "transformslime"
	cooldown_min = 0
	charge_max = 0
	invocation_type = "none"
	shapeshift_type = /mob/living/simple_animal/slime/transformedslime
	convert_damage = TRUE
	convert_damage_type = CLONE
	var/remove_on_restore = FALSE

/obj/effect/proc_holder/spell/targeted/shapeshift/slimeform/Restore(mob/living/M)
	if(remove_on_restore)
		if(M.mind)
			M.mind.RemoveSpell(src)
	..()

/mob/living/simple_animal/slime/transformedslime

/mob/living/simple_animal/slime/transformedslime/Reproduce() //Just in case.
	to_chat(src, "<span class='warning'>I can't reproduce...</span>")
	return

////////////////////////
////	CHARGED		////
////////////////////////

/obj/item/slimepotion/slime_reviver
	name = "slime revival potion"
	desc = "Infused with plasma and compressed gel, this brings dead slimes back to life."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potsilver"

/obj/item/slimepotion/slime_reviver/attack(mob/living/simple_animal/slime/M, mob/user)
	if(!isslime(M))
		to_chat(user, "<span class='warning'>The potion only works on slimes!</span>")
		return ..()
	if(M.stat != DEAD)
		to_chat(user, "<span class='warning'>The slime is still alive!</span>")
		return
	if(M.maxHealth <= 0)
		to_chat(user, "<span class='warning'>The slime is too unstable to return!</span>")
	M.revive(full_heal = 1)
	M.stat = CONSCIOUS
	M.visible_message("<span class='notice'>[M] is filled with renewed vigor and blinks awake!</span>")
	M.maxHealth -= 10 //Revival isn't healthy.
	M.health -= 10
	M.regenerate_icons()
	qdel(src)

/obj/item/slimepotion/slime/chargedstabilizer
	name = "slime omnistabilizer"
	desc = "An extremely potent chemical mix that will stop a slime from mutating completely."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potcyan"

/obj/item/slimepotion/slime/chargedstabilizer/attack(mob/living/simple_animal/slime/M, mob/user)
	if(!isslime(M))
		to_chat(user, "<span class='warning'>The stabilizer only works on slimes!</span>")
		return ..()
	if(M.stat)
		to_chat(user, "<span class='warning'>The slime is dead!</span>")
		return
	if(M.mutation_chance == 0)
		to_chat(user, "<span class='warning'>The slime already has no chance of mutating!</span>")
		return

	to_chat(user, "<span class='notice'>You feed the slime the omnistabilizer. It will not mutate this cycle!</span>")
	M.mutation_chance = 0
	qdel(src)

/obj/item/stock_parts/cell/high/slime/hypercharged
	name = "hypercharged slime core"
	desc = "A charged yellow slime extract, infused with even more plasma. It almost hurts to touch."
	rating = 7 //Roughly 1.5 times the original.
	maxcharge = 20000 //2 times the normal one.
	chargerate = 2250 //1.5 times the normal rate.

/obj/item/slimepotion/spaceproof
	name = "slime pressurization potion"
	desc = "A potent chemical sealant that will render any article of clothing airtight. Has two uses."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potblue"
	var/uses = 2

/obj/item/slimepotion/spaceproof/afterattack(obj/item/clothing/C, mob/user, proximity)
	..()
	if(!uses)
		qdel(src)
		return
	if(!proximity)
		return
	if(!istype(C))
		to_chat(user, "<span class='warning'>The potion can only be used on clothing!</span>")
		return
	if(C.min_cold_protection_temperature == SPACE_SUIT_MIN_TEMP_PROTECT && C.clothing_flags & STOPSPRESSUREDAMAGE)
		to_chat(user, "<span class='warning'>The [C] is already pressure-resistant!</span>")
		return ..()
	to_chat(user, "<span class='notice'>You slather the blue gunk over the [C], making it airtight.</span>")
	C.name = "pressure-resistant [C.name]"
	C.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	C.add_atom_colour("#000080", FIXED_COLOUR_PRIORITY)
	C.min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	C.cold_protection = C.body_parts_covered
	C.clothing_flags |= STOPSPRESSUREDAMAGE
	uses--
	if(!uses)
		qdel(src)

/obj/item/slimepotion/enhancer/max
	name = "extract maximizer"
	desc = "An extremely potent chemical mix that will maximize a slime extract's uses."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potpurple"

/obj/item/slimepotion/lavaproof
	name = "slime lavaproofing potion"
	desc = "A strange, reddish goo said to repel lava as if it were water, without reducing flammability. Has two uses."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potred"
	var/uses = 2

/obj/item/slimepotion/lavaproof/afterattack(obj/item/C, mob/user, proximity)
	..()
	if(!uses)
		qdel(src)
		return ..()
	if(!proximity)
		return ..()
	if(!istype(C))
		to_chat(user, "<span class='warning'>You can't coat this with lavaproofing fluid!</span>")
		return ..()
	to_chat(user, "<span class='notice'>You slather the red gunk over the [C], making it lavaproof.</span>")
	C.name = "lavaproof [C.name]"
	C.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	C.add_atom_colour("#800000", FIXED_COLOUR_PRIORITY)
	C.resistance_flags |= LAVA_PROOF
	if (istype(C, /obj/item/clothing))
		var/obj/item/clothing/CL = C
		CL.clothing_flags |= LAVAPROTECT
	uses--
	if(!uses)
		qdel(src)

/obj/item/slimepotion/lovepotion
	name = "love potion"
	desc = "A pink chemical mix thought to inspire feelings of love."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potpink"

/obj/item/slimepotion/lovepotion/attack(mob/living/M, mob/user)
	if(!isliving(M) || M.stat == DEAD)
		to_chat(user, "<span class='warning'>The love potion only works on living things, sicko!</span>")
		return ..()
	if(user == M)
		to_chat(user, "<span class='warning'>You can't drink the love potion. What are you, a narcissist?</span>")
		return ..()
	if(M.has_status_effect(STATUS_EFFECT_INLOVE))
		to_chat(user, "<span class='warning'>[M] is already lovestruck!</span>")
		return ..()

	M.visible_message("<span class='danger'>[user] starts to feed [M] a love potion!</span>",
		"<span class='userdanger'>[user] starts to feed you a love potion!</span>")

	if(!do_after(user, 50, target = M))
		return
	to_chat(user, "<span class='notice'>You feed [M] the love potion!</span>")
	to_chat(M, "<span class='notice'>You develop feelings for [user], and anyone [user.p_they()] like.</span>")
	if(M.mind)
		M.mind.store_memory("You are in love with [user].")
	M.faction |= "[REF(user)]"
	M.apply_status_effect(STATUS_EFFECT_INLOVE, user)
	qdel(src)

/obj/item/slimepotion/peacepotion
	name = "pacification potion"
	desc = "A light pink solution of chemicals, smelling like liquid peace. And mercury salts."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potlightpink"

/obj/item/slimepotion/peacepotion/attack(mob/living/M, mob/user)
	if(!isliving(M) || M.stat == DEAD)
		to_chat(user, "<span class='warning'>The pacification potion only works on the living.</span>")
		return ..()
	if(M != user)
		M.visible_message("<span class='danger'>[user] starts to feed [M] a pacification potion!</span>",
			"<span class='userdanger'>[user] starts to feed you a love potion!</span>")
	else
		M.visible_message("<span class='danger'>[user] starts to drink the pacification potion!</span>",
			"<span class='danger'>You start to drink the pacification potion!</span>")

	if(!do_after(user, 100, target = M))
		return
	if(M != user)
		to_chat(user, "<span class='notice'>You feed [M] the pacification potion!</span>")
	else
		to_chat(user, "<span class='warning'>You drink the pacification potion!</span>")
	if(isanimal(M))
		M.add_trait(TRAIT_PACIFISM, MAGIC_TRAIT)
	else if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.gain_trauma(/datum/brain_trauma/severe/pacifism, TRAUMA_RESILIENCE_SURGERY)
	qdel(src)

////////////////////////
////	CHILLING	////
////////////////////////

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
	if(slot == SLOT_WEAR_MASK)
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
	. = ..()
	playsound(src, 'sound/magic/ethereal_exit.ogg', 50, 1)

/obj/structure/ice_stasis/Destroy()
	for(var/atom/movable/M in contents)
		M.forceMove(loc)
	playsound(src, 'sound/effects/glassbr3.ogg', 50, 1)
	return ..()

/obj/item/clothing/glasses/prism_glasses
	name = "prism glasses"
	desc = "The lenses seem to glow slightly, and reflect light into dazzling colors."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "prismglasses"
	var/colour = "#FFFFFF"
	actions_types = list(/datum/action/item_action/change_prism_colour, /datum/action/item_action/place_light_prism)

/obj/item/clothing/glasses/prism_glasses/item_action_slot_check(slot)
	if(slot == SLOT_GLASSES)
		return TRUE

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
	item_flags = ABSTRACT | NODROP | DROPDEL
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
	if(slot == SLOT_HEAD)
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
	obj_flags = IMMUTABLE_SLOW
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

/obj/item/clothing/suit/armor/heavy/adamantine/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()
