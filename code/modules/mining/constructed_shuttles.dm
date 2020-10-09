/obj/item/shuttlecapsule
	name = "bluespace shuttle capsule"
	desc = "An shuttle stored within a pocket of bluespace."
	icon_state = "capsule"
	icon = 'icons/obj/mining.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/template_id = "construction_mining"
	var/datum/map_template/shuttle/template
	var/used = FALSE

/obj/item/shuttlecapsule/proc/get_template()
	if(template)
		return
	template = SSmapping.shuttle_templates[template_id]
	if(!template)
		loc.visible_message("<span class='warning'>Wrong template_id: [template_id]</span>")

/obj/item/shuttlecapsule/Destroy()
	template = null // without this, capsules would be one use. per round.
	. = ..()

/obj/item/shuttlecapsule/examine(mob/user)
	. = ..()
	get_template()
	. += "This capsule has the [template.name] stored."
	. += template.description

/obj/item/shuttlecapsule/attack_self()
	//Can't grab when capsule is New() because templates aren't loaded then
	get_template()
	if(!used)
		loc.visible_message("<span class='warning'>\The [src] begins to shake. Stand back!</span>")
		used = TRUE
		sleep(50)
		/*var/turf/deploy_location = get_turf(src)
		var/status = template.check_deploy(deploy_location)
		switch(status)
			if(SHELTER_DEPLOY_BAD_AREA)
				src.loc.visible_message("<span class='warning'>\The [src] will not function in this area.</span>")
			if(SHELTER_DEPLOY_BAD_TURFS, SHELTER_DEPLOY_ANCHORED_OBJECTS)
				var/width = template.width
				var/height = template.height
				src.loc.visible_message("<span class='warning'>\The [src] doesn't have room to deploy! You need to clear a [width]x[height] area!</span>")

		if(status != SHELTER_DEPLOY_ALLOWED)
			used = FALSE
			return*/

		used = FALSE

		playsound(src, 'sound/effects/phasein.ogg', 100, TRUE)

		if(!is_mining_level(deploy_location.z) && !isspaceturf(deploy_location)) //only report capsules away from the mining/lavaland level or not in space 
			message_admins("[ADMIN_LOOKUPFLW(usr)] activated a bluespace shuttle capsule away from the mining level, and not in space! [ADMIN_VERBOSEJMP(deploy_location)]")
			log_admin("[key_name(usr)] activated a bluespace shuttle capsule away from the mining level, or space, at [AREACOORD(deploy_location)]")
		//Area saving docking_port
		var/obj/docking_port/stationary/dock_port = new(deploy_location)
		dock_port.unregister()
		dock_port.delete_after = TRUE
		template.load(deploy_location, centered = TRUE)
		var/obj/docking_port/mobile/shuttle_port = SSshuttle.get_containing_shuttle(deploy_location)
		dock_port.forceMove(shuttle_port.loc)
		new /obj/effect/particle_effect/smoke(get_turf(src))
		qdel(src)
