//This file contains loot you can obtain from tendril chests.

//KA modkit design discs
/obj/item/disk/design_disk/modkit_disc
	name = "KA Mod Disk"
	desc = "A design disc containing the design for a unique kinetic accelerator modkit. It's compatible with a research console."
	icon_state = "datadisk1"
	var/modkit_design = /datum/design/unique_modkit

/obj/item/disk/design_disk/modkit_disc/Initialize(mapload)
	. = ..()
	blueprints += new modkit_design

/obj/item/disk/design_disk/modkit_disc/mob_and_turf_aoe
	name = "Offensive Mining Explosion Mod Disk"
	modkit_design = /datum/design/unique_modkit/offensive_turf_aoe

/obj/item/disk/design_disk/modkit_disc/rapid_repeater
	name = "Rapid Repeater Mod Disk"
	modkit_design = /datum/design/unique_modkit/rapid_repeater

/obj/item/disk/design_disk/modkit_disc/resonator_blast
	name = "Resonator Blast Mod Disk"
	modkit_design = /datum/design/unique_modkit/resonator_blast

/obj/item/disk/design_disk/modkit_disc/bounty
	name = "Death Syphon Mod Disk"
	modkit_design = /datum/design/unique_modkit/bounty

/datum/design/unique_modkit
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_PKA_MODS,
	)
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/unique_modkit/offensive_turf_aoe
	name = "Kinetic Accelerator Offensive Mining Explosion Mod"
	desc = "A device which causes kinetic accelerators to fire AoE blasts that destroy rock and damage creatures."
	id = "hyperaoemod"
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*3.5, /datum/material/glass = SHEET_MATERIAL_AMOUNT*1.5, /datum/material/silver =SHEET_MATERIAL_AMOUNT*1.5, /datum/material/gold =SHEET_MATERIAL_AMOUNT*1.5, /datum/material/diamond = SHEET_MATERIAL_AMOUNT*2)
	build_path = /obj/item/borg/upgrade/modkit/aoe/turfs/andmobs

/datum/design/unique_modkit/rapid_repeater
	name = "Kinetic Accelerator Rapid Repeater Mod"
	desc = "A device which greatly reduces a kinetic accelerator's cooldown on striking a living target or rock, but greatly increases its base cooldown."
	id = "repeatermod"
	materials = list(/datum/material/iron =HALF_SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass =SHEET_MATERIAL_AMOUNT * 2.5, /datum/material/uranium = SHEET_MATERIAL_AMOUNT*4, /datum/material/bluespace =SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/borg/upgrade/modkit/cooldown/repeater

/datum/design/unique_modkit/resonator_blast
	name = "Kinetic Accelerator Resonator Blast Mod"
	desc = "A device which causes kinetic accelerators to fire shots that leave and detonate resonator blasts."
	id = "resonatormod"
	materials = list(/datum/material/iron =HALF_SHEET_MATERIAL_AMOUNT*5, /datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT*5, /datum/material/silver =HALF_SHEET_MATERIAL_AMOUNT*5, /datum/material/uranium =SHEET_MATERIAL_AMOUNT * 2.5)
	build_path = /obj/item/borg/upgrade/modkit/resonator_blasts

/datum/design/unique_modkit/bounty
	name = "Kinetic Accelerator Death Syphon Mod"
	desc = "A device which causes kinetic accelerators to permanently gain damage against creature types killed with it."
	id = "bountymod"
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*2, /datum/material/silver = SHEET_MATERIAL_AMOUNT*2, /datum/material/gold = SHEET_MATERIAL_AMOUNT*2, /datum/material/bluespace = SHEET_MATERIAL_AMOUNT*2)
	build_path = /obj/item/borg/upgrade/modkit/bounty

//Spooky special loot

//Rod of Asclepius
/obj/item/rod_of_asclepius
	name = "\improper Rod of Asclepius"
	desc = "A wooden rod about the size of your forearm with a snake carved around it, winding its way up the sides of the rod. Something about it seems to inspire in you the responsibilty and duty to help others."
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	icon_state = "asclepius_dormant"
	inhand_icon_state = "asclepius_dormant"
	icon_angle = -45
	var/activated = FALSE

/obj/item/rod_of_asclepius/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/rod_of_asclepius/update_desc(updates)
	. = ..()
	desc = activated ? "A short wooden rod with a mystical snake inseparably gripping itself and the rod to your forearm. It flows with a healing energy that disperses amongst yourself and those around you." : initial(desc)

/obj/item/rod_of_asclepius/update_icon_state()
	. = ..()
	icon_state = inhand_icon_state = "asclepius_[activated ? "active" : "dormant"]"

/obj/item/rod_of_asclepius/vv_edit_var(vname, vval)
	. = ..()
	if(vname == NAMEOF(src, activated) && activated)
		activated()

/obj/item/rod_of_asclepius/attack_self(mob/user)
	if(activated)
		return
	if(!iscarbon(user))
		to_chat(user, span_warning("The snake carving seems to come alive, if only for a moment, before returning to its dormant state, almost as if it finds you incapable of holding its oath."))
		return
	var/mob/living/carbon/itemUser = user
	var/usedHand = itemUser.get_held_index_of_item(src)
	if(itemUser.has_status_effect(/datum/status_effect/hippocratic_oath))
		to_chat(user, span_warning("You can't possibly handle the responsibility of more than one rod!"))
		return
	var/failText = span_warning("The snake seems unsatisfied with your incomplete oath and returns to its previous place on the rod, returning to its dormant, wooden state. You must stand still while completing your oath!")
	to_chat(itemUser, span_notice("The wooden snake that was carved into the rod seems to suddenly come alive and begins to slither down your arm! The compulsion to help others grows abnormally strong..."))
	if(do_after(itemUser, 4 SECONDS, target = itemUser))
		itemUser.say("I swear to fulfill, to the best of my ability and judgment, this covenant:", forced = "hippocratic oath")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 2 SECONDS, target = itemUser))
		itemUser.say("I will apply, for the benefit of the sick, all measures that are required, avoiding those twin traps of overtreatment and therapeutic nihilism.", forced = "hippocratic oath")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 3 SECONDS, target = itemUser))
		itemUser.say("I will remember that I remain a member of society, with special obligations to all my fellow human beings, those sound of mind and body as well as the infirm.", forced = "hippocratic oath")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 3 SECONDS, target = itemUser))
		itemUser.say("If I do not violate this oath, may I enjoy life and art, respected while I live and remembered with affection thereafter. May I always act so as to preserve the finest traditions of my calling and may I long experience the joy of healing those who seek my help.", forced = "hippocratic oath")
	else
		to_chat(itemUser, failText)
		return
	to_chat(itemUser, span_notice("The snake, satisfied with your oath, attaches itself and the rod to your forearm with an inseparable grip. Your thoughts seem to only revolve around the core idea of helping others, and harm is nothing more than a distant, wicked memory..."))
	var/datum/status_effect/hippocratic_oath/effect = itemUser.apply_status_effect(/datum/status_effect/hippocratic_oath)
	effect.hand = usedHand
	activated()

