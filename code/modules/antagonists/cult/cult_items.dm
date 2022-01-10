/obj/item/tome
	name = "arcane tome"
	desc = "An old, dusty tome with frayed edges and a sinister-looking cover."
	icon_state ="tome"
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL

/obj/item/melee/cultblade/dagger
	name = "ritual dagger"
	desc = "A strange dagger said to be used by sinister groups for \"preparing\" a corpse before sacrificing it to their dark gods."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	inhand_icon_state = "cultdagger"
	worn_icon_state = "render"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	w_class = WEIGHT_CLASS_SMALL
	force = 15
	throwforce = 25
	block_chance = 25
	wound_bonus = -10
	bare_wound_bonus = 20
	armour_penetration = 35

/obj/item/melee/cultblade/dagger/Initialize(mapload)
	. = ..()
	var/image/silicon_image = image(icon = 'icons/effects/blood.dmi' , icon_state = null, loc = src)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "cult_dagger", silicon_image)

	var/examine_text = {"Allows the scribing of blood runes of the cult of Nar'Sie.
Hitting a cult structure will unanchor or reanchor it. Cult Girders will be destroyed in a single blow.
Can be used to scrape blood runes away, removing any trace of them.
Striking another cultist with it will purge all holy water from them and transform it into unholy water.
Striking a noncultist, however, will tear their flesh."}

	AddComponent(/datum/component/cult_ritual_item, span_cult(examine_text))

/obj/item/melee/cultblade/dagger/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/block_message = "[owner] parries [attack_text] with [src]"
	if(owner.get_active_held_item() != src)
		block_message = "[owner] parries [attack_text] with [src] in their offhand"

	if(IS_CULTIST(owner) && prob(final_block_chance) && attack_type != PROJECTILE_ATTACK)
		new /obj/effect/temp_visual/cult/sparks(get_turf(owner))
		playsound(src, 'sound/weapons/parry.ogg', 100, TRUE)
		owner.visible_message(span_danger("[block_message]"))
		return TRUE
	else
		return FALSE

/obj/item/melee/cultblade
	name = "eldritch longsword"
	desc = "A sword humming with unholy energy. It glows with a dim red light."
	icon_state = "cultblade"
	inhand_icon_state = "cultblade"
	worn_icon_state = "cultblade"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	flags_1 = CONDUCT_1
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_BULKY
	force = 30 // whoever balanced this got beat in the head by a bible too many times good lord
	throwforce = 10
	block_chance = 50 // now it's officially a cult esword
	wound_bonus = -50
	bare_wound_bonus = 20
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "rends")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "rend")

/obj/item/melee/cultblade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 40, 100)

/obj/item/melee/cultblade/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(IS_CULTIST(owner) && prob(final_block_chance))
		new /obj/effect/temp_visual/cult/sparks(get_turf(owner))
		playsound(src, 'sound/weapons/parry.ogg', 100, TRUE)
		owner.visible_message(span_danger("[owner] parries [attack_text] with [src]!"))
		return TRUE
	else
		return FALSE

/obj/item/melee/cultblade/attack(mob/living/target, mob/living/carbon/human/user)
	if(!IS_CULTIST(user))
		user.Paralyze(100)
		user.dropItemToGround(src, TRUE)
		user.visible_message(span_warning("A powerful force shoves [user] away from [target]!"), \
				span_cultlarge("\"You shouldn't play with sharp things. You'll poke someone's eye out.\""))
		if(ishuman(user))
			var/mob/living/carbon/human/miscreant = user
			miscreant.apply_damage(rand(force/2, force), BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		else
			user.adjustBruteLoss(rand(force/2,force))
		return
	..()

/obj/item/melee/cultblade/ghost
	name = "eldritch sword"
	force = 19 //can't break normal airlocks
	item_flags = NEEDS_PERMIT | DROPDEL
	flags_1 = NONE
	block_chance = 25 //these dweebs don't get full block chance, because they're free cultists

/obj/item/melee/cultblade/ghost/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/melee/cultblade/pickup(mob/living/user)
	..()
	if(!IS_CULTIST(user))
		to_chat(user, span_cultlarge("\"I wouldn't advise that.\""))

/obj/item/cult_bastard
	name = "bloody bastard sword"
	desc = "An enormous sword used by Nar'Sien cultists to rapidly harvest the souls of non-believers."
	w_class = WEIGHT_CLASS_HUGE
	block_chance = 50
	throwforce = 20
	force = 35
	armour_penetration = 45
	throw_speed = 1
	throw_range = 3
	sharpness = SHARP_EDGED
	light_system = MOVABLE_LIGHT
	light_range = 4
	light_color = COLOR_RED
	attack_verb_continuous = list("cleaves", "slashes", "tears", "lacerates", "hacks", "rips", "dices", "carves")
	attack_verb_simple = list("cleave", "slash", "tear", "lacerate", "hack", "rip", "dice", "carve")
	icon_state = "cultbastard"
	inhand_icon_state = "cultbastard"
	hitsound = 'sound/weapons/bladeslice.ogg'
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	actions_types = list()
	item_flags = SLOWS_WHILE_IN_HAND
	var/datum/action/innate/dash/cult/jaunt
	var/datum/action/innate/cult/spin2win/linked_action
	var/spinning = FALSE
	var/spin_cooldown = 250
	var/dash_toggled = TRUE

/obj/item/cult_bastard/Initialize(mapload)
	. = ..()
	jaunt = new(src)
	linked_action = new(src)
	AddComponent(/datum/component/butchering, 50, 80)
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)

