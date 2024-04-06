/obj/item/implant/wasps
	name = "wasp revenge implant"
	desc = "NO! NOT THE BEES!"
	icon_state = "notthebees"
	actions_types = null
	var/active = FALSE
	var/beemount = 5

/obj/item/implant/wasps/proc/on_doof(datum/source, gibbed)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(activate), "death")

/obj/item/implant/wasps/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Bee Liberation BUZZ-13 Revenge Implant<BR>
				<b>Life:</b> Activates upon death.<BR>
				<b>Important Notes:</b> Releases a shitton of toxic bees.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a compact, bluespace containment unit with an electronically sealed hatch and drill combo which will puncture the host's flesh to release it's contents.<BR>
				<b>Special Features:</b> Releases a shitton of toxic bees.<BR>
				"}
	return dat

/obj/item/implant/wasps/activate(cause)
	if(!cause || !imp_in || active)
		return FALSE

	var/turf/beeturf = get_turf(imp_in)

	message_admins("[ADMIN_LOOKUPFLW(imp_in)] has activated their [name] at [ADMIN_VERBOSEJMP(beeturf)], with cause of [cause].")
	if(cause == "death")
		beetime()

/obj/item/implant/wasps/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(.)
		RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_doof))

/obj/item/implant/wasps/removed(mob/target, silent = FALSE, special = FALSE)
	. = ..()
	if(.)
		UnregisterSignal(target, COMSIG_LIVING_DEATH)

/obj/item/implant/wasps/proc/beetime()
	var/turf/beeturf = get_turf(imp_in)
	sleep(0.25 SECONDS) // Just in case tots get both this and the flyzapper, don't want the tesla shock to kill the bees.
	for(var/i in 1 to beemount)
		new /mob/living/basic/bee/toxin(get_turf(beeturf))

/obj/item/implant/wasps/macro
	beemount = 20


/obj/item/implanter/wasps
	name = "implanter (wasp vengeance)"
	imp_type = /obj/item/implant/wasps

/obj/item/implantcase/wasps
	name = "Implant Case - 'Wasp Vengeance'"
	desc = "A glass case containing a wasp vengeance implant."
	imp_type = /obj/item/implant/wasps

/obj/item/implanter/wasps/macro
	name = "implanter (macro wasp vengeance)"
	imp_type = /obj/item/implant/wasps/macro

/obj/item/implantcase/wasps/macro
	name = "Implant Case - 'Macro Wasp Vengeance'"
	desc = "A glass case containing a macro wasp vengeance implant."
	imp_type = /obj/item/implant/wasps/macro


/obj/item/implant/tesla
	name = "flyzapper implant"
	desc = "Shock em' dead."
	icon_state = "lighting_bolt"
	actions_types = null
	var/active = FALSE
	var/zap_range = 7
	var/zap_power = 30000

/obj/item/implant/tesla/proc/on_deef(datum/source, gibbed)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(activate), "death")

/obj/item/implant/tesla/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> ZAP-50 Revenge Implant<BR>
				<b>Life:</b> Activates upon death.<BR>
				<b>Important Notes:</b> Zaps everyone nearby.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a compact, tesla coil bluespace unit rigged to a health sensor primed to activate on death.<BR>
				<b>Special Features:</b> Zaps everyone nearby.<BR>
				"}
	return dat

/obj/item/implant/tesla/activate(cause)
	if(!cause || !imp_in || active)
		return FALSE

	var/turf/teslaturf = get_turf(imp_in)

	message_admins("[ADMIN_LOOKUPFLW(imp_in)] has activated their [name] at [ADMIN_VERBOSEJMP(teslaturf)], with cause of [cause].")
	if(cause == "death")
		teslatime()

/obj/item/implant/tesla/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(.)
		RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_deef))

/obj/item/implant/tesla/removed(mob/target, silent = FALSE, special = FALSE)
	. = ..()
	if(.)
		UnregisterSignal(target, COMSIG_LIVING_DEATH)

/obj/item/implant/tesla/proc/teslatime()
	var/zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_MOB_STUN
	//var/turf/teslaturf = get_turf(imp_in)
	tesla_zap(imp_in, zap_range, zap_power, zap_flags)
	playsound(imp_in, 'sound/machines/defib_zap.ogg', 50, TRUE)

/obj/item/implant/tesla/macro
	zap_range = 20
	zap_power = 90000


/obj/item/implanter/tesla
	name = "implanter (flyzapper implant)"
	imp_type = /obj/item/implant/tesla

/obj/item/implantcase/tesla
	name = "Implant Case - 'Flyzapper Implant'"
	desc = "A glass case containing a flyzapper implant."
	imp_type = /obj/item/implant/tesla

/obj/item/implanter/tesla/macro
	name = "implanter (macro flyzapper implant)"
	imp_type = /obj/item/implant/tesla/macro

/obj/item/implantcase/tesla/macro
	name = "Implant Case - 'Macro Flyzapper Implant'"
	desc = "A glass case containing a macro flyzapper implant."
	imp_type = /obj/item/implant/tesla/macro