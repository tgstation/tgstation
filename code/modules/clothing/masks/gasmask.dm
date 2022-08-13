/obj/item/clothing/mask/gas
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply. Good for concealing your identity and with a filter slot to help remove those toxins." //More accurate
	icon_state = "gas_alt"
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS | GAS_FILTERING
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	w_class = WEIGHT_CLASS_NORMAL
	inhand_icon_state = "gas_alt"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, FIRE = 0, ACID = 0)
	flags_cover = MASKCOVERSEYES | MASKCOVERSMOUTH | PEPPERPROOF
	resistance_flags = NONE
	///Max numbers of installable filters
	var/max_filters = 1
	///List to keep track of each filter
	var/list/gas_filters
	///Type of filter that spawns on roundstart
	var/starting_filter_type = /obj/item/gas_filter
	///Does the mask have an FOV?
	var/has_fov = TRUE

/obj/item/clothing/mask/gas/Initialize(mapload)
	. = ..()
	init_fov()
	if(!max_filters || !starting_filter_type)
		return

	for(var/i in 1 to max_filters)
		var/obj/item/gas_filter/inserted_filter = new starting_filter_type(src)
		LAZYADD(gas_filters, inserted_filter)
	has_filter = TRUE

/obj/item/clothing/mask/gas/Destroy()
	QDEL_LAZYLIST(gas_filters)
	return..()

/obj/item/clothing/mask/gas/examine(mob/user)
	. = ..()
	if(max_filters > 0)
		. += "<span class='notice'>[src] has [max_filters] slot\s for filters.</span>"
	if(LAZYLEN(gas_filters) > 0)
		. += "<span class='notice'>Currently there [LAZYLEN(gas_filters) == 1 ? "is" : "are"] [LAZYLEN(gas_filters)] filter\s with [get_filter_durability()]% durability.</span>"
		. += "<span class='notice'>The filters can be removed by right-clicking with an empty hand on [src].</span>"

/obj/item/clothing/mask/gas/attackby(obj/item/tool, mob/user)
	if(!istype(tool, /obj/item/gas_filter))
		return ..()
	if(LAZYLEN(gas_filters) >= max_filters)
		return ..()
	if(!user.transferItemToLoc(tool, src))
		return ..()
	LAZYADD(gas_filters, tool)
	has_filter = TRUE
	return TRUE

/obj/item/clothing/mask/gas/attack_hand_secondary(mob/user, list/modifiers)
	if(!has_filter || !max_filters)
		return SECONDARY_ATTACK_CONTINUE_CHAIN
	for(var/i in 1 to max_filters)
		var/obj/item/gas_filter/filter = locate() in src
		if(!filter)
			continue
		user.put_in_hands(filter)
		LAZYREMOVE(gas_filters, filter)
	if(LAZYLEN(gas_filters) <= 0)
		has_filter = FALSE
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

///Check _masks.dm for this one
/obj/item/clothing/mask/gas/consume_filter(datum/gas_mixture/breath)
	if(LAZYLEN(gas_filters) <= 0 || max_filters == 0)
		return breath
	var/obj/item/gas_filter/gas_filter = pick(gas_filters)
	var/datum/gas_mixture/filtered_breath = gas_filter.reduce_filter_status(breath)
	if(gas_filter.filter_status <= 0)
		LAZYREMOVE(gas_filters, gas_filter)
		qdel(gas_filter)
	if(LAZYLEN(gas_filters) <= 0)
		has_filter = FALSE
	return filtered_breath

/// Initializes the FoV component for the gas mask
/obj/item/clothing/mask/gas/proc/init_fov()
	if (has_fov)
		AddComponent(/datum/component/clothing_fov_visor, FOV_90_DEGREES)

/**
 * Getter for overall filter durability, takes into consideration all filters filter_status
 */
/obj/item/clothing/mask/gas/proc/get_filter_durability()
	var/max_filters_durability = LAZYLEN(gas_filters) * 100
	var/current_filters_durability
	for(var/obj/item/gas_filter/gas_filter as anything in gas_filters)
		current_filters_durability += gas_filter.filter_status
	var/durability = (current_filters_durability / max_filters_durability) * 100
	return durability

