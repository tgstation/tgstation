/obj/item
	/// How much power would this item use?
	var/power_use_amount = 50

/// Use the power of an attached component that posesses power handling, will return the signal bitflag.
/obj/item/proc/item_use_power(use_amount, mob/user, check_only)
	SHOULD_CALL_PARENT(TRUE)
	return SEND_SIGNAL(src, COMSIG_ITEM_POWER_USE, use_amount, user, check_only)


/obj/machinery/dryer
	name = "hand dryer"
	desc = "The Breath Of Lizards-3000, an experimental dryer."
	icon = 'monkestation/code/modules/blueshift/icons/dryer.dmi'
	icon_state = "dryer"
	density = FALSE
	anchored = TRUE
	var/busy = FALSE

/obj/machinery/dryer/attack_hand(mob/user)
	if(iscyborg(user) || isAI(user))
		return

	if(!can_interact(user))
		return

	if(busy)
		to_chat(user, span_warning("Someone's already drying here."))
		return

	to_chat(user, span_notice("You start drying your hands."))
	playsound(src, 'monkestation/code/modules/blueshift/sounds/drying.ogg', 50)
	add_fingerprint(user)
	busy = TRUE
	if(do_after(user, 4 SECONDS, src))
		busy = FALSE
		user.visible_message("[user] dried their hands using \the [src].")
	else
		busy = FALSE

/obj/item/clothing/head/hair_tie
	name = "hair tie"
	desc = "An elastic hair tie, made to hold your hair up!"
	icon = 'monkestation/code/modules/blueshift/icons/items.dmi'
	icon_state = "hairtie"
	worn_icon = 'monkestation/code/modules/blueshift/icons/items.dmi'
	worn_icon_state = "hair_tie_worn_no_icon"
	lefthand_file = 'monkestation/code/modules/blueshift/icons/items.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/items.dmi'
	inhand_icon_state = "hair_tie_worn_no_icon"
	w_class = WEIGHT_CLASS_TINY
	custom_price = PAYCHECK_CREW * 0.2
	///string which set_hairstyle() will read
	var/picked_hairstyle
	///storage for the original hairstyle string
	var/actual_hairstyle
	///which projectile object to use as flicked hair tie
	var/projectile_to_fire = /obj/projectile/bullet/hair_tie
	///how long the do_after takes to flick the hair tie
	var/fire_speed = 3 SECONDS
	///how big is the randomized aim radius when flicked
	var/projectile_aim_radius = 30

/obj/item/clothing/head/hair_tie/scrunchie
	name = "scrunchie"
	desc = "An elastic hair tie, its fabric is velvet soft."
	icon_state = "hairtie_scrunchie"

/obj/item/clothing/head/hair_tie/plastic_beads
	name = "colorful hair tie"
	desc = "An elastic hair tie, adornished with colorful plastic beads."
	icon_state = "hairtie_beads"
	custom_materials = (list(/datum/material/plastic = HALF_SHEET_MATERIAL_AMOUNT))

/obj/item/clothing/head/hair_tie/syndicate
	name = "\improper Syndicate hair tie"
	desc = "An elastic hair tie with a metal clip, brandishing the logo of the Syndicate."
	icon_state = "hairtie_syndie"
	fire_speed = 1.5 SECONDS
	projectile_to_fire = /obj/projectile/bullet/hair_tie/syndicate
	projectile_aim_radius = 0 //accurate aim

/obj/item/clothing/head/hair_tie/examine(mob/user)
	. = ..()
	if(picked_hairstyle)
		. += span_notice("Wearing it will change your hairstyle to '[picked_hairstyle]'.")
	. += span_notice("<b>Use in hand</b> to pick a new hairstyle.")
	. += span_notice("<b>Alt-click</b> [src] to fling it.")

/obj/item/clothing/head/hair_tie/mob_can_equip(mob/living/carbon/human/user, slot, disable_warning, bypass_equip_delay_self, ignore_equipped, indirect_action)
	if(user.hairstyle == "Bald") //could create a list of the bald hairstyles to check
		return FALSE
	return ..()

