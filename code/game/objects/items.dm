GLOBAL_DATUM_INIT(fire_overlay, /mutable_appearance, mutable_appearance('icons/effects/fire.dmi', "fire"))

GLOBAL_VAR_INIT(rpg_loot_items, FALSE)
// if true, everyone item when created will have its name changed to be
// more... RPG-like.

/obj/item
	name = "item"
	icon = 'icons/obj/items.dmi'
	var/item_state = null
	var/lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	var/righthand_file = 'icons/mob/inhands/items_righthand.dmi'

	//Dimensions of the icon file used when this item is worn, eg: hats.dmi
	//eg: 32x32 sprite, 64x64 sprite, etc.
	//allows inhands/worn sprites to be of any size, but still centered on a mob properly
	var/worn_x_dimension = 32
	var/worn_y_dimension = 32
	//Same as above but for inhands, uses the lefthand_ and righthand_ file vars
	var/inhand_x_dimension = 32
	var/inhand_y_dimension = 32

	//Not on /clothing because for some reason any /obj/item can technically be "worn" with enough fuckery.
	var/icon/alternate_worn_icon = null//If this is set, update_icons() will find on mob (WORN, NOT INHANDS) states in this file instead, primary use: badminnery/events
	var/alternate_worn_layer = null//If this is set, update_icons() will force the on mob state (WORN, NOT INHANDS) onto this layer, instead of it's default

	max_integrity = 200

	var/hitsound = null
	var/usesound = null
	var/throwhitsound = null
	var/w_class = WEIGHT_CLASS_NORMAL
	var/slot_flags = 0		//This is used to determine on which slots an item can fit.
	pass_flags = PASSTABLE
	pressure_resistance = 4
	var/obj/item/master = null

	var/heat_protection = 0 //flags which determine which body parts are protected from heat. Use the HEAD, CHEST, GROIN, etc. flags. See setup.dm
	var/cold_protection = 0 //flags which determine which body parts are protected from cold. Use the HEAD, CHEST, GROIN, etc. flags. See setup.dm
	var/max_heat_protection_temperature //Set this variable to determine up to which temperature (IN KELVIN) the item protects against heat damage. Keep at null to disable protection. Only protects areas set by heat_protection flags
	var/min_cold_protection_temperature //Set this variable to determine down to which temperature (IN KELVIN) the item protects against cold damage. 0 is NOT an acceptable number due to if(varname) tests!! Keep at null to disable protection. Only protects areas set by cold_protection flags

	var/list/actions //list of /datum/action's that this item has.
	var/list/actions_types //list of paths of action datums to give to the item on New().

	//Since any item can now be a piece of clothing, this has to be put here so all items share it.
	var/flags_inv //This flag is used to determine when items in someone's inventory cover others. IE helmets making it so you can't see glasses, etc.

	var/item_color = null //this needs deprecating, soonish

	var/body_parts_covered = 0 //see setup.dm for appropriate bit flags
	//var/heat_transfer_coefficient = 1 //0 prevents all transfers, 1 is invisible
	var/gas_transfer_coefficient = 1 // for leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/permeability_coefficient = 1 // for chemicals/diseases
	var/siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit)
	var/slowdown = 0 // How much clothing is slowing you down. Negative values speeds you up
	var/armour_penetration = 0 //percentage of armour effectiveness to remove
	var/list/allowed = null //suit storage stuff.
	var/obj/item/device/uplink/hidden_uplink = null
	var/equip_delay_self = 0 //In deciseconds, how long an item takes to equip; counts only for normal clothing slots, not pockets etc.
	var/equip_delay_other = 20 //In deciseconds, how long an item takes to put on another person
	var/strip_delay = 40 //In deciseconds, how long an item takes to remove from another person
	var/breakouttime = 0
	var/list/materials
	var/origin_tech = null	//Used by R&D to determine what research bonuses it grants.
	var/needs_permit = 0			//Used by security bots to determine if this item is safe for public use.

	var/list/attack_verb //Used in attackby() to say how something was attacked "[x] has been [z.attack_verb] by [y] with [z]"
	var/list/species_exception = null	// list() of species types, if a species cannot put items in a certain slot, but species type is in list, it will be able to wear that item

	var/suittoggled = FALSE
	var/hooded = 0

	var/mob/thrownby = null

	/obj/item/mouse_drag_pointer = MOUSE_ACTIVE_POINTER //the icon to indicate this object is being dragged

	//So items can have custom embedd values
	//Because customisation is king
	var/embed_chance = EMBED_CHANCE
	var/embedded_fall_chance = EMBEDDED_ITEM_FALLOUT
	var/embedded_pain_chance = EMBEDDED_PAIN_CHANCE
	var/embedded_pain_multiplier = EMBEDDED_PAIN_MULTIPLIER  //The coefficient of multiplication for the damage this item does while embedded (this*w_class)
	var/embedded_fall_pain_multiplier = EMBEDDED_FALL_PAIN_MULTIPLIER //The coefficient of multiplication for the damage this item does when falling out of a limb (this*w_class)
	var/embedded_impact_pain_multiplier = EMBEDDED_IMPACT_PAIN_MULTIPLIER //The coefficient of multiplication for the damage this item does when first embedded (this*w_class)
	var/embedded_unsafe_removal_pain_multiplier = EMBEDDED_UNSAFE_REMOVAL_PAIN_MULTIPLIER //The coefficient of multiplication for the damage removing this without surgery causes (this*w_class)
	var/embedded_unsafe_removal_time = EMBEDDED_UNSAFE_REMOVAL_TIME //A time in ticks, multiplied by the w_class.

	var/flags_cover = 0 //for flags such as GLASSESCOVERSEYES
	var/heat = 0
	var/sharpness = IS_BLUNT
	var/toolspeed = 1

	var/block_chance = 0
	var/hit_reaction_chance = 0 //If you want to have something unrelated to blocking/armour piercing etc. Maybe not needed, but trying to think ahead/allow more freedom
	var/reach = 1 //In tiles, how far this weapon can reach; 1 for adjacent, which is default

	//The list of slots by priority. equip_to_appropriate_slot() uses this list. Doesn't matter if a mob type doesn't have a slot.
	var/list/slot_equipment_priority = null // for default list, see /mob/proc/equip_to_appropriate_slot()

	// Needs to be in /obj/item because corgis can wear a lot of
	// non-clothing items
	var/datum/dog_fashion/dog_fashion = null

	var/datum/rpg_loot/rpg_loot = null


	//Tooltip vars
	var/in_inventory = FALSE//is this item equipped into an inventory slot or hand of a mob?
	var/force_string //string form of an item's force. Edit this var only to set a custom force string
	var/last_force_string_check = 0
	var/tip_timer
	var/force_string_override

