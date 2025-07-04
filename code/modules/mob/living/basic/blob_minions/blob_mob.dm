/// Root of shared behaviour for mobs spawned by blobs, is abstract and should not be spawned
/mob/living/basic/blob_minion
	name = "Blob Error"
	desc = "A nonfunctional fungal creature created by bad code or celestial mistake. Point and laugh."
	icon = 'icons/mob/nonhuman-player/blob.dmi'
	icon_state = "blob_head"
	base_icon_state = "blob_head"
	unique_name = TRUE
	status_flags = CANPUSH
	pass_flags = PASSBLOB
	faction = list(ROLE_BLOB)
	combat_mode = TRUE
	bubble_icon = "blob"
	speak_emote = null
	habitable_atmos = null
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	lighting_cutoff_red = 20
	lighting_cutoff_green = 40
	lighting_cutoff_blue = 30
	initial_language_holder = /datum/language_holder/empty
	can_buckle_to = FALSE
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, STAMINA = 0, OXY = 1)
	/// Size of cloud produced from a dying spore
	var/death_cloud_size = BLOBMOB_CLOUD_NONE
	var/list/loot = list(/obj/item/food/spore_sack)

/mob/living/basic/blob_minion/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_BLOB_ALLY, TRAIT_MUTE), INNATE_TRAIT)
	AddComponent(/datum/component/blob_minion, on_strain_changed = CALLBACK(src, PROC_REF(on_strain_updated)), new_death_cloud_size = death_cloud_size)

	if(length(loot))
		loot = string_list(loot)
		AddElement(/datum/element/death_drops, loot)

/// Called when our blob overmind changes their variant, update some of our mob properties
/mob/living/basic/blob_minion/proc/on_strain_updated(mob/eye/blob/overmind, datum/blobstrain/new_strain)
	//revert independent blob mobs to the pale sprite so they can be recoloured
	if(new_strain)
		icon_state = base_icon_state

/// Associates this mob with a specific blob factory node
/mob/living/basic/blob_minion/proc/link_to_factory(obj/structure/blob/special/factory/factory)
	RegisterSignal(factory, COMSIG_QDELETING, PROC_REF(on_factory_destroyed))

/// Called when our factory is destroyed
/mob/living/basic/blob_minion/proc/on_factory_destroyed()
	SIGNAL_HANDLER
	to_chat(src, span_userdanger("Your factory was destroyed! You feel yourself dying!"))
