/// The designs Ratwood offers besides its patterns (caparison attack_right()): none, or a symbol.
#define ROGUE_CAPARISON_PLAIN "None"
#define ROGUE_CAPARISON_SYMBOL "Symbol"

/// Caparisons and bards (Ratwood rogueitems/caparison.dm, barding.dm; simple_animal.dm update_icon(), updatehealth(), attack_right(),
/// getarmor(), damage_clothes()): a saddled saiga takes a caparison for show and a bard for protection, each fitted over the saddle and taken
/// off before it. The bard is the mount's armour - one covering over the whole body, by the armour tiers of the module
/// (combat/armor.dm) - wears out under the blows it stops and slows the mount down, ridden or not. Both are drawn over the mount
/// from its own sheet, the caparison tinted with its colour and, if it bears a pattern or a symbol, that in a second colour; the
/// caparison is drawn under the bard or, adjusted (Alt+click on the mount, husbandry/mounts.dm), over it.
/obj/item/caparison
	/// State of the caparison in the mount's sheet (Ratwood caparison_state, female_caparison_state); "-above" is its front part.
	var/rogue_tack_state = "caparison"
	var/rogue_tack_female_state = "caparison-f"
	/// The mount it fits (Ratwood valid_animal_types); null - a mount that is not in the port.
	var/rogue_tack_fits = /mob/living/simple_animal/hostile/retaliate/rogue/saiga
	/// Ratwood detail_types and symbol_types: the patterns and the symbols it may bear, "name" = state suffix in the mount's sheet.
	var/list/rogue_detail_types
	var/list/rogue_symbol_types
	/// Ratwood detail_state and detail_color: the pattern or symbol it bears and its colour.
	var/rogue_detail_state
	var/rogue_detail_color

/obj/item/caparison/astrata
	rogue_tack_state = "astra_caparison"
	rogue_tack_female_state = "astra_caparison-f"

/obj/item/caparison/eora
	rogue_tack_state = "eora_caparison"
	rogue_tack_female_state = "eora_caparison-f"

/obj/item/caparison/psy
	rogue_tack_state = "psy_caparison"
	rogue_tack_female_state = "psy_caparison-f"

/obj/item/caparison/heartfelt
	rogue_tack_state = "heartfelt_caparison"
	rogue_tack_female_state = "heartfelt_caparison-f"

/// Ratwood's fogbeast is not ported. Its caparison is the one with patterns and symbols (in the fogbeast's sheet).
/obj/item/caparison/fogbeast
	rogue_tack_fits = null
	rogue_detail_types = list("Quad" = "quad")
	rogue_symbol_types = list("Psycross" = "psycross", "Astrata" = "astrata")

/obj/item/caparison/proc/rogue_tack_overlays(mob/living/basic/rockhill/mount, cover_layer)
	var/state = (mount.gender == FEMALE && rogue_tack_female_state) ? rogue_tack_female_state : rogue_tack_state
	. = list(
		rogue_tack_overlay(mount.icon, state, cover_layer, color),
		rogue_tack_overlay(mount.icon, "[state]-above", cover_layer - ROGUE_TACK_FRONT_DROP, color),
	)
	if(rogue_detail_state)
		. += rogue_tack_overlay(mount.icon, "[state]_[rogue_detail_state]", cover_layer, rogue_detail_color)
		. += rogue_tack_overlay(mount.icon, "[state]_[rogue_detail_state]-above", cover_layer - ROGUE_TACK_FRONT_DROP, rogue_detail_color)

/// Ratwood attack_right() and rmb_self(): a right click on a caparison in hand picks its pattern or symbol and its colours, if it can
/// bear any.
/obj/item/caparison/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if(. || !length(rogue_detail_types) || !isliving(user))
		return
	INVOKE_ASYNC(src, PROC_REF(rogue_pick_design), user)
	return TRUE

