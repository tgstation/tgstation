// Alright.
// Let me tell you a story.
// Of how BYOND planes are complete. fucking. shit.
//
// It all began when this DM coder decided to port /vg/lighting to TG.
// He got the code working, but gasp! When he opened the game, the lighting was invisible!
// It was, of course a planes issue. See, the lighting plane didn't support the multiplication blending!
//
// So how do you fix this? Multiplicative blending onto a plane doesn't work as it stays black!
// What if we BLEND_OVERLAY onto the plane, and the plane blends multiplicative?
// Alas, this also doesn't work! The areas without lighting overlay become black!
// So what if we make the lighting overlay overlay the negative colour,
// then make the plane invert itself afterwards again? Genius!
// The plane is dark when not blended onto so it inverts to white,
// It's dark which gets inverted to white when a fully lit overlay is blended on,
// and it's bright which gets inverted to black when a dark overlay is blended on.
// Surely this method was infallible!
//
// And so the coder tried, but alas it did not work.
//
// After careful science™️, he came to the following conclusion:
// BYOND planes are black when blended onto by other things.
// But anything not blended on turns white for the colour matrix and such.
//
// WHAT THE FUCK?
//
// And today we are here, with this god damn screen object.
// This screen object serves as a white backdrop so we can always blend into white.
// Making everything actually work.
// T-thanks BYOND.
// Remake when?


/obj/screen/lighting_backdrop
	icon = 'WHITE_THING.dmi'
	icon_state = "reeee"
	screen_loc = "SOUTH,WEST"
	plane = LIGHTING_PLANE
	layer = -1
	blend_mode = BLEND_OVERLAY

/obj/screen/lighting_backdrop/New(loc, new_size)
	..()
	update_size(new_size)

/obj/screen/lighting_backdrop/proc/update_size(new_size)
	var/matrix/M = matrix()
	var/size = new_size*2 + 1

	M.Scale(size)
	transform = M
