// CHAPLAIN NULLROD AND CUSTOM WEAPONS //

/obj/item/nullrod
	name = "null rod"
	desc = "A rod of pure obsidian; its very presence disrupts and dampens 'magical forces'. That's what the guidebook says, anyway."
	icon = 'icons/obj/weapons/staff.dmi'
	icon_state = "nullrod"
	inhand_icon_state = "nullrod"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	force = 18
	throw_speed = 3
	throw_range = 4
	throwforce = 10
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_TINY
	obj_flags = UNIQUE_RENAME
	wound_bonus = -10
	/// boolean on whether it's allowed to be picked from the nullrod's transformation ability
	var/chaplain_spawnable = TRUE
	/// Short description of what this item is capable of, for radial menu uses.
	var/menu_description = "A standard chaplain's weapon. Fits in pockets. Can be worn on the belt."
	/// Lazylist, tracks refs()s to all cultists which have been crit or killed by this nullrod.
	var/list/cultists_slain

/obj/item/nullrod/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY)
	AddComponent(/datum/component/effect_remover, \
		success_feedback = "You disrupt the magic of %THEEFFECT with %THEWEAPON.", \
		success_forcesay = "BEGONE FOUL MAGIKS!!", \
		tip_text = "Clear rune", \
		on_clear_callback = CALLBACK(src, PROC_REF(on_cult_rune_removed)), \
		effects_we_clear = list(/obj/effect/rune, /obj/effect/heretic_rune, /obj/effect/cosmic_rune), \
	)
	AddElement(/datum/element/bane, target_type = /mob/living/basic/revenant, damage_multiplier = 0, added_damage = 25, requires_combat_mode = FALSE)

	if(!GLOB.holy_weapon_type && type == /obj/item/nullrod)
		var/list/rods = list()
		for(var/obj/item/nullrod/nullrod_type as anything in typesof(/obj/item/nullrod))
			if(!initial(nullrod_type.chaplain_spawnable))
				continue
			rods[nullrod_type] = initial(nullrod_type.menu_description)
		//special non-nullrod subtyped shit
		rods[/obj/item/gun/ballistic/bow/divine/with_quiver] = "A divine bow and 10 quivered holy arrows."
		rods[/obj/item/organ/internal/cyberimp/arm/shard/scythe] = "A shard that implants itself into your arm, \
									allowing you to conjure forth a vorpal scythe. \
									Allows you to behead targets for empowered strikes. \
									Harms you if you dismiss the scythe without first causing harm to a creature. \
									The shard also causes you to become Morbid, shifting your interests towards the macabre."
		AddComponent(/datum/component/subtype_picker, rods, CALLBACK(src, PROC_REF(on_holy_weapon_picked)))

/obj/item/nullrod/proc/on_holy_weapon_picked(obj/item/nullrod/holy_weapon_type)
	GLOB.holy_weapon_type = holy_weapon_type
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NULLROD_PICKED)
	SSblackbox.record_feedback("tally", "chaplain_weapon", 1, "[initial(holy_weapon_type.name)]")

/obj/item/nullrod/proc/on_cult_rune_removed(obj/effect/target, mob/living/user)
	if(!istype(target, /obj/effect/rune))
		return

	var/obj/effect/rune/target_rune = target
	if(target_rune.log_when_erased)
		user.log_message("erased [target_rune.cultist_name] rune using [src]", LOG_GAME)
	SSshuttle.shuttle_purchase_requirements_met[SHUTTLE_UNLOCK_NARNAR] = TRUE

