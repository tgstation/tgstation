// Azure Peak's charged weapons and their specials (code/modules/mob/living/combat/special_intents.dm ignite_dagger,
// coat_blade, permafrost; rogueweapons/melee/knives.dm, swords.dm, axe/axes.dm), which Ratwood has not: the special charges
// the weapon itself for a while instead of striking around.
// - the fire dagger glows: its blows burn and land blunt;
// - "Bane's Edge" is coated in poison: its blows poison, weaker;
// - the deathfrost axe ices over: its cuts and chops frostbite (slower, stiff, tiring).
// Sprites from Azure Peak (combat/icons/azure_weapons32.dmi, azure_weapons64.dmi); the baked held and worn sprites are the
// steel dagger's, the sabre's and the battle axe's until bake_onmob_sheets.py bakes their own. The specials' numbers are in
// config/redtard/mechanics/values/specials.txt like every special's, the frostbite's in values/combat.txt, "Weapons and gear".

#define AZURE_FROSTBITE_COLOR "#88bfff"

/// What is held looks and strikes anew after a charge comes or goes.
/obj/item/proc/rogue_weapon_changed()
	update_appearance()
	var/mob/living/holder = loc
	if(istype(holder))
		holder.rogue_refresh_intents()
		holder.update_held_items()

// Ignite Dagger and the fire dagger.

/datum/special_intent/ignite_dagger
	name = "Ignite Dagger"
	desc = "Channel the power of the magycks within the dagger to heat it to an incredible degree."
	cooldown = 120 SECONDS
	stamcost = 25
	tunables = list("cooldown", "stamcost", "active_dur")
	var/active_dur = 20 SECONDS

/datum/special_intent/ignite_dagger/on_create()
	var/obj/item/rogueweapon/huntingknife/idagger/steel/fire/dagger = iparent
	if(istype(dagger))
		dagger.rogue_ignite(howner, tune("active_dur"))

/obj/item/rogueweapon/huntingknife/idagger/steel/fire
	name = "fire dagger"
	desc = "A dagger enchanted with lost arcyne arts to render it as Astrata's wrath, but only for a short duration."
	icon = 'modular_redtard/combat/icons/azure_weapons32.dmi'
	icon_state = "fdagger"
	inhand_icon_state = "sdagger"
	rogue_onmob_state = "sdagger"
	sheathe_icon = "sdagger"
	smeltresult = null
	special = /datum/special_intent/ignite_dagger
	/// Azure Peak active_intents: the glowing blade strikes blunt, and with fire.
	var/list/active_intents = list(/datum/intent/dagger/thrust/blunt, /datum/intent/dagger/cut/blunt, /datum/intent/dagger/thrust/pick/blunt, /datum/intent/dagger/sucker_punch)
	var/list/inactive_intents
	/// Burning until this timer runs out.
	var/rogue_charge_timer

/obj/item/rogueweapon/huntingknife/idagger/steel/fire/proc/rogue_ignite(mob/living/holder, duration)
	if(rogue_charge_timer)
		return FALSE
	holder?.visible_message(span_warning("[src]'s blade begins to glow intensely in [holder]'s grasp!"))
	damtype = BURN
	icon_state = "fdagger_active"
	inactive_intents = possible_item_intents
	possible_item_intents = active_intents
	rogue_charge_timer = addtimer(CALLBACK(src, PROC_REF(rogue_cool_down)), duration, TIMER_STOPPABLE)
	rogue_weapon_changed()
	playsound(src, 'modular_redtard/rockhill/sound/items/firelight.ogg', 100)
	return TRUE

/obj/item/rogueweapon/huntingknife/idagger/steel/fire/proc/rogue_cool_down()
	if(!rogue_charge_timer)
		return
	deltimer(rogue_charge_timer)
	rogue_charge_timer = null
	visible_message(span_warning("[src]'s blade cools down!"))
	damtype = BRUTE
	icon_state = initial(icon_state)
	if(inactive_intents)
		possible_item_intents = inactive_intents
	inactive_intents = null
	rogue_weapon_changed()
	playsound(src, 'modular_redtard/rockhill/sound/items/firesnuff.ogg', 100)

/// Azure Peak's blunt dagger intents of the training dagger, the burning dagger's blows.
/datum/intent/dagger/thrust/blunt
	blade_class = BCLASS_BLUNT
	penfactor = 0
	// Ratwood BLUNT_DEFAULT_INT_DAMAGEFACTOR.
	intent_intdamage_factor = 1.4
	hitsound = list('modular_redtard/rockhill/sound/combat/hits/blunt/metalblunt (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/blunt/metalblunt (2).ogg', 'modular_redtard/rockhill/sound/combat/hits/blunt/metalblunt (3).ogg')

