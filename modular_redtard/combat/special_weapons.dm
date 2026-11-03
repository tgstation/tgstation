// Ratwood's weapons with procedures of their own, which the porter brings as plain data (rogueweapons/melee/special.dm,
// polearms/polearms.dm, polearms/lance.dm, swords/swords.dm, swords/greatswords.dm, rogueweapons/shields.dm):
// - the master's rod and the staff of the shepherd: their electrocute (smite) and silence intents strike a subject of the
//   realm within seven paces, for their rightful holder and inside their own place;
// - the stunmace: switched on in hand, it drains a struck foe's energy and shocks one who is spent, on its own charge;
// - the militia spear: a clump of hay wound round its head, lit at a fire, sets the next one it strikes ablaze;
// - the "Daemonslayer" swats arrows and thrown things aside like a shield of its coverage;
// - the blacksteel weapons: their special may be chosen once, right-clicking them with a free hand;
// - the lances, the blacksteel halberd and eagle's beak and the bronze spears take a banner of cloth in a colour;
// - "Terminus Est" is wiped clean with its rag (right-click with it in hand);
// - the bucklers parry with the skill of the weapon in the active hand.
// The ducal standard is in combat/keep_standard.dm. Numbers in config/redtard/mechanics/values/combat.txt, "Weapons and gear".

#define SPECIAL_ROD_RANGE rogue_value("rod_range")
#define SPECIAL_ROD_SHOCK rogue_value("rod_shock_damage")
#define SPECIAL_ROD_SILENCE rogue_value("rod_silence")
#define SPECIAL_SCEPTER_SHOCK_COOLDOWN rogue_value("scepter_shock_cooldown")
#define SPECIAL_SCEPTER_SILENCE_COOLDOWN rogue_value("scepter_silence_cooldown")
#define SPECIAL_STAFF_SMITE_COOLDOWN rogue_value("aries_smite_cooldown")
#define SPECIAL_STAFF_SILENCE_COOLDOWN rogue_value("aries_silence_cooldown")
#define SPECIAL_STAFF_SMITE_FIRE rogue_value("aries_smite_fire_stacks")
#define SPECIAL_STUNMACE_CHARGE rogue_value("stunmace_charge")
#define SPECIAL_STUNMACE_LOW_CHARGE rogue_value("stunmace_low_charge")
#define SPECIAL_STUNMACE_FORCE rogue_value("stunmace_on_force")
#define SPECIAL_STUNMACE_DRAIN rogue_value("stunmace_drain")
#define SPECIAL_STUNMACE_RECHARGE rogue_value("stunmace_recharge")
#define SPECIAL_STUNMACE_SHOCK rogue_value("stunmace_shock_damage")
#define SPECIAL_STUNMACE_SHOCK_COST rogue_value("stunmace_shock_cost")
#define SPECIAL_STUNMACE_SAP_COST rogue_value("stunmace_sap_cost")
#define SPECIAL_STUNMACE_ENERGY rogue_value("stunmace_energy_drain")
#define SPECIAL_STUNMACE_STAMINA rogue_value("stunmace_stamina")
#define SPECIAL_MILITIA_FIRE_STACKS rogue_value("militia_spear_fire_stacks")
#define SPECIAL_STUNMACE_TOGGLE_SOUNDS list('modular_redtard/combat/sound/items/stunmace_toggle (1).ogg', 'modular_redtard/combat/sound/items/stunmace_toggle (2).ogg', 'modular_redtard/combat/sound/items/stunmace_toggle (3).ogg')
#define SPECIAL_STUNMACE_HIT_SOUNDS list('modular_redtard/combat/sound/items/stunmace_hit (1).ogg', 'modular_redtard/combat/sound/items/stunmace_hit (2).ogg')
#define SPECIAL_CLOTH_WIPE_SOUNDS list('modular_redtard/combat/sound/items/cloth_wipe (1).ogg', 'modular_redtard/combat/sound/items/cloth_wipe (2).ogg', 'modular_redtard/combat/sound/items/cloth_wipe (3).ogg')

// The master's rod and the staff of the shepherd (Ratwood afterattack()).

/obj/item/rogueweapon
	/// Ratwood COOLDOWN_DECLARE(scepter) of the master's rod and the staff of the shepherd.
	COOLDOWN_DECLARE(rogue_rod_cooldown)

