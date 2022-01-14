//This file contains loot you can obtain from tendril chests.

//KA modkit design discs
/obj/item/disk/design_disk/modkit_disc
	name = "KA Mod Disk"
	desc = "A design disc containing the design for a unique kinetic accelerator modkit. It's compatible with a research console."
	icon_state = "datadisk1"
	var/modkit_design = /datum/design/unique_modkit

/obj/item/disk/design_disk/modkit_disc/Initialize(mapload)
	. = ..()
	blueprints[1] = new modkit_design

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
	category = list("Mining Designs", "Cyborg Upgrade Modules") //can't be normally obtained
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/unique_modkit/offensive_turf_aoe
	name = "Kinetic Accelerator Offensive Mining Explosion Mod"
	desc = "A device which causes kinetic accelerators to fire AoE blasts that destroy rock and damage creatures."
	id = "hyperaoemod"
	materials = list(/datum/material/iron = 7000, /datum/material/glass = 3000, /datum/material/silver = 3000, /datum/material/gold = 3000, /datum/material/diamond = 4000)
	build_path = /obj/item/borg/upgrade/modkit/aoe/turfs/andmobs

/datum/design/unique_modkit/rapid_repeater
	name = "Kinetic Accelerator Rapid Repeater Mod"
	desc = "A device which greatly reduces a kinetic accelerator's cooldown on striking a living target or rock, but greatly increases its base cooldown."
	id = "repeatermod"
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 5000, /datum/material/uranium = 8000, /datum/material/bluespace = 2000)
	build_path = /obj/item/borg/upgrade/modkit/cooldown/repeater

/datum/design/unique_modkit/resonator_blast
	name = "Kinetic Accelerator Resonator Blast Mod"
	desc = "A device which causes kinetic accelerators to fire shots that leave and detonate resonator blasts."
	id = "resonatormod"
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 5000, /datum/material/silver = 5000, /datum/material/uranium = 5000)
	build_path = /obj/item/borg/upgrade/modkit/resonator_blasts

/datum/design/unique_modkit/bounty
	name = "Kinetic Accelerator Death Syphon Mod"
	desc = "A device which causes kinetic accelerators to permanently gain damage against creature types killed with it."
	id = "bountymod"
	materials = list(/datum/material/iron = 4000, /datum/material/silver = 4000, /datum/material/gold = 4000, /datum/material/bluespace = 4000)
	reagents_list = list(/datum/reagent/blood = 40)
	build_path = /obj/item/borg/upgrade/modkit/bounty

//Spooky special loot

//Rod of Asclepius
/obj/item/rod_of_asclepius
	name = "\improper Rod of Asclepius"
	desc = "A wooden rod about the size of your forearm with a snake carved around it, winding its way up the sides of the rod. Something about it seems to inspire in you the responsibilty and duty to help others."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	icon_state = "asclepius_dormant"
	var/activated = FALSE
	var/usedHand

/obj/item/rod_of_asclepius/attack_self(mob/user)
	if(activated)
		return
	if(!iscarbon(user))
		to_chat(user, span_warning("The snake carving seems to come alive, if only for a moment, before returning to its dormant state, almost as if it finds you incapable of holding its oath."))
		return
	var/mob/living/carbon/itemUser = user
	usedHand = itemUser.get_held_index_of_item(src)
	if(itemUser.has_status_effect(STATUS_EFFECT_HIPPOCRATIC_OATH))
		to_chat(user, span_warning("You can't possibly handle the responsibility of more than one rod!"))
		return
	var/failText = span_warning("The snake seems unsatisfied with your incomplete oath and returns to its previous place on the rod, returning to its dormant, wooden state. You must stand still while completing your oath!")
	to_chat(itemUser, span_notice("The wooden snake that was carved into the rod seems to suddenly come alive and begins to slither down your arm! The compulsion to help others grows abnormally strong..."))
	if(do_after(itemUser, 40, target = itemUser))
		itemUser.say("I swear to fulfill, to the best of my ability and judgment, this covenant:", forced = "hippocratic oath")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 20, target = itemUser))
		itemUser.say("I will apply, for the benefit of the sick, all measures that are required, avoiding those twin traps of overtreatment and therapeutic nihilism.", forced = "hippocratic oath")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 30, target = itemUser))
		itemUser.say("I will remember that I remain a member of society, with special obligations to all my fellow human beings, those sound of mind and body as well as the infirm.", forced = "hippocratic oath")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 30, target = itemUser))
		itemUser.say("If I do not violate this oath, may I enjoy life and art, respected while I live and remembered with affection thereafter. May I always act so as to preserve the finest traditions of my calling and may I long experience the joy of healing those who seek my help.", forced = "hippocratic oath")
	else
		to_chat(itemUser, failText)
		return
	to_chat(itemUser, span_notice("The snake, satisfied with your oath, attaches itself and the rod to your forearm with an inseparable grip. Your thoughts seem to only revolve around the core idea of helping others, and harm is nothing more than a distant, wicked memory..."))
	var/datum/status_effect/hippocratic_oath/effect = itemUser.apply_status_effect(STATUS_EFFECT_HIPPOCRATIC_OATH)
	effect.hand = usedHand
	activated()

