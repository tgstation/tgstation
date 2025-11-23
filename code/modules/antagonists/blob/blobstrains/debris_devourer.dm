#define DEBRIS_DENSITY (length(overmind.blob_core.contents) / (length(overmind.blobs_legit) * 0.25)) // items per blob
#define SPORE_TRASH_COUNT 3
#define FREE_MINION_DEBRIS_CHANCE 80

// Accumulates junk liberally
/datum/blobstrain/debris_devourer
	name = "Debris Devourer"
	description = "will launch accumulated debris into targets. Does very low brute damage without debris-launching."
	analyzerdescdamage = "Does very low brute damage and may grab onto melee weapons."
	analyzerdesceffect = "Devours loose items left on the station, and releases them when attacking or attacked."
	color = "#8B1000"
	complementary_color = "#00558B"
	blobbernaut_message = "blasts"
	message = "The blob blasts you"

/datum/blobstrain/debris_devourer/attack_living(mob/living/L, list/nearby_blobs)
	send_message(L)
	for (var/obj/structure/blob/blob in nearby_blobs)
		debris_attack(L, blob)

/datum/blobstrain/debris_devourer/on_sporedeath(mob/living/spore, death_cloud_size)
	var/list/trash_source = overmind ? overmind.blob_core.contents : spore.contents

	var/trashsplosion_count = overmind ? SPORE_TRASH_COUNT : spore.contents.len

	for(var/i in 1 to trashsplosion_count)
		var/obj/item/trash_shrapnel = pick(trash_source)
		if (trash_shrapnel && !QDELETED(trash_shrapnel))
			trash_shrapnel.forceMove(get_turf(spore))
			trash_shrapnel.throw_at(get_edge_target_turf(spore,pick(GLOB.alldirs)), 6, 5, spore, TRUE, FALSE, null, 3)
	playsound(spore, 'sound/effects/pop_expl.ogg', vol = 100, vary = TRUE)

/datum/blobstrain/debris_devourer/expand_reaction(obj/structure/blob/B, obj/structure/blob/newB, turf/T, mob/eye/blob/O, coefficient = 1) //when the blob expands, do this
	for (var/obj/item/I in T)
		I.forceMove(overmind.blob_core)

/datum/blobstrain/debris_devourer/proc/debris_attack(atom/attacking, atom/source)
	if (!prob(overmind ? 40 * DEBRIS_DENSITY : FREE_MINION_DEBRIS_CHANCE)) // Pretend the items are spread through the blob and its mobs and not in the core.
		return

	var/list/trash_collection = overmind ? overmind.blob_core.contents : source.contents

	if(!length(trash_collection))
		return

	var/obj/item/trash_weapon = pick(trash_collection)

	if (QDELETED(trash_weapon))
		return

	trash_weapon.forceMove(get_turf(source))
	trash_weapon.throw_at(attacking, 6, 5, overmind ? overmind : source, TRUE, FALSE, null, 3)

/datum/blobstrain/debris_devourer/blobbernaut_attack(mob/living/blobbernaut, atom/victim)
	..()
	debris_attack(victim, blobbernaut)

/datum/blobstrain/debris_devourer/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag, coefficient = 1) //when the blob takes damage, do this
	return round(max((coefficient*damage)-min(coefficient*DEBRIS_DENSITY, 10), 0)) // reduce damage taken by items per blob, up to 10

/datum/blobstrain/debris_devourer/examine(mob/user)
	. = ..()
	if (isobserver(user))
		. += span_notice("Absorbed debris is currently reducing incoming damage by [round(max(min(DEBRIS_DENSITY, 10),0))]")
	else
		switch (round(max(min(DEBRIS_DENSITY, 10),0)))
			if (0)
				. += span_notice("There is not currently enough absorbed debris to reduce damage.")
			if (1 to 3)
				. += span_notice("Absorbed debris is currently reducing incoming damage by a very low amount.") // these roughly correspond with force description strings
			if (4 to 7)
				. += span_notice("Absorbed debris is currently reducing incoming damage by a low amount.")
			if (8 to 10)
				. += span_notice("Absorbed debris is currently reducing incoming damage by a medium amount.")

/datum/blobstrain/debris_devourer/on_blobmob_atom_interacted(mob/living/minion, atom/interacted_atom, adjacent, modifiers)
	. = ..()
	if(!isitem(interacted_atom) || !adjacent)
		return

	if(minion.contents.len >= minion.mob_size * 5)
		to_chat(minion, span_warning("You feel too full to eat more trash."))
		return

	playsound(minion, 'sound/items/eatfood.ogg', 60, TRUE)
	var/obj/item/tasty_trash = interacted_atom
	minion.do_attack_animation(tasty_trash)
	tasty_trash.forceMove(overmind ? overmind.blob_core : minion)
	return COMPONENT_HOSTILE_NO_ATTACK

#undef DEBRIS_DENSITY
#undef SPORE_TRASH_COUNT
#undef FREE_MINION_DEBRIS_CHANCE
