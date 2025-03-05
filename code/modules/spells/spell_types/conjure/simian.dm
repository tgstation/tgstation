/datum/action/cooldown/spell/conjure/simian
	name = "Summon Simians"
	desc = "This spell reaches deep into the elemental plane of bananas (the monkey one, not the clown one), and \
		summons monkeys and gorillas that will promptly flip out and attack everything in sight. Fun! \
		Their lesser, easily manipulable minds will be convinced you are one of their allies, but only for a minute. Unless you also are a monkey."
	button_icon_state = "simian"
	sound = 'sound/music/antag/monkey.ogg'

	school = SCHOOL_CONJURATION
	cooldown_time = 1.5 MINUTES
	cooldown_reduction_per_rank = 15 SECONDS

	invocation = "OOGA OOGA OOGA!!!!"
	invocation_type = INVOCATION_SHOUT

	///Our gorilla transformation spell, additionally granted to the user at max level.
	var/datum/action/cooldown/spell/shapeshift/gorilla/gorilla_transformation

	summon_radius = 2
	summon_type = list(
		/mob/living/basic/gorilla/lesser,
		/mob/living/carbon/human/species/monkey/angry,
		/mob/living/carbon/human/species/monkey/angry, // Listed twice so it's twice as likely, this class doesn't use pick weight
	)
	summon_amount = 4

/datum/action/cooldown/spell/conjure/simian/Destroy()
	. = ..()
	QDEL_NULL(gorilla_transformation)

/datum/action/cooldown/spell/conjure/simian/level_spell(bypass_cap)
	. = ..()
	summon_amount++ // MORE, MOOOOORE
	if(spell_level == spell_max_level) // We reward the faithful.
		gorilla_transformation = new(owner)
		gorilla_transformation.Grant(owner)
		spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC // Max level lets you cast it naked, for monkey larp.
		to_chat(owner, span_notice("Your simian power has reached maximum capacity! You can now cast this spell naked, and have additionally been granted a gorilla transformation spell!"))

/datum/action/cooldown/spell/conjure/simian/cast(atom/cast_on)
	. = ..()
	var/mob/living/cast_mob = cast_on
	if(!istype(cast_mob))
		return
	if(FACTION_MONKEY in cast_mob.faction)
		return
	cast_mob.faction |= FACTION_MONKEY
	addtimer(CALLBACK(src, PROC_REF(remove_monky_faction), cast_mob), 1 MINUTES)

/datum/action/cooldown/spell/conjure/simian/proc/remove_monky_faction(mob/cast_mob)
	cast_mob.faction -= FACTION_MONKEY

/datum/action/cooldown/spell/conjure/simian/post_summon(atom/summoned_object, atom/cast_on)
	var/mob/living/alive_dude = summoned_object
	alive_dude.faction |= list(FACTION_MONKEY)
	if(ismonkey(alive_dude))
		equip_monky(alive_dude)
		return

/** Equips summoned monky with gear depending on how the roll plays out, affected by spell lvl.
 * Can give them bananas and garland or gatfruit and axes. Monkeys are comically inept, which balances out what might otherwise be a little crazy.
 */
/datum/action/cooldown/spell/conjure/simian/proc/equip_monky(mob/living/carbon/human/species/monkey/summoned_monkey)

	// These are advanced monkeys we're talking about
	var/datum/ai_controller/monkey/monky_controller = summoned_monkey.ai_controller
	monky_controller.set_trip_mode(mode = FALSE)
	summoned_monkey.fully_replace_character_name(summoned_monkey.real_name, "primal " + summoned_monkey.name)

	// Monkeys get a random gear tier, but it's more likely to be good the more leveled the spell is!
	var/monkey_gear_tier = rand(0, 5) + (spell_level - 1)
	monkey_gear_tier = min(monkey_gear_tier, 5)

	// Monkey weapons, ordered by tier
	var/static/list/monky_weapon = list(
		list(/obj/item/food/grown/banana, /obj/item/grown/bananapeel),
		list(/obj/item/tailclub, /obj/item/knife/combat/bone),
		list(/obj/item/shovel/serrated, /obj/item/spear/bamboospear),
		list(/obj/item/spear/bonespear, /obj/item/fireaxe/boneaxe),
		list(/obj/item/gun/syringe/blowgun, /obj/item/gun/ballistic/revolver),
	)

	var/list/options = monky_weapon[min(monkey_gear_tier, length(monky_weapon))]

	var/obj/item/weapon
	if(monkey_gear_tier != 0)
		var/weapon_type = pick(options)
		weapon = new weapon_type(summoned_monkey)
		summoned_monkey.equip_to_slot_or_del(weapon, ITEM_SLOT_HANDS)

	// Load the ammo
	if(istype(weapon, /obj/item/gun/syringe/blowgun))
		var/obj/item/reagent_containers/syringe/crude/tribal/syring = new(summoned_monkey)
		weapon.attackby(syring, summoned_monkey)

	// Wield the weapon!
	if(is_type_in_list(weapon, list(/obj/item/spear, /obj/item/fireaxe)))
		weapon.attack_self(summoned_monkey)

	// Fashionable ape wear, organised by tier
	var/static/list/monky_hats = list(
		null, // nothin here
		/obj/item/clothing/head/costume/garland,
		/obj/item/clothing/head/helmet/durathread,
		/obj/item/clothing/head/helmet/skull,
	)

	var/stylish_monkey_hat = monky_hats[min(monkey_gear_tier, length(monky_hats))]
	if(!isnull(stylish_monkey_hat))
		summoned_monkey.equip_to_slot_or_del(new stylish_monkey_hat(summoned_monkey), ITEM_SLOT_HEAD)