/obj/item/cult_bastard/Destroy()
	QDEL_NULL(jaunt)
	QDEL_NULL(linked_action)
	return ..()

/obj/item/cult_bastard/examine(mob/user)
	. = ..()
	if(length(contents))
		. += "<b>There are [length(contents)] souls trapped within the sword's core.</b>"
	else
		. += "The sword appears to be quite lifeless."

/obj/item/cult_bastard/can_be_pulled(user)
	return FALSE

/obj/item/cult_bastard/attack_self(mob/user)
	dash_toggled = !dash_toggled
	if(dash_toggled)
		to_chat(loc, span_notice("You raise [src] and prepare to jaunt with it."))
	else
		to_chat(loc, span_notice("You lower [src] and prepare to swing it normally."))

/obj/item/cult_bastard/pickup(mob/living/user)
	. = ..()
	if(!IS_CULTIST(user))
		to_chat(user, span_cultlarge("\"I wouldn't advise that.\""))
		force = 5
		return
	force = initial(force)
	jaunt.Grant(user, src)
	linked_action.Grant(user, src)
	user.update_icons()

/obj/item/cult_bastard/dropped(mob/user)
	. = ..()
	linked_action.Remove(user)
	jaunt.Remove(user)
	user.update_icons()

/obj/item/cult_bastard/IsReflect()
	if(spinning)
		playsound(src, pick('sound/weapons/effects/ric1.ogg', 'sound/weapons/effects/ric2.ogg', 'sound/weapons/effects/ric3.ogg', 'sound/weapons/effects/ric4.ogg', 'sound/weapons/effects/ric5.ogg'), 100, TRUE)
		return TRUE
	else
		..()

/obj/item/cult_bastard/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(prob(final_block_chance))
		if(attack_type == PROJECTILE_ATTACK)
			owner.visible_message(span_danger("[owner] deflects [attack_text] with [src]!"))
			playsound(src, pick('sound/weapons/effects/ric1.ogg', 'sound/weapons/effects/ric2.ogg', 'sound/weapons/effects/ric3.ogg', 'sound/weapons/effects/ric4.ogg', 'sound/weapons/effects/ric5.ogg'), 100, TRUE)
			return TRUE
		else
			playsound(src, 'sound/weapons/parry.ogg', 75, TRUE)
			owner.visible_message(span_danger("[owner] parries [attack_text] with [src]!"))
			return TRUE
	return FALSE

/obj/item/cult_bastard/afterattack(atom/target, mob/user, proximity, click_parameters)
	. = ..()
	if(dash_toggled && !proximity)
		jaunt.teleport(user, target)
		return
	if(!proximity)
		return
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(human_target.stat != CONSCIOUS)
			var/obj/item/soulstone/stone = new /obj/item/soulstone(src)
			stone.attack(human_target, user)
			if(!LAZYLEN(stone.contents))
				qdel(stone)
	if(istype(target, /obj/structure/constructshell) && length(contents))
		var/obj/item/soulstone/stone = contents[1]
		if(!istype(stone))
			stone.forceMove(drop_location())
		else if(!stone.transfer_to_construct(target, user) && !(locate(/mob/living/simple_animal/shade) in stone))
			qdel(stone)

/datum/action/innate/dash/cult
	name = "Rend the Veil"
	desc = "Use the sword to shear open the flimsy fabric of this reality and teleport to your target."
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "phaseshift"
	dash_sound = 'sound/magic/enter_blood.ogg'
	recharge_sound = 'sound/magic/exit_blood.ogg'
	beam_effect = "sendbeam"
	phasein = /obj/effect/temp_visual/dir_setting/cult/phase
	phaseout = /obj/effect/temp_visual/dir_setting/cult/phase/out

/datum/action/innate/dash/cult/IsAvailable()
	if(IS_CULTIST(owner) && current_charges)
		return TRUE
	else
		return FALSE



/datum/action/innate/cult/spin2win
	name = "Geometer's Fury"
	desc = "You draw on the power of the sword's ancient runes, spinning it wildly around you as you become immune to most attacks."
	background_icon_state = "bg_demon"
	button_icon_state = "sintouch"
	var/cooldown = 0
	var/mob/living/carbon/human/holder
	var/obj/item/cult_bastard/sword

/datum/action/innate/cult/spin2win/Grant(mob/user, obj/bastard)
	. = ..()
	sword = bastard
	holder = user

/datum/action/innate/cult/spin2win/IsAvailable()
	if(IS_CULTIST(holder) && cooldown <= world.time)
		return TRUE
	else
		return FALSE

/datum/action/innate/cult/spin2win/Activate()
	cooldown = world.time + sword.spin_cooldown
	holder.changeNext_move(50)
	holder.apply_status_effect(/datum/status_effect/sword_spin)
	sword.spinning = TRUE
	sword.block_chance = 100
	sword.slowdown += 1.5
	addtimer(CALLBACK(src, .proc/stop_spinning), 50)
	holder.update_action_buttons_icon()

/datum/action/innate/cult/spin2win/proc/stop_spinning()
	sword.spinning = FALSE
	sword.block_chance = 50
	sword.slowdown -= 1.5
	sleep(sword.spin_cooldown)
	holder.update_action_buttons_icon()

/obj/item/restraints/legcuffs/bola/cult
	name = "\improper Nar'Sien bola"
	desc = "A strong bola, bound with dark magic that allows it to pass harmlessly through Nar'Sien cultists. Throw it to trip and slow your victim."
	icon_state = "bola_cult"
	inhand_icon_state = "bola_cult"
	breakouttime = 6 SECONDS
	knockdown = 30

#define CULT_BOLA_PICKUP_STUN 6 SECONDS
/obj/item/restraints/legcuffs/bola/cult/attack_hand(mob/living/carbon/user, list/modifiers)
	. = ..()

	if(IS_CULTIST(user) || !iscarbon(user))
		return
	var/mob/living/carbon/carbon_user = user
	if(user.num_legs < 2 || carbon_user.legcuffed) //if they can't be ensnared, stun for the same time as it takes to breakout of bola
		to_chat(user, span_cultlarge("\"I wouldn't advise that.\""))
		user.dropItemToGround(src, TRUE)
		user.Paralyze(CULT_BOLA_PICKUP_STUN)
	else
		to_chat(user, span_warning("The bola seems to take on a life of its own!"))
		ensnare(user)
#undef CULT_BOLA_PICKUP_STUN


/obj/item/restraints/legcuffs/bola/cult/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/mob/hit_mob = hit_atom
	if (istype(hit_mob) && IS_CULTIST(hit_mob))
		return
	. = ..()


/obj/item/clothing/head/hooded/cult_hoodie
	name = "ancient cultist hood"
	icon_state = "culthood"
	desc = "A torn, dust-caked hood. Strange letters line the inside."
	flags_inv = HIDEFACE|HIDEHAIR|HIDEEARS
	flags_cover = HEADCOVERSEYES
	armor = list(MELEE = 40, BULLET = 30, LASER = 40,ENERGY = 40, BOMB = 25, BIO = 10, FIRE = 10, ACID = 10)
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT

/obj/item/clothing/suit/hooded/cultrobes
	name = "ancient cultist robes"
	desc = "A ragged, dusty set of robes. Strange letters line the inside."
	icon_state = "cultrobes"
	inhand_icon_state = "cultrobes"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor = list(MELEE = 40, BULLET = 30, LASER = 40,ENERGY = 40, BOMB = 25, BIO = 10, FIRE = 10, ACID = 10)
	flags_inv = HIDEJUMPSUIT
	cold_protection = CHEST|GROIN|LEGS|ARMS
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|ARMS
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie


/obj/item/clothing/head/hooded/cult_hoodie/alt
	name = "cultist hood"
	desc = "An armored hood worn by the followers of Nar'Sie."
	icon_state = "cult_hoodalt"
	inhand_icon_state = "cult_hoodalt"

/obj/item/clothing/suit/hooded/cultrobes/alt
	name = "cultist robes"
	desc = "An armored set of robes worn by the followers of Nar'Sie."
	icon_state = "cultrobesalt"
	inhand_icon_state = "cultrobesalt"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/alt

/obj/item/clothing/suit/hooded/cultrobes/alt/ghost
	item_flags = DROPDEL

/obj/item/clothing/suit/hooded/cultrobes/alt/ghost/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)


/obj/item/clothing/head/magus
	name = "magus helm"
	icon_state = "magus"
	inhand_icon_state = "magus"
	desc = "A helm worn by the followers of Nar'Sie."
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDEEARS|HIDEEYES|HIDESNOUT
	armor = list(MELEE = 50, BULLET = 30, LASER = 50,ENERGY = 50, BOMB = 25, BIO = 10, FIRE = 10, ACID = 10)
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH

/obj/item/clothing/suit/magusred
	name = "magus robes"
	desc = "A set of armored robes worn by the followers of Nar'Sie."
	icon_state = "magusred"
	inhand_icon_state = "magusred"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor = list(MELEE = 50, BULLET = 30, LASER = 50,ENERGY = 50, BOMB = 25, BIO = 10, FIRE = 10, ACID = 10)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/hooded/cultrobes/hardened
	name = "\improper Nar'Sien hardened armor"
	desc = "A heavily-armored exosuit worn by warriors of the Nar'Sien cult. It can withstand hard vacuum."
	icon_state = "cult_armor"
	inhand_icon_state = "cult_armor"
	w_class = WEIGHT_CLASS_BULKY
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade, /obj/item/tank/internals)
	armor = list(MELEE = 50, BULLET = 40, LASER = 50, ENERGY = 60, BOMB = 50, BIO = 30, FIRE = 100, ACID = 100)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/hardened
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	flags_inv = HIDEGLOVES | HIDESHOES | HIDEJUMPSUIT
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	resistance_flags = NONE

/obj/item/clothing/head/hooded/cult_hoodie/hardened
	name = "\improper Nar'Sien hardened helmet"
	desc = "A heavily-armored helmet worn by warriors of the Nar'Sien cult. It can withstand hard vacuum."
	icon_state = "cult_helmet"
	inhand_icon_state = "cult_helmet"
	armor = list(MELEE = 50, BULLET = 40, LASER = 50, ENERGY = 60, BOMB = 50, BIO = 30, FIRE = 100, ACID = 100)
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT | PLASMAMAN_HELMET_EXEMPT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	flash_protect = FLASH_PROTECTION_WELDER
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	resistance_flags = NONE

/obj/item/sharpener/cult
	name = "eldritch whetstone"
	desc = "A block, empowered by dark magic. Sharp weapons will be enhanced when used on the stone."
	icon_state = "cult_sharpener"
	uses = 1
	increment = 5
	max = 40
	prefix = "darkened"

/obj/item/sharpener/cult/update_icon_state()
	icon_state = "cult_sharpener[(uses == 0) ? "_used" : ""]"
	return ..()

