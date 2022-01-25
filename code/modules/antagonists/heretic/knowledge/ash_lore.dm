/datum/heretic_knowledge/base_ash
	name = "Nightwatcher's Secret"
	desc = "Opens up the Path of Ash to you. Allows you to transmute a match with a kitchen knife, or its derivatives, into an Ashen Blade."
	gain_text = "The City Guard know their watch. If you ask them at night, they may tell you about the ashy lantern."
	banned_knowledge = list(
		/datum/heretic_knowledge/base_rust,
		/datum/heretic_knowledge/base_flesh,
		/datum/heretic_knowledge/final/rust_final,
		/datum/heretic_knowledge/final/flesh_final,
		/datum/heretic_knowledge/final/void_final,
		/datum/heretic_knowledge/base_void
	)
	next_knowledge = list(/datum/heretic_knowledge/ashen_grasp)
	required_atoms = list(/obj/item/knife, /obj/item/match)
	result_atoms = list(/obj/item/melee/sickly_blade/ash)
	cost = 1
	route = PATH_ASH

/datum/heretic_knowledge/spell/ashen_shift
	name = "Ashen Shift"
	gain_text = "The Nightwatcher was the first of them, his treason started it all."
	desc = "A short range jaunt that can help you escape from bad situations."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash
	next_knowledge = list(
		/datum/heretic_knowledge/ash_mark,
		/datum/heretic_knowledge/essence,
		/datum/heretic_knowledge/ashen_eyes
	)
	route = PATH_ASH

/datum/heretic_knowledge/ashen_grasp
	name = "Grasp of Ash"
	gain_text = "He knew how to walk between the planes."
	desc = "Empowers your Mansus Grasp to blind opponents you touch with it."
	cost = 1
	next_knowledge = list(/datum/heretic_knowledge/spell/ashen_shift)
	route = PATH_ASH

/datum/heretic_knowledge/ashen_grasp/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!iscarbon(target))
		return
	var/mob/living/carbon/blind_victim = target
	to_chat(blind_victim, span_danger("Your eyes burn horrifically!")) //pocket sand! also, this is the message that changeling blind stings use, and no, I'm not ashamed about reusing it
	blind_victim.become_nearsighted(EYE_DAMAGE)
	blind_victim.blind_eyes(5)
	blind_victim.blur_eyes(10)

/datum/heretic_knowledge/ashen_grasp/on_eldritch_blade(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!iscarbon(target))
		return
	var/mob/living/carbon/victim = target
	var/datum/status_effect/eldritch/effect = victim.has_status_effect(/datum/status_effect/eldritch/rust) || victim.has_status_effect(/datum/status_effect/eldritch/ash) || victim.has_status_effect(/datum/status_effect/eldritch/flesh) || victim.has_status_effect(/datum/status_effect/eldritch/void)
	if(effect)
		effect.on_effect()
		for(var/obj/effect/proc_holder/spell/targeted/touch/mansus_grasp/grasp in user.mind.spell_list)
			grasp.charge_counter = min(round(grasp.charge_counter + grasp.charge_max * 0.75), grasp.charge_max) // refunds 75% of charge.

/datum/heretic_knowledge/ashen_eyes
	name = "Ashen Eyes"
	gain_text = "Piercing eyes, guide me through the mundane."
	desc = "Allows you to craft thermal vision amulet by transmutating eyes with a glass shard."
	cost = 1
	next_knowledge = list(/datum/heretic_knowledge/spell/ashen_shift,/datum/heretic_knowledge/flesh_ghoul)
	required_atoms = list(/obj/item/organ/eyes,/obj/item/shard)
	result_atoms = list(/obj/item/clothing/neck/eldritch_amulet)

/datum/heretic_knowledge/ash_mark
	name = "Mark of Ash"
	gain_text = "The Nightwatcher was a very particular man, always watching in the dead of night. But in spite of his duty, he regularly tranced through the manse with his blazing lantern held high."
	desc = "Your Mansus Grasp now applies the Mark of Ash on hit. Attack the afflicted with your Sickly Blade to detonate the mark. Upon detonation, the Mark of Ash causes stamina damage and burn damage, and spreads to an additional nearby opponent. The damage decreases with each spread."
	cost = 2
	next_knowledge = list(/datum/heretic_knowledge/mad_mask)
	banned_knowledge = list(
		/datum/heretic_knowledge/rust_mark,
		/datum/heretic_knowledge/flesh_mark,
		/datum/heretic_knowledge/void_mark
	)
	route = PATH_ASH

/datum/heretic_knowledge/ash_mark/on_mansus_grasp(target,user,proximity_flag,click_parameters)
	. = ..()
	if(isliving(target))
		. = TRUE
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/eldritch/ash, 5)

/datum/heretic_knowledge/mad_mask
	name = "Mask of Madness"
	gain_text = "He walks the world, unnoticed by the masses."
	desc = "Allows you to transmute any mask, with a candle and a pair of eyes, to create a mask of madness, It causes passive stamina damage to everyone around the wearer and hallucinations, can be forced on a non believer to make him unable to take it off..."
	cost = 1
	result_atoms = list(/obj/item/clothing/mask/void_mask)
	required_atoms = list(/obj/item/organ/eyes,/obj/item/clothing/mask,/obj/item/candle)
	next_knowledge = list(
		/datum/heretic_knowledge/curse/corrosion,
		/datum/heretic_knowledge/ash_blade_upgrade,
		/datum/heretic_knowledge/curse/paralysis
	)
	route = PATH_ASH