/obj/item/clothing/head/hair_tie/attack_self(mob/user)
	var/hair_id = tgui_input_list(user, "How does your hair look when its up?", "Pick!", GLOB.hairstyles_list)
	if(!hair_id || hair_id == "Bald")
		balloon_alert(user, "error!")
		return
	balloon_alert(user, "[hair_id]")
	picked_hairstyle = hair_id

/obj/item/clothing/head/hair_tie/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(!ishuman(user) || !(slot_flags & slot))
		return
	if(!picked_hairstyle)
		return
	user.visible_message(
		span_notice("[user.name] ties up [user.p_their()] hair."),
		span_notice("You tie up your hair!"),
	)
	actual_hairstyle = user.hairstyle
	user.hairstyle = picked_hairstyle
	user.update_body_parts()

/obj/item/clothing/head/hair_tie/dropped(mob/living/carbon/human/user)
	. = ..()
	if(!ishuman(user))
		return
	if(!picked_hairstyle || !actual_hairstyle)
		return
	user.visible_message(
		span_notice("[user.name] takes [src] out of [user.p_their()] hair."),
		span_notice("You let down your hair!"),
	)
	user.hairstyle = actual_hairstyle
	user.update_body_parts()
	actual_hairstyle = null

/obj/item/clothing/head/hair_tie/AltClick(mob/living/user)
	if(!(user.get_slot_by_item(src) == ITEM_SLOT_HANDS))
		balloon_alert(user, "hold in-hand!")
		return
	user.visible_message(
		span_danger("[user.name] puts [src] around [user.p_their()] fingers, beginning to flick it!"),
		span_notice("You try to flick [src]!"),
	)
	flick_hair_tie(user)
	return

///This proc flicks the hair tie out of the player's hand, tripping the target hit for 1 second
/obj/item/clothing/head/hair_tie/proc/flick_hair_tie(mob/living/user)
	if(!do_after(user, fire_speed, src))
		return
	//build the projectile
	var/obj/projectile/bullet/hair_tie/proj = new projectile_to_fire (drop_location())
	//clone some vars
	proj.name = name
	proj.icon_state = icon_state
	//add projectile_drop
	proj.AddElement(/datum/element/projectile_drop, type)
	//aim and fire
	proj.firer = user
	proj.fired_from = user
	proj.fire((dir2angle(user.dir) + rand(-projectile_aim_radius, projectile_aim_radius)))
	playsound(src, 'sound/weapons/effects/batreflect.ogg', 25, TRUE)
	//get rid of what we just launched to let projectile_drop spawn a new one
	qdel(src)

/obj/projectile/bullet/hair_tie
	icon = 'monkestation/code/modules/blueshift/icons/items.dmi'
	icon_state = "hairtie"
	hitsound = 'sound/weapons/genhit.ogg'
	damage = 0 //its just about the knockdown
	sharpness = NONE
	shrapnel_type = NONE //no embedding pls
	impact_effect_type = null
	ricochet_chance = 0
	range = 7
	knockdown = 1 SECONDS

/obj/projectile/bullet/hair_tie/syndicate
	damage = 10 //getting hit with this one fucking sucks
	stamina = 30
	eyeblur = 2 SECONDS
	jitter = 8 SECONDS