/obj/item/clothing/suit/hooded/cultrobes/cult_shield
	name = "empowered cultist armor"
	desc = "Empowered armor which creates a powerful shield around the user."
	icon_state = "cult_armor"
	inhand_icon_state = "cult_armor"
	w_class = WEIGHT_CLASS_BULKY
	armor = list(MELEE = 50, BULLET = 40, LASER = 50,ENERGY = 50, BOMB = 50, BIO = 30, FIRE = 50, ACID = 60)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/cult_shield

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/setup_shielding()
	AddComponent(/datum/component/shielded, recharge_start_delay = 0 SECONDS, shield_icon_file = 'icons/effects/cult_effects.dmi', shield_icon = "shield-cult", run_hit_callback = CALLBACK(src, .proc/shield_damaged))

/// A proc for callback when the shield breaks, since cult robes are stupid and have different effects
/obj/item/clothing/suit/hooded/cultrobes/cult_shield/proc/shield_damaged(mob/living/wearer, attack_text, new_current_charges)
	wearer.visible_message(span_danger("[wearer]'s robes neutralize [attack_text] in a burst of blood-red sparks!"))
	new /obj/effect/temp_visual/cult/sparks(get_turf(wearer))
	if(new_current_charges == 0)
		wearer.visible_message(span_danger("The runed shield around [wearer] suddenly disappears!"))

/obj/item/clothing/head/hooded/cult_hoodie/cult_shield
	name = "empowered cultist helmet"
	desc = "Empowered helmet which creates a powerful shield around the user."
	icon_state = "cult_hoodalt"
	armor = list(MELEE = 50, BULLET = 40, LASER = 50,ENERGY = 50, BOMB = 50, BIO = 30, FIRE = 50, ACID = 60)

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/equipped(mob/living/user, slot)
	..()
	if(!IS_CULTIST(user))
		to_chat(user, span_cultlarge("\"I wouldn't advise that.\""))
		to_chat(user, span_warning("An overwhelming sense of nausea overpowers you!"))
		user.dropItemToGround(src, TRUE)
		user.Dizzy(30)
		user.Paralyze(100)

/obj/item/clothing/suit/hooded/cultrobes/berserker
	name = "flagellant's robes"
	desc = "Blood-soaked robes infused with dark magic; allows the user to move at inhuman speeds, but at the cost of increased damage."
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor = list(MELEE = -45, BULLET = -45, LASER = -45,ENERGY = -55, BOMB = -45, BIO = -45, FIRE = 0, ACID = 0)
	slowdown = -0.6
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/berserkerhood

/obj/item/clothing/head/hooded/cult_hoodie/berserkerhood
	name = "flagellant's hood"
	desc = "Blood-soaked hood infused with dark magic."
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/suit/hooded/cultrobes/berserker/equipped(mob/living/user, slot)
	..()
	if(!IS_CULTIST(user))
		to_chat(user, span_cultlarge("\"I wouldn't advise that.\""))
		to_chat(user, span_warning("An overwhelming sense of nausea overpowers you!"))
		user.dropItemToGround(src, TRUE)
		user.Dizzy(30)
		user.Paralyze(100)

/obj/item/clothing/glasses/hud/health/night/cultblind
	desc = "may Nar'Sie guide you through the darkness and shield you from the light."
	name = "zealot's blindfold"
	icon_state = "blindfold"
	inhand_icon_state = "blindfold"
	flash_protect = FLASH_PROTECTION_WELDER

/obj/item/clothing/glasses/hud/health/night/cultblind/equipped(mob/living/user, slot)
	..()
	if(user.stat != DEAD && !IS_CULTIST(user) && slot == ITEM_SLOT_EYES)
		to_chat(user, span_cultlarge("\"You want to be blind, do you?\""))
		user.dropItemToGround(src, TRUE)
		user.Dizzy(30)
		user.Paralyze(100)
		user.blind_eyes(30)

/obj/item/reagent_containers/glass/beaker/unholywater
	name = "flask of unholy water"
	desc = "Toxic to nonbelievers; reinvigorating to the faithful - this flask may be sipped or thrown."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "holyflask"
	color = "#333333"
	list_reagents = list(/datum/reagent/fuel/unholywater = 50)

///how many times can the shuttle be cursed?
#define MAX_SHUTTLE_CURSES 3
///if the max number of shuttle curses are used within this duration, the entire cult gets an achievement
#define SHUTTLE_CURSE_OMFG_TIMESPAN 10 SECONDS

/obj/item/shuttle_curse
	name = "cursed orb"
	desc = "You peer within this smokey orb and glimpse terrible fates befalling the emergency escape shuttle. "
	icon = 'icons/obj/cult.dmi'
	icon_state ="shuttlecurse"
	///how many times has the shuttle been cursed so far?
	var/static/totalcurses = 0
	///when was the first shuttle curse?
	var/static/first_curse_time
	///curse messages that have already been used
	var/static/list/remaining_curses