/obj/item/nullrod/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is killing [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to get closer to god!"))
	return (BRUTELOSS|FIRELOSS)

/obj/item/nullrod/attack(mob/living/target_mob, mob/living/user, params)
	if(!user.mind?.holy_role)
		return ..()
	if(!IS_CULTIST(target_mob) || istype(target_mob, /mob/living/carbon/human/cult_ghost))
		return ..()

	var/old_stat = target_mob.stat
	. = ..()
	if(old_stat < target_mob.stat)
		LAZYOR(cultists_slain, REF(target_mob))
	return .

/obj/item/nullrod/examine(mob/user)
	. = ..()
	if(!IS_CULTIST(user) || !GET_ATOM_BLOOD_DNA_LENGTH(src))
		return

	var/num_slain = LAZYLEN(cultists_slain)
	. += span_cult_italic("It has the blood of [num_slain] fallen cultist[num_slain == 1 ? "" : "s"] on it. \
		<b>Offering</b> it to Nar'sie will transform it into a [num_slain >= 3 ? "powerful" : "standard"] cult weapon.")

/// Claymore Variant
/// This subtype possesses a block chance and is sharp.

/obj/item/nullrod/claymore
	name = "holy claymore"
	desc = "A weapon fit for a crusade!"
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "claymore_gold"
	inhand_icon_state = "claymore_gold"
	worn_icon_state = "claymore_gold"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	block_chance = 30
	block_sound = 'sound/weapons/parry.ogg'
	sharpness = SHARP_EDGED
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	menu_description = "A sharp claymore which provides a low chance of blocking incoming melee attacks. Can be worn on the back or belt."

/obj/item/nullrod/claymore/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	if(attack_type == PROJECTILE_ATTACK || attack_type == LEAP_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight, and also you aren't going to really block someone full body tackling you with a sword
	return ..()

/obj/item/nullrod/claymore/darkblade
	name = "dark blade"
	desc = "Spread the glory of the dark gods!"
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "cultblade"
	inhand_icon_state = "cultblade"
	worn_icon_state = "cultblade"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	hitsound = 'sound/hallucinations/growl1.ogg'
	menu_description = "A sharp blade which provides a low chance of blocking incoming melee attacks. Can be worn on the back or belt."

/obj/item/nullrod/claymore/chainsaw_sword
	name = "sacred chainsaw sword"
	desc = "Suffer not a heretic to live."
	icon_state = "chainswordon"
	inhand_icon_state = "chainswordon"
	worn_icon_state = "chainswordon"
	slot_flags = ITEM_SLOT_BELT
	attack_verb_continuous = list("saws", "tears", "lacerates", "cuts", "chops", "dices")
	attack_verb_simple = list("saw", "tear", "lacerate", "cut", "chop", "dice")
	hitsound = 'sound/weapons/chainsawhit.ogg'
	tool_behaviour = TOOL_SAW
	toolspeed = 1.5 //slower than a real saw
	menu_description = "A sharp chainsaw sword which provides a low chance of blocking incoming melee attacks. Can be used as a slower saw tool. Can be worn on the belt."

/obj/item/nullrod/claymore/glowing
	name = "force weapon"
	desc = "The blade glows with the power of faith. Or possibly a battery."
	icon_state = "swordon"
	inhand_icon_state = "swordon"
	worn_icon_state = "swordon"
	menu_description = "A sharp weapon which provides a low chance of blocking incoming melee attacks. Can be worn on the back or belt."

/obj/item/nullrod/claymore/katana
	name = "\improper Hanzo steel"
	desc = "Capable of cutting clean through a holy claymore."
	icon_state = "katana"
	inhand_icon_state = "katana"
	worn_icon_state = "katana"
	menu_description = "A sharp katana which provides a low chance of blocking incoming melee attacks. Can be worn on the back or belt."

/obj/item/nullrod/claymore/multiverse
	name = "extradimensional blade"
	desc = "Once the harbinger of an interdimensional war, its sharpness fluctuates wildly."
	icon_state = "multiverse"
	inhand_icon_state = "multiverse"
	worn_icon_state = "multiverse"
	slot_flags = ITEM_SLOT_BACK
	force = 15
	menu_description = "An odd sharp blade which provides a low chance of blocking incoming melee attacks and deals a random amount of damage, which can range from almost nothing to very high. Can be worn on the back."

/obj/item/nullrod/claymore/multiverse/melee_attack_chain(mob/user, atom/target, params)
	var/old_force = force
	force += rand(-14, 15)
	. = ..()
	force = old_force

/obj/item/nullrod/claymore/saber
	name = "light energy sword"
	desc = "If you strike me down, I shall become more robust than you can possibly imagine."
	icon = 'icons/obj/weapons/transforming_energy.dmi'
	icon_state = "e_sword_on_blue"
	inhand_icon_state = "e_sword_on_blue"
	worn_icon_state = "swordblue"
	slot_flags = ITEM_SLOT_BELT
	hitsound = 'sound/weapons/blade1.ogg'
	block_sound = 'sound/weapons/block_blade.ogg'
	menu_description = "A sharp energy sword which provides a low chance of blocking incoming melee attacks. Can be worn on the belt."

/obj/item/nullrod/claymore/saber/red
	name = "dark energy sword"
	desc = "Woefully ineffective when used on steep terrain."
	icon_state = "e_sword_on_red"
	inhand_icon_state = "e_sword_on_red"
	worn_icon_state = "swordred"

/obj/item/nullrod/claymore/saber/pirate
	name = "nautical energy sword"
	desc = "Convincing HR that your religion involved piracy was no mean feat."
	icon_state = "e_cutlass_on"
	inhand_icon_state = "e_cutlass_on"
	worn_icon_state = "swordred"

/// Vibro Variant
/// This subtype possesses armor penetration and is sharp.

/obj/item/nullrod/vibro
	name = "high frequency blade"
	desc = "Bad references are the DNA of the soul."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "hfrequency0"
	inhand_icon_state = "hfrequency1"
	worn_icon_state = "hfrequency0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	armour_penetration = 35
	slot_flags = ITEM_SLOT_BACK
	sharpness = SHARP_EDGED
	attack_verb_continuous = list("chops", "slices", "cuts", "zandatsu's")
	attack_verb_simple = list("chop", "slice", "cut", "zandatsu")
	hitsound = 'sound/weapons/rapierhit.ogg'
	menu_description = "A sharp blade which partially penetrates armor. Very effective at butchering bodies. Can be worn on the back."

/obj/item/nullrod/vibro/Initialize(mapload)
	. = ..()
	AddComponent(
		/datum/component/butchering, \
		speed = 7 SECONDS, \
		effectiveness = 110, \
	)

/obj/item/nullrod/vibro/spellblade
	name = "dormant spellblade"
	desc = "The blade grants the wielder nearly limitless power...if they can figure out how to turn it on, that is."
	icon = 'icons/obj/weapons/guns/magic.dmi'
	icon_state = "spellblade"
	inhand_icon_state = "spellblade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	worn_icon_state = "spellblade"
	hitsound = 'sound/weapons/rapierhit.ogg'
	menu_description = "A sharp blade which partially penetrates armor. Very effective at butchering bodies. Can be worn on the back."

/obj/item/nullrod/vibro/talking
	name = "possessed blade"
	desc = "When the station falls into chaos, it's nice to have a friend by your side."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "talking_sword"
	inhand_icon_state = "talking_sword"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	worn_icon_state = "talking_sword"
	attack_verb_continuous = list("chops", "slices", "cuts")
	attack_verb_simple= list("chop", "slice", "cut")
	hitsound = 'sound/weapons/rapierhit.ogg'
	menu_description = "A sharp blade which partially penetrates armor. Able to awaken a friendly spirit to provide guidance. Very effective at butchering bodies. Can be worn on the back."

/obj/item/nullrod/vibro/talking/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spirit_holding)

/obj/item/nullrod/vibro/talking/chainsword
	name = "possessed chainsaw sword"
	desc = "Suffer not a heretic to live."
	icon_state = "chainswordon"
	inhand_icon_state = "chainswordon"
	worn_icon_state = "chainswordon"
	force = 30
	slot_flags = ITEM_SLOT_BELT
	attack_verb_continuous = list("saws", "tears", "lacerates", "cuts", "chops", "dices")
	attack_verb_simple = list("saw", "tear", "lacerate", "cut", "chop", "dice")
	hitsound = 'sound/weapons/chainsawhit.ogg'
	tool_behaviour = TOOL_SAW
	toolspeed = 0.5 //same speed as an active chainsaw
	chaplain_spawnable = FALSE //prevents being pickable as a chaplain weapon (it has 30 force)

/// Other Variants
/// Not a special category on their own, but usually possess more unique mechanics

// God Hand - Cannot be dropped. Does burn damage.

/obj/item/nullrod/godhand
	name = "god hand"
	desc = "This hand of yours glows with an awesome power!"
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "disintegrate"
	inhand_icon_state = "disintegrate"
	lefthand_file = 'icons/mob/inhands/items/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/touchspell_righthand.dmi'
	slot_flags = null
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	hitsound = 'sound/weapons/sear.ogg'
	damtype = BURN
	attack_verb_continuous = list("punches", "cross counters", "pummels")
	attack_verb_simple = list(SFX_PUNCH, "cross counter", "pummel")
	menu_description = "An undroppable god hand dealing burn damage. Disappears if the arm holding it is cut off."

/obj/item/nullrod/godhand/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

// Red/Blue Holy Staff - 50% block chance, almost no damage at all.

/obj/item/nullrod/staff
	name = "red holy staff"
	desc = "It has a mysterious, protective aura."
	icon = 'icons/obj/weapons/staff.dmi'
	icon_state = "godstaff-red"
	inhand_icon_state = "godstaff-red"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	force = 5
	slot_flags = ITEM_SLOT_BACK
	block_chance = 50
	block_sound = 'sound/weapons/genhit.ogg'
	menu_description = "A red staff which provides a medium chance of blocking incoming attacks via a protective red aura around its user, but deals very low amount of damage. Can be worn only on the back."
	/// The icon which appears over the mob holding the item
	var/shield_icon = "shield-red"

/obj/item/nullrod/staff/worn_overlays(mutable_appearance/standing, isinhands)
	. = ..()
	if(isinhands)
		. += mutable_appearance('icons/effects/effects.dmi', shield_icon, MOB_SHIELD_LAYER)

/obj/item/nullrod/staff/blue
	name = "blue holy staff"
	icon_state = "godstaff-blue"
	inhand_icon_state = "godstaff-blue"
	shield_icon = "shield-old"
	menu_description = "A blue staff which provides a medium chance of blocking incoming attacks via a protective blue aura around its user, but deals very low amount of damage. Can be worn only on the back."

// SORD - It is unspeakably shitty.

/obj/item/nullrod/sord
	name = "\improper UNREAL SORD"
	desc = "This thing is so unspeakably HOLY you are having a hard time even holding it."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "sord"
	inhand_icon_state = "sord"
	worn_icon_state = "sord"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 4.13
	throwforce = 1
	slot_flags = ITEM_SLOT_BELT
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	menu_description = "An odd s(w)ord dealing a laughable amount of damage. Fits in pockets. Can be worn on the belt."

/obj/item/nullrod/sord/suicide_act(mob/living/user) //a near-exact copy+paste of the actual sord suicide_act()
	user.visible_message(span_suicide("[user] is trying to impale [user.p_them()]self with [src]! It might be a suicide attempt if it weren't so HOLY."), \
	span_suicide("You try to impale yourself with [src], but it's TOO HOLY..."))
	return SHAME

// Relic War Hammer - Nothing special.

/obj/item/nullrod/hammer
	name = "relic war hammer"
	desc = "This war hammer cost the chaplain forty thousand space dollars."
	icon = 'icons/obj/weapons/hammer.dmi'
	icon_state = "hammeron"
	inhand_icon_state = "hammeron"
	worn_icon_state = "hammeron"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("smashes", "bashes", "hammers", "crunches")
	attack_verb_simple = list("smash", "bash", "hammer", "crunch")
	menu_description = "A war hammer. Capable of tapping knees to measure brain health. Can be worn on the belt."

/obj/item/nullrod/hammer/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/kneejerk)