/obj/item/rod_of_asclepius/proc/activated()
	item_flags = DROPDEL
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(type))
	activated = TRUE
	update_appearance()

//Memento Mori
/obj/item/clothing/neck/necklace/memento_mori
	name = "Memento Mori"
	desc = "A mysterious pendant. An inscription on it says: \"Certain death tomorrow means certain life today.\""
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "memento_mori"
	worn_icon_state = "memento"
	actions_types = list(/datum/action/item_action/hands_free/memento_mori)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/mob/living/carbon/human/active_owner

/obj/item/clothing/neck/necklace/memento_mori/item_action_slot_check(slot)
	return (slot & ITEM_SLOT_NECK)

/obj/item/clothing/neck/necklace/memento_mori/dropped(mob/user)
	..()
	if(active_owner)
		mori()

//Just in case
/obj/item/clothing/neck/necklace/memento_mori/Destroy()
	if(active_owner)
		mori()
	return ..()

/obj/item/clothing/neck/necklace/memento_mori/proc/memento(mob/living/carbon/human/user)
	to_chat(user, span_warning("You feel your life being drained by the pendant..."))
	if(do_after(user, 4 SECONDS, target = user))
		to_chat(user, span_notice("Your lifeforce is now linked to the pendant! You feel like removing it would kill you, and yet you instinctively know that until then, you won't die."))
		user.add_traits(list(TRAIT_NODEATH, TRAIT_NOHARDCRIT, TRAIT_NOCRITDAMAGE), CLOTHING_TRAIT)
		RegisterSignal(user, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(check_health))
		icon_state = "memento_mori_active"
		active_owner = user

/obj/item/clothing/neck/necklace/memento_mori/proc/mori()
	icon_state = "memento_mori"
	if(!active_owner)
		return
	UnregisterSignal(active_owner, COMSIG_LIVING_HEALTH_UPDATE)
	var/mob/living/carbon/human/H = active_owner //to avoid infinite looping when dust unequips the pendant
	active_owner = null
	to_chat(H, span_userdanger("You feel your life rapidly slipping away from you!"))
	H.dust(TRUE, TRUE)

/obj/item/clothing/neck/necklace/memento_mori/proc/check_health(mob/living/source)
	SIGNAL_HANDLER

	var/list/guardians = source.get_all_linked_holoparasites()
	if(!length(guardians))
		return
	if(source.health <= HEALTH_THRESHOLD_DEAD)
		for(var/mob/guardian in guardians)
			if(guardian.loc == src)
				continue
			consume_guardian(guardian)
	else if(source.health > HEALTH_THRESHOLD_CRIT)
		for(var/mob/guardian in guardians)
			if(guardian.loc != src)
				continue
			regurgitate_guardian(guardian)

/obj/item/clothing/neck/necklace/memento_mori/proc/consume_guardian(mob/living/basic/guardian/guardian)
	new /obj/effect/temp_visual/guardian/phase/out(get_turf(guardian))
	guardian.locked = TRUE
	guardian.forceMove(src)
	to_chat(guardian, span_userdanger("You have been locked away in your summoner's pendant!"))
	guardian.playsound_local(get_turf(guardian), 'sound/effects/magic/summonitems_generic.ogg', 50, TRUE)

/obj/item/clothing/neck/necklace/memento_mori/proc/regurgitate_guardian(mob/living/basic/guardian/guardian)
	guardian.locked = FALSE
	guardian.recall(forced = TRUE)
	to_chat(guardian, span_notice("You have been returned back from your summoner's pendant!"))
	guardian.playsound_local(get_turf(guardian), 'sound/effects/magic/repulse.ogg', 50, TRUE)

/datum/action/item_action/hands_free/memento_mori
	check_flags = NONE
	name = "Memento Mori"
	desc = "Bind your life to the pendant."

/datum/action/item_action/hands_free/memento_mori/Trigger(trigger_flags)
	var/obj/item/clothing/neck/necklace/memento_mori/MM = target
	if(!MM.active_owner)
		if(ishuman(owner))
			MM.memento(owner)
			Remove(MM.active_owner) //Remove the action button, since there's no real use in having it now.

//Wisp Lantern
/obj/item/wisp_lantern
	name = "spooky lantern"
	desc = "This lantern gives off no light, but is home to a friendly wisp."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "lantern-blue-on"
	inhand_icon_state = "lantern-blue-on"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	var/obj/effect/wisp/wisp

/obj/item/wisp_lantern/attack_self(mob/user)
	if(!wisp)
		to_chat(user, span_warning("The wisp has gone missing!"))
		icon_state = "lantern-blue"
		inhand_icon_state = "lantern-blue"
		return

	if(wisp.loc == src)
		to_chat(user, span_notice("You release the wisp. It begins to bob around your head."))
		icon_state = "lantern-blue"
		inhand_icon_state = "lantern-blue"
		wisp.orbit(user, 20)
		SSblackbox.record_feedback("tally", "wisp_lantern", 1, "Freed")
		return

	to_chat(user, span_notice("You return the wisp to the lantern."))
	icon_state = "lantern-blue-on"
	inhand_icon_state = "lantern-blue-on"
	wisp.forceMove(src)
	SSblackbox.record_feedback("tally", "wisp_lantern", 1, "Returned")

