/obj/item/pod_attachment
	name = "pod attachment"
	desc = "An attachment for a space pod"
	icon = 'icons/oldschool/spacepods/pod_attachments.dmi'
	icon_state = "attachment_default"
	item_state = "syringe_kit"
	w_class = 4
	layer = 3.3

	var/overlay_icon_state = ""
	var/hardpoint_slot = P_HARDPOINT_SHIELD
	var/list/minimum_pod_size = list(1, 1)
	var/attachment_delay = 10
	var/detachment_delay = 20
	var/has_menu = 1
	var/obj/pod/attached_to = 0
	var/power_usage = 0
	var/power_usage_condition = P_ATTACHMENT_USAGE_ONUSE
	var/keybind = 0
	var/use_sound = 0
	var/last_use = 0
	var/cooldown = 10
	var/active = P_ATTACHMENT_ACTIVE
	var/can_detach = 1

	// Necessary for the fabricator
	var/construction_time = 100
	var/list/construction_cost = list()

	New()
		..()

		name = "[name] ([GetHardpointDisplayName()])"

		if(istype(loc, /obj/pod))
			attached_to = loc
			attached_to.update_icon()

	examine()
		..()
		to_chat(usr,"\blue The label says it requires a [minimum_pod_size[1]] by [minimum_pod_size[2]] pod, and attaches to the [GetHardpointDisplayName()].")

	proc/GetOverlay(var/list/size = minimum_pod_size)
		var/icon/I = icon(file("icons/oldschool/spacepods/pod-[size[1]]-[size[2]].dmi"))
		var/list/states = I.IconStates()
		if(("[overlay_icon_state]_on" in states) && ("[overlay_icon_state]_off" in states))
			var/on = active & P_ATTACHMENT_ACTIVE
			return image(icon = "icons/oldschool/spacepods/pod-[size[1]]-[size[2]].dmi", icon_state = "[overlay_icon_state]_[on ? "on" : "off"]")
		return image(icon = "icons/oldschool/spacepods/pod-[size[1]]-[size[2]].dmi", icon_state = src.overlay_icon_state)

	proc/StartAttach(var/obj/pod/pod, var/mob/user)
		to_chat(user,"<span class='info'>You start attaching the [src] to the [GetHardpointDisplayName()] of the [pod].</span>")
		if(do_after(user, attachment_delay,target = pod))
			user.doUnEquip(src, 1)
			to_chat(user,"<span class='info'>You finished attaching the [src].</span>")
			OnAttach(pod, user)

	proc/StartDetach(var/obj/pod/pod, var/mob/user)
		if(!can_detach)
			to_chat(user,"<span class='info'>The [src] can't be removed.</span>")
			return 0

		to_chat(user,"<span class='info'>You start detaching the [src] from the [GetHardpointDisplayName()] of the [pod].</span>")
		if(do_after(user, detachment_delay,target = pod))
			to_chat(user,"<span class='info'>You finish detaching the [src].</span>")
			OnDetach(pod, user)

	proc/OnAttach(var/obj/pod/pod, var/mob/user)
		src.loc = pod
		attached_to = pod
		pod.attachments += src
		pod.update_icon()
		pod.pod_log.LogModification(user, src)

	proc/OnDetach(var/obj/pod/pod, var/mob/user)
		pod.attachments -= src
		attached_to = 0
		pod.update_icon()
		src.loc = get_turf(user)
		pod.pod_log.LogModification(user, src)

		if((!pod.pilot) || (pod.pilot != user))
			user.put_in_hands(src)

	proc/PodProcess(var/obj/pod/pod)
		if(!attached_to)
			if(pod.CanAttach(src))
				OnAttach(pod, 0)
			else
				qdel(src)
			return 0

		if(active & P_ATTACHMENT_INACTIVE)
			return 0

		if(power_usage_condition & P_ATTACHMENT_USAGE_ONTICK)
			if(!pod.UsePower(power_usage))
				return 0

		return 1

	proc/Use(var/atom/target, var/mob/user, var/flags = P_ATTACHMENT_PLAYSOUND | P_ATTACHMENT_LOG)
		if(!(flags & P_ATTACHMENT_IGNORE_COOLDOWN))
			if(last_use && ((last_use + cooldown) > world.time))
				return 0

		if(active & P_ATTACHMENT_INACTIVE)
			return 0

		if((!(flags & P_ATTACHMENT_IGNORE_EMPED)) && attached_to.HasDamageFlag(P_DAMAGE_EMPED))
			to_chat(user,"<span class='warning'>Equipment malfunctioning...</span>")
			return 0

		if(!(flags & P_ATTACHMENT_IGNORE_POWER))
			if(!UsePower(power_usage))
				attached_to.PrintSystemAlert("Insufficient power.")
				return 0

		if(!(flags & P_ATTACHMENT_IGNORE_COOLDOWN))
			last_use = world.time

		if(flags & P_ATTACHMENT_PLAYSOUND)
			spawn(0)
				playsound(get_turf(src), use_sound, 10, 5, 0)

		user.changeNext_move(3)

		if(flags & P_ATTACHMENT_LOG)
			attached_to.pod_log.LogUsage(user, src, list(target), list())

		return 1

	proc/PodBumpedAction(var/list/turfs = list())
		return 0

	proc/PodAttackbyAction(var/obj/item/I, var/mob/living/user)
		return 0
