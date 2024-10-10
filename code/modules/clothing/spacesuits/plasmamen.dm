//Suits for the pink and grey skeletons! //EVA version no longer used in favor of the Jumpsuit version

/obj/item/clothing/suit/space/eva/plasmaman
	name = "EVA plasma envirosuit"
	desc = "A special plasma containment suit designed to be space-worthy, as well as worn over other clothing. Like its smaller counterpart, it can automatically extinguish the wearer in a crisis, and holds twice as many charges."
	allowed = list(/obj/item/gun, /obj/item/ammo_casing, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword, /obj/item/restraints/handcuffs, /obj/item/tank)
	armor_type = /datum/armor/eva_plasmaman
	resistance_flags = FIRE_PROOF
	icon_state = "plasmaman_suit"
	inhand_icon_state = "plasmaman_suit"
	fishing_modifier = 0
	var/next_extinguish = 0
	var/extinguish_cooldown = 100
	var/extinguishes_left = 10


/datum/armor/eva_plasmaman
	bio = 100
	fire = 100
	acid = 75

/obj/item/clothing/suit/space/eva/plasmaman/examine(mob/user)
	. = ..()
	. += span_notice("There [extinguishes_left == 1 ? "is" : "are"] [extinguishes_left] extinguisher charge\s left in this suit.")


/obj/item/clothing/suit/space/eva/plasmaman/proc/Extinguish(mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(H.fire_stacks > 0)
		if(extinguishes_left)
			if(next_extinguish > world.time)
				return
			next_extinguish = world.time + extinguish_cooldown
			extinguishes_left--
			H.visible_message(span_warning("[H]'s suit automatically extinguishes [H.p_them()]!"),span_warning("Your suit automatically extinguishes you."))
			H.extinguish_mob()
			new /obj/effect/particle_effect/water(get_turf(H))


//I just want the light feature of helmets
/obj/item/clothing/head/helmet/space/plasmaman
	name = "plasma envirosuit helmet"
	desc = "A special containment helmet that allows plasma-based lifeforms to exist safely in an oxygenated environment. It is space-worthy, and may be worn in tandem with other EVA gear."
	icon = 'icons/obj/clothing/head/plasmaman_hats.dmi'
	worn_icon = 'icons/mob/clothing/head/plasmaman_head.dmi'
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT | STACKABLE_HELMET_EXEMPT | PLASMAMAN_PREVENT_IGNITION | HEADINTERNALS
	icon_state = "plasmaman-helm"
	inhand_icon_state = "plasmaman-helm"
	strip_delay = 80
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 2
	armor_type = /datum/armor/space_plasmaman
	resistance_flags = FIRE_PROOF
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_range = 4
	light_power = 0.8
	light_color = "#ffcc99"
	light_on = FALSE
	fishing_modifier = 0
	var/helmet_on = FALSE
	var/smile = FALSE
	var/smile_color = COLOR_RED
	var/visor_icon = "envisor"
	var/smile_state = "envirohelm_smile"
	var/obj/item/clothing/head/attached_hat
	actions_types = list(/datum/action/item_action/toggle_helmet_light, /datum/action/item_action/toggle_welding_screen)
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	flags_cover = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF
	visor_flags_inv = HIDEEYES|HIDEFACE
	slowdown = 0

/datum/armor/space_plasmaman
	bio = 100
	fire = 100
	acid = 75

/obj/item/clothing/head/helmet/space/plasmaman/Initialize(mapload)
	. = ..()
	visor_toggling()
	update_appearance()

/obj/item/clothing/head/helmet/space/plasmaman/examine()
	. = ..()
	if(attached_hat)
		. += span_notice("There's [attached_hat.name] placed on the helmet. Right-click to remove it.")
	else
		. += span_notice("There's nothing placed on the helmet.")

/obj/item/clothing/head/helmet/space/plasmaman/click_alt(mob/user)
	if(user.can_perform_action(src))
		adjust_visor(user)

/obj/item/clothing/head/helmet/space/plasmaman/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/toggle_welding_screen))
		adjust_visor(user)
		return

	return ..()

