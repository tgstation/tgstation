//Basically the assistant suit
/obj/item/clothing/under/plasmaman
	name = "plasma envirosuit"
	desc = "A special containment suit that allows plasma-based lifeforms to exist safely in an oxygenated environment, and automatically extinguishes them in a crisis. Despite being airtight, it's not spaceworthy."
	icon_state = "plasmaman"
	inhand_icon_state = "plasmaman"
	icon = 'icons/obj/clothing/under/plasmaman.dmi'
	worn_icon = 'icons/mob/clothing/under/plasmaman.dmi'
	clothing_flags = PLASMAMAN_PREVENT_IGNITION
	armor_type = /datum/armor/clothing_under/plasmaman
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	can_adjust = FALSE
	strip_delay = 80
	COOLDOWN_DECLARE(extinguish_timer)
	var/extinguish_cooldown = 100
	var/extinguishes_left = 5

/datum/armor/clothing_under/plasmaman
	bio = 100
	fire = 95
	acid = 95

/obj/item/clothing/under/plasmaman/examine(mob/user)
	. = ..()
	. += span_notice("There [extinguishes_left == 1 ? "is" : "are"] [extinguishes_left] extinguisher charges left in this suit.")

/obj/item/clothing/under/plasmaman/equipped(mob/living/user, slot)
	. = ..()
	if (slot & ITEM_SLOT_ICLOTHING)
		RegisterSignals(user, list(COMSIG_MOB_EQUIPPED_ITEM, COMSIG_LIVING_IGNITED, SIGNAL_ADDTRAIT(TRAIT_HEAD_ATMOS_SEALED)), PROC_REF(check_fire_state))
		check_fire_state()

/obj/item/clothing/under/plasmaman/dropped(mob/living/user)
	. = ..()
	UnregisterSignal(user, list(COMSIG_MOB_EQUIPPED_ITEM, COMSIG_LIVING_IGNITED, SIGNAL_ADDTRAIT(TRAIT_HEAD_ATMOS_SEALED)))

/obj/item/clothing/under/plasmaman/proc/check_fire_state(datum/source)
	SIGNAL_HANDLER

	if (!ishuman(loc))
		return

	// This is weird but basically we're calling this proc once the cooldown ends in case our wearer gets set on fire again during said cooldown
	// This is why we're ignoring source and instead checking by loc
	var/mob/living/carbon/human/owner = loc
	if (!owner.on_fire || !owner.is_atmos_sealed(additional_flags = PLASMAMAN_PREVENT_IGNITION, check_hands = TRUE, alt_flags = TRUE))
		return

	if (!extinguishes_left || !COOLDOWN_FINISHED(src, extinguish_timer))
		return

	extinguishes_left -= 1
	COOLDOWN_START(src, extinguish_timer, extinguish_cooldown)
	// Check if our (possibly other) wearer is on fire once the cooldown ends
	addtimer(CALLBACK(src, PROC_REF(check_fire_state)), extinguish_cooldown)
	owner.visible_message(span_warning("[owner]'s suit automatically extinguishes [owner.p_them()]!"), span_warning("Your suit automatically extinguishes you."))
	owner.extinguish_mob()
	new /obj/effect/particle_effect/water(get_turf(owner))

/obj/item/clothing/under/plasmaman/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if (!istype(tool, /obj/item/extinguisher_refill))
		return ..()

	if (extinguishes_left == 5)
		to_chat(user, span_notice("The inbuilt extinguisher is full."))
		return ITEM_INTERACT_BLOCKING

	extinguishes_left = 5
	to_chat(user, span_notice("You refill the suit's built-in extinguisher, using up the cartridge."))
	check_fire_state()
	qdel(tool)
	return ITEM_INTERACT_SUCCESS

/obj/item/extinguisher_refill
	name = "envirosuit extinguisher cartridge"
	desc = "A cartridge loaded with a compressed extinguisher mix, used to refill the automatic extinguisher on plasma envirosuits."
	icon_state = "plasmarefill"
	icon = 'icons/obj/canisters.dmi'

/obj/item/clothing/under/plasmaman/cargo
	name = "cargo plasma envirosuit"
	desc = "A joint envirosuit used by plasmamen quartermasters and cargo techs alike, due to the logistical problems of differenciating the two with the length of their pant legs."
	icon_state = "cargo_envirosuit"
	inhand_icon_state = null

/obj/item/clothing/under/plasmaman/mining
	name = "mining plasma envirosuit"
	desc = "An air-tight khaki suit designed for operations on lavaland by plasmamen."
	icon_state = "explorer_envirosuit"
	inhand_icon_state = null