/obj/item/Initialize()
	if (!materials)
		materials = list()
	. = ..()
	for(var/path in actions_types)
		new path(src)
	actions_types = null

	if(GLOB.rpg_loot_items)
		rpg_loot = new(src)

	if(force_string)
		force_string_override = TRUE

/obj/item/Destroy()
	flags &= ~DROPDEL	//prevent reqdels
	if(ismob(loc))
		var/mob/m = loc
		m.temporarilyRemoveItemFromInventory(src, TRUE)
	for(var/X in actions)
		qdel(X)
	QDEL_NULL(rpg_loot)
	return ..()

/obj/item/device
	icon = 'icons/obj/device.dmi'

/obj/item/proc/check_allowed_items(atom/target, not_inside, target_self)
	if(((src in target) && !target_self) || (!isturf(target.loc) && !isturf(target) && not_inside))
		return 0
	else
		return 1

/obj/item/blob_act(obj/structure/blob/B)
	if(B && B.loc == loc)
		qdel(src)

//user: The mob that is suiciding
//damagetype: The type of damage the item will inflict on the user
//BRUTELOSS = 1
//FIRELOSS = 2
//TOXLOSS = 4
//OXYLOSS = 8
//Output a creative message and then return the damagetype done
/obj/item/proc/suicide_act(mob/user)
	return

