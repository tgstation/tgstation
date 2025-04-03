/datum/component/splat
	///The icon state to use for the decal
	var/icon_state
	///The bodypart layer to use for the decal
	var/layer
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
	icon_state = "creampie",
	layer = EXTERNAL_FRONT,
	memory_type = /datum/memory/witnessed_creampie,
	smudge_type = /obj/effect/decal/cleanable/food/pie_smudge,
	moodlet_type = /datum/mood_event/creampie,
	splat_color,
	datum/callback/hit_callback,
)
	. = ..()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.icon_state = icon_state
	src.layer = layer
	src.memory_type = memory_type
	src.smudge_type = smudge_type
	src.moodlet_type = moodlet_type
	src.hit_callback = hit_callback
	src.splat_color = splat_color

/datum/component/splat/Destroy()
	hit_callback = null
	return ..()

/datum/component/splat/RegisterWithParent()
	if(isprojectile(parent))
		RegisterSignal(parent, COMSIG_PROJECTILE_SELF_ON_HIT, PROC_REF(projectile_splat))
	else
		RegisterSignal(parent, COMSIG_MOVABLE_IMPACT, PROC_REF(throw_splat))

/datum/component/splat/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_IMPACT, COMSIG_PROJECTILE_SELF_ON_HIT))

/datum/component/splat/proc/projectile_splat(obj/projectile/source, atom/firer, atom/target, angle, hit_limb_zone, blocked, pierce_hit)
	SIGNAL_HANDLER
	if(blocked != 100 && !pierce_hit)
		splat(source, target)

/datum/component/splat/proc/throw_splat(atom/movable/source, atom/hit_atom, datum/thrownthing/throwing_datum, caught)
	SIGNAL_HANDLER
	if(caught) //someone caught us!
		return
	splat(source, hit_atom)

/datum/component/splat/proc/splat(atom/movable/source, atom/hit_atom)
	var/turf/hit_turf = get_turf(hit_atom)
	new smudge_type(hit_turf)
	var/can_splat_on = TRUE
	if(isliving(hit_atom))
		var/mob/living/living_target_getting_hit = hit_atom
		if(iscarbon(living_target_getting_hit))
			can_splat_on = !!(living_target_getting_hit.get_bodypart(BODY_ZONE_HEAD))
		hit_callback?.Invoke(living_target_getting_hit, can_splat_on)
	if(can_splat_on && is_type_in_typecache(hit_atom, GLOB.splattable))
		hit_atom.AddComponent(/datum/component/face_decal/splat, icon_state, layer, splat_color || source.color, memory_type, moodlet_type)
	SEND_SIGNAL(source, COMSIG_MOVABLE_SPLAT, hit_atom)
	if(!isprojectile(source))
		qdel(source)