/datum/design/plastic_hair_tie
	name = "Plastic Hair Tie"
	id = "plastic_hair_tie"
	build_type = PROTOLATHE | AWAY_LATHE | AUTOLATHE
	materials = list(
		/datum/material/plastic = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/clothing/head/hair_tie/plastic_beads
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SERVICE,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/obj/item/scissors
	name = "barber's scissors"
	desc = "Some say a barbers best tool is his electric razor, that is not the case. These are used to cut hair in a professional way!"
	icon = 'monkestation/code/modules/blueshift/icons/items.dmi'
	icon_state = "scissors"
	w_class = WEIGHT_CLASS_TINY
	sharpness = SHARP_EDGED
	// How long does it take to change someone's hairstyle?
	var/haircut_duration = 1 MINUTES
	// How long does it take to change someone's facial hair style?
	var/facial_haircut_duration = 20 SECONDS

/obj/item/scissors/attack(mob/living/attacked_mob, mob/living/user, params)
	if(!ishuman(attacked_mob))
		return

	var/mob/living/carbon/human/target_human = attacked_mob

	var/location = user.zone_selected
	if(!(location in list(BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_HEAD)) && !(user.istate & ISTATE_HARM))
		to_chat(user, span_warning("You stop, look down at what you're currently holding and ponder to yourself, \"This is probably to be used on their hair or their facial hair.\""))
		return

	if(target_human.hairstyle == "Bald" && target_human.facial_hairstyle == "Shaved")
		balloon_alert(user, "What hair? They have none!")
		return

	if(user.zone_selected != BODY_ZONE_HEAD)
		return ..()

	var/selected_part = tgui_alert(user, "Please select which part of [target_human] you would like to sculpt!", "It's sculpting time!", list("Hair", "Facial Hair", "Cancel"))

	if(!selected_part || selected_part == "Cancel")
		return

	if(selected_part == "Hair")
		if(!target_human.hairstyle == "Bald" && target_human.head)
			balloon_alert(user, "They have no hair to cut!")
			return

		var/hair_id = tgui_input_list(user, "Please select what hairstyle you'd like to sculpt!", "Select masterpiece", GLOB.hairstyles_list)
		if(!hair_id)
			return

		if(hair_id == "Bald")
			to_chat(target_human, span_danger("[user] seems to be cutting all your hair off!"))

		to_chat(user, span_notice("You begin to masterfully sculpt [target_human]'s hair!"))

		playsound(target_human, 'monkestation/code/modules/blueshift/sounds/haircut.ogg', 100)

		if(do_after(user, haircut_duration, target_human))
			target_human.hairstyle = hair_id
			target_human.update_body_parts()
			user.visible_message(span_notice("[user] successfully cuts [target_human]'s hair!"), span_notice("You successfully cut [target_human]'s hair!"))
			new /obj/effect/decal/cleanable/hair(get_turf(src))
	else
		if(!target_human.facial_hairstyle == "Shaved" && target_human.wear_mask)
			balloon_alert(user, "They have no facial hair to cut!")
			return

		var/facial_hair_id = tgui_input_list(user, "Please select what facial hairstyle you'd like to sculpt!", "Select masterpiece", GLOB.facial_hairstyles_list)
		if(!facial_hair_id)
			return

		if(facial_hair_id == "Shaved")
			to_chat(target_human, span_danger("[user] seems to be cutting all your facial hair off!"))

		to_chat(user, "You begin to masterfully sculpt [target_human]'s facial hair!")

		playsound(target_human, 'monkestation/code/modules/blueshift/sounds/haircut.ogg', 100)

		if(do_after(user, facial_haircut_duration, target_human))
			target_human.facial_hairstyle = facial_hair_id
			target_human.update_body_parts()
			user.visible_message(span_notice("[user] successfully cuts [target_human]'s facial hair!"), span_notice("You successfully cut [target_human]'s facial hair!"))
			new /obj/effect/decal/cleanable/hair(get_turf(src))

/obj/item/reagent_containers/dropper/precision
	name = "pipette"
	desc = "A high precision pippette. Holds 1 unit."
	icon = 'monkestation/code/modules/blueshift/icons/items.dmi'
	icon_state = "pipette1"
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = list(0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1)
	volume = 1
	w_class = WEIGHT_CLASS_TINY

/obj/structure/chair/comfy/barber_chair
	name = "barber's chair"
	desc = "You sit in this, and your hair shall be cut."
	icon = 'monkestation/code/modules/blueshift/icons/chair.dmi'
	icon_state = "barber_chair"

/obj/machinery/vending/barbervend
	name = "Fab-O-Vend"
	desc = "It would seem it vends dyes, and other stuff to make you pretty."
	icon = 'monkestation/code/modules/blueshift/icons/vendor.dmi'
	icon_state = "barbervend"
	product_slogans = "Spread the colour, like butter, onto toast... Onto their hair.; Sometimes, I dream about dyes...; Paint 'em up and call me Mr. Painter.; Look brother, I'm a vendomat, I solve practical problems."
	product_ads = "Cut 'em all!; To sheds!; Hair be gone!; Prettify!; Beautify!"
	vend_reply = "Come again!; Buy another!; Dont you love your new look?"
	req_access = list(ACCESS_SERVICE)
	refill_canister = /obj/item/vending_refill/barbervend
	products = list(
		/obj/item/reagent_containers/spray/quantum_hair_dye = 3,
		/obj/item/reagent_containers/spray/baldium = 3,
		/obj/item/reagent_containers/spray/barbers_aid = 3,
		/obj/item/clothing/head/hair_tie = 3,
		/obj/item/dyespray = 5,
		/obj/item/hairbrush = 3,
		/obj/item/hairbrush/comb = 3,
		/obj/item/fur_dyer = 1,
	)
	premium = list(
		/obj/item/scissors = 3,
		/obj/item/reagent_containers/spray/super_barbers_aid = 3,
		/obj/item/storage/box/lipsticks = 3,
		/obj/item/lipstick/quantum = 1,
		/obj/item/razor = 1,
		/obj/item/storage/box/perfume = 1,
	)
	refill_canister = /obj/item/vending_refill/barbervend
	default_price = PAYCHECK_CREW
	extra_price = PAYCHECK_COMMAND
	payment_department = ACCOUNT_SRV

/obj/item/vending_refill/barbervend
	machine_name = "barber vend resupply"
	icon_state = "refill_snack" //generic item refill because there isnt one sprited yet.

/obj/structure/closet/secure_closet/barber
	name = "barber's locker"
	icon_state = "barber"
	icon = 'monkestation/code/modules/blueshift/icons/obj/closet.dmi'
	req_access = list(ACCESS_SERVICE)

/obj/structure/closet/secure_closet/barber/PopulateContents()
	new /obj/item/clothing/mask/surgical(src) // These three are here, so the barber can pick and choose what he's painting.
	new /obj/item/clothing/under/rank/medical/scrubs/blue(src)
	new /obj/item/clothing/suit/apron/surgical(src)
	new /obj/item/clothing/accessory/waistcoat(src)
	new /obj/item/clothing/under/rank/civilian/lawyer/purpsuit(src)
	new /obj/item/clothing/suit/toggle/lawyer/purple(src)
	new /obj/item/razor(src)
	new /obj/item/hairbrush/comb(src)
	new /obj/item/scissors(src)
	new /obj/item/fur_dyer(src)
	new /obj/item/dyespray(src)
	new /obj/item/storage/box/lipsticks(src)
	new /obj/item/reagent_containers/spray/quantum_hair_dye(src)
	new /obj/item/reagent_containers/spray/barbers_aid(src)
	new /obj/item/reagent_containers/spray/cleaner(src)
	new /obj/item/reagent_containers/cup/rag(src)
	new /obj/item/storage/medkit(src)

#define COLOR_MODE_SPECIFIC "Specific Marking"
#define COLOR_MODE_GENERAL "General Color"

/obj/item/fur_dyer
	name = "electric fur dyer"
	desc = "Dye that is capable of recoloring fur in a mostly permanent way."
	icon = 'monkestation/code/modules/blueshift/icons/items.dmi'
	icon_state = "fur_sprayer"
	w_class = WEIGHT_CLASS_TINY

	var/mode = COLOR_MODE_SPECIFIC

/obj/item/fur_dyer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cell)

