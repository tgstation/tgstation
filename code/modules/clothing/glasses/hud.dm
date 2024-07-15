/obj/item/clothing/glasses/hud
	name = "HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	flags_1 = null //doesn't protect eyes because it's a monocle, duh
	///A list of atom hud types added to the mob when the glasses are worn on the appropriate slot.
	var/list/hud_types

	// NOTE: Just because you have a HUD display doesn't mean you should be able to interact with stuff on examine, that's where the associated trait (TRAIT_MEDICAL_HUD, TRAIT_SECURITY_HUD, etc) is necessary.

/obj/item/clothing/glasses/hud/equipped(mob/living/carbon/human/user, slot)
	..()
	if(!(slot & ITEM_SLOT_EYES))
		return
	for(var/hud_type in hud_types)
		var/datum/atom_hud/our_hud = GLOB.huds[hud_type]
		our_hud.show_to(user)

/obj/item/clothing/glasses/hud/dropped(mob/living/carbon/human/user)
	..()
	if(!istype(user) || user.glasses != src)
		return
	for(var/hud_type in hud_types)
		var/datum/atom_hud/our_hud = GLOB.huds[hud_type]
		our_hud.hide_from(user)

/obj/item/clothing/glasses/hud/emp_act(severity)
	. = ..()
	if(obj_flags & EMAGGED || . & EMP_PROTECT_SELF)
		return
	obj_flags |= EMAGGED
	desc = "[desc] The display is flickering slightly."

/obj/item/clothing/glasses/hud/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	balloon_alert(user, "display scrambled")
	desc = "[desc] The display is flickering slightly."
	return TRUE

/obj/item/clothing/glasses/hud/suicide_act(mob/living/user)
	if(user.is_blind())
		return SHAME
	var/mob/living/living_user = user
	user.visible_message(span_suicide("[user] looks through [src] and looks overwhelmed with the information! It looks like [user.p_theyre()] trying to commit suicide!"))
	if(living_user.get_organ_loss(ORGAN_SLOT_BRAIN) >= BRAIN_DAMAGE_SEVERE)
		var/mob/thing = pick((/mob in view()) - user)
		if(thing)
			user.say("VALID MAN IS WANTER, ARREST HE!!")
			user.pointed(thing)
		else
			user.say("WHY IS THERE A BAR ON MY HEAD?!!")
	return OXYLOSS

/obj/item/clothing/glasses/hud/health
	name = "health scanner HUD"
	desc = "A heads-up display that scans the humanoids in view and provides accurate data about their health status."
	icon_state = "healthhud"
	hud_types = list(DATA_HUD_MEDICAL_ADVANCED)
	clothing_traits = list(TRAIT_MEDICAL_HUD)
	glass_colour_type = /datum/client_colour/glass_colour/lightblue

/obj/item/clothing/glasses/hud/medsechud
	name = "health scanner security HUD"
	desc = "A heads-up display that scans the humanoids in view and provides accurate data about their health status, ID status and security records."
	icon_state = "medsechud"
	hud_types = list(DATA_HUD_MEDICAL_ADVANCED, DATA_HUD_SECURITY_ADVANCED)
	clothing_traits = list(TRAIT_MEDICAL_HUD, TRAIT_SECURITY_HUD)

/obj/item/clothing/glasses/hud/health/night
	name = "night vision health scanner HUD"
	desc = "An advanced medical heads-up display that allows doctors to find patients in complete darkness."
	icon_state = "healthhudnight"
	inhand_icon_state = "glasses"
	flash_protect = FLASH_PROTECTION_SENSITIVE
	flags_cover = GLASSESCOVERSEYES
	// Blue green, dark
	color_cutoffs = list(20, 20, 45)
	glass_colour_type = /datum/client_colour/glass_colour/lightgreen
	actions_types = list(/datum/action/item_action/toggle_nv)
	forced_glass_color = TRUE

/obj/item/clothing/glasses/hud/health/night/update_icon_state()
	. = ..()
	icon_state = length(color_cutoffs) ? initial(icon_state) : "night_off"

/obj/item/clothing/glasses/hud/health/night/meson
	name = "night vision meson health scanner HUD"
	desc = "Truly combat ready."
	vision_flags = SEE_TURFS

/obj/item/clothing/glasses/hud/health/night/science
	name = "night vision medical science scanner HUD"
	desc = "An clandestine medical science heads-up display that allows operatives to find \
		dying captains and the perfect poison to finish them off in complete darkness."
	clothing_traits = list(TRAIT_REAGENT_SCANNER, TRAIT_MEDICAL_HUD)
	forced_glass_color = FALSE

/obj/item/clothing/glasses/hud/health/sunglasses
	name = "medical HUDSunglasses"
	desc = "Sunglasses with a medical HUD."
	icon_state = "sunhudmed"
	flash_protect = FLASH_PROTECTION_FLASH
	flags_cover = GLASSESCOVERSEYES
	tint = 1
	glass_colour_type = /datum/client_colour/glass_colour/blue

/obj/item/clothing/glasses/hud/health/sunglasses/Initialize(mapload)
	. = ..()
	var/static/list/slapcraft_recipe_list = list(/datum/crafting_recipe/hudsunmedremoval)

	AddElement(
		/datum/element/slapcrafting,\
		slapcraft_recipes = slapcraft_recipe_list,\
	)

/obj/item/clothing/glasses/hud/diagnostic
	name = "diagnostic HUD"
	desc = "A heads-up display capable of analyzing the integrity and status of robotics and exosuits."
	icon_state = "diagnostichud"
	hud_types = list(DATA_HUD_DIAGNOSTIC_BASIC)
	clothing_traits = list(TRAIT_DIAGNOSTIC_HUD)
	glass_colour_type = /datum/client_colour/glass_colour/lightorange

/obj/item/clothing/glasses/hud/diagnostic/night
	name = "night vision diagnostic HUD"
	desc = "A robotics diagnostic HUD fitted with a light amplifier."
	icon_state = "diagnostichudnight"
	inhand_icon_state = "glasses"
	flash_protect = FLASH_PROTECTION_SENSITIVE
	flags_cover = GLASSESCOVERSEYES
	// Pale yellow
	color_cutoffs = list(25, 15, 5)
	glass_colour_type = /datum/client_colour/glass_colour/lightyellow
	actions_types = list(/datum/action/item_action/toggle_nv)
	forced_glass_color = TRUE

/obj/item/clothing/glasses/hud/diagnostic/night/update_icon_state()
	. = ..()
	icon_state = length(color_cutoffs) ? initial(icon_state) : "night_off"

/obj/item/clothing/glasses/hud/diagnostic/sunglasses
	name = "diagnostic sunglasses"
	desc = "Sunglasses with a diagnostic HUD."
	icon_state = "sunhuddiag"
	inhand_icon_state = "glasses"
	flash_protect = FLASH_PROTECTION_FLASH
	flags_cover = GLASSESCOVERSEYES
	tint = 1

/obj/item/clothing/glasses/hud/diagnostic/sunglasses/Initialize(mapload)
	. = ..()
	var/static/list/slapcraft_recipe_list = list(/datum/crafting_recipe/hudsundiagremoval)

	AddElement(
		/datum/element/slapcrafting,\
		slapcraft_recipes = slapcraft_recipe_list,\
	)

/obj/item/clothing/glasses/hud/security
	name = "security HUD"
	desc = "A heads-up display that scans the humanoids in view and provides accurate data about their ID status and security records."
	icon_state = "securityhud"
	hud_types = list(DATA_HUD_SECURITY_ADVANCED)
	clothing_traits = list(TRAIT_SECURITY_HUD)
	glass_colour_type = /datum/client_colour/glass_colour/red

/obj/item/clothing/glasses/hud/security/chameleon
	name = "chameleon security HUD"
	desc = "A stolen security HUD integrated with Syndicate chameleon technology. Provides flash protection."
	flash_protect = FLASH_PROTECTION_FLASH
	actions_types = list(/datum/action/item_action/chameleon/change/glasses/no_preset)

/obj/item/clothing/glasses/hud/security/sunglasses/eyepatch
	name = "eyepatch HUD"
	desc = "The cooler looking cousin of HUDSunglasses."
	icon_state = "hudpatch"
	base_icon_state = "hudpatch"
	actions_types = list(/datum/action/item_action/flip)

/obj/item/clothing/glasses/hud/security/sunglasses/eyepatch/attack_self(mob/user, modifiers)
	. = ..()
	icon_state = (icon_state == base_icon_state) ? "[base_icon_state]_flipped" : base_icon_state
	user.update_worn_glasses()

/obj/item/clothing/glasses/hud/security/sunglasses
	name = "security HUDSunglasses"
	desc = "Sunglasses with a security HUD."
	icon_state = "sunhudsec"
	flash_protect = FLASH_PROTECTION_FLASH
	flags_cover = GLASSESCOVERSEYES
	tint = 1
	glass_colour_type = /datum/client_colour/glass_colour/darkred

/obj/item/clothing/glasses/hud/security/sunglasses/Initialize(mapload)
	. = ..()
	var/static/list/slapcraft_recipe_list = list(/datum/crafting_recipe/hudsunsecremoval)

	AddElement(
		/datum/element/slapcrafting,\
		slapcraft_recipes = slapcraft_recipe_list,\
	)

