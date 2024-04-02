/**
 * Render relay object assigned to a plane master to be able to relay it's render onto other planes that are not it's own
 */
/atom/movable/render_plane_relay
	screen_loc = "CENTER"
	layer = -1
	plane = 0
	appearance_flags = PASS_MOUSE | NO_CLIENT_COLOR | KEEP_TOGETHER
	var/displayed = FALSE
	/// Our source plane master
	var/atom/movable/screen/plane_master/source
	/// Our target plane master
	var/atom/movable/screen/plane_master/target

/atom/movable/render_plane_relay/Destroy(force)
	. = ..()
	if(displayed)
		source.relay_removed()
		displayed = FALSE
	source.render_relay_planes -= plane
	source.relays -= src
	if(source.home)
		source.home.relays["[plane]"] -= src
	var/client/lad = source.home?.our_hud?.mymob?.canon_client
	if(lad)
		lad.screen -= src
	source = null
	target = null

/atom/movable/render_plane_relay/proc/sync_relay(client/owner)
	if(source.hidden || (target?.hidden && source.should_hide_relay(plane)))
		if(displayed)
			source.relay_removed()
		displayed = FALSE
		owner.screen -= src
	else
		if(!displayed)
			source.relay_activated()
		displayed = TRUE
		owner.screen += src