/obj/item/wisp_lantern/Initialize(mapload)
	. = ..()
	wisp = new(src)

/obj/item/wisp_lantern/Destroy()
	if(wisp)
		if(wisp.loc == src)
			qdel(wisp)
		else
			wisp.visible_message(span_notice("[wisp] has a sad feeling for a moment, then it passes."))
	return ..()

/obj/effect/wisp
	name = "friendly wisp"
	desc = "Happy to light your way."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "orb"
	light_system = OVERLAY_LIGHT
	light_range = 6
	light_power = 1.2
	light_color = "#79f1ff"
	light_flags = LIGHT_ATTACHED
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	var/list/color_cutoffs = list(10, 25, 25)

/obj/effect/wisp/orbit(atom/thing, radius, clockwise, rotation_speed, rotation_segments, pre_rotation, lockinorbit)
	. = ..()
	if(!ismob(thing))
		return
	var/mob/being = thing
	RegisterSignal(being, COMSIG_MOB_UPDATE_SIGHT, PROC_REF(update_user_sight))
	to_chat(being, span_notice("The wisp enhances your vision."))
	ADD_TRAIT(being, TRAIT_THERMAL_VISION, REF(src))
	being.update_sight()

/obj/effect/wisp/stop_orbit(datum/component/orbiter/orbits)
	if(!ismob(orbit_target))
		return ..()
	var/mob/being = orbit_target
	UnregisterSignal(being, COMSIG_MOB_UPDATE_SIGHT)
	to_chat(being, span_notice("Your vision returns to normal."))
	REMOVE_TRAIT(being, TRAIT_THERMAL_VISION, REF(src))
	being.update_sight()
	return ..()

/obj/effect/wisp/proc/update_user_sight(mob/user)
	SIGNAL_HANDLER
	if(!isnull(color_cutoffs))
		user.lighting_color_cutoffs = blend_cutoff_colors(user.lighting_color_cutoffs, color_cutoffs)

//Red/Blue Cubes
/obj/item/warp_cube
	name = "blue cube"
	desc = "A mysterious blue cube."
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "blue_cube"
	var/teleport_color = "#3FBAFD"
	var/obj/item/warp_cube/linked
	var/teleporting = FALSE

/obj/item/warp_cube/Destroy()
	if(!QDELETED(linked))
		qdel(linked)
	linked = null
	return ..()

/obj/item/warp_cube/attack_self(mob/user)
	var/turf/current_location = get_turf(user)
	if(!linked || !check_teleport_valid(src, current_location))
		to_chat(user, span_warning("[src] fizzles uselessly."))
		return
	if(teleporting)
		return
	teleporting = TRUE
	linked.teleporting = TRUE
	var/turf/T = get_turf(src)
	new /obj/effect/temp_visual/warp_cube(T, user, teleport_color, TRUE)
	SSblackbox.record_feedback("tally", "warp_cube", 1, type)
	new /obj/effect/temp_visual/warp_cube(get_turf(linked), user, linked.teleport_color, FALSE)
	var/obj/effect/warp_cube/link_holder = new /obj/effect/warp_cube(T)
	user.forceMove(link_holder) //mess around with loc so the user can't wander around
	sleep(0.25 SECONDS)
	if(QDELETED(user))
		qdel(link_holder)
		return
	if(QDELETED(linked))
		user.forceMove(get_turf(link_holder))
		qdel(link_holder)
		return
	link_holder.forceMove(get_turf(linked))
	sleep(0.25 SECONDS)
	if(QDELETED(user))
		qdel(link_holder)
		return
	teleporting = FALSE
	if(!QDELETED(linked))
		linked.teleporting = FALSE
	user.forceMove(get_turf(link_holder))
	qdel(link_holder)

/obj/item/warp_cube/red
	name = "red cube"
	desc = "A mysterious red cube."
	icon_state = "red_cube"
	teleport_color = "#FD3F48"

/obj/item/warp_cube/red/Initialize(mapload)
	. = ..()
	if(!linked)
		var/obj/item/warp_cube/blue = new(src.loc)
		linked = blue
		blue.linked = src

/obj/effect/warp_cube
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE

//Immortality Talisman
/obj/item/immortality_talisman
	name = "\improper Immortality Talisman"
	desc = "A dread talisman that can render you completely invulnerable."
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "talisman"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	actions_types = list(/datum/action/item_action/immortality)
	var/cooldown = 0

/obj/item/immortality_talisman/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, ALL)

/datum/action/item_action/immortality
	name = "Immortality"

/obj/item/immortality_talisman/attack_self(mob/user)
	if(cooldown < world.time)
		SSblackbox.record_feedback("amount", "immortality_talisman_uses", 1)
		cooldown = world.time + 600
		new /obj/effect/immortality_talisman(get_turf(user), user)
	else
		to_chat(user, span_warning("[src] is not ready yet!"))

/obj/effect/immortality_talisman
	name = "hole in reality"
	desc = "It's shaped an awful lot like a person."
	icon_state = "blank"
	icon = 'icons/effects/effects.dmi'
	var/vanish_description = "vanishes from reality"
	// Weakref to the user who we're "acting" on
	var/datum/weakref/user_ref

/obj/effect/immortality_talisman/Initialize(mapload, mob/new_user)
	. = ..()
	if(new_user)
		vanish(new_user)

/obj/effect/immortality_talisman/Destroy()
	// If we have a mob, we need to free it before cleanup
	// This is a safety to prevent nuking a human, not so much a good pattern in general
	unvanish()
	return ..()

/obj/effect/immortality_talisman/proc/unvanish()
	var/mob/user = user_ref?.resolve()
	user_ref = null

	if(!user)
		return

	user.remove_traits(list(TRAIT_GODMODE, TRAIT_NO_TRANSFORM), REF(src))
	user.forceMove(get_turf(src))
	user.visible_message(span_danger("[user] pops back into reality!"))