/obj/item/clothing/mask/gas/atmos
	name = "atmospheric gas mask"
	desc = "Improved gas mask utilized by atmospheric technicians. It's flameproof!"
	icon_state = "gas_atmos"
	inhand_icon_state = "gas_atmos"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 100, FIRE = 20, ACID = 10)
	resistance_flags = FIRE_PROOF
	max_filters = 3

/obj/item/clothing/mask/gas/atmos/captain
	name = "captain's gas mask"
	desc = "Nanotrasen cut corners and repainted a spare atmospheric gas mask, but don't tell anyone."
	icon_state = "gas_cap"
	inhand_icon_state = "gas_cap"
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/mask/gas/atmos/centcom
	name = "\improper CentCom gas mask"
	desc = "Oooh, gold and green. Fancy! This should help as you sit in your office."
	icon = 'icons/obj/clothing/masks.dmi'
	worn_icon = 'icons/mob/clothing/mask.dmi'
	worn_icon_state = "gas_centcom"
	icon_state = "gas_centcom"
	inhand_icon_state = "gas_centcom"
	resistance_flags = FIRE_PROOF | ACID_PROOF

// **** Welding gas mask ****

/obj/item/clothing/mask/gas/welding
	name = "welding mask"
	desc = "A gas mask with built-in welding goggles and a face shield. Looks like a skull - clearly designed by a nerd."
	icon_state = "weldingmask"
	flash_protect = FLASH_PROTECTION_WELDER
	custom_materials = list(/datum/material/iron=4000, /datum/material/glass=2000)
	tint = 2
	armor = list(MELEE = 10, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 100, FIRE = 100, ACID = 55)
	actions_types = list(/datum/action/item_action/toggle)
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDESNOUT
	flags_cover = MASKCOVERSEYES
	visor_flags_inv = HIDEEYES
	visor_flags_cover = MASKCOVERSEYES
	resistance_flags = FIRE_PROOF

/obj/item/clothing/mask/gas/welding/attack_self(mob/user)
	weldingvisortoggle(user)

/obj/item/clothing/mask/gas/welding/up

/obj/item/clothing/mask/gas/welding/up/Initialize(mapload)
	. = ..()
	visor_toggling()

// ********************************************************************

//Plague Dr suit can be found in clothing/suits/bio.dm
/obj/item/clothing/mask/gas/plaguedoctor
	name = "plague doctor mask"
	desc = "A modernised version of the classic design, this mask will not only filter out toxins but it can also be connected to an air supply."
	icon_state = "plaguedoctor"
	inhand_icon_state = "gas_mask"
	has_fov = FALSE
	flags_cover = MASKCOVERSEYES

/obj/item/clothing/mask/gas/syndicate
	name = "syndicate mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "syndicate"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	strip_delay = 60
	w_class = WEIGHT_CLASS_SMALL
	has_fov = FALSE

/obj/item/clothing/mask/gas/clown_hat
	name = "clown wig and mask"
	desc = "A true prankster's facial attire. A clown is incomplete without his wig and mask."
	clothing_flags = MASKINTERNALS
	icon_state = "clown"
	inhand_icon_state = "clown_hat"
	dye_color = DYE_CLOWN
	w_class = WEIGHT_CLASS_SMALL
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE
	actions_types = list(/datum/action/item_action/adjust)
	dog_fashion = /datum/dog_fashion/head/clown
	species_exception = list(/datum/species/golem/bananium)
	has_fov = FALSE
	var/list/clownmask_designs = list()

/obj/item/clothing/mask/gas/clown_hat/plasmaman
	starting_filter_type = /obj/item/gas_filter/plasmaman

/obj/item/clothing/mask/gas/clown_hat/Initialize(mapload)
	.=..()
	clownmask_designs = list(
		"True Form" = image(icon = src.icon, icon_state = "clown"),
		"The Feminist" = image(icon = src.icon, icon_state = "sexyclown"),
		"The Jester" = image(icon = src.icon, icon_state = "chaos"),
		"The Madman" = image(icon = src.icon, icon_state = "joker"),
		"The Rainbow Color" = image(icon = src.icon, icon_state = "rainbow")
		)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CLOWN, CELL_VIRUS_TABLE_GENERIC, rand(2,3), 0)

