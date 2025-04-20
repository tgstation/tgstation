/* First aid storage
 * Contains:
 * First Aid Kits
 * Pill Bottles
 * Dice Pack (in a pill bottle)
 */

/*
 * First Aid Kits
 */
/obj/item/storage/medkit
	name = "medkit"
	desc = "It's an emergency medical kit for those serious boo-boos."
	icon = 'icons/obj/storage/medkit.dmi'
	icon_state = "medkit"
	inhand_icon_state = "medkit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throw_speed = 3
	throw_range = 7
	drop_sound = 'sound/items/handling/medkit/medkit_drop.ogg'
	pickup_sound = 'sound/items/handling/medkit/medkit_pick_up.ogg'
	sound_vary = TRUE
	storage_type = /datum/storage/medkit

	var/empty = FALSE
	/// Defines damage type of the medkit. General ones stay null. Used for medibot healing bonuses
	var/damagetype_healed

/obj/item/storage/medkit/regular
	icon_state = "medkit"
	desc = "A first aid kit with the ability to heal common types of injuries."

/obj/item/storage/medkit/regular/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins giving [user.p_them()]self aids with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/storage/medkit/regular/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/stack/medical/gauze = 1,
		/obj/item/stack/medical/suture = 2,
		/obj/item/stack/medical/mesh = 2,
		/obj/item/reagent_containers/hypospray/medipen = 1,
		/obj/item/healthanalyzer/simple = 1,
	)
	generate_items_inside(items_inside,src)

/obj/item/storage/medkit/emergency
	icon_state = "medbriefcase"
	inhand_icon_state = "medkit-emergency"
	name = "emergency medkit"
	desc = "A very simple first aid kit meant to secure and stabilize serious wounds for later treatment."

/obj/item/storage/medkit/emergency/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/healthanalyzer/simple = 1,
		/obj/item/stack/medical/gauze = 1,
		/obj/item/stack/medical/suture/emergency = 1,
		/obj/item/stack/medical/ointment = 1,
		/obj/item/reagent_containers/hypospray/medipen/ekit = 2,
		/obj/item/storage/pill_bottle/iron = 1,
	)
	generate_items_inside(items_inside,src)

/obj/item/storage/medkit/surgery
	name = "surgical medkit"
	icon_state = "medkit_surgery"
	inhand_icon_state = "medkit-surgical"
	desc = "A high capacity aid kit for doctors, full of medical supplies and basic surgical equipment."
	storage_type = /datum/storage/medkit/surgery

/obj/item/storage/medkit/surgery/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/healthanalyzer = 1,
		/obj/item/stack/medical/gauze/twelve = 1,
		/obj/item/stack/medical/suture = 2,
		/obj/item/stack/medical/mesh = 2,
		/obj/item/reagent_containers/hypospray/medipen = 1,
		/obj/item/surgical_drapes = 1,
		/obj/item/scalpel = 1,
		/obj/item/hemostat = 1,
		/obj/item/cautery = 1,
	)
	generate_items_inside(items_inside,src)

/obj/item/storage/medkit/ancient
	icon_state = "oldfirstaid"
	desc = "A first aid kit with the ability to heal common types of injuries."

/obj/item/storage/medkit/ancient/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/stack/medical/gauze = 1,
		/obj/item/stack/medical/bruise_pack = 3,
		/obj/item/stack/medical/ointment= 3)
	generate_items_inside(items_inside,src)

/obj/item/storage/medkit/ancient/heirloom
	desc = "A first aid kit with the ability to heal common types of injuries. You start thinking of the good old days just by looking at it."
	empty = TRUE // long since been ransacked by hungry powergaming assistants breaking into med storage

/obj/item/storage/medkit/fire
	name = "burn treatment kit"
	desc = "A specialized medical kit for when the ordnance lab <i>-spontaneously-</i> burns down."
	icon_state = "medkit_burn"
	inhand_icon_state = "medkit-ointment"
	damagetype_healed = BURN

/obj/item/storage/medkit/fire/get_medbot_skin()
	return "burn"

/obj/item/storage/medkit/fire/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins rubbing \the [src] against [user.p_them()]self! It looks like [user.p_theyre()] trying to start a fire!"))
	return FIRELOSS

