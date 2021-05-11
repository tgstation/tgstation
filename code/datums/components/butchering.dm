/datum/component/butchering
	/// Time in deciseconds taken to butcher something
	var/speed
	/// Percentage effectiveness; numbers above 100 yield extra drops
	var/effectiveness
	/// Percentage increase to bonus item chance
	var/bonus_modifier
	/// Sound played when butchering
	var/butcher_sound

/datum/component/butchering/Initialize(
	speed = 8 SECONDS,
	effectiveness = 100,
	bonus_modifier = 0,
	butcher_sound = 'sound/effects/butcher.ogg'
)
	src.speed = speed
	src.effectiveness = effectiveness
	src.bonus_modifier = bonus_modifier
	src.butcher_sound = butcher_sound

/datum/component/butchering/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/on_item_attacking)

/datum/component/butchering/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK)

/datum/component/butchering/proc/on_item_attacking(obj/item/source, mob/living/target, mob/living/user)
	SIGNAL_HANDLER

	if(target.stat == DEAD && (target.butcher_results || target.guaranteed_butcher_results)) //can we butcher it?
		INVOKE_ASYNC(src, .proc/startButcher, source, target, user)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(ishuman(target) && source.force && source.get_sharpness())
		var/mob/living/carbon/human/human_victim = target
		if((user.pulling == human_victim && user.grab_state >= GRAB_AGGRESSIVE) && user.zone_selected == BODY_ZONE_HEAD) // Only aggressive grabbed can be sliced.
			if(human_victim.has_status_effect(/datum/status_effect/neck_slice))
				user.show_message("<span class='warning'>[human_victim]'s neck has already been already cut, you can't make the bleeding any worse!</span>", MSG_VISUAL, \
								"<span class='warning'>Their neck has already been already cut, you can't make the bleeding any worse!</span>")
				return COMPONENT_CANCEL_ATTACK_CHAIN
			INVOKE_ASYNC(src, .proc/startNeckSlice, source, human_victim, user)
			return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/butchering/proc/startButcher(obj/item/source, mob/living/target, mob/living/user)
	to_chat(user, "<span class='notice'>You begin to butcher [target]...</span>")
	playsound(target.loc, butcher_sound, 50, TRUE, -1)
	if(do_mob(user, target, speed) && target.Adjacent(source))
		Butcher(user, target, source)
	else
		log_combat(user, human_victim, "attempted to butcher", source)

/datum/component/butchering/proc/startNeckSlice(obj/item/source, mob/living/carbon/human/human_victim, mob/living/user)
	if(DOING_INTERACTION_WITH_TARGET(user, human_victim))
		to_chat(user, "<span class='warning'>You're already interacting with [human_victim]!</span>")
		return

	user.visible_message("<span class='danger'>[user] is slitting [human_victim]'s throat!</span>", \
					"<span class='danger'>You start slicing [human_victim]'s throat!</span>", \
					"<span class='hear'>You hear a cutting noise!</span>", ignored_mobs = human_victim)
	human_victim.show_message("<span class='userdanger'>Your throat is being slit by [user]!</span>", MSG_VISUAL, \
					"<span class = 'userdanger'>Something is cutting into your neck!</span>", NONE)
	log_combat(user, human_victim, "attempted throat slitting", source)

	playsound(human_victim.loc, butcher_sound, 50, TRUE, -1)
	if(do_mob(user, human_victim, clamp(500 / source.force, 30, 100)) && human_victim.Adjacent(source))
		if(human_victim.has_status_effect(/datum/status_effect/neck_slice))
			user.show_message("<span class='warning'>[human_victim]'s neck has already been already cut, you can't make the bleeding any worse!</span>", MSG_VISUAL, \
							"<span class='warning'>Their neck has already been already cut, you can't make the bleeding any worse!</span>")
			return

		human_victim.visible_message("<span class='danger'>[user] slits [human_victim]'s throat!</span>", \
					"<span class='userdanger'>[user] slits your throat...</span>")
		log_combat(user, human_victim, "wounded via throat slitting", source)
		human_victim.apply_damage(source.force, BRUTE, BODY_ZONE_HEAD, wound_bonus=CANT_WOUND) // easy tiger, we'll get to that in a sec
		var/obj/item/bodypart/slit_throat = human_victim.get_bodypart(BODY_ZONE_HEAD)
		if(slit_throat)
			var/datum/wound/slash/critical/screaming_through_a_slit_throat = new
			screaming_through_a_slit_throat.apply_wound(slit_throat)
		human_victim.apply_status_effect(/datum/status_effect/neck_slice)

/**
 * Handles a user butchering a target
 *
 * Arguments:
 * - [butcher][/mob/living]: The mob doing the butchering
 * - [meat][/mob/living]: The mob being butchered
 * - [tool][/obj/item]: tool used to butcher. optional and just used in logging
 */
/datum/component/butchering/proc/Butcher(mob/living/butcher, mob/living/meat, obj/item/tool)
	log_combat(butcher, meat, "butchered", tool)
	var/list/results = list()
	var/turf/meat_drop_location = meat.drop_location()
	var/final_effectiveness = effectiveness - meat.butcher_difficulty
	var/bonus_chance = max(0, (final_effectiveness - 100) + bonus_modifier) //so 125 total effectiveness = 25% extra chance
	for(var/obj/bones as anything in meat.butcher_results)
		var/amount = meat.butcher_results[bones]
		for(var/_i in 1 to amount)
			if(!prob(final_effectiveness))
				if(butcher)
					to_chat(butcher, "<span class='warning'>You fail to harvest some of the [initial(bones.name)] from [meat].</span>")
				continue

			if(prob(bonus_chance))
				if(butcher)
					to_chat(butcher, "<span class='info'>You harvest some extra [initial(bones.name)] from [meat]!</span>")
				results += new bones(meat_drop_location)
			results += new bones(meat_drop_location)

		meat.butcher_results.Remove(bones) //in case you want to, say, have it drop its results on gib

	for(var/obj/sinew as anything in meat.guaranteed_butcher_results)
		var/amount = meat.guaranteed_butcher_results[sinew]
		for(var/i in 1 to amount)
			results += new sinew(meat_drop_location)
		meat.guaranteed_butcher_results.Remove(sinew)

	for(var/obj/item/carrion in results)
		var/list/meat_mats = carrion.has_material_type(/datum/material/meat)
		if(!length(meat_mats))
			continue
		carrion.set_custom_materials((carrion.custom_materials - meat_mats) + list(GET_MATERIAL_REF(/datum/material/meat/mob_meat, meat) = counterlist_sum(meat_mats)))

	if(butcher)
		butcher.visible_message("<span class='notice'>[butcher] butchers [meat].</span>", \
								"<span class='notice'>You butcher [meat].</span>")
	ButcherEffects(meat)
	meat.harvest(butcher)
	meat.gib(FALSE, FALSE, TRUE)

/datum/component/butchering/proc/ButcherEffects(mob/living/meat) //extra effects called on butchering, override this via subtypes
	return

///Special snowflake component only used for the recycler.
/datum/component/butchering/recycler

/datum/component/butchering/recycler/Initialize(_speed, _effectiveness, _bonus_modifier, _butcher_sound, disabled, _can_be_blunt)
	if(!istype(parent, /obj/machinery/recycler)) //EWWW
		return COMPONENT_INCOMPATIBLE
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, parent, loc_connections)

/datum/component/butchering/recycler/RegisterWithParent()
	return //we do not want the signals the parent (oop definition of parent) has

/datum/component/butchering/recycler/UnregisterFromParent()
	return

/datum/component/butchering/recycler/proc/on_entered(datum/source, mob/living/L)
	SIGNAL_HANDLER

	if(!istype(L))
		return
	var/obj/machinery/recycler/eater = parent
	if(eater.safety_mode || (eater.machine_stat & (BROKEN|NOPOWER))) //I'm so sorry.
		return
	if(L.stat == DEAD && (L.butcher_results || L.guaranteed_butcher_results))
		Butcher(parent, L)