/obj/item/clothing/head/helmet/space/plasmaman/adjust_visor(mob/living/user)
	. = ..()
	if(!.)
		return
	if(helmet_on)
		to_chat(user, span_notice("Your helmet's torch can't pass through your welding visor!"))
		set_light_on(FALSE)
		helmet_on = FALSE
	playsound(src, 'sound/vehicles/mecha/mechmove03.ogg', 50, TRUE) //Visors don't just come from nothing
	update_appearance()

/obj/item/clothing/head/helmet/space/plasmaman/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][helmet_on ? "-light":""]"
	inhand_icon_state = icon_state

/obj/item/clothing/head/helmet/space/plasmaman/update_overlays()
	. = ..()
	if(!up)
		. += visor_icon
	if(smile)
		var/mutable_appearance/smiley = mutable_appearance(icon, smile_state)
		smiley.color = smile_color
		. += smiley

/obj/item/clothing/head/helmet/space/plasmaman/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/toy/crayon))
		if(smile)
			to_chat(user, span_warning("Seems like someone already drew something on [src]'s visor!"))
			return ITEM_INTERACT_BLOCKING

		var/obj/item/toy/crayon/crayon = tool
		to_chat(user, span_notice("You start drawing a smiley face on [src]'s visor..."))
		if(!do_after(user, 2.5 SECONDS, target = src))
			return ITEM_INTERACT_BLOCKING

		smile = TRUE
		smile_color = crayon.paint_color
		to_chat(user, "You draw a smiley on [src] visor.")
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	if(!istype(tool, /obj/item/clothing/head))
		return NONE

	var/obj/item/clothing/hitting_clothing = tool
	if(hitting_clothing.clothing_flags & STACKABLE_HELMET_EXEMPT)
		to_chat(user, span_notice("You cannot place [hitting_clothing.name] on [src]!"))
		return ITEM_INTERACT_BLOCKING

	if(attached_hat)
		to_chat(user, span_notice("There's already something placed on [src]!"))
		return ITEM_INTERACT_BLOCKING

	attached_hat = hitting_clothing
	to_chat(user, span_notice("You placed [hitting_clothing.name] on [src]!"))
	hitting_clothing.forceMove(src)
	update_appearance()
	return ITEM_INTERACT_SUCCESS

///By the by, helmets have the update_icon_updates_onmob element, so we don't have to call mob.update_worn_head()
/obj/item/clothing/head/helmet/space/plasmaman/worn_overlays(mutable_appearance/standing, isinhands)
	. = ..()
	if(!isinhands && smile)
		var/mutable_appearance/M = mutable_appearance('icons/mob/clothing/head/plasmaman_head.dmi', smile_state)
		M.color = smile_color
		. += M
	if(!isinhands && attached_hat)
		. += attached_hat.build_worn_icon(default_layer = HEAD_LAYER, default_icon_file = 'icons/mob/clothing/head/default.dmi')
	if(!isinhands && !up)
		. += mutable_appearance('icons/mob/clothing/head/plasmaman_head.dmi', visor_icon)
	else
		cut_overlays()

/obj/item/clothing/head/helmet/space/plasmaman/wash(clean_types)
	. = ..()
	if(smile && (clean_types & CLEAN_TYPE_HARD_DECAL))
		smile = FALSE
		update_appearance()
		return TRUE

/obj/item/clothing/head/helmet/space/plasmaman/attack_self(mob/user)
	helmet_on = !helmet_on
	update_appearance()

	if(helmet_on)
		if(!up)
			to_chat(user, span_notice("Your helmet's torch can't pass through your welding visor!"))
			set_light_on(FALSE)
		else
			set_light_on(TRUE)
	else
		set_light_on(FALSE)

	update_item_action_buttons()

/obj/item/clothing/head/helmet/space/plasmaman/on_saboteur(datum/source, disrupt_duration)
	. = ..()
	if(!helmet_on)
		return FALSE
	helmet_on = FALSE
	update_appearance()
	return TRUE

/obj/item/clothing/head/helmet/space/plasmaman/attack_hand_secondary(mob/user)
	..()
	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!attached_hat)
		return
	user.put_in_active_hand(attached_hat)
	to_chat(user, span_notice("You removed [attached_hat.name] from helmet!"))
	attached_hat = null
	update_appearance()

