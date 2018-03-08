/*
Charged extracts:
	Have a unique, effect when filled with
	10u plasma and activated in-hand, related to their
	normal extract effect.
*/
/obj/item/slimecross/charged
	name = "charged extract"
	desc = "It sparks with electric power."
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
	playsound(get_turf(src), 'sound/effects/bubbles.ogg', 50, 1)
	playsound(get_turf(src), 'sound/effects/light_flicker.ogg', 50, 1)
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
	var/obj/item/stack/sheet/metal/M = new(get_turf(user))
	M.amount = 25
	var/obj/item/stack/sheet/plasteel/P = new(get_turf(user))
	P.amount = 10
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
	var/obj/item/stack/sheet/mineral/plasma/M = new(get_turf(user))
	M.amount = 10
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
	var/obj/item/stack/sheet/bluespace_crystal/M = new(get_turf(user))
	M.amount = 10
	user.visible_message("<span class='notice'>[src] produces several sheets of polycrystal!</span>")
	..()

/obj/item/slimecross/charged/sepia
	colour = "sepia"

/obj/item/slimecross/charged/sepia/do_effect(mob/user)
	new /obj/item/device/camera/spooky(get_turf(user))
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

/obj/item/slimecross/charged/red
	colour = "red"

/obj/item/slimecross/charged/green
	colour = "green"

/obj/item/slimecross/charged/pink
	colour = "pink"

/obj/item/slimecross/charged/gold
	colour = "gold"

/obj/item/slimecross/charged/oil
	colour = "oil"

/obj/item/slimecross/charged/black
	colour = "black"

/obj/item/slimecross/charged/lightpink
	colour = "light pink"

/obj/item/slimecross/charged/adamantine
	colour = "adamantine"

/obj/item/slimecross/charged/rainbow
	colour = "rainbow"

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

/obj/item/slimepotion/spaceproof/afterattack(obj/item/clothing/C, mob/user)
	..()
	if(!uses)
		qdel(src)
		return
	if(!istype(C))
		to_chat(user, "<span class='warning'>The potion can only be used on clothing!</span>")
		return
	if(C.min_cold_protection_temperature == SPACE_SUIT_MIN_TEMP_PROTECT && STOPSPRESSUREDMAGE_1 in C.flags_1)
		to_chat(user, "<span class='warning'>The [C] is already pressure-resistant!</span>")
		return ..()
	to_chat(user, "<span class='notice'>You slather the blue gunk over the [C], making it airtight.</span>")
	C.name = "pressure-resistant [C.name]"
	C.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	C.add_atom_colour("#000080", FIXED_COLOUR_PRIORITY)
	C.min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	C.cold_protection = C.body_parts_covered
	C.flags_1 |= STOPSPRESSUREDMAGE_1
	uses --
	if(!uses)
		qdel(src)

/obj/item/slimepotion/enhancer/max
	name = "extract maximizer"
	desc = "An extremely potent chemical mix that will maximize a slime extract's uses."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potpurple"