/// The rod's power on target with the holder's intent: NONE when the intent is not one of the rod's own, so the click goes
/// on as a blow or nothing.
/obj/item/rogueweapon/proc/rogue_rod_power(atom/target, mob/living/user)
	return NONE

/// Ratwood's checks common to both rods; the rod's effects follow in rogue_rod_power(). Returns the subject, or null.
/obj/item/rogueweapon/proc/rogue_rod_subject(atom/target, mob/living/user, owner_title, refusal, list/places, place_refusal)
	user.changeNext_move(CLICK_CD_MELEE)
	if(user.mind?.assigned_role?.title != owner_title)
		to_chat(user, refusal)
		return null
	var/mob/living/carbon/human/subject = target
	if(!istype(subject) || subject == user)
		return null
	var/area/place = get_area(subject)
	if(!is_type_in_typecache(place, places))
		to_chat(user, span_danger(place_refusal))
		return null
	if(!COOLDOWN_FINISHED(src, rogue_rod_cooldown))
		to_chat(user, span_danger("\The [src] is not ready yet! [round(COOLDOWN_TIMELEFT(src, rogue_rod_cooldown) / 10, 1)] seconds left!"))
		return null
	if(subject.can_block_magic(MAGIC_RESISTANCE))
		to_chat(user, span_danger("Something is disrupting the rod's power!"))
		return null
	// Ratwood: only someone with a NERVELOCK account, no stunlocking the realm's enemies.
	if(!SSrogue_treasury.get_account(subject))
		to_chat(user, span_danger("The target must have a Nervelock account!"))
		return null
	return subject

/obj/item/rogueweapon/lordscepter/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = rogue_rod_power(interacting_with, user)
	if(!.)
		return ..()

/obj/item/rogueweapon/lordscepter/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = rogue_rod_power(interacting_with, user)
	if(!.)
		return ..()

/// Ratwood's master's rod: the Grand Duke electrocutes or silences someone inside the manor.
/obj/item/rogueweapon/lordscepter/rogue_rod_power(atom/target, mob/living/user)
	var/mob/living/carbon/human/wielder = user
	if(!istype(wielder))
		return NONE
	var/datum/intent/intent = wielder.rogue_strike_intent(src)
	var/shock = istype(intent, /datum/intent/lord_electrocute)
	if(!shock && !istype(intent, /datum/intent/lord_silence))
		return NONE
	if(get_dist(user, target) > SPECIAL_ROD_RANGE)
		return ITEM_INTERACT_BLOCKING
	var/static/list/manor = typecacheof(/area/rogue/indoors/town/manor)
	var/mob/living/carbon/human/subject = rogue_rod_subject(target, user, JOB_ROCKHILL_GRAND_DUKE, span_danger("The rod doesn't obey me."), manor, "The rod cannot be used on targets outside of the manor!")
	if(!subject)
		return ITEM_INTERACT_BLOCKING
	if(shock)
		user.visible_message(span_warning("[user] electrocutes [subject] with \the [src]."))
		user.Beam(subject, icon_state = "lightning[rand(1, 12)]", time = 0.5 SECONDS)
		subject.electrocute_act(SPECIAL_ROD_SHOCK, src)
		COOLDOWN_START(src, rogue_rod_cooldown, SPECIAL_SCEPTER_SHOCK_COOLDOWN)
		to_chat(subject, span_danger("I'm electrocuted by the scepter!"))
	else
		user.visible_message(span_warning("[user] silences [subject] with \the [src]."))
		subject.set_silence(SPECIAL_ROD_SILENCE)
		COOLDOWN_START(src, rogue_rod_cooldown, SPECIAL_SCEPTER_SILENCE_COOLDOWN)
		to_chat(subject, span_danger("I'm silenced by the scepter!"))
	log_combat(user, subject, shock ? "electrocuted" : "silenced", src)
	return ITEM_INTERACT_SUCCESS

/obj/item/rogueweapon/woodstaff/aries/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = rogue_rod_power(interacting_with, user)
	if(!.)
		return ..()

/obj/item/rogueweapon/woodstaff/aries/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = rogue_rod_power(interacting_with, user)
	if(!.)
		return ..()