/// Ratwood attack_right(): a design - none, a pattern, or a symbol - then the main colour and, for a pattern, the second one (a symbol
/// is white), of Ratwood's dyes. Nothing changes unless every choice is made with the caparison still in hand.
/obj/item/caparison/proc/rogue_pick_design(mob/living/user)
	var/list/designs = list(ROGUE_CAPARISON_PLAIN) + rogue_detail_types
	if(length(rogue_symbol_types))
		designs += ROGUE_CAPARISON_SYMBOL
	var/design = tgui_input_list(user, "Select a design.", "Caparison Design", designs)
	if(!design || QDELETED(src) || !user.is_holding(src))
		return
	var/detail
	if(design == ROGUE_CAPARISON_SYMBOL)
		var/symbol = tgui_input_list(user, "Select a symbol.", "Caparison Design", rogue_symbol_types)
		if(!symbol || QDELETED(src) || !user.is_holding(src))
			return
		detail = rogue_symbol_types[symbol]
	else if(design != ROGUE_CAPARISON_PLAIN)
		detail = rogue_detail_types[design]
	var/primary = tgui_input_list(user, "Select a primary color.", "Caparison Design", GLOB.rogue_dye_colors)
	if(!primary || QDELETED(src) || !user.is_holding(src))
		return
	var/detail_color = COLOR_WHITE
	if(detail && design != ROGUE_CAPARISON_SYMBOL)
		var/secondary = tgui_input_list(user, "Select a secondary color.", "Caparison Design", GLOB.rogue_dye_colors)
		if(!secondary || QDELETED(src) || !user.is_holding(src))
			return
		detail_color = GLOB.rogue_dye_colors[secondary]
	add_atom_colour(GLOB.rogue_dye_colors[primary], FIXED_COLOUR_PRIORITY)
	rogue_detail_state = detail
	rogue_detail_color = detail ? detail_color : null
	to_chat(user, span_notice("I rework the design of [src]."))

/obj/item/clothing/barding
	/// State of the bard in the mount's sheet (Ratwood barding_state, female_barding_state); "-above" is its front part.
	var/rogue_tack_state = "barding"
	var/rogue_tack_female_state = "barding-f"
	/// The mount it fits (Ratwood valid_animal_types); null - a mount that is not in the port.
	var/rogue_tack_fits = /mob/living/simple_animal/hostile/retaliate/rogue/saiga
	/// Ratwood slowdown_factor: the mount's pace in it.
	var/rogue_slowdown = 1.1

/obj/item/clothing/barding/chain
	rogue_tack_state = "barding_chain"
	rogue_tack_female_state = "barding_chain-f"
	rogue_slowdown = 1.2

/// Ratwood's fogbeast is not ported.
/obj/item/clothing/barding/fogbeast
	rogue_tack_fits = null

/obj/item/clothing/barding/proc/rogue_tack_overlays(mob/living/basic/rockhill/mount, cover_layer)
	var/state = (mount.gender == FEMALE && rogue_tack_female_state) ? rogue_tack_female_state : rogue_tack_state
	return list(
		rogue_tack_overlay(mount.icon, state, cover_layer),
		rogue_tack_overlay(mount.icon, "[state]-above", cover_layer - ROGUE_TACK_FRONT_DROP),
	)

/// Ratwood caparison and barding attack(): what keeps a covering off this mount, said to the one fitting it.
/datum/component/rogue_mount/proc/cover_blocked(mob/living/user, obj/item/cover, fits, obj/item/worn, kind)
	var/mob/living/basic/rockhill/mount = parent
	if(!fits || !istype(mount, fits))
		to_chat(user, span_warning("\The [cover] cannot be used on [mount]! It is only meant for specific animals."))
		return TRUE
	if(worn)
		to_chat(user, span_warning("[mount] is already wearing a [kind]!"))
		return TRUE
	if(!saddle)
		to_chat(user, span_warning("[mount] needs to be saddled before you can fit a [kind] onto [mount.p_them()]!"))
		return TRUE
	if(user.buckled)
		to_chat(user, span_warning("You need to hop off [user.buckled] before you can drape [cover] on [mount]."))
		return TRUE
	return FALSE

/datum/component/rogue_mount/proc/fit_caparison(mob/living/user, obj/item/caparison/cover)
	var/mob/living/basic/rockhill/mount = parent
	if(cover_blocked(user, cover, cover.rogue_tack_fits, caparison, "caparison"))
		return
	user.visible_message(span_notice("[user] is fitting a caparison onto [mount]..."), span_notice("I start fitting a caparison onto [mount]..."))
	if(!do_after(user, ROGUE_TACK_TIME, target = mount) || caparison || !saddle || !user.is_holding(cover))
		return
	if(!user.transferItemToLoc(cover, mount))
		return
	caparison = cover
	mount.update_appearance(UPDATE_OVERLAYS)
	user.visible_message(span_notice("[user] fits a caparison onto [mount]."), span_notice("I fit a caparison onto [mount]."))

/datum/component/rogue_mount/proc/fit_barding(mob/living/user, obj/item/clothing/barding/bard)
	var/mob/living/basic/rockhill/mount = parent
	if(cover_blocked(user, bard, bard.rogue_tack_fits, barding, "bard"))
		return
	user.visible_message(span_notice("[user] is fitting a bard onto [mount]..."), span_notice("I start fitting a bard onto [mount]..."))
	if(!do_after(user, ROGUE_TACK_TIME, target = mount) || barding || !saddle || !user.is_holding(bard))
		return
	if(!user.transferItemToLoc(bard, mount))
		return
	barding = bard
	update_barding_pace()
	mount.update_appearance(UPDATE_OVERLAYS)
	user.visible_message(span_notice("[user] fits a bard onto [mount]."), span_notice("I fit a bard onto [mount]."))