/obj/item/rod_of_asclepius/proc/activated()
	item_flags = DROPDEL
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(type))
	desc = "A short wooden rod with a mystical snake inseparably gripping itself and the rod to your forearm. It flows with a healing energy that disperses amongst yourself and those around you. "
	icon_state = "asclepius_active"
	activated = TRUE

//Memento Mori
/obj/item/clothing/neck/necklace/memento_mori
	name = "Memento Mori"
	desc = "A mysterious pendant. An inscription on it says: \"Certain death tomorrow means certain life today.\""
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "memento_mori"
	worn_icon_state = "memento"
	actions_types = list(/datum/action/item_action/hands_free/memento_mori)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/mob/living/carbon/human/active_owner

/obj/item/clothing/neck/necklace/memento_mori/item_action_slot_check(slot)
	return slot == ITEM_SLOT_NECK

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
	if(do_after(user, 40, target = user))
		to_chat(user, span_notice("Your lifeforce is now linked to the pendant! You feel like removing it would kill you, and yet you instinctively know that until then, you won't die."))
		ADD_TRAIT(user, TRAIT_NODEATH, CLOTHING_TRAIT)
		ADD_TRAIT(user, TRAIT_NOHARDCRIT, CLOTHING_TRAIT)
		ADD_TRAIT(user, TRAIT_NOCRITDAMAGE, CLOTHING_TRAIT)
		RegisterSignal(user, COMSIG_CARBON_HEALTH_UPDATE, .proc/check_health)
		icon_state = "memento_mori_active"
		active_owner = user

/obj/item/clothing/neck/necklace/memento_mori/proc/mori()
	icon_state = "memento_mori"
	if(!active_owner)
		return
	UnregisterSignal(active_owner, COMSIG_CARBON_HEALTH_UPDATE)
	var/mob/living/carbon/human/H = active_owner //to avoid infinite looping when dust unequips the pendant
	active_owner = null
	to_chat(H, span_userdanger("You feel your life rapidly slipping away from you!"))
	H.dust(TRUE, TRUE)

/obj/item/clothing/neck/necklace/memento_mori/proc/check_health(mob/living/source)
	SIGNAL_HANDLER

	var/list/guardians = source.hasparasites()
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

/obj/item/clothing/neck/necklace/memento_mori/proc/consume_guardian(mob/living/simple_animal/hostile/guardian/guardian)
	new /obj/effect/temp_visual/guardian/phase/out(get_turf(guardian))
	guardian.locked = TRUE
	guardian.forceMove(src)
	to_chat(guardian, span_userdanger("You have been locked away in your summoner's pendant!"))
	guardian.playsound_local(get_turf(guardian), 'sound/magic/summonitems_generic.ogg', 50, TRUE)

/obj/item/clothing/neck/necklace/memento_mori/proc/regurgitate_guardian(mob/living/simple_animal/hostile/guardian/guardian)
	guardian.locked = FALSE
	guardian.Recall(TRUE)
	to_chat(guardian, span_notice("You have been returned back from your summoner's pendant!"))
	guardian.playsound_local(get_turf(guardian), 'sound/magic/repulse.ogg', 50, TRUE)

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
	icon_state = "lantern-blue"
	inhand_icon_state = "lantern"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	var/obj/effect/wisp/wisp

/obj/item/wisp_lantern/attack_self(mob/user)
	if(!wisp)
		to_chat(user, span_warning("The wisp has gone missing!"))
		icon_state = "lantern"
		return

	if(wisp.loc == src)
		to_chat(user, span_notice("You release the wisp. It begins to bob around your head."))
		icon_state = "lantern"
		wisp.orbit(user, 20)
		SSblackbox.record_feedback("tally", "wisp_lantern", 1, "Freed")

	else
		to_chat(user, span_notice("You return the wisp to the lantern."))
		icon_state = "lantern-blue"
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
	light_system = MOVABLE_LIGHT
	light_range = 7
	light_flags = LIGHT_ATTACHED
	layer = ABOVE_ALL_MOB_LAYER
	var/sight_flags = SEE_MOBS
	var/lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/effect/wisp/orbit(atom/thing, radius, clockwise, rotation_speed, rotation_segments, pre_rotation, lockinorbit)
	. = ..()
	if(ismob(thing))
		RegisterSignal(thing, COMSIG_MOB_UPDATE_SIGHT, .proc/update_user_sight)
		var/mob/being = thing
		being.update_sight()
		to_chat(thing, span_notice("The wisp enhances your vision."))

