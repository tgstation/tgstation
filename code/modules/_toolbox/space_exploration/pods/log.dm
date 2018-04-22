var/list/pod_logs = list()

/datum/pod_log
	var/list/modification_log = list()
	var/list/occupancy_log = list()
	var/list/toggle_log = list()
	var/list/security_log = list()
	var/list/damage_log = list()
	var/list/general_log = list()
	var/list/usage_log = list()
	var/obj/pod/holder

	New(var/obj/pod/pod)
		..()
		holder = pod
		pod_logs += src

	proc/Stamp()
		return "\[[time_stamp()]\]: "

	proc/Log(var/message = "", var/color = "red")
		general_log.Add(Stamp() + "<font color='[color]'>[message]</font>")

	proc/LogModification(var/mob/living/user, var/obj/item/I)
		var/attach = (I in holder)
		var/obj/item/pod_attachment/attachment
		if(istype(I, /obj/item/pod_attachment))
			attachment = I

		var/log = "[key_name(user)] [attach ? "attached" : "detached"] \the [I.name] ([I.type])[attachment ? " Hardpoint: [attachment.hardpoint_slot]" : ""]."
		modification_log.Add(Stamp() + "<font color='[attach ? "green" : "blue"]'>[log]</font>")

	proc/LogOccupancy(var/mob/living/occupant, var/as_pilot = 1, var/mob/living/dragged_by = 0)
		var/entered = (occupant in holder.GetOccupants())
		var/log = "[key_name(occupant)] [entered ? "<font color='green'>entered</font>" : "<font color='red'>left</font>"] \the [holder] ([holder.type]) as [as_pilot ? "pilot" : "passenger"]"
		if(dragged_by)
			log += ", (dragged out by [key_name(dragged_by)]"
		log += "."
		occupancy_log.Add(Stamp() + "<font color='[as_pilot ? "blue" : "orange"]'>[log]</font>")

	proc/LogToggle(var/mob/living/user, var/type = 0)
		var/on = holder.toggles & type
		var/log = "[key_name(user)] toggled '[type]' [on ? "on" : "off"]."
		toggle_log.Add(Stamp() + "<font color='[on ? "green" : "red"]'>[log]</font>")

	proc/LogToggleAttachment(var/mob/living/user, var/obj/item/pod_attachment/attachment)
		var/on = (attachment.active & P_ATTACHMENT_ACTIVE)
		var/log = "[user ? key_name(user) : "(Undefined)"] toggled the [attachment] ([attachment.type]) [on ? "on" : "off"]."
		toggle_log.Add(Stamp() + "<font color='[on ? "green" : "red"]'>[log]</font>")

	proc/LogSecurity(var/mob/living/user, var/lock_type = 0, var/data = 0)
		var/added = (data in holder.locks)
		var/log = "[key_name(user)] [added ? "added" : "removed"] a lock[data ? " ('[data]')" : ""][lock_type ? " (lock type: [lock_type])" : ""]"
		security_log.Add(Stamp() + "<font color='[added ? "green" : "red"]'>[log]</font>")

	proc/LogDamage(var/damage = 0, var/bf = 0, var/obj/item/I, var/mob/living/attacker)
		var/log = "[damage] damage taken[(bf == P_DAMAGE_ABSORBED) ? " (absorbed)" : (bf == P_DAMAGE_REDUCED) ? " (reduced)" : ""]"
		if(I)
			if(istype(I, /obj/item/projectile))
				var/obj/item/projectile/P = I
				log += ", shot by [key_name(P.firer)] (type: [P.type]) (damage: [P.damage]) (REMHP: [holder.health])"
			else
				log += ", attacked with the [I] by [key_name(attacker)] (REMHP: [holder.health])"
		else if(attacker && !ishuman(attacker))
			log += ", attacked by ([attacker.type]) (REMHP: [holder.health])"
			if(attacker.client)
				log += " ([key_name(attacker)])"
		else if(attacker && ishuman(attacker))
			log += ", attacked by [key_name(attacker)] (REMHP: [holder.health])"
			if(attacker.client)
				log += " ([key_name(attacker)])"
		damage_log.Add(Stamp() + "<font color='[(bf == P_DAMAGE_ABSORBED) ? "green" : (bf == P_DAMAGE_REDUCED) ? "orange" : "red"]'>[log]</font>")

	proc/LogUsage(var/mob/living/user, var/obj/item/pod_attachment/attachment, var/list/targets = list(), var/list/additions = list())
		var/log = "[key_name(user)] used the [attachment.name] ([attachment.type]) (cost: [attachment.power_usage]) (power left: [holder.power_source ? holder.power_source.charge : "Undefined"])"
		for(var/turf/T in targets)
			log += ", (Target #[targets.Find(T)] {[T.x], [T.y], [T.z]}"
			if(length(additions) >= targets.Find(T))
				var/addition = additions[targets.Find(T)]
				if(length(addition))
					log += ", [addition])"
					continue
			log += ")[(length(targets) > targets.Find(T)) ? ", " : ""]"

		usage_log.Add(Stamp() + "<font color='red'>[log]</font>")
