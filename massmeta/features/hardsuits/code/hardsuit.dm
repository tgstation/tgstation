/// How much damage you take from an emp when wearing a hardsuit
#define HARDSUIT_EMP_BURN 2 // a very orange number

/obj/item/clothing/suit/space/hardsuit
	name = "hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon = 'massmeta/features/hardsuits/icons/suits.dmi'
	worn_icon = 'massmeta/features/hardsuits/icons/suit.dmi'
	icon_state = "hardsuit-engineering"
	max_integrity = 300
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	armor_type = /datum/armor/hardsuit
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/t_scanner, /obj/item/construction/rcd, /obj/item/pipe_dispenser)
	siemens_coefficient = 0
	actions_types = list(/datum/action/item_action/toggle_helmet)
	supports_variations_flags = NONE

	var/obj/item/clothing/head/helmet/space/hardsuit/helmet
	var/helmettype = /obj/item/clothing/head/helmet/space/hardsuit
	var/obj/item/tank/jetpack/suit/jetpack = null
	var/hardsuit_type
	/// Whether the helmet is on.
	var/helmet_on = FALSE

/obj/item/clothing/suit/space/hardsuit/Initialize(mapload)
	. = ..()
	if(jetpack && ispath(jetpack))
		jetpack = new jetpack(src)

	MakeHelmet()

/obj/item/clothing/suit/space/hardsuit/Destroy()
	if(!QDELETED(helmet))
		QDEL_NULL(helmet)
	if(jetpack)
		QDEL_NULL(jetpack)
	return ..()

/obj/item/clothing/suit/space/hardsuit/proc/MakeHelmet()
	if(!helmettype)
		return
	if(!helmet)
		var/obj/item/clothing/head/helmet/space/hardsuit/W = new helmettype(src)
		W.suit = src
		helmet = W

/obj/item/clothing/suit/space/hardsuit/proc/RemoveHelmet()
	if(!helmet)
		return
	helmet_on = FALSE
	if(ishuman(helmet.loc))
		var/mob/living/carbon/H = helmet.loc
		if(helmet.on)
			helmet.attack_self(H)
		H.transferItemToLoc(helmet, src, TRUE)
		H.update_worn_oversuit()
		to_chat(H, span_notice("The helmet on the hardsuit disengages."))
		playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, TRUE)
	else
		helmet.forceMove(src)

/obj/item/clothing/suit/space/hardsuit/proc/ToggleHelmet()
	var/mob/living/carbon/human/H = src.loc
	if(!istype(src.loc) || !helmettype)
		return
	if(!helmet)
		to_chat(H, span_warning("The helmet's lightbulb seems to be damaged! You'll need a replacement bulb."))
		return
	if(!helmet_on)
		if(H.wear_suit != src)
			to_chat(H, span_warning("You must be wearing [src] to engage the helmet!"))
			return
		if(H.head)
			to_chat(H, span_warning("You're already wearing something on your head!"))
			return
		else if(H.equip_to_slot_if_possible(helmet,ITEM_SLOT_HEAD,0,0,1))
			to_chat(H, span_notice("You engage the helmet on the hardsuit."))
			helmet_on = TRUE
			H.update_worn_oversuit()
			playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, TRUE)
	else
		RemoveHelmet()

/obj/item/clothing/suit/space/hardsuit/ui_action_click()
	ToggleHelmet()

/obj/item/clothing/suit/space/hardsuit/attack_self(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	..()

/obj/item/clothing/suit/space/hardsuit/examine(mob/user)
	. = ..()
	if(!helmet && helmettype)
		. += span_notice("The helmet on [src] seems to be malfunctioning. Its light bulb needs to be replaced.")

/obj/item/clothing/suit/space/hardsuit/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tank/jetpack/suit))
		if(jetpack)
			to_chat(user, span_warning("[src] already has a jetpack installed."))
			return
		if(src == user.get_item_by_slot(ITEM_SLOT_OCLOTHING)) //Make sure the player is not wearing the suit before applying the upgrade.
			to_chat(user, span_warning("You cannot install the upgrade to [src] while wearing it."))
			return

		if(user.transferItemToLoc(I, src))
			jetpack = I
			to_chat(user, span_notice("You successfully install the jetpack into [src]."))
			return
	else if(!cell_cover_open && I.tool_behaviour == TOOL_SCREWDRIVER)
		if(!jetpack)
			to_chat(user, span_warning("[src] has no jetpack installed."))
			return
		if(src == user.get_item_by_slot(ITEM_SLOT_OCLOTHING))
			to_chat(user, span_warning("You cannot remove the jetpack from [src] while wearing it."))
			return

		jetpack.turn_off(user)
		jetpack.forceMove(drop_location())
		jetpack = null
		to_chat(user, span_notice("You successfully remove the jetpack from [src]."))
		return
	else if(istype(I, /obj/item/light) && helmettype)
		if(src == user.get_item_by_slot(ITEM_SLOT_OCLOTHING))
			to_chat(user, span_warning("You cannot replace the bulb in the helmet of [src] while wearing it."))
			return
		if(helmet)
			to_chat(user, span_warning("The helmet of [src] does not require a new bulb."))
			return
		var/obj/item/light/L = I
		if(L.status)
			to_chat(user, span_warning("This bulb is too damaged to use as a replacement!"))
			return
		if(do_after(user, 5 SECONDS, src))
			qdel(I)
			helmet = new helmettype(src)
			to_chat(user, span_notice("You have successfully repaired [src]'s helmet."))
			new /obj/item/light/bulb/broken(drop_location())
	return ..()