/obj/effect/wisp/stop_orbit(datum/component/orbiter/orbits)
	. = ..()
	if(ismob(orbits.parent))
		UnregisterSignal(orbits.parent, COMSIG_MOB_UPDATE_SIGHT)
		to_chat(orbits.parent, span_notice("Your vision returns to normal."))

/obj/effect/wisp/proc/update_user_sight(mob/user)
	SIGNAL_HANDLER
	user.sight |= sight_flags
	if(!isnull(lighting_alpha))
		user.lighting_alpha = min(user.lighting_alpha, lighting_alpha)

//Red/Blue Cubes
/obj/item/warp_cube
	name = "blue cube"
	desc = "A mysterious blue cube."
	icon = 'icons/obj/lavaland/artefacts.dmi'
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
	var/area/current_area = current_location.loc
	if(!linked || (current_area.area_flags & NOTELEPORT))
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
	sleep(2.5)
	if(QDELETED(user))
		qdel(link_holder)
		return
	if(QDELETED(linked))
		user.forceMove(get_turf(link_holder))
		qdel(link_holder)
		return
	link_holder.forceMove(get_turf(linked))
	sleep(2.5)
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
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "talisman"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	actions_types = list(/datum/action/item_action/immortality)
	var/cooldown = 0

/obj/item/immortality_talisman/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, TRUE, TRUE, TRUE)

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
	var/can_destroy = TRUE

/obj/effect/immortality_talisman/Initialize(mapload, mob/new_user)
	. = ..()
	if(new_user)
		vanish(new_user)

/obj/effect/immortality_talisman/proc/vanish(mob/user)
	user.visible_message(span_danger("[user] [vanish_description], leaving a hole in [user.p_their()] place!"))

	desc = "It's shaped an awful lot like [user.name]."
	setDir(user.dir)

	user.forceMove(src)
	user.notransform = TRUE
	user.status_flags |= GODMODE

	can_destroy = FALSE

	addtimer(CALLBACK(src, .proc/unvanish, user), 10 SECONDS)

/obj/effect/immortality_talisman/proc/unvanish(mob/user)
	user.status_flags &= ~GODMODE
	user.notransform = FALSE
	user.forceMove(get_turf(src))

	user.visible_message(span_danger("[user] pops back into reality!"))
	can_destroy = TRUE
	qdel(src)

/obj/effect/immortality_talisman/attackby()
	return

/obj/effect/immortality_talisman/singularity_pull()
	return

/obj/effect/immortality_talisman/Destroy(force)
	if(!can_destroy && !force)
		return QDEL_HINT_LETMELIVE
	else
		. = ..()

/obj/effect/immortality_talisman/void
	vanish_description = "is dragged into the void"

//Shared Bag

/obj/item/shared_storage
	name = "paradox bag"
	desc = "Somehow, it's in two places at once."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "paradox_bag"
	worn_icon_state = "paradoxbag"
	slot_flags = ITEM_SLOT_BELT
	resistance_flags = INDESTRUCTIBLE

/obj/item/shared_storage/red
	name = "paradox bag"
	desc = "Somehow, it's in two places at once."

/obj/item/shared_storage/red/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = AddComponent(/datum/component/storage/concrete)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 15
	STR.max_items = 21
	new /obj/item/shared_storage/blue(drop_location(), STR)

/obj/item/shared_storage/blue/Initialize(mapload, datum/component/storage/concrete/master)
	. = ..()
	if(!istype(master))
		return INITIALIZE_HINT_QDEL
	var/datum/component/storage/STR = AddComponent(/datum/component/storage, master)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 15
	STR.max_items = 21

//Book of Babel

/obj/item/book_of_babel
	name = "Book of Babel"
	desc = "An ancient tome written in countless tongues."
	icon = 'icons/obj/library.dmi'
	icon_state = "book1"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/book_of_babel/attack_self(mob/user)
	if(!user.can_read(src))
		return FALSE
	to_chat(user, span_notice("You flip through the pages of the book, quickly and conveniently learning every language in existence. Somewhat less conveniently, the aging book crumbles to dust in the process. Whoops."))
	user.grant_all_languages()
	new /obj/effect/decal/cleanable/ash(get_turf(user))
	qdel(src)