/obj/item/shuttle_curse/attack_self(mob/living/user)
	if(!IS_CULTIST(user))
		user.dropItemToGround(src, TRUE)
		user.Paralyze(100)
		to_chat(user, span_warning("A powerful force shoves you away from [src]!"))
		return
	if(totalcurses >= MAX_SHUTTLE_CURSES)
		to_chat(user, span_warning("You try to shatter the orb, but it remains as solid as a rock!"))
		to_chat(user, span_danger(span_big("It seems that the blood cult has exhausted its ability to curse the emergency escape shuttle. It would be unwise to create more cursed orbs or to continue to try to shatter this one.")))
		return
	if(locate(/obj/narsie) in SSpoints_of_interest.narsies)
		to_chat(user, span_warning("Nar'Sie is already on this plane, there is no delaying the end of all things."))
		return

	if(SSshuttle.emergency.mode == SHUTTLE_CALL)
		var/cursetime = 3 MINUTES
		var/timer = SSshuttle.emergency.timeLeft(1) + cursetime
		var/security_num = seclevel2num(get_security_level())
		var/set_coefficient = 1

		if(totalcurses == 0)
			first_curse_time = world.time

		switch(security_num)
			if(SEC_LEVEL_GREEN)
				set_coefficient = 2
			if(SEC_LEVEL_BLUE)
				set_coefficient = 1
			else
				set_coefficient = 0.5
		var/surplus = timer - (SSshuttle.emergencyCallTime * set_coefficient)
		SSshuttle.emergency.setTimer(timer)
		if(surplus > 0)
			SSshuttle.block_recall(surplus)
		totalcurses++
		to_chat(user, span_danger("You shatter the orb! A dark essence spirals into the air, then disappears."))
		playsound(user.loc, 'sound/effects/glassbr1.ogg', 50, TRUE)

		if(!remaining_curses)
			remaining_curses = strings(CULT_SHUTTLE_CURSE, "curse_announce")

		var/curse_message = pick_n_take(remaining_curses) || "Something has gone horrendously wrong..."

		curse_message += " The shuttle will be delayed by three minutes."
		priority_announce("[curse_message]", "System Failure", 'sound/misc/notice1.ogg')
		if(MAX_SHUTTLE_CURSES-totalcurses <= 0)
			to_chat(user, span_danger(span_big("You sense that the emergency escape shuttle can no longer be cursed. It would be unwise to create more cursed orbs.")))
		else if(MAX_SHUTTLE_CURSES-totalcurses == 1)
			to_chat(user, span_danger(span_big("You sense that the emergency escape shuttle can only be cursed one more time.")))
		else
			to_chat(user, span_danger(span_big("You sense that the emergency escape shuttle can only be cursed [MAX_SHUTTLE_CURSES-totalcurses] more times.")))

		if(totalcurses >= MAX_SHUTTLE_CURSES && (world.time < first_curse_time + SHUTTLE_CURSE_OMFG_TIMESPAN))
			var/omfg_message = pick_list(CULT_SHUTTLE_CURSE, "omfg_announce") || "LEAVE US ALONE!"
			addtimer(CALLBACK(GLOBAL_PROC, .proc/priority_announce, omfg_message, "Priority Alert", 'sound/misc/notice1.ogg', null, "Nanotrasen Department of Transportation: Central Command"), rand(2 SECONDS, 6 SECONDS))
			for(var/mob/iter_player as anything in GLOB.player_list)
				if(IS_CULTIST(iter_player))
					iter_player.client?.give_award(/datum/award/achievement/misc/cult_shuttle_omfg, iter_player)

		qdel(src)

#undef MAX_SHUTTLE_CURSES

/obj/item/cult_shift
	name = "veil shifter"
	desc = "This relic instantly teleports you, and anything you're pulling, forward by a moderate distance."
	icon = 'icons/obj/cult.dmi'
	icon_state ="shifter"
	var/uses = 4

/obj/item/cult_shift/examine(mob/user)
	. = ..()
	if(uses)
		. += span_cult("It has [uses] use\s remaining.")
	else
		. += span_cult("It seems drained.")

/obj/item/cult_shift/proc/handle_teleport_grab(turf/T, mob/user)
	var/mob/living/carbon/C = user
	if(C.pulling)
		var/atom/movable/pulled = C.pulling
		do_teleport(pulled, T, channel = TELEPORT_CHANNEL_CULT)
		. = pulled