// Chainsaw Hand - Cannot be dropped.

/obj/item/nullrod/chainsaw
	name = "chainsaw hand"
	desc = "Good? Bad? You're the guy with the chainsaw hand."
	icon = 'icons/obj/weapons/chainsaw.dmi'
	icon_state = "chainsaw_on"
	inhand_icon_state = "mounted_chainsaw"
	lefthand_file = 'icons/mob/inhands/weapons/chainsaw_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/chainsaw_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = null
	item_flags = ABSTRACT
	sharpness = SHARP_EDGED
	attack_verb_continuous = list("saws", "tears", "lacerates", "cuts", "chops", "dices")
	attack_verb_simple = list("saw", "tear", "lacerate", "cut", "chop", "dice")
	hitsound = 'sound/weapons/chainsawhit.ogg'
	tool_behaviour = TOOL_SAW
	toolspeed = 2 //slower than a real saw
	menu_description = "An undroppable sharp chainsaw hand. Can be used as a very slow saw tool. Capable of slowly butchering bodies. Disappears if the arm holding it is cut off."

/obj/item/nullrod/chainsaw/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	AddComponent(/datum/component/butchering, \
	speed = 3 SECONDS, \
	effectiveness = 100, \
	bonus_modifier = 0, \
	butcher_sound = hitsound, \
	)

