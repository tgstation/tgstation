/// A shambling mob made out of a crew member
/mob/living/basic/blob_minion/zombie
	name = "blob zombie"
	desc = "A shambling corpse animated by the blob."
	icon_state = "zombie"
	icon_living = "zombie"
	health_doll_icon = "blobpod"
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	health = 70
	maxHealth = 70
	verb_say = "gurgles"
	verb_ask = "demands"
	verb_exclaim = "roars"
	verb_yell = "bellows"
	melee_damage_lower = 10
	melee_damage_upper = 15
	melee_attack_cooldown = CLICK_CD_MELEE
	obj_damage = 20
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/items/weapons/genhit1.ogg'
	death_message = "collapses to the ground!"
	gold_core_spawnable = NO_SPAWN
	basic_mob_flags = DEL_ON_DEATH
	ai_controller = /datum/ai_controller/basic_controller/blob_zombie
	death_cloud_size = BLOBMOB_CLOUD_NORMAL
	/// The dead body we have inside
	var/mob/living/carbon/human/corpse
	///Our head overlay
	var/mutable_appearance/blob_head_overlay

/mob/living/basic/blob_minion/zombie/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_PERMANENTLY_MORTAL, INNATE_TRAIT) // This mob doesn't function visually without a corpse and wouldn't respawn with one
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_BLOBSPORE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/basic/blob_minion/zombie/death(gibbed)
	corpse?.forceMove(loc)
	return ..()

/mob/living/basic/blob_minion/zombie/Exited(atom/movable/gone, direction)
	. = ..()
	if (gone != corpse)
		return
	corpse = null
	death()

/mob/living/basic/blob_minion/zombie/Destroy()
	QDEL_NULL(corpse)
	return ..()

/mob/living/basic/blob_minion/zombie/on_factory_destroyed()
	. = ..()
	death()

/mob/living/basic/blob_minion/zombie/on_strain_updated(mob/eye/blob/overmind, datum/blobstrain/new_strain)
	. = ..()
	update_appearance()
	color = initial(color)
	blob_head_overlay?.icon_state = "blob_head"
	blob_head_overlay?.color = new_strain ? new_strain.color : COLOR_WHITE

/mob/living/basic/blob_minion/zombie/update_overlays()
	. = ..()
	if(!blob_head_overlay)
		blob_head_overlay = mutable_appearance('icons/mob/nonhuman-player/blob.dmi', "blob_head_independent")
	. += blob_head_overlay

/// Store a body so that we can drop it on death
/mob/living/basic/blob_minion/zombie/proc/consume_corpse(mob/living/carbon/human/new_corpse)
	if(new_corpse.wear_suit)
		maxHealth += new_corpse.get_armor_rating(MELEE)
		health = maxHealth
	new_corpse.set_facial_hairstyle("Shaved", update = FALSE)
	new_corpse.set_hairstyle("Bald", update = TRUE)
	new_corpse.forceMove(src)
	corpse = new_corpse
	copy_overlays(corpse, TRUE)
	update_appearance(UPDATE_ICON)
	RegisterSignal(corpse, COMSIG_LIVING_REVIVE, PROC_REF(on_corpse_revived))

/// Dynamic changeling reentry
/mob/living/basic/blob_minion/zombie/proc/on_corpse_revived()
	SIGNAL_HANDLER
	visible_message(span_boldwarning("[src] bursts from the inside!"))
	death()

/// Blob-created zombies will ping for player control when they make a zombie
/mob/living/basic/blob_minion/zombie/controlled

/mob/living/basic/blob_minion/zombie/controlled/consume_corpse(mob/living/carbon/human/new_corpse)
	. = ..()
	if (!isnull(client) || SSticker.current_state == GAME_STATE_FINISHED)
		return
	AddComponent(\
		/datum/component/ghost_direct_control,\
		ban_type = ROLE_BLOB_INFECTION,\
		poll_candidates = TRUE,\
		poll_ignore_key = POLL_IGNORE_BLOB,\
	)
