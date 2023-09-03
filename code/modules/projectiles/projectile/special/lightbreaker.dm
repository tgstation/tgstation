/obj/projectile/energy/fisher
	name = "attenuated kinetic force"
	icon_state = null
	damage = 0
	damage_type = BRUTE
	armor_flag = BOMB
	range = 7
	pass_flags = PASSTABLE | PASSMACHINE | PASSSTRUCTURE
	/// A list of things that the projectile will gain damage and a demolition_mod for. Mainly for light sources, because it's for shooting lights out.
	var/list/i_hate_lightbulbs = list(/obj/machinery/light,
		/obj/machinery/power/floodlight,)

/obj/projectile/energy/fisher/on_hit(atom/target, blocked, pierce_hit)
	if(is_type_in_list(target, i_hate_lightbulbs))
		damage = 25 // should guarantee light breaks
		demolition_mod = 2 // should VERY guarantee light breaks
	. = ..()
	if(!ishuman(target))
		return
	var/flickered = FALSE
	for(var/obj/item/thingy in target.contents)
		if(istype(thingy, /obj/item/flashlight))
			var/obj/item/flashlight/light = thingy
			if(light.on)
				light.toggle_light()
				flickered = TRUE
				continue
		var/datum/component/seclite_attachable/has_a_light = thingy.GetComponent(/datum/component/seclite_attachable)
		if(has_a_light?.light.on)
			has_a_light.toggle_light()
			flickered = TRUE
		if(flickered)
			to_chat(target, span_warning("Your light sources flick off."))
