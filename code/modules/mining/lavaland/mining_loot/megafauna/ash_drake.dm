// Ash drake suit

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

/obj/item/clothing/suit/hooded/cloak/drake
	name = "drake armour"
	icon_state = "dragon"
	desc = "A suit of armour fashioned from the remains of an ash drake."
	armor_type = /datum/armor/cloak_drake
	hoodtype = /obj/item/clothing/head/hooded/cloakhood/drake
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	transparent_protection = HIDEGLOVES|HIDESUITSTORAGE|HIDEJUMPSUIT|HIDESHOES

/datum/armor/cloak_drake
	melee = 65
	bullet = 15
	laser = 40
	energy = 40
	bomb = 70
	bio = 60
	fire = 100
	acid = 100
	wound = 10

/obj/item/clothing/suit/hooded/cloak/drake/Initialize(mapload)
	. = ..()
	allowed = GLOB.mining_suit_allowed

/obj/item/clothing/head/hooded/cloakhood/drake
	name = "drake helm"
	icon = 'icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	icon_state = "dragon"
	desc = "The skull of a dragon."
	armor_type = /datum/armor/cloak_drake
	clothing_flags = SNUG_FIT
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

// Spectral blade

/obj/item/melee/ghost_sword
	name = "\improper spectral blade"
	desc = "A rusted and dulled blade. It doesn't look like it'd do much damage. It glows weakly."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "spectral"
	inhand_icon_state = "spectral"
	icon_angle = -45
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	obj_flags = CONDUCTS_ELECTRICITY
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_BULKY
	force = 5 // Breakpoint past which something counts as a weapon, usually
	throwforce = 5
	hitsound = 'sound/effects/ghost2.ogg'
	block_sound = 'sound/items/weapons/parry.ogg'
	attack_verb_continuous = list("attacks", "slashes", "slices", "tears", "lacerates", "rips", "dices", "rends")
	attack_verb_simple = list("attack", "slash", "slice", "tear", "lacerate", "rip", "dice", "rend")
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/list/mob/dead/observer/spirits
	var/list/alt_continuous = list("stabs", "pierces", "impales")
	var/list/alt_simple = list("stab", "pierce", "impale")
	COOLDOWN_DECLARE(summon_cooldown)

/obj/item/melee/ghost_sword/Initialize(mapload)
	. = ..()
	spirits = list()
	START_PROCESSING(SSobj, src)
	SSpoints_of_interest.make_point_of_interest(src)
	alt_continuous = string_list(alt_continuous)
	alt_simple = string_list(alt_simple)
	AddComponent(/datum/component/alternative_sharpness, SHARP_POINTY, alt_continuous, alt_simple)
	AddComponent(\
		/datum/component/butchering, \
		speed = 15 SECONDS, \
		effectiveness = 90, \
	)

/obj/item/melee/ghost_sword/Destroy()
	for(var/mob/dead/observer/ghost in spirits)
		ghost.RemoveInvisibility(type)
	spirits.Cut()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/melee/ghost_sword/attack_self(mob/user)
	if(!COOLDOWN_FINISHED(src, summon_cooldown))
		to_chat(user, span_warning("You just recently called out for aid. You don't want to annoy the spirits!"))
		return

	COOLDOWN_START(src, summon_cooldown, 60 SECONDS)
	to_chat(user, span_notice("You call out for aid, attempting to summon spirits to your side."))
	notify_ghosts(
		"[user.real_name] is raising [user.p_their()] [name], calling for your help!",
		source = user,
		ignore_key = POLL_IGNORE_SPECTRAL_BLADE,
		header = "Spectral blade",
	)

/obj/item/melee/ghost_sword/process()
	ghost_check()

/obj/item/melee/ghost_sword/proc/ghost_check()
	var/turf/cur_turf = get_turf(src)
	var/list/contents = cur_turf.get_all_contents()
	var/mob/dead/observer/current_spirits = list()
	for(var/atom/random_thing in contents)
		random_thing.transfer_observers_to(src)

	for(var/mob/dead/observer/ghost in orbiters?.orbiter_list)
		ghost.SetInvisibility(INVISIBILITY_NONE, id = type, priority = INVISIBILITY_PRIORITY_BASIC_ANTI_INVISIBILITY)
		current_spirits |= ghost

	for(var/mob/dead/observer/ghost in spirits - current_spirits)
		ghost.RemoveInvisibility(type)

	var/new_force = clamp((length(current_spirits) * 4), 0, 75)
	var/old_force = clamp((length(spirits) * 4), 0, 75)
	force += new_force - old_force
	spirits = current_spirits
	return length(spirits)

/obj/item/melee/ghost_sword/attack(mob/living/target, mob/living/carbon/human/user)
	var/ghost_counter = ghost_check()
	user.visible_message(span_danger("[user] strikes with the force of [ghost_counter] vengeful spirits!"))
	. = ..()

/obj/item/melee/ghost_sword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	var/ghost_counter = ghost_check()
	final_block_chance += clamp((ghost_counter * 5), 0, 75)
	owner.visible_message(span_danger("[owner] is protected by a ring of [ghost_counter] ghosts!"))
	return ..()

// Dragon's blood

/obj/item/dragons_blood
	name = "bottle of dragons blood"
	desc = "You're not actually going to drink this, are you?"
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "vial"