/obj/item/clothing/suit/space/hardsuit/equipped(mob/user, slot)
	..()
	if(helmet && slot != ITEM_SLOT_OCLOTHING)
		RemoveHelmet()

	if(jetpack)
		if(slot == ITEM_SLOT_OCLOTHING)
			for(var/X in jetpack.actions)
				var/datum/action/A = X
				A.Grant(user)

/obj/item/clothing/suit/space/hardsuit/dropped(mob/user)
	..()
	RemoveHelmet()
	if(jetpack)
		for(var/X in jetpack.actions)
			var/datum/action/A = X
			A.Remove(user)

/obj/item/clothing/suit/space/hardsuit/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_OCLOTHING) //we only give the mob the ability to toggle the helmet if he's wearing the hardsuit.
		return 1

/// Burn the person inside the hard suit just a little, the suit got really hot for a moment
/obj/item/clothing/suit/space/emp_act(severity)
	. = ..()
	var/mob/living/carbon/human/user = src.loc
	if(istype(user))
		user.apply_damage(HARDSUIT_EMP_BURN, BURN, spread_damage=TRUE)
		to_chat(user, span_warning("You feel \the [src] heat up from the EMP burning you slightly."))

		// Chance to scream
		if (user.stat < UNCONSCIOUS && prob(10))
			user.emote("scream")

/////////////////////////////////// ENGIE /////////////////////////////////////////////

/obj/item/clothing/head/helmet/space/hardsuit/engine
	name = "engineering hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "hardsuit0-engineering"
	armor_type = /datum/armor/hardsuit_engine
	hardsuit_type = "engineering"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/head/helmet/space/hardsuit/engine/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)

/obj/item/clothing/suit/space/hardsuit/engine
	name = "engineering hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "hardsuit-engineering"
	armor_type = /datum/armor/hardsuit_engine
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine
	slowdown = 0.5
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/space/hardsuit/engine/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)

/obj/item/clothing/suit/space/hardsuit/engine/equipped(mob/user, slot)
	. = ..()
	AddComponent(/datum/component/geiger_sound)

/obj/item/clothing/suit/space/hardsuit/engine/dropped()
	. = ..()
	var/datum/component/geiger_sound/GS = GetComponent(/datum/component/geiger_sound)
	if(GS)
		qdel(GS)

/////////////////////////////////// CE /////////////////////////////////////////////

/obj/item/clothing/head/helmet/space/hardsuit/engine/elite
	name = "advanced hardsuit helmet"
	desc = "An advanced helmet designed for work in a hazardous, low pressure environment. Shines with a high polish."
	inhand_icon_state = "ce_helm"
	hardsuit_type = "white"
	icon_state = "hardsuit0-white"
	armor_type = /datum/armor/hardsuit_engine_elite
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/engine/elite
	icon_state = "hardsuit-white"
	name = "advanced hardsuit"
	desc = "An advanced suit that protects against hazardous, low pressure environments. Shines with a high polish."
	inhand_icon_state = "ce_hardsuit"
	armor_type = /datum/armor/hardsuit_engine_elite
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine/elite
	jetpack = /obj/item/tank/jetpack/suit
	cell = /obj/item/stock_parts/cell/super
	slowdown = 0.4

/////////////////////////////////// ATMOSPHERICS /////////////////////////////////////////////

/obj/item/clothing/head/helmet/space/hardsuit/atmos
	name = "atmospherics hardsuit helmet"
	desc = "A modified engineering hardsuit for work in a hazardous, low pressure environment. The radiation shielding plates were removed to allow for improved thermal protection instead."
	icon_state = "hardsuit0-atmospherics"
	hardsuit_type = "atmospherics"
	armor_type = /datum/armor/hardsuit_atmos
	heat_protection = HEAD //Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/atmos
	name = "atmospherics hardsuit"
	desc = "A modified engineering hardsuit for work in a hazardous, low pressure environment. The radiation shielding plates were removed to allow for improved thermal protection instead."
	icon_state = "hardsuit-atmospherics"
	armor_type = /datum/armor/hardsuit_atmos
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS //Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/atmos
	slowdown = 0.5

/obj/item/clothing/suit/space/hardsuit/atmos/equipped(mob/user, slot)
	. = ..()
	AddComponent(/datum/component/geiger_sound)

/obj/item/clothing/suit/space/hardsuit/atmos/dropped()
	. = ..()
	var/datum/component/geiger_sound/GS = GetComponent(/datum/component/geiger_sound)
	if(GS)
		qdel(GS)

/////////////////////////////////// CMO /////////////////////////////////////////////

/obj/item/clothing/head/helmet/space/hardsuit/cmo
	name = "medical hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Built with lightweight materials for extra comfort, but does not protect the eyes from intense light."
	icon_state = "hardsuit0-medical"
	hardsuit_type = "medical"
	flash_protect = FLASH_PROTECTION_NONE
	armor_type = /datum/armor/hardsuit_medical
	clothing_traits = list(TRAIT_REAGENT_SCANNER)
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT

/obj/item/clothing/suit/space/hardsuit/cmo
	name = "medical hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Built with lightweight materials for easier movement."
	icon_state = "hardsuit-medical"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/storage/medkit, /obj/item/healthanalyzer, /obj/item/stack/medical)
	armor_type = /datum/armor/hardsuit_medical
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/combatmedic
	slowdown = 0.25

/////////////////////////////////// RD /////////////////////////////////////////////

/obj/item/clothing/head/helmet/space/hardsuit/rd
	name = "prototype hardsuit helmet"
	desc = "A prototype helmet designed for research in a hazardous, low pressure environment. Scientific data flashes across the visor."
	icon_state = "hardsuit0-rd"
	hardsuit_type = "rd"
	resistance_flags = ACID_PROOF | FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	armor_type = /datum/armor/hardsuit_rd
	clothing_traits = list(TRAIT_REAGENT_SCANNER, TRAIT_RESEARCH_SCANNER)
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT
	actions_types = list(/datum/action/item_action/toggle_helmet_light)
	var/explosion_detection_dist = 21

