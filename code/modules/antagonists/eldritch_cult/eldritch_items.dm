/obj/item/living_heart
	name = "Living Heart"
	desc = "A link to the worlds beyond."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "living_heart"
	w_class = WEIGHT_CLASS_SMALL
	///Target
	var/mob/living/carbon/human/target

/obj/item/living_heart/attack_self(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return
	if(!target)
		to_chat(user,span_warning("No target could be found. Put the living heart on a transmutation rune and activate the rune to recieve a target."))
		return
	var/dist = get_dist(get_turf(user),get_turf(target))
	var/dir = get_dir(get_turf(user),get_turf(target))
	if(user.z != target.z)
		to_chat(user,span_warning("[target.real_name] is on another plane of existence!"))
	else
		switch(dist)
			if(0 to 15)
				to_chat(user,span_warning("[target.real_name] is near you. They are to the [dir2text(dir)] of you!"))
			if(16 to 31)
				to_chat(user,span_warning("[target.real_name] is somewhere in your vicinity. They are to the [dir2text(dir)] of you!"))
			if(32 to 127)
				to_chat(user,span_warning("[target.real_name] is far away from you. They are to the [dir2text(dir)] of you!"))
			else
				to_chat(user,span_warning("[target.real_name] is beyond our reach."))

	if(target.stat == DEAD)
		to_chat(user,span_warning("[target.real_name] is dead. Bring them to a transmutation rune!"))

/obj/item/melee/sickly_blade
	name = "\improper Sickly Blade"
	desc = "A sickly green crescent blade, decorated with an ornamental eye. You feel like you're being watched..."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eldritch_blade"
	inhand_icon_state = "eldritch_blade"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	flags_1 = CONDUCT_1
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_NORMAL
	force = 17
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "rends")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "rend")

/obj/item/melee/sickly_blade/attack(mob/living/M, mob/living/user)
	if(!(IS_HERETIC(user) || IS_HERETIC_MONSTER(user)))
		to_chat(user,span_danger("You feel a pulse of alien intellect lash out at your mind!"))
		var/mob/living/carbon/human/human_user = user
		human_user.AdjustParalyzed(5 SECONDS)
		return FALSE
	return ..()

/obj/item/melee/sickly_blade/attack_self(mob/user)
	var/turf/safe_turf = find_safe_turf(zlevels = z, extended_safety_checks = TRUE)
	if(IS_HERETIC(user) || IS_HERETIC_MONSTER(user))
		if(do_teleport(user, safe_turf, channel = TELEPORT_CHANNEL_MAGIC))
			to_chat(user,span_warning("As you shatter [src], you feel a gust of energy flow through your body. The Rusted Hills heard your call..."))
		else
			to_chat(user,span_warning("You shatter [src], but your plea goes unanswered."))
	else
		to_chat(user,span_warning("You shatter [src]."))
	playsound(src, "shatter", 70, TRUE) //copied from the code for smashing a glass sheet onto the ground to turn it into a shard
	qdel(src)

/obj/item/melee/sickly_blade/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()

	var/datum/antagonist/heretic/cultie = user.mind?.has_antag_datum(/datum/antagonist/heretic)

	if(!cultie)
		return
	var/list/knowledge = cultie.get_all_knowledge()
	for(var/X in knowledge)
		var/datum/eldritch_knowledge/eldritch_knowledge_datum = knowledge[X]
		if(proximity_flag)
			eldritch_knowledge_datum.on_eldritch_blade(target,user,proximity_flag,click_parameters)
		else
			eldritch_knowledge_datum.on_ranged_attack_eldritch_blade(target,user,click_parameters)

/obj/item/melee/sickly_blade/examine(mob/user)
	. = ..()
	if(IS_HERETIC(user) || IS_HERETIC_MONSTER(user))
		. += span_notice("<B>A heretic (or a servant of one) can shatter this blade to teleport to a random, mostly safe location by activating it in-hand.</B>")

/obj/item/melee/sickly_blade/rust
	name = "\improper Rusted Blade"
	desc = "This crescent blade is decrepit, wasting to rust. Yet still it bites, ripping flesh and bone with jagged, rotten teeth."
	icon_state = "rust_blade"
	inhand_icon_state = "rust_blade"

/obj/item/melee/sickly_blade/ash
	name = "\improper Ashen Blade"
	desc = "Molten and unwrought, a hunk of metal warped to cinders and slag. Unmade, it aspires to be more than it is, and shears soot-filled wounds with a blunt edge."
	icon_state = "ash_blade"
	inhand_icon_state = "ash_blade"