//Potion of Flight
/obj/item/reagent_containers/glass/bottle/potion
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "potionflask"

/obj/item/reagent_containers/glass/bottle/potion/flight
	name = "strange elixir"
	desc = "A flask with an almost-holy aura emitting from it. The label on the bottle says: 'erqo'hyy tvi'rf lbh jv'atf'."
	list_reagents = list(/datum/reagent/flightpotion = 5)

/obj/item/reagent_containers/glass/bottle/potion/update_icon_state()
	icon_state = "potionflask[reagents.total_volume ? null : "_empty"]"
	return ..()

/datum/reagent/flightpotion
	name = "Flight Potion"
	description = "Strange mutagenic compound of unknown origins."
	reagent_state = LIQUID
	color = "#FFEBEB"

/datum/reagent/flightpotion/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE)
	. = ..()
	if(iscarbon(exposed_mob) && exposed_mob.stat != DEAD)
		var/mob/living/carbon/exposed_carbon = exposed_mob
		var/holycheck = ishumanbasic(exposed_carbon)
		if(!HAS_TRAIT(exposed_carbon, TRAIT_CAN_USE_FLIGHT_POTION) || reac_volume < 5)
			if((methods & INGEST) && show_message)
				to_chat(exposed_carbon, span_notice("<i>You feel nothing but a terrible aftertaste.</i>"))
			return
		if(exposed_carbon.dna.species.has_innate_wings)
			to_chat(exposed_carbon, span_userdanger("A terrible pain travels down your back as your wings change shape!"))
		else
			to_chat(exposed_carbon, span_userdanger("A terrible pain travels down your back as wings burst out!"))
		exposed_carbon.dna.species.GiveSpeciesFlight(exposed_carbon)
		if(holycheck)
			to_chat(exposed_carbon, span_notice("You feel blessed!"))
			ADD_TRAIT(exposed_carbon, TRAIT_HOLY, FLIGHTPOTION_TRAIT)
		playsound(exposed_carbon.loc, 'sound/items/poster_ripped.ogg', 50, TRUE, -1)
		exposed_carbon.adjustBruteLoss(20)
		exposed_carbon.emote("scream")


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
	inhand_icon_state = "concussive_gauntlets"
	toolspeed = 0.1
	strip_delay = 40
	equip_delay_other = 20
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = LAVA_PROOF | FIRE_PROOF //they are from lavaland after all
	armor = list(MELEE = 15, BULLET = 25, LASER = 15, ENERGY = 15, BOMB = 100, BIO = 0, FIRE = 100, ACID = 30) //mostly bone bracer armor

/obj/item/clothing/gloves/gauntlets/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_GLOVES)
		tool_behaviour = TOOL_MINING
		RegisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, .proc/rocksmash)
		RegisterSignal(user, COMSIG_MOVABLE_BUMP, .proc/rocksmash)
	else
		stopmining(user)

/obj/item/clothing/gloves/gauntlets/dropped(mob/user)
	. = ..()
	stopmining(user)

/obj/item/clothing/gloves/gauntlets/proc/stopmining(mob/user)
	tool_behaviour = initial(tool_behaviour)
	UnregisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)
	UnregisterSignal(user, COMSIG_MOVABLE_BUMP)

/obj/item/clothing/gloves/gauntlets/proc/rocksmash(mob/living/carbon/human/H, atom/A, proximity)
	SIGNAL_HANDLER
	if(!istype(A, /turf/closed/mineral))
		return
	A.attackby(src, H)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/clothing/suit/hooded/berserker
	name = "berserker armor"
	desc = "Voices echo from the armor, driving the user insane. Is not space-proof."
	icon_state = "berserker"
	hoodtype = /obj/item/clothing/head/hooded/berserker
	armor = list(MELEE = 30, BULLET = 30, LASER = 10, ENERGY = 20, BOMB = 50, BIO = 100, FIRE = 100, ACID = 100)
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	resistance_flags = FIRE_PROOF
	clothing_flags = THICKMATERIAL
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/pickaxe, /obj/item/spear, /obj/item/organ/regenerative_core/legion, /obj/item/knife, /obj/item/kinetic_crusher, /obj/item/resonator, /obj/item/melee/cleaving_saw)

/obj/item/clothing/suit/hooded/berserker/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, TRUE, TRUE, TRUE, ITEM_SLOT_OCLOTHING)