/obj/item/clothing/glasses/hud/security/night
	name = "night vision security HUD"
	desc = "An advanced heads-up display that provides ID data and vision in complete darkness."
	icon_state = "securityhudnight"
	flash_protect = FLASH_PROTECTION_SENSITIVE
	flags_cover = GLASSESCOVERSEYES
	// Red with a tint of green
	color_cutoffs = list(40, 15, 10)
	glass_colour_type = /datum/client_colour/glass_colour/lightred
	actions_types = list(/datum/action/item_action/toggle_nv)
	forced_glass_color = TRUE

/obj/item/clothing/glasses/hud/security/night/update_icon_state()
	. = ..()
	icon_state = length(color_cutoffs) ? initial(icon_state) : "night_off"

/obj/item/clothing/glasses/hud/security/sunglasses/gars
	name = "\improper HUD gar glasses"
	desc = "GAR glasses with a HUD."
	icon_state = "gar_sec"
	inhand_icon_state = "gar_black"
	alternate_worn_layer = ABOVE_BODY_FRONT_HEAD_LAYER
	force = 10
	throwforce = 10
	throw_speed = 4
	attack_verb_continuous = list("slices")
	attack_verb_simple = list("slice")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP_EDGED

/obj/item/clothing/glasses/hud/security/sunglasses/gars/giga
	name = "giga HUD gar glasses"
	desc = "GIGA GAR glasses with a HUD."
	icon_state = "gigagar_sec"
	force = 12
	throwforce = 12

/obj/item/clothing/glasses/hud/toggle
	name = "Toggle HUD"
	desc = "A hud with multiple functions."
	flags_cover = GLASSESCOVERSEYES
	actions_types = list(/datum/action/item_action/switch_hud)

/obj/item/clothing/glasses/hud/toggle/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/wearer = user
	if (wearer.glasses != src)
		return

	for(var/hud_type in hud_types)
		var/datum/atom_hud/our_hud = GLOB.huds[hud_type]
		our_hud.hide_from(user)

	if (DATA_HUD_MEDICAL_ADVANCED in hud_types)
		hud_types = null
	else if (DATA_HUD_SECURITY_ADVANCED in hud_types)
		hud_types = list(DATA_HUD_MEDICAL_ADVANCED)
	else
		hud_types = list(DATA_HUD_SECURITY_ADVANCED)

	for(var/hud_type in hud_types)
		var/datum/atom_hud/our_hud = GLOB.huds[hud_type]
		our_hud.show_to(user)

/datum/action/item_action/switch_hud
	name = "Switch HUD"

/obj/item/clothing/glasses/hud/toggle/thermal
	name = "thermal HUD scanner"
	desc = "Thermal imaging HUD in the shape of glasses."
	icon_state = "thermal"
	hud_types = list(DATA_HUD_SECURITY_ADVANCED)
	vision_flags = SEE_MOBS
	color_cutoffs = list(25, 8, 5)
	glass_colour_type = /datum/client_colour/glass_colour/red

/obj/item/clothing/glasses/hud/toggle/thermal/attack_self(mob/user)
	..()
	var/hud_type = hud_types[1]
	switch (hud_type)
		if (DATA_HUD_MEDICAL_ADVANCED)
			icon_state = "meson"
			color_cutoffs = list(5, 15, 5)
			change_glass_color(/datum/client_colour/glass_colour/green)
		if (DATA_HUD_SECURITY_ADVANCED)
			icon_state = "thermal"
			color_cutoffs = list(25, 8, 5)
			change_glass_color(/datum/client_colour/glass_colour/red)
		else
			icon_state = "purple"
			color_cutoffs = list(15, 0, 25)
			change_glass_color(/datum/client_colour/glass_colour/purple)
	user.update_sight()
	user.update_worn_glasses()

/obj/item/clothing/glasses/hud/toggle/thermal/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	thermal_overload()

/obj/item/clothing/glasses/hud/spacecop
	name = "police aviators"
	desc = "For thinking you look cool while brutalizing protestors and minorities."
	icon_state = "bigsunglasses"
	flash_protect = FLASH_PROTECTION_FLASH
	flags_cover = GLASSESCOVERSEYES
	tint = 1
	glass_colour_type = /datum/client_colour/glass_colour/gray


/obj/item/clothing/glasses/hud/spacecop/hidden // for the undercover cop
	name = "sunglasses"
	desc = "These sunglasses are special, and let you view potential criminals."
	icon_state = "sun"
	inhand_icon_state = "sunglasses"
