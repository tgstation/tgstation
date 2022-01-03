/**
 * # Ninja Suit
 *
 * Space ninja's suit.  Provides him with most of his powers.
 *
 * Space ninja's suit.  Gives space ninja all his iconic powers, which are mostly kept in
 * the folder ninja_equipment_actions.  Has a lot of unique stuff going on, so make sure to check
 * the variables.  Check suit_attackby to see radium interaction, disk copying, and cell replacement.
 *
 */
/obj/item/clothing/suit/space/space_ninja
	name = "ninja suit"
	desc = "A unique, vacuum-proof suit of nano-enhanced armor designed specifically for Spider Clan assassins."
	icon_state = "s-ninja"
	inhand_icon_state = "s-ninja_suit"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/stock_parts/cell)
	resistance_flags = LAVA_PROOF | ACID_PROOF
	armor = list(MELEE = 40, BULLET = 30, LASER = 20,ENERGY = 30, BOMB = 30, BIO = 30, FIRE = 100, ACID = 100)
	strip_delay = 12
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	actions_types = list(/datum/action/item_action/initialize_ninja_suit, /datum/action/item_action/ninjastatus, /datum/action/item_action/ninjaboost, /datum/action/item_action/ninjapulse, /datum/action/item_action/ninjastar, /datum/action/item_action/ninjanet, /datum/action/item_action/ninja_sword_recall, /datum/action/item_action/ninja_stealth)

	///The person wearing the suit
	var/mob/living/carbon/human/affecting = null
	///The suit's spark system, used for... sparking.
	var/datum/effect_system/spark_spread/spark_system
	///The suit's stored research.  Used for the research objective (see antagonist file)
	var/datum/techweb/stored_research
	///The katana registered with the suit, used for recalling and catching the katana.  Set when the ninja outfit is created.
	var/obj/item/energy_katana/energyKatana

	///The space ninja's hood.
	var/obj/item/clothing/head/helmet/space/space_ninja/n_hood
	///The space ninja's shoes.
	var/obj/item/clothing/shoes/space_ninja/n_shoes
	///The space ninja's gloves.
	var/obj/item/clothing/gloves/space_ninja/n_gloves
	///The space ninja's mask.
	var/obj/item/clothing/mask/gas/space_ninja/n_mask

	///Whether or not the suit is currently booted up.  Starts off.
	var/s_initialized = FALSE//Suit starts off.
	///The suit's current cooldown.  If not 0, blocks usage of most abilities, and decrements its value by 1 every process
	var/s_coold = 0
	///How much energy the suit expends in a single process
	var/s_cost = 1
	///Additional energy cost for cloaking per process
	var/s_acost = 4
	///How fast the suit is at certain actions, like draining power from things
	var/s_delay = 40
	///Units of radium required to refill the adrenaline boost
	var/a_transfer = 20//How much radium is required to refill the adrenaline boost.
	///Whether or not the suit is currently in stealth mode.
	var/stealth = FALSE//Stealth off.
	///Whether or not the wearer is in the middle of an action, like hacking.
	var/s_busy = FALSE
	///Whether or not the adrenaline boost ability is available
	var/a_boost = TRUE

/obj/item/clothing/suit/space/space_ninja/examine(mob/user)
	. = ..()
	if(!s_initialized)
		return
	if(!user == affecting)
		return
	. += "All systems operational. Current energy capacity: <B>[display_energy(cell.charge)]</B>.\n"+\
	"The CLOAK-tech device is <B>[stealth?"active":"inactive"]</B>.\n"+\
	"[a_boost?"An adrenaline boost is available to use.":"There is no adrenaline boost available.  Try refilling the suit with 20 units of radium."]"

/obj/item/clothing/suit/space/space_ninja/Initialize(mapload)
	. = ..()

	//Spark Init
	spark_system = new
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	//Research Init
	stored_research = new()

	//Cell Init
	cell = new/obj/item/stock_parts/cell/high
	cell.charge = 9000
	cell.name = "black power cell"
	cell.icon_state = "bscell"

