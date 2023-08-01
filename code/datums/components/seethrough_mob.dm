///A component that lets you turn your character transparent in order to see and click through yourself.
/datum/component/seethrough_mob
	///The fake version of ourselves
	var/image/trickery_image
	///Which alpha do we animate towards?
	var/target_alpha
	///How long our faze in/out takes
	var/animation_time
	///Does this object let clicks from players its transparent to pass through it
	var/clickthrough
	///Are we currently applying our effects to the mob?
	var/is_active

///see_through_map is a define pointing to a specific map. It's basically defining the area which is considered behind. See see_through_maps.dm for a list of maps
/datum/component/seethrough_mob/Initialize(target_alpha = 100, animation_time = 0.5 SECONDS, clickthrough = TRUE)
	. = ..()

	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

	src.target_alpha = target_alpha
	src.animation_time = animation_time
	src.clickthrough = clickthrough
	src.is_active = FALSE

///Apply the trickery image and animation
/datum/component/seethrough_mob/proc/trick_mob()
	SIGNAL_HANDLER

	var/mob/fool = parent
	var/datum/hud/our_hud = fool.hud_used
	for(var/atom/movable/screen/plane_master/seethrough in our_hud.get_true_plane_masters(SEETHROUGH_PLANE))
		seethrough.unhide_plane(fool)

	var/atom/atom_parent = parent
	trickery_image = new(atom_parent)
	trickery_image.loc = atom_parent
	trickery_image.override = TRUE

	if(clickthrough)
		//Special plane so we can click through the overlay
		SET_PLANE_EXPLICIT(trickery_image, SEETHROUGH_PLANE, atom_parent)

	//These are inherited, but we already use the atom's loc so we end up at double the pixel offset
	trickery_image.pixel_x = 0
	trickery_image.pixel_y = 0

	fool.client.images += trickery_image

	animate(trickery_image, alpha = target_alpha, time = animation_time)

	RegisterSignal(fool, COMSIG_MOB_LOGOUT, PROC_REF(on_client_disconnect))
	RegisterSignal(fool, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_direction_change))
	RegisterSignal(fool, COMSIG_ATOM_UPDATE_APPEARANCE, PROC_REF(on_appearance_change))

///Remove the screen object and make us appear solid to ourselves again
/datum/component/seethrough_mob/proc/untrick_mob()
	var/mob/fool = parent
	animate(trickery_image, alpha = 255, time = animation_time)
	UnregisterSignal(fool, COMSIG_MOB_LOGOUT)
	UnregisterSignal(fool, COMSIG_ATOM_DIR_CHANGE)

	//after playing the fade-in animation, remove the screen obj
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/component/seethrough,clear_image), trickery_image, fool.client), animation_time)

///Remove a screen image from a client
/datum/component/seethrough_mob/proc/clear_image(image/removee, client/remove_from)
	remove_from?.images -= removee //player could've logged out during the animation, so check just in case

///Image is removed when they log out because client gets deleted, so drop the mob reference
/datum/component/seethrough_mob/proc/on_client_disconnect()
	SIGNAL_HANDLER

	var/mob/fool = parent
	UnregisterSignal(fool, COMSIG_MOB_LOGOUT)
	UnregisterSignal(fool, COMSIG_ATOM_DIR_CHANGE)
	var/datum/hud/our_hud = fool.hud_used
	is_active = FALSE
	for(var/atom/movable/screen/plane_master/seethrough in our_hud.get_true_plane_masters(SEETHROUGH_PLANE))
		seethrough.hide_plane(fool)
	clear_image(trickery_image, fool.client)

/datum/component/seethrough_mob/proc/on_direction_change()
	SIGNAL_HANDLER


	var/atom/atom_parent = parent
	trickery_image.setDir(atom_parent.dir)
	on_appearance_change()

/datum/component/seethrough_mob/proc/on_appearance_change()
	SIGNAL_HANDLER

	var/prior_alpha = trickery_image.alpha
	var/atom/atom_parent = parent
	trickery_image.appearance = atom_parent.appearance
	trickery_image.override = TRUE
	trickery_image.pixel_x = 0
	trickery_image.pixel_y = 0

	if(clickthrough)
		SET_PLANE_EXPLICIT(trickery_image, SEETHROUGH_PLANE, atom_parent)

	trickery_image.alpha = prior_alpha


/datum/action/toggle_seethrough
	name = "Toggle Seethrough"
	desc = "Allows you to see behind your massive body and click through it."
	button_icon = 'icons/mob/actions/actions_xeno.dmi'
	button_icon_state = "smallqueen"
	background_icon_state = "bg_alien"

/datum/action/toggle_seethrough/Trigger(trigger_flags)
	..()
	var/datum/component/seethrough_mob/seethroughComp = owner.GetComponent(/datum/component/seethrough_mob)
	if(!seethroughComp.is_active)
		seethroughComp.trick_mob()
		seethroughComp.is_active = TRUE
	else
		seethroughComp.untrick_mob()
		seethroughComp.is_active = FALSE
