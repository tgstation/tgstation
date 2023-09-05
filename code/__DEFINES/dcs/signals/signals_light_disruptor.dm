// Light disruptor. Not to be confused with the light eater, which permanently disables lights.

/// from /obj/projectile/energy/fisher/on_hit() or /obj/item/gun/energy/recharge/fisher when striking a target
#define COMSIG_DISRUPTED_LIGHTS "disrupted_lights"
	/// if there was a light that we were able to successfully disrupt
	#define LIGHT_DISRUPTOR_SUCCESS (1<<0)