// Clown Dagger - Nothing special, just honks.

/obj/item/nullrod/clown
	name = "clown dagger"
	desc = "Used for absolutely hilarious sacrifices."
	icon = 'icons/obj/weapons/khopesh.dmi'
	icon_state = "clownrender"
	inhand_icon_state = "cultdagger"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	worn_icon_state = "render"
	hitsound = 'sound/items/bikehorn.ogg'
	sharpness = SHARP_EDGED
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	menu_description = "A sharp dagger. Fits in pockets. Can be worn on the belt. Honk."

// Pride-struck Hammer - Transfers reagents in your body to those you hit.

#define CHEMICAL_TRANSFER_CHANCE 30

/obj/item/nullrod/pride_hammer
	name = "Pride-struck Hammer"
	desc = "It resonates an aura of Pride."
	icon = 'icons/obj/weapons/hammer.dmi'
	icon_state = "pride"
	inhand_icon_state = "pride"
	worn_icon_state = "pride"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	force = 16
	throwforce = 15
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	attack_verb_continuous = list("attacks", "smashes", "crushes", "splatters", "cracks")
	attack_verb_simple = list("attack", "smash", "crush", "splatter", "crack")
	hitsound = 'sound/weapons/blade1.ogg'
	menu_description = "A hammer dealing a little less damage due to its user's pride. Has a low chance of transferring some of the user's reagents to the target. Capable of tapping knees to measure brain health. Can be worn on the back."