/obj/item/dragons_blood/attack_self(mob/living/carbon/human/user)
	if(!istype(user))
		return

	var/mob/living/carbon/human/consumer = user
	var/random = rand(1,4)

	switch(random)
		if(1)
			to_chat(user, span_danger("Your appearance morphs to that of a very small humanoid ash dragon! You get to look like a freak without the cool abilities."))
			consumer.dna.features = list(
				FEATURE_MUTANT_COLOR = "#A02720",
				FEATURE_TAIL_LIZARD = "Dark Tiger",
				FEATURE_TAIL = "None",
				FEATURE_SNOUT = "Sharp",
				FEATURE_HORNS = "Curled",
				FEATURE_EARS = "None",
				FEATURE_WINGS = "None",
				FEATURE_FRILLS = "None",
				FEATURE_SPINES = "Long",
				FEATURE_LIZARD_MARKINGS = "Dark Tiger Body",
				FEATURE_LEGS = DIGITIGRADE_LEGS,
			)
			consumer.set_eye_color("#FEE5A3")
			consumer.set_species(/datum/species/lizard)
		if(2)
			to_chat(user, span_danger("Your flesh begins to melt! Miraculously, you seem fine otherwise."))
			consumer.set_species(/datum/species/skeleton)
		if(3)
			to_chat(user, span_danger("Power courses through you! You can now shift your form at will."))
			var/datum/action/cooldown/spell/shapeshift/dragon/dragon_shapeshift = new(user.mind || user)
			dragon_shapeshift.Grant(user)
		if(4)
			to_chat(user, span_danger("You feel like you could walk straight through lava now."))
			ADD_TRAIT(user, TRAIT_LAVA_IMMUNE, type)

	playsound(user,'sound/items/drink.ogg', 30, TRUE)
	qdel(src)

// Lava staff

/obj/item/lava_staff
	name = "staff of lava"
	desc = "The ability to fill the emergency shuttle with lava. What more could you want out of life?"
	icon_state = "lavastaff"
	inhand_icon_state = "lavastaff"
	icon_angle = -45
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	icon = 'icons/obj/weapons/guns/magic.dmi'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_NORMAL
	force = 18
	damtype = BURN
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	attack_verb_continuous = list("sears", "clubs", "burn")
	attack_verb_simple = list("sear", "club", "burn")
	hitsound = 'sound/items/weapons/sear.ogg'
	var/turf_type = /turf/open/lava/smooth/weak
	var/transform_string = "lava"
	var/reset_turf_type = /turf/open/misc/asteroid/basalt
	var/reset_string = "basalt"
	var/create_cooldown = 10 SECONDS
	var/create_delay = 3 SECONDS
	var/reset_cooldown = 5 SECONDS
	var/static/list/banned_turfs = typecacheof(list(/turf/open/space, /turf/closed))
	COOLDOWN_DECLARE(use_cooldown)

/obj/item/lava_staff/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(interacting_with.atom_storage || SHOULD_SKIP_INTERACTION(interacting_with, src, user))
		return NONE

	return ranged_interact_with_atom(interacting_with, user, modifiers)

/obj/item/lava_staff/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!COOLDOWN_FINISHED(src, use_cooldown))
		return NONE

	if(is_type_in_typecache(interacting_with, banned_turfs))
		return NONE

	if(!(interacting_with in view(user.client.view, get_turf(user))))
		return NONE

	var/turf/open/target_turf = get_turf(interacting_with)
	if(!istype(target_turf))
		return NONE

	if(islava(target_turf))
		var/old_name = target_turf.name
		if(target_turf.TerraformTurf(reset_turf_type, flags = CHANGETURF_INHERIT_AIR))
			return ITEM_INTERACT_FAILURE

		COOLDOWN_START(src, use_cooldown, reset_cooldown)
		user.visible_message(span_danger("[user] turns \the [old_name] into [reset_string]!"))
		playsound(target_turf,'sound/effects/magic/fireball.ogg', 200, TRUE)
		return ITEM_INTERACT_SUCCESS

	var/obj/effect/temp_visual/lavastaff/lava_visual = new /obj/effect/temp_visual/lavastaff(target_turf)
	lava_visual.alpha = 0
	animate(lava_visual, alpha = 255, time = create_delay)
	user.visible_message(span_danger("[user] points [src] at [target_turf]!"))
	COOLDOWN_START(src, use_cooldown, create_delay + 1)

	if(!do_after(user, create_delay, target_turf))
		balloon_alert(user, "interrupted!")
		COOLDOWN_RESET(src, use_cooldown)
		qdel(lava_visual)
		return ITEM_INTERACT_FAILURE

	var/old_name = target_turf.name
	if(!target_turf.TerraformTurf(turf_type, flags = CHANGETURF_INHERIT_AIR))
		qdel(lava_visual)
		return ITEM_INTERACT_FAILURE

	user.visible_message(span_danger("[user] turns \the [old_name] into [transform_string]!"))
	message_admins("[ADMIN_LOOKUPFLW(user)] fired the lava staff at [ADMIN_VERBOSEJMP(target_turf)]")
	user.log_message("fired the lava staff at [AREACOORD(target_turf)].", LOG_ATTACK)
	COOLDOWN_START(src, use_cooldown, create_cooldown)
	playsound(target_turf,'sound/effects/magic/fireball.ogg', 200, TRUE)
	qdel(lava_visual)
	return ITEM_INTERACT_SUCCESS

/obj/effect/temp_visual/lavastaff
	icon_state = "lavastaff_warn"
	duration = 50

/turf/open/lava/smooth/weak
	lava_damage = 10
	lava_firestacks = 10
	temperature_damage = 2500