/obj/item/clothing/head/helmet/space/plasmaman/security
	name = "security plasma envirosuit helmet"
	desc = "A plasmaman containment helmet designed for security officers, protecting them from burning alive, alongside other undesirables."
	icon_state = "security_envirohelm"
	inhand_icon_state = null
	armor_type = /datum/armor/head_helmet/plasmaman

/datum/armor/head_helmet/plasmaman
	bio = 100
	fire = 100
	acid = 75

/obj/item/clothing/head/helmet/space/plasmaman/security/detective
	name = "detective's plasma envirosuit helmet"
	desc = "A special containment helmet designed for detectives, protecting them from burning alive, alongside other undesirables."
	icon_state = "white_envirohelm"
	inhand_icon_state = null
	armor_type = /datum/armor/fedora_det_hat/plasmaman

/datum/armor/fedora_det_hat/plasmaman
	bio = 100
	fire = 100
	acid = 75

/obj/item/clothing/head/helmet/space/plasmaman/security/warden
	name = "warden's plasma envirosuit helmet"
	desc = "A plasmaman containment helmet designed for the warden. A pair of white stripes being added to differeciate them from other members of security."
	icon_state = "warden_envirohelm"
	inhand_icon_state = null
	armor_type = /datum/armor/hats_warden/plasmaman

/datum/armor/hats_warden/plasmaman
	bio = 100
	fire = 100
	acid = 75

/obj/item/clothing/head/helmet/space/plasmaman/security/head_of_security
	name = "head of security's plasma envirosuit helmet"
	desc = "A special containment helmet designed for the Head of Security. A pair of gold stripes are added to differentiate them from other members of security."
	icon_state = "hos_envirohelm"
	inhand_icon_state = null
	armor_type = /datum/armor/hats_hos/plasmaman

/datum/armor/hats_hos/plasmaman
	bio = 100
	fire = 100
	acid = 75

/obj/item/clothing/head/helmet/space/plasmaman/prisoner
	name = "prisoner's plasma envirosuit helmet"
	desc = "A plasmaman containment helmet for prisoners."
	icon_state = "prisoner_envirohelm"
	inhand_icon_state = null

/obj/item/clothing/head/helmet/space/plasmaman/medical
	name = "medical doctor's plasma envirosuit helmet"
	desc = "An envirohelmet designed for plasmaman medical doctors, having two stripes down its length to denote as much."
	icon_state = "doctor_envirohelm"
	inhand_icon_state = null

/obj/item/clothing/head/helmet/space/plasmaman/coroner
	name = "coroners's plasma envirosuit helmet"
	desc = "An envirohelmet designed for plasmaman coroners, having more edge than the usual model."
	icon_state = "coroner_envirohelm"
	inhand_icon_state = null

/obj/item/clothing/head/helmet/space/plasmaman/paramedic
	name = "paramedic plasma envirosuit helmet"
	desc = "An envirohelmet designed for plasmaman paramedics, with darker blue stripes compared to the medical model."
	icon_state = "paramedic_envirohelm"
	inhand_icon_state = null

/obj/item/clothing/head/helmet/space/plasmaman/viro
	name = "virology plasma envirosuit helmet"
	desc = "The helmet worn by the safest people on the station, those who are completely immune to the monstrosities they create."
	icon_state = "virologist_envirohelm"
	inhand_icon_state = null

/obj/item/clothing/head/helmet/space/plasmaman/chemist
	name = "chemistry plasma envirosuit helmet"
	desc = "A plasmaman envirosuit designed for chemists, two orange stripes going down its face."
	icon_state = "chemist_envirohelm"
	inhand_icon_state = null

/obj/item/clothing/head/helmet/space/plasmaman/chief_medical_officer
	name = "chief medical officer's plasma envirosuit helmet"
	desc = "A special containment helmet designed for the Chief Medical Officer. A gold stripe applied to differentiate them from other medical staff."
	icon_state = "cmo_envirohelm"
	inhand_icon_state = null