#define MAX_BERSERK_CHARGE 100
#define PROJECTILE_HIT_MULTIPLIER 1.5
#define DAMAGE_TO_CHARGE_SCALE 0.75
#define CHARGE_DRAINED_PER_SECOND 5
#define BERSERK_MELEE_ARMOR_ADDED 50
#define BERSERK_ATTACK_SPEED_MODIFIER 0.25

/obj/item/clothing/head/hooded/berserker
	name = "berserker helmet"
	desc = "Peering into the eyes of the helmet is enough to seal damnation."
	icon_state = "berserker"
	armor = list(MELEE = 30, BULLET = 30, LASER = 10, ENERGY = 20, BOMB = 50, BIO = 100, FIRE = 100, ACID = 100)
	actions_types = list(/datum/action/item_action/berserk_mode)
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	clothing_flags = SNUG_FIT|THICKMATERIAL
	/// Current charge of berserk, goes from 0 to 100
	var/berserk_charge = 0
	/// Status of berserk
	var/berserk_active = FALSE

/obj/item/clothing/head/hooded/berserker/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, LOCKED_HELMET_TRAIT)

/obj/item/clothing/head/hooded/berserker/examine()
	. = ..()
	. += span_notice("Berserk mode is [berserk_charge]% charged.")

/obj/item/clothing/head/hooded/berserker/process(delta_time)
	if(berserk_active)
		berserk_charge = clamp(berserk_charge - CHARGE_DRAINED_PER_SECOND * delta_time, 0, MAX_BERSERK_CHARGE)
	if(!berserk_charge)
		if(ishuman(loc))
			end_berserk(loc)

/obj/item/clothing/head/hooded/berserker/dropped(mob/user)
	. = ..()
	end_berserk(user)

/obj/item/clothing/head/hooded/berserker/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(berserk_active)
		return
	var/berserk_value = damage * DAMAGE_TO_CHARGE_SCALE
	if(attack_type == PROJECTILE_ATTACK)
		berserk_value *= PROJECTILE_HIT_MULTIPLIER
	berserk_charge = clamp(round(berserk_charge + berserk_value), 0, MAX_BERSERK_CHARGE)
	if(berserk_charge >= MAX_BERSERK_CHARGE)
		to_chat(owner, span_notice("Berserk mode is fully charged."))
		balloon_alert(owner, "berserk charged")

/obj/item/clothing/head/hooded/berserker/IsReflect()
	if(berserk_active)
		return TRUE

/// Starts berserk, giving the wearer 50 melee armor, doubled attacking speed, NOGUNS trait, adding a color and giving them the berserk movespeed modifier
/obj/item/clothing/head/hooded/berserker/proc/berserk_mode(mob/living/carbon/human/user)
	to_chat(user, span_warning("You enter berserk mode."))
	playsound(user, 'sound/magic/staff_healing.ogg', 50)
	user.add_movespeed_modifier(/datum/movespeed_modifier/berserk)
	user.physiology.armor.melee += BERSERK_MELEE_ARMOR_ADDED
	user.next_move_modifier *= BERSERK_ATTACK_SPEED_MODIFIER
	user.add_atom_colour(COLOR_BUBBLEGUM_RED, TEMPORARY_COLOUR_PRIORITY)
	ADD_TRAIT(user, TRAIT_NOGUNS, BERSERK_TRAIT)
	ADD_TRAIT(src, TRAIT_NODROP, BERSERK_TRAIT)
	berserk_active = TRUE
	START_PROCESSING(SSobj, src)

/// Ends berserk, reverting the changes from the proc [berserk_mode]
/obj/item/clothing/head/hooded/berserker/proc/end_berserk(mob/living/carbon/human/user)
	if(!berserk_active)
		return
	berserk_active = FALSE
	if(QDELETED(user))
		return
	to_chat(user, span_warning("You exit berserk mode."))
	playsound(user, 'sound/magic/summonitems_generic.ogg', 50)
	user.remove_movespeed_modifier(/datum/movespeed_modifier/berserk)
	user.physiology.armor.melee -= BERSERK_MELEE_ARMOR_ADDED
	user.next_move_modifier /= BERSERK_ATTACK_SPEED_MODIFIER
	user.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_BUBBLEGUM_RED)
	REMOVE_TRAIT(user, TRAIT_NOGUNS, BERSERK_TRAIT)
	REMOVE_TRAIT(src, TRAIT_NODROP, BERSERK_TRAIT)
	STOP_PROCESSING(SSobj, src)

#undef MAX_BERSERK_CHARGE
#undef PROJECTILE_HIT_MULTIPLIER
#undef DAMAGE_TO_CHARGE_SCALE
#undef CHARGE_DRAINED_PER_SECOND
#undef BERSERK_MELEE_ARMOR_ADDED
#undef BERSERK_ATTACK_SPEED_MODIFIER

