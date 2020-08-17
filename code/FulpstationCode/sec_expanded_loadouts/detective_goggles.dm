//Detective Goggles

#define MODE_NONE ""
#define MODE_MESON "meson"

/datum/design/detective_glasses
	name = "Detective Glasses"
	desc = "Stylish glasses with integrated medical, diagnostic and security HUDs and reagent scanning used by detectives. Has an integrated Meson Scanner mode. Flash proofing compromised to accomodate HUD integration."
	id = "detective_glasses"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/plastic = 2000, /datum/material/glass = 2000, /datum/material/silver = 1000, /datum/material/gold = 1000, /datum/material/uranium = 1000)
	build_path = /obj/item/clothing/glasses/detective
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/obj/item/clothing/glasses/detective
	name = "detective's glasses"
	desc = "Stylish glasses with integrated medical, diagnostic and security HUDs and reagent scanning used by detectives. The Meson Scanner mode lets you see basic structural and terrain layouts through walls. WARNING! Flash proofing has been compromised to accomodate HUD integration."
	icon = 'icons/Fulpicons/Surreal_stuff/detective_obs.dmi'
	worn_icon = 'icons/Fulpicons/Surreal_stuff/detective_obs_worn.dmi'
	icon_state = "sundetect-"
	inhand_icon_state = "sunglasses"
	actions_types = list(/datum/action/item_action/toggle_mode)

	vision_flags = NONE
	darkness_view = 2
	invis_view = SEE_INVISIBLE_LIVING

	var/list/modes = list(MODE_NONE = MODE_MESON, MODE_MESON = MODE_NONE)
	var/mode = MODE_NONE
	var/range = 1
	var/emped = FALSE //whether or not it's subject to the effects of an EMP.

	clothing_flags = SCAN_REAGENTS //You can see reagents while wearing detective glasses
	resistance_flags = ACID_PROOF
	glass_colour_type = /datum/client_colour/glass_colour/red
	armor = list("melee" = 0, "bullet" = 0, "laser" = 5, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 25, "fire" = 100, "acid" = 100)

/obj/item/clothing/glasses/detective/Initialize()
	. = ..()
	update_icon()

/obj/item/clothing/glasses/detective/dropped(mob/user)
	..()
	remove_sensors(user)

/obj/item/clothing/glasses/detective/equipped(mob/user, slot)
	..()
	add_sensors(user, slot)

/obj/item/clothing/glasses/detective/proc/remove_sensors(mob/user)
	if(!user)
		if(ismob(loc))
			user = loc
		else
			return
	var/datum/atom_hud/secsensor = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	var/datum/atom_hud/diagsensor = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
	secsensor.remove_hud_from(user)
	medsensor.remove_hud_from(user)
	diagsensor.remove_hud_from(user)

/obj/item/clothing/glasses/detective/proc/add_sensors(mob/user, slot)
	if(emped) //doesn't function while affected by EMPs.
		return
	if(slot != ITEM_SLOT_EYES)
		return
	if(!user)
		if(ismob(loc))
			user = loc
		else
			return
	var/datum/atom_hud/secsensor = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	var/datum/atom_hud/diagsensor = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
	secsensor.add_hud_to(user)
	medsensor.add_hud_to(user)
	diagsensor.add_hud_to(user)


/obj/item/clothing/glasses/detective/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	emp_overload(severity)

/obj/item/clothing/glasses/detective/proc/emp_overload(severity)
	if(ismob(src.loc))
		var/mob/M = src.loc
		to_chat(M, "<span class='danger'>[src]' hud abruptly flickers out as it overloads!</span>")
		remove_sensors(M)
	if(mode == MODE_MESON) //disable mesons if active
		vision_flags = NONE
		darkness_view = 2
		lighting_alpha = null
		mode = MODE_NONE
	emped = TRUE
	addtimer(CALLBACK(src, /obj/item/clothing/glasses/detective/.proc/emp_recover), rand(100*severity, 200*severity))


/obj/item/clothing/glasses/detective/proc/emp_recover(slot)
	emped = FALSE
	if(!ishuman(src.loc))
		return
	var/mob/living/carbon/human/H = src.loc
	if(H.glasses == src)
		to_chat(H, "<span class='notice'>[src]' hud elements flicker and shutter back into view as its interface reboots.</span>")
		add_sensors(H, ITEM_SLOT_EYES)



/obj/item/clothing/glasses/detective/Destroy()
	remove_sensors()
	return ..()

/obj/item/clothing/glasses/detective/proc/toggle_mode(mob/user, voluntary)
	if(!user)
		if(!ismob(src.loc))
			return
		user = src.loc

	if(emped)
		to_chat(user, "<span class='warning'>[src]' hud elements flash and flicker, but fail to materialize.</span>")
		return

	mode = modes[mode]

	switch(mode)
		if(MODE_MESON)
			vision_flags = SEE_TURFS
			darkness_view = 1
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

		if(MODE_NONE) //undoes the last mode, meson
			vision_flags = NONE
			darkness_view = 2
			lighting_alpha = null

	if(user)
		to_chat(user, "<span class='[voluntary ? "notice":"warning"]'>[voluntary ? "You turn the goggles":"The goggles turn"] [mode ? "to [mode] mode":"off"][voluntary ? ".":"!"]</span>")
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.glasses == src)
				H.update_sight()

	update_icon()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/glasses/detective/attack_self(mob/user)
	toggle_mode(user, TRUE)

/obj/item/clothing/glasses/detective/update_icon()
	icon_state = "sundetect-[mode]"
	update_mob()

/obj/item/clothing/glasses/detective/proc/update_mob()
	inhand_icon_state = icon_state
	if(isliving(loc))
		var/mob/living/user = loc
		if(user.get_item_by_slot(ITEM_SLOT_EYES) == src)
			user.update_inv_glasses()
		else
			user.update_inv_hands()

#undef MODE_NONE
#undef MODE_MESON
