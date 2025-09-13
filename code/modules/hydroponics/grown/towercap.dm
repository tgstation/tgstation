/obj/item/seeds/tower
	name = "tower-cap mycelium pack"
	desc = "This mycelium grows into tower-cap mushrooms."
	icon_state = "mycelium-tower"
	species = "towercap"
	plantname = "Tower Caps"
	product = /obj/item/grown/log
	lifespan = 80
	endurance = 50
	maturation = 15
	production = 1
	yield = 5
	potency = 50
	growthstages = 3
	growing_icon = 'icons/obj/service/hydroponics/growing_mushrooms.dmi'
	icon_dead = "towercap-dead"
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism)
	mutatelist = list(/obj/item/seeds/tower/steel)
	reagents_add = list(/datum/reagent/cellulose = 0.05)
	graft_gene = /datum/plant_gene/trait/plant_type/fungal_metabolism

/obj/item/seeds/tower/steel
	name = "steel-cap mycelium pack"
	desc = "This mycelium grows into steel logs."
	icon_state = "mycelium-steelcap"
	species = "steelcap"
	plantname = "Steel Caps"
	product = /obj/item/grown/log/steel
	mutatelist = null
	reagents_add = list(/datum/reagent/cellulose = 0.05, /datum/reagent/iron = 0.05)
	rarity = PLANT_MODERATELY_RARE

/obj/item/grown/log
	seed = /obj/item/seeds/tower
	name = "tower-cap log"
	desc = "It's better than bad, it's good!"
	icon_state = "logs"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 2
	throw_range = 3
	attack_verb_continuous = list("bashes", "batters", "bludgeons", "whacks")
	attack_verb_simple = list("bash", "batter", "bludgeon", "whack")
	/// Type of plank you can get from this type of log
	var/plank_type = /obj/item/stack/sheet/mineral/wood
	/// How many planks you can get from this type of log, without counting seed potency
	var/plank_count = 1
	/// Name of plank, shown in context tips and balloon alerts when cutting the log
	var/plank_name = "wooden planks"
	var/static/list/accepted = typecacheof(list(
		/obj/item/food/grown/tobacco,
		/obj/item/food/grown/tea,
		/obj/item/food/grown/ash_flora/mushroom_leaf,
		/obj/item/food/grown/ambrosia/vulgaris,
		/obj/item/food/grown/ambrosia/deus,
		/obj/item/food/grown/wheat,
	))

/obj/item/grown/log/Initialize(mapload, obj/item/seeds/new_seed)
	. = ..()
	register_context()
	if(seed)
		plank_count += round(seed.potency / 25)

/obj/item/grown/log/add_context(
	atom/source,
	list/context,
	obj/item/held_item,
	mob/living/user,
)

	if(isnull(held_item))
		return NONE

	if(held_item.get_sharpness())
		// May be a little long, but I think "cut into planks" for steel caps may be confusing.
		context[SCREENTIP_CONTEXT_LMB] = "Cut into [plank_name]"
		return CONTEXTUAL_SCREENTIP_SET

	if(CheckAccepted(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Make torch"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/obj/item/grown/log/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(attacking_item.get_sharpness())

		user.balloon_alert(user, "made [plank_count] [plank_name]")
		new plank_type(user.loc, plank_count)
		qdel(src)
		return

	if(CheckAccepted(attacking_item))
		var/obj/item/food/grown/leaf = attacking_item
		if(HAS_TRAIT(leaf, TRAIT_DRIED))
			user.balloon_alert(user, "torch crafted")
			var/obj/item/flashlight/flare/torch/new_torch = new /obj/item/flashlight/flare/torch(user.loc)
			user.dropItemToGround(attacking_item)
			user.put_in_active_hand(new_torch)
			qdel(leaf)
			qdel(src)
			return
		else
			balloon_alert(user, "dry it first!")
	else
		return ..()

/obj/item/grown/log/proc/CheckAccepted(obj/item/I)
	return is_type_in_typecache(I, accepted)

/obj/item/grown/log/tree
	seed = null
	name = "wood log"
	desc = "TIMMMMM-BERRRRRRRRRRR!"
	plank_count = 10

/obj/item/grown/log/steel
	seed = /obj/item/seeds/tower/steel
	name = "steel-cap log"
	desc = "It's made of metal."
	icon_state = "steellogs"
	plank_type = /obj/item/stack/rods
	plank_name = "rods"

/obj/item/grown/log/steel/CheckAccepted(obj/item/I)
	return FALSE

/obj/structure/punji_sticks
	name = "punji sticks"
	desc = "Don't step on this."
	icon = 'icons/obj/service/hydroponics/equipment.dmi'
	icon_state = "punji"
	resistance_flags = FLAMMABLE
	max_integrity = 30
	density = FALSE
	anchored = TRUE
	buckle_lying = 90
	/// Overlay we apply when impaling a mob.
	var/mutable_appearance/stab_overlay

/obj/structure/punji_sticks/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, min_damage = 20, max_damage = 30, flags = CALTROP_BYPASS_SHOES)
	build_stab_overlay()

/obj/structure/punji_sticks/proc/build_stab_overlay()
	stab_overlay = mutable_appearance(icon, "[icon_state]_stab", layer = ABOVE_MOB_LAYER)

/obj/structure/punji_sticks/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	. = ..()
	if(same_z_layer)
		return
	build_stab_overlay()
	update_appearance()

/obj/structure/punji_sticks/post_buckle_mob(mob/living/M)
	update_appearance()
	return ..()

/obj/structure/punji_sticks/post_unbuckle_mob(mob/living/M)
	update_appearance()
	return ..()

/obj/structure/punji_sticks/update_overlays()
	. = ..()
	if(length(buckled_mobs))
		. += stab_overlay

/obj/structure/punji_sticks/intercept_zImpact(list/falling_movables, levels)
	. = ..()
	for(var/mob/living/fallen_mob in falling_movables)
		if(LAZYLEN(buckled_mobs))
			return
		if(buckle_mob(fallen_mob, TRUE))
			to_chat(fallen_mob, span_userdanger("You are impaled by [src]!"))
			fallen_mob.apply_damage(25 * levels, BRUTE, sharpness = SHARP_POINTY)
			if(iscarbon(fallen_mob))
				var/mob/living/carbon/fallen_carbon = fallen_mob
				fallen_carbon.emote("scream")
				fallen_carbon.bleed(30)
	. |= FALL_INTERCEPTED | FALL_NO_MESSAGE

/obj/structure/punji_sticks/unbuckle_mob(mob/living/buckled_mob, force, can_fall)
	if(force)
		return ..()
	to_chat(buckled_mob, span_warning("You begin climbing out of [src]."))
	buckled_mob.apply_damage(5, BRUTE, sharpness = SHARP_POINTY)
	if(!do_after(buckled_mob, 5 SECONDS, target = src))
		to_chat(buckled_mob, span_userdanger("You fail to detach yourself from [src]."))
		return
	return ..()

/obj/structure/punji_sticks/spikes
	name = "wooden spikes"
	icon_state = "woodspike"