/obj/item/storage/medkit/fire/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/applicator/patch/aiuri = 3,
		/obj/item/reagent_containers/spray/hercuri = 1,
		/obj/item/reagent_containers/hypospray/medipen/oxandrolone = 1,
		/obj/item/reagent_containers/hypospray/medipen = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/medkit/toxin
	name = "toxin treatment kit"
	desc = "Used to treat toxic blood content and radiation poisoning."
	icon_state = "medkit_toxin"
	inhand_icon_state = "medkit-toxin"
	damagetype_healed = TOX

/obj/item/storage/medkit/toxin/get_medbot_skin()
	return "tox"

/obj/item/storage/medkit/toxin/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins licking the lead paint off \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return TOXLOSS


/obj/item/storage/medkit/toxin/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/storage/pill_bottle/multiver/less = 1,
		/obj/item/reagent_containers/syringe/syriniver = 3,
		/obj/item/storage/pill_bottle/potassiodide = 1,
		/obj/item/reagent_containers/hypospray/medipen/penacid = 1,
		/obj/item/healthanalyzer/simple/disease = 1,
		)
	generate_items_inside(items_inside,src)

/obj/item/storage/medkit/o2
	name = "oxygen deprivation treatment kit"
	desc = "A box full of oxygen goodies."
	icon_state = "medkit_o2"
	inhand_icon_state = "medkit-o2"
	damagetype_healed = OXY

/obj/item/storage/medkit/o2/get_medbot_skin()
	return "oxy"

/obj/item/storage/medkit/o2/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins hitting [user.p_their()] neck with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/storage/medkit/o2/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/syringe/convermol = 3,
		/obj/item/reagent_containers/hypospray/medipen/salbutamol = 1,
		/obj/item/reagent_containers/hypospray/medipen = 1,
		/obj/item/storage/pill_bottle/iron = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/medkit/brute
	name = "brute trauma treatment kit"
	desc = "A first aid kit for when you get toolboxed."
	icon_state = "medkit_brute"
	inhand_icon_state = "medkit-brute"
	damagetype_healed = BRUTE

/obj/item/storage/medkit/brute/get_medbot_skin()
	return "brute"

/obj/item/storage/medkit/brute/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins beating [user.p_them()]self over the head with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/storage/medkit/brute/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/applicator/patch/libital = 3,
		/obj/item/stack/medical/gauze = 1,
		/obj/item/storage/pill_bottle/probital = 1,
		/obj/item/reagent_containers/hypospray/medipen/salacid = 1,
		/obj/item/healthanalyzer/simple = 1,
		)
	generate_items_inside(items_inside,src)

/obj/item/storage/medkit/advanced
	name = "advanced first aid kit"
	desc = "An advanced kit to help deal with advanced wounds."
	icon_state = "medkit_advanced"
	inhand_icon_state = "medkit-advanced"
	custom_premium_price = PAYCHECK_COMMAND * 6
	damagetype_healed = HEAL_ALL_DAMAGE

/obj/item/storage/medkit/advanced/get_medbot_skin()
	return "adv"

/obj/item/storage/medkit/advanced/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/applicator/patch/synthflesh = 3,
		/obj/item/reagent_containers/hypospray/medipen/atropine = 2,
		/obj/item/stack/medical/gauze = 1,
		/obj/item/storage/pill_bottle/penacid = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/medkit/tactical_lite
	name = "combat first aid kit"
	icon_state = "medkit_tactical_lite"
	inhand_icon_state = "medkit-tactical-lite"
	damagetype_healed = HEAL_ALL_DAMAGE

/obj/item/storage/medkit/tactical_lite/get_medbot_skin()
	return "bezerk"

/obj/item/storage/medkit/tactical_lite/PopulateContents()
	if(empty)
		return
	var/static/list/items_inside = list(
		/obj/item/healthanalyzer/advanced = 1,
		/obj/item/reagent_containers/hypospray/medipen/atropine = 1,
		/obj/item/stack/medical/gauze = 1,
		/obj/item/stack/medical/suture/medicated = 2,
		/obj/item/stack/medical/mesh/advanced = 2,
	)
	generate_items_inside(items_inside, src)

/obj/item/storage/medkit/tactical
	name = "combat medical kit"
	desc = "I hope you've got insurance."
	icon_state = "medkit_tactical"
	inhand_icon_state = "medkit-tactical"
	damagetype_healed = HEAL_ALL_DAMAGE
	storage_type = /datum/storage/medkit/tactical