/obj/item/clothing/head/helmet/space/hardsuit/rd/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION, PROC_REF(sense_explosion))

/obj/item/clothing/head/helmet/space/hardsuit/rd/equipped(mob/living/carbon/human/user, slot)
	..()
	if (slot == ITEM_SLOT_HEAD)
		var/datum/atom_hud/DHUD = GLOB.huds[DATA_HUD_DIAGNOSTIC_BASIC]
		DHUD.show_to(user)

/obj/item/clothing/head/helmet/space/hardsuit/rd/dropped(mob/living/carbon/human/user)
	..()
	if (user.head == src)
		var/datum/atom_hud/DHUD = GLOB.huds[DATA_HUD_DIAGNOSTIC_BASIC]
		DHUD.hide_from(user)

/obj/item/clothing/head/helmet/space/hardsuit/rd/proc/sense_explosion(datum/source, turf/epicenter, devastation_range, heavy_impact_range,
		light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
	SIGNAL_HANDLER

	var/turf/T = get_turf(src)
	if(T?.z != epicenter.z)
		return
	if(get_dist(epicenter, T) > explosion_detection_dist)
		return
	display_visor_message("Explosion detected! Epicenter: [devastation_range], Outer: [heavy_impact_range], Shock: [light_impact_range]")

/obj/item/clothing/suit/space/hardsuit/rd
	name = "prototype hardsuit"
	desc = "A prototype suit that protects against hazardous, low pressure environments. Fitted with extensive plating for handling explosives and dangerous research materials."
	icon_state = "hardsuit-rd"
	resistance_flags = ACID_PROOF | FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT //Same as an emergency firesuit. Not ideal for extended exposure.
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/gun/energy/wormhole_projector,
	/obj/item/hand_tele, /obj/item/aicard)
	armor_type = /datum/armor/hardsuit_rd
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/rd
	cell = /obj/item/stock_parts/cell/super
	slowdown = 0.75

/////////////////////////////////// SECURITY /////////////////////////////////////////////

/obj/item/clothing/head/helmet/space/hardsuit/security
	name = "security hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "hardsuit0-sec"
	hardsuit_type = "sec"
	armor_type = /datum/armor/hardsuit_security


/obj/item/clothing/suit/space/hardsuit/security
	icon_state = "hardsuit-sec"
	name = "security hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has an additional layer of armor."
	armor_type = /datum/armor/hardsuit_security
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security
	slowdown = 0.5

/////////////////////////////////// HOS /////////////////////////////////////////////

/obj/item/clothing/head/helmet/space/hardsuit/security/hos
	name = "head of security's hardsuit helmet"
	desc = "A special bulky helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "hardsuit0-hos"
	hardsuit_type = "hos"
	armor_type = /datum/armor/hardsuit_security_hos


/obj/item/clothing/suit/space/hardsuit/security/hos
	icon_state = "hardsuit-hos"
	name = "head of security's hardsuit"
	desc = "A special bulky suit that protects against hazardous, low pressure environments. Has an additional layer of armor."
	armor_type = /datum/armor/hardsuit_security_hos
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security/hos
	jetpack = /obj/item/tank/jetpack/suit
	cell = /obj/item/stock_parts/cell/super
	slowdown = 0.4

/////////////////////////////////// SWAT /////////////////////////////////////////////

/obj/item/clothing/head/helmet/space/hardsuit/swat
	name = "\improper MK.II SWAT Helmet"
	icon_state = "swat2helm"
	inhand_icon_state = "swat2helm"
	desc = "A tactical SWAT helmet MK.II."
	armor_type = /datum/armor/hardsuit_swat
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT //we want to see the mask //this makes the hardsuit not fireproof you genius
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	actions_types = list()

/obj/item/clothing/suit/space/hardsuit/swat
	name = "\improper MK.II SWAT Suit"
	desc = "A MK.II SWAT suit with streamlined joints and armor made out of superior materials, insulated against intense heat if worn with the complementary gas mask. The most advanced tactical armor available."
	icon_state = "swat2"
	inhand_icon_state = "swat2"
	armor_type = /datum/armor/hardsuit_swat
	resistance_flags = FIRE_PROOF | ACID_PROOF
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT //this needed to be added a long fucking time ago
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/swat
	slowdown = 0.5

// SWAT and Captain get EMP Protection
/obj/item/clothing/suit/space/hardsuit/swat/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_hardsuit_allowed

/////////////////////////////////// CAPTAIN /////////////////////////////////////////////

/obj/item/clothing/head/helmet/space/hardsuit/swat/captain
	name = "captain's SWAT helmet"
	icon_state = "capspace"
	inhand_icon_state = "capspacehelmet"
	desc = "A tactical MK.II SWAT helmet boasting better protection and a reasonable fashion sense."

/obj/item/clothing/suit/space/hardsuit/swat/captain
	name = "captain's SWAT suit"
	desc = "A MK.II SWAT suit with streamlined joints and armor made out of superior materials, insulated against intense heat with the complementary gas mask. The most advanced tactical armor available. Usually reserved for heavy hitter corporate security, this one has a regal finish in Nanotrasen company colors. Better not let the assistants get a hold of it."
	icon_state = "caparmor"
	inhand_icon_state = "capspacesuit"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/swat/captain
	cell = /obj/item/stock_parts/cell/super
	slowdown = 0.4

/////////////////////////////////// CLOWN /////////////////////////////////////////////

