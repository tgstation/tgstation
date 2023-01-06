/**
 * Deployable - Bring your big guns with you, and smack em' down where you want.
 *
 * Allows items to spawn other items (usually objects) in front of the user after a short delay.
 * If attaching this to something:
 * Set deploy_time to a number in seconds for the deploy delay
 * Set thing_to_be_deployed to an obj path for the thing that gets spawned
 * Lastly, set delete_on_use to TRUE or FALSE if you want the object you're deploying with to get deleted when used
 */

/datum/component/deployable
	/// The time it takes to deploy the object
	var/deploy_time = 5 SECONDS
	/// The object that gets spawned if deployed successfully
	var/obj/thing_to_be_deployed
	/// Used in getting the name of the deployed object
	var/deployed_name
	/// If the item used to deploy gets deleted on use or not
	var/delete_on_use = TRUE

/datum/component/deployable/Initialize(deploy_time, thing_to_be_deployed, delete_on_use)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.deploy_time = deploy_time
	src.thing_to_be_deployed = thing_to_be_deployed
	src.delete_on_use = delete_on_use

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(examine))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_hand))

	var/obj/item/typecast = thing_to_be_deployed
	deployed_name = initial(typecast.name)

/datum/component/deployable/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("[source.p_they()] look[source.p_s()] like [source.p_they()] can be deployed into \a [deployed_name].")

/datum/component/deployable/proc/on_attack_hand(datum/source, mob/user, location, direction)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(deploy), source, user, location, direction)

/datum/component/deployable/proc/deploy(obj/source, mob/user, location, direction) //If there's no user, location and direction are used
	var/obj/deployed_object //Used for spawning the deployed object
	var/turf/deploy_location //Where our deployed_object gets put
	var/new_direction //What direction do we want our deployed object in
	if(user)
		if(!ishuman(user))
			return

		deploy_location = get_step(user, user.dir) //Gets spawn location for thing_to_be_deployed if there is a user
		if(deploy_location.is_blocked_turf(TRUE))
			source.balloon_alert(user, "insufficient room to deploy here.")
			return
		new_direction = user.dir //Gets the direction for thing_to_be_deployed if there is a user
		source.balloon_alert(user, "deploying...")
		playsound(source, 'sound/items/ratchet.ogg', 50, TRUE)
		if(!do_after(user, deploy_time))
			return
	else //If there is for some reason no user, then the location and direction are set here
		deploy_location = location
		new_direction = direction

	deployed_object = new thing_to_be_deployed(deploy_location)
	deployed_object.setDir(new_direction)

	//Sets the integrity of the new deployed machine to that of the object it came from
	deployed_object.modify_max_integrity(source.max_integrity)
	deployed_object.update_icon_state()

	if(delete_on_use)
		qdel(source)