/obj/item/clothing/glasses/godeye
	name = "eye of god"
	desc = "A strange eye, said to have been torn from an omniscient creature that used to roam the wastes."
	icon_state = "godeye"
	inhand_icon_state = "godeye"
	vision_flags = SEE_TURFS
	darkness_view = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	custom_materials = null
	var/obj/effect/proc_holder/scan/scan

/obj/item/clothing/glasses/godeye/Initialize(mapload)
	. = ..()
	scan = new(src)

/obj/item/clothing/glasses/godeye/equipped(mob/living/user, slot)
	. = ..()
	if(ishuman(user) && slot == ITEM_SLOT_EYES)
		ADD_TRAIT(src, TRAIT_NODROP, EYE_OF_GOD_TRAIT)
		pain(user)
		user.AddAbility(scan)

/obj/item/clothing/glasses/godeye/dropped(mob/living/user)
	. = ..()
	// Behead someone, their "glasses" drop on the floor
	// and thus, the god eye should no longer be sticky
	REMOVE_TRAIT(src, TRAIT_NODROP, EYE_OF_GOD_TRAIT)
	user.RemoveAbility(scan)

/obj/item/clothing/glasses/godeye/proc/pain(mob/living/victim)
	to_chat(victim, span_userdanger("You experience blinding pain, as [src] burrows into your skull."))
	victim.emote("scream")
	victim.flash_act()

/obj/effect/proc_holder/scan
	name = "Scan"
	desc = "Scan an enemy, to get their location and stagger them, increasing their time between attacks."
	action_background_icon_state = "bg_clock"
	action_icon = 'icons/mob/actions/actions_items.dmi'
	action_icon_state = "scan"
	ranged_mousepointer = 'icons/effects/mouse_pointers/scan_target.dmi'
	var/cooldown_time = 45 SECONDS
	COOLDOWN_DECLARE(scan_cooldown)

/obj/effect/proc_holder/scan/on_lose(mob/living/user)
	remove_ranged_ability()

/obj/effect/proc_holder/scan/Click(location, control, params)
	. = ..()
	if(!isliving(usr))
		return TRUE
	var/mob/living/user = usr
	fire(user)

/obj/effect/proc_holder/scan/fire(mob/living/carbon/user)
	if(active)
		remove_ranged_ability(span_notice("Your eye relaxes."))
	else
		add_ranged_ability(user, span_notice("Your eye starts spinning fast. <B>Left-click a creature to scan it!</B>"), TRUE)

/obj/effect/proc_holder/scan/InterceptClickOn(mob/living/caller, params, atom/target)
	. = ..()
	if(.)
		return
	if(ranged_ability_user.stat)
		remove_ranged_ability()
		return
	if(!COOLDOWN_FINISHED(src, scan_cooldown))
		balloon_alert(ranged_ability_user, "not ready!")
		return
	if(!isliving(target) || target == ranged_ability_user)
		balloon_alert(ranged_ability_user, "invalid target!")
		return
	var/mob/living/living_target = target
	living_target.apply_status_effect(STATUS_EFFECT_STAGGER)
	var/datum/status_effect/agent_pinpointer/scan_pinpointer = ranged_ability_user.apply_status_effect(/datum/status_effect/agent_pinpointer/scan)
	scan_pinpointer.scan_target = living_target
	living_target.Jitter(5 SECONDS)
	to_chat(living_target, span_warning("You've been staggered!"))
	living_target.add_filter("scan", 2, list("type" = "outline", "color" = COLOR_YELLOW, "size" = 1))
	addtimer(CALLBACK(living_target, /atom/.proc/remove_filter, "scan"), 30 SECONDS)
	ranged_ability_user.playsound_local(get_turf(ranged_ability_user), 'sound/magic/smoke.ogg', 50, TRUE)
	balloon_alert(ranged_ability_user, "[living_target] scanned")
	COOLDOWN_START(src, scan_cooldown, cooldown_time)
	addtimer(CALLBACK(src, /atom/.proc/balloon_alert, ranged_ability_user, "scan recharged"), cooldown_time)
	remove_ranged_ability()
	return TRUE

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

/obj/item/organ/cyberimp/arm/katana
	name = "dark shard"
	desc = "An eerie metal shard surrounded by dark energies."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "cursed_katana_organ"
	status = ORGAN_ORGANIC
	organ_flags = ORGAN_FROZEN|ORGAN_UNREMOVABLE
	items_to_create = list(/obj/item/cursed_katana)
	extend_sound = 'sound/items/unsheath.ogg'
	retract_sound = 'sound/items/sheath.ogg'