/// Ratwood updatehealth(): a bard slows the mount's own pace too, not only its rider's (move_to_delay times barding_speed_mult) - its
/// pace without the bard, times the bard's slowdown.
/datum/component/rogue_mount/proc/update_barding_pace()
	var/mob/living/basic/rockhill/mount = parent
	mount.remove_movespeed_modifier(/datum/movespeed_modifier/rogue_barding)
	if(!barding || barding.rogue_slowdown <= 1 || mount.cached_multiplicative_slowdown <= 0)
		return
	mount.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/rogue_barding, multiplicative_slowdown = mount.cached_multiplicative_slowdown * (barding.rogue_slowdown - 1))

/datum/movespeed_modifier/rogue_barding
	variable = TRUE

/// Ratwood attack_right(): the caparison comes off first, then the bard.
/datum/component/rogue_mount/proc/take_off_cover(mob/living/user)
	var/mob/living/basic/rockhill/mount = parent
	var/obj/item/cover = caparison || barding
	var/kind = cover == caparison ? "caparison" : "bard"
	user.visible_message(span_notice("[user] is removing the [kind] from [mount]..."), span_notice("I start removing the [kind] from [mount]..."))
	if(!do_after(user, ROGUE_UNTACK_TIME, target = mount) || QDELETED(cover) || cover.loc != mount)
		return
	playsound(mount, 'modular_redtard/husbandry/sound/saddledismount.ogg', 100, FALSE)
	cover.forceMove(mount.drop_location())
	user.put_in_hands(cover)
	user.visible_message(span_notice("[user] removes the [kind] from [mount]."), span_notice("I remove the [kind] from [mount]."))

/// Share of a blow's damage that gets through the bard, wearing the bard on the way: the rules of rogue_armor_hit() for one
/// covering over the whole body. Blunt is absorbed whole by any blunt tier; slash and stab pass at or above the block tier, a
/// share by the penetration; piercing passes a fixed share at or above it. Burn and the like are left to the TG armour.
/datum/component/rogue_mount/proc/barding_share(armor_type, damage, penetration, wear_factor = 1)
	if(!barding || !armor_type || armor_type == ROGUE_ARMOR_FIRE || armor_type == ROGUE_ARMOR_ACID || armor_type == ROGUE_ARMOR_MAGIC)
		return 1
	var/datum/rogue_armor/armor = barding.get_rogue_armor()
	var/tier = armor?.get_rating(armor_type)
	if(!tier)
		return 1
	if(armor_type == ROGUE_ARMOR_BLUNT)
		barding.rogue_armor_wear(damage / (1 + ROGUE_ARMOR_BLUNT_DR * tier) * wear_factor)
		return 0
	var/share = 0
	if(armor_type == ROGUE_ARMOR_PIERCING)
		share = penetration >= tier ? ROGUE_PEN_PROJECTILE_PASSTHROUGH : 0
	else if(penetration >= tier && penetration > 0)
		share = min(ROGUE_PEN_PASSTHROUGH_MIN + penetration * ROGUE_PEN_PASSTHROUGH_PER_TIER, 1)
	if(!share)
		barding.rogue_armor_wear(damage * wear_factor)
	return share

/// Arrows, bolts, thrown things and the bites of beasts: the bard counts as the body's armour (Ratwood getarmor()). Our own
/// strikes run through it in rogue_take_strike() and are not counted twice.
/datum/component/rogue_mount/proc/on_damage_modifiers(mob/living/basic/rockhill/source, list/damage_mods, damage, damagetype, def_zone, sharpness, attack_direction, attacking_item)
	SIGNAL_HANDLER
	if(!barding || source.rogue_armor_resolved || !attacking_item)
		return
	var/armor_type = rogue_damage_armor_type(damagetype, sharpness, attacking_item)
	if(armor_type)
		damage_mods += barding_share(armor_type, damage, rogue_attack_penetration(attacking_item))

/// A blow of the module's combat on a mount in a bard: the bard takes it first, by the blow's intent and its penetration.
/mob/living/basic/rockhill/rogue_take_strike(datum/rogue_strike/strike)
	var/datum/component/rogue_mount/tack = GetComponent(/datum/component/rogue_mount)
	if(tack?.barding && (!strike.weapon || strike.weapon.damtype == BRUTE))
		strike.damage *= tack.barding_share(strike.intent.item_d_type, strike.damage, strike.intent.penfactor, rogue_wear_factor(strike.weapon, strike.intent))
	return ..()

#undef ROGUE_CAPARISON_PLAIN
#undef ROGUE_CAPARISON_SYMBOL