/obj/item/clothing/under/plasmaman/chef
	name = "chef's plasma envirosuit"
	desc = "A white plasmaman envirosuit designed for cullinary practices. One might question why a member of a species that doesn't need to eat would become a chef."
	icon_state = "chef_envirosuit"
	inhand_icon_state = null

/obj/item/clothing/under/plasmaman/enviroslacks
	name = "enviroslacks"
	desc = "The pet project of a particularly posh plasmaman, this custom suit was quickly appropriated by Nanotrasen for its lawyers, and bartenders alike."
	icon_state = "enviroslacks"
	inhand_icon_state = null

/obj/item/clothing/under/plasmaman/chaplain
	name = "chaplain's plasma envirosuit"
	desc = "An envirosuit specially designed for only the most pious of plasmamen."
	icon_state = "chap_envirosuit"
	inhand_icon_state = null

/obj/item/clothing/under/plasmaman/curator
	name = "curator's plasma envirosuit"
	desc = "Made out of a modified voidsuit, this suit was Nanotrasen's first solution to the *logistical problems* that come with employing plasmamen. Due to the modifications, the suit is no longer space-worthy. Despite their limitations, these suits are still in used by historian and old-styled plasmamen alike."
	icon_state = "prototype_envirosuit"
	inhand_icon_state = null

/obj/item/clothing/under/plasmaman/janitor
	name = "janitor's plasma envirosuit"
	desc = "A grey and purple envirosuit designated for plasmamen janitors."
	icon_state = "janitor_envirosuit"
	inhand_icon_state = null

/obj/item/clothing/under/plasmaman/botany
	name = "botany envirosuit"
	desc = "A green and blue envirosuit designed to protect plasmamen from minor plant-related injuries."
	icon_state = "botany_envirosuit"
	inhand_icon_state = null

/obj/item/clothing/under/plasmaman/mime
	name = "mime envirosuit"
	desc = "It's not very colourful."
	icon_state = "mime_envirosuit"
	inhand_icon_state = null

/obj/item/clothing/under/plasmaman/clown
	name = "clown envirosuit"
	desc = "<i>'HONK!'</i>"
	icon_state = "clown_envirosuit"
	inhand_icon_state = null

/obj/item/clothing/under/plasmaman/bitrunner
	name = "bitrunner envirosuit"
	desc = "An envirosuit specially designed for plasmamen with bad posture."
	icon_state = "bitrunner_envirosuit"
	inhand_icon_state = null

/obj/item/clothing/under/plasmaman/clown/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CLOWN, CELL_VIRUS_TABLE_GENERIC, rand(2,3), 0)

/obj/item/clothing/under/plasmaman/prisoner
	name = "prisoner envirosuit"
	desc = "An orange envirosuit identifying and protecting a criminal plasmaman. Its suit sensors are stuck in the \"Fully On\" position."
	icon_state = "prisoner_envirosuit"
	inhand_icon_state = null
	has_sensor = LOCKED_SENSORS
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/plasmaman/clown/check_fire_state(datum/source, datum/status_effect/fire_handler/status_effect)
	if (!ishuman(loc))
		return

	// This is weird but basically we're calling this proc once the cooldown ends in case our wearer gets set on fire again during said cooldown
	// This is why we're ignoring source and instead checking by loc
	var/mob/living/carbon/human/owner = loc
	if (!owner.on_fire || !owner.is_atmos_sealed(additional_flags = PLASMAMAN_PREVENT_IGNITION, check_hands = TRUE, alt_flags = TRUE))
		return

	if (!extinguishes_left || !COOLDOWN_FINISHED(src, extinguish_timer))
		return

	extinguishes_left -= 1
	COOLDOWN_START(src, extinguish_timer, extinguish_cooldown)
	// Check if our (possibly other) wearer is on fire once the cooldown ends
	addtimer(CALLBACK(src, PROC_REF(check_fire_state)), extinguish_cooldown)
	owner.visible_message(span_warning("[owner]'s suit spews space lube everywhere!"), span_warning("Your suit spews space lube everywhere!"))
	owner.extinguish_mob()
	var/datum/effect_system/fluid_spread/foam/foam = new
	var/datum/reagents/foamreagent = new /datum/reagents(15)
	foamreagent.add_reagent(/datum/reagent/lube, 15)
	foam.set_up(4, holder = src, location = get_turf(owner), carry = foamreagent)
	foam.start() //Truly terrifying.