/obj/item/nullrod/pride_hammer/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/kneejerk)
	AddElement(
		/datum/element/chemical_transfer,\
		span_notice("Your pride reflects on %VICTIM."),\
		span_userdanger("You feel insecure, taking on %ATTACKER's burden."),\
		CHEMICAL_TRANSFER_CHANCE\
	)

#undef CHEMICAL_TRANSFER_CHANCE

// Holy Whip - Does more damage to vampires.

/obj/item/nullrod/whip
	name = "holy whip"
	desc = "What a terrible night to be on Space Station 13."
	icon = 'icons/obj/weapons/whip.dmi'
	icon_state = "chain"
	inhand_icon_state = "chain"
	worn_icon_state = "whip"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	attack_verb_continuous = list("whips", "lashes")
	attack_verb_simple = list("whip", "lash")
	hitsound = 'sound/weapons/chainhit.ogg'
	menu_description = "A whip. Deals extra damage to vampires. Fits in pockets. Can be worn on the belt."

// Atheist's Fedora - Wear it on your head. No melee damage, massive throw force.

/obj/item/nullrod/fedora
	name = "atheist's fedora"
	desc = "The brim of the hat is as sharp as your wit. The edge would hurt almost as much as disproving the existence of God."
	icon_state = "fedora"
	inhand_icon_state = "fedora"
	slot_flags = ITEM_SLOT_HEAD
	icon = 'icons/obj/clothing/head/hats.dmi'
	worn_icon = 'icons/mob/clothing/head/hats.dmi'
	lefthand_file = 'icons/mob/inhands/clothing/hats_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/hats_righthand.dmi'
	force = 0
	throw_speed = 4
	throw_range = 7
	throwforce = 30
	sharpness = SHARP_EDGED
	attack_verb_continuous = list("enlightens", "redpills")
	attack_verb_simple = list("enlighten", "redpill")
	menu_description = "A sharp fedora dealing a very high amount of throw damage, but none of melee. Fits in pockets. Can be worn on the head, obviously."

/obj/item/nullrod/fedora/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is killing [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to get further from god!"))
	return (BRUTELOSS|FIRELOSS)

// Dark Blessing - Replaces your arm with an armblade. Cannot be dropped.

/obj/item/nullrod/armblade
	name = "dark blessing"
	desc = "Particularly twisted deities grant gifts of dubious value."
	icon = 'icons/obj/weapons/changeling_items.dmi'
	icon_state = "arm_blade"
	inhand_icon_state = "arm_blade"
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	slot_flags = null
	item_flags = ABSTRACT
	w_class = WEIGHT_CLASS_HUGE
	sharpness = SHARP_EDGED
	wound_bonus = -20
	bare_wound_bonus = 25
	menu_description = "An undroppable sharp armblade capable of inflicting deep wounds. Capable of an ineffective butchering of bodies. Disappears if the arm holding it is cut off."

/obj/item/nullrod/armblade/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	AddComponent(/datum/component/butchering, \
	speed = 8 SECONDS, \
	effectiveness = 70, \
	)

// Unholy Blessing - Just a reskinned dark blessing.

/obj/item/nullrod/armblade/tentacle
	name = "unholy blessing"
	icon_state = "tentacle"
	inhand_icon_state = "tentacle"
	menu_description = "An undroppable sharp tentacle capable of inflicting deep wounds. Capable of an ineffective butchering of bodies. Disappears if the arm holding it is cut off."

// Carp-sie Plushie - Gives you the carp faction so that you can be friends with carp.

/obj/item/nullrod/carp
	name = "carp-sie plushie"
	desc = "An adorable stuffed toy that resembles the god of all carp. The teeth look pretty sharp. Activate it to receive the blessing of Carp-Sie."
	icon = 'icons/obj/toys/plushes.dmi'
	icon_state = "map_plushie_carp"
	greyscale_config = /datum/greyscale_config/plush_carp
	greyscale_colors = "#cc99ff#000000"
	inhand_icon_state = "carp_plushie"
	worn_icon_state = "nullrod"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	force = 15
	attack_verb_continuous = list("bites", "eats", "fin slaps")
	attack_verb_simple = list("bite", "eat", "fin slap")
	hitsound = 'sound/weapons/bite.ogg'
	menu_description = "A plushie dealing a little less damage due to its cute form. Capable of blessing one person with the Carp-Sie favor, which grants friendship of all wild space carps. Fits in pockets. Can be worn on the belt."

/obj/item/nullrod/carp/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/faction_granter, FACTION_CARP, holy_role_required = HOLY_ROLE_PRIEST, grant_message = span_boldnotice("You are blessed by Carp-Sie. Wild space carp will no longer attack you."))

