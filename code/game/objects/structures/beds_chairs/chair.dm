#define DECLENT_PREPOSITION_S ((copytext_char(declent_ru(NOMINATIVE), 1, 2) in list("с", "С")) ? "со" : "с") // BANDASTATION EDIT

/obj/structure/chair
	name = "chair"
	desc = "Это стул, на нём сидят. Хочешь ты этого или нет."
	icon = 'icons/obj/chairs.dmi'
	icon_state = "chair"
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = 0 //you sit in a chair, not lay
	resistance_flags = NONE
	max_integrity = 100
	integrity_failure = 0.1
	custom_materials = list(/datum/material/iron =SHEET_MATERIAL_AMOUNT)
	layer = OBJ_LAYER
	interaction_flags_mouse_drop = ALLOW_RESTING

	var/buildstacktype = /obj/item/stack/sheet/iron
	var/buildstackamount = 1
	var/item_chair = /obj/item/chair // if null it can't be picked up
	///How much sitting on this chair influences fishing difficulty
	var/fishing_modifier = -5
	var/has_armrest = FALSE

/obj/structure/chair/Initialize(mapload)
	. = ..()
	if(prob(0.2))
		ru_names_rename(ru_names_list("tactical [name]", "тактический [declent_ru(NOMINATIVE)]", "тактического [declent_ru(GENITIVE)]", "тактическому [declent_ru(DATIVE)]", "тактический [declent_ru(ACCUSATIVE)]", "тактическим [declent_ru(INSTRUMENTAL)]", "тактическом [declent_ru(PREPOSITIONAL)]", gender = declent_ru("gender")))
		name = "tactical [name]"
		fishing_modifier -= 8
	MakeRotate()
	if(can_buckle && fishing_modifier)
		AddElement(/datum/element/adjust_fishing_difficulty, fishing_modifier)

/obj/structure/chair/buckle_feedback(mob/living/being_buckled, mob/buckler)
	if(HAS_TRAIT(being_buckled, TRAIT_RESTRAINED))
		return ..()

	if(being_buckled == buckler)
		being_buckled.visible_message(
			span_notice("[buckler] садится на [declent_ru(NOMINATIVE)]."),
			span_notice("Вы садитесь на [declent_ru(NOMINATIVE)]."),
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
		)
	else
		being_buckled.visible_message(
			span_notice("[buckler] усаживает [being_buckled] на [declent_ru(NOMINATIVE)]."),
			span_notice("[buckler] усаживает вас на [declent_ru(NOMINATIVE)]."),
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
		)

/obj/structure/chair/unbuckle_feedback(mob/living/being_unbuckled, mob/unbuckler)
	if(HAS_TRAIT(being_unbuckled, TRAIT_RESTRAINED))
		return ..()

	if(being_unbuckled == unbuckler)
		being_unbuckled.visible_message(
			span_notice("[unbuckler] встаёт [DECLENT_PREPOSITION_S] [declent_ru(GENITIVE)]."),
			span_notice("Вы встаёте [DECLENT_PREPOSITION_S] [declent_ru(GENITIVE)]."),
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
		)
	else
		being_unbuckled.visible_message(
			span_notice("[unbuckler] помогает [being_unbuckled] встать [DECLENT_PREPOSITION_S] [declent_ru(GENITIVE)]."),
			span_notice("[unbuckler] помогает вам встать [DECLENT_PREPOSITION_S] [declent_ru(GENITIVE)]."),
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
		)

/obj/structure/chair/examine(mob/user)
	. = ..()
	. += span_notice("[capitalize(declent_ru(NOMINATIVE))] скрепле[genderize_ru(gender, "н", "на", "но", "ны")] парой <b>болтов</b>.")
	if(!has_buckled_mobs() && can_buckle)
		. += span_notice("Перетащите на него своего персонажа, чтобы сесть.")

///This proc adds the rotate component, overwrite this if you for some reason want to change some specific args.
/obj/structure/chair/proc/MakeRotate()
	AddElement(/datum/element/simple_rotation, ROTATION_IGNORE_ANCHORED|ROTATION_GHOSTS_ALLOWED)

/obj/structure/chair/Destroy()
	SSjob.latejoin_trackers -= src //These may be here due to the arrivals shuttle
	return ..()

/obj/structure/chair/atom_deconstruct(disassembled)
	if(buildstacktype)
		new buildstacktype(loc,buildstackamount)
	else
		for(var/datum/material/mat as anything in custom_materials)
			new mat.sheet_type(loc, FLOOR(custom_materials[mat] / SHEET_MATERIAL_AMOUNT, 1))

/obj/structure/chair/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/chair/narsie_act()
	var/obj/structure/chair/wood/W = new/obj/structure/chair/wood(get_turf(src))
	W.setDir(dir)
	qdel(src)

/obj/structure/chair/attackby(obj/item/W, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(W, /obj/item/assembly/shock_kit) && !HAS_TRAIT(src, TRAIT_ELECTRIFIED_BUCKLE))
		electrify_self(W, user)
		return
	. = ..()

/obj/structure/chair/update_overlays()
	. = ..()
	if (!has_buckled_mobs())
		return
	var/mutable_appearance/armrest = mutable_appearance(icon, "[icon_state]_armrest", ABOVE_MOB_LAYER, src, appearance_flags = KEEP_APART)
	var/mutable_appearance/armrest_blocker = emissive_blocker(icon, "[icon_state]_armrest", src, ABOVE_MOB_LAYER)
	if (cached_color_filter)
		armrest = filter_appearance_recursive(armrest, cached_color_filter)
	. += armrest
	. += armrest_blocker

///allows each chair to request the electrified_buckle component with overlays that dont look ridiculous
/obj/structure/chair/proc/electrify_self(obj/item/assembly/shock_kit/input_shock_kit, mob/user, list/overlays_from_child_procs)
	SHOULD_CALL_PARENT(TRUE)
	if(!user.temporarilyRemoveItemFromInventory(input_shock_kit))
		return
	if(!overlays_from_child_procs || overlays_from_child_procs.len == 0)
		var/mutable_appearance/echair_overlay = mutable_appearance('icons/obj/chairs.dmi', "echair_over", OBJ_LAYER, src, appearance_flags = KEEP_APART)
		AddComponent(/datum/component/electrified_buckle, (SHOCK_REQUIREMENT_ITEM | SHOCK_REQUIREMENT_LIVE_CABLE | SHOCK_REQUIREMENT_SIGNAL_RECEIVED_TOGGLE), input_shock_kit, list(echair_overlay), FALSE)
	else
		AddComponent(/datum/component/electrified_buckle, (SHOCK_REQUIREMENT_ITEM | SHOCK_REQUIREMENT_LIVE_CABLE | SHOCK_REQUIREMENT_SIGNAL_RECEIVED_TOGGLE), input_shock_kit, overlays_from_child_procs, FALSE)

	if(HAS_TRAIT(src, TRAIT_ELECTRIFIED_BUCKLE))
		to_chat(user, span_notice("Вы прикручиваете набор шокера к [declent_ru(DATIVE)], электризуя его!"))
	else
		user.put_in_active_hand(input_shock_kit)
		to_chat(user, span_notice("Вы не можете прицепить набор шокера к [declent_ru(DATIVE)]!"))


/obj/structure/chair/wrench_act_secondary(mob/living/user, obj/item/weapon)
	..()
	weapon.play_tool_sound(src)
	deconstruct(disassembled = TRUE)
	return TRUE

/obj/structure/chair/attack_tk(mob/user)
	if(!anchored || has_buckled_mobs() || !isturf(user.loc))
		return ..()
	setDir(turn(dir,-90))
	return COMPONENT_CANCEL_ATTACK_CHAIN


/obj/structure/chair/proc/handle_rotation(direction)
	handle_layer()
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.setDir(direction)

/obj/structure/chair/proc/handle_layer()
	if(has_buckled_mobs() && dir == NORTH)
		layer = ABOVE_MOB_LAYER
	else
		layer = OBJ_LAYER

/obj/structure/chair/post_buckle_mob(mob/living/M)
	. = ..()
	handle_layer()
	if (has_armrest)
		update_appearance()

/obj/structure/chair/post_unbuckle_mob()
	. = ..()
	handle_layer()
	if (has_armrest)
		update_appearance()

/obj/structure/chair/setDir(newdir)
	..()
	handle_rotation(newdir)

// Chair types

///Material chair
/obj/structure/chair/greyscale
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	item_chair = /obj/item/chair/greyscale
	buildstacktype = null //Custom mats handle this


/obj/structure/chair/wood
	icon_state = "wooden_chair"
	name = "wooden chair"
	desc = "Крафт нынче в моде."
	resistance_flags = FLAMMABLE
	max_integrity = 40
	buildstacktype = /obj/item/stack/sheet/mineral/wood
	buildstackamount = 3
	item_chair = /obj/item/chair/wood
	fishing_modifier = -6
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT * 3)

/obj/structure/chair/wood/narsie_act()
	return

/obj/structure/chair/wood/wings
	icon_state = "wooden_chair_wings"
	item_chair = /obj/item/chair/wood/wings

/obj/structure/chair/comfy
	name = "comfy chair"
	desc = "Выглядит уютненько."
	icon_state = "comfychair"
	color = rgb(255, 255, 255)
	resistance_flags = FLAMMABLE
	max_integrity = 70
	buildstackamount = 2
	item_chair = null
	fishing_modifier = -7
	has_armrest = TRUE
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2)

/obj/structure/chair/comfy/brown
	color = rgb(70, 47, 28)

/obj/structure/chair/comfy/beige
	color = rgb(240, 238, 198)

/obj/structure/chair/comfy/teal
	color = rgb(117, 214, 214)

/obj/structure/chair/comfy/black
	color = rgb(61, 60, 56)

/obj/structure/chair/comfy/lime
	color = rgb(193, 248, 104)

/obj/structure/chair/comfy/shuttle
	name = "shuttle seat"
	desc = "Крепкое и комфортное кресло для дальних космических перелётов. Оборудовано надголовным ограничителем чтобы вас не выкинуло в стену при жёсткой посадке."
	icon_state = "shuttle_chair"
	buildstacktype = /obj/item/stack/sheet/mineral/titanium
	buckle_sound = SFX_SEATBELT_BUCKLE
	unbuckle_sound = SFX_SEATBELT_UNBUCKLE
	resistance_flags = FIRE_PROOF
	max_integrity = 120
	custom_materials = list(/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 2)

/obj/structure/chair/comfy/shuttle/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/structure/chair/comfy/shuttle/electrify_self(obj/item/assembly/shock_kit/input_shock_kit, mob/user, list/overlays_from_child_procs)
	if(!overlays_from_child_procs)
		var/mutable_appearance/echair_overlay = mutable_appearance('icons/obj/chairs.dmi', "echair_over", OBJ_LAYER, src, appearance_flags = KEEP_APART)
		echair_overlay.pixel_x = -1
		overlays_from_child_procs = list(echair_overlay)
	. = ..()

/obj/structure/chair/comfy/shuttle/buckle_feedback(mob/living/being_buckled, mob/buckler)
	if(being_buckled == buckler)
		being_buckled.visible_message(
			span_notice("[buckler] усаживается в [declent_ru(NOMINATIVE)], опуская ограничитель."),
			span_notice("Вы усаживаетесь в [declent_ru(NOMINATIVE)], опуская ограничитель."),
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
		)
	else
		being_buckled.visible_message(
			span_notice("[buckler] усаживает [being_buckled] в [declent_ru(NOMINATIVE)], опуская ограничитель."),
			span_notice("[buckler] усаживает вас в [declent_ru(NOMINATIVE)], опуская ограничитель."),
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
		)

/obj/structure/chair/comfy/shuttle/unbuckle_feedback(mob/living/being_unbuckled, mob/unbuckler)
	if(being_unbuckled == unbuckler)
		being_unbuckled.visible_message(
			span_notice("[unbuckler] откидывает ограничитель вверх, вставая [DECLENT_PREPOSITION_S] [declent_ru(GENITIVE)]."),
			span_notice("Вы откидываете ограничители вверх, вставая [DECLENT_PREPOSITION_S] [declent_ru(GENITIVE)]."),
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
		)
	else
		being_unbuckled.visible_message(
			span_notice("[unbuckler] откидывает ограничитель вверх, поднимая [being_unbuckled] [DECLENT_PREPOSITION_S] [declent_ru(GENITIVE)]."),
			span_notice("[unbuckler] откидывает ограничитель вверх, поднимая вас [DECLENT_PREPOSITION_S] [declent_ru(GENITIVE)]."),
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
		)

/obj/structure/chair/comfy/shuttle/update_overlays()
	. = ..()
	if(has_buckled_mobs())
		. += mutable_appearance(icon, "[icon_state]_down_front", ABOVE_MOB_LAYER + 0.01)
		. += mutable_appearance(icon, "[icon_state]_down_behind", src.layer + 0.01)
	else
		. += mutable_appearance(icon, "[icon_state]_up", src.layer + 0.01)

/obj/structure/chair/comfy/shuttle/tactical
	name = "tactical chair"

/obj/structure/chair/comfy/carp
	name = "carpskin chair"
	desc = "Роскошное кресло. Множество пурпурных чешуек красиво переливаются на свету."
	icon_state = "carp_chair"
	buildstacktype = /obj/item/stack/sheet/animalhide/carp
	fishing_modifier = -12
	custom_materials = null

/obj/structure/chair/office
	name = "office chair"
	anchored = FALSE
	buildstackamount = 5
	item_chair = null
	fishing_modifier = -6
	icon_state = "officechair_dark"
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5)

/obj/structure/chair/office/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noisy_movement)

/obj/structure/chair/office/electrify_self(obj/item/assembly/shock_kit/input_shock_kit, mob/user, list/overlays_from_child_procs)
	if(!overlays_from_child_procs)
		var/mutable_appearance/echair_overlay = mutable_appearance('icons/obj/chairs.dmi', "echair_over", OBJ_LAYER, src, appearance_flags = KEEP_APART)
		echair_overlay.pixel_x = -1
		overlays_from_child_procs = list(echair_overlay)
	. = ..()

/obj/structure/chair/office/tactical
	name = "tactical swivel chair"
	fishing_modifier = -10

/obj/structure/chair/office/light
	name = "office chair"
	icon_state = "officechair_white"

//Stool

/obj/structure/chair/stool
	name = "stool"
	desc = "Присядьте."
	icon_state = "stool"
	buildstackamount = 1
	item_chair = /obj/item/chair/stool
	max_integrity = 300

/obj/structure/chair/stool/post_buckle_mob(mob/living/Mob)
	Mob.add_offsets(type, z_add = 4)
	. = ..()

/obj/structure/chair/stool/post_unbuckle_mob(mob/living/Mob)
	Mob.remove_offsets(type)

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/chair/stool, 0)

/obj/structure/chair/stool/narsie_act()
	return

/obj/structure/chair/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	if(!isliving(user) || over_object != user)
		return
	if(!item_chair || has_buckled_mobs())
		return
	if(flags_1 & HOLOGRAM_1)
		to_chat(user, span_notice("Вы пытаетесь поднять [declent_ru(ACCUSATIVE)], но он растворяется!"))
		qdel(src)
		return

	user.visible_message(span_notice("[user] хватает [declent_ru(ACCUSATIVE)]."), span_notice("Вы хватаете [declent_ru(ACCUSATIVE)]."))
	var/obj/item/chair_item = new item_chair(loc)
	chair_item.set_custom_materials(custom_materials)
	TransferComponents(chair_item)
	chair_item.update_integrity(get_integrity())
	user.put_in_hands(chair_item)
	qdel(src)

/obj/structure/chair/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	return ..()

/obj/structure/chair/stool/bar
	name = "bar stool"
	desc = "Фу, он липкий."
	icon_state = "bar"
	item_chair = /obj/item/chair/stool/bar

/obj/structure/chair/stool/bar/post_buckle_mob(mob/living/Mob)
	. = ..()
	Mob.add_offsets(type, z_add = 7)

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/chair/stool/bar, 0)

/obj/structure/chair/stool/bamboo
	name = "bamboo stool"
	desc = "Небрежно сколоченный табурет. О таком бы сказали «винтаж», но ценителей среди нас не найдёшь."
	icon_state = "bamboo_stool"
	resistance_flags = FLAMMABLE
	max_integrity = 40
	buildstacktype = /obj/item/stack/sheet/mineral/bamboo
	buildstackamount = 2
	item_chair = /obj/item/chair/stool/bamboo
	custom_materials = list(/datum/material/bamboo = SHEET_MATERIAL_AMOUNT * 2)

/obj/item/chair
	name = "chair"
	desc = "Незаменим для барной потасовки."
	icon = 'icons/obj/chairs.dmi'
	icon_state = "chair_toppled"
	inhand_icon_state = "chair"
	icon_angle = 180
	lefthand_file = 'icons/mob/inhands/items/chairs_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/chairs_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	force = 8
	throwforce = 10
	demolition_mod = 1.25
	throw_range = 3
	max_integrity = 100
	hitsound = 'sound/items/trayhit/trayhit1.ogg'
	hit_reaction_chance = 50
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)
	item_flags = SKIP_FANTASY_ON_SPAWN

	// Duration of daze inflicted when the chair is smashed against someone from behind.
	var/daze_amount = 3 SECONDS

	// What structure type does this chair become when placed?
	var/obj/structure/chair/origin_type = /obj/structure/chair

/obj/item/chair/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/cuffable_item)

/obj/item/chair/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] заносит над собой [declent_ru(NOMINATIVE)]! Кажется, [user.ru_p_they()] пытается совершить самоубийство!"))
	playsound(src,hitsound,50,TRUE)
	return BRUTELOSS

/obj/item/chair/narsie_act()
	var/obj/item/chair/wood/W = new/obj/item/chair/wood(get_turf(src))
	W.setDir(dir)
	qdel(src)

/obj/item/chair/attack_self(mob/user)
	plant(user)

/obj/item/chair/proc/plant(mob/user)
	var/turf/turf = user.loc
	if(!istype(turf) || isgroundlessturf(turf))
		to_chat(user, span_warning("Вам нужна твёрдая поверхность, чтобы поставить [declent_ru(NOMINATIVE)]!"))
		return
	if(!user.dropItemToGround(src))
		to_chat(user, span_warning("[declent_ru(NOMINATIVE)] прилип[genderize_ru(gender, "", "ла", "ло", "ли")] к вашей руке!"))
		return
	if(flags_1 & HOLOGRAM_1)
		to_chat(user, span_notice("Вы пытаетесь поставить [declent_ru(ACCUSATIVE)], но он растворяется!"))
		qdel(src)
		return

	for(var/obj/object in turf)
		if(istype(object, /obj/structure/chair))
			to_chat(user, span_warning("Здесь уже есть [declent_ru(NOMINATIVE)]!"))
			return
		if(object.density && !(object.flags_1 & ON_BORDER_1))
			to_chat(user, span_warning("Здесь уже что-то есть!"))
			return

	user.visible_message(span_notice("[user] ставит [declent_ru(ACCUSATIVE)]."), span_notice("Вы ставите [declent_ru(ACCUSATIVE)]."))
	var/obj/structure/chair/chair = new origin_type(turf)
	chair.set_custom_materials(custom_materials)
	TransferComponents(chair)
	chair.setDir(user.dir)
	chair.update_integrity(get_integrity())
	qdel(src)

/obj/item/chair/proc/smash(mob/living/user)
	var/stack_type = initial(origin_type.buildstacktype)
	if(!stack_type)
		return
	var/remaining_mats = initial(origin_type.buildstackamount)
	remaining_mats-- //Part of the chair was rendered completely unusable. It magically disappears. Maybe make some dirt?
	if(remaining_mats)
		for(var/M=1 to remaining_mats)
			new stack_type(get_turf(loc))
	else if(custom_materials[SSmaterials.get_material(/datum/material/iron)])
		new /obj/item/stack/rods(get_turf(loc), 2)
	qdel(src)

/obj/item/chair/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	if(attack_type == UNARMED_ATTACK && prob(hit_reaction_chance) || attack_type == LEAP_ATTACK && prob(hit_reaction_chance))
		owner.visible_message(span_danger("[owner] отражает [attack_text] с помощью [declent_ru(GENITIVE)]!"))
		if(take_chair_damage(damage, damage_type, MELEE)) // Our chair takes our incoming damage for us, which can result in it smashing.
			smash(owner)
		return TRUE
	return FALSE