/obj/item/fur_dyer/attack_self(mob/user, modifiers)
	. = ..()
	if(mode == COLOR_MODE_SPECIFIC)
		mode = COLOR_MODE_GENERAL
	else
		mode = COLOR_MODE_SPECIFIC

	balloon_alert(user, "Set to [mode]!")

/obj/item/fur_dyer/attack(mob/living/M, mob/living/user, params)
	if(!ishuman(M))
		return ..()

	var/mob/living/carbon/human/target_human = M

	switch(mode)
		if(COLOR_MODE_SPECIFIC)
			dye_marking(target_human, user)
		if(COLOR_MODE_GENERAL)
			dye_general(target_human, user)

/obj/item/fur_dyer/proc/dye_general(mob/living/carbon/human/target_human, mob/living/user)
	var/selected_mutant_color = tgui_alert(user, "Please select which mutant color you'd like to change", "Select Color", list("One", "Two", "Three"))

	if(!selected_mutant_color)
		return

	if(!(item_use_power(power_use_amount, user, TRUE) & COMPONENT_POWER_SUCCESS))
		to_chat(user, span_danger("A red light blinks!"))
		return

	var/selected_color = tgui_color_picker(
		user,
		"Select marking color",
		default = COLOR_WHITE,
	)

	if(!selected_color)
		return

	selected_color = sanitize_hexcolor(selected_color)

	visible_message(span_notice("[user] starts to masterfully paint [target_human]!"))

	if(do_after(user, 20 SECONDS, target_human))
		switch(selected_mutant_color)
			if("One")
				target_human.dna.features["mcolor"] = selected_color
			if("Two")
				target_human.dna.features["mcolor1"] = selected_color
			if("Three")
				target_human.dna.features["mcolor2"] = selected_color

		target_human.regenerate_icons()
		item_use_power(power_use_amount, user)

		visible_message(span_notice("[user] finishes painting [target_human]!"))

		playsound(src.loc, 'sound/effects/spray2.ogg', 50, TRUE)