/// Ratwood's staff of the shepherd: the Bishop smites (shock and holy fire) or silences someone on hallowed ground.
/obj/item/rogueweapon/woodstaff/aries/rogue_rod_power(atom/target, mob/living/user)
	var/mob/living/carbon/human/wielder = user
	if(!istype(wielder))
		return NONE
	var/datum/intent/intent = wielder.rogue_strike_intent(src)
	var/smite = istype(intent, /datum/intent/priest_smite)
	if(!smite && !istype(intent, /datum/intent/priest_silence))
		return NONE
	if(get_dist(user, target) > SPECIAL_ROD_RANGE)
		return ITEM_INTERACT_BLOCKING
	// Ratwood holy_area: the church, its roof and the graveyard.
	var/static/list/hallowed = typecacheof(list(/area/rogue/indoors/town/church, /area/rogue/outdoors/town/roofs/church, /area/rogue/outdoors/town/graveyard))
	var/mob/living/carbon/human/subject = rogue_rod_subject(target, user, JOB_ROCKHILL_BISHOP, "<font color='yellow'>THIS IS NOT YOURS.</font>", hallowed, "The staff cannot be used on targets outside of the church!")
	if(!subject)
		return ITEM_INTERACT_BLOCKING
	if(smite)
		user.visible_message(span_warning("[user] smites [subject] with \the [src]!"))
		user.Beam(subject, icon_state = "lightning[rand(1, 12)]", time = 0.5 SECONDS)
		subject.electrocute_act(SPECIAL_ROD_SHOCK, src)
		COOLDOWN_START(src, rogue_rod_cooldown, SPECIAL_STAFF_SMITE_COOLDOWN)
		subject.adjust_fire_stacks(SPECIAL_STAFF_SMITE_FIRE)
		subject.ignite_mob()
		to_chat(subject, span_danger("I'm smote by divine power!"))
	else
		user.visible_message(span_warning("[user] silences [subject] with \the [src]."))
		subject.set_silence(SPECIAL_ROD_SILENCE)
		COOLDOWN_START(src, rogue_rod_cooldown, SPECIAL_STAFF_SILENCE_COOLDOWN)
		to_chat(subject, span_danger("I'm silenced by divine power!"))
	log_combat(user, subject, smite ? "smote" : "silenced", src)
	return ITEM_INTERACT_SUCCESS

// The stunmace (Ratwood melee/special.dm).

/obj/item/rogueweapon/mace/stunmace
	// Ratwood's stunmace is one-handed (gripped_intents = null); the porter leaves it the mace's grip.
	gripped_intents = null
	rogue_force_wielded = 0
	/// Ratwood charge: spent while switched on and by every jolt, regained while off.
	var/charge
	/// Switched on (Ratwood on).
	var/on = FALSE
	/// The force it had when switched on, given back when it goes off.
	var/rogue_unpowered_force

/obj/item/rogueweapon/mace/stunmace/Initialize(mapload)
	. = ..()
	charge = SPECIAL_STUNMACE_CHARGE

/obj/item/rogueweapon/mace/stunmace/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/rogueweapon/mace/stunmace/examine(mob/user)
	. = ..()
	. += span_notice("It is switched [on ? "on" : "off"]; its charge is at [round(charge / SPECIAL_STUNMACE_CHARGE * 100)]%.")

/obj/item/rogueweapon/mace/stunmace/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return
	if(on)
		rogue_power(FALSE)
	else
		if(charge <= SPECIAL_STUNMACE_LOW_CHARGE)
			to_chat(user, span_warning("It's out of juice."))
			return TRUE
		user.visible_message(span_warning("[user] flicks [src] on."))
		charge--
		rogue_power(TRUE)
	playsound(user, pick(SPECIAL_STUNMACE_TOGGLE_SOUNDS), 100, TRUE)
	add_fingerprint(user)
	return TRUE

/// Switches the mace on (force 6, Ratwood) or off (its own force back).
/obj/item/rogueweapon/mace/stunmace/proc/rogue_power(state)
	if(on == state)
		return
	on = state
	if(on)
		rogue_unpowered_force = force
		rogue_set_force(SPECIAL_STUNMACE_FORCE)
	else if(!isnull(rogue_unpowered_force))
		rogue_set_force(rogue_unpowered_force)
		rogue_unpowered_force = null
	icon_state = on ? "stunmace1" : "stunmace0"
	update_appearance(UPDATE_ICON_STATE)
	if(ismob(loc))
		var/mob/holder = loc
		holder.update_held_items()
	START_PROCESSING(SSobj, src)