/obj/item/clothing/head/helmet/space/hardsuit/clown
	name = "cosmohonk hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-humor environment. Has radiation shielding."
	icon_state = "hardsuit0-clown"
	inhand_icon_state = "hardsuit0-clown"
	armor_type = /datum/armor/hardsuit_clown
	hardsuit_type = "clown"

/obj/item/clothing/suit/space/hardsuit/clown
	name = "cosmohonk hardsuit"
	desc = "A special suit that protects against hazardous, low humor environments. Has radiation shielding. Only a true clown can wear it."
	icon_state = "hardsuit-clown"
	inhand_icon_state = "clown_hardsuit"
	armor_type = /datum/armor/hardsuit_clown
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/clown
	slowdown = 0.5

/////////////////////////////////// MINING /////////////////////////////////////////////

/obj/item/clothing/head/helmet/space/hardsuit/mining
	name = "mining hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has reinforced plating for wildlife encounters and dual floodlights."
	icon_state = "hardsuit0-mining"
	inhand_icon_state = "mining_helm"
	hardsuit_type = "mining"
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	heat_protection = HEAD
	armor_type = /datum/armor/hardsuit_mining
	light_range = 7

/obj/item/clothing/head/helmet/space/hardsuit/mining/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate)
	RegisterSignal(src, COMSIG_ARMOR_PLATED, .proc/upgrade_icon)

/obj/item/clothing/head/helmet/space/hardsuit/mining/proc/upgrade_icon(datum/source, amount, maxamount)
	SIGNAL_HANDLER

	if(amount)
		name = "reinforced [initial(name)]"
		hardsuit_type = "mining_goliath"
		if(amount == maxamount)
			hardsuit_type = "mining_goliath_full"
	icon_state = "hardsuit[on]-[hardsuit_type]"
	set_light_color(LIGHT_COLOR_FLARE)
	if(ishuman(loc))
		var/mob/living/carbon/human/wearer = loc
		if(wearer.head == src)
			wearer.update_worn_head()

/obj/item/clothing/suit/space/hardsuit/mining
	name = "mining hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has reinforced plating for wildlife encounters."
	icon_state = "hardsuit-mining"
	inhand_icon_state = "mining_hardsuit"
	hardsuit_type = "mining"
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	armor_type = /datum/armor/hardsuit_mining
	allowed = list(
		/obj/item/flashlight,
		/obj/item/gun/energy/recharge/kinetic_accelerator,
		/obj/item/mining_scanner,
		/obj/item/pickaxe,
		/obj/item/resonator,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/tank/internals,
		)

	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/mining
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	slowdown = 0.4

/obj/item/clothing/suit/space/hardsuit/mining/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate)
	RegisterSignal(src, COMSIG_ARMOR_PLATED, .proc/upgrade_icon)

/obj/item/clothing/suit/space/hardsuit/mining/proc/upgrade_icon(datum/source, amount, maxamount)
	SIGNAL_HANDLER

	if(amount)
		name = "reinforced [initial(name)]"
		hardsuit_type = "mining_goliath"
		if(amount == maxamount)
			hardsuit_type = "mining_goliath_full"
	icon_state = "hardsuit-[hardsuit_type]"
	if(ishuman(loc))
		var/mob/living/carbon/human/wearer = loc
		if(wearer.wear_suit == src)
			wearer.update_worn_oversuit()

/////////////////////////////////// COMBAT MEDIC /////////////////////////////////////////////

/obj/item/clothing/head/helmet/space/hardsuit/combatmedic
	name = "endemic combat medic helmet"
	desc = "The integrated helmet of the combat medic hardsuit, this has a bright, glowing facemask."
	icon_state = "hardsuit0-combatmedic"
	inhand_icon_state = "hardsuit0-combatmedic"
	armor_type = /datum/armor/hardsuit_combatmedic
	hardsuit_type = "combatmedic"

/obj/item/clothing/suit/space/hardsuit/combatmedic
	name = "endemic combat medic hardsuit"
	desc = "The standard issue hardsuit of infectious disease officers, before the formation of ERT teams. This model is labeled 'Veradux'."
	icon_state = "combatmedic"
	inhand_icon_state = "combatmedic"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/combatmedic
	armor_type = /datum/armor/hardsuit_combatmedic
	allowed = list(/obj/item/gun, /obj/item/melee/baton, /obj/item/circular_saw, /obj/item/tank/internals, /obj/item/storage/box/pillbottles,\
	/obj/item/storage/medkit, /obj/item/stack/medical/gauze, /obj/item/stack/medical/suture, /obj/item/stack/medical/mesh, /obj/item/storage/bag/chemistry)
	slowdown = 0.5

/////////////////////////////////// SYNDI /////////////////////////////////////////////

/obj/item/clothing/head/helmet/space/hardsuit/syndi
	name = "blood-red hardsuit helmet"
	desc = "A dual-mode advanced helmet designed for work in special operations. It is in EVA mode. Property of Gorlex Marauders."
	var/alt_desc = "A dual-mode advanced helmet designed for work in special operations. It is in combat mode. Property of Gorlex Marauders."
	icon_state = "hardsuit1-syndi"
	inhand_icon_state = "syndie_helm"
	hardsuit_type = "syndi"
	armor_type = /datum/armor/hardsuit_syndi
	on = TRUE
	var/obj/item/clothing/suit/space/hardsuit/syndi/linkedsuit = null
	actions_types = list(/datum/action/item_action/toggle_helmet_mode)
	visor_flags_inv = HIDEMASK|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	visor_flags = STOPSPRESSUREDAMAGE