/obj/item/verb/move_to_top()
	set name = "Move To Top"
	set category = "Object"
	set src in oview(1)

	if(!isturf(loc) || usr.stat || usr.restrained() || !usr.canmove)
		return

	var/turf/T = src.loc

	src.loc = null

	src.loc = T

/obj/item/examine(mob/user) //This might be spammy. Remove?
	..()
	var/pronoun
	if(src.gender == PLURAL)
		pronoun = "They are"
	else
		pronoun = "It is"
	var/size = weightclass2text(src.w_class)
	to_chat(user, "[pronoun] a [size] item." )

	if(user.research_scanner) //Mob has a research scanner active.
		var/msg = "*--------* <BR>"

		if(origin_tech)
			msg += "<span class='notice'>Testing potentials:</span><BR>"
			var/list/techlvls = params2list(origin_tech)
			for(var/T in techlvls) //This needs to use the better names.
				msg += "Tech: [CallTechName(T)] | magnitude: [techlvls[T]] <BR>"
		else
			msg += "<span class='danger'>No tech origins detected.</span><BR>"


		if(materials.len)
			msg += "<span class='notice'>Extractable materials:<BR>"
			for(var/mat in materials)
				msg += "[CallMaterialName(mat)]<BR>" //Capitize first word, remove the "$"
		else
			msg += "<span class='danger'>No extractable materials detected.</span><BR>"
		msg += "*--------*"
		to_chat(user, msg)


/obj/item/attack_self(mob/user)
	interact(user)

/obj/item/interact(mob/user)
	add_fingerprint(user)
	if(hidden_uplink && hidden_uplink.active)
		hidden_uplink.interact(user)
		return 1
	ui_interact(user)

/obj/item/ui_act(action, params)
	add_fingerprint(usr)
	return ..()

/obj/item/attack_hand(mob/user)
	if(!user)
		return
	if(anchored)
		return

	if(resistance_flags & ON_FIRE)
		var/mob/living/carbon/C = user
		if(istype(C))
			if(C.gloves && (C.gloves.max_heat_protection_temperature > 360))
				extinguish()
				to_chat(user, "<span class='notice'>You put out the fire on [src].</span>")
			else
				to_chat(user, "<span class='warning'>You burn your hand on [src]!</span>")
				var/obj/item/bodypart/affecting = C.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
				if(affecting && affecting.receive_damage( 0, 5 ))		// 5 burn damage
					C.update_damage_overlays()
				return
		else
			extinguish()

	if(acid_level > 20 && !ismob(loc))// so we can still remove the clothes on us that have acid.
		var/mob/living/carbon/C = user
		if(istype(C))
			if(!C.gloves || (!(C.gloves.resistance_flags & (UNACIDABLE|ACID_PROOF))))
				to_chat(user, "<span class='warning'>The acid on [src] burns your hand!</span>")
				var/obj/item/bodypart/affecting = C.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
				if(affecting && affecting.receive_damage( 0, 5 ))		// 5 burn damage
					C.update_damage_overlays()


	if(istype(loc, /obj/item/weapon/storage))
		//If the item is in a storage item, take it out
		var/obj/item/weapon/storage/S = loc
		S.remove_from_storage(src, user.loc)

	if(throwing)
		throwing.finalize(FALSE)
	if(loc == user)
		if(!user.dropItemToGround(src))
			return

	pickup(user)
	add_fingerprint(user)
	if(!user.put_in_active_hand(src))
		dropped(user)