/obj/item/fur_dyer/proc/dye_marking(mob/living/carbon/human/target_human, mob/living/user)

	var/list/list/current_markings = list(target_human.dna.features["body_markings"])

	if(!current_markings.len)
		to_chat(user, span_danger("[target_human] has no markings!"))
		return

	if(!(item_use_power(power_use_amount, user, TRUE) & COMPONENT_POWER_SUCCESS))
		to_chat(user, span_danger("A red light blinks!"))
		return

	var/selected_marking_area = user.zone_selected

	if(!current_markings[selected_marking_area])
		to_chat(user, span_danger("[target_human] has no bodymarkings on this limb!"))
		return

	var/selected_marking_id = tgui_input_list(user, "Please select which marking you'd like to color!", "Select marking", current_markings[selected_marking_area])

	if(!selected_marking_id)
		return

	var/selected_color = tgui_color_picker(
		user,
		"Select marking color",
		default = COLOR_WHITE,
	)

	if(!selected_color)
		return

	selected_color = sanitize_hexcolor(selected_color)

	visible_message(span_notice("[user] starts to masterfully paint [target_human]!"))

	if(do_after(user, 20 SECONDS, target_human))
		current_markings[selected_marking_area][selected_marking_id] = selected_color

		target_human.dna.features["body_markings"] = current_markings[1]

		target_human.regenerate_icons()

		item_use_power(power_use_amount, user)

		visible_message(span_notice("[user] finishes painting [target_human]!"))

		playsound(src.loc, 'sound/effects/spray2.ogg', 50, TRUE)



/obj/item/storage/box/lipsticks
	name = "lipstick box"

/obj/item/storage/box/lipsticks/PopulateContents()
	..()
	new /obj/item/lipstick(src)
	new /obj/item/lipstick/purple(src)
	new /obj/item/lipstick/jade(src)
	new /obj/item/lipstick/black(src)

/obj/item/lipstick/quantum
	name = "quantum lipstick"

/obj/item/lipstick/quantum/attack(mob/attacked_mob, mob/user)
	if(!open || !ismob(attacked_mob))
		return

	if(!ishuman(attacked_mob))
		to_chat(user, span_warning("Where are the lips on that?"))
		return

	INVOKE_ASYNC(src, PROC_REF(async_set_color), attacked_mob, user)

/obj/item/lipstick/quantum/proc/async_set_color(mob/attacked_mob, mob/user)
	var/new_color = tgui_color_picker(
		user,
		"Select lipstick color",
		default = COLOR_WHITE,
	)

	var/mob/living/carbon/human/target = attacked_mob
	if(target.is_mouth_covered())
		to_chat(user, span_warning("Remove [ target == user ? "your" : "[target.p_their()]" ] mask!"))
		return
	if(target.lip_style) //if they already have lipstick on
		to_chat(user, span_warning("You need to wipe off the old lipstick first!"))
		return

	if(target == user)
		user.visible_message(span_notice("[user] does [user.p_their()] lips with \the [src]."), \
			span_notice("You take a moment to apply \the [src]. Perfect!"))
		target.update_lips("lipstick", new_color, lipstick_trait)
		return

	user.visible_message(span_warning("[user] begins to do [target]'s lips with \the [src]."), \
		span_notice("You begin to apply \the [src] on [target]'s lips..."))
	if(!do_after(user, 2 SECONDS, target = target))
		return
	user.visible_message(span_notice("[user] does [target]'s lips with \the [src]."), \
		span_notice("You apply \the [src] on [target]'s lips."))
	target.update_lips("lipstick", new_color, lipstick_trait)