/datum/heretic_knowledge/spell/flame_birth
	name = "Flame Birth"
	gain_text = "The Nightwatcher was a man of principles, and yet his power arose from the chaos he vowed to combat."
	desc = "A spell that steals some health from every burning person around you."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/targeted/fiery_rebirth
	next_knowledge = list(
		/datum/heretic_knowledge/spell/cleave,
		/datum/heretic_knowledge/summon/ashy,
		/datum/heretic_knowledge/final/ash_final
	)
	route = PATH_ASH

/datum/heretic_knowledge/ash_blade_upgrade
	name = "Fiery Blade"
	gain_text = "Blade in hand, he swung and swung as the ash fell from the skies. His city, his people... all burnt to cinders, and yet life still remained in his charred body."
	desc = "Your blade of choice will now light your enemies ablaze."
	cost = 2
	next_knowledge = list(/datum/heretic_knowledge/spell/flame_birth)
	banned_knowledge = list(
		/datum/heretic_knowledge/rust_blade_upgrade,
		/datum/heretic_knowledge/flesh_blade_upgrade,
		/datum/heretic_knowledge/void_blade_upgrade
	)
	route = PATH_ASH

/datum/heretic_knowledge/ash_blade_upgrade/on_eldritch_blade(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/burn_victim = target
		burn_victim.adjust_fire_stacks(1)
		burn_victim.IgniteMob()

/datum/heretic_knowledge/curse/corrosion
	name = "Curse of Corrosion"
	gain_text = "Cursed land, cursed man, cursed mind."
	desc = "Curse someone for 2 minutes of vomiting and major organ damage. Using a wirecutter, a pool of vomit, a heart and an item that the victim touched  with their bare hands."
	cost = 1
	required_atoms = list(/obj/item/wirecutters,/obj/effect/decal/cleanable/vomit,/obj/item/organ/heart)
	next_knowledge = list(
		/datum/heretic_knowledge/mad_mask,
		/datum/heretic_knowledge/spell/area_conversion
	)
	timer = 2 MINUTES

/datum/heretic_knowledge/curse/corrosion/curse(mob/living/chosen_mob)
	. = ..()
	chosen_mob.apply_status_effect(/datum/status_effect/corrosion_curse)

/datum/heretic_knowledge/curse/corrosion/uncurse(mob/living/chosen_mob)
	. = ..()
	chosen_mob.remove_status_effect(/datum/status_effect/corrosion_curse)

/datum/heretic_knowledge/curse/paralysis
	name = "Curse of Paralysis"
	gain_text = "Corrupt their flesh, make them bleed."
	desc = "Curse someone for 5 minutes of inability to walk. Sacrifice a knife, a pool of blood, a pair of legs, a hatchet and an item that the victim touched with their bare hands. "
	cost = 1
	required_atoms = list(/obj/item/bodypart/l_leg,/obj/item/bodypart/r_leg,/obj/item/hatchet)
	next_knowledge = list(/datum/heretic_knowledge/mad_mask,/datum/heretic_knowledge/summon/raw_prophet)
	timer = 5 MINUTES

/datum/heretic_knowledge/curse/paralysis/curse(mob/living/chosen_mob)
	. = ..()
	ADD_TRAIT(chosen_mob,TRAIT_PARALYSIS_L_LEG,MAGIC_TRAIT)
	ADD_TRAIT(chosen_mob,TRAIT_PARALYSIS_R_LEG,MAGIC_TRAIT)


/datum/heretic_knowledge/curse/paralysis/uncurse(mob/living/chosen_mob)
	. = ..()
	REMOVE_TRAIT(chosen_mob,TRAIT_PARALYSIS_L_LEG,MAGIC_TRAIT)
	REMOVE_TRAIT(chosen_mob,TRAIT_PARALYSIS_R_LEG,MAGIC_TRAIT)


/datum/heretic_knowledge/spell/cleave
	name = "Blood Cleave"
	gain_text = "At first I didn't understand these instruments of war, but the priest told me to use them regardless. Soon, he said, I would know them well."
	desc = "Gives AOE spell that causes heavy bleeding and blood loss."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/pointed/cleave
	next_knowledge = list(/datum/heretic_knowledge/spell/entropic_plume,/datum/heretic_knowledge/spell/flame_birth)

/datum/heretic_knowledge/final/ash_final
	name = "Ashlord's Rite"
	gain_text = "The Nightwatcher found the rite and shared it amongst mankind! For now I am one with the fire, WITNESS MY ASCENSION!"
	desc = "Bring 3 corpses onto a transmutation rune, you will become immune to fire, the vacuum of space, cold and other enviromental hazards and become overall sturdier to all other damages. You will gain a spell that passively creates ring of fire around you as well ,as you will gain a powerful ability that lets you create a wave of flames all around you."
	required_atoms = list(/mob/living/carbon/human)
	cost = 3
	route = PATH_ASH
	var/list/trait_list = list(
		TRAIT_RESISTHEAT,
		TRAIT_NOBREATH,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOFIRE
	)

/datum/heretic_knowledge/final/ash_final/on_finished_recipe(mob/living/user, list/atoms, loc)
	priority_announce("$^@&#*$^@(#&$(@&#^$&#^@# Fear the blaze, for the Ashlord, [user.real_name] has ascended! The flames shall consume all! $^@&#*$^@(#&$(@&#^$&#^@#","#$^@&#*$^@(#&$(@&#^$&#^@#", ANNOUNCER_SPANOMALIES)
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/fire_cascade/big)
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/fire_sworn)
	var/mob/living/carbon/human/ascendant = user
	ascendant.physiology.brute_mod *= 0.5
	ascendant.physiology.burn_mod *= 0.5
	ascendant.client?.give_award(/datum/award/achievement/misc/ash_ascension, ascendant)
	for(var/trait in trait_list)
		ADD_TRAIT(user, trait, MAGIC_TRAIT)
	return ..()