/obj/item/attack_paw(mob/user)
	if(!user)
		return
	if(anchored)
		return

	if(istype(loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = loc
		S.remove_from_storage(src, user.loc)

	if(throwing)
		throwing.finalize(FALSE)
	if(loc == user)
		if(!user.dropItemToGround(src))
			return

	pickup(user)
	add_fingerprint(user)
	if(!user.put_in_active_hand(src))
		dropped(user)

/obj/item/attack_alien(mob/user)
	var/mob/living/carbon/alien/A = user

	if(!A.has_fine_manipulation)
		if(src in A.contents) // To stop Aliens having items stuck in their pockets
			A.dropItemToGround(src)
		to_chat(user, "<span class='warning'>Your claws aren't capable of such fine manipulation!</span>")
		return
	attack_paw(A)

/obj/item/attack_ai(mob/user)
	if(istype(src.loc, /obj/item/weapon/robot_module))
		//If the item is part of a cyborg module, equip it
		if(!iscyborg(user))
			return
		var/mob/living/silicon/robot/R = user
		if(!R.low_power_mode) //can't equip modules with an empty cell.
			R.activate_module(src)
			R.hud_used.update_robot_modules_display()

// Due to storage type consolidation this should get used more now.
// I have cleaned it up a little, but it could probably use more.  -Sayu
// The lack of ..() is intentional, do not add one
/obj/item/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = W
		if(S.use_to_pickup)
			if(S.collection_mode) //Mode is set to collect multiple items on a tile and we clicked on a valid one.
				if(isturf(loc))
					var/list/rejections = list()

					var/list/things = loc.contents.Copy()
					if (S.collection_mode == 2)
						things = typecache_filter_list(things, typecacheof(type))

					var/len = things.len
					if(!len)
						to_chat(user, "<span class='notice'>You failed to pick up anything with [S].</span>")
						return
					var/datum/progressbar/progress = new(user, len, loc)

					while (do_after(user, 10, TRUE, S, FALSE, CALLBACK(src, .proc/handle_mass_pickup, S, things, loc, rejections, progress)))
						sleep(1)

					qdel(progress)

					to_chat(user, "<span class='notice'>You put everything you could [S.preposition] [S].</span>")

			else if(S.can_be_inserted(src))
				S.handle_item_insertion(src)

/obj/item/proc/handle_mass_pickup(obj/item/weapon/storage/S, list/things, atom/thing_loc, list/rejections, datum/progressbar/progress)
	for(var/obj/item/I in things)
		things -= I
		if(I.loc != thing_loc)
			continue
		if(I.type in rejections) // To limit bag spamming: any given type only complains once
			continue
		if(!S.can_be_inserted(I, stop_messages = TRUE))	// Note can_be_inserted still makes noise when the answer is no
			if(S.contents.len >= S.storage_slots)
				break
			rejections += I.type	// therefore full bags are still a little spammy
			continue

		S.handle_item_insertion(I, TRUE)	//The 1 stops the "You put the [src] into [S]" insertion message from being displayed.

		if (TICK_CHECK)
			progress.update(progress.goal - things.len)
			return TRUE

	progress.update(progress.goal - things.len)
	return FALSE

// afterattack() and attack() prototypes moved to _onclick/item_attack.dm for consistency

/obj/item/proc/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(prob(final_block_chance))
		owner.visible_message("<span class='danger'>[owner] blocks [attack_text] with [src]!</span>")
		return 1
	return 0

/obj/item/proc/talk_into(mob/M, input, channel, spans, datum/language/language)
	return ITALICS | REDUCE_RANGE

/obj/item/proc/dropped(mob/user)
	for(var/X in actions)
		var/datum/action/A = X
		A.Remove(user)
	if(DROPDEL & flags)
		qdel(src)
	in_inventory = FALSE

// called just as an item is picked up (loc is not yet changed)
/obj/item/proc/pickup(mob/user)
	in_inventory = TRUE
	return


// called when this item is removed from a storage item, which is passed on as S. The loc variable is already set to the new destination before this is called.
/obj/item/proc/on_exit_storage(obj/item/weapon/storage/S)
	return

// called when this item is added into a storage item, which is passed on as S. The loc variable is already set to the storage item.
/obj/item/proc/on_enter_storage(obj/item/weapon/storage/S)
	return

// called when "found" in pockets and storage items. Returns 1 if the search should end.
/obj/item/proc/on_found(mob/finder)
	return

// called after an item is placed in an equipment slot //NOPE, for example, if you put a helmet in slot_head, it is NOT in user's head variable yet, how stupid.
// user is mob that equipped it
// slot uses the slot_X defines found in setup.dm
// for items that can be placed in multiple slots
// note this isn't called during the initial dressing of a player
/obj/item/proc/equipped(mob/user, slot)
	for(var/X in actions)
		var/datum/action/A = X
		if(item_action_slot_check(slot, user)) //some items only give their actions buttons when in a specific slot.
			A.Grant(user)
	in_inventory = TRUE

//sometimes we only want to grant the item's action if it's equipped in a specific slot.
/obj/item/proc/item_action_slot_check(slot, mob/user)
	if(slot == slot_in_backpack || slot == slot_legcuffed) //these aren't true slots, so avoid granting actions there
		return FALSE
	return TRUE

//the mob M is attempting to equip this item into the slot passed through as 'slot'. Return 1 if it can do this and 0 if it can't.
//if this is being done by a mob other than M, it will include the mob equipper, who is trying to equip the item to mob M. equipper will be null otherwise.
//If you are making custom procs but would like to retain partial or complete functionality of this one, include a 'return ..()' to where you want this to happen.
//Set disable_warning to 1 if you wish it to not give you outputs.
/obj/item/proc/mob_can_equip(mob/living/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	if(!M)
		return 0

	return M.can_equip(src, slot, disable_warning, bypass_equip_delay_self)

/obj/item/verb/verb_pickup()
	set src in oview(1)
	set category = "Object"
	set name = "Pick up"

	if(usr.incapacitated() || !Adjacent(usr) || usr.lying)
		return

	if(usr.get_active_held_item() == null) // Let me know if this has any problems -Yota
		usr.UnarmedAttack(src)

//This proc is executed when someone clicks the on-screen UI button.
//The default action is attack_self().
//Checks before we get to here are: mob is alive, mob is not restrained, stunned, asleep, resting, laying, item is on the mob.
/obj/item/proc/ui_action_click(mob/user, actiontype)
	attack_self(user)

/obj/item/proc/IsReflect(var/def_zone) //This proc determines if and at what% an object will reflect energy projectiles if it's in l_hand,r_hand or wear_suit
	return 0

/obj/item/proc/eyestab(mob/living/carbon/M, mob/living/carbon/user)

	var/is_human_victim = 0
	var/obj/item/bodypart/affecting = M.get_bodypart("head")
	if(ishuman(M))
		if(!affecting) //no head!
			return
		is_human_victim = 1
		var/mob/living/carbon/human/H = M
		if((H.head && H.head.flags_cover & HEADCOVERSEYES) || \
			(H.wear_mask && H.wear_mask.flags_cover & MASKCOVERSEYES) || \
			(H.glasses && H.glasses.flags_cover & GLASSESCOVERSEYES))
			// you can't stab someone in the eyes wearing a mask!
			to_chat(user, "<span class='danger'>You're going to need to remove that mask/helmet/glasses first!</span>")
			return

	if(ismonkey(M))
		var/mob/living/carbon/monkey/Mo = M
		if(Mo.wear_mask && Mo.wear_mask.flags_cover & MASKCOVERSEYES)
			// you can't stab someone in the eyes wearing a mask!
			to_chat(user, "<span class='danger'>You're going to need to remove that mask/helmet/glasses first!</span>")
			return

	if(isalien(M))//Aliens don't have eyes./N     slimes also don't have eyes!
		to_chat(user, "<span class='warning'>You cannot locate any eyes on this creature!</span>")
		return

	if(isbrain(M))
		to_chat(user, "<span class='danger'>You cannot locate any organic eyes on this brain!</span>")
		return

	src.add_fingerprint(user)

	playsound(loc, src.hitsound, 30, 1, -1)

	user.do_attack_animation(M)

	if(M != user)
		M.visible_message("<span class='danger'>[user] has stabbed [M] in the eye with [src]!</span>", \
							"<span class='userdanger'>[user] stabs you in the eye with [src]!</span>")
	else
		user.visible_message( \
			"<span class='danger'>[user] has stabbed themself in the eyes with [src]!</span>", \
			"<span class='userdanger'>You stab yourself in the eyes with [src]!</span>" \
		)
	if(is_human_victim)
		var/mob/living/carbon/human/U = M
		U.apply_damage(7, BRUTE, affecting)

	else
		M.take_bodypart_damage(7)

	add_logs(user, M, "attacked", "[src.name]", "(INTENT: [uppertext(user.a_intent)])")

	M.adjust_blurriness(3)
	M.adjust_eye_damage(rand(2,4))
	var/obj/item/organ/eyes/eyes = M.getorganslot("eyes_sight")
	if (!eyes)
		return
	if(eyes.eye_damage >= 10)
		M.adjust_blurriness(15)
		if(M.stat != DEAD)
			to_chat(M, "<span class='danger'>Your eyes start to bleed profusely!</span>")
		if(!(M.disabilities & (NEARSIGHT | BLIND)))
			if(M.become_nearsighted())
				to_chat(M, "<span class='danger'>You become nearsighted!</span>")
		if(prob(50))
			if(M.stat != DEAD)
				if(M.drop_item())
					to_chat(M, "<span class='danger'>You drop what you're holding and clutch at your eyes!</span>")
			M.adjust_blurriness(10)
			M.Unconscious(20)
			M.Knockdown(40)
		if (prob(eyes.eye_damage - 10 + 1))
			if(M.become_blind())
				to_chat(M, "<span class='danger'>You go blind!</span>")

/obj/item/clean_blood()
	. = ..()
	if(.)
		if(initial(icon) && initial(icon_state))
			var/index = blood_splatter_index()
			var/icon/blood_splatter_icon = GLOB.blood_splatter_icons[index]
			if(blood_splatter_icon)
				cut_overlay(blood_splatter_icon)

/obj/item/clothing/gloves/clean_blood()
	. = ..()
	if(.)
		transfer_blood = 0

/obj/item/singularity_pull(S, current_size)
	if(current_size >= STAGE_FOUR)
		throw_at(S,14,3, spin=0)
	else ..()

/obj/item/throw_impact(atom/A)
	if(A && !QDELETED(A))
		if(is_hot() && isliving(A))
			var/mob/living/L = A
			L.IgniteMob()
		var/itempush = 1
		if(w_class < 4)
			itempush = 0 //too light to push anything
		return A.hitby(src, 0, itempush)

/obj/item/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback)
	thrownby = thrower
	callback = CALLBACK(src, .proc/after_throw, callback) //replace their callback with our own
	. = ..(target, range, speed, thrower, spin, diagonals_first, callback)


/obj/item/proc/after_throw(datum/callback/callback)
	if (callback) //call the original callback
		. = callback.Invoke()
	throw_speed = initial(throw_speed) //explosions change this.
	in_inventory = FALSE

/obj/item/proc/remove_item_from_storage(atom/newLoc) //please use this if you're going to snowflake an item out of a obj/item/weapon/storage
	if(!newLoc)
		return 0
	if(istype(loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = loc
		S.remove_from_storage(src,newLoc)
		return 1
	return 0

/obj/item/proc/is_hot()
	return heat

/obj/item/proc/is_sharp()
	return sharpness

/obj/item/proc/get_dismemberment_chance(obj/item/bodypart/affecting)
	if(affecting.can_dismember(src))
		if((sharpness || damtype == BURN) && w_class >= 3)
			. = force*(w_class-1)

/obj/item/proc/get_dismember_sound()
	if(damtype == BURN)
		. = 'sound/weapons/sear.ogg'
	else
		. = pick('sound/misc/desceration-01.ogg', 'sound/misc/desceration-02.ogg', 'sound/misc/desceration-03.ogg')

/obj/item/proc/open_flame(flame_heat=700)
	var/turf/location = loc
	if(ismob(location))
		var/mob/M = location
		var/success = FALSE
		if(src == M.get_item_by_slot(slot_wear_mask))
			success = TRUE
		if(success)
			location = get_turf(M)
	if(isturf(location))
		location.hotspot_expose(flame_heat, 5)

/obj/item/proc/ignition_effect(atom/A, mob/user)
	if(is_hot())
		. = "<span class='notice'>[user] lights [A] with [src].</span>"
	else
		. = ""


//when an item modify our speech spans when in our active hand. Override this to modify speech spans.
/obj/item/proc/get_held_item_speechspans(mob/living/carbon/user)
	return

/obj/item/hitby(atom/movable/AM)
	return

/obj/item/attack_hulk(mob/living/carbon/human/user)
	return 0

/obj/item/attack_animal(mob/living/simple_animal/M)
	return 0

/obj/item/mech_melee_attack(obj/mecha/M)
	return 0

/obj/item/burn()
	if(!QDELETED(src))
		var/turf/T = get_turf(src)
		var/ash_type = /obj/effect/decal/cleanable/ash
		if(w_class == WEIGHT_CLASS_HUGE || w_class == WEIGHT_CLASS_GIGANTIC)
			ash_type = /obj/effect/decal/cleanable/ash/large
		var/obj/effect/decal/cleanable/ash/A = new ash_type(T)
		A.desc += "\nLooks like this used to be \an [name] some time ago."
		..()

/obj/item/acid_melt()
	if(!QDELETED(src))
		var/turf/T = get_turf(src)
		var/obj/effect/decal/cleanable/molten_object/MO = new(T)
		MO.pixel_x = rand(-16,16)
		MO.pixel_y = rand(-16,16)
		MO.desc = "Looks like this was \an [src] some time ago."
		..()

/obj/item/proc/microwave_act(obj/machinery/microwave/M)
	if(M && M.dirty < 100)
		M.dirty++

/obj/item/proc/on_mob_death(mob/living/L, gibbed)

/obj/item/proc/set_force_string()
	switch(force)
		if(0 to 4)
			force_string = "very low"
		if(4 to 7)
			force_string = "low"
		if(7 to 10)
			force_string = "medium"
		if(10 to 11)
			force_string = "high"
		if(11 to 20) //12 is the force of a toolbox
			force_string = "robust"
		if(20 to 25)
			force_string = "very robust"
		else
			force_string = "exceptionally robust"
	last_force_string_check = force

/obj/item/proc/openTip(location, control, params, user)
	if(last_force_string_check != force && !force_string_override)
		set_force_string()
	if(!force_string_override)
		openToolTip(user,src,params,title = name,content = "[desc]<br>[force ? "<b>Force:</b> [force_string]" : ""]",theme = "")
	else
		openToolTip(user,src,params,title = name,content = "[desc]<br><b>Force:</b> [force_string]",theme = "")

/obj/item/MouseEntered(location, control, params)
	if(in_inventory && usr.client.prefs.enable_tips)
		var/timedelay = usr.client.prefs.tip_delay/100
		var/user = usr
		tip_timer = addtimer(CALLBACK(src, .proc/openTip, location, control, params, user), timedelay, TIMER_STOPPABLE)//timer takes delay in deciseconds, but the pref is in milliseconds. dividing by 100 converts it.

/obj/item/MouseExited()
	deltimer(tip_timer)//delete any in-progress timer if the mouse is moved off the item before it finishes
	closeToolTip(usr)