/obj/item/clothing/mask/gas/clown_hat/ui_action_click(mob/user)
	if(!istype(user) || user.incapacitated())
		return

	var/list/options = list()
	options["True Form"] = "clown"
	options["The Feminist"] = "sexyclown"
	options["The Madman"] = "joker"
	options["The Rainbow Color"] ="rainbow"
	options["The Jester"] ="chaos" //Nepeta33Leijon is holding me captive and forced me to help with this please send help

	var/choice = show_radial_menu(user,src, clownmask_designs, custom_check = FALSE, radius = 36, require_near = TRUE)
	if(!choice)
		return FALSE

	if(src && choice && !user.incapacitated() && in_range(user,src))
		icon_state = options[choice]
		user.update_inv_wear_mask()
		update_action_buttons()
		to_chat(user, span_notice("Your Clown Mask has now morphed into [choice], all praise the Honkmother!"))
		return TRUE

/obj/item/clothing/mask/gas/sexyclown
	name = "sexy-clown wig and mask"
	desc = "A feminine clown mask for the dabbling crossdressers or female entertainers."
	clothing_flags = MASKINTERNALS
	icon_state = "sexyclown"
	inhand_icon_state = "sexyclown"
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE
	species_exception = list(/datum/species/golem/bananium)
	has_fov = FALSE

/obj/item/clothing/mask/gas/mime
	name = "mime mask"
	desc = "The traditional mime's mask. It has an eerie facial posture."
	clothing_flags = MASKINTERNALS
	icon_state = "mime"
	inhand_icon_state = "mime"
	w_class = WEIGHT_CLASS_SMALL
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE
	actions_types = list(/datum/action/item_action/adjust)
	species_exception = list(/datum/species/golem)
	has_fov = FALSE
	var/list/mimemask_designs = list()

/obj/item/clothing/mask/gas/mime/plasmaman
	starting_filter_type = /obj/item/gas_filter/plasmaman

/obj/item/clothing/mask/gas/mime/Initialize(mapload)
	.=..()
	mimemask_designs = list(
		"Blanc" = image(icon = src.icon, icon_state = "mime"),
		"Excité" = image(icon = src.icon, icon_state = "sexymime"),
		"Triste" = image(icon = src.icon, icon_state = "sadmime"),
		"Effrayé" = image(icon = src.icon, icon_state = "scaredmime")
		)

/obj/item/clothing/mask/gas/mime/ui_action_click(mob/user)
	if(!istype(user) || user.incapacitated())
		return

	var/list/options = list()
	options["Blanc"] = "mime"
	options["Triste"] = "sadmime"
	options["Effrayé"] = "scaredmime"
	options["Excité"] ="sexymime"

	var/choice = show_radial_menu(user,src, mimemask_designs, custom_check = FALSE, radius = 36, require_near = TRUE)
	if(!choice)
		return FALSE

	if(src && choice && !user.incapacitated() && in_range(user,src))
		icon_state = options[choice]
		user.update_inv_wear_mask()
		update_action_buttons()
		to_chat(user, span_notice("Your Mime Mask has now morphed into [choice]!"))
		return TRUE

/obj/item/clothing/mask/gas/monkeymask
	name = "monkey mask"
	desc = "A mask used when acting as a monkey."
	clothing_flags = MASKINTERNALS
	icon_state = "monkeymask"
	inhand_icon_state = "monkeymask"
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE
	has_fov = FALSE

/obj/item/clothing/mask/gas/sexymime
	name = "sexy mime mask"
	desc = "A traditional female mime's mask."
	clothing_flags = MASKINTERNALS
	icon_state = "sexymime"
	inhand_icon_state = "sexymime"
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE
	species_exception = list(/datum/species/golem)
	has_fov = FALSE

/obj/item/clothing/mask/gas/cyborg
	name = "cyborg visor"
	desc = "Beep boop."
	icon_state = "death"
	resistance_flags = FLAMMABLE
	has_fov = FALSE
	flags_cover = MASKCOVERSEYES

/obj/item/clothing/mask/gas/owl_mask
	name = "owl mask"
	desc = "Twoooo!"
	icon_state = "owl"
	clothing_flags = MASKINTERNALS
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE
	has_fov = FALSE