// Monk's Staff - Higher block, lower damage.

/obj/item/nullrod/bostaff
	name = "monk's staff"
	desc = "A long, tall staff made of polished wood. Traditionally used in ancient old-Earth martial arts, it is now used to harass the clown."
	force = 15
	block_chance = 40
	block_sound = 'sound/weapons/genhit.ogg'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	hitsound = SFX_SWING_HIT
	attack_verb_continuous = list("smashes", "slams", "whacks", "thwacks")
	attack_verb_simple = list("smash", "slam", "whack", "thwack")
	icon = 'icons/obj/weapons/staff.dmi'
	icon_state = "bostaff0"
	inhand_icon_state = "bostaff0"
	worn_icon_state = "bostaff0"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	menu_description = "A staff which provides a medium-low chance of blocking incoming melee attacks and deals a little less damage. Can be worn on the back."

// Arrhythmic Knife - Lets your walk without rhythm by varying your walk speed. Can't be put away.

/obj/item/nullrod/tribal_knife
	name = "arrhythmic knife"
	desc = "They say fear is the true mind killer, but stabbing them in the head works too. Honour compels you to not sheathe it once drawn."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "crysknife"
	inhand_icon_state = "crysknife"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	sharpness = SHARP_EDGED
	slot_flags = null
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	item_flags = SLOWS_WHILE_IN_HAND
	menu_description = "A sharp knife. Randomly speeds or slows its user at a regular intervals. Capable of butchering bodies. Cannot be worn anywhere."

/obj/item/nullrod/tribal_knife/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/butchering, \
	speed = 5 SECONDS, \
	effectiveness = 100, \
	)

/obj/item/nullrod/tribal_knife/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/nullrod/tribal_knife/process()
	slowdown = rand(-10, 10)/10
	if(iscarbon(loc))
		var/mob/living/carbon/wielder = loc
		if(wielder.is_holding(src))
			wielder.update_equipment_speed_mods()

// Unholy Pitchfork - Does absolutely nothing special, it is just bigger.

/obj/item/nullrod/pitchfork
	name = "unholy pitchfork"
	desc = "Holding this makes you look absolutely devilish."
	icon = 'icons/obj/weapons/spear.dmi'
	icon_state = "pitchfork0"
	inhand_icon_state = "pitchfork0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	worn_icon_state = "pitchfork0"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	attack_verb_continuous = list("pokes", "impales", "pierces", "jabs")
	attack_verb_simple = list("poke", "impale", "pierce", "jab")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP_EDGED
	menu_description = "A sharp pitchfork. Can be worn on the back."

// Egyptian Staff - Used as a tool for making mummy wraps.

/obj/item/nullrod/egyptian
	name = "egyptian staff"
	desc = "A tutorial in mummification is carved into the staff. You could probably craft the wraps if you had some cloth."
	icon = 'icons/obj/weapons/guns/magic.dmi'
	icon_state = "pharoah_sceptre"
	inhand_icon_state = "pharoah_sceptre"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	worn_icon_state = "pharoah_sceptre"
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BACK
	attack_verb_continuous = list("bashes", "smacks", "whacks")
	attack_verb_simple = list("bash", "smack", "whack")
	menu_description = "A staff. Can be used as a tool to craft exclusive egyptian items. Easily stored. Can be worn on the back."

// Hypertool - It does brain damage rather than normal damage.

/obj/item/nullrod/hypertool
	name = "hypertool"
	desc = "A tool so powerful even you cannot perfectly use it."
	icon = 'icons/obj/weapons/club.dmi'
	icon_state = "hypertool"
	inhand_icon_state = "hypertool"
	worn_icon_state = "hypertool"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	damtype = BRAIN
	armour_penetration = 35
	attack_verb_continuous = list("pulses", "mends", "cuts")
	attack_verb_simple = list("pulse", "mend", "cut")
	hitsound = 'sound/effects/sparks4.ogg'
	menu_description = "A tool dealing brain damage which partially penetrates armor. Fits in pockets. Can be worn on the belt."

