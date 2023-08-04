///A component that lets you turn your character transparent in order to see and click through yourself.
/datum/component/seethrough_mob
	///The atom that enables our horseshit
	var/obj/render_source_atom
	///The fake version of ourselves
	var/image/trickery_image
	///Which alpha do we animate towards?
	var/target_alpha
	///How long our faze in/out takes
	var/animation_time
	///Does this object let clicks from players its transparent to pass through it
	var/clickthrough
	///Is the seethrough effect currently active
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

	render_source_atom = new()

	var/static/uid = 0
	uid++
	fool.render_target = "*transparent_bigmob[uid]"
	fool.vis_contents.Add(render_source_atom)
	render_source_atom.render_source = fool.render_target

	render_source_atom.appearance_flags |= ( RESET_COLOR | RESET_TRANSFORM)

	render_source_atom.vis_flags |= (VIS_INHERIT_ID | VIS_INHERIT_PLANE | VIS_INHERIT_LAYER)

	//32 too much
	//64 just right
	//96 too little

	var/icon/current_mob_icon = icon(fool.icon, fool.icon_state)
	render_source_atom.pixel_x = -fool.pixel_x
	render_source_atom.pixel_y = ((current_mob_icon.Height() - 32) * 0.5)

	trickery_image = new(render_source_atom)
	trickery_image.loc = render_source_atom
	trickery_image.override = TRUE

	trickery_image.pixel_x = 0
	trickery_image.pixel_y = 0

	if(clickthrough)
		//Special plane so we can click through the overlay
		SET_PLANE_EXPLICIT(trickery_image, SEETHROUGH_PLANE, fool)

	fool.client.images += trickery_image

	animate(trickery_image, alpha = target_alpha, time = animation_time)

	RegisterSignal(fool, COMSIG_MOB_LOGOUT, PROC_REF(on_client_disconnect))

///Remove the screen object and make us appear solid to ourselves again
/datum/component/seethrough_mob/proc/untrick_mob()
	var/mob/fool = parent
	animate(trickery_image, alpha = 255, time = animation_time)
	UnregisterSignal(fool, COMSIG_MOB_LOGOUT)

	//after playing the fade-in animation, remove the screen obj
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/component/seethrough,clear_image), trickery_image, fool.client), animation_time)

///Remove a screen image from a client
/datum/component/seethrough_mob/proc/clear_image(image/removee, client/remove_from)
	var/atom/atom_parent = parent
	atom_parent.appearance_flags &= ~KEEP_TOGETHER
	atom_parent.render_target = null
	qdel(render_source_atom)
	remove_from?.images -= removee //player could've logged out during the animation, so check just in case

///Image is removed when they log out because client gets deleted, so drop the mob reference
/datum/component/seethrough_mob/proc/on_client_disconnect()
	SIGNAL_HANDLER

	var/mob/fool = parent
	UnregisterSignal(fool, COMSIG_MOB_LOGOUT)
	var/datum/hud/our_hud = fool.hud_used
	for(var/atom/movable/screen/plane_master/seethrough in our_hud.get_true_plane_masters(SEETHROUGH_PLANE))
		seethrough.hide_plane(fool)
	clear_image(trickery_image, fool.client)

/datum/action/toggle_seethrough
	name = "Toggle Seethrough"
	desc = "Allows you to see behind your massive body and click through it."
	button_icon = 'icons/mob/actions/actions_xeno.dmi'
	button_icon_state = "alien_sneak"
	background_icon_state = "bg_alien"


/datum/action/toggle_seethrough/Grant(mob/grant_to)
	. = ..()
	if(!grant_to.GetComponent(/datum/component/seethrough_mob))
		grant_to.AddComponent(/datum/component/seethrough_mob)

/datum/action/toggle_seethrough/Remove(mob/remove_from)
	var/datum/component/seethrough_mob/seethroughComp = owner.GetComponent(/datum/component/seethrough_mob)
	if(seethroughComp.is_active)
		seethroughComp.untrick_mob()
	. = ..()

/datum/action/toggle_seethrough/Trigger(trigger_flags)
	..()
	var/datum/component/seethrough_mob/seethroughComp = owner.GetComponent(/datum/component/seethrough_mob)
	seethroughComp.is_active = !seethroughComp.is_active
	if(seethroughComp.is_active)
		seethroughComp.trick_mob()
	else
		seethroughComp.untrick_mob()