/obj/effect/immortality_talisman/proc/vanish(mob/user)
	user.visible_message(span_danger("[user] [vanish_description], leaving a hole in [user.p_their()] place!"))

	desc = "It's shaped an awful lot like [user.name]."
	setDir(user.dir)

	user.forceMove(src)
	user.add_traits(list(TRAIT_GODMODE, TRAIT_NO_TRANSFORM), REF(src))

	user_ref = WEAKREF(user)

	addtimer(CALLBACK(src, PROC_REF(dissipate)), 10 SECONDS)

/obj/effect/immortality_talisman/proc/dissipate()
	qdel(src)

/obj/effect/immortality_talisman/attackby()
	return

/obj/effect/immortality_talisman/relaymove(mob/living/user, direction)
	// Won't really come into play since our mob has TRAIT_NO_TRANSFORM and cannot move,
	// but regardless block all relayed moves, because no, you cannot move in the void.
	return

/obj/effect/immortality_talisman/singularity_pull(atom/singularity, current_size)
	return

/obj/effect/immortality_talisman/void
	vanish_description = "is dragged into the void"

//Shared Bag

/obj/item/shared_storage
	name = "paradox bag"
	desc = "Somehow, it's in two places at once."
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "paradox_bag"
	worn_icon_state = "paradoxbag"
	slot_flags = ITEM_SLOT_BELT
	resistance_flags = INDESTRUCTIBLE

/obj/item/shared_storage/red

/obj/item/shared_storage/red/Initialize(mapload)
	. = ..()

	create_storage(max_total_storage = 15, max_slots = 21)

	new /obj/item/shared_storage/blue(drop_location(), src)

/obj/item/shared_storage/blue/Initialize(mapload, atom/master)
	. = ..()
	if(!istype(master))
		return INITIALIZE_HINT_QDEL
	create_storage(max_total_storage = 15, max_slots = 21)

	atom_storage.set_real_location(master)

//Book of Babel

/obj/item/book_of_babel
	name = "Book of Babel"
	desc = "An ancient tome written in countless tongues."
	icon = 'icons/obj/service/library.dmi'
	icon_state = "book1"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/book_of_babel/attack_self(mob/user)
	if(user.is_blind())
		to_chat(user, span_warning("You are blind and can't read anything!"))
		return FALSE
	if(!user.can_read(src))
		return FALSE
	to_chat(user, span_notice("You flip through the pages of the book, quickly and conveniently learning every language in existence. Somewhat less conveniently, the aging book crumbles to dust in the process. Whoops."))
	cure_curse_of_babel(user) // removes tower of babel if we have it
	user.grant_all_languages(source = LANGUAGE_BABEL)
	user.remove_blocked_language(GLOB.all_languages, source = LANGUAGE_ALL)
	if(user.mind)
		ADD_TRAIT(user.mind, TRAIT_TOWER_OF_BABEL, MAGIC_TRAIT) // this makes you immune to babel effects
	new /obj/effect/decal/cleanable/ash(get_turf(user))
	qdel(src)


//Potion of Flight
/obj/item/reagent_containers/cup/bottle/potion
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "potionflask"
	fill_icon = 'icons/obj/mining_zones/artefacts.dmi'
	fill_icon_state = "potion_fill"
	fill_icon_thresholds = list(0, 1)

/obj/item/reagent_containers/cup/bottle/potion/update_overlays()
	. = ..()
	if(reagents?.total_volume)
		. += "potionflask_cap"

/obj/item/reagent_containers/cup/bottle/potion/flight
	name = "strange elixir"
	desc = "A flask with an almost-holy aura emitting from it. The label on the bottle says: 'erqo'hyy tvi'rf lbh jv'atf'."
	list_reagents = list(/datum/reagent/flightpotion = 5)

/datum/reagent/flightpotion
	name = "Flight Potion"
	description = "Strange mutagenic compound of unknown origins."
	color = "#976230"

/datum/reagent/flightpotion/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE)
	. = ..()
	if(!ishuman(exposed_mob) || exposed_mob.stat == DEAD)
		return
	if(!(methods & (INGEST | TOUCH)))
		return
	var/mob/living/carbon/human/exposed_human = exposed_mob
	var/obj/item/bodypart/chest/chest = exposed_human.get_bodypart(BODY_ZONE_CHEST)
	if(!chest.wing_types || reac_volume < 5 || !exposed_human.dna)
		if((methods & INGEST) && show_message)
			to_chat(exposed_human, span_notice("<i>You feel nothing but a terrible aftertaste.</i>"))
		return
	if(exposed_human.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS))
		to_chat(exposed_human, span_userdanger("A terrible pain travels down your back as your wings change shape!"))
	else
		to_chat(exposed_human, span_userdanger("A terrible pain travels down your back as wings burst out!"))
	var/obj/item/organ/wings/functional/wings = get_wing_choice(exposed_human, chest)
	wings = new wings()
	wings.Insert(exposed_human)
	playsound(exposed_human.loc, 'sound/items/poster/poster_ripped.ogg', 50, TRUE, -1)
	exposed_human.apply_damage(20, def_zone = BODY_ZONE_CHEST, forced = TRUE, wound_bonus = CANT_WOUND)
	exposed_human.emote("scream")