// Ancient Spear - Slight armor penetration, based on the Brass Spear from the Clockcult game mode.

/obj/item/nullrod/spear
	name = "ancient spear"
	desc = "An ancient spear made of brass, I mean gold, I mean bronze. It looks highly mechanical."
	icon = 'icons/obj/weapons/spear.dmi'
	icon_state = "ratvarian_spear"
	inhand_icon_state = "ratvarian_spear"
	lefthand_file = 'icons/mob/inhands/antag/clockwork_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/clockwork_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	armour_penetration = 10
	sharpness = SHARP_POINTY
	w_class = WEIGHT_CLASS_HUGE
	attack_verb_continuous = list("stabs", "pokes", "slashes", "clocks")
	attack_verb_simple = list("stab", "poke", "slash", "clock")
	hitsound = 'sound/weapons/bladeslice.ogg'
	menu_description = "A pointy spear which penetrates armor a little. Can be worn only on the belt."

// Nullblade - For when you really want to feel like rolling dice during combat

/obj/item/nullrod/nullblade
	name = "nullblade"
	desc = "Clerical assassins are not officially recognized by the collective faiths of Nanotrasen. And yet, here you are."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "nullsword"
	inhand_icon_state = "nullsword"
	worn_icon_state = "nullsword"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	force = 12
	wound_bonus = 10
	bare_wound_bonus = 30
	slot_flags = ITEM_SLOT_BELT
	block_sound = 'sound/weapons/parry.ogg'
	sharpness = SHARP_POINTY
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "punctures", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "puncture", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	menu_description = "A blade that deals variable, low amounts of damage, but does easily inflict wounds. \
		The stronger your swinging arm is, the stronger the blade is, though only slightly. \
		Against debilitated targets, can also deal additional sneak attack damage with a very high wound chance."

/obj/item/nullrod/nullblade/melee_attack_chain(mob/user, atom/target, params)
	//Track our actual force separately
	var/old_force = force
	force = 0
	//Potential dice roll for our baseline force
	force += roll("1d6")

	//Now we can check for our user's potential 'strength' value. As a baseline, we'll use a default value of 4 for the sake of nonhuman users.
	var/strength_value = 4

	//We can use our human wielder's arm strength to determine their 'strength'. We add unarmed lower and upper, then divide by four.
	//This isn't how strength works in dnd but who fucking cares.
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		var/obj/item/bodypart/wielding_bodypart = human_user.get_active_hand()
		strength_value = round((wielding_bodypart.unarmed_damage_low + wielding_bodypart.unarmed_damage_high) * 0.25, 1)

	force += strength_value

	//If our old_force is higher than our initial force, add the difference to this calculation.
	//We do this because our force could have been changed by things like whetstones and RPG stats.
	force += old_force - initial(force)

	. = ..()
	//Reapply our old force.
	force = old_force

/obj/item/nullrod/nullblade/afterattack(atom/target, mob/user, click_parameters)
	if(!isliving(target))
		return

	var/mob/living/living_target = target

	if(user == living_target)
		return

	if(living_target.stat == DEAD)
		return

	sneak_attack(living_target, user)