/obj/item/clothing/head/helmet/space/plasmaman/science
	name = "science plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for scientists."
	icon_state = "scientist_envirohelm"
	inhand_icon_state = null

/obj/item/clothing/head/helmet/space/plasmaman/robotics
	name = "robotics plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for roboticists."
	icon_state = "roboticist_envirohelm"
	inhand_icon_state = null

/obj/item/clothing/head/helmet/space/plasmaman/genetics
	name = "geneticist's plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for geneticists."
	icon_state = "geneticist_envirohelm"
	inhand_icon_state = null

/obj/item/clothing/head/helmet/space/plasmaman/research_director
	name = "research director's plasma envirosuit helmet"
	desc = "A special containment helmet designed for the Research Director. A light brown design is applied to differentiate them from other scientists."
	icon_state = "rd_envirohelm"
	inhand_icon_state = null

/obj/item/clothing/head/helmet/space/plasmaman/engineering
	name = "engineering plasma envirosuit helmet"
	desc = "A space-worthy helmet specially designed for engineer plasmamen, the usual purple stripes being replaced by engineering's orange."
	icon_state = "engineer_envirohelm"
	inhand_icon_state = null
	armor_type = /datum/armor/space_plasmaman/engineering_atmos

/datum/armor/space_plasmaman/engineering_atmos
	acid = 95

/obj/item/clothing/head/helmet/space/plasmaman/atmospherics
	name = "atmospherics plasma envirosuit helmet"
	desc = "A space-worthy helmet specially designed for atmos technician plasmamen, the usual purple stripes being replaced by atmos' blue. Has improved thermal shielding."
	icon_state = "atmos_envirohelm"
	inhand_icon_state = null
	armor_type = /datum/armor/space_plasmaman/engineering_atmos
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT // Same protection as the Atmospherics Hardhat

/obj/item/clothing/head/helmet/space/plasmaman/chief_engineer
	name = "chief engineer's plasma envirosuit helmet"
	desc = "A special containment helmet designed for the Chief Engineer, the usual purple stripes being replaced by the chief's green. Has improved thermal shielding."
	icon_state = "ce_envirohelm"
	inhand_icon_state = null
	armor_type = /datum/armor/space_plasmaman/engineering_atmos
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT // Same protection as the Atmospherics Hardhat

/obj/item/clothing/head/helmet/space/plasmaman/cargo
	name = "cargo plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for cargo techs and quartermasters."
	icon_state = "cargo_envirohelm"
	inhand_icon_state = null

/obj/item/clothing/head/helmet/space/plasmaman/mining
	name = "mining plasma envirosuit helmet"
	desc = "A khaki helmet given to plasmamen miners operating on lavaland."
	icon_state = "explorer_envirohelm"
	inhand_icon_state = null
	visor_icon = "explorer_envisor"

/obj/item/clothing/head/helmet/space/plasmaman/chaplain
	name = "chaplain's plasma envirosuit helmet"
	desc = "An envirohelmet specially designed for only the most pious of plasmamen."
	icon_state = "chap_envirohelm"
	inhand_icon_state = null

/obj/item/clothing/head/helmet/space/plasmaman/white
	name = "white plasma envirosuit helmet"
	desc = "A generic white envirohelm."
	icon_state = "white_envirohelm"
	inhand_icon_state = null

/obj/item/clothing/head/helmet/space/plasmaman/curator
	name = "curator's plasma envirosuit helmet"
	desc = "A slight modification on a traditional voidsuit helmet, this helmet was Nanotrasen's first solution to the *logistical problems* that come with employing plasmamen. Despite their limitations, these helmets still see use by historians and old-school plasmamen alike."
	icon_state = "prototype_envirohelm"
	inhand_icon_state = "void_helmet"
	actions_types = list(/datum/action/item_action/toggle_welding_screen)
	smile_state = "prototype_smile"
	visor_icon = "prototype_envisor"

/obj/item/clothing/head/helmet/space/plasmaman/botany
	name = "botany plasma envirosuit helmet"
	desc = "A green and blue envirohelmet designating its wearer as a botanist. While not specifically designed for it, it would protect against minor plant-related injuries."
	icon_state = "botany_envirohelm"
	inhand_icon_state = null