/datum/reagent/flightpotion/proc/get_wing_choice(mob/needs_wings, obj/item/bodypart/chest/chest)
	var/list/wing_types = chest.wing_types.Copy()
	if(wing_types.len == 1 || !needs_wings.client)
		return wing_types[1]
	var/list/radial_wings = list()
	var/list/name2type = list()
	for(var/obj/item/organ/wings/functional/possible_type as anything in wing_types)
		var/datum/sprite_accessory/accessory = initial(possible_type.sprite_accessory_override) //get the type
		accessory = SSaccessories.wings_list[initial(accessory.name)] //get the singleton instance
		var/image/img = image(icon = accessory.icon, icon_state = "m_wingsopen_[accessory.icon_state]_BEHIND") //Process the HUD elements
		img.transform *= 0.5
		img.pixel_x = -32
		if(radial_wings[accessory.name])
			stack_trace("Different wing types with repeated names. Please fix as this may cause issues.")
		else
			radial_wings[accessory.name] = img
			name2type[accessory.name] = possible_type
	var/wing_name = show_radial_menu(needs_wings, needs_wings, radial_wings, tooltips = TRUE)
	var/wing_type = name2type[wing_name]
	if(!wing_type)
		wing_type = pick(wing_types)
	return wing_type

/obj/item/jacobs_ladder
	name = "jacob's ladder"
	desc = "A celestial ladder that violates the laws of physics."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder00"

/obj/item/jacobs_ladder/attack_self(mob/user)
	var/turf/T = get_turf(src)
	var/ladder_x = T.x
	var/ladder_y = T.y
	to_chat(user, span_notice("You unfold the ladder. It extends much farther than you were expecting."))
	var/last_ladder = null
	for(var/i in 1 to world.maxz)
		if(is_centcom_level(i) || is_reserved_level(i) || is_away_level(i))
			continue
		var/turf/T2 = locate(ladder_x, ladder_y, i)
		last_ladder = new /obj/structure/ladder/unbreakable/jacob(T2, null, last_ladder)
	qdel(src)

// Inherit from unbreakable but don't set ID, to suppress the default Z linkage
/obj/structure/ladder/unbreakable/jacob
	name = "jacob's ladder"
	desc = "An indestructible celestial ladder that violates the laws of physics."

//Concussive Gauntlets
/obj/item/clothing/gloves/gauntlets
	name = "concussive gauntlets"
	desc = "Pickaxes... for your hands!"
	icon_state = "concussive_gauntlets"
	inhand_icon_state = null
	toolspeed = 0.1
	strip_delay = 40
	equip_delay_other = 20
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	body_parts_covered = HANDS|ARMS
	resistance_flags = LAVA_PROOF | FIRE_PROOF //they are from lavaland after all
	armor_type = /datum/armor/gloves_gauntlets

/datum/armor/gloves_gauntlets
	melee = 15
	bullet = 25
	laser = 15
	energy = 15
	bomb = 100
	fire = 100
	acid = 30

/obj/item/clothing/gloves/gauntlets/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_GLOVES)
		tool_behaviour = TOOL_MINING
		RegisterSignal(user, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(rocksmash))
		RegisterSignal(user, COMSIG_MOVABLE_BUMP, PROC_REF(rocksmash))
	else
		stopmining(user)

/obj/item/clothing/gloves/gauntlets/dropped(mob/user)
	. = ..()
	stopmining(user)

/obj/item/clothing/gloves/gauntlets/proc/stopmining(mob/user)
	tool_behaviour = initial(tool_behaviour)
	UnregisterSignal(user, COMSIG_LIVING_UNARMED_ATTACK)
	UnregisterSignal(user, COMSIG_MOVABLE_BUMP)

/obj/item/clothing/gloves/gauntlets/proc/rocksmash(mob/living/carbon/human/user, atom/rocks, proximity)
	SIGNAL_HANDLER
	if(!proximity)
		return NONE
	if(!ismineralturf(rocks) && !isasteroidturf(rocks))
		return NONE
	rocks.attackby(src, user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/clothing/suit/hooded/berserker
	name = "berserker armor"
	desc = "This hulking armor seems to possess some kind of dark force within; howling in rage, hungry for carnage. \
		The self-sealing stem bolts that allowed this suit to be spaceworthy have long since corroded. However, the entity \
		sealed within the suit seems to hunger for the fleeting lifeforce found in the remains left in the remains of drakes. \
		Feeding it drake remains seems to empower a suit piece, though turns the remains back to lifeless ash."
	icon_state = "berserker"
	icon = 'icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor.dmi'
	hoodtype = /obj/item/clothing/head/hooded/berserker
	armor_type = /datum/armor/hooded_berserker
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	clothing_flags = THICKMATERIAL|HEADINTERNALS

/datum/armor/hooded_berserker
	melee = 30
	bullet = 30
	laser = 10
	energy = 20
	bomb = 50
	bio = 60
	fire = 100
	acid = 100
	wound = 10

/datum/armor/drake_empowerment
	melee = 35
	laser = 30
	energy = 20
	bomb = 20

/obj/item/clothing/suit/hooded/berserker/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, ALL, inventory_flags = ITEM_SLOT_OCLOTHING)
	AddComponent(/datum/component/armor_plate, maxamount = 1, upgrade_item = /obj/item/drake_remains, armor_mod = /datum/armor/drake_empowerment, upgrade_prefix = "empowered")
	allowed = GLOB.mining_suit_allowed

#define MAX_BERSERK_CHARGE 100
#define PROJECTILE_HIT_MULTIPLIER 1.5
#define DAMAGE_TO_CHARGE_SCALE 0.75
#define CHARGE_DRAINED_PER_SECOND 5
#define BERSERK_ATTACK_SPEED_MODIFIER 0.25

/obj/item/clothing/head/hooded/berserker
	name = "berserker helmet"
	desc = "This burdensome helmet seems to possess some kind of dark force within; howling in rage, hungry for carnage. \
		The self-sealing stem bolts that allowed this helmet to be spaceworthy have long since corroded. However, the entity \
		sealed within the suit seems to hunger for the fleeting lifeforce found in the remains left in the remains of drakes. \
		Feeding it drake remains seems to empower a suit piece, though turns the remains back to lifeless ash."
	icon_state = "berserker"
	icon = 'icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	armor_type = /datum/armor/hooded_berserker
	actions_types = list(/datum/action/item_action/berserk_mode)
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS|HIDESNOUT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	clothing_flags = SNUG_FIT|THICKMATERIAL
	/// Current charge of berserk, goes from 0 to 100
	var/berserk_charge = 0
	/// Status of berserk
	var/berserk_active = FALSE

/obj/item/clothing/head/hooded/berserker/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, LOCKED_HELMET_TRAIT)
	AddComponent(/datum/component/armor_plate, maxamount = 1, upgrade_item = /obj/item/drake_remains, armor_mod = /datum/armor/drake_empowerment, upgrade_prefix = "empowered")
	AddComponent(/datum/component/item_equipped_movement_rustle, SFX_PLATE_ARMOR_RUSTLE, 8)

/obj/item/clothing/head/hooded/berserker/examine()
	. = ..()
	. += span_notice("Berserk mode is [berserk_charge]% charged.")

/obj/item/clothing/head/hooded/berserker/process(seconds_per_tick)
	if(berserk_active)
		berserk_charge = clamp(berserk_charge - CHARGE_DRAINED_PER_SECOND * seconds_per_tick, 0, MAX_BERSERK_CHARGE)
	if(!berserk_charge)
		if(ishuman(loc))
			end_berserk(loc)

/obj/item/clothing/head/hooded/berserker/dropped(mob/user)
	. = ..()
	end_berserk(user)

/obj/item/clothing/head/hooded/berserker/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	if(berserk_active)
		return
	var/berserk_value = damage * DAMAGE_TO_CHARGE_SCALE
	if(attack_type == PROJECTILE_ATTACK)
		berserk_value *= PROJECTILE_HIT_MULTIPLIER
	berserk_charge = clamp(round(berserk_charge + berserk_value), 0, MAX_BERSERK_CHARGE)
	if(berserk_charge >= MAX_BERSERK_CHARGE)
		var/datum/action/item_action/berserk_mode/ragemode = locate() in actions
		to_chat(owner, span_notice("Berserk mode is fully charged."))
		balloon_alert(owner, "berserk charged")
		ragemode?.build_all_button_icons(UPDATE_BUTTON_STATUS)

/obj/item/clothing/head/hooded/berserker/IsReflect()
	if(berserk_active)
		return TRUE

/// Starts berserk, reducing incoming brute by 50%, doubled attacking speed, NOGUNS trait, adding a color and giving them the berserk movespeed modifier
/obj/item/clothing/head/hooded/berserker/proc/berserk_mode(mob/living/carbon/human/user)
	var/datum/action/item_action/berserk_mode/ragemode = locate() in actions
	to_chat(user, span_warning("You enter berserk mode."))
	playsound(user, 'sound/effects/magic/staff_healing.ogg', 50)
	user.add_movespeed_modifier(/datum/movespeed_modifier/berserk)
	user.physiology.brute_mod *= 0.5
	user.next_move_modifier *= BERSERK_ATTACK_SPEED_MODIFIER
	user.add_atom_colour(COLOR_BUBBLEGUM_RED, TEMPORARY_COLOUR_PRIORITY)
	user.add_traits(list(TRAIT_NOGUNS, TRAIT_TOSS_GUN_HARD), BERSERK_TRAIT)
	ADD_TRAIT(src, TRAIT_NODROP, BERSERK_TRAIT)
	berserk_active = TRUE
	START_PROCESSING(SSobj, src)
	ragemode?.build_all_button_icons(UPDATE_BUTTON_STATUS)

/// Ends berserk, reverting the changes from the proc [berserk_mode]
/obj/item/clothing/head/hooded/berserker/proc/end_berserk(mob/living/carbon/human/user)
	if(!berserk_active)
		return
	berserk_active = FALSE
	if(QDELETED(user))
		return
	var/datum/action/item_action/berserk_mode/ragemode = locate() in actions
	ragemode?.build_all_button_icons(UPDATE_BUTTON_STATUS)
	to_chat(user, span_warning("You exit berserk mode."))
	playsound(user, 'sound/effects/magic/summonitems_generic.ogg', 50)
	user.remove_movespeed_modifier(/datum/movespeed_modifier/berserk)
	user.physiology.brute_mod *= 2
	user.next_move_modifier /= BERSERK_ATTACK_SPEED_MODIFIER
	user.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_BUBBLEGUM_RED)
	user.remove_traits(list(TRAIT_NOGUNS, TRAIT_TOSS_GUN_HARD), BERSERK_TRAIT)
	REMOVE_TRAIT(src, TRAIT_NODROP, BERSERK_TRAIT)
	STOP_PROCESSING(SSobj, src)

#undef MAX_BERSERK_CHARGE
#undef PROJECTILE_HIT_MULTIPLIER
#undef DAMAGE_TO_CHARGE_SCALE
#undef CHARGE_DRAINED_PER_SECOND
#undef BERSERK_ATTACK_SPEED_MODIFIER

/obj/item/drake_remains
	name = "drake remains"
	desc = "The gathered remains of a drake. It still crackles with heat, and smells distinctly of brimstone."
	icon = 'icons/obj/clothing/head/helmet.dmi'
	icon_state = "dragon"

/obj/item/drake_remains/Initialize(mapload)
	. = ..()
	add_shared_particles(/particles/bonfire)

/obj/item/drake_remains/Destroy(force)
	remove_shared_particles(/particles/bonfire)
	return ..()

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

/obj/item/organ/cyberimp/arm/shard
	name = "dark spoon shard"
	desc = "An eerie metal shard surrounded by dark energies...of soup drinking. You probably don't think you should have been able to find this."
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "cursed_katana_organ"
	organ_flags = ORGAN_ORGANIC | ORGAN_FROZEN | ORGAN_UNREMOVABLE
	items_to_create = list(/obj/item/kitchen/spoon)
	extend_sound = 'sound/items/unsheath.ogg'
	retract_sound = 'sound/items/sheath.ogg'

/obj/item/organ/cyberimp/arm/shard/attack_self(mob/user, modifiers)
	. = ..()
	to_chat(user, span_userdanger("The mass goes up your arm and goes inside it!"))
	playsound(user, 'sound/effects/magic/demon_consume.ogg', 50, TRUE)
	var/index = user.get_held_index_of_item(src)
	zone = (index == LEFT_HANDS ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM)
	SetSlotFromZone()
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	Insert(user)