/obj/item/chair/afterattack(atom/target, mob/user, list/modifiers, list/attack_modifiers)
	if(!ishuman(target))
		return

	var/mob/living/carbon/human/give_this_fucker_the_chair = target

	// Here we determine if our attack is against a vulnerable target
	var/vulnerable_hit = check_behind(user, give_this_fucker_the_chair)

	// If our attack is against a vulnerable target, we do additional damage to the chair
	var/damage_to_inflict = vulnerable_hit ? (force * 5) : (force * 2.5)

	if(!take_chair_damage(damage_to_inflict, damtype, MELEE)) // If we would do enough damage to bring our chair's integrity to 0, we instead go past the check to smash it against our target
		return

	user.visible_message(span_danger("[user] разбивает [declent_ru(ACCUSATIVE)] в щепки об [give_this_fucker_the_chair]"))
	if(!HAS_TRAIT(give_this_fucker_the_chair, TRAIT_BRAWLING_KNOCKDOWN_BLOCKED))
		if(vulnerable_hit || give_this_fucker_the_chair.get_timed_status_effect_duration(/datum/status_effect/staggered))
			give_this_fucker_the_chair.Knockdown(2 SECONDS, daze_amount = daze_amount)
			if(give_this_fucker_the_chair.health < give_this_fucker_the_chair.maxHealth*0.5)
				give_this_fucker_the_chair.adjust_confusion(10 SECONDS)

	smash(user)

/obj/item/chair/proc/take_chair_damage(damage_to_inflict, damage_type, armor_flag)
	if(damage_to_inflict >= atom_integrity)
		return TRUE
	take_damage(damage_to_inflict, damage_type, armor_flag)
	return FALSE

/obj/item/chair/greyscale
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	origin_type = /obj/structure/chair/greyscale

/obj/item/chair/stool
	name = "stool"
	icon_state = "stool_toppled"
	inhand_icon_state = "stool"
	origin_type = /obj/structure/chair/stool
	max_integrity = 300 //It's too sturdy.

/obj/item/chair/stool/bar
	name = "bar stool"
	icon_state = "bar_toppled"
	inhand_icon_state = "stool_bar"
	origin_type = /obj/structure/chair/stool/bar

/obj/item/chair/stool/bamboo
	name = "bamboo stool"
	icon_state = "bamboo_stool"
	inhand_icon_state = "stool_bamboo"
	hitsound = 'sound/items/weapons/genhit1.ogg'
	origin_type = /obj/structure/chair/stool/bamboo
	max_integrity = 40 //Submissive and breakable unlike the chad iron stool
	daze_amount = 0 //Not hard enough to cause them to become dazed
	custom_materials = list(/datum/material/bamboo = SHEET_MATERIAL_AMOUNT * 2)

/obj/item/chair/stool/narsie_act()
	return //sturdy enough to ignore a god

/obj/item/chair/wood
	name = "wooden chair"
	icon_state = "wooden_chair_toppled"
	inhand_icon_state = "woodenchair"
	resistance_flags = FLAMMABLE
	max_integrity = 40
	hitsound = 'sound/items/weapons/genhit1.ogg'
	origin_type = /obj/structure/chair/wood
	custom_materials = null
	daze_amount = 0
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT * 3)

/obj/item/chair/wood/narsie_act()
	return

/obj/item/chair/wood/wings
	icon_state = "wooden_chair_wings_toppled"
	origin_type = /obj/structure/chair/wood/wings

/obj/structure/chair/old
	name = "strange chair"
	desc = "Это стул, на нём сидят. Хочешь ты этого или нет. Выглядит ОЧЕНЬ неудобным."
	icon_state = "chairold"
	item_chair = null
	fishing_modifier = 4

/obj/structure/chair/bronze
	name = "brass chair"
	desc = "Вращающееся кресло из бронзы. У него маленькие шестерёнки вместо колёс!"
	anchored = FALSE
	icon_state = "brass_chair"
	buildstacktype = /obj/item/stack/sheet/bronze
	buildstackamount = 1
	item_chair = null
	fishing_modifier = -13 //the pinnacle of Ratvarian technology.
	has_armrest = TRUE
	custom_materials = list(/datum/material/bronze = SHEET_MATERIAL_AMOUNT)
	/// Total rotations made
	var/turns = 0