/obj/item/clothing/head/helmet/space/hardsuit/syndi/Initialize(mapload)
	. = ..()
	if(istype(loc, /obj/item/clothing/suit/space/hardsuit/syndi))
		linkedsuit = loc

/obj/item/clothing/head/helmet/space/hardsuit/syndi/attack_self(mob/user) //Toggle Helmet
	if(!isturf(user.loc))
		to_chat(user, span_warning("You cannot toggle your helmet while in this [user.loc]!") )
		return
	on = !on
	if(on || force)
		to_chat(user, span_notice("You switch your hardsuit to EVA mode, sacrificing speed for space protection."))
		name = initial(name)
		desc = initial(desc)
		set_light_on(TRUE)
		clothing_flags |= visor_flags
		flags_cover |= HEADCOVERSEYES | HEADCOVERSMOUTH
		flags_inv |= visor_flags_inv
		cold_protection |= HEAD
	else
		to_chat(user, span_notice("You switch your hardsuit to combat mode and can now run at full speed."))
		name += " (combat)"
		desc = alt_desc
		set_light_on(FALSE)
		clothing_flags &= ~visor_flags
		flags_cover &= ~(HEADCOVERSEYES | HEADCOVERSMOUTH)
		flags_inv &= ~visor_flags_inv
		cold_protection &= ~HEAD
	update_appearance()
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, TRUE)
	toggle_hardsuit_mode(user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.head_update(src, forced = 1)
	icon_state = "hardsuit[on]-[hardsuit_type]"
	worn_icon_state = "hardsuit[on]-[hardsuit_type]"
	user.update_worn_head()
	update_item_action_buttons()

/obj/item/clothing/head/helmet/space/hardsuit/syndi/proc/toggle_hardsuit_mode(mob/user) //Helmet Toggles Suit Mode
	if(linkedsuit)
		if(on)
			linkedsuit.name = initial(linkedsuit.name)
			linkedsuit.desc = initial(linkedsuit.desc)
			linkedsuit.slowdown = initial(linkedsuit.slowdown)
			linkedsuit.clothing_flags |= STOPSPRESSUREDAMAGE
			linkedsuit.cold_protection |= CHEST | GROIN | LEGS | FEET | ARMS | HANDS
		else
			linkedsuit.name += " (combat)"
			linkedsuit.desc = linkedsuit.alt_desc
			linkedsuit.slowdown = 0
			linkedsuit.clothing_flags &= ~STOPSPRESSUREDAMAGE
			linkedsuit.cold_protection &= ~(CHEST | GROIN | LEGS | FEET | ARMS | HANDS)

		linkedsuit.icon_state = "hardsuit[on]-[hardsuit_type]"
		linkedsuit.update_appearance()
		user.update_worn_oversuit()
		user.update_worn_undersuit()
		user.update_equipment_speed_mods()


/obj/item/clothing/suit/space/hardsuit/syndi
	name = "blood-red hardsuit"
	desc = "A dual-mode advanced hardsuit designed for work in special operations. It is in EVA mode. Property of Gorlex Marauders."
	var/alt_desc = "A dual-mode advanced hardsuit designed for work in special operations. It is in combat mode. Property of Gorlex Marauders."
	icon_state = "hardsuit1-syndi"
	inhand_icon_state = "syndie_hardsuit"
	hardsuit_type = "syndi"
	w_class = WEIGHT_CLASS_NORMAL
	armor_type = /datum/armor/hardsuit_syndi
	allowed = list(/obj/item/gun, /obj/item/ammo_box,/obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword/saber, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi
	jetpack = /obj/item/tank/jetpack/suit
	cell = /obj/item/stock_parts/cell/hyper

/////////////////////////////////// SYNDI ELITE /////////////////////////////////////////////

/obj/item/clothing/head/helmet/space/hardsuit/syndi/elite
	name = "elite syndicate hardsuit helmet"
	desc = "An elite version of the syndicate helmet, with improved armour and fireproofing. It is in EVA mode. Property of Gorlex Marauders."
	alt_desc = "An elite version of the syndicate helmet, with improved armour and fireproofing. It is in combat mode. Property of Gorlex Marauders."
	icon_state = "hardsuit1-syndielite"
	hardsuit_type = "syndielite"
	armor_type = /datum/armor/hardsuit_syndi_elite
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/head/helmet/space/hardsuit/syndi/elite/debug

/obj/item/clothing/head/helmet/space/hardsuit/syndi/elite/admin
	name = "jannie hardsuit helmet"
	armor_type = /datum/armor/hardsuit_syndi_admin

/obj/item/clothing/suit/space/hardsuit/syndi/elite
	name = "elite syndicate hardsuit"
	desc = "An elite version of the syndicate hardsuit, with improved armour and fireproofing. It is in travel mode."
	alt_desc = "An elite version of the syndicate hardsuit, with improved armour and fireproofing. It is in combat mode."
	icon_state = "hardsuit1-syndielite"
	hardsuit_type = "syndielite"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite
	armor_type = /datum/armor/hardsuit_syndi_elite
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	cell = /obj/item/stock_parts/cell/bluespace

/obj/item/clothing/suit/space/hardsuit/syndi/elite/debug
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite/debug

/obj/item/clothing/suit/space/hardsuit/syndi/elite/admin //the hardsuit to end all other hardsuits
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite/admin
	name = "jannie hardsuit"
	slowdown = 0
	armor_type = /datum/armor/hardsuit_syndi_admin
	cell = /obj/item/stock_parts/cell/infinite
	clothing_flags = list(TRAIT_SHOVE_KNOCKDOWN_BLOCKED)
	strip_delay = 1000
	equip_delay_other = 1000

/obj/item/clothing/head/helmet/space/hardsuit/syndi/owl
	name = "owl hardsuit helmet"
	desc = "A dual-mode advanced helmet designed for any crime-fighting situation. It is in travel mode."
	alt_desc = "A dual-mode advanced helmet designed for any crime-fighting situation. It is in combat mode."
	icon_state = "hardsuit1-owl"
	inhand_icon_state = "s_helmet"
	hardsuit_type = "owl"
	visor_flags_inv = 0
	visor_flags = 0
	on = FALSE

/obj/item/clothing/suit/space/hardsuit/syndi/owl
	name = "owl hardsuit"
	desc = "A dual-mode advanced hardsuit designed for any crime-fighting situation. It is in travel mode."
	alt_desc = "A dual-mode advanced hardsuit designed for any crime-fighting situation. It is in combat mode."
	icon_state = "hardsuit1-owl"
	inhand_icon_state = "s_suit"
	hardsuit_type = "owl"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/owl

/////////////////////////////////// WIZARD /////////////////////////////////////////////

/obj/item/clothing/head/helmet/space/hardsuit/wizard
	name = "gem-encrusted hardsuit helmet"
	desc = "A bizarre gem-encrusted helmet that radiates magical energies."
	icon_state = "hardsuit0-wiz"
	inhand_icon_state = "wiz_helm"
	hardsuit_type = "wiz"
	resistance_flags = FIRE_PROOF | ACID_PROOF //No longer shall our kind be foiled by lone chemists with spray bottles!
	armor_type = /datum/armor/hardsuit_wizard
	heat_protection = HEAD //Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/wizard
	name = "gem-encrusted hardsuit"
	desc = "A bizarre gem-encrusted suit that radiates magical energies."
	icon_state = "hardsuit-wiz"
	inhand_icon_state = "wiz_hardsuit"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor_type = /datum/armor/hardsuit_wizard
	allowed = list(/obj/item/teleportation_scroll, /obj/item/tank/internals)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS //Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/wizard
	cell = /obj/item/stock_parts/cell/hyper
	slowdown = 0 //you're spending 2 wizard points on this thing, the least it could do is not make you a sitting duck

/obj/item/clothing/suit/space/hardsuit/wizard/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, TRUE, FALSE, FALSE, ITEM_SLOT_OCLOTHING, INFINITY, FALSE)

/////////////////////////////////// ANCIENT /////////////////////////////////////////////

/obj/item/clothing/head/helmet/space/hardsuit/ancient
	name = "prototype RIG hardsuit helmet"
	desc = "Early prototype RIG hardsuit helmet, designed to quickly shift over a user's head. Design constraints of the helmet mean it has no inbuilt cameras, thus it restricts the users visability."
	icon_state = "hardsuit0-ancient"
	inhand_icon_state = "anc_helm"
	armor_type = /datum/armor/hardsuit_ancient
	hardsuit_type = "ancient"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/space/hardsuit/ancient
	name = "prototype RIG hardsuit"
	desc = "Prototype powered RIG hardsuit. Provides excellent protection from the elements of space while being comfortable to move around in, thanks to the powered locomotives. Remains very bulky however."
	icon_state = "hardsuit-ancient"
	inhand_icon_state = "anc_hardsuit"
	armor_type = /datum/armor/hardsuit_ancient
	slowdown = 2
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ancient
	resistance_flags = FIRE_PROOF
	var/footstep = 1
	var/mob/listeningTo

/obj/item/clothing/suit/space/hardsuit/ancient/proc/on_mob_move()
	SIGNAL_HANDLER
	var/mob/living/carbon/human/H = loc
	if(!istype(H) || H.wear_suit != src)
		return
	if(footstep > 1)
		playsound(src, 'sound/effects/servostep.ogg', 100, TRUE)
		footstep = 0
	else
		footstep++

/obj/item/clothing/suit/space/hardsuit/ancient/equipped(mob/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_OCLOTHING)
		if(listeningTo)
			UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
		return
	if(listeningTo == user)
		return
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/on_mob_move)
	listeningTo = user

