/obj/item/clothing/glasses/godeye
	name = "eye of god"
	desc = "A strange eye, said to have been torn from an omniscient creature that used to roam the wastes."
	icon_state = "godeye"
	inhand_icon_state = null
	vision_flags = SEE_TURFS
	clothing_traits = list(TRAIT_MADNESS_IMMUNE)
	// Blue, light blue
	color_cutoffs = list(15, 30, 40)
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	custom_materials = null
	var/datum/action/cooldown/spell/pointed/scan/scan_ability

/obj/item/clothing/glasses/godeye/Initialize(mapload)
	. = ..()
	scan_ability = new(src)

/obj/item/clothing/glasses/godeye/Destroy()
	QDEL_NULL(scan_ability)
	return ..()

/obj/item/clothing/glasses/godeye/equipped(mob/living/user, slot)
	. = ..()
	if(ishuman(user) && (slot & ITEM_SLOT_EYES))
		ADD_TRAIT(src, TRAIT_NODROP, EYE_OF_GOD_TRAIT)
		pain(user)
		scan_ability.Grant(user)

/obj/item/clothing/glasses/godeye/dropped(mob/living/user)
	. = ..()
	// Behead someone, their "glasses" drop on the floor
	// and thus, the god eye should no longer be sticky
	REMOVE_TRAIT(src, TRAIT_NODROP, EYE_OF_GOD_TRAIT)
	// And remove the scan ability, note that if we're being called from Destroy
	// that this may already be nulled and removed
	scan_ability?.Remove(user)

/obj/item/clothing/glasses/godeye/proc/pain(mob/living/victim)
	to_chat(victim, span_userdanger("You experience blinding pain, as [src] burrows into your skull."))
	victim.emote("scream")
	victim.flash_act()

/datum/action/cooldown/spell/pointed/scan
	name = "Scan"
	desc = "Scan an enemy, to get their location and rebuke them, increasing their time between attacks."
	background_icon_state = "bg_clock"
	overlay_icon_state = "bg_clock_border"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "scan"
	school = SCHOOL_HOLY
	cooldown_time = 35 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	antimagic_flags = MAGIC_RESISTANCE_MIND //Even god cannot penetrate the tin foil hat

	ranged_mousepointer = 'icons/effects/mouse_pointers/scan_target.dmi'

/datum/action/cooldown/spell/pointed/scan/is_valid_target(atom/cast_on)
	if(!isliving(cast_on))
		owner.balloon_alert(owner, "not a valid target!")
		return FALSE
	var/mob/living/living_cast_on = cast_on
	if(living_cast_on.stat == DEAD)
		owner.balloon_alert(owner, "target is dead!")
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/scan/cast(mob/living/cast_on)
	. = ..()

	if(cast_on.can_block_magic(MAGIC_RESISTANCE_MIND, charge_cost = 0))
		to_chat(owner, span_warning("As we apply our dissecting vision, we are abruptly cut short. \
			They have some kind of enigmatic mental defense. It seems we've been foiled."))
		return

	if(cast_on == owner)
		to_chat(owner, span_warning("The last time a god stared too closely into their own reflection, they became transfixed for all of time. Do not let us become like them."))
		return

	var/mob/living/living_owner = owner
	var/mob/living/living_scanned = cast_on
	living_scanned.apply_status_effect(/datum/status_effect/rebuked)
	var/datum/status_effect/agent_pinpointer/scan_pinpointer = living_owner.apply_status_effect(/datum/status_effect/agent_pinpointer/scan)
	scan_pinpointer.scan_target = living_scanned

	to_chat(living_scanned, span_warning("You briefly see a flash of [living_owner]'s face before being knocked off-balance by an unseen force!"))
	living_scanned.add_filter("scan", 2, list("type" = "outline", "color" = COLOR_RED, "size" = 1))
	addtimer(CALLBACK(living_scanned, TYPE_PROC_REF(/datum, remove_filter), "scan"), 30 SECONDS)

	healthscan(living_owner, living_scanned, 1, TRUE)

	owner.playsound_local(get_turf(owner), 'sound/effects/magic/smoke.ogg', 50, TRUE)
	owner.balloon_alert(owner, "[living_scanned] scanned")
	addtimer(CALLBACK(src, PROC_REF(send_cooldown_end_message), cooldown_time))

/datum/action/cooldown/spell/pointed/scan/proc/send_cooldown_end_message()
	owner?.balloon_alert(owner, "scan recharged")

/datum/status_effect/agent_pinpointer/scan
	duration = 15 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/agent_pinpointer/scan
	tick_interval = 2 SECONDS
	range_fuzz_factor = 0
	minimum_range = 1
	range_mid = 5
	range_far = 15

/datum/status_effect/agent_pinpointer/scan/scan_for_target()
	return

/atom/movable/screen/alert/status_effect/agent_pinpointer/scan
	name = "Scan Target"
	desc = "Contact may or may not be close."
