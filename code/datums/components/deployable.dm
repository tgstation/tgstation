/**
 * Deployable - Bring your big guns with you, and smack em' down where you want.
 *
 * Allows items to spawn other items (usually objects) in front of the user after a short delay.
 * If attaching this to something:
 * Set deploy_time to a number in seconds for the deploy delay
 * Set thing_to_be_deployed to an obj path for the thing that gets spawned
 * Multiple deployments and deployments work together to allow a thing to be placed down several times. If multiple deployments is false then don't worry about deployments
 * Direction setting true means the object spawned will face the direction of the person who deployed it, false goes to the default direction
 */

/datum/component/deployable
	/// The time it takes to deploy the object
	var/deploy_time
	/// The object that gets spawned if deployed successfully
	var/obj/thing_to_be_deployed
	/// Can the parent be deployed multiple times
	var/multiple_deployments
	/// How many times we can deploy the parent, if multiple deployments is set to true and this gets below zero, the parent will be deleted
	var/deployments
	/// If the component adds a little bit into the parent's description
	var/add_description_hint
	/// If the direction of the thing we place is changed upon placing
	var/direction_setting

	/// Used in getting the name of the deployed object
	var/deployed_name

/datum/component/deployable/Initialize(deploy_time = 5 SECONDS, thing_to_be_deployed, multiple_deployments = FALSE, deployments = 1, add_description_hint = TRUE, direction_setting = TRUE)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.deploy_time = deploy_time
	src.thing_to_be_deployed = thing_to_be_deployed
	src.add_description_hint = add_description_hint
	src.direction_setting = direction_setting
	src.deployments = deployments
	src.multiple_deployments = multiple_deployments

	if(add_description_hint)
		RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(examine))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_hand))

	var/obj/item/typecast = thing_to_be_deployed
	deployed_name = initial(typecast.name)

/datum/component/deployable/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("It can be used <b>in hand</b> to deploy into [((deployments > 1) && multiple_deployments) ? "[deployments]" : "a"] [deployed_name].")

/datum/component/deployable/proc/on_attack_hand(datum/source, mob/user, location, direction)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(deploy), source, user, location, direction)

/datum/component/deployable/proc/deploy(obj/source, mob/user, location, direction) //If there's no user, location and direction are used
	// The object we are going to create
	var/atom/deployed_object
	// The turf our object is going to be deployed to
	var/turf/deploy_location
	// What direction will the deployed object be placed facing
	var/new_direction

	if(user)
		deploy_location = get_step(user, user.dir) //Gets spawn location for thing_to_be_deployed if there is a user
		if(deploy_location.is_blocked_turf(TRUE, parent))
			source.balloon_alert(user, "insufficient room to deploy here.")
			return
		new_direction = user.dir //Gets the direction for thing_to_be_deployed if there is a user
		source.balloon_alert(user, "deploying...")
		playsound(source, 'sound/items/tools/ratchet.ogg', 50, TRUE)
		if(!do_after(user, deploy_time))
			return
	else // If there is for some reason no user, then the location and direction are set here
		deploy_location = location
		new_direction = direction

	deployed_object = new thing_to_be_deployed(deploy_location)
	if(direction_setting)
		deployed_object.setDir(new_direction)
		deployed_object.update_icon_state()

	deployments -= 1

	if(!multiple_deployments || deployments < 1)
		qdel(source)