/obj/item/clothing/suit/space/space_ninja/Destroy()
	QDEL_NULL(spark_system)
	QDEL_NULL(cell)
	return ..()

// seal the cell in the ninja outfit
/obj/item/clothing/suit/space/space_ninja/toggle_spacesuit_cell(mob/user)
	return

// Space Suit temperature regulation and power usage
/obj/item/clothing/suit/space/space_ninja/process(delta_time)
	var/mob/living/carbon/human/user = src.loc
	if(!user || !ishuman(user) || !(user.wear_suit == src))
		return

	// Check for energy usage
	if(s_initialized)
		if(!affecting)
			terminate() // Kills the suit and attached objects.
		else if(cell.charge > 0)
			if(s_coold > 0)
				s_coold = max(s_coold - delta_time, 0) // Checks for ability s_cooldown first.
			cell.charge -= s_cost * delta_time // s_cost is the default energy cost each ntick, usually 5.
			if(stealth) // If stealth is active.
				cell.charge -= s_acost * delta_time
		else
			cell.charge = 0
			cancel_stealth()

	user.adjust_bodytemperature(BODYTEMP_NORMAL - user.bodytemperature)

/obj/item/clothing/suit/space/space_ninja/ui_action_click(mob/user, action)
	if(IS_NINJA_SUIT_INITIALIZATION(action))
		toggle_on_off()
		return TRUE
	if(!s_initialized)
		to_chat(user, span_warning("<b>ERROR</b>: suit offline. Please activate suit."))
		return FALSE
	if(s_coold > 0)
		to_chat(user, span_warning("<b>ERROR</b>: suit is on cooldown."))
		return FALSE
	if(IS_NINJA_SUIT_STATUS(action))
		ninjastatus()
		return TRUE
	if(IS_NINJA_SUIT_BOOST(action))
		ninjaboost()
		return TRUE
	if(IS_NINJA_SUIT_EMP(action))
		ninjapulse()
		return TRUE
	if(IS_NINJA_SUIT_STAR_CREATION(action))
		ninjastar()
		return TRUE
	if(IS_NINJA_SUIT_NET_CREATION(action))
		ninjanet()
		return TRUE
	if(IS_NINJA_SUIT_SWORD_RECALL(action))
		ninja_sword_recall()
		return TRUE
	if(IS_NINJA_SUIT_STEALTH(action))
		toggle_stealth()
		return TRUE
	return FALSE

/obj/item/clothing/suit/space/space_ninja/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	. = ..()
	if(stealth)
		cancel_stealth()
		s_coold = 5

/**
 * Proc for changing the suit's appearance upon locking.
 *
 * Proc for when space ninja's suit locks.  If the user selects Original, gives it glowing lights, along with having an alternate sprite for female body types.
 * Yes, we do have nipLEDs, how could you tell?
 * If the user selects New Age, it applies new sprites to all the gear.
 * Arguments:
 * * ninja - The person wearing the suit.
 */
/obj/item/clothing/suit/space/space_ninja/proc/lockIcons(mob/living/carbon/human/ninja)
	var/design_choice = tgui_alert(ninja, "Please choose your desired suit design.",,list("Original","New Age"))
	switch(design_choice)
		if("Original")
			icon_state = ninja.body_type == "female" ? "s-ninjanf" : "s-ninjan"
			ninja.gloves.icon_state = "s-ninjan"
			ninja.gloves.inhand_icon_state = "s-ninjan"
		if("New Age")
			icon_state ="ninja_new"
			n_hood.icon_state = "ninja_newcowl"
			n_gloves.icon_state = "ninja_new"
			if(n_mask)
				n_mask.icon_state = "ninja_new"


/**
 * Proc called to lock the important gear pieces onto space ninja's body.
 *
 * Called during the suit startup to lock all gear pieces onto space ninja.
 * Terminates if a gear piece is not being worn.  Also gives the ninja the inability to use firearms.
 * If the person in the suit isn't a ninja when this is called, this proc just gibs them instead.
 * Arguments:
 * * ninja - The person wearing the suit.
 * * Returns false if the locking fails due to lack of all suit parts, and true if it succeeds.
 */