/obj/item/cult_shift/attack_self(mob/user)
	if(!uses || !iscarbon(user))
		to_chat(user, span_warning("\The [src] is dull and unmoving in your hands."))
		return
	if(!IS_CULTIST(user))
		user.dropItemToGround(src, TRUE)
		step(src, pick(GLOB.alldirs))
		to_chat(user, span_warning("\The [src] flickers out of your hands, your connection to this dimension is too strong!"))
		return

	var/mob/living/carbon/C = user
	var/turf/mobloc = get_turf(C)
	var/turf/destination = get_teleport_loc(mobloc,C,9,1,3,1,0,1)

	if(destination)
		uses--
		if(uses <= 0)
			icon_state ="shifter_drained"
		playsound(mobloc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		new /obj/effect/temp_visual/dir_setting/cult/phase/out(mobloc, C.dir)

		var/atom/movable/pulled = handle_teleport_grab(destination, C)
		if(do_teleport(C, destination, channel = TELEPORT_CHANNEL_CULT))
			if(pulled)
				C.start_pulling(pulled) //forcemove resets pulls, so we need to re-pull
			new /obj/effect/temp_visual/dir_setting/cult/phase(destination, C.dir)
			playsound(destination, 'sound/effects/phasein.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			playsound(destination, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

	else
		to_chat(C, span_warning("The veil cannot be torn here!"))

/obj/item/flashlight/flare/culttorch
	name = "void torch"
	desc = "Used by veteran cultists to instantly transport items to their needful brethren."
	w_class = WEIGHT_CLASS_SMALL
	light_range = 1
	icon_state = "torch"
	inhand_icon_state = "torch"
	color = "#ff0000"
	on_damage = 15
	slot_flags = null
	on = TRUE
	var/charges = 5

/obj/item/flashlight/flare/culttorch/afterattack(atom/movable/A, mob/user, proximity)
	if(!proximity)
		return
	if(!IS_CULTIST(user))
		to_chat(user, "That doesn't seem to do anything useful.")
		return

	if(!istype(A, /obj/item))
		..()
		to_chat(user, span_warning("\The [src] can only transport items!"))
		return

	var/list/cultists = list()
	for(var/datum/mind/M as anything in get_antag_minds(/datum/antagonist/cult))
		if(M.current && M.current.stat != DEAD)
			cultists |= M.current
	var/mob/living/cultist_to_receive = tgui_input_list(user, "Who do you wish to call to [src]?", "Followers of the Geometer", (cultists - user))
	if(!Adjacent(user) || !src || QDELETED(src) || user.incapacitated())
		return
	if(isnull(cultist_to_receive))
		to_chat(user, "<span class='cult italic'>You require a destination!</span>")
		log_game("Void torch failed - no target")
		return
	if(cultist_to_receive.stat == DEAD)
		to_chat(user, "<span class='cult italic'>[cultist_to_receive] has died!</span>")
		log_game("Void torch failed - target died")
		return
	if(!IS_CULTIST(cultist_to_receive))
		to_chat(user, "<span class='cult italic'>[cultist_to_receive] is not a follower of the Geometer!</span>")
		log_game("Void torch failed - target was deconverted")
		return
	if(A in user.get_all_contents())
		to_chat(user, "<span class='cult italic'>[A] must be on a surface in order to teleport it!</span>")
		return
	to_chat(user, "<span class='cult italic'>You ignite [A] with \the [src], turning it to ash, but through the torch's flames you see that [A] has reached [cultist_to_receive]!</span>")
	cultist_to_receive.put_in_hands(A)
	charges--
	to_chat(user, "\The [src] now has [charges] charge\s.")
	if(charges == 0)
		qdel(src)

/obj/item/melee/cultblade/halberd
	name = "bloody halberd"
	desc = "A halberd with a volatile axehead made from crystallized blood. It seems linked to its creator. And, admittedly, more of a poleaxe than a halberd."
	icon_state = "occultpoleaxe0"
	base_icon_state = "occultpoleaxe"
	inhand_icon_state = "occultpoleaxe0"
	w_class = WEIGHT_CLASS_HUGE
	force = 17
	throwforce = 40
	throw_speed = 2
	armour_penetration = 30
	block_chance = 30
	slot_flags = null
	attack_verb_continuous = list("attacks", "slices", "shreds", "sunders", "lacerates", "cleaves")
	attack_verb_simple = list("attack", "slice", "shred", "sunder", "lacerate", "cleave")
	sharpness = SHARP_EDGED
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/datum/action/innate/cult/halberd/halberd_act
	var/wielded = FALSE // track wielded status on item

/obj/item/melee/cultblade/halberd/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/on_wield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)

/obj/item/melee/cultblade/halberd/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/butchering, 100, 90)
	AddComponent(/datum/component/two_handed, force_unwielded=17, force_wielded=24)

/// triggered on wield of two handed item
/obj/item/melee/cultblade/halberd/proc/on_wield(obj/item/source, mob/user)
	SIGNAL_HANDLER

	wielded = TRUE

/// triggered on unwield of two handed item
/obj/item/melee/cultblade/halberd/proc/on_unwield(obj/item/source, mob/user)
	SIGNAL_HANDLER

	wielded = FALSE

/obj/item/melee/cultblade/halberd/update_icon_state()
	icon_state = wielded ? "[base_icon_state]1" : "[base_icon_state]0"
	inhand_icon_state = wielded ? "[base_icon_state]1" : "[base_icon_state]0"
	return ..()

/obj/item/melee/cultblade/halberd/Destroy()
	if(halberd_act)
		QDEL_NULL(halberd_act)
	return ..()

/obj/item/melee/cultblade/halberd/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/turf/T = get_turf(hit_atom)
	if(isliving(hit_atom))
		var/mob/living/L = hit_atom
		if(IS_CULTIST(L))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
			if(L.put_in_active_hand(src))
				L.visible_message(span_warning("[L] catches [src] out of the air!"))
			else
				L.visible_message(span_warning("[src] bounces off of [L], as if repelled by an unseen force!"))
		else if(!..())
			if(!L.anti_magic_check())
				L.Paralyze(50)
			break_halberd(T)
	else
		..()

/obj/item/melee/cultblade/halberd/proc/break_halberd(turf/T)
	if(src)
		if(!T)
			T = get_turf(src)
		if(T)
			T.visible_message(span_warning("[src] shatters and melts back into blood!"))
			new /obj/effect/temp_visual/cult/sparks(T)
			new /obj/effect/decal/cleanable/blood/splatter(T)
			playsound(T, 'sound/effects/glassbr3.ogg', 100)
	qdel(src)

/obj/item/melee/cultblade/halberd/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(wielded)
		final_block_chance *= 2
	if(IS_CULTIST(owner) && prob(final_block_chance))
		if(attack_type == PROJECTILE_ATTACK)
			owner.visible_message(span_danger("[owner] deflects [attack_text] with [src]!"))
			playsound(get_turf(owner), pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, TRUE)
			new /obj/effect/temp_visual/cult/sparks(get_turf(owner))
			return TRUE
		else
			playsound(src, 'sound/weapons/parry.ogg', 100, TRUE)
			owner.visible_message(span_danger("[owner] parries [attack_text] with [src]!"))
			new /obj/effect/temp_visual/cult/sparks(get_turf(owner))
			return TRUE
	else
		return FALSE

/datum/action/innate/cult/halberd
	name = "Bloody Bond"
	desc = "Call the bloody halberd back to your hand!"
	background_icon_state = "bg_demon"
	button_icon_state = "bloodspear"
	var/obj/item/melee/cultblade/halberd/halberd
	var/cooldown = 0