/obj/item/hairbrush/comb
	name = "comb"
	desc = "A rather simple tool, used to straighten out hair and knots in it."
	icon = 'monkestation/code/modules/blueshift/icons/items.dmi'
	icon_state = "blackcomb"

/obj/item/hairstyle_preview_magazine
	name = "hip hairstyles magazine"
	desc = "A magazine featuring a magnitude of hairsytles!"

/obj/item/hairstyle_preview_magazine/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	// A simple GUI with a list of hairstyles and a view, so people can choose a hairstyle!

/obj/effect/decal/cleanable/hair
	name = "hair cuttings"
	icon = 'monkestation/code/modules/blueshift/icons/items.dmi'
	icon_state = "cut_hair"

/obj/item/razor
	name = "electric razor"
	desc = "The latest and greatest power razor born from the science of shaving."
	icon = 'monkestation/code/modules/blueshift/icons/items.dmi'
	icon_state = "razor"
	w_class = WEIGHT_CLASS_TINY
	flags_1 = CONDUCT_1
	toolspeed = 1
	// How long do we take to shave someone's (facial) hair?
	var/shaving_time = 5 SECONDS
	//Gigarazor W/ Bananium
	var/unlocked = FALSE //for unlocking super hairstyles

/obj/item/razor/attackby(obj/item/item, mob/user, params)
	.=..()
	if(istype(item, /obj/item/stack/sheet/mineral/bananium))
		if(unlocked)
			to_chat(user, "<span class='userdanger'>[src] is already powered by bananium!</span>")
			return
		item.use_tool(src, user, amount=1)
		unlocked = TRUE
		to_chat(user, "<span class='userdanger'>You insert the bananium into the battery pack.</span>")

/obj/item/razor/gigarazor
	name = "shmick 9000"
	desc = "It gets the job done."
	unlocked = TRUE

/obj/item/razor/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins shaving [user.p_them()]self without the razor guard! It looks like [user.p_theyre()] trying to commit suicide!"))
	shave(user, BODY_ZONE_PRECISE_MOUTH)
	shave(user, BODY_ZONE_HEAD)//doesnt need to be BODY_ZONE_HEAD specifically, but whatever
	return BRUTELOSS

/obj/item/razor/proc/shave(mob/living/carbon/human/target_human, location = BODY_ZONE_PRECISE_MOUTH)
	if(location == BODY_ZONE_PRECISE_MOUTH)
		target_human.hairstyle = "Shaved"
		target_human.update_body_parts()
	else
		target_human.hairstyle = "Bald"
		target_human.update_body_parts()

	playsound(loc, 'sound/items/unsheath.ogg', 20, TRUE)