/obj/item/clothing/suit/space/hardsuit/ancient/dropped()
	. = ..()
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)

/obj/item/clothing/suit/space/hardsuit/ancient/Destroy()
	listeningTo = null
	return ..()

/////////////////////////////////// DEATHSQUAD /////////////////////////////////////////////

/obj/item/clothing/head/helmet/space/hardsuit/deathsquad
	name = "MK.III SWAT Helmet"
	desc = "An advanced tactical space helmet."
	icon_state = "deathsquad"
	inhand_icon_state = "deathsquad"
	armor_type = list(MELEE = 80, BULLET = 80, LASER = 50, ENERGY = 60, BOMB = 100, BIO = 100, FIRE = 100, ACID = 100, WOUND = 20)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	actions_types = list()

/obj/item/clothing/suit/space/hardsuit/deathsquad
	name = "MK.III SWAT Suit"
	desc = "A prototype designed to replace the ageing MK.II SWAT suit. Based on the streamlined MK.II model, the traditional ceramic and graphene plate construction was replaced with plasteel, allowing superior armor against most threats. There's room for some kind of energy projection device on the back."
	icon_state = "deathsquad"
	inhand_icon_state = "swat_suit"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/knife/combat)
	armor_type = /datum/armor/hardsuit_deathsquad
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/deathsquad
	dog_fashion = /datum/dog_fashion/back/deathsquad
	cell = /obj/item/stock_parts/cell/bluespace
	slowdown = 0.5

	//Emergency Response Team suits