/datum/action/innate/cult/halberd/Grant(mob/user, obj/blood_halberd)
	. = ..()
	halberd = blood_halberd
	button.screen_loc = "6:157,4:-2"
	button.moved = "6:157,4:-2"

/datum/action/innate/cult/halberd/Activate()
	if(owner == halberd.loc || cooldown > world.time)
		return
	var/halberd_location = get_turf(halberd)
	var/owner_location = get_turf(owner)
	if(get_dist(owner_location, halberd_location) > 10)
		to_chat(owner,span_cult("The halberd is too far away!"))
	else
		cooldown = world.time + 20
		if(isliving(halberd.loc))
			var/mob/living/current_owner = halberd.loc
			current_owner.dropItemToGround(halberd)
			current_owner.visible_message(span_warning("An unseen force pulls the bloody halberd from [current_owner]'s hands!"))
		halberd.throw_at(owner, 10, 2, owner)


/obj/item/gun/ballistic/rifle/enchanted/arcane_barrage/blood
	name = "blood bolt barrage"
	desc = "Blood for blood."
	color = "#ff0000"
	guns_left = 24
	mag_type = /obj/item/ammo_box/magazine/internal/blood
	fire_sound = 'sound/magic/wand_teleport.ogg'

/obj/item/gun/ballistic/rifle/enchanted/arcane_barrage/blood/can_trigger_gun(mob/living/user)
	. = ..()
	if(!IS_CULTIST(user))
		to_chat(user, span_cultlarge("\"Did you truly think that you could channel MY blood without my approval? Amusing, but futile.\""))
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			if(C.active_hand_index == 1)
				C.apply_damage(20, BRUTE, BODY_ZONE_L_ARM, wound_bonus = 20, sharpness = SHARP_EDGED) //oof ouch
			else
				C.apply_damage(20, BRUTE, BODY_ZONE_R_ARM, wound_bonus = 20, sharpness = SHARP_EDGED)
		qdel(src)
		return FALSE

/obj/item/ammo_box/magazine/internal/blood
	caliber = CALIBER_A762
	ammo_type = /obj/item/ammo_casing/magic/arcane_barrage/blood

/obj/item/ammo_casing/magic/arcane_barrage/blood
	projectile_type = /obj/projectile/magic/arcane_barrage/blood
	firing_effect_type = /obj/effect/temp_visual/cult/sparks

/obj/projectile/magic/arcane_barrage/blood
	name = "blood bolt"
	icon_state = "mini_leaper"
	nondirectional_sprite = TRUE
	damage_type = BRUTE
	impact_effect_type = /obj/effect/temp_visual/dir_setting/bloodsplatter

/obj/projectile/magic/arcane_barrage/blood/Bump(atom/target)
	var/turf/T = get_turf(target)
	playsound(T, 'sound/effects/splat.ogg', 50, TRUE)
	var/mob/mob_target = target

	if(mob_target && IS_CULTIST(mob_target))
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.stat != DEAD)
				H.reagents.add_reagent(/datum/reagent/fuel/unholywater, 4)
		if(isshade(target) || isconstruct(target))
			var/mob/living/simple_animal/M = target
			if(M.health+5 < M.maxHealth)
				M.adjustHealth(-5)
		new /obj/effect/temp_visual/cult/sparks(T)
		qdel(src)
	else
		..()

/obj/item/blood_beam
	name = "\improper magical aura"
	desc = "Sinister looking aura that distorts the flow of reality around it."
	icon = 'icons/obj/items_and_weapons.dmi'
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	icon_state = "disintegrate"
	inhand_icon_state = "disintegrate"
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	var/charging = FALSE
	var/firing = FALSE
	var/angle

/obj/item/blood_beam/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)


/obj/item/blood_beam/afterattack(atom/A, mob/living/user, proximity_flag, clickparams)
	. = ..()
	if(firing || charging)
		return
	if(ishuman(user))
		angle = get_angle(user, A)
	else
		qdel(src)
		return
	charging = TRUE
	INVOKE_ASYNC(src, .proc/charge, user)
	if(do_after(user, 9 SECONDS, target = user))
		firing = TRUE
		ADD_TRAIT(user, TRAIT_IMMOBILIZED, CULT_TRAIT)
		INVOKE_ASYNC(src, .proc/pewpew, user, clickparams)
		var/obj/structure/emergency_shield/cult/weak/N = new(user.loc)
		if(do_after(user, 9 SECONDS, target = user))
			user.Paralyze(40)
			to_chat(user, "<span class='cult italic'>You have exhausted the power of this spell!</span>")
		REMOVE_TRAIT(user, TRAIT_IMMOBILIZED, CULT_TRAIT)
		firing = FALSE
		if(N)
			qdel(N)
		qdel(src)
	charging = FALSE

/obj/item/blood_beam/proc/charge(mob/user)
	var/obj/O
	playsound(src, 'sound/magic/lightning_chargeup.ogg', 100, TRUE)
	for(var/i in 1 to 12)
		if(!charging)
			break
		if(i > 1)
			sleep(15)
		if(i < 4)
			O = new /obj/effect/temp_visual/cult/rune_spawn/rune1/inner(user.loc, 30, "#ff0000")
		else
			O = new /obj/effect/temp_visual/cult/rune_spawn/rune5(user.loc, 30, "#ff0000")
			new /obj/effect/temp_visual/dir_setting/cult/phase/out(user.loc, user.dir)
	if(O)
		qdel(O)