/datum/intent/dagger/cut/blunt
	blade_class = BCLASS_BLUNT
	penfactor = 0
	intent_intdamage_factor = 1.4
	hitsound = list('modular_redtard/rockhill/sound/combat/hits/blunt/metalblunt (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/blunt/metalblunt (2).ogg', 'modular_redtard/rockhill/sound/combat/hits/blunt/metalblunt (3).ogg')

/datum/intent/dagger/thrust/pick/blunt
	blade_class = BCLASS_BLUNT

// Coat Blade and "Bane's Edge".

/datum/special_intent/coat_blade
	name = "Coat Blade"
	desc = "Channel the power of the magycks within this sabre to render it as toxic as it once was."
	cooldown = 120 SECONDS
	stamcost = 25
	tunables = list("cooldown", "stamcost", "active_dur", "force_loss")
	var/active_dur = 20 SECONDS
	/// Force the coated blade loses in one hand and wielded (Azure Peak force -= 15).
	var/force_loss = 15

/datum/special_intent/coat_blade/on_create()
	var/obj/item/rogueweapon/sword/sabre/bane/sabre = iparent
	if(istype(sabre))
		sabre.rogue_coat(howner, tune("active_dur"), tune("force_loss"))

/obj/item/rogueweapon/sword/sabre/bane
	name = "\"Bane's Edge\""
	desc = "A stained sabre made of blacksteel, its edge is coated in long-dried blood as well as poison."
	icon = 'modular_redtard/combat/icons/azure_weapons32.dmi'
	icon_state = "poisonsabre"
	inhand_icon_state = "saber"
	rogue_onmob_state = "saber"
	sheathe_icon = "saber"
	force = 25
	max_integrity = 200
	sellprice = 50
	smeltresult = null
	special = /datum/special_intent/coat_blade
	var/rogue_charge_timer
	/// Force the coating took, given back when it falls off.
	var/rogue_coat_force = 0

/obj/item/rogueweapon/sword/sabre/bane/proc/rogue_coat(mob/living/holder, duration, force_loss)
	if(rogue_charge_timer)
		return FALSE
	holder?.visible_message(span_warning("[src]'s blade forms a solid layer of poison in [holder]'s grasp!"))
	damtype = TOX
	rogue_coat_force = force_loss
	rogue_add_force(-force_loss)
	icon_state = "poisonsabre_active"
	rogue_charge_timer = addtimer(CALLBACK(src, PROC_REF(rogue_uncoat)), duration, TIMER_STOPPABLE)
	rogue_weapon_changed()
	playsound(src, 'modular_redtard/combat/sound/magic/lava_death.ogg', 100)
	return TRUE

/obj/item/rogueweapon/sword/sabre/bane/proc/rogue_uncoat()
	if(!rogue_charge_timer)
		return
	deltimer(rogue_charge_timer)
	rogue_charge_timer = null
	visible_message(span_warning("[src]'s coating of toxins falls to the dirt!"))
	damtype = BRUTE
	rogue_add_force(rogue_coat_force)
	rogue_coat_force = 0
	icon_state = initial(icon_state)
	rogue_weapon_changed()
	playsound(src, 'modular_redtard/combat/sound/magic/bladescrape.ogg', 100)

/// The coating falls off before the sabre breaks or mends, so the force it took is not lost (combat/integrity.dm).
/obj/item/rogueweapon/sword/sabre/bane/rogue_break()
	if(rogue_charge_timer)
		rogue_uncoat()
	return ..()

/obj/item/rogueweapon/sword/sabre/bane/rogue_mend()
	if(rogue_charge_timer)
		rogue_uncoat()
	return ..()

// Permafrost and the deathfrost axe.

/datum/special_intent/permafrost
	name = "Permafrost"
	desc = "Channel the deathly cold lingering in the blade's memory to spread it to your enemies."
	cooldown = 120 SECONDS
	stamcost = 25
	tunables = list("cooldown", "stamcost", "active_dur")
	var/active_dur = 20 SECONDS

/datum/special_intent/permafrost/on_create()
	var/obj/item/rogueweapon/stoneaxe/battle/ice/axe = iparent
	if(istype(axe))
		axe.rogue_freeze(howner, tune("active_dur"))

/obj/item/rogueweapon/stoneaxe/battle/ice
	name = "deathfrost axe"
	desc = "This axe's blade is as sharp as it is cold."
	icon = 'modular_redtard/combat/icons/azure_weapons64.dmi'
	icon_state = "iceaxe"
	inhand_icon_state = "battleaxe"
	rogue_onmob_state = "battleaxe"
	pixel_x = -16
	pixel_y = -16
	smeltresult = null
	special = /datum/special_intent/permafrost
	/// Azure Peak active_intents and active_gripped_intents: cuts and chops that frostbite.
	var/list/active_intents = list(/datum/intent/axe/cut/frost, /datum/intent/axe/chop/frost, /datum/intent/axe/bash)
	var/list/active_gripped_intents = list(/datum/intent/axe/cut/frost, /datum/intent/axe/chop/frost, /datum/intent/axe/bash)
	var/list/inactive_intents
	var/list/inactive_gripped_intents
	var/rogue_charge_timer

