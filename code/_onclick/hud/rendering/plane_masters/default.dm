/**
 * Plane master that byond will by default draw to
 * Shouldn't be used, exists to prevent people using plane 0
 * NOTE: If we used SEE_BLACKNESS on a map format that wasn't SIDE_MAP, this is where its darkness would land
 * This would allow us to control it and do fun things. But we can't because side map doesn't support it, so this is just a stub
 */
/atom/movable/screen/plane_master/default
	name = "Default"
	documentation = "This is quite fiddly, so bear with me. By default (in byond) everything in the game is rendered onto plane 0. It's the default plane. \
		<br>But, because we've moved everything we control off plane 0, all that's left is stuff byond internally renders. \
		<br>What I'd like to do with this is capture byond blackness by giving mobs the SEE_BLACKNESS sight flag. \
		<br>But we CAN'T because SEE_BLACKNESS does not work with our rendering format. So I just eat it I guess"
	plane = DEFAULT_PLANE
	multiz_scaled = FALSE
	start_hidden = TRUE // Doesn't DO anything, exists to hold this place