/obj/item/blood_beam/proc/pewpew(mob/user, proximity_flag)
	var/turf/targets_from = get_turf(src)
	var/spread = 40
	var/second = FALSE
	var/set_angle = angle
	for(var/i in 1 to 12)
		if(second)
			set_angle = angle - spread
			spread -= 8
		else
			sleep(15)
			set_angle = angle + spread
		second = !second //Handles beam firing in pairs
		if(!firing)
			break
		playsound(src, 'sound/magic/exit_blood.ogg', 75, TRUE)
		new /obj/effect/temp_visual/dir_setting/cult/phase(user.loc, user.dir)
		var/turf/temp_target = get_turf_in_angle(set_angle, targets_from, 40)
		for(var/turf/T in get_line(targets_from,temp_target))
			if (locate(/obj/effect/blessing, T))
				temp_target = T
				playsound(T, 'sound/machines/clockcult/ark_damage.ogg', 50, TRUE)
				new /obj/effect/temp_visual/at_shield(T, T)
				break
			T.narsie_act(TRUE, TRUE)
			for(var/mob/living/target in T.contents)
				if(IS_CULTIST(target))
					new /obj/effect/temp_visual/cult/sparks(T)
					if(ishuman(target))
						var/mob/living/carbon/human/H = target
						if(H.stat != DEAD)
							H.reagents.add_reagent(/datum/reagent/fuel/unholywater, 7)
					if(isshade(target) || isconstruct(target))
						var/mob/living/simple_animal/M = target
						if(M.health+15 < M.maxHealth)
							M.adjustHealth(-15)
						else
							M.health = M.maxHealth
				else
					var/mob/living/L = target
					if(L.density)
						L.Paralyze(20)
						L.adjustBruteLoss(45)
						playsound(L, 'sound/hallucinations/wail.ogg', 50, TRUE)
						L.emote("scream")
		user.Beam(temp_target, icon_state="blood_beam", time = 7, beam_type = /obj/effect/ebeam/blood)


/obj/effect/ebeam/blood
	name = "blood beam"

/obj/item/shield/mirror
	name = "mirror shield"
	desc = "An infamous shield used by Nar'Sien sects to confuse and disorient their enemies. Its edges are weighted for use as a throwing weapon - capable of disabling multiple foes with preternatural accuracy."
	icon_state = "mirror_shield" // eshield1 for expanded
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	force = 5
	throwforce = 15
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("bumps", "prods")
	attack_verb_simple = list("bump", "prod")
	hitsound = 'sound/weapons/smash.ogg'
	var/illusions = 2

/obj/item/shield/mirror/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(IS_CULTIST(owner))
		if(istype(hitby, /obj/projectile))
			var/obj/projectile/P = hitby
			if(P.damage_type == BRUTE || P.damage_type == BURN)
				if(P.damage >= 30)
					var/turf/T = get_turf(owner)
					T.visible_message(span_warning("The sheer force from [P] shatters the mirror shield!"))
					new /obj/effect/temp_visual/cult/sparks(T)
					playsound(T, 'sound/effects/glassbr3.ogg', 100)
					owner.Paralyze(25)
					qdel(src)
					return FALSE
			if(P.reflectable & REFLECT_NORMAL)
				return FALSE //To avoid reflection chance double-dipping with block chance
		. = ..()
		if(.)
			playsound(src, 'sound/weapons/parry.ogg', 100, TRUE)
			if(illusions > 0)
				illusions--
				addtimer(CALLBACK(src, /obj/item/shield/mirror.proc/readd), 450)
				if(prob(60))
					var/mob/living/simple_animal/hostile/illusion/M = new(owner.loc)
					M.faction = list("cult")
					M.Copy_Parent(owner, 70, 10, 5)
					M.move_to_delay = owner.cached_multiplicative_slowdown
				else
					var/mob/living/simple_animal/hostile/illusion/escape/E = new(owner.loc)
					E.Copy_Parent(owner, 70, 10)
					E.GiveTarget(owner)
					E.Goto(owner, owner.cached_multiplicative_slowdown, E.minimum_distance)
			return TRUE
	else
		if(prob(50))
			var/mob/living/simple_animal/hostile/illusion/H = new(owner.loc)
			H.Copy_Parent(owner, 100, 20, 5)
			H.faction = list("cult")
			H.GiveTarget(owner)
			H.move_to_delay = owner.cached_multiplicative_slowdown
			to_chat(owner, span_danger("<b>[src] betrays you!</b>"))
		return FALSE

/obj/item/shield/mirror/proc/readd()
	illusions++
	if(illusions == initial(illusions) && isliving(loc))
		var/mob/living/holder = loc
		to_chat(holder, "<span class='cult italic'>The shield's illusions are back at full strength!</span>")

/obj/item/shield/mirror/IsReflect()
	if(prob(block_chance))
		return TRUE
	return FALSE

/obj/item/shield/mirror/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/turf/T = get_turf(hit_atom)
	var/datum/thrownthing/D = throwingdatum
	if(isliving(hit_atom))
		var/mob/living/L = hit_atom
		if(IS_CULTIST(L))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
			if(L.put_in_active_hand(src))
				L.visible_message(span_warning("[L] catches [src] out of the air!"))
			else
				L.visible_message(span_warning("[src] bounces off of [L], as if repelled by an unseen force!"))
		else if(!..())
			if(!L.anti_magic_check())
				L.Paralyze(30)
				if(D?.thrower)
					for(var/mob/living/Next in orange(2, T))
						if(!Next.density || IS_CULTIST(Next))
							continue
						throw_at(Next, 3, 1, D.thrower)
						return
					throw_at(D.thrower, 7, 1, null)
	else
		..()