/obj/item/clothing/head/helmet/space/hardsuit/ert
	name = "emergency response team commander helmet"
	desc = "The integrated helmet of an ERT hardsuit, this one has blue highlights."
	icon_state = "hardsuit0-ert_commander"
	inhand_icon_state = "hardsuit0-ert_commander"
	hardsuit_type = "ert_commander"
	armor_type = /datum/armor/hardsuit_ert
	strip_delay = 130
	light_range = 7
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/head/helmet/space/hardsuit/ert/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, LOCKED_HELMET_TRAIT)

/obj/item/clothing/suit/space/hardsuit/ert
	name = "emergency response team commander hardsuit"
	desc = "The standard issue hardsuit of the ERT, this one has blue highlights. Offers superb protection against environmental hazards."
	icon_state = "ert_command"
	inhand_icon_state = "ert_command"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor_type = /datum/armor/hardsuit_ert
	slowdown = 0
	strip_delay = 130
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	cell = /obj/item/stock_parts/cell/bluespace

// ERT suit's gets EMP Protection
/obj/item/clothing/suit/space/hardsuit/ert/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_CONTENTS)

	//ERT Security
/obj/item/clothing/head/helmet/space/hardsuit/ert/sec
	name = "emergency response team security helmet"
	desc = "The integrated helmet of an ERT hardsuit, this one has red highlights."
	icon_state = "hardsuit0-ert_security"
	inhand_icon_state = "hardsuit0-ert_security"
	hardsuit_type = "ert_security"

/obj/item/clothing/suit/space/hardsuit/ert/sec
	name = "emergency response team security hardsuit"
	desc = "The standard issue hardsuit of the ERT, this one has red highlights. Offers superb protection against environmental hazards."
	icon_state = "ert_security"
	inhand_icon_state = "ert_security"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/sec
	slowdown = 0.5

	//ERT Engineering
/obj/item/clothing/head/helmet/space/hardsuit/ert/engi
	name = "emergency response team engineering helmet"
	desc = "The integrated helmet of an ERT hardsuit, this one has orange highlights."
	icon_state = "hardsuit0-ert_engineer"
	inhand_icon_state = "hardsuit0-ert_engineer"
	hardsuit_type = "ert_engineer"

/obj/item/clothing/suit/space/hardsuit/ert/engi
	name = "emergency response team engineering hardsuit"
	desc = "The standard issue hardsuit of the ERT, this one has orange highlights. Offers superb protection against environmental hazards."
	icon_state = "ert_engineer"
	inhand_icon_state = "ert_engineer"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/engi
	slowdown = 0.5

	//ERT Medical
/obj/item/clothing/head/helmet/space/hardsuit/ert/med
	name = "emergency response team medical helmet"
	desc = "The integrated helmet of an ERT hardsuit, this one has white highlights."
	icon_state = "hardsuit0-ert_medical"
	inhand_icon_state = "hardsuit0-ert_medical"
	hardsuit_type = "ert_medical"

/obj/item/clothing/suit/space/hardsuit/ert/med
	name = "emergency response team medical hardsuit"
	desc = "The standard issue hardsuit of the ERT, this one has white highlights. Offers superb protection against environmental hazards."
	icon_state = "ert_medical"
	inhand_icon_state = "ert_medical"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/med
	slowdown = 0.25

	//ERT Janitor
/obj/item/clothing/head/helmet/space/hardsuit/ert/jani
	name = "emergency response team janitorial helmet"
	desc = "The integrated helmet of an ERT hardsuit, this one has purple highlights."
	icon_state = "hardsuit0-ert_janitor"
	inhand_icon_state = "hardsuit0-ert_janitor"
	hardsuit_type = "ert_janitor"

/obj/item/clothing/suit/space/hardsuit/ert/jani
	name = "emergency response team janitorial hardsuit"
	desc = "The standard issue hardsuit of the ERT, this one has purple highlights. Offers superb protection against environmental hazards. This one has extra clips for holding various janitorial tools."
	icon_state = "ert_janitor"
	inhand_icon_state = "ert_janitor"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/jani
	allowed = list(/obj/item/tank/internals, /obj/item/storage/bag/trash, /obj/item/melee/flyswatter, /obj/item/mop, /obj/item/holosign_creator, /obj/item/reagent_containers/cup/bucket, /obj/item/reagent_containers/spray/chemsprayer/janitor)
	slowdown = 0.5

	//ERT Clown
/obj/item/clothing/head/helmet/space/hardsuit/ert/clown
	name = "emergency response team clown helmet"
	desc = "The integrated helmet of an ERT hardsuit, this one is colourful!"
	icon_state = "hardsuit0-ert_clown"
	inhand_icon_state = "hardsuit0-ert_clown"
	hardsuit_type = "ert_clown"

/obj/item/clothing/suit/space/hardsuit/ert/clown
	name = "emergency response team clown hardsuit"
	desc = "The non-standard issue hardsuit of the ERT, this one is colourful! Offers superb protection against environmental hazards. Does not offer superb protection against a ravaging crew."
	icon_state = "ert_clown"
	inhand_icon_state = "ert_clown"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/clown
	allowed = list(/obj/item/tank/internals, /obj/item/bikehorn, /obj/item/instrument, /obj/item/food/grown/banana, /obj/item/grown/bananapeel)
	slowdown = 0.5

	//Paranormal ERT
/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal
	name = "paranormal response team helmet"
	desc = "A helmet worn by those who deal with paranormal threats for a living."
	icon_state = "hardsuit0-prt"
	inhand_icon_state = "hardsuit0-prt"
	hardsuit_type = "prt"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	actions_types = list()
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/space/hardsuit/ert/paranormal
	name = "paranormal response team hardsuit"
	desc = "Powerful wards are built into this hardsuit, protecting the user from all manner of paranormal threats."
	icon_state = "knight_grey"
	inhand_icon_state = "knight_grey"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	slowdown = 0.5

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, TRUE, TRUE, TRUE, ITEM_SLOT_OCLOTHING)

	//Inquisitor
/obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor
	name = "inquisitor's hardsuit"
	icon_state = "hardsuit-inq"
	inhand_icon_state = "hardsuit-inq"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/inquisitor
	slowdown = 0.4

/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/inquisitor
	name = "inquisitor's helmet"
	icon_state = "hardsuit0-inq"
	inhand_icon_state = "hardsuit0-inq"
	hardsuit_type = "inq"

//Carpsuit, bestsuit, lovesuit
/obj/item/clothing/head/helmet/space/hardsuit/carp
	name = "carp helmet"
	desc = "Spaceworthy and it looks like a space carp's head, smells like one too."
	icon_state = "carp_helm"
	inhand_icon_state = "syndicate"
	armor_type = /datum/armor/hardsuit_carp //As whimpy as a space carp
	light_system = NO_LIGHT_SUPPORT
	light_range = 0 //luminosity when on
	actions_types = list()
	flags_inv = HIDEEARS|HIDEHAIR|HIDEFACIALHAIR //facial hair will clip with the helm, this'll need a dynamic_fhair_suffix at some point.

/obj/item/clothing/head/helmet/space/hardsuit/carp/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, LOCKED_HELMET_TRAIT)

/obj/item/clothing/suit/space/hardsuit/carp
	name = "carp space suit"
	desc = "A slimming piece of dubious space carp technology, you suspect it won't stand up to hand-to-hand blows."
	icon_state = "carp_suit"
	inhand_icon_state = "space_suit_syndicate"
	slowdown = 0 //Space carp magic, never stop believing
	armor_type = /datum/armor/hardsuit_carp //As whimpy whimpy whoo
	allowed = list(/obj/item/tank/internals, /obj/item/gun/ballistic/rifle/boltaction/harpoon) //I'm giving you a hint here
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/carp

/obj/item/clothing/head/helmet/space/hardsuit/carp/equipped(mob/living/carbon/human/user, slot)
	..()
	if (slot == ITEM_SLOT_HEAD)
		user.faction |= "carp"

/obj/item/clothing/head/helmet/space/hardsuit/carp/dropped(mob/living/carbon/human/user)
	..()
	if (user.head == src)
		user.faction -= "carp"

/obj/item/clothing/suit/space/hardsuit/carp/old
	name = "battered carp space suit"
	desc = "It's covered in bite marks and scratches, yet seems to be still perfectly functional."
	slowdown = 1

/////////////SHIELDED//////////////////////////////////

/obj/item/clothing/suit/space/hardsuit/shielded
	name = "shielded hardsuit"
	desc = "A hardsuit with built in energy shielding. Will rapidly recharge when not under fire."
	icon_state = "hardsuit-hos"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security/hos
	allowed = null
	armor_type = /datum/armor/hardsuit_shielded
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/suit/space/hardsuit/shielded/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shielded, max_charges = 3, recharge_start_delay = 20 SECONDS, charge_increment_delay = 1 SECONDS, charge_recovery = 1, lose_multiple_charges = FALSE, shield_icon = "shield-old")

/obj/item/clothing/head/helmet/space/hardsuit/shielded
	resistance_flags = FIRE_PROOF | ACID_PROOF

//////Syndicate Version
/obj/item/clothing/suit/space/hardsuit/shielded/syndi
	name = "blood-red hardsuit"
	desc = "An advanced hardsuit with built in energy shielding."
	icon_state = "hardsuit1-syndi"
	inhand_icon_state = "syndie_hardsuit"
	hardsuit_type = "syndi"
	armor_type = /datum/armor/hardsuit_shielded_syndi
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword/saber, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/syndi
	slowdown = 0
	jetpack = /obj/item/tank/jetpack/suit

/obj/item/clothing/suit/space/hardsuit/shielded/syndi/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shielded, max_charges = 3, recharge_start_delay = 20 SECONDS, charge_increment_delay = 1 SECONDS, charge_recovery = 1, lose_multiple_charges = FALSE, shield_icon = "shield-red")

/obj/item/clothing/head/helmet/space/hardsuit/shielded/syndi
	name = "blood-red hardsuit helmet"
	desc = "An advanced hardsuit helmet with built in energy shielding."
	icon_state = "hardsuit1-syndi"
	inhand_icon_state = "syndie_helm"
	hardsuit_type = "syndi"
	armor_type = /datum/armor/hardsuit_shielded_syndi

///SWAT version
/obj/item/clothing/suit/space/hardsuit/shielded/swat
	name = "death commando spacesuit"
	desc = "An advanced hardsuit favored by commandos for use in special operations."
	icon_state = "deathsquad"
	inhand_icon_state = "swat_suit"
	hardsuit_type = "syndi"
	armor_type = /datum/armor/hardsuit_shielded_swat
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/swat
	dog_fashion = /datum/dog_fashion/back/deathsquad

/obj/item/clothing/suit/space/hardsuit/shielded/swat/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shielded, max_charges = 4, recharge_start_delay = 1.5 SECONDS, charge_increment_delay = 1 SECONDS, charge_recovery = 1, lose_multiple_charges = FALSE, shield_icon = "shield-old")

/obj/item/clothing/head/helmet/space/hardsuit/shielded/swat
	name = "death commando helmet"
	desc = "A tactical helmet with built in energy shielding."
	icon_state = "deathsquad"
	inhand_icon_state = "deathsquad"
	hardsuit_type = "syndi"
	armor_type = /datum/armor/hardsuit_shielded_swat
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	actions_types = list()
	slowdown = 0.5

#undef HARDSUIT_EMP_BURN
