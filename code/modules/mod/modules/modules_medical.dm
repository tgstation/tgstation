/obj/item/mod/module/organ_thrower
	name = "MOD organ thrower module"
	desc = "An arm mounted organ launching device to automatically insert organs into open bodies."
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = 50
	incompatible_modules = list(/obj/item/mod/module/organ_thrower)
	var/max_organs = 5
	var/organ_list = list()
	var/require_open = TRUE

/obj/item/mod/module/organ_thrower/bluespace
	name = "MOD bluespace organ thrower module"
	desc = "Like the organ thrower, except it doesn't require an open body to replace the organ!"
	require_open = FALSE

/obj/item/mod/module/organ_thrower/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/wearer_human = mod.wearer
	if(get_dist(wearer_human, target) > 7)
		return
	if(istype(target, /obj/item/organ))
		if(!wearer_human.Adjacent(target))
			return
		var/atom/movable/organ = target
		if(length(organ_list) >= max_organs)
			mod.wearer.balloon_alert("too many organs!")
			return
		organ_list += organ
		organ.forceMove(src)
		mod.wearer.balloon_alert("picked up [organ]")
		playsound(src, 'sound/mecha/hydraulic.ogg', 25, TRUE)
	if(!length(organ_list))
		return
	var/atom/target_to_shoot = target
	var/obj/projectile/organ/organ_proj = new /obj/projectile/organ
	organ_proj.organ_ref = pop(organ_list)
	organ_proj.icon = organ_proj.organ_ref.icon
	organ_proj.icon_state = organ_proj.organ_ref.icon_state
	organ_proj.require_open = require_open
	organ_proj.preparePixelProjectile(target_to_shoot, mod.wearer)
	organ_proj.firer = mod.wearer
	mod.wearer.balloon_alert("fired [organ_proj.organ_ref]")
	playsound(src, 'sound/mecha/hydraulic.ogg', 25, TRUE)
	INVOKE_ASYNC(organ_proj, /obj/projectile.proc/fire)

/obj/projectile/organ
	name = "flying organ"
	icon_state = "tether"
	icon = 'icons/obj/mod.dmi'
	pass_flags = PASSTABLE
	damage = 0
	nodamage = TRUE
	hitsound = 'sound/weapons/batonextend.ogg'
	hitsound_wall = 'sound/weapons/batonextend.ogg'
	var/obj/item/organ/organ_ref
	var/require_open = TRUE


/obj/projectile/organ/on_hit(atom/target)
	. = ..()
	if(!ishuman(target))
		organ_ref.forceMove(get_turf(target))
		return
	var/mob/living/carbon/human/organ_reciever = target
	var/succeed = TRUE
	if(require_open)
		succeed = FALSE
		if(organ_reciever.surgeries.len)
			for(var/datum/surgery/procedure in organ_reciever.surgeries)
				if(procedure.location != organ_ref.zone)
					continue
				if(!istype(procedure, /datum/surgery/organ_manipulation))
					continue
				var/datum/surgery_step/surgery_step = procedure.get_surgery_step()
				if(!istype(surgery_step, /datum/surgery_step/manipulate_organs))
					continue
				succeed = TRUE
				break
	if(succeed)
		var/list/organs_to_boot_out = organ_reciever.getorganslot(organ_ref.slot)
		for(var/obj/item/organ/organ_evacced in organs_to_boot_out)
			if(organ_evacced.organ_flags & ORGAN_UNREMOVABLE)
				continue
			organ_evacced.Remove(target)
			organ_evacced.forceMove(get_turf(target))
		organ_ref.Insert(target)
	else
		organ_ref.forceMove(get_turf(target))


