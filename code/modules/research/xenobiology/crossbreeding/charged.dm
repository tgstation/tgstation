/*
Charged extracts:
	Have a unique, effect when filled with
	10u plasma and activated in-hand, related to their
	normal extract effect.
*/
/obj/item/slimecross/charged
	name = "charged extract"
	desc = "It sparks with electric power."
	effect = "charged"
	container_type = INJECTABLE | DRAWABLE
	icon_state = "charged"

/obj/item/slimecross/charged/Initialize()
	..()
	create_reagents(10)

/obj/item/slimecross/charged/attack_self(mob/user)
	if(!reagents.has_reagent("plasma",10))
		to_chat(user, "<span class='warning'>This extract needs to be full of plasma to activate!</span>")
		return
	reagents.remove_reagent("plasma",10)
	to_chat(user, "<span class='notice'>You squeeze the extract, and it absorbs the plasma!</span>")
	playsound(src, 'sound/effects/bubbles.ogg', 50, 1)
	playsound(src, 'sound/effects/light_flicker.ogg', 50, 1)
	do_effect(user)

/obj/item/slimecross/charged/proc/do_effect(mob/user) //If, for whatever reason, you don't want to delete the extract, don't do ..()
	qdel(src)
	return

/obj/item/slimecross/charged/grey
	colour = "grey"

/obj/item/slimecross/charged/grey/do_effect(mob/user)
	new /obj/item/slimepotion/slime_reviver(get_turf(user))
	user.visible_message("<span class='notice'>[src] distills into a potion!</span>")
	..()

/obj/item/slimecross/charged/orange
	colour = "orange"

/obj/item/slimecross/charged/orange/do_effect(mob/user)
	for(var/turf/turf in range(5,get_turf(user)))
		if(!locate(/obj/effect/hotspot) in turf)
			new /obj/effect/hotspot(turf)
	..()

/obj/item/slimecross/charged/purple
	colour = "purple"

/obj/item/slimecross/charged/purple/do_effect(mob/user)
	new /obj/item/slimecrossbeaker/omnizine(get_turf(user))
	user.visible_message("<span class='notice'>[src] sparks, and floods with a regenerative solution!</span>")
	..()

/obj/item/slimecross/charged/blue
	colour = "blue"

/obj/item/slimecross/charged/blue/do_effect(mob/user)
	new /obj/item/slimepotion/slime/chargedstabilizer(get_turf(user))
	user.visible_message("<span class='notice'>[src] distills into a potion!</span>")
	..()

/obj/item/slimecross/charged/metal
	colour = "metal"

/obj/item/slimecross/charged/metal/do_effect(mob/user)
	new /obj/item/stack/sheet/metal(get_turf(user), 25)
	new /obj/item/stack/sheet/plasteel(get_turf(user), 10)
	user.visible_message("<span class='notice'>[src] grows into a plethora of metals!</span>")
	..()

/obj/item/slimecross/charged/yellow
	colour = "yellow"

/obj/item/slimecross/charged/yellow/do_effect(mob/user)
	new /obj/item/stock_parts/cell/high/slime/hypercharged(get_turf(user))
	user.visible_message("<span class='notice'>[src] sparks violently, and swells with electric power!</span>")
	..()

/obj/item/slimecross/charged/darkpurple
	colour = "dark purple"

/obj/item/slimecross/charged/darkpurple/do_effect(mob/user)
	new /obj/item/stack/sheet/mineral/plasma(get_turf(user), 10)
	user.visible_message("<span class='notice'>[src] produces a large amount of plasma!</span>")
	..()

/obj/item/slimecross/charged/darkblue
	colour = "dark blue"

/obj/item/slimecross/charged/darkblue/do_effect(mob/user)
	new /obj/item/slimepotion/spaceproof(get_turf(user))
	user.visible_message("<span class='notice'>[src] distills into a potion!</span>")
	..()

/obj/item/slimecross/charged/silver
	colour = "silver"

/obj/item/slimecross/charged/silver/do_effect(mob/user)
	new /obj/item/reagent_containers/food/snacks/store/cake/slimecake(get_turf(user))
	for(var/i in 1 to 10)
		var/drink_type = get_random_drink()
		new drink_type(get_turf(user))
	user.visible_message("<span class='notice'>[src] produces a party's worth of cake and drinks!</span>")
	..()

/obj/item/slimecross/charged/bluespace
	colour = "bluespace"

/obj/item/slimecross/charged/bluespace/do_effect(mob/user)
	new /obj/item/stack/sheet/bluespace_crystal(get_turf(user), 10)
	user.visible_message("<span class='notice'>[src] produces several sheets of polycrystal!</span>")
	..()

/obj/item/slimecross/charged/sepia
	colour = "sepia"

/obj/item/slimecross/charged/sepia/do_effect(mob/user)
	new /obj/item/camera/spooky(get_turf(user))
	user.visible_message("<span class='notice'>[src] flickers in a strange, ethereal manner, and produces a camera!</span>")
	..()

/obj/item/slimecross/charged/cerulean
	colour = "cerulean"