/obj/item/organ/cyberimp/arm/katana/attack_self(mob/user, modifiers)
	. = ..()
	to_chat(user, span_userdanger("The mass goes up your arm and goes inside it!"))
	playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)
	var/index = user.get_held_index_of_item(src)
	zone = (index == LEFT_HANDS ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM)
	SetSlotFromZone()
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	Insert(user)

/obj/item/organ/cyberimp/arm/katana/screwdriver_act(mob/living/user, obj/item/screwtool)
	return

/obj/item/organ/cyberimp/arm/katana/Retract()
	var/obj/item/cursed_katana/katana = active_item
	if(!katana || katana.shattered)
		return
	if(!katana.drew_blood)
		to_chat(owner, span_userdanger("[katana] lashes out at you in hunger!"))
		playsound(owner, 'sound/magic/demon_attack1.ogg', 50, TRUE)
		var/obj/item/bodypart/part = owner.get_holding_bodypart_of_item(katana)
		if(part)
			part.receive_damage(brute = 25, wound_bonus = 10, sharpness = SHARP_EDGED)
	katana.drew_blood = FALSE
	katana.wash(CLEAN_TYPE_BLOOD)
	return ..()

#define LEFT_SLASH "Left Slash"
#define RIGHT_SLASH "Right Slash"
#define COMBO_STEPS "steps"
#define COMBO_PROC "proc"
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
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "cursed_katana"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 15
	armour_penetration = 30
	block_chance = 30
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_HUGE
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | FREEZE_PROOF
	var/shattered = FALSE
	var/drew_blood = FALSE
	var/timerid
	var/list/input_list = list()
	var/list/combo_strings = list()
	var/static/list/combo_list = list(
		ATTACK_STRIKE = list(COMBO_STEPS = list(LEFT_SLASH, LEFT_SLASH, RIGHT_SLASH), COMBO_PROC = .proc/strike),
		ATTACK_SLICE = list(COMBO_STEPS = list(RIGHT_SLASH, LEFT_SLASH, LEFT_SLASH), COMBO_PROC = .proc/slice),
		ATTACK_DASH = list(COMBO_STEPS = list(LEFT_SLASH, RIGHT_SLASH, RIGHT_SLASH), COMBO_PROC = .proc/dash),
		ATTACK_CUT = list(COMBO_STEPS = list(RIGHT_SLASH, RIGHT_SLASH, LEFT_SLASH), COMBO_PROC = .proc/cut),
		ATTACK_CLOAK = list(COMBO_STEPS = list(LEFT_SLASH, RIGHT_SLASH, LEFT_SLASH, RIGHT_SLASH), COMBO_PROC = .proc/cloak),
		ATTACK_SHATTER = list(COMBO_STEPS = list(RIGHT_SLASH, LEFT_SLASH, RIGHT_SLASH, LEFT_SLASH), COMBO_PROC = .proc/shatter),
		)

/obj/item/cursed_katana/Initialize(mapload)
	. = ..()
	for(var/combo in combo_list)
		var/list/combo_specifics = combo_list[combo]
		var/step_string = english_list(combo_specifics[COMBO_STEPS])
		combo_strings += span_notice("<b>[combo]</b> - [step_string]")

/obj/item/cursed_katana/examine(mob/user)
	. = ..()
	. += drew_blood ? span_nicegreen("It's sated... for now.") : span_danger("It will not be sated until it tastes blood.")
	. += span_notice("<i>There seem to be inscriptions on it... you could examine them closer?</i>")

/obj/item/cursed_katana/examine_more(mob/user)
	. = ..()
	. += combo_strings

/obj/item/cursed_katana/dropped(mob/user)
	. = ..()
	reset_inputs(null, TRUE)
	if(isturf(loc))
		qdel(src)

/obj/item/cursed_katana/attack_self(mob/user)
	. = ..()
	reset_inputs(user, TRUE)