/obj/structure/chair/bronze/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noisy_movement, 'sound/machines/clockcult/integration_cog_install.ogg', 50)

/obj/structure/chair/bronze/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()

/obj/structure/chair/bronze/process()
	setDir(turn(dir,-90))
	playsound(src, 'sound/effects/servostep.ogg', 50, FALSE)
	turns++
	if(turns >= 8)
		STOP_PROCESSING(SSfastprocess, src)

/obj/structure/chair/bronze/MakeRotate()
	return

/obj/structure/chair/bronze/click_alt(mob/user)
	turns = 0
	if(!(datum_flags & DF_ISPROCESSING))
		user.visible_message(span_notice("[user] вращает [declent_ru(ACCUSATIVE)], и последние остатки технологии Ратвара заставляют его вращаться ВЕЧНО."), \
		span_notice("Автоматические вращающиеся кресла. Вершина древней технологии Ратвара."))
		START_PROCESSING(SSfastprocess, src)
	else
		user.visible_message(span_notice("[user] останавливает неконтролируемое вращение [declent_ru(GENITIVE)]."), \
		span_notice("Вы хватаете [declent_ru(ACCUSATIVE)] и останавливаете его бешеное вращение."))
		STOP_PROCESSING(SSfastprocess, src)
	return CLICK_ACTION_SUCCESS

/obj/structure/chair/mime
	name = "invisible chair"
	desc = "Мимам стоит сидеть (и помалкивать)."
	anchored = FALSE
	icon_state = null
	buildstacktype = null
	item_chair = null
	obj_flags = parent_type::obj_flags | NO_DEBRIS_AFTER_DECONSTRUCTION
	alpha = 0
	fishing_modifier = -21 //it only lives for 25 seconds, so we make them worth it.
	custom_materials = null

/obj/structure/chair/mime/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/tool_blocker, TOOL_WRENCH, TOOL_ACT_SECONDARY)

/obj/structure/chair/mime/post_buckle_mob(mob/living/M)
	M.add_offsets(type, z_add = 5)

/obj/structure/chair/mime/post_unbuckle_mob(mob/living/M)
	M.remove_offsets(type)

/obj/structure/chair/plastic
	icon_state = "plastic_chair"
	name = "folding plastic chair"
	desc = "Сколько ни вертись, всё равно неудобно."
	resistance_flags = FLAMMABLE
	max_integrity = 70
	custom_materials = list(/datum/material/plastic = SHEET_MATERIAL_AMOUNT * 2)
	buildstacktype = /obj/item/stack/sheet/plastic
	buildstackamount = 2
	item_chair = /obj/item/chair/plastic
	fishing_modifier = -10

/obj/structure/chair/plastic/post_buckle_mob(mob/living/Mob)
	Mob.add_offsets(type, z_add = 2)
	. = ..()
	if(iscarbon(Mob))
		INVOKE_ASYNC(src, PROC_REF(snap_check), Mob)

/obj/structure/chair/plastic/post_unbuckle_mob(mob/living/Mob)
	Mob.remove_offsets(type)

/obj/structure/chair/plastic/proc/snap_check(mob/living/carbon/Mob)
	if (Mob.nutrition >= NUTRITION_LEVEL_FAT)
		to_chat(Mob, span_warning("[declent_ru(NOMINATIVE)] начинает трещать и ломаться, вы слишком тяжелы!"))
		if(do_after(Mob, 6 SECONDS, progress = FALSE))
			Mob.visible_message(span_notice("[declent_ru(NOMINATIVE)] ломается под весом [Mob]!"))
			new /obj/effect/decal/cleanable/plastic(loc)
			qdel(src)

/obj/item/chair/plastic
	name = "folding plastic chair"
	desc = "Ну и дешманщина."
	icon = 'icons/obj/chairs.dmi'
	icon_state = "folded_chair"
	inhand_icon_state = "folded_chair"
	lefthand_file = 'icons/mob/inhands/items/chairs_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/chairs_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	force = 7
	throw_range = 5 //Lighter Weight --> Flies Farther.
	custom_materials = list(/datum/material/plastic = SHEET_MATERIAL_AMOUNT * 2)
	max_integrity = 70
	daze_amount = 0
	origin_type = /obj/structure/chair/plastic