/obj/item/clothing/suit/space/space_ninja/proc/lock_suit(mob/living/carbon/human/ninja)
	if(!istype(ninja))
		return FALSE
	if(!IS_SPACE_NINJA(ninja))
		to_chat(ninja, span_danger("<B>fÄTaL ÈÈRRoR</B>: 382200-*#00CÖDE <B>RED</B>\nUNAUHORIZED USÈ DETÈCeD\nCoMMÈNCING SUB-R0UIN3 13...\nTÈRMInATING U-U-USÈR..."))
		ninja.gib()
		return FALSE
	if(!istype(ninja.head, /obj/item/clothing/head/helmet/space/space_ninja))
		to_chat(ninja, "[span_userdanger("ERROR")]: 100113 UNABLE TO LOCATE HEAD GEAR\nABORTING...")
		return FALSE
	if(!istype(ninja.shoes, /obj/item/clothing/shoes/space_ninja))
		to_chat(ninja, "[span_userdanger("ERROR")]: 122011 UNABLE TO LOCATE FOOT GEAR\nABORTING...")
		return FALSE
	if(!istype(ninja.gloves, /obj/item/clothing/gloves/space_ninja))
		to_chat(ninja, "[span_userdanger("ERROR")]: 110223 UNABLE TO LOCATE HAND GEAR\nABORTING...")
		return FALSE
	affecting = ninja
	ADD_TRAIT(src, TRAIT_NODROP, NINJA_SUIT_TRAIT)
	n_hood = ninja.head
	ADD_TRAIT(n_hood, TRAIT_NODROP, NINJA_SUIT_TRAIT)
	n_shoes = ninja.shoes
	ADD_TRAIT(n_shoes, TRAIT_NODROP, NINJA_SUIT_TRAIT)
	n_gloves = ninja.gloves
	ADD_TRAIT(n_gloves, TRAIT_NODROP, NINJA_SUIT_TRAIT)
	n_mask = ninja.wear_mask

	ADD_TRAIT(ninja, TRAIT_NOGUNS, NINJA_SUIT_TRAIT)
	return TRUE

/**
 * Proc called to unlock all the gear off space ninja's body.
 *
 * Proc which is essentially the opposite of lock_suit.  Lets you take off all the suit parts.
 * Also gets rid of the objection to using firearms from the wearer.
 * Arguments:
 * * ninja - The person wearing the suit.
 */
/obj/item/clothing/suit/space/space_ninja/proc/unlock_suit(mob/living/carbon/human/ninja)
	affecting = null
	REMOVE_TRAIT(src, TRAIT_NODROP, NINJA_SUIT_TRAIT)
	icon_state = "s-ninja"
	if(n_hood)//Should be attached, might not be attached.
		REMOVE_TRAIT(n_hood, TRAIT_NODROP, NINJA_SUIT_TRAIT)
		n_hood.icon_state = "s-ninja"
	if(n_shoes)
		REMOVE_TRAIT(n_shoes, TRAIT_NODROP, NINJA_SUIT_TRAIT)
	if(n_gloves)
		n_gloves.icon_state = "black"
		REMOVE_TRAIT(n_gloves, TRAIT_NODROP, NINJA_SUIT_TRAIT)
		n_gloves.draining = FALSE

		REMOVE_TRAIT(ninja, TRAIT_NOGUNS, NINJA_SUIT_TRAIT)
	if(n_mask)
		n_mask.icon_state = "s-ninja"

/**
 * Proc used to delete all the attachments and itself.
 *
 * Can be called to entire rid of the suit pieces and the suit itself.
 */
/obj/item/clothing/suit/space/space_ninja/proc/terminate()
	QDEL_NULL(n_hood)
	QDEL_NULL(n_gloves)
	QDEL_NULL(n_shoes)
	QDEL_NULL(src)
