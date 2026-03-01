/// Gives someone the stable voided trauma and then self destructs
/obj/item/clothing/head/helmet/skull/cosmic
	name = "cosmic skull"
	desc = "You can see and feel the surrounding space pulsing through it..."
	icon = 'icons/obj/weapons/voidwalker_items.dmi'
	icon_state = "cosmic_skull_charged"

	light_on = TRUE
	light_color = "#CC00CC"
	light_range = 3
	/// Icon state for when drained
	var/drained_icon_state = "cosmic_skull_drained"
	/// How many uses does it have left?
	var/uses = 1

/obj/item/clothing/head/helmet/skull/cosmic/attack_self(mob/user, modifiers)
	. = ..()

	if(istype(user, /mob/living/basic/voidwalker))
		to_chat(user, span_bolddanger("OH GOD NOO!!!! WHYYYYYYYYY??!!! WHO WOULD DO THIS?!!"))
		return

	if(!uses || !ishuman(user))
		return

	to_chat(user, span_purple("You begin staring into \the [src]..."))

	if(!do_after(user, 10 SECONDS, src))
		return

	uses--
	if(uses <= 0)
		icon_state = drained_icon_state
		light_on = FALSE

	var/mob/living/carbon/human/starer = user

	if(starer.has_trauma_type(/datum/brain_trauma/voided/stable))
		starer.put_in_hands(new /obj/item/void_eater(), TRUE, forced = TRUE)
		playsound(starer, 'sound/effects/blob/blobattack.ogg', 60, TRUE)
	else
		starer.cure_trauma_type(/datum/brain_trauma/voided) //this wouldn't make much sense to have anymore
		starer.gain_trauma(/datum/brain_trauma/voided/stable)

	to_chat(user, span_purple("And a whole world opens up to you."))
	playsound(get_turf(user), 'sound/effects/curse/curse5.ogg', 60)

/**
 * An armblade that pops windows
 */
/obj/item/void_eater
	name = "void eater" //as opposed to full eater
	desc = "A deformed appendage, capable of shattering any glass and any flesh."
	icon = 'icons/obj/weapons/voidwalker_items.dmi'
	icon_state = "tentacle"
	inhand_icon_state = "tentacle"
	icon_angle = 180
	force = 25
	armour_penetration = 35
	lefthand_file = 'icons/mob/inhands/antag/voidwalker_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/voidwalker_righthand.dmi'
	blocks_emissive = EMISSIVE_BLOCK_NONE
	item_flags = ABSTRACT | DROPDEL
	resistance_flags = INDESTRUCTIBLE | ACID_PROOF | FIRE_PROOF | LAVA_PROOF | UNACIDABLE
	w_class = WEIGHT_CLASS_HUGE
	tool_behaviour = TOOL_MINING
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	wound_bonus = -30
	exposed_wound_bonus = 20

/obj/item/void_eater/Initialize(mapload)
	. = ..()

	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	AddComponent(/datum/component/temporary_glass_shatterer)

/obj/effect/spawner/random/glass_shards
	loot = list(/obj/item/shard = 2, /obj/item/shard/plasma = 1, /obj/item/shard/titanium = 1, /obj/item/shard/plastitanium = 1)
	spawn_random_offset = TRUE

	/// Min shards we generate
	var/min_spawn = 4
	/// Max shards we generate
	var/max_spawn = 6

/obj/effect/spawner/random/glass_shards/Initialize(mapload)
	spawn_loot_count = rand(min_spawn, max_spawn)

	return ..()

/obj/effect/spawner/random/glass_shards/mini
	min_spawn = 1
	max_spawn = 2

/obj/effect/spawner/random/glass_debris
	/// Weighted list for the debris we spawn
	loot = list(
		/obj/effect/decal/cleanable/glass = 2,
		/obj/effect/decal/cleanable/glass/plasma = 1,
		/obj/effect/decal/cleanable/glass/titanium = 1,
		/obj/effect/decal/cleanable/glass/plastitanium = 1,
		)