/// Ratwood process() every two seconds: a unit of charge spent while on, a unit regained while off.
/obj/item/rogueweapon/mace/stunmace/process(seconds_per_tick)
	if(on)
		charge -= SPECIAL_STUNMACE_DRAIN * seconds_per_tick
		if(charge <= 0)
			rogue_run_dry()
		return
	charge = min(charge + SPECIAL_STUNMACE_RECHARGE * seconds_per_tick, SPECIAL_STUNMACE_CHARGE)
	if(charge >= SPECIAL_STUNMACE_CHARGE)
		return PROCESS_KILL

/// Switched off before it breaks and before it mends, so its own force is the one broken and given back (combat/integrity.dm).
/obj/item/rogueweapon/mace/stunmace/rogue_break()
	rogue_power(FALSE)
	return ..()

/obj/item/rogueweapon/mace/stunmace/rogue_mend()
	rogue_power(FALSE)
	return ..()

/obj/item/rogueweapon/mace/stunmace/proc/rogue_run_dry()
	charge = 0
	rogue_power(FALSE)
	playsound(src, pick(SPECIAL_STUNMACE_TOGGLE_SOUNDS), 100, TRUE)

/// Ratwood funny_attack_effects(): a struck foe who is spent takes a shock, any other loses energy and breath.
/obj/item/rogueweapon/mace/stunmace/afterattack(atom/target, mob/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(!on || !isliving(target))
		return
	var/mob/living/struck = target
	playsound(struck, pick(SPECIAL_STUNMACE_HIT_SOUNDS), 100, TRUE)
	if(struck.get_stamina_loss() >= struck.max_stamina)
		struck.electrocute_act(SPECIAL_STUNMACE_SHOCK, src)
		charge -= SPECIAL_STUNMACE_SHOCK_COST
	else
		if(ishuman(struck))
			var/mob/living/carbon/human/sapped = struck
			sapped.rogue_energy_add(-SPECIAL_STUNMACE_ENERGY)
		struck.adjust_stamina_loss(SPECIAL_STUNMACE_STAMINA)
		charge -= SPECIAL_STUNMACE_SAP_COST
	if(charge <= 0)
		rogue_run_dry()

/// Ratwood extinguish(): water shorts it out, shocking whoever holds it.
/obj/item/rogueweapon/mace/stunmace/extinguish()
	. = ..()
	if(!on)
		return
	var/mob/living/holder = loc
	if(istype(holder))
		holder.electrocute_act(SPECIAL_STUNMACE_SHOCK, src)
	rogue_run_dry()

// The militia spear (Ratwood melee/special.dm, /datum/component/ignitable/warspear).

/obj/item/rogueweapon/spear/militia
	light_system = OVERLAY_LIGHT
	light_range = 5
	light_power = 1
	light_color = "#db892b"
	light_on = FALSE
	resistance_flags = FIRE_PROOF
	/// Hay is wound round the head (Ratwood is_loaded).
	var/is_loaded = FALSE
	/// The hay burns (Ratwood is_active of the ignitable component).
	var/rogue_hay_lit = FALSE

/// Ratwood hay_types: what a clump of hay is taken from.
/obj/item/rogueweapon/spear/militia/proc/rogue_hay_source(atom/target)
	var/static/list/hay = typecacheof(list(/obj/structure/fluff/nest, /obj/structure/composter, /obj/structure/flora/roguegrass, /obj/item/reagent_containers/food/snacks/grown/wheat))
	return is_type_in_typecache(target, hay)

/obj/item/rogueweapon/spear/militia/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(isliving(interacting_with))
		return ..()
	if(!is_loaded && rogue_hay_source(interacting_with))
		user.visible_message(span_warning("[user] grabs a clump of [interacting_with] and wraps it around \the [src]!"))
		playsound(src, 'modular_redtard/combat/sound/items/hay_collect.ogg', 100)
		qdel(interacting_with)
		is_loaded = TRUE
		rogue_hay_look()
		return ITEM_INTERACT_SUCCESS
	if(!isobj(interacting_with))
		return ..()
	var/obj/thing = interacting_with
	if(rogue_hay_lit)
		// The burning hay sets a flammable thing alight and burns out.
		if(!(thing.resistance_flags & FIRE_PROOF))
			thing.spark_act()
			thing.fire_act()
			rogue_hay_burnt()
		return ..()
	var/obj/item/flame = thing
	if(is_loaded && (thing.light_on || (istype(flame) && flame.get_temperature())))
		rogue_light_hay()
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/item/rogueweapon/spear/militia/fire_act(exposed_temperature, exposed_volume)
	if(is_loaded && !rogue_hay_lit)
		rogue_light_hay()
	return ..()

/obj/item/rogueweapon/spear/militia/proc/rogue_light_hay()
	rogue_hay_lit = TRUE
	set_light_on(TRUE)
	playsound(loc, 'modular_redtard/rockhill/sound/items/firelight.ogg', 100)
	rogue_hay_look()

/// The hay burns out after setting something ablaze (single use).
/obj/item/rogueweapon/spear/militia/proc/rogue_hay_burnt()
	rogue_hay_lit = FALSE
	is_loaded = FALSE
	set_light_on(FALSE)
	playsound(get_turf(src), 'modular_redtard/rockhill/sound/items/firesnuff.ogg', 100)
	rogue_hay_look()

/obj/item/rogueweapon/spear/militia/proc/rogue_hay_look()
	icon_state = rogue_hay_lit ? "peasantwarspear_hayfire" : (is_loaded ? "peasantwarspear_hay" : initial(icon_state))
	update_appearance(UPDATE_ICON_STATE)
	if(ismob(loc))
		var/mob/holder = loc
		holder.update_held_items()

/// Ratwood item_afterattack() of the ignitable component: the burning head sets a struck foe ablaze.
/obj/item/rogueweapon/spear/militia/afterattack(atom/target, mob/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(!rogue_hay_lit || !isliving(target))
		return
	var/mob/living/burned = target
	burned.adjust_fire_stacks(SPECIAL_MILITIA_FIRE_STACKS)
	burned.ignite_mob()
	rogue_hay_burnt()

/obj/item/rogueweapon/spear/militia/extinguish()
	. = ..()
	if(rogue_hay_lit)
		rogue_hay_burnt()

// The "Daemonslayer" (Ratwood swords/greatswords.dm hit_reaction()).

/// Ratwood: the great sword swats aside arrows and thrown things from a foe in sight, like a shield of its coverage.
/obj/item/rogueweapon/sword/long/exe/berserk/dragonslayer/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	. = ..()
	if(. || rogue_broken || (attack_type != PROJECTILE_ATTACK && attack_type != THROWN_PROJECTILE_ATTACK))
		return
	var/mob/living/attacker
	if(isprojectile(hitby))
		var/obj/projectile/shot = hitby
		attacker = shot.firer
	else
		attacker = hitby.throwing?.get_thrower()
	if(!isliving(attacker) || !owner.rogue_sees(attacker) || !prob(coverage))
		return FALSE
	owner.visible_message(span_danger("[owner] swings [src] forward in an arc, swatting [hitby] away!"))
	playsound(src, pick(GLOB.rogue_swing_sounds["bladed_large"]), 100, TRUE, -1)
	return TRUE

// The blacksteel weapons' choice of a special (Ratwood attack_right() and examine()).

/obj/item/rogueweapon
	/// Ratwood selection: specials the weapon's own may be swapped for, once.
	var/list/selection
	/// The special was chosen already (Ratwood used).
	var/used = FALSE

/obj/item/rogueweapon/halberd/blacksteel
	selection = list(/datum/special_intent/polearm_backstep, /datum/special_intent/axe_swing, /datum/special_intent/greatsword_swing)

/obj/item/rogueweapon/eaglebeak/blacksteel
	selection = list(/datum/special_intent/polearm_backstep, /datum/special_intent/flail_sweep, /datum/special_intent/ground_smash)

/obj/item/rogueweapon/greatsword/grenz/flamberge/blacksteel
	selection = list(/datum/special_intent/greatsword_swing, /datum/special_intent/side_sweep, /datum/special_intent/limbguard)

/obj/item/rogueweapon/sword/long/blacksteel
	selection = list(/datum/special_intent/side_sweep, /datum/special_intent/axe_swing, /datum/special_intent/piercing_lunge, /datum/special_intent/polearm_backstep, /datum/special_intent/flail_sweep)

/obj/item/rogueweapon/sword/rapier/blacksteel
	selection = list(/datum/special_intent/piercing_lunge, /datum/special_intent/polearm_backstep)

/obj/item/rogueweapon/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || !length(selection) || used || !isliving(user))
		return
	INVOKE_ASYNC(src, PROC_REF(rogue_choose_special), user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/// Ratwood attack_right() of the blacksteel weapons: one pick from the selection, for good.
/obj/item/rogueweapon/proc/rogue_choose_special(mob/living/user)
	var/list/options = list()
	for(var/datum/special_intent/choice as anything in selection)
		options[initial(choice.name)] = choice
	var/picked = tgui_input_list(user, "Choose the Manoeuvre", "MANOEUVRE", options)
	if(!picked || used || QDELETED(src) || QDELETED(user) || !IsReachableBy(user))
		return
	rogue_set_special(options[picked])
	used = TRUE
	to_chat(user, span_notice("[src] will now perform [picked]."))

/// Swaps the weapon's special; the one in use is made anew from the type (combat/specials.dm).
/obj/item/proc/rogue_set_special(special_type)
	special = special_type
	QDEL_NULL(special_instance)

// Banners of cloth on polearms (Ratwood attackby() with /obj/item/natural/cloth, update_icon() with detail_tag).

/obj/item/rogueweapon
	/// Ratwood detail_tag of a weapon: the banner's state is "[icon_state][this]".
	var/rogue_banner_state = "detail"
	/// The banner's colour (Ratwood detail_color); none means no banner.
	var/rogue_banner_color
	/// A banner of cloth may be tied to it.
	var/rogue_bannerable = FALSE

/obj/item/rogueweapon/spear/lance
	rogue_bannerable = TRUE

/obj/item/rogueweapon/halberd/blacksteel
	rogue_bannerable = TRUE

/obj/item/rogueweapon/eaglebeak/blacksteel
	rogue_bannerable = TRUE

/obj/item/rogueweapon/spear/bronze
	rogue_bannerable = TRUE

/// Ratwood: the banner of Otava always bears Otava's orange.
/obj/item/rogueweapon/spear/otava
	rogue_banner_state = "_det"
	rogue_banner_color = "#FFA500"

/obj/item/rogueweapon/Initialize(mapload)
	. = ..()
	if(rogue_banner_color)
		update_appearance(UPDATE_OVERLAYS)

/obj/item/rogueweapon/update_overlays()
	. = ..()
	if(!rogue_banner_color)
		return
	var/banner = "[icon_state][rogue_banner_state]"
	if(icon_exists(icon, banner))
		. += rogue_color_layer(icon, banner, rogue_banner_color)

/// Examine lines of the weapons' own procedures (combat/integrity.dm shows them).
/obj/item/rogueweapon/proc/rogue_weapon_notes()
	. = list()
	if(length(selection) && !used)
		. += span_notice("The Special Manoeuvre of this weapon can be changed. Right-click it with a free hand to select one. This can only be done once.")
	if(rogue_bannerable && !rogue_banner_color)
		. += span_notice("A length of cloth wrapped around the shaft would bear my heraldry.")

/obj/item/rogueweapon/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!rogue_bannerable || rogue_banner_color || !istype(tool, /obj/item/natural/cloth))
		return ..()
	INVOKE_ASYNC(src, PROC_REF(rogue_add_banner), user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/item/rogueweapon/proc/rogue_add_banner(mob/living/user, obj/item/cloth)
	var/choice = tgui_input_list(user, "Choose a color.", "Banner", GLOB.rogue_dye_colors)
	if(!choice || rogue_banner_color || QDELETED(src) || QDELETED(cloth) || !user.is_holding(cloth) || !IsReachableBy(user))
		return
	user.visible_message(span_warning("[user] adds a banner to [src]."))
	user.transferItemToLoc(cloth, src)
	rogue_banner_color = GLOB.rogue_dye_colors[choice]
	update_appearance(UPDATE_OVERLAYS)

// "Terminus Est" (Ratwood swords.dm rmb_self()).

/obj/item/rogueweapon/sword/long/exe/cloth/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(user, pick(SPECIAL_CLOTH_WIPE_SOUNDS), 100, TRUE)
	wash(CLEAN_SCRUB)
	user.visible_message(span_warning("[user] wipes [src] down with its cloth."), span_notice("I wipe [src] down with its cloth."))
	return TRUE

// Bucklers (Ratwood shields.dm bucklerskill(), called by every parry of parry.dm).

/obj/item/rogueweapon/shield
	/// Parries with the skill of the weapon in the active hand (Ratwood's buckler and the captain's 'Order').
	var/rogue_buckler = FALSE

/obj/item/rogueweapon/shield/buckler
	rogue_buckler = TRUE

/obj/item/rogueweapon/shield/capbuckler
	rogue_buckler = TRUE

/obj/item/rogueweapon/shield/examine(mob/user)
	. = ..()
	if(rogue_buckler)
		. += span_notice("Buckler uses the skill of your active weapon to parry. Otherwise it uses your shields skill.")

/obj/item/rogueweapon/shield/equipped(mob/user, slot, initial)
	. = ..()
	if(!rogue_buckler || !isliving(user))
		return
	if(!(slot & ITEM_SLOT_HANDS))
		rogue_buckler_release(user)
		return
	RegisterSignals(user, list(COMSIG_MOB_SWAP_HANDS, COMSIG_MOB_EQUIPPED_ITEM, COMSIG_ROGUE_STRIKE_INCOMING), PROC_REF(on_holder_hands), override = TRUE)
	RegisterSignal(user, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(on_holder_unequip), override = TRUE)
	rogue_buckler_skill(user)

/obj/item/rogueweapon/shield/dropped(mob/user, silent)
	. = ..()
	if(rogue_buckler)
		rogue_buckler_release(user)

/obj/item/rogueweapon/shield/proc/rogue_buckler_release(mob/user)
	UnregisterSignal(user, list(COMSIG_MOB_SWAP_HANDS, COMSIG_MOB_EQUIPPED_ITEM, COMSIG_ROGUE_STRIKE_INCOMING, COMSIG_MOB_UNEQUIPPED_ITEM))
	associated_skill = initial(associated_skill)

/obj/item/rogueweapon/shield/proc/on_holder_hands(mob/living/source)
	SIGNAL_HANDLER
	rogue_buckler_skill(source)

/// The item leaving the hand is still held while this runs, so it is passed over.
/obj/item/rogueweapon/shield/proc/on_holder_unequip(mob/living/source, obj/item/leaving)
	SIGNAL_HANDLER
	if(leaving != src)
		rogue_buckler_skill(source, leaving)

/// Ratwood bucklerskill(): the active hand's weapon's skill if it parries with a combat skill, else the shield skill.
/obj/item/rogueweapon/shield/proc/rogue_buckler_skill(mob/living/holder, obj/item/leaving)
	var/obj/item/mainhand = holder.get_active_held_item()
	if(!mainhand || mainhand == src || mainhand == leaving || !mainhand.can_parry || !ispath(mainhand.associated_skill, /datum/attribute/skill/combat))
		associated_skill = initial(associated_skill)
		return
	associated_skill = mainhand.associated_skill

#undef SPECIAL_ROD_RANGE
#undef SPECIAL_ROD_SHOCK
#undef SPECIAL_ROD_SILENCE
#undef SPECIAL_SCEPTER_SHOCK_COOLDOWN
#undef SPECIAL_SCEPTER_SILENCE_COOLDOWN
#undef SPECIAL_STAFF_SMITE_COOLDOWN
#undef SPECIAL_STAFF_SILENCE_COOLDOWN
#undef SPECIAL_STAFF_SMITE_FIRE
#undef SPECIAL_STUNMACE_CHARGE
#undef SPECIAL_STUNMACE_LOW_CHARGE
#undef SPECIAL_STUNMACE_FORCE
#undef SPECIAL_STUNMACE_DRAIN
#undef SPECIAL_STUNMACE_RECHARGE
#undef SPECIAL_STUNMACE_SHOCK
#undef SPECIAL_STUNMACE_SHOCK_COST
#undef SPECIAL_STUNMACE_SAP_COST
#undef SPECIAL_STUNMACE_ENERGY
#undef SPECIAL_STUNMACE_STAMINA
#undef SPECIAL_MILITIA_FIRE_STACKS
#undef SPECIAL_STUNMACE_TOGGLE_SOUNDS
#undef SPECIAL_STUNMACE_HIT_SOUNDS
#undef SPECIAL_CLOTH_WIPE_SOUNDS