/obj/item/organ/cyberimp/arm/shard/screwdriver_act(mob/living/user, obj/item/screwtool)
	return

/obj/item/organ/cyberimp/arm/shard/katana
	name = "dark shard"
	desc = "An eerie metal shard surrounded by dark energies."
	items_to_create = list(/obj/item/cursed_katana)

/obj/item/organ/cyberimp/arm/shard/katana/Retract()
	var/obj/item/cursed_katana/katana = active_item
	if(!katana || katana.shattered)
		return FALSE
	if(!katana.drew_blood)
		to_chat(owner, span_userdanger("[katana] lashes out at you in hunger!"))
		playsound(owner, 'sound/effects/magic/demon_attack1.ogg', 50, TRUE)
		owner.apply_damage(25, BRUTE, hand, wound_bonus = 10, sharpness = SHARP_EDGED)
	katana.drew_blood = FALSE
	katana.wash(CLEAN_TYPE_BLOOD)
	return ..()

#define ATTACK_STRIKE "Hilt Strike"
#define ATTACK_SLICE "Wide Slice"
#define ATTACK_DASH "Dash Attack"
#define ATTACK_CUT "Tendon Cut"
#define ATTACK_CLOAK "Dark Cloak"
#define ATTACK_SHATTER "Shatter"

/obj/item/cursed_katana
	name = "cursed katana"
	desc = "A katana used to seal something vile away long ago. \
	Even with the weapon destroyed, all the pieces containing the creature have coagulated back together to find a new host."
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "cursed_katana"
	icon_angle = -45
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 15
	armour_penetration = 30
	block_chance = 30
	block_sound = 'sound/items/weapons/parry.ogg'
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_HUGE
	attack_verb_continuous = list("attacks", "slashes", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "slice", "tear", "lacerate", "rip", "dice", "cut")
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | FREEZE_PROOF
	var/shattered = FALSE
	var/drew_blood = FALSE
	var/static/list/combo_list = list(
		ATTACK_STRIKE = list(COMBO_STEPS = list(LEFT_ATTACK, LEFT_ATTACK, RIGHT_ATTACK), COMBO_PROC = PROC_REF(strike)),
		ATTACK_SLICE = list(COMBO_STEPS = list(RIGHT_ATTACK, LEFT_ATTACK, LEFT_ATTACK), COMBO_PROC = PROC_REF(slice)),
		ATTACK_DASH = list(COMBO_STEPS = list(LEFT_ATTACK, RIGHT_ATTACK, RIGHT_ATTACK), COMBO_PROC = PROC_REF(dash)),
		ATTACK_CUT = list(COMBO_STEPS = list(RIGHT_ATTACK, RIGHT_ATTACK, LEFT_ATTACK), COMBO_PROC = PROC_REF(cut)),
		ATTACK_CLOAK = list(COMBO_STEPS = list(LEFT_ATTACK, RIGHT_ATTACK, LEFT_ATTACK, RIGHT_ATTACK), COMBO_PROC = PROC_REF(cloak)),
		ATTACK_SHATTER = list(COMBO_STEPS = list(RIGHT_ATTACK, LEFT_ATTACK, RIGHT_ATTACK, LEFT_ATTACK), COMBO_PROC = PROC_REF(shatter)),
	)
	var/list/alt_continuous = list("stabs", "pierces", "impales")
	var/list/alt_simple = list("stab", "pierce", "impale")

/obj/item/cursed_katana/Initialize(mapload)
	. = ..()
	alt_continuous = string_list(alt_continuous)
	alt_simple = string_list(alt_simple)
	AddComponent(/datum/component/alternative_sharpness, SHARP_POINTY, alt_continuous, alt_simple)
	AddComponent( \
		/datum/component/combo_attacks, \
		combos = combo_list, \
		max_combo_length = 4, \
		examine_message = span_notice("<i>There seem to be inscriptions on it... you could examine them closer?</i>"), \
		reset_message = "you return to neutral stance", \
		can_attack_callback = CALLBACK(src, PROC_REF(can_combo_attack)) \
	)

/obj/item/cursed_katana/examine(mob/user)
	. = ..()
	. += drew_blood ? span_nicegreen("It's sated... for now.") : span_danger("It will not be sated until it tastes blood.")

/obj/item/cursed_katana/dropped(mob/user)
	. = ..()
	if(isturf(loc))
		qdel(src)

/obj/item/cursed_katana/attack(mob/living/target, mob/user, click_parameters)
	if(target.stat < DEAD && target != user)
		drew_blood = TRUE
		if(ismining(target))
			user.changeNext_move(CLICK_CD_RAPID)
	return ..()

/obj/item/cursed_katana/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	if(attack_type == PROJECTILE_ATTACK || attack_type == LEAP_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight, and also you aren't going to really block someone full body tackling you with a sword
	return ..()

/obj/item/cursed_katana/proc/can_combo_attack(mob/user, mob/living/target)
	return target.stat != DEAD && target != user

/obj/item/cursed_katana/proc/strike(mob/living/target, mob/user)
	user.visible_message(span_warning("[user] strikes [target] with [src]'s hilt!"),
		span_notice("You hilt strike [target]!"))
	to_chat(target, span_userdanger("You've been struck by [user]!"))
	playsound(src, 'sound/items/weapons/genhit3.ogg', 50, TRUE)
	RegisterSignal(target, COMSIG_MOVABLE_IMPACT, PROC_REF(strike_throw_impact))
	var/atom/throw_target = get_edge_target_turf(target, user.dir)
	target.throw_at(throw_target, 5, 3, user, FALSE, gentle = TRUE)
	target.apply_damage(damage = 17, bare_wound_bonus = 10)
	to_chat(target, span_userdanger("You've been struck by [user]!"))
	user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)