/// If our target is incapacitated, unable to protect themselves, or we attack them from behind, we sneak attack!
/obj/item/nullrod/nullblade/proc/sneak_attack(mob/living/living_target, mob/user)
	// Did we successfully meet the criteria for a sneak attack?
	var/successful_sneak_attack = FALSE

	// Did our sneak attack fail due to a special effect?
	var/sneak_attack_fail_message = FALSE

	// The force our sneak attack applies. Starts as 3d6, then changed based on certain factors.
	var/sneak_attack_dice = roll("3d6")

	// Status effects on the target that grant us sneak attacks
	if(living_target.is_blind())
		successful_sneak_attack = TRUE

	else if(living_target.get_timed_status_effect_duration(/datum/status_effect/staggered))
		successful_sneak_attack = TRUE

	else if(living_target.get_timed_status_effect_duration(/datum/status_effect/confusion))
		successful_sneak_attack = TRUE

	// Our target is in some kind of grapple, which prevents them form protecting themselves.
	else if(living_target.pulledby && living_target.pulledby.grab_state >= GRAB_AGGRESSIVE)
		successful_sneak_attack = TRUE

	// traits that render you unable to defend yourself properly from an attack
	else if(HAS_TRAIT(living_target, TRAIT_SPINNING) || HAS_TRAIT(living_target, TRAIT_HANDS_BLOCKED))
		successful_sneak_attack = TRUE

	// We'll take "same tile" as "behind" for ease
	else if(living_target.loc == user.loc)
		successful_sneak_attack = TRUE

	// We'll also assume lying down is vulnerable, as mob directions when lying are unclear and you have trouble defending yourself from prone
	else if(living_target.body_position == LYING_DOWN)
		successful_sneak_attack = TRUE

	// Now check for if we're behind
	var/dir_living_target_to_user = get_dir(living_target, user)
	if(living_target.dir & REVERSE_DIR(dir_living_target_to_user))
		successful_sneak_attack = TRUE

	/// Now we'll check for things that STOP a sneak attack. Why? Because this mechanic isn't complicated enough and I must insert more ivory tower design.

	if(living_target.mob_biotypes & MOB_SLIME) // SLIMES HAVE NO ANATOMY.
		successful_sneak_attack = FALSE
		sneak_attack_fail_message = TRUE

	else if(living_target.incorporeal_move >= 1 && !HAS_TRAIT(living_target, TRAIT_REVENANT_REVEALED)) // WE CAN'T SNEAK ATTACK INCORPOREAL JERKS. BUT WE CAN SNEAK ATTACK REVEALED REVENANTS BECAUSE DUH, NULLROD.
		successful_sneak_attack = FALSE
		sneak_attack_fail_message = TRUE

	else if(IS_HERETIC_MONSTER(living_target) && prob(50)) // IT IS HARD TO SNEAK ATTACK SOMETHING WITH TOO MANY REDUNDANT EVERYTHINGS.
		successful_sneak_attack = FALSE
		sneak_attack_fail_message = TRUE

	else if(HAS_TRAIT(living_target, TRAIT_STABLEHEART) && prob(50)) // THEIR ANATOMY IS FUCKING WEIRD.
		successful_sneak_attack = FALSE
		sneak_attack_fail_message = TRUE

	else if(HAS_TRAIT(living_target, TRAIT_MIND_READER) && !user.can_block_magic(MAGIC_RESISTANCE_MIND, charge_cost = 0)) // FORESIGHT SAYS 'FUCK YOU' TO SNEAK ATTACKERS. BUT IF YOU HAVE A TIN FOIL HAT, YOU'RE SAFE!
		successful_sneak_attack = FALSE
		sneak_attack_fail_message = TRUE

	else if(user.is_blind()) // YOU CAN'T STAB PRECISELY WHAT YOU CAN'T SEE.
		successful_sneak_attack = FALSE
		sneak_attack_fail_message = TRUE

	/// And so we return here if we are not entitled to a sneak attack.
	if(!successful_sneak_attack)
		if(sneak_attack_fail_message)
			user.balloon_alert(living_target, "sneak attack avoided!")
		return

	/// And now we'll deal with sneak attack damage modifiers.

	// If our target is also unconscious for some reason, we get even more damage. Coup de grace, motherfucker.
	if(HAS_TRAIT(living_target, TRAIT_KNOCKEDOUT))
		sneak_attack_dice += roll("1d6")
		new /obj/effect/temp_visual/crit(get_turf(living_target))

	// If the target is rebuked, we also add some additional damage. It is the closest thing to 'studying' your target, okay?
	if(living_target.has_status_effect(/datum/status_effect/rebuked))
		sneak_attack_dice += 2

	// If we're morbid, and the target has been dissected, we get an extra d6.
	// The chances of this occuring are quite low, as even having this weapon means you're locked out of becoming morbid as a chaplain, but when it does come up...
	// Or the coroner stole this blade to go hunt the recently dead...
	if(HAS_TRAIT(user, TRAIT_MORBID) && HAS_TRAIT(living_target, TRAIT_DISSECTED))
		sneak_attack_dice += roll("1d6")

	// Baton + this weapon might be a little too much fun so we're nerfing this combination outright.
	if(HAS_TRAIT(living_target, TRAIT_IWASBATONED))
		sneak_attack_dice *= 0.5

	// Affecting body part check.
	var/obj/item/bodypart/affecting = living_target.get_bodypart(user.get_random_valid_zone(user.zone_selected))
	// Target's armor value. Accounts for armor penetration even though we have no armour_penetration defined on the parent.
	var/armor_block = living_target.run_armor_check(affecting, MELEE, armour_penetration = armour_penetration)

	// We got a sneak attack!
	living_target.apply_damage(round(sneak_attack_dice, DAMAGE_PRECISION), BRUTE, def_zone = affecting, blocked = armor_block, wound_bonus = bare_wound_bonus, sharpness = SHARP_EDGED)
	living_target.balloon_alert(user, "sneak attack!")
	playsound(living_target, 'sound/weapons/guillotine.ogg', 50, TRUE)
