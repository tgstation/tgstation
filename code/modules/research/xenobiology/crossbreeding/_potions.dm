/*
Slimecrossing Potions
	Potions added by the slimecrossing system.
	Collected here for clarity.
*/

//Extract cloner - Charged Grey
/obj/item/slimepotion/extract_cloner
	name = "extract cloning potion"
	desc = "A more powerful version of the extract enhancer potion, capable of cloning regular slime extracts."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "potpurple"

/obj/item/slimepotion/extract_cloner/afterattack(obj/item/target, mob/user , proximity)
	if(!proximity)
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	if(is_reagent_container(target))
		return ..(target, user, proximity)
	if(istype(target, /obj/item/slimecross))
		to_chat(user, span_warning("[target] is too complex for the potion to clone!"))
		return
	if(!istype(target, /obj/item/slime_extract))
		return
	var/obj/item/slime_extract/S = target
	if(S.recurring)
		to_chat(user, span_warning("[target] is too complex for the potion to clone!"))
		return
	var/path = S.type
	var/obj/item/slime_extract/C = new path(get_turf(target))
	C.Uses = S.Uses
	to_chat(user, span_notice("You pour the potion onto [target], and the fluid solidifies into a copy of it!"))
	qdel(src)
	return

//Peace potion - Charged Light Pink
/obj/item/slimepotion/peacepotion
	name = "pacification potion"
	desc = "A light pink solution of chemicals, smelling like liquid peace. And mercury salts."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "potlightpink"

/obj/item/slimepotion/peacepotion/attack(mob/living/peace_target, mob/user)
	if(!isliving(peace_target) || peace_target.stat == DEAD)
		to_chat(user, span_warning("[src] only works on the living."))
		return ..()
	if(ismegafauna(peace_target))
		to_chat(user, span_warning("[src] does not work on beings of pure evil!"))
		return ..()
	if(peace_target != user)
		peace_target.visible_message(span_danger("[user] starts to feed [peace_target] [src]!"),
			span_userdanger("[user] starts to feed you [src]!"))
	else
		peace_target.visible_message(span_danger("[user] starts to drink [src]!"),
			span_danger("You start to drink [src]!"))

	if(!do_after(user, 100, target = peace_target))
		return
	if(peace_target != user)
		to_chat(user, span_notice("You feed [peace_target] [src]!"))
	else
		to_chat(user, span_warning("You drink [src]!"))
	if(isanimal(peace_target))
		ADD_TRAIT(peace_target, TRAIT_PACIFISM, MAGIC_TRAIT)
	else if(iscarbon(peace_target))
		var/mob/living/carbon/peaceful_carbon = peace_target
		peaceful_carbon.gain_trauma(/datum/brain_trauma/severe/pacifism, TRAUMA_RESILIENCE_SURGERY)
	qdel(src)

//Love potion - Charged Pink
/obj/item/slimepotion/lovepotion
	name = "love potion"
	desc = "A pink chemical mix thought to inspire feelings of love."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "potpink"

/obj/item/slimepotion/lovepotion/attack(mob/living/love_target, mob/user)
	if(!isliving(love_target) || love_target.stat == DEAD)
		to_chat(user, span_warning("The love potion only works on living things, sicko!"))
		return ..()
	if(ismegafauna(love_target))
		to_chat(user, span_warning("The love potion does not work on beings of pure evil!"))
		return ..()
	if(user == love_target)
		to_chat(user, span_warning("You can't drink the love potion. What are you, a narcissist?"))
		return ..()
	if(love_target.has_status_effect(/datum/status_effect/in_love))
		to_chat(user, span_warning("[love_target] is already lovestruck!"))
		return ..()

	love_target.visible_message(span_danger("[user] starts to feed [love_target] a love potion!"),
		span_userdanger("[user] starts to feed you a love potion!"))

	if(!do_after(user, 50, target = love_target))
		return
	to_chat(user, span_notice("You feed [love_target] the love potion!"))
	to_chat(love_target, span_notice("You develop feelings for [user], and anyone [user.p_they()] like[user.p_s()]."))
	love_target.faction |= "[REF(user)]"
	love_target.apply_status_effect(/datum/status_effect/in_love, user)
	qdel(src)