/obj/item/rogueweapon/stoneaxe/battle/ice/proc/rogue_freeze(mob/living/holder, duration)
	if(rogue_charge_timer)
		return FALSE
	holder?.visible_message(span_warning("[src]'s blade forms a layer of ice in [holder]'s grasp!"))
	icon_state = "iceaxeactive"
	inactive_intents = possible_item_intents
	inactive_gripped_intents = gripped_intents
	possible_item_intents = active_intents
	gripped_intents = active_gripped_intents
	rogue_charge_timer = addtimer(CALLBACK(src, PROC_REF(rogue_thaw)), duration, TIMER_STOPPABLE)
	rogue_weapon_changed()
	playsound(src, 'modular_redtard/combat/sound/magic/blade_burst.ogg', 100)
	return TRUE

/obj/item/rogueweapon/stoneaxe/battle/ice/proc/rogue_thaw()
	if(!rogue_charge_timer)
		return
	deltimer(rogue_charge_timer)
	rogue_charge_timer = null
	visible_message(span_warning("The ice covering [src]'s blade thaws out!"))
	icon_state = initial(icon_state)
	if(inactive_intents)
		possible_item_intents = inactive_intents
	if(inactive_gripped_intents)
		gripped_intents = inactive_gripped_intents
	inactive_intents = null
	inactive_gripped_intents = null
	rogue_weapon_changed()
	playsound(src, 'modular_redtard/combat/sound/items/waterenter.ogg', 100)

/// Azure Peak intent_effect of the frost intents: a landed cut or chop frostbites.
/obj/item/rogueweapon/stoneaxe/battle/ice/afterattack(atom/target, mob/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(!rogue_charge_timer || !isliving(target) || !ishuman(user))
		return
	var/mob/living/carbon/human/wielder = user
	var/datum/intent/intent = wielder.rogue_strike_intent(src)
	if(!istype(intent, /datum/intent/axe/cut/frost) && !istype(intent, /datum/intent/axe/chop/frost))
		return
	var/mob/living/struck = target
	struck.apply_status_effect(/datum/status_effect/rogue/frostbite)

/// Azure Peak's frost intents of the deathfrost axe (intent_effect /datum/status_effect/buff/frostbite).
/datum/intent/axe/cut/frost

/datum/intent/axe/chop/frost

/// Azure Peak's buff/frostbite (spells_status_effects.dm): a few seconds of frozen limbs - slower and less speed, a tint of
/// blue, breath drained every second until the victim is spent, which thaws it.
/datum/status_effect/rogue/frostbite
	id = "rogue_frostbite"
	tick_interval = 1 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/rogue/frostbite

/datum/status_effect/rogue/frostbite/on_creation(mob/living/new_owner, set_duration)
	base_duration = rogue_value("frostbite_duration")
	return ..()

/datum/status_effect/rogue/frostbite/on_apply()
	. = ..()
	owner.attributes?.set_variable_attribute_modifier(id, list(ROGUE_STAT_SPEED = rogue_value("frostbite_speed")))
	owner.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/rogue_frostbite, multiplicative_slowdown = rogue_value("frostbite_slowdown"))
	owner.add_atom_colour(AZURE_FROSTBITE_COLOR, TEMPORARY_COLOUR_PRIORITY)
	addtimer(CALLBACK(owner, TYPE_PROC_REF(/atom, remove_atom_colour), TEMPORARY_COLOUR_PRIORITY, AZURE_FROSTBITE_COLOR), rogue_value("frostbite_tint"))
	owner.adjust_stamina_loss(rogue_value("frostbite_stamina"))

/datum/status_effect/rogue/frostbite/tick(seconds_between_ticks)
	owner.adjust_stamina_loss(rogue_value("frostbite_stamina_tick") * seconds_between_ticks)
	if(owner.get_stamina_loss() >= owner.max_stamina)
		qdel(src)

/datum/status_effect/rogue/frostbite/on_remove()
	owner.attributes?.remove_attribute_modifier(id)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/rogue_frostbite)
	return ..()

/datum/movespeed_modifier/rogue_frostbite
	variable = TRUE
	movetypes = GROUND

/atom/movable/screen/alert/status_effect/rogue/frostbite
	name = "Frostbite"
	desc = "My limbs are frozen stiff!"
	icon_state = "debuff"

#undef AZURE_FROSTBITE_COLOR