/obj/item/melee/sickly_blade/flesh
	name = "Flesh Blade"
	desc = "A crescent blade born from a fleshwarped creature. Keenly aware, it seeks to spread to others the suffering it has endured from its dreadful origins."
	icon_state = "flesh_blade"
	inhand_icon_state = "flesh_blade"

/obj/item/melee/sickly_blade/void
	name = "Void Blade"
	desc = "Devoid of any substance, this blade reflects nothingness. It is a real depiction of purity, and chaos that ensues after its implementation."
	icon_state = "void_blade"
	inhand_icon_state = "void_blade"

/obj/item/clothing/neck/eldritch_amulet
	name = "Warm Eldritch Medallion"
	desc = "A strange medallion. Peering through the crystalline surface, the world around you melts away. You see your own beating heart, and the pulsing of a thousand others."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eye_medalion"
	w_class = WEIGHT_CLASS_SMALL
	///What trait do we want to add upon equipiing
	var/trait = TRAIT_THERMAL_VISION

/obj/item/clothing/neck/eldritch_amulet/equipped(mob/user, slot)
	. = ..()
	if(ishuman(user) && user.mind && slot == ITEM_SLOT_NECK && (IS_HERETIC(user) || IS_HERETIC_MONSTER(user)) )
		ADD_TRAIT(user, trait, CLOTHING_TRAIT)
		user.update_sight()

/obj/item/clothing/neck/eldritch_amulet/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, trait, CLOTHING_TRAIT)
	user.update_sight()

/obj/item/clothing/neck/eldritch_amulet/piercing
	name = "Piercing Eldritch Medallion"
	desc = "A strange medallion. Peering through the crystalline surface, the light refracts into new and terrifying spectrums of color. You see yourself, reflected off cascading mirrors, warped into impossible shapes."
	trait = TRAIT_XRAY_VISION

/obj/item/clothing/head/hooded/cult_hoodie/eldritch
	name = "ominous hood"
	icon_state = "eldritch"
	desc = "A torn, dust-caked hood. Strange eyes line the inside."
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	flash_protect = FLASH_PROTECTION_WELDER

/obj/item/clothing/suit/hooded/cultrobes/eldritch
	name = "ominous armor"
	desc = "A ragged, dusty set of robes. Strange eyes line the inside."
	icon_state = "eldritch_armor"
	inhand_icon_state = "eldritch_armor"
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS
	allowed = list(/obj/item/melee/sickly_blade, /obj/item/forbidden_book, /obj/item/living_heart)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch
	// slightly better than normal cult robes
	armor = list(MELEE = 50, BULLET = 50, LASER = 50,ENERGY = 50, BOMB = 35, BIO = 20, FIRE = 20, ACID = 20)

/obj/item/reagent_containers/glass/beaker/eldritch
	name = "flask of eldritch essence"
	desc = "Toxic to the closed minded, yet refreshing to those with knowledge of the beyond."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eldrich_flask"
	list_reagents = list(/datum/reagent/eldritch = 50)

/obj/item/clothing/head/hooded/cult_hoodie/void
	name = "void hood"
	icon_state = "void_cloak"
	flags_inv = NONE
	flags_cover = NONE
	desc = "Black like tar, doesn't reflect any light. Runic symbols line the outside, with each flash you loose comprehension of what you are seeing."
	item_flags = EXAMINE_SKIP
	armor = list(MELEE = 30, BULLET = 30, LASER = 30,ENERGY = 30, BOMB = 15, BIO = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/head/hooded/cult_hoodie/void/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_STRIP, src)

/obj/item/clothing/suit/hooded/cultrobes/void
	name = "void cloak"
	desc = "Black like tar, doesn't reflect any light. Runic symbols line the outside, with each flash you loose comprehension of what you are seeing."
	icon_state = "void_cloak"
	inhand_icon_state = "void_cloak"
	allowed = list(/obj/item/melee/sickly_blade, /obj/item/forbidden_book, /obj/item/living_heart)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/void
	flags_inv = NONE
	// slightly worse than normal cult robes
	armor = list(MELEE = 30, BULLET = 30, LASER = 30,ENERGY = 30, BOMB = 15, BIO = 0, FIRE = 0, ACID = 0)
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/void_cloak
	alternative_mode = TRUE