/obj/item/cursed_katana/proc/strike_throw_impact(mob/living/source, atom/hit_atom, datum/thrownthing/thrownthing)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	if(isclosedturf(hit_atom))
		source.apply_damage(damage = 5)
		if(ishostile(source))
			var/mob/living/simple_animal/hostile/target = source
			target.ranged_cooldown += 5 SECONDS
		else if(iscarbon(source))
			var/mob/living/carbon/target = source
			target.set_confusion_if_lower(8 SECONDS)
	return NONE

/obj/item/cursed_katana/proc/slice(mob/living/target, mob/user)
	user.visible_message(span_warning("[user] does a wide slice!"),
		span_notice("You do a wide slice!"))
	playsound(src, 'sound/items/weapons/bladeslice.ogg', 50, TRUE)
	user.do_item_attack_animation(target, used_item = src, animation_type = ATTACK_ANIMATION_SLASH)
	var/turf/user_turf = get_turf(user)
	var/dir_to_target = get_dir(user_turf, get_turf(target))
	var/static/list/cursed_katana_slice_angles = list(0, -45, 45, -90, 90) //so that the animation animates towards the target clicked and not towards a side target
	for(var/iteration in cursed_katana_slice_angles)
		var/turf/turf = get_step(user_turf, turn(dir_to_target, iteration))
		user.do_attack_animation(turf, ATTACK_EFFECT_SLASH)
		for(var/mob/living/additional_target in turf)
			if(user.Adjacent(additional_target) && additional_target.density)
				additional_target.apply_damage(damage = 15, sharpness = SHARP_EDGED, bare_wound_bonus = 10)
				to_chat(additional_target, span_userdanger("You've been sliced by [user]!"))
	target.apply_damage(damage = 5, sharpness = SHARP_EDGED, wound_bonus = 10)

/obj/item/cursed_katana/proc/cloak(mob/living/target, mob/user)
	user.alpha = 150
	user.SetInvisibility(INVISIBILITY_OBSERVER, id=type) // so hostile mobs cant see us or target us
	user.add_sight(SEE_SELF) // so we can see us
	user.visible_message(span_warning("[user] vanishes into thin air!"),
		span_notice("You enter the dark cloak."))
	new /obj/effect/temp_visual/mook_dust(get_turf(src))
	playsound(src, 'sound/effects/magic/smoke.ogg', 50, TRUE)
	if(ishostile(target))
		var/mob/living/simple_animal/hostile/hostile_target = target
		if(hostile_target.target == user)
			hostile_target.LoseTarget()
	addtimer(CALLBACK(src, PROC_REF(uncloak), user), 5 SECONDS, TIMER_UNIQUE)

/obj/item/cursed_katana/proc/uncloak(mob/user)
	user.alpha = 255
	user.RemoveInvisibility(type)
	user.clear_sight(SEE_SELF)
	user.visible_message(span_warning("[user] appears from thin air!"),
		span_notice("You exit the dark cloak."))
	playsound(src, 'sound/effects/magic/summonitems_generic.ogg', 50, TRUE)
	new /obj/effect/temp_visual/mook_dust(get_turf(src))

/obj/item/cursed_katana/proc/cut(mob/living/target, mob/user)
	user.visible_message(span_warning("[user] cuts [target]'s tendons!"),
		span_notice("You tendon cut [target]!"))
	to_chat(target, span_userdanger("Your tendons have been cut by [user]!"))
	user.do_item_attack_animation(target, used_item = src, animation_type = ATTACK_ANIMATION_SLASH)
	target.apply_damage(damage = 15, sharpness = SHARP_EDGED, wound_bonus = 15)
	user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
	playsound(src, 'sound/items/weapons/rapierhit.ogg', 50, TRUE)
	var/datum/status_effect/stacking/saw_bleed/bloodletting/status = target.has_status_effect(/datum/status_effect/stacking/saw_bleed/bloodletting)
	if(!status)
		target.apply_status_effect(/datum/status_effect/stacking/saw_bleed/bloodletting, 6)
	else
		status.add_stacks(6)

/obj/item/cursed_katana/proc/dash(mob/living/target, mob/user)
	user.visible_message(span_warning("[user] dashes through [target]!"),
		span_notice("You dash through [target]!"))
	to_chat(target, span_userdanger("[user] dashes through you!"))
	playsound(src, 'sound/effects/magic/blink.ogg', 50, TRUE)
	target.apply_damage(damage = 17, sharpness = SHARP_POINTY, bare_wound_bonus = 10)
	var/turf/dash_target = get_turf(target)
	for(var/distance in 0 to 8)
		var/turf/current_dash_target = dash_target
		current_dash_target = get_step(current_dash_target, user.dir)
		if(!current_dash_target.is_blocked_turf(TRUE))
			dash_target = current_dash_target
		else
			break
	new /obj/effect/temp_visual/guardian/phase/out(get_turf(user))
	new /obj/effect/temp_visual/guardian/phase(dash_target)
	do_teleport(user, dash_target, channel = TELEPORT_CHANNEL_MAGIC)

/obj/item/cursed_katana/proc/shatter(mob/living/target, mob/user)
	user.visible_message(span_warning("[user] shatters [src] over [target]!"),
		span_notice("You shatter [src] over [target]!"))
	to_chat(target, span_userdanger("[user] shatters [src] over you!"))
	target.apply_damage(damage = ishostile(target) ? 75 : 35, wound_bonus = 20)
	user.do_attack_animation(target, ATTACK_EFFECT_SMASH)
	playsound(src, 'sound/effects/glass/glassbr3.ogg', 100, TRUE)
	shattered = TRUE
	moveToNullspace()
	balloon_alert(user, "katana shattered")
	addtimer(CALLBACK(src, PROC_REF(coagulate), user), 45 SECONDS)

/obj/item/cursed_katana/proc/coagulate(mob/user)
	balloon_alert(user, "katana coagulated")
	shattered = FALSE
	playsound(src, 'sound/effects/magic/demon_consume.ogg', 50, TRUE)

#undef ATTACK_STRIKE
#undef ATTACK_SLICE
#undef ATTACK_DASH
#undef ATTACK_CUT
#undef ATTACK_CLOAK
#undef ATTACK_SHATTER