/obj/structure/chair/musical
	name = "musical chair"
	desc = "Значит слушай сюда... зачётная музычка, а?"
	item_chair = /obj/item/chair/musical
	particles = new /particles/musical_notes

/obj/item/chair/musical
	name = "musical chair"
	desc = "О, это ж прям как в детском садике. Чё? Говоришь, ты космический нищук-голодранец и у тебя не было детства? Боже правый, не разводи нюни."
	particles = new /particles/musical_notes
	origin_type = /obj/structure/chair/musical

/obj/structure/handrail
	name = "handrail"
	desc = "Держитесь крепче!"
	icon = 'icons/obj/handrail.dmi'
	icon_state = "handrail"
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = NO_BUCKLE_LYING
	resistance_flags = FIRE_PROOF
	max_integrity = 50
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)
	layer = OBJ_LAYER

/obj/structure/handrail/attack_hand(mob/living/user, list/modifiers)
	return ..() || mouse_buckle_handling(user, user)

/obj/structure/handrail/is_user_buckle_possible(mob/living/target, mob/user, check_loc = TRUE)
	return ..() && user == target && !HAS_TRAIT(target, TRAIT_HANDS_BLOCKED)

/obj/structure/handrail/post_buckle_mob(mob/living/buckled_mob)
	RegisterSignal(buckled_mob, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED), PROC_REF(stop_buckle))

	var/z_offset = 0
	var/w_offset = 0
	if(dir & NORTH)
		z_offset = -4
	else if(dir & SOUTH)
		z_offset = 8
	if(dir & EAST)
		w_offset = -8
	else if(dir & WEST)
		w_offset = 8

	buckled_mob.add_offsets(type, z_add = z_offset, w_add = w_offset)

/obj/structure/handrail/post_unbuckle_mob(mob/living/unbuckled_mob)
	UnregisterSignal(unbuckled_mob, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED))
	unbuckled_mob.remove_offsets(type)

/obj/structure/handrail/proc/stop_buckle(mob/living/source, ...)
	SIGNAL_HANDLER
	source.visible_message(
		span_warning("[source] теряет хватку на [declent_ru(PREPOSITIONAL)]!"),
		span_warning("Вы теряете хватку на [declent_ru(PREPOSITIONAL)]!"),
		visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
		vision_distance = COMBAT_MESSAGE_RANGE,
	)
	unbuckle_mob(source, TRUE, TRUE)

/obj/structure/handrail/buckle_feedback(mob/living/being_buckled, mob/buckler)
	buckler.visible_message(
		span_notice("[buckler] крепко хватается за [declent_ru(ACCUSATIVE)], удерживая себя в вертикальном положении."),
		span_notice("Вы крепко хватаетесь за [declent_ru(ACCUSATIVE)], удерживая себя в вертикальном положении."),
		visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
		vision_distance = COMBAT_MESSAGE_RANGE,
	)

/obj/structure/handrail/unbuckle_feedback(mob/living/being_unbuckled, mob/unbuckler)
	if(being_unbuckled == unbuckler)
		being_unbuckled.visible_message(
			span_notice("[unbuckler] отпускает [declent_ru(ACCUSATIVE)]."),
			span_notice("Вы отпускаете [declent_ru(ACCUSATIVE)]."),
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
			vision_distance = COMBAT_MESSAGE_RANGE,
		)
	else
		being_unbuckled.visible_message(
			span_warning("[unbuckler.declent_ru(NOMINATIVE)] заставляет [being_unbuckled.declent_ru(ACCUSATIVE)] отпустить [declent_ru(ACCUSATIVE)]!"),
			span_warning("[unbuckler] заставляет вас отпустить [declent_ru(ACCUSATIVE)]!"),
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
			vision_distance = COMBAT_MESSAGE_RANGE,
		)

#undef DECLENT_PREPOSITION_S // BANDASTATION EDIT