/obj/item/razor/attack(mob/attacked_mob, mob/living/user)
	if(!ishuman(attacked_mob))
		return ..()

	var/mob/living/carbon/human/target_human = attacked_mob
	var/location = user.zone_selected
	var/obj/item/bodypart/head/noggin = target_human.get_bodypart(BODY_ZONE_HEAD)
	var/static/list/head_zones = list(BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_HEAD)

	if(!noggin && (location in head_zones))
		to_chat(user, span_warning("[target_human] doesn't have a head!"))
		return

	if(!(location in head_zones) && !(user.istate & ISTATE_HARM))
		to_chat(user, span_warning("You stop, look down at what you're currently holding and ponder to yourself, \"This is probably to be used on their hair or their facial hair.\""))
		return

	if(location == BODY_ZONE_PRECISE_MOUTH)
		if(!get_location_accessible(target_human, location))
			to_chat(user, span_warning("The mask is in the way!"))
			return

		if(!(noggin.head_flags & HEAD_FACIAL_HAIR))
			to_chat(user, span_warning("There is no facial hair to style!"))
			return

		if(HAS_TRAIT(target_human, TRAIT_SHAVED))
			to_chat(user, span_warning("[target_human] is just way too shaved. Like, really really shaved."))
			return

		if(target_human.facial_hairstyle == "Shaved")
			to_chat(user, span_warning("Already clean-shaven!"))
			return

		var/self_shaving = target_human == user // Shaving yourself?
		user.visible_message(span_notice("[user] starts to shave [self_shaving ? user.p_their() : "[target_human]'s"] hair with [src]."), \
			span_notice("You take a moment to shave [self_shaving ? "your" : "[target_human]'s" ] hair with [src]..."))

		if(do_after(user, shaving_time, target = target_human))
			user.visible_message(span_notice("[user] shaves [self_shaving ? user.p_their() : "[target_human]'s"] hair clean with [src]."), \
				span_notice("You finish shaving [self_shaving ? "your" : " [target_human]'s"] hair with [src]. Fast and clean!"))

			shave(target_human, location)

	else if(location == BODY_ZONE_HEAD)

		if(!get_location_accessible(target_human, location))
			to_chat(user, span_warning("The headgear is in the way!"))
			return

		if(!(noggin.head_flags & HEAD_HAIR))
			to_chat(user, span_warning("There is no hair to shave!"))
			return

		if(target_human.hairstyle == "Bald" || target_human.hairstyle == "Balding Hair" || target_human.hairstyle == "Skinhead")
			to_chat(user, span_warning("There is not enough hair left to shave!"))
			return

		if(HAS_TRAIT(target_human, TRAIT_SHAVED))
			to_chat(user, span_warning("[target_human] is just way too shaved. Like, really really shaved."))
			return

		var/self_shaving = target_human == user // Shaving yourself?
		user.visible_message(span_notice("[user] starts to shave [self_shaving ? user.p_their() : "[target_human]'s"] hair with [src]."), \
			span_notice("You take a moment to shave [self_shaving ? "your" : "[target_human]'s" ] hair with [src]..."))

		if(do_after(user, shaving_time, target = target_human))
			user.visible_message(span_notice("[user] shaves [self_shaving ? user.p_their() : "[target_human]'s"] hair clean with [src]."), \
				span_notice("You finish shaving [self_shaving ? "your" : " [target_human]'s"] hair with [src]. Fast and clean!"))

			shave(target_human, location)

		return

	return ..()

/obj/structure/sign/barber
	name = "barbershop sign"
	desc = "A glowing red-blue-white stripe you won't mistake for any other!"
	icon = 'monkestation/code/modules/blueshift/icons/items.dmi'
	icon_state = "barber"
	buildable_sign = FALSE // Don't want them removed, they look too jank.

/obj/item/storage/box/perfume
	name = "box of perfumes"

/obj/item/storage/box/perfume/PopulateContents()
	new /obj/item/perfume/cologne(src)
	new /obj/item/perfume/wood(src)
	new /obj/item/perfume/rose(src)
	new /obj/item/perfume/jasmine(src)
	new /obj/item/perfume/mint(src)
	new /obj/item/perfume/vanilla(src)
	new /obj/item/perfume/pear(src)
	new /obj/item/perfume/strawberry(src)
	new /obj/item/perfume/cherry(src)
	new /obj/item/perfume/amber(src)

/obj/item/reagent_containers/spray/quantum_hair_dye
	name = "quantum hair dye"
	desc = "Changes hair colour RANDOMLY! Don't forget to read the label!"
	icon = 'monkestation/code/modules/blueshift/icons/items.dmi'
	icon_state = "hairspraywhite"
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = list(1, 5)
	list_reagents = list(/datum/reagent/hair_dye = 30)
	volume = 50

/obj/item/reagent_containers/spray/baldium
	name = "baldium spray"
	desc = "Causes baldness, exessive use may cause customer disatisfaction."
	icon = 'monkestation/code/modules/blueshift/icons/items.dmi'
	icon_state = "hairremoval"
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = list(1, 5)
	list_reagents = list(/datum/reagent/baldium = 30)
	volume = 50

/obj/item/reagent_containers/spray/barbers_aid
	name = "barber's aid"
	desc = "Causes rapid hair and facial hair growth!"
	icon = 'monkestation/code/modules/blueshift/icons/items.dmi'
	icon_state = "hairaccelerator"
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = list(1, 5)
	list_reagents = list(/datum/reagent/barbers_aid = 50)
	volume = 50

/obj/item/reagent_containers/spray/super_barbers_aid
	name = "super barber's aid"
	desc = "Causes SUPER rapid hair and facial hair growth!"
	icon = 'monkestation/code/modules/blueshift/icons/items.dmi'
	icon_state = "hairaccelerator"
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = list(1, 5)
	list_reagents = list(/datum/reagent/concentrated_barbers_aid = 30)
	volume = 50

// Hairbrushes

/obj/item/hairbrush
	name = "hairbrush"
	desc = "A small, circular brush with an ergonomic grip for efficient brush application."
	icon = 'monkestation/code/modules/blueshift/icons/hairbrush.dmi'
	icon_state = "brush"
	inhand_icon_state = "inhand"
	lefthand_file = 'monkestation/code/modules/blueshift/icons/inhand_left.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/inhand_right.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/brush_speed = 3 SECONDS

/obj/item/hairbrush/attack(mob/target, mob/user)
	if(target.stat == DEAD)
		to_chat(usr, span_warning("There isn't much point brushing someone who can't appreciate it!"))
		return
	brush(target, user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Brushes someone, giving them a small mood boost
/obj/item/hairbrush/proc/brush(mob/living/target, mob/user)
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		var/obj/item/bodypart/head = human_target.get_bodypart(BODY_ZONE_HEAD)

		// Don't brush if you can't reach their head or cancel the action
		if(!head)
			to_chat(user, span_warning("[human_target] has no head!"))
			return
		if(human_target.is_mouth_covered(ITEM_SLOT_HEAD))
			to_chat(user, span_warning("You can't brush [human_target]'s hair while [human_target.p_their()] head is covered!"))
			return
		if(!do_after(user, brush_speed, human_target))
			return

		// Do 1 brute to their head if they're bald. Should've been more careful.
		if(human_target.hairstyle == "Bald" || human_target.hairstyle == "Skinhead" && is_species(human_target, /datum/species/human)) //It can be assumed most anthros have hair on them!
			human_target.visible_message(span_warning("[usr] scrapes the bristles uncomfortably over [human_target]'s scalp."), span_warning("You scrape the bristles uncomfortably over [human_target]'s scalp."))
			head.receive_damage(1)
			return

		// Brush their hair
		if(human_target == user)
			human_target.visible_message(span_notice("[usr] brushes [usr.p_their()] hair!"), span_notice("You brush your hair."))
			human_target.add_mood_event("brushed", /datum/mood_event/brushed/self)
		else
			user.visible_message(span_notice("[usr] brushes [human_target]'s hair!"), span_notice("You brush [human_target]'s hair."), ignored_mobs=list(human_target))
			human_target.show_message(span_notice("[usr] brushes your hair!"), MSG_VISUAL)
			human_target.add_mood_event("brushed", /datum/mood_event/brushed, user)

	else if(istype(target, /mob/living/basic/pet))
		if(!do_after(usr, brush_speed, target))
			return
		to_chat(user, span_notice("[target] closes [target.p_their()] eyes as you brush [target.p_them()]!"))
		var/mob/living/living_user = user
		if(istype(living_user))
			living_user.add_mood_event("brushed", /datum/mood_event/brushed/pet, target)

/datum/mood_event/brushed
	description = span_nicegreen("Someone brushed my hair recently, that felt great!\n")
	mood_change = 3
	timeout = 4 MINUTES

/datum/mood_event/brushed/add_effects(mob/brusher)
	description = span_nicegreen("[brusher? brusher.name : "I"] brushed my hair recently, that felt great!\n")

/datum/mood_event/brushed/self
	description = span_nicegreen("I brushed my hair recently!\n")
	mood_change = 2		// You can't hit all the right spots yourself, or something

/datum/mood_event/brushed/pet/add_effects(mob/brushed_pet)
	description = span_nicegreen("I brushed [brushed_pet] recently, they're so cute!\n")
