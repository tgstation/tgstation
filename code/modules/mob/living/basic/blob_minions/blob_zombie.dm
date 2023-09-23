/// A shambling mob made out of a crew member
/mob/living/basic/blob_zombie
	name = "blob zombie"
	desc = "A shambling corpse animated by the blob."
	icon = 'icons/mob/human/human.dmi'
	icon_state = "zombie"
	icon_living = "zombie"
	health_doll_icon = "blobpod"
	unique_name = TRUE
	pass_flags = PASSBLOB
	faction = list(ROLE_BLOB)
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	combat_mode = TRUE
	health = 70
	maxHealth = 70
	bubble_icon = "blob"
	speak_emote = null
	verb_say = "psychically pulses"
	verb_ask = "psychically probes"
	verb_exclaim = "psychically yells"
	verb_yell = "psychically screams"
	melee_damage_lower = 10
	melee_damage_upper = 15
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	obj_damage = 20
	attack_verb_continuous = "hits"
	attack_verb_simple = "hit"
	attack_sound = 'sound/weapons/genhit1.ogg'
	death_message = "explodes into a cloud of gas!"
	lighting_cutoff_red = 20
	lighting_cutoff_green = 40
	lighting_cutoff_blue = 30
	initial_language_holder = /datum/language_holder/empty
	gold_core_spawnable = HOSTILE_SPAWN
	basic_mob_flags = DEL_ON_DEATH
	ai_controller = /datum/ai_controller/basic_controller/blob_zombie
	/// The dead body we have inside
	var/mob/living/carbon/human/corpse

/mob/living/basic/blob_zombie/update_overlays()
	. = ..()
	copy_overlays(corpse, TRUE)
	var/mutable_appearance/blob_head_overlay = mutable_appearance('icons/mob/nonhuman-player/blob.dmi', "blob_head")
	blob_head_overlay.color = LAZYACCESS(atom_colours, FIXED_COLOUR_PRIORITY) || COLOR_WHITE
	color = initial(color) // reversing what our component did lol, but we needed the value for the overlay
	. += blob_head_overlay

/// Store a body so that we can drop it on death
/mob/living/basic/blob_zombie/proc/consume_corpse(mob/living/carbon/human/new_corpse)
	if(new_corpse.wear_suit)
		maxHealth += new_corpse.get_armor_rating(MELEE)
		health = maxHealth
	new_corpse.set_facial_hairstyle("Shaved", update = FALSE)
	new_corpse.set_hairstyle("Bald", update = TRUE)
	new_corpse.forceMove(src)
	corpse = new_corpse
	update_appearance(UPDATE_ICON)

/// Blob-created zombies will ping for player control when they make a zombie
/mob/living/basic/blob_zombie/controlled

/mob/living/basic/blob_zombie/controlled/consume_corpse(mob/living/carbon/human/new_corpse)
	. = ..()
	if (key)
		return
	AddComponent(\
		/datum/component/ghost_direct_control,\
		ban_type = ROLE_BLOB_INFECTION,\
		poll_candidates = TRUE,\
		poll_ignore_key = POLL_IGNORE_BLOB,\
	)
