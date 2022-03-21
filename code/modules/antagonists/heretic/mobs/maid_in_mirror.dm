// A summon which floats around the station incorporeally, and can appear in any mirror
/mob/living/simple_animal/hostile/heretic_summon/maid_in_the_mirror
	name = "Maid in the Mirror"
	real_name = "Maid in the Mirror"
	desc = "An abomination made from several limbs and organs. \
		Every moment you stare at it, it appears to shift and change unnaturally."
	icon_state = "stalker"
	icon_living = "stalker" // MELBERT TODO sprite
	speak_emote = list("whispers")
	movement_type = FLOATING
	status_flags = CANSTUN | CANPUSH
	attack_sound = SFX_SHATTER
	maxHealth = 80
	health = 80
	melee_damage_lower = 12
	melee_damage_upper = 16
	sight = SEE_MOBS | SEE_OBJS | SEE_TURFS
	deathmessage = "shatters and vanishes, releasing a gust of cold air."
	loot = list(/obj/item/shard, /obj/effect/decal/cleanable/ash)
	spells_to_add = list(/obj/effect/proc_holder/spell/targeted/mirror_walk)

/mob/living/simple_animal/hostile/heretic_summon/maid_in_the_mirror/death(gibbed)
	var/turf/death_turf = get_turf(src)
	death_turf.TakeTemperature(-40)
	return ..()
