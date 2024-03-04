/// Bluespace Limons

/datum/xenoflora_plant/bluespace_limon
	name = "Bluespace Limon Tree"
	desc = "A rare alien tree which is surprisingly similar to lemons and limes in biology, if you ignore it's high bluespace activity."

	icon_state = "bluespace_limon"
	ground_icon_state = "grass"
	seeds_icon_state = "xenoseeds-limon"

	min_safe_temp = T0C
	max_safe_temp = T0C + 40

	required_gases = list(/datum/gas/carbon_dioxide = 0.1)
	produced_gases = list()

	required_chems = list(/datum/reagent/acetone = 0.2, /datum/reagent/oxygen = 0.1)
	produced_chems = list(/datum/reagent/acetone_oxide = 0.1)

	min_produce = 3
	max_produce = 6
	produce_type = /obj/item/food/xenoflora/bluespace_limon

/obj/item/food/xenoflora/bluespace_limon
	name = "bluespace limon"
	desc = "This is what happens when you dip your balls in bluespace powder after having too much lemon-lime."
	icon_state = "bluespace_limon"
	food_reagents = list(/datum/reagent/consumable/limonjuice = 5, /datum/reagent/consumable/nutriment = 2) //No bluespace dust here because we want a custom effect upon being squashed instead of random teleportation
	tastes = list("...lemons? Limes?" = 1, "teleportation" = 1, "lost virginity" = 1) //Reference to one of eigenstasium lines
	juice_results = list(/datum/reagent/bluespace = 2,/datum/reagent/consumable/limonjuice = 5, /datum/reagent/consumable/nutriment = 2)
	foodtypes = FRUIT
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	seed_type = /obj/item/xeno_seeds/bluespace_limon

/obj/item/food/xenoflora/bluespace_limon/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(.)
		return
	squash(hit_atom)

/obj/item/food/xenoflora/bluespace_limon/attack_self(mob/user, modifiers)
	. = ..()
	to_chat(user, span_warning("You squish [src] in your hand!"))
	squash(user)

/obj/item/food/xenoflora/bluespace_limon/proc/squash(atom/main_target)
	var/turf/our_turf = get_turf(main_target)
	var/obj/effect/decal/cleanable/food/plant_smudge/smudge = new(our_turf)
	smudge.name = "[src] smudge"
	smudge.color = "#EBEBEB"
	our_turf.visible_message(span_warning("[src] is squashed."), null, span_hear("You hear a smack."))
	if(!reagents) //Just in case
		qdel(src)
		return

	reagents.expose(main_target, TOUCH)
	for(var/atom/touch_atom in our_turf)
		if(touch_atom == src)
			continue
		reagents.expose(touch_atom, TOUCH)

	if(main_target != our_turf)
		reagents.expose(our_turf, TOUCH)

	qdel(src)

/// Pyrite Peaches

/datum/xenoflora_plant/pyrite_peaches
	name = "Pyrite Peach Tree"
	desc = "An unusual subspecies of peaches that naturally produces Chlorine Trifluoride for self-defence."

	icon_state = "pyrite_peach"
	ground_icon_state = "grass_alien"
	seeds_icon_state = "xenoseeds-peach"

	min_safe_temp = T0C + 70
	max_safe_temp = T0C + 150

	required_gases = list(/datum/gas/oxygen = 0.3) //Just hook it up to distro and a heater or some shit
	produced_gases = list()

	required_chems = list(/datum/reagent/napalm = 0.1)
	produced_chems = list()

	min_produce = 2
	max_produce = 5
	produce_type = /obj/item/food/xenoflora/pyrite_peach

/obj/item/food/xenoflora/pyrite_peach
	name = "pyrite peach"
	desc = "Do not let the damn indians take our peaches how they took our jobs!" //TODO: racist, need to think up something better
	icon_state = "bluespace_limon"
	food_reagents = list(/datum/reagent/consumable/peachjuice = 3, /datum/reagent/consumable/sugar = 2, /datum/reagent/consumable/nutriment = 2, /datum/reagent/clf3 = 5)
	tastes = list("flames" = 1, "peaches" = 1)
	foodtypes = FRUIT
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	seed_type = /obj/item/xeno_seeds/pyrite_peaches

/obj/item/food/xenoflora/pyrite_peach/pickup(mob/living/carbon/user)
	. = ..()
	if(!istype(user) || HAS_TRAIT(user, TRAIT_PLANT_SAFE) || !reagents)
		return

	for(var/obj/item/clothing/worn_item in user.get_equipped_items())
		if((worn_item.body_parts_covered & HANDS) && (worn_item.clothing_flags & THICKMATERIAL))
			return

	reagents.expose(user, TOUCH, 0.2)
