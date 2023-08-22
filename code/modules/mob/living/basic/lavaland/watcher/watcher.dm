/// A floating eyeball which keeps its distance and plays red light/green light with you.
/mob/living/basic/mining/watcher
	name = "watcher"
	desc = "A levitating, monocular creature held aloft by wing-like veins. A sharp spine of crystal protrudes from its body."
	icon = 'icons/mob/simple/lavaland/lavaland_monsters_wide.dmi'
	icon_state = "watcher"
	icon_living = "watcher"
	icon_dead = "watcher_dead"
	health_doll_icon = "watcher"
	pixel_x = -12
	base_pixel_x = -12
	speak_emote = list("chimes")
	speed = 3
	maxHealth = 160
	health = 160
	attack_verb_continuous = "buffets"
	attack_verb_simple = "buffet"
	crusher_loot = /obj/item/crusher_trophy/watcher_wing
	ai_controller = /datum/ai_controller/basic_controller/watcher
	butcher_results = list(
		/obj/item/stack/sheet/bone = 1,
		/obj/item/stack/ore/diamond = 2,
		/obj/item/stack/sheet/sinew = 2,
	)
	/// How often can we shoot?
	var/ranged_cooldown = 3 SECONDS
	/// What kind of beams we got?
	var/projectile_type = /obj/projectile/temp/watcher
	/// Icon state for our eye overlay
	var/eye_glow = "ice_glow"
	/// Sound to play when we shoot
	var/shoot_sound = 'sound/weapons/pierce.ogg'
	/// Typepath of our gaze ability
	var/gaze_attack = /datum/action/cooldown/mob_cooldown/watcher_gaze
	// We attract and eat these things for some reason
	var/list/wanted_objects = list(
		/obj/item/stack/sheet/mineral/diamond,
		/obj/item/stack/ore/diamond,
		/obj/item/pen/survival,
	)

/mob/living/basic/mining/watcher/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/simple_flying)
	AddElement(/datum/element/content_barfer)
	AddComponent(/datum/component/ai_target_timer)
	AddComponent(/datum/component/basic_ranged_ready_overlay, overlay_state = eye_glow)
	AddComponent(\
		/datum/component/ranged_attacks,\
		cooldown_time = ranged_cooldown,\
		projectile_type = projectile_type,\
		projectile_sound = shoot_sound,\
	)
	AddComponent(\
		/datum/component/magnet,\
		attracted_typecache = wanted_objects,\
		on_contact = CALLBACK(src, PROC_REF(consume)),\
	)
	update_appearance(UPDATE_OVERLAYS)

	var/datum/action/cooldown/mob_cooldown/watcher_overwatch/overwatch = new(src)
	overwatch.Grant(src)
	overwatch.projectile_type = projectile_type
	ai_controller.set_blackboard_key(BB_WATCHER_OVERWATCH, overwatch)

	var/datum/action/cooldown/mob_cooldown/watcher_gaze/gaze = new gaze_attack(src)
	gaze.Grant(src)
	ai_controller.set_blackboard_key(BB_WATCHER_GAZE, gaze)

/mob/living/basic/mining/watcher/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "watcher_emissive", src)

/// I love eating diamonds yum
/mob/living/basic/mining/watcher/proc/consume(atom/movable/thing)
	visible_message(span_warning("[thing] seems to vanish into [src]'s body!"))
	thing.forceMove(src)

/// More durable, burning projectiles
/mob/living/basic/mining/watcher/magmawing
	name = "magmawing watcher"
	desc = "Presented with extreme temperatures, adaptive watchers absorb heat through their circulatory wings and repurpose it as a weapon."
	icon_state = "watcher_magmawing"
	icon_living = "watcher_magmawing"
	icon_dead = "watcher_magmawing_dead"
	eye_glow = "fire_glow"
	maxHealth = 175 //Compensate for the lack of slowdown on projectiles with a bit of extra health
	health = 175
	projectile_type = /obj/projectile/temp/watcher/magma_wing
	gaze_attack = /datum/action/cooldown/mob_cooldown/watcher_gaze/fire
	crusher_loot = /obj/item/crusher_trophy/blaster_tubes/magma_wing
	crusher_drop_chance = 100 // There's only going to be one of these per round throw them a bone

/// Less durable, freezing projectiles
/mob/living/basic/mining/watcher/icewing
	name = "icewing watcher"
	desc = "Watchers which fail to absorb enough heat during their development become fragile, but share their internal chill with their enemies."
	icon_state = "watcher_icewing"
	icon_living = "watcher_icewing"
	icon_dead = "watcher_icewing_dead"
	maxHealth = 130
	health = 130
	projectile_type = /obj/projectile/temp/watcher/ice_wing
	gaze_attack = /datum/action/cooldown/mob_cooldown/watcher_gaze/ice
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/bone = 1)
	crusher_loot = /obj/item/crusher_trophy/watcher_wing/ice_wing
	crusher_drop_chance = 100