/obj/item/clothing/head/helmet/space/plasmaman/janitor
	name = "janitor's plasma envirosuit helmet"
	desc = "A grey helmet bearing a pair of purple stripes, designating the wearer as a janitor."
	icon_state = "janitor_envirohelm"
	inhand_icon_state = null

/obj/item/clothing/head/helmet/space/plasmaman/mime
	name = "mime envirosuit helmet"
	desc = "The make-up is painted on, it's a miracle it doesn't chip. It's not very colourful."
	icon_state = "mime_envirohelm"
	inhand_icon_state = null
	visor_icon = "mime_envisor"

/obj/item/clothing/head/helmet/space/plasmaman/clown
	name = "clown envirosuit helmet"
	desc = "The make-up is painted on, it's a miracle it doesn't chip. <i>'HONK!'</i>"
	icon_state = "clown_envirohelm"
	inhand_icon_state = null
	visor_icon = "clown_envisor"
	smile_state = "clown_smile"

/obj/item/clothing/head/helmet/space/plasmaman/clown/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CLOWN, CELL_VIRUS_TABLE_GENERIC, rand(2,3), 0)

/obj/item/clothing/head/helmet/space/plasmaman/head_of_personnel
	name = "head of personnel's envirosuit helmet"
	desc = "A special containment helmet designed for the Head of Personnel. Embarrassingly enough, it looks way too much like the captain's design save for the red stripes."
	icon_state = "hop_envirohelm"
	inhand_icon_state = null
	armor_type = /datum/armor/hats_hopcap/plasmaman

/datum/armor/hats_hopcap/plasmaman
	bio = 100
	fire = 100
	acid = 75

/obj/item/clothing/head/helmet/space/plasmaman/captain
	name = "captain's plasma envirosuit helmet"
	desc = "A special containment helmet designed for the Captain. Embarrassingly enough, it looks way too much like the Head of Personnel's design save for the gold stripes. I mean, come on. Gold stripes can fix anything."
	icon_state = "captain_envirohelm"
	inhand_icon_state = null
	armor_type = /datum/armor/hats_caphat/plasmaman

/datum/armor/hats_caphat/plasmaman
	bio = 100
	fire = 100
	acid = 75

/obj/item/clothing/head/helmet/space/plasmaman/centcom_commander
	name = "CentCom commander plasma envirosuit helmet"
	desc = "A special containment helmet designed for the Higher Central Command Staff. Not many of these exist, as CentCom does not usually employ plasmamen to higher staff positions due to their complications."
	icon_state = "commander_envirohelm"
	inhand_icon_state = null
	armor_type = /datum/armor/hats_centhat/plasmaman

/datum/armor/hats_centhat/plasmaman
	bio = 100
	fire = 100
	acid = 75

/obj/item/clothing/head/helmet/space/plasmaman/centcom_official
	name = "CentCom official plasma envirosuit helmet"
	desc = "A special containment helmet designed for CentCom Staff. They sure do love their green."
	icon_state = "official_envirohelm"
	inhand_icon_state = null

/obj/item/clothing/head/helmet/space/plasmaman/centcom_intern
	name = "CentCom intern plasma envirosuit helmet"
	desc = "A special containment helmet designed for CentCom Staff. You know, so any coffee spills don't kill the poor sod."
	icon_state = "intern_envirohelm"
	inhand_icon_state = null

/obj/item/clothing/head/helmet/space/plasmaman/syndie
	name = "tacticool envirosuit helmet"
	desc = "There's no doubt about it, this helmet puts you above ALL of the other plasmamen. If you see another plasmaman wearing a helmet like this, it's either because they're a fellow badass, \
		or they've murdered one of your fellow badasses and have taken it from them as a trophy. Either way, anyone wearing this deserves at least a cursory nod of respect."
	icon_state = "syndie_envirohelm"
	inhand_icon_state = null

/obj/item/clothing/head/helmet/space/plasmaman/bitrunner
	name = "bitrunner's plasma envirosuit helmet"
	desc = "An envirohelmet with extended blue light filters for bitrunning plasmamen."
	icon_state = "bitrunner_envirohelm"
