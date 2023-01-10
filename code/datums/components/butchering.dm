/datum/component/butchering
	/// Time in deciseconds taken to butcher something
	var/speed = 8 SECONDS
	/// Percentage effectiveness; numbers above 100 yield extra drops
	var/effectiveness = 100
	/// Percentage increase to bonus item chance
	var/bonus_modifier = 0
	/// Sound played when butchering
	var/butcher_sound = 'sound/effects/butcher.ogg'
	/// Whether or not this component can be used to butcher currently. Used to temporarily disable butchering
	var/butchering_enabled = TRUE
	/// Whether or not this component is compatible with blunt tools.
	var/can_be_blunt = FALSE
	/// Callback for butchering
	var/datum/callback/butcher_callback

/datum/component/butchering/Initialize(
	speed,
	effectiveness,
	bonus_modifier,
	butcher_sound,
	disabled,
	can_be_blunt,
	butcher_callback,
)
	src.speed = speed
	src.effectiveness = effectiveness
	src.bonus_modifier = bonus_modifier
	src.butcher_sound = butcher_sound
	if(disabled)
		src.butchering_enabled = FALSE
	src.can_be_blunt = can_be_blunt
	src.butcher_callback = butcher_callback
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(onItemAttack))

/datum/component/butchering/proc/onItemAttack(obj/item/source, mob/living/M, mob/living/user)
	SIGNAL_HANDLER

	if(!user.combat_mode)
		return
	if(M.stat == DEAD && (M.butcher_results || M.guaranteed_butcher_results)) //can we butcher it?
		if(butchering_enabled && (can_be_blunt || source.get_sharpness()))
			INVOKE_ASYNC(src, PROC_REF(startButcher), source, M, user)
			return COMPONENT_CANCEL_ATTACK_CHAIN

	if(ishuman(M) && source.force && source.get_sharpness())
		var/mob/living/carbon/human/H = M
		if((user.pulling == H && user.grab_state >= GRAB_AGGRESSIVE) && user.zone_selected == BODY_ZONE_HEAD) // Only aggressive grabbed can be sliced.
			if(HAS_TRAIT(user, TRAIT_PACIFISM))
				to_chat(user, span_warning("You don't want to harm other living beings!"))
				return COMPONENT_CANCEL_ATTACK_CHAIN

			if(H.has_status_effect(/datum/status_effect/neck_slice))
				user.show_message(span_warning("[H]'s neck has already been already cut, you can't make the bleeding any worse!"), MSG_VISUAL, \
								span_warning("Their neck has already been already cut, you can't make the bleeding any worse!"))
				return COMPONENT_CANCEL_ATTACK_CHAIN
			INVOKE_ASYNC(src, PROC_REF(startNeckSlice), source, H, user)
			return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/butchering/proc/startButcher(obj/item/source, mob/living/M, mob/living/user)
	to_chat(user, span_notice("You begin to butcher [M]..."))
	playsound(M.loc, butcher_sound, 50, TRUE, -1)
	if(do_mob(user, M, speed) && M.Adjacent(source))
		on_butchering(user, M)

/datum/component/butchering/proc/startNeckSlice(obj/item/source, mob/living/carbon/human/H, mob/living/user)
	if(DOING_INTERACTION_WITH_TARGET(user, H))
		to_chat(user, span_warning("You're already interacting with [H]!"))
		return

	user.visible_message(span_danger("[user] is slitting [H]'s throat!"), \
					span_danger("You start slicing [H]'s throat!"), \
					span_hear("You hear a cutting noise!"), ignored_mobs = H)
	H.show_message(span_userdanger("Your throat is being slit by [user]!"), MSG_VISUAL, \
					span_userdanger("Something is cutting into your neck!"), NONE)
	log_combat(user, H, "attempted throat slitting", source)

	playsound(H.loc, butcher_sound, 50, TRUE, -1)
	if(do_mob(user, H, clamp(500 / source.force, 30, 100)) && H.Adjacent(source))
		if(H.has_status_effect(/datum/status_effect/neck_slice))
			user.show_message(span_warning("[H]'s neck has already been already cut, you can't make the bleeding any worse!"), MSG_VISUAL, \
							span_warning("Their neck has already been already cut, you can't make the bleeding any worse!"))
			return

		H.visible_message(span_danger("[user] slits [H]'s throat!"), \
					span_userdanger("[user] slits your throat..."))
		log_combat(user, H, "wounded via throat slitting", source)
		H.apply_damage(source.force, BRUTE, BODY_ZONE_HEAD, wound_bonus=CANT_WOUND) // easy tiger, we'll get to that in a sec
		var/obj/item/bodypart/slit_throat = H.get_bodypart(BODY_ZONE_HEAD)
		if(slit_throat)
			var/datum/wound/slash/critical/screaming_through_a_slit_throat = new
			screaming_through_a_slit_throat.apply_wound(slit_throat)
		H.apply_status_effect(/datum/status_effect/neck_slice)

/**
 * Handles a user butchering a target
 *
 * Arguments:
 * - [butcher][/mob/living]: The mob doing the butchering
 * - [meat][/mob/living]: The mob being butchered
 */
/datum/component/butchering/proc/on_butchering(atom/butcher, mob/living/meat)
	var/list/results = list()
	var/turf/T = meat.drop_location()
	var/final_effectiveness = effectiveness - meat.butcher_difficulty
	var/bonus_chance = max(0, (final_effectiveness - 100) + bonus_modifier) //so 125 total effectiveness = 25% extra chance
	for(var/V in meat.butcher_results)
		var/obj/bones = V
		var/amount = meat.butcher_results[bones]
		for(var/_i in 1 to amount)
			if(!prob(final_effectiveness))
				if(butcher)
					to_chat(butcher, span_warning("You fail to harvest some of the [initial(bones.name)] from [meat]."))
				continue

			if(prob(bonus_chance))
				if(butcher)
					to_chat(butcher, span_info("You harvest some extra [initial(bones.name)] from [meat]!"))
				results += new bones (T)
			results += new bones (T)

		meat.butcher_results.Remove(bones) //in case you want to, say, have it drop its results on gib

	for(var/V in meat.guaranteed_butcher_results)
		var/obj/sinew = V
		var/amount = meat.guaranteed_butcher_results[sinew]
		for(var/i in 1 to amount)
			results += new sinew (T)
		meat.guaranteed_butcher_results.Remove(sinew)

	for(var/obj/item/carrion in results)
		var/list/meat_mats = carrion.has_material_type(/datum/material/meat)
		if(!length(meat_mats))
			continue
		carrion.set_custom_materials((carrion.custom_materials - meat_mats) + list(GET_MATERIAL_REF(/datum/material/meat/mob_meat, meat) = counterlist_sum(meat_mats)))

	if(butcher)
		butcher.visible_message(span_notice("[butcher] butchers [meat]."), \
								span_notice("You butcher [meat]."))
	butcher_callback?.Invoke(butcher, meat)
	meat.harvest(butcher)
	meat.log_message("has been butchered by [key_name(butcher)]", LOG_ATTACK)
	meat.gib(FALSE, FALSE, TRUE)

///Enables the butchering mechanic for the mob who has equipped us.
/datum/component/butchering/proc/enable_butchering(datum/source)
	SIGNAL_HANDLER
	butchering_enabled = TRUE

///Disables the butchering mechanic for the mob who has dropped us.
/datum/component/butchering/proc/disable_butchering(datum/source)
	SIGNAL_HANDLER
	butchering_enabled = FALSE

///Special snowflake component only used for the recycler.
/datum/component/butchering/recycler


/datum/component/butchering/recycler/Initialize(
	speed,
	effectiveness,
	bonus_modifier,
	butcher_sound,
	disabled,
	can_be_blunt,
	butcher_callback,
)
	if(!istype(parent, /obj/machinery/recycler)) //EWWW
		return COMPONENT_INCOMPATIBLE
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddComponent(/datum/component/connect_loc_behalf, parent, loc_connections)

/datum/component/butchering/recycler/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!isliving(arrived))
		return
	var/mob/living/victim = arrived
	var/obj/machinery/recycler/eater = parent
	if(eater.safety_mode || (eater.machine_stat & (BROKEN|NOPOWER))) //I'm so sorry.
		return
	if(victim.stat == DEAD && (victim.butcher_results || victim.guaranteed_butcher_results))
		on_butchering(parent, victim)

/datum/component/butchering/mecha

/datum/component/butchering/mecha/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MECHA_EQUIPMENT_ATTACHED, PROC_REF(enable_butchering))
	RegisterSignal(parent, COMSIG_MECHA_EQUIPMENT_DETACHED, PROC_REF(disable_butchering))
	RegisterSignal(parent, COMSIG_MECHA_DRILL_MOB, PROC_REF(on_drill))

/datum/component/butchering/mecha/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_MECHA_DRILL_MOB,
		COMSIG_MECHA_EQUIPMENT_ATTACHED,
		COMSIG_MECHA_EQUIPMENT_DETACHED,
	))

///When we are ready to drill through a mob
/datum/component/butchering/mecha/proc/on_drill(datum/source, obj/vehicle/sealed/mecha/chassis, mob/living/meat)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(on_butchering), chassis, meat)

/datum/component/butchering/wearable

/datum/component/butchering/wearable/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(worn_enable_butchering))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(worn_disable_butchering))

/datum/component/butchering/wearable/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED,
	))

///Same as enable_butchering but for worn items
/datum/component/butchering/wearable/proc/worn_enable_butchering(obj/item/source, mob/user, slot)
	SIGNAL_HANDLER
	//check if the item is being not worn
	if(!(slot & source.slot_flags))
		return
	butchering_enabled = TRUE
	RegisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, PROC_REF(butcher_target))

///Same as disable_butchering but for worn items
/datum/component/butchering/wearable/proc/worn_disable_butchering(obj/item/source, mob/user)
	SIGNAL_HANDLER
	butchering_enabled = FALSE
	UnregisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)

/datum/component/butchering/wearable/proc/butcher_target(mob/user, atom/target, proximity)
	SIGNAL_HANDLER
	if(!isliving(target))
		return
	onItemAttack(parent, target, user)