/obj/item/storage/medkit/tactical/PopulateContents()
	if(empty)
		return
	var/static/list/items_inside = list(
		/obj/item/cautery = 1,
		/obj/item/scalpel = 1,
		/obj/item/healthanalyzer/advanced = 1,
		/obj/item/hemostat = 1,
		/obj/item/reagent_containers/medigel/sterilizine = 1,
		/obj/item/storage/box/bandages = 1,
		/obj/item/surgical_drapes = 1,
		/obj/item/reagent_containers/hypospray/medipen/atropine = 2,
		/obj/item/stack/medical/gauze = 2,
		/obj/item/stack/medical/suture/medicated = 2,
		/obj/item/stack/medical/mesh/advanced = 2,
		/obj/item/reagent_containers/applicator/patch/libital = 4,
		/obj/item/reagent_containers/applicator/patch/aiuri = 4,
	)
	generate_items_inside(items_inside,src)

/obj/item/storage/medkit/tactical/premium
	name = "premium combat medical kit"
	desc = "May or may not contain traces of lead."
	icon_state = "medkit_tactical_premium"
	inhand_icon_state = "medkit-tactical-premium"
	grind_results = list(/datum/reagent/lead = 10)
	storage_type = /datum/storage/medkit/tactical/premium

/obj/item/storage/medkit/tactical/premium/PopulateContents()
	if(empty)
		return
	var/static/list/items_inside = list(
		/obj/item/stack/medical/suture/medicated = 2,
		/obj/item/stack/medical/mesh/advanced = 2,
		/obj/item/reagent_containers/applicator/patch/libital = 3,
		/obj/item/reagent_containers/applicator/patch/aiuri = 3,
		/obj/item/healthanalyzer/advanced = 1,
		/obj/item/stack/medical/gauze = 2,
		/obj/item/mod/module/thread_ripper = 1,
		/obj/item/mod/module/surgical_processor/preloaded = 1,
		/obj/item/mod/module/defibrillator/combat = 1,
		/obj/item/mod/module/health_analyzer = 1,
		/obj/item/autosurgeon/syndicate/emaggedsurgerytoolset = 1,
		/obj/item/reagent_containers/hypospray/combat/empty = 1,
		/obj/item/storage/box/bandages = 1,
		/obj/item/storage/box/evilmeds = 1,
		/obj/item/reagent_containers/medigel/sterilizine = 1,
		/obj/item/clothing/glasses/hud/health/night/science = 1,
	)
	generate_items_inside(items_inside,src)

/obj/item/storage/medkit/coroner
	name = "compact coroner's medkit"
	desc = "A smaller medical kit designed primarily for assisting in dissecting the deceased, rather than treating the living."
	icon = 'icons/obj/storage/medkit.dmi'
	icon_state = "compact_coronerkit"
	inhand_icon_state = "coronerkit"
	storage_type = /datum/storage/medkit/coroner

/obj/item/storage/medkit/coroner/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/cup/bottle/formaldehyde = 1,
		/obj/item/reagent_containers/medigel/sterilizine = 1,
		/obj/item/reagent_containers/blood = 1,
		/obj/item/bodybag = 2,
		/obj/item/reagent_containers/syringe = 1,
	)
	generate_items_inside(items_inside,src)

//medibot assembly
/obj/item/storage/medkit/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/bodypart/arm/left/robot) && !istype(tool, /obj/item/bodypart/arm/right/robot))
		return ..()
	//Making a medibot!
	if(contents.len >= 1)
		balloon_alert(user, "items inside!")
		return ITEM_INTERACT_BLOCKING

	var/obj/item/bot_assembly/medbot/medbot_assembly = new()
	medbot_assembly.set_skin(get_medbot_skin())
	user.put_in_hands(medbot_assembly)
	medbot_assembly.balloon_alert(user, "arm added")
	medbot_assembly.robot_arm = tool.type
	medbot_assembly.medkit_type = type
	qdel(tool)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/// Gets what skin (icon_state) this medkit uses for a medbot
/obj/item/storage/medkit/proc/get_medbot_skin()
	return "generic"

