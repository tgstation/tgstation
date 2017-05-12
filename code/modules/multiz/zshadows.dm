

//An appearance, in movable atom form, designed to show through Zs
//System only visibly displays 2 z of depth, for visual clarity+performance
/atom/movable/zshadow
	var/atom/owner

/atom/movable/zshadow/Initialize()
	..()
	LAZYADD(SSz.zshadows, src)

/atom/movable/zshadow/Move() //loc = only bby.
	return

/atom/movable/zshadow/CanFallThroughZ() //amusing, but no
	return

/atom/movable/zshadow/Destroy()
	if(!QDELETED(owner)) //Nothing destroys these if their owner exists, they *ARE* their owner as far as we're concerned
		return QDEL_HINT_LETMELIVE
	LAZYREMOVE(SSz.zshadows, src)
	return ..()

/atom/movable/zshadow/examine(mob/user)
	if(owner)
		owner.examine(user)

/atom/movable/zshadow/CreateZShadow() //cascade upwards
	if(istype(owner, /atom/movable/zshadow)) //but only owner->shadow->shadow, no more (more than 2 levels of depth wouldn't be visible)
		return
	..()

/atom/movable/zshadow/proc/SyncAppearance()
	var/visibilityLevel = 2
	if(!istype(owner, /atom/movable/zshadow))
		visibilityLevel = 1

	var/mutable_appearance/MA = new(owner)
	MA.color = (visibilityLevel == 1) ? "#555555" : "#111111"//visible : visible barely
	MA.density = FALSE
	MA.opacity = FALSE
	MA.layer *= 0.01 //a shrunken version of our layer (so we correctly layer as our owner would, but locked below our turf)
	MA.verbs = list() //so you don't try to "pick-up" the shadow
	appearance = MA

	if(zshadow)
		zshadow.SyncAppearance() //cascade upwards

//forceMove is deliberately ignored here, don't you dare change it
/atom/movable/zshadow/proc/SyncLoc()
	if(isturf(owner) || owner && isturf(owner.loc))
		loc = GetAboveConnectedTurf(owner)
	var/turf/Tloc = loc
	if(!isturf(loc) || !Tloc.z_open) //if we're not supposed to show through
		loc = null
	Moved()
	if(loc && zshadow)
		zshadow.SyncLoc() //cascade upwards

//lazy
/atom/movable/zshadow/proc/Sync()
	SyncAppearance()
	SyncLoc()