// KA modkit design discs

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

// Wisp Lantern
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
	. = ..()

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
	var/static/list/color_cutoffs = list(10, 25, 25)

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

// Jacob's ladder

/obj/item/jacobs_ladder
	name = "jacob's ladder"
	desc = "A celestial ladder that violates the laws of physics."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder00"

/obj/item/jacobs_ladder/attack_self(mob/user)
	var/turf/our_loc = get_turf(src)
	var/ladder_x = our_loc.x
	var/ladder_y = our_loc.y
	to_chat(user, span_notice("You unfold the ladder. It extends much farther than you were expecting."))
	var/last_ladder = null
	for(var/i in 1 to world.maxz)
		if(is_centcom_level(i) || is_reserved_level(i) || is_away_level(i))
			continue
		var/turf/new_loc = locate(ladder_x, ladder_y, i)
		last_ladder = new /obj/structure/ladder/unbreakable/jacob(new_loc, null, last_ladder)
	qdel(src)

// Inherit from unbreakable but don't set ID, to suppress the default Z linkage
/obj/structure/ladder/unbreakable/jacob
	name = "jacob's ladder"
	desc = "An indestructible celestial ladder that violates the laws of physics."

// Book of Babel

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


// Potion of Flight

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
	var/had_wings = exposed_human.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
	var/wing_type = get_wing_choice(exposed_human, chest)
	if(!wing_type)
		return
	var/obj/item/organ/wings/functional/wings = new wing_type()
	wings.Insert(exposed_human)
	if(had_wings)
		to_chat(exposed_human, span_userdanger("A terrible pain travels down your back as your wings change shape!"))
	else
		to_chat(exposed_human, span_userdanger("A terrible pain travels down your back as wings burst out!"))
	playsound(exposed_human.loc, 'sound/items/poster/poster_ripped.ogg', 50, TRUE, -1)
	exposed_human.apply_damage(20, def_zone = BODY_ZONE_CHEST, forced = TRUE, wound_bonus = CANT_WOUND)
	exposed_human.emote("scream")

/datum/reagent/flightpotion/proc/get_wing_choice(mob/living/carbon/human/needs_wings, obj/item/bodypart/chest/chest)
	var/list/wing_types = chest.wing_types.Copy()
	if (wing_types.len == 1 || !needs_wings.client)
		return wing_types[1]
	var/list/radial_wings = list()
	var/list/name2type = list()
	for(var/obj/item/organ/wings/functional/possible_type as anything in wing_types)
		var/datum/sprite_accessory/accessory = initial(possible_type.sprite_accessory_override) //get the type
		accessory = SSaccessories.wings_list[initial(accessory.name)] //get the singleton instance
		var/image/img = image(icon = accessory.icon, icon_state = "m_wingsopen_[accessory.icon_state]_BEHIND") //Process the HUD elements
		img.transform *= 0.5
		img.pixel_w = -32
		if(radial_wings[accessory.name])
			stack_trace("Different wing types with repeated names. Please fix as this may cause issues.")
		else
			radial_wings[accessory.name] = img
			name2type[accessory.name] = possible_type
	var/wing_name = show_radial_menu(needs_wings, needs_wings, radial_wings, tooltips = TRUE)
	var/wing_type = name2type[wing_name]
	// If our chest gets replaced in the meanwile this can end up breaking, so we need to re-fetch it just to make sure
	var/obj/item/bodypart/chest/new_chest = needs_wings.get_bodypart(BODY_ZONE_CHEST)
	if(new_chest != chest)
		chest = new_chest
		wing_type = null
	if(!wing_type)
		if(!length(chest.wing_types))
			return
		wing_type = pick(chest.wing_types)
	return wing_type