/// A box which takes in coolant and uses it to preserve organs and body parts
/obj/item/storage/organbox
	name = "organ transport box"
	desc = "An advanced box with a cooling mechanism that uses cryostylane or other cold reagents to keep the organs or bodyparts inside preserved."
	icon = 'icons/obj/storage/case.dmi'
	icon_state = "organbox"
	base_icon_state = "organbox"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throw_speed = 3
	throw_range = 7
	custom_premium_price = PAYCHECK_CREW * 4
	storage_type = /datum/storage/organ_box
	/// var to prevent it freezing the same things over and over
	var/cooling = FALSE

/obj/item/storage/organbox/Initialize(mapload)
	. = ..()

	create_reagents(100, TRANSPARENT)

	START_PROCESSING(SSobj, src)

/obj/item/storage/organbox/process(seconds_per_tick)
	///if there is enough coolant var
	var/using_coolant = coolant_to_spend()
	if (isnull(using_coolant))
		if (cooling)
			cooling = FALSE
			update_appearance()
			for(var/obj/stored in contents)
				stored.unfreeze()
		return

	var/amount_used = 0.05 * seconds_per_tick
	if (using_coolant != /datum/reagent/cryostylane)
		amount_used *= 2
	reagents.remove_reagent(using_coolant, amount_used)

	if(cooling)
		return
	cooling = TRUE
	update_appearance()
	for(var/obj/stored in contents)
		stored.freeze()

/// Returns which coolant we are about to use, or null if there isn't any
/obj/item/storage/organbox/proc/coolant_to_spend()
	if (reagents.get_reagent_amount(/datum/reagent/cryostylane))
		return /datum/reagent/cryostylane
	if (reagents.get_reagent_amount(/datum/reagent/consumable/ice))
		return /datum/reagent/consumable/ice
	return null

/obj/item/storage/organbox/update_icon_state()
	icon_state = "[base_icon_state][cooling ? "-working" : null]"
	return ..()

/obj/item/storage/organbox/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	if(is_reagent_container(tool) && tool.is_open_container())
		var/obj/item/reagent_containers/RC = tool
		var/units = RC.reagents.trans_to(src, RC.amount_per_transfer_from_this, transferred_by = user)
		if(units)
			balloon_alert(user, "[units]u transferred")
			return ITEM_INTERACT_SUCCESS
		return ITEM_INTERACT_BLOCKING
	if(istype(tool, /obj/item/plunger))
		balloon_alert(user, "plunging...")
		if(do_after(user, 1 SECONDS, target = src))
			balloon_alert(user, "plunged")
			reagents.clear_reagents()
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/item/storage/organbox/suicide_act(mob/living/carbon/user)
	if(HAS_TRAIT(user, TRAIT_RESISTCOLD)) //if they're immune to cold, just do the box suicide
		var/obj/item/bodypart/head/myhead = user.get_bodypart(BODY_ZONE_HEAD)
		if(myhead)
			user.visible_message(span_suicide("[user] puts [user.p_their()] head into \the [src] and begins closing it! It looks like [user.p_theyre()] trying to commit suicide!"))
			myhead.dismember()
			myhead.forceMove(src) //force your enemies to kill themselves with your head collection box!
			playsound(user, "desecration-01.ogg", 50, TRUE, -1)
			return BRUTELOSS
		user.visible_message(span_suicide("[user] is beating [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
		return BRUTELOSS
	user.visible_message(span_suicide("[user] is putting [user.p_their()] head inside the [src], it looks like [user.p_theyre()] trying to commit suicide!"))
	user.adjust_bodytemperature(-300)
	user.apply_status_effect(/datum/status_effect/freon)
	return FIRELOSS

/// A subtype of organ storage box which starts with a full coolant tank
/obj/item/storage/organbox/preloaded

/obj/item/storage/organbox/preloaded/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/cryostylane, reagents.maximum_volume)

/obj/item/storage/test_tube_rack
	name = "test tube rack"
	desc = "A wooden rack for storing test tubes."
	icon_state = "rack"
	base_icon_state = "rack"
	icon = 'icons/obj/medical/chemical.dmi'
	inhand_icon_state = "contsolid"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	storage_type = /datum/storage/test_tube_rack

/obj/item/storage/test_tube_rack/update_icon_state()
	icon_state = "[base_icon_state][contents.len > 0 ? contents.len : null]"
	return ..()

/obj/item/storage/test_tube_rack/full/PopulateContents()
	for(var/i in 1 to atom_storage.max_slots)
		new /obj/item/reagent_containers/cup/tube(src)
	update_appearance(UPDATE_ICON_STATE)