//Pressure potion - Charged Dark Blue
/obj/item/slimepotion/spaceproof
	name = "slime pressurization potion"
	desc = "A potent chemical sealant that will render any article of clothing airtight. Has two uses."
	icon = 'icons/obj/medical/chemical.dmi'
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
		to_chat(user, span_warning("The potion can only be used on clothing!"))
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	if(istype(C, /obj/item/clothing/suit/space))
		to_chat(user, span_warning("The [C] is already pressure-resistant!"))
		return . | ..()
	if(C.min_cold_protection_temperature == SPACE_SUIT_MIN_TEMP_PROTECT && C.clothing_flags & STOPSPRESSUREDAMAGE)
		to_chat(user, span_warning("The [C] is already pressure-resistant!"))
		return . | ..()
	to_chat(user, span_notice("You slather the blue gunk over the [C], making it airtight."))
	C.name = "pressure-resistant [C.name]"
	C.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	C.add_atom_colour("#000080", FIXED_COLOUR_PRIORITY)
	C.min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	C.cold_protection = C.body_parts_covered
	C.clothing_flags |= STOPSPRESSUREDAMAGE
	uses--
	if(!uses)
		qdel(src)
	return .

//Enhancer potion - Charged Cerulean
/obj/item/slimepotion/enhancer/max
	name = "extract maximizer"
	desc = "An extremely potent chemical mix that will maximize a slime extract's uses."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "potpurple"

//Lavaproofing potion - Charged Red
/obj/item/slimepotion/lavaproof
	name = "slime lavaproofing potion"
	desc = "A strange, reddish goo said to repel lava as if it were water, without reducing flammability. Has two uses."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "potred"
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	var/uses = 2

/obj/item/slimepotion/lavaproof/afterattack(obj/item/C, mob/user, proximity)
	. = ..()
	if(!uses)
		qdel(src)
		return ..()
	if(!proximity)
		return ..()
	if(!istype(C))
		to_chat(user, span_warning("You can't coat this with lavaproofing fluid!"))
		return ..()
	. |= AFTERATTACK_PROCESSED_ITEM
	to_chat(user, span_notice("You slather the red gunk over the [C], making it lavaproof."))
	C.name = "lavaproof [C.name]"
	C.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	C.add_atom_colour("#800000", FIXED_COLOUR_PRIORITY)
	C.resistance_flags |= LAVA_PROOF
	if (isclothing(C))
		var/obj/item/clothing/CL = C
		CL.clothing_flags |= LAVAPROTECT
	uses--
	if(!uses)
		qdel(src)
	return .

//Revival potion - Charged Grey
/obj/item/slimepotion/slime_reviver
	name = "slime revival potion"
	desc = "Infused with plasma and compressed gel, this brings dead slimes back to life."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "potsilver"

/obj/item/slimepotion/slime_reviver/attack(mob/living/simple_animal/slime/revive_target, mob/user)
	if(!isslime(revive_target))
		to_chat(user, span_warning("The potion only works on slimes!"))
		return ..()
	if(revive_target.stat != DEAD)
		to_chat(user, span_warning("The slime is still alive!"))
		return
	if(revive_target.maxHealth <= 0)
		to_chat(user, span_warning("The slime is too unstable to return!"))
	revive_target.revive(HEAL_ALL)
	revive_target.set_stat(CONSCIOUS)
	revive_target.visible_message(span_notice("[revive_target] is filled with renewed vigor and blinks awake!"))
	revive_target.maxHealth -= 10 //Revival isn't healthy.
	revive_target.health -= 10
	revive_target.regenerate_icons()
	qdel(src)

//Stabilizer potion - Charged Blue
/obj/item/slimepotion/slime/chargedstabilizer
	name = "slime omnistabilizer"
	desc = "An extremely potent chemical mix that will stop a slime from mutating completely."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "potcyan"

/obj/item/slimepotion/slime/chargedstabilizer/attack(mob/living/simple_animal/slime/stabilize_target, mob/user)
	if(!isslime(stabilize_target))
		to_chat(user, span_warning("The stabilizer only works on slimes!"))
		return ..()
	if(stabilize_target.stat)
		to_chat(user, span_warning("The slime is dead!"))
		return
	if(stabilize_target.mutation_chance == 0)
		to_chat(user, span_warning("The slime already has no chance of mutating!"))
		return

	to_chat(user, span_notice("You feed the slime the omnistabilizer. It will not mutate this cycle!"))
	stabilize_target.mutation_chance = 0
	qdel(src)
