/datum/component/splat
	///The type of memory to celebrate the event of getting hit by this
	var/memory_type
	///The type of smudge we create on the floor
	var/smudge_type
	///The moodlet passed down to the creamed component
	var/moodlet_type
	///The color we give to the creamed component/overlay
	var/splat_color
	///The callback called when a mob is hit by this
	var/datum/callback/hit_callback

/datum/component/splat/Initialize(
	memory_type = /datum/memory/witnessed_creampie,
	smudge_type = /obj/effect/decal/cleanable/food/pie_smudge,
	moodlet_type = /datum/mood_event/creampie,
	splat_color,
	datum/callback/hit_callback,
)
	. = ..()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.memory_type = memory_type
	src.smudge_type = smudge_type
	src.moodlet_type = moodlet_type
	src.hit_callback = hit_callback
	src.splat_color = splat_color

/datum/component/splat/Destroy()
	QDEL_NULL(hit_callback)
	return ..()

/datum/component/splat/RegisterWithParent()
	if(isprojectile(parent))
		RegisterSignal(parent, COMSIG_PROJECTILE_SELF_ON_HIT, PROC_REF(projectile_splat))
	else
		RegisterSignal(parent, COMSIG_MOVABLE_IMPACT, PROC_REF(throw_splat))

/datum/component/splat/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_IMPACT, COMSIG_PROJECTILE_SELF_ON_HIT))

/datum/component/splat/proc/projectile_splat(obj/projectile/source, atom/firer, atom/target, angle, hit_limb_zone, blocked)
	SIGNAL_HANDLER
	if(blocked != 100)
		splat(source, target)

/datum/component/splat/proc/throw_splat(atom/movable/source, atom/hit_atom, datum/thrownthing/throwing_datum, caught)
	SIGNAL_HANDLER
	if(caught) //someone caught us!
		return
	splat(source, hit_atom)

/datum/component/splat/proc/splat(atom/movable/source, atom/hit_atom)
	var/turf/hit_turf = get_turf(hit_atom)
	new smudge_type(hit_turf)
	var/is_creamable = TRUE
	if(isliving(hit_atom))
		var/mob/living/living_target_getting_hit = hit_atom
		if(iscarbon(living_target_getting_hit))
			is_creamable = !!(living_target_getting_hit.get_bodypart(BODY_ZONE_HEAD))
		hit_callback?.Invoke(living_target_getting_hit, is_creamable)
	if(is_creamable && is_type_in_typecache(hit_atom, GLOB.creamable))
		hit_atom.AddComponent(/datum/component/creamed, splat_color || source.color, memory_type, moodlet_type)
	SEND_SIGNAL(source, COMSIG_MOVABLE_SPLAT, hit_atom)
	qdel(source)
