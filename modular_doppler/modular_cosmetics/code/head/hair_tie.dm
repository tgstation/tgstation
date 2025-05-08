/obj/item/clothing/head/hair_tie
	name = "hair tie"
	desc = "An elastic hair tie, made to hold your hair up!"
	icon = 'modular_doppler/modular_cosmetics/icons/obj/head/hair_ties.dmi'
	icon_state = "hairtie"
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/head/hair_ties.dmi'
	worn_icon_state = "hair_tie_worn_no_icon"
	inhand_icon_state = null
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
	var/hair_id = tgui_input_list(user, "How does your hair look when it's up?", "Pick!", SSaccessories.hairstyles_list)
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
	user.set_hairstyle(picked_hairstyle, update = TRUE)

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
	user.set_hairstyle(actual_hairstyle, update = TRUE)
	actual_hairstyle = null

/obj/item/clothing/head/hair_tie/click_alt(mob/living/user)
	if(!(user.get_slot_by_item(src) == ITEM_SLOT_HANDS))
		balloon_alert(user, "hold in-hand!")
		return CLICK_ACTION_BLOCKING
	user.visible_message(
		span_danger("[user.name] puts [src] around [user.p_their()] fingers, beginning to flick it!"),
		span_notice("You try to flick [src]!"),
	)
	flick_hair_tie(user)
	return CLICK_ACTION_SUCCESS

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
	playsound(src, 'sound/items/weapons/effects/batreflect.ogg', 25, TRUE)
	//get rid of what we just launched to let projectile_drop spawn a new one
	qdel(src)

/obj/projectile/bullet/hair_tie
	icon = 'modular_doppler/modular_cosmetics/icons/obj/head/hair_ties.dmi'
	icon_state = "hairtie"
	hitsound = 'sound/items/weapons/genhit.ogg'
	damage = 0 //its just about the knockdown
	sharpness = NONE
	shrapnel_type = NONE //no embedding pls
	impact_effect_type = null
	ricochet_chance = 0
	range = 7
	knockdown = 1 SECONDS