/obj/item/clothing/suit/hooded/cultrobes/void/RemoveHood()
	if (!HAS_TRAIT(src, TRAIT_NO_STRIP))
		return ..()
	var/mob/living/carbon/carbon_user = loc
	to_chat(carbon_user, span_notice("The kaleidoscope of colours collapses around you, as the cloak shifts to visibility!"))
	item_flags &= ~EXAMINE_SKIP
	REMOVE_TRAIT(src, TRAIT_NO_STRIP, src)
	return ..()

/obj/item/clothing/suit/hooded/cultrobes/void/MakeHood()
	if(!iscarbon(loc))
		CRASH("[src] attempted to make a hood on a non-carbon thing: [loc]")

	var/mob/living/carbon/carbon_user = loc
	if(IS_HERETIC(carbon_user) || IS_HERETIC_MONSTER(carbon_user))
		. = ..()
		to_chat(carbon_user,span_notice("The light shifts around you making the cloak invisible!"))
		item_flags |= EXAMINE_SKIP
		ADD_TRAIT(src, TRAIT_NO_STRIP, src)
		return

	to_chat(carbon_user,span_danger("You can't force the hood onto your head!"))

/obj/item/clothing/mask/void_mask
	name = "Abyssal Mask"
	desc = "Mask created from the suffering of existance, you can look down it's eyes, and notice something gazing back at you."
	icon_state = "mad_mask"
	inhand_icon_state = "mad_mask"
	w_class = WEIGHT_CLASS_SMALL
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE
	flags_inv = HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	///Who is wearing this
	var/mob/living/carbon/human/local_user

/obj/item/clothing/mask/void_mask/equipped(mob/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_MASK)
		return
	if(ishuman(user) && user.mind && slot == ITEM_SLOT_MASK)
		local_user = user
		START_PROCESSING(SSobj,src)

		if(IS_HERETIC(user) || IS_HERETIC_MONSTER(user))
			return
		ADD_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)

/obj/item/clothing/mask/void_mask/dropped(mob/M)
	local_user = null
	STOP_PROCESSING(SSobj,src)
	REMOVE_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)
	return ..()

/obj/item/clothing/mask/void_mask/process(delta_time)
	if(!local_user)
		return PROCESS_KILL

	if((IS_HERETIC(local_user) || IS_HERETIC_MONSTER(local_user)) && HAS_TRAIT(src,TRAIT_NODROP))
		REMOVE_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)

	for(var/mob/living/carbon/human/human_in_range in spiral_range(9,local_user))
		if(IS_HERETIC(human_in_range) || IS_HERETIC_MONSTER(human_in_range))
			continue

		SEND_SIGNAL(human_in_range,COMSIG_VOID_MASK_ACT,rand(-2,-20)*delta_time)

		if(DT_PROB(60,delta_time))
			human_in_range.hallucination += 5

		if(DT_PROB(40,delta_time))
			human_in_range.Jitter(5)

		if(DT_PROB(30,delta_time))
			human_in_range.emote(pick("giggle","laugh"))
			human_in_range.adjustStaminaLoss(10)

		if(DT_PROB(25,delta_time))
			human_in_range.Dizzy(5)

/obj/item/melee/rune_carver
	name = "Carving Knife"
	desc = "Cold Steel, pure, perfect, this knife can carve the floor in many ways, but only few can evoke the dangers that lurk beneath reality."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "rune_carver"
	flags_1 = CONDUCT_1
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_SMALL
	wound_bonus = 20
	force = 10
	throwforce = 20
	embedding = list(embed_chance=75, jostle_chance=2, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.4, pain_mult=3, jostle_pain_mult=5, rip_time=15)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "rends")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "rend")
	///turfs that you cannot draw carvings on
	var/static/list/blacklisted_turfs = typecacheof(list(/turf/closed,/turf/open/space,/turf/open/lava))
	///A check to see if you are in process of drawing a rune
	var/drawing = FALSE
	///A list of current runes
	var/list/current_runes = list()
	///Max amount of runes
	var/max_rune_amt = 3
	///Linked action
	var/datum/action/innate/rune_shatter/linked_action

/obj/item/melee/rune_carver/examine(mob/user)
	. = ..()
	. += "This item can carve 'Alert carving' - nearly invisible rune that when stepped on gives you a prompt about where someone stood on it and who it was, doesn't get destroyed by being stepped on."
	. += "This item can carve 'Grasping carving' - when stepped on it causes heavy damage to the legs and stuns for 5 seconds."
	. += "This item can carve 'Mad carving' - when stepped on it causes dizzyness, jiterryness, temporary blindness, confusion , stuttering and slurring."