/obj/item/cursed_katana/attack(mob/living/target, mob/user, click_parameters)
	if(target.stat == DEAD || target == user)
		return ..()
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		balloon_alert(user, "you don't want to harm!")
		return
	drew_blood = TRUE
	var/list/modifiers = params2list(click_parameters)
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		input_list += RIGHT_SLASH
	if(LAZYACCESS(modifiers, LEFT_CLICK))
		input_list += LEFT_SLASH
	if(ishostile(target))
		user.changeNext_move(CLICK_CD_RAPID)
	if(length(input_list) > 4)
		reset_inputs(user, TRUE)
	if(check_input(target, user))
		reset_inputs(null, TRUE)
		return TRUE
	else
		timerid = addtimer(CALLBACK(src, .proc/reset_inputs, user, FALSE), 5 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
		return ..()

/obj/item/cursed_katana/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight
	return ..()

/obj/item/cursed_katana/proc/check_input(mob/living/target, mob/user)
	for(var/combo in combo_list)
		var/list/combo_specifics = combo_list[combo]
		if(compare_list(input_list,combo_specifics[COMBO_STEPS]))
			INVOKE_ASYNC(src, combo_specifics[COMBO_PROC], target, user)
			return TRUE
	return FALSE

/obj/item/cursed_katana/proc/reset_inputs(mob/user, deltimer)
	input_list.Cut()
	if(user)
		balloon_alert(user, "you return to neutral stance")
	if(deltimer && timerid)
		deltimer(timerid)

/obj/item/cursed_katana/proc/strike(mob/living/target, mob/user)
	user.visible_message(span_warning("[user] strikes [target] with [src]'s hilt!"),
		span_notice("You hilt strike [target]!"))
	to_chat(target, span_userdanger("You've been struck by [user]!"))
	playsound(src, 'sound/weapons/genhit3.ogg', 50, TRUE)
	RegisterSignal(target, COMSIG_MOVABLE_IMPACT, .proc/strike_throw_impact)
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
			target.set_confusion(max(target.get_confusion(), 8))
	return NONE

/obj/item/cursed_katana/proc/slice(mob/living/target, mob/user)
	user.visible_message(span_warning("[user] does a wide slice!"),
		span_notice("You do a wide slice!"))
	playsound(src, 'sound/weapons/bladeslice.ogg', 50, TRUE)
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
	user.invisibility = INVISIBILITY_OBSERVER // so hostile mobs cant see us or target us
	user.sight |= SEE_SELF // so we can see us
	user.visible_message(span_warning("[user] vanishes into thin air!"),
		span_notice("You enter the dark cloak."))
	playsound(src, 'sound/magic/smoke.ogg', 50, TRUE)
	if(ishostile(target))
		var/mob/living/simple_animal/hostile/hostile_target = target
		hostile_target.LoseTarget()
	addtimer(CALLBACK(src, .proc/uncloak, user), 5 SECONDS, TIMER_UNIQUE)

/obj/item/cursed_katana/proc/uncloak(mob/user)
	user.alpha = 255
	user.invisibility = 0
	user.sight &= ~SEE_SELF
	user.visible_message(span_warning("[user] appears from thin air!"),
		span_notice("You exit the dark cloak."))
	playsound(src, 'sound/magic/summonitems_generic.ogg', 50, TRUE)

/obj/item/cursed_katana/proc/cut(mob/living/target, mob/user)
	user.visible_message(span_warning("[user] cuts [target]'s tendons!"),
		span_notice("You tendon cut [target]!"))
	to_chat(target, span_userdanger("Your tendons have been cut by [user]!"))
	target.apply_damage(damage = 15, sharpness = SHARP_EDGED, wound_bonus = 15)
	user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
	playsound(src, 'sound/weapons/rapierhit.ogg', 50, TRUE)
	var/datum/status_effect/stacking/saw_bleed/bloodletting/status = target.has_status_effect(/datum/status_effect/stacking/saw_bleed/bloodletting)
	if(!status)
		target.apply_status_effect(/datum/status_effect/stacking/saw_bleed/bloodletting, 6)
	else
		status.add_stacks(6)

/obj/item/cursed_katana/proc/dash(mob/living/target, mob/user)
	user.visible_message(span_warning("[user] dashes through [target]!"),
		span_notice("You dash through [target]!"))
	to_chat(target, span_userdanger("[user] dashes through you!"))
	playsound(src, 'sound/magic/blink.ogg', 50, TRUE)
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
	playsound(src, 'sound/effects/glassbr3.ogg', 100, TRUE)
	shattered = TRUE
	moveToNullspace()
	balloon_alert(user, "katana shattered")
	addtimer(CALLBACK(src, .proc/coagulate, user), 45 SECONDS)

/obj/item/cursed_katana/proc/coagulate(mob/user)
	balloon_alert(user, "katana coagulated")
	shattered = FALSE
	playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)

#undef LEFT_SLASH
#undef RIGHT_SLASH
#undef COMBO_STEPS
#undef COMBO_PROC
#undef ATTACK_STRIKE
#undef ATTACK_SLICE
#undef ATTACK_DASH
#undef ATTACK_CUT
#undef ATTACK_CLOAK
#undef ATTACK_SHATTER
