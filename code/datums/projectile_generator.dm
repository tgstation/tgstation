//IMPORTANT NOTE FOR ANYTHING USING THIS:
//Whatever uses this MUST dereference this manually after qdeling it! This is meant to not be forcefully destroyed as its child projectiles may still need to use it!
/datum/projectile_generator
	var/name = "Generic Projectile Generator"
	var/list/obj/item/projectile/projectiles		//lazylist

/datum/projectile_generator/Destroy(force)
	if(force)
		return ..()
	return QDEL_HINT_IWILLGC

//However if you really need this gone, use this and all the projectiles it's "supporting" will be deleted too.
/datum/projectile_generator/proc/force_destroy()
	for(var/i in projectiles)
		if(istype(i, /obj/item/projectile))
			var/obj/item/projectile/P = i
			qdel(P)			//Unless the projectile is horribly coded it will call parent of /projectile/Destroy() and dereference this thing.
	projectiles.Cut()
	qdel(src, TRUE)

/datum/projectile_generator/proc/generate_projectile(typepath, location)
	var/obj/item/projectile/P = new typepath(location, src)
	return P

//These two procs are called by the projectile being added/removed from it.
/datum/projectile_generator/proc/register_projectile(obj/item/projectile/P)
	LAZYADD(projectiles, P)
	SEND_SIGNAL(src, COMSIG_PROJECTILE_REGISTER, P)

/datum/projectile_generator/proc/deregister_projectile(obj/item/projectile/P)
	LAZYREMOVE(projectiles, P)
	UNSETEMPTY(projectiles)
	SEND_SIGNAL(src, COMSIG_PROJECTILE_UNREGISTER, P)