/obj/item/melee/rune_carver/Initialize(mapload)
	. = ..()
	linked_action = new(src)

/obj/item/melee/rune_carver/Destroy()
	. = ..()
	QDEL_NULL(linked_action)

/obj/item/melee/rune_carver/pickup(mob/user)
	. = ..()
	linked_action.Grant(user, src)

/obj/item/melee/rune_carver/dropped(mob/user, silent)
	. = ..()
	linked_action.Remove(user, src)

/obj/item/melee/rune_carver/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(isturf(target) && !is_type_in_typecache(target,blacklisted_turfs) && !drawing && proximity_flag)
		carve_rune(target,user,proximity_flag,click_parameters)

///Action of carving runes, gives you the ability to click on floor and choose a rune of your need.
/obj/item/melee/rune_carver/proc/carve_rune(atom/target, mob/user, proximity_flag, click_parameters)
	var/obj/structure/trap/eldritch/elder = locate() in range(1,target)
	if(elder)
		to_chat(user,span_notice("You can't draw runes that close to each other!"))
		return

	for(var/_rune_ref in current_runes)
		var/datum/weakref/rune_ref = _rune_ref
		if(!rune_ref.resolve())
			current_runes -= rune_ref

	if(length(current_runes) >= max_rune_amt)
		to_chat(user,span_notice("The blade cannot support more runes!"))
		return

	var/list/pick_list = list()
	for(var/E in subtypesof(/obj/structure/trap/eldritch))
		var/obj/structure/trap/eldritch/eldritch = E
		pick_list[initial(eldritch.name)] = eldritch

	drawing = TRUE

	var/type = pick_list[tgui_input_list(user, "Choose the rune", "Rune", pick_list) ]
	if(isnull(type))
		drawing = FALSE
		return


	to_chat(user,span_notice("You start drawing the rune..."))
	if(!do_after(user,5 SECONDS,target = target))
		drawing = FALSE
		return

	drawing = FALSE
	var/obj/structure/trap/eldritch/eldritch = new type(target)
	eldritch.set_owner(user)
	current_runes += WEAKREF(eldritch)

/datum/action/innate/rune_shatter
	name = "Rune break"
	desc = "Destroys all runes that were drawn by this blade."
	background_icon_state = "bg_ecult"
	button_icon_state = "rune_break"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	check_flags = AB_CHECK_CONSCIOUS
	///Reference to the rune knife it is inside of
	var/obj/item/melee/rune_carver/sword

/datum/action/innate/rune_shatter/Grant(mob/user, obj/object)
	sword = object
	return ..()

/datum/action/innate/rune_shatter/Activate()
	for(var/_rune_ref in sword.current_runes)
		var/datum/weakref/rune_ref = _rune_ref
		qdel(rune_ref.resolve())
	sword.current_runes.Cut()

/obj/item/eldritch_potion
	name = "Brew of Day and Night"
	desc = "You should never see this"
	icon = 'icons/obj/eldritch.dmi'
	///Typepath to the status effect this is supposed to hold
	var/status_effect

/obj/item/eldritch_potion/attack_self(mob/user)
	. = ..()
	to_chat(user,span_notice("You drink the potion and with the viscous liquid, the glass dematerializes."))
	effect(user)
	qdel(src)

///The effect of the potion if it has any special one, in general try not to override this and utilize the status_effect var to make custom effects.
/obj/item/eldritch_potion/proc/effect(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/carbie = user
	carbie.apply_status_effect(status_effect)

/obj/item/eldritch_potion/crucible_soul
	name = "Brew of Crucible Soul"
	desc = "Allows you to phase through walls for 15 seconds, after the time runs out, you get teleported to your original location."
	icon_state = "crucible_soul"
	status_effect = /datum/status_effect/crucible_soul

/obj/item/eldritch_potion/duskndawn
	name = "Brew of Dusk and Dawn"
	desc = "Allows you to see clearly through walls and objects for 60 seconds."
	icon_state = "clarity"
	status_effect = /datum/status_effect/duskndawn

/obj/item/eldritch_potion/wounded
	name = "Brew of Wounded Soldier"
	desc = "For the next 60 seconds each wound will heal you, minor wounds heal 1 of it's damage type per second, moderate heal 3 and critical heal 6. You also become immune to damage slowdon."
	icon_state = "marshal"
	status_effect = /datum/status_effect/marshal