/obj/item/slimecross/charged/cerulean/do_effect(mob/user)
	new /obj/item/slimepotion/enhancer/max(get_turf(user))
	user.visible_message("<span class='notice'>[src] distills into a potion!</span>")
	..()

/obj/item/slimecross/charged/pyrite
	colour = "pyrite"

/obj/item/slimecross/charged/pyrite/do_effect(mob/user)
	new /obj/item/stack/sheet/mineral/bananium(get_turf(user), 10)
	user.visible_message("<span class='warning'>[src] solidifies with a horrifying banana stench!</span>")
	..()

/obj/item/slimecross/charged/red
	colour = "red"

/obj/item/slimecross/charged/red/do_effect(mob/user)
	new /obj/item/slimepotion/lavaproof(get_turf(user))
	user.visible_message("<span class='notice'>[src] distills into a potion!</span>")
	..()

/obj/item/slimecross/charged/green
	colour = "green"

/obj/item/slimecross/charged/green/do_effect(mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		to_chat(user, "<span class='warning'>You must be a humanoid to use this!</span>")
		return
	var/racechoice = input(H, "Choose your slime subspecies.", "Slime Selection") as null|anything in subtypesof(/datum/species/jelly)
	if(!racechoice)
		to_chat(user, "<span class='notice'>You decide not to become a slime for now.</span>")
		return
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	H.set_species(racechoice, icon_update=1)
	H.visible_message("<span class='warning'>[H] suddenly shifts form as [src] dissolves into [H.p_their()] skin!</span>")
	..()

/obj/item/slimecross/charged/pink
	colour = "pink"

/obj/item/slimecross/charged/pink/do_effect(mob/user)
	new /obj/item/slimepotion/lovepotion(get_turf(user))
	user.visible_message("<span class='notice'>[src] distills into a potion!</span>")
	..()

/obj/item/slimecross/charged/gold
	colour = "gold"
	var/max_spawn = 10
	var/spawned = 0

/obj/item/slimecross/charged/gold/do_effect(mob/user)
	user.visible_message("<span class='warning'>[src] starts shuddering violently!</span>")
	addtimer(CALLBACK(src, .proc/startTimer), 50)

/obj/item/slimecross/charged/gold/proc/startTimer()
	START_PROCESSING(SSobj, src)

/obj/item/slimecross/charged/gold/process()
	visible_message("<span class='warning'>[src] lets off a spark, and produces a living creature!</span>")
	new /obj/effect/particle_effect/sparks(get_turf(src))
	playsound(get_turf(src), "sparks", 50, 1)
	create_random_mob(get_turf(src), HOSTILE_SPAWN)
	spawned++
	if(spawned >= max_spawn)
		visible_message("<span class='warning'>[src] collapses into a puddle of goo.</span>")
		qdel(src)

/obj/item/slimecross/charged/gold/Destroy()
	STOP_PROCESSING(SSobj, src)
	..()

/obj/item/slimecross/charged/oil
	colour = "oil"

/obj/item/slimecross/charged/oil/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] begins to shake with rapidly increasing force!</span>")
	addtimer(CALLBACK(src, .proc/boom), 50)

/obj/item/slimecross/charged/oil/proc/boom()
	explosion(get_turf(src), 3, 2, 1) //Much smaller effect than normal oils, but devastatingly strong where it does hit.
	qdel(src)

/obj/item/slimecross/charged/black
	colour = "black"

/obj/item/slimecross/charged/black/do_effect(mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		to_chat(user, "<span class='warning'>You have to be able to have a species to get your species changed.</span>")
		return
	var/list/allowed_species = list()
	for(var/X in subtypesof(/datum/species))
		var/datum/species/temp = X
		if(!initial(temp.blacklisted))
			allowed_species += X
	var/datum/species/changed = pick(allowed_species)
	if(changed)
		H.set_species(changed, icon_update = 1)
		to_chat(H, "<span class='danger'>You feel very different!</span>")
	..()

/obj/item/slimecross/charged/lightpink
	colour = "light pink"

/obj/item/slimecross/charged/lightpink/do_effect(mob/user)
	new /obj/item/slimepotion/peacepotion(get_turf(user))
	user.visible_message("<span class='notice'>[src] distills into a potion!</span>")
	..()

/obj/item/slimecross/charged/adamantine
	colour = "adamantine"

/obj/item/slimecross/charged/adamantine/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] produces a fully formed golem shell!</span>")
	new /obj/effect/mob_spawn/human/golem/servant(get_turf(src), /datum/species/golem/adamantine, user)
	..()

/obj/item/slimecross/charged/rainbow
	colour = "rainbow"

/obj/item/slimecross/charged/rainbow/do_effect(mob/user)
	user.visible_message("<span class='warning'>[src] swells and splits into three new slimes!</span>")
	for(var/i in 1 to 3)
		var/mob/living/simple_animal/slime/S = new(get_turf(user))
		S.random_colour()
	..()

////////////Unique things.

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
	. = ..()
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
	. = ..()
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