/obj/item/clothing/mask/gas/carp
	name = "carp mask"
	desc = "Gnash gnash."
	icon_state = "carp_mask"
	has_fov = FALSE
	flags_cover = MASKCOVERSEYES

/obj/item/clothing/mask/gas/tiki_mask
	name = "tiki mask"
	desc = "A creepy wooden mask. Surprisingly expressive for a poorly carved bit of wood."
	icon_state = "tiki_eyebrow"
	inhand_icon_state = "tiki_eyebrow"
	custom_materials = list(/datum/material/wood = MINERAL_MATERIAL_AMOUNT * 1.25)
	resistance_flags = FLAMMABLE
	has_fov = FALSE
	flags_cover = MASKCOVERSEYES
	max_integrity = 100
	actions_types = list(/datum/action/item_action/adjust)
	dog_fashion = null
	species_exception = list(/datum/species/golem/wood)
	var/list/tikimask_designs = list()

/obj/item/clothing/mask/gas/tiki_mask/Initialize(mapload)
	.=..()
	tikimask_designs = list(
		"Original Tiki" = image(icon = src.icon, icon_state = "tiki_eyebrow"),
		"Happy Tiki" = image(icon = src.icon, icon_state = "tiki_happy"),
		"Confused Tiki" = image(icon = src.icon, icon_state = "tiki_confused"),
		"Angry Tiki" = image(icon = src.icon, icon_state = "tiki_angry")
		)

/obj/item/clothing/mask/gas/tiki_mask/ui_action_click(mob/user)
	var/mob/M = usr
	var/list/options = list()
	options["Original Tiki"] = "tiki_eyebrow"
	options["Happy Tiki"] = "tiki_happy"
	options["Confused Tiki"] = "tiki_confused"
	options["Angry Tiki"] ="tiki_angry"

	var/choice = show_radial_menu(user,src, tikimask_designs, custom_check = FALSE, radius = 36, require_near = TRUE)
	if(!choice)
		return FALSE

	if(src && choice && !M.stat && in_range(M,src))
		icon_state = options[choice]
		user.update_inv_wear_mask()
		update_action_buttons()
		to_chat(M, span_notice("The Tiki Mask has now changed into the [choice] Mask!"))
		return 1

/obj/item/clothing/mask/gas/tiki_mask/yalp_elor
	icon_state = "tiki_yalp"
	actions_types = list()

/obj/item/clothing/mask/gas/hunter
	name = "bounty hunting mask"
	desc = "A custom tactical mask with decals added."
	icon_state = "hunter"
	inhand_icon_state = "hunter"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_inv = HIDEFACIALHAIR|HIDEFACE|HIDEEYES|HIDEEARS|HIDEHAIR|HIDESNOUT
	has_fov = FALSE

/obj/item/clothing/mask/gas/prop
	name = "prop gas mask"
	desc = "A prop gas mask designed for appearance. Unlike a normal gas mask this does not filter gasses or protect against pepper spray."
	icon_state = "gas_prop"
	inhand_icon_state = "gas_prop"
	clothing_flags = NONE
	flags_cover = MASKCOVERSMOUTH
	resistance_flags = FLAMMABLE
	has_fov = FALSE

/obj/item/clothing/mask/gas/atmosprop
	name = "prop atmospheric gas mask"
	desc = "A prop atmospheric gas mask designed for appearance. Unlike a normal atmospheric gas mask this does not filter gasses or protect against pepper spray."
	worn_icon_state = "gas_prop_atmos"
	icon_state = "gas_atmos"
	inhand_icon_state = "gas_atmos"
	clothing_flags = NONE
	flags_cover = MASKCOVERSMOUTH
	resistance_flags = FLAMMABLE
	has_fov = FALSE

/obj/item/clothing/mask/gas/driscoll
	name = "driscoll mask"
	desc = "Great for train hijackings. Works like a normal full face gas mask, but won't conceal your identity."
	icon_state = "driscoll_mask"
	flags_inv = HIDEFACIALHAIR
	w_class = WEIGHT_CLASS_NORMAL
	inhand_icon_state = "driscoll_mask"
