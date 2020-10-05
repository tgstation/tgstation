/obj/item/paper/guides/antag/antinoblium_guide
	info = "Antinoblium Shard User's Manual<br>\
	<ul>\
	<li>Approach an active supermatter crystal with radiation shielded personal protective equipment. DO NOT MAKE PHYSICAL CONTACT.</li>\
	<li>Attach the data corruptor (provided) to the supermatter control infrastructure to allow the attachment of the antinoblium shard.</li>\
	<li>Open the antinoblium container (also provided).</li>\
	<li>Use antinoblium extraction tongs (also provided) and apply the shard to the crystal. Take note that an EMP pulse will be emitted upon attachment. Prepare accordingly. </li>\
	<li>Physical contact of any object with the antinoblium shard will fracture the shard and cause a spontaneous energy release.</li>\
	<li>Extricate yourself immediately. You have approximately 5 minutes before the infrastructure fails completely.</li>\
	<li>Upon complete infrastructure failure, the crystal well will destabilize and emit electromagnetic waves that span the entire station.</li>\
	<li>Nanotresen safety controls will announce the destabilization of the crystal. Your identity will likely be compromised, but nothing can be done about the crystal.</li>\
	</ul>"

/obj/item/supermatter_delaminator/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/supermatter_delaminator/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/supermatter_delaminator/antinoblium_shard
	icon = 'icons/obj/supermatter.dmi'
	name = "antinoblium shard"
	desc = "A small syndicate-engineered shard derived from supermatter. Highly fragile, do not handle without protection!"
	icon_state = "antinoblium_shard"

/obj/item/supermatter_delaminator/antinoblium_shard/attack_tk() // no TK dusting memes
	return FALSE

/obj/item/supermatter_delaminator/antinoblium_shard/can_be_pulled(user) // no drag memes
	return FALSE

/obj/item/supermatter_delaminator/antinoblium_shard/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/antinoblium))
		var/obj/item/antinoblium/tongs = W
		if (tongs.shard)
			to_chat(user, "<span class='notice'>\The [tongs] is already holding an antinoblium shard!</span>")
			return FALSE
		forceMove(tongs)
		tongs.shard = src
		tongs.update_icon()
		to_chat(user, "<span class='notice'>You carefully pick up [src] with [tongs].</span>")
	else if(istype(W, /obj/item/antinoblium_container/)) // we don't want it to dust
		return
	else
		to_chat(user, "<span class='notice'>As it touches \the [src], both \the [src] and \the [W] burst into dust!</span>")
		radiation_pulse(user, 100)
		playsound(src, 'sound/effects/supermatter.ogg', 50, 1)
		qdel(W)
		qdel(src)

/obj/item/supermatter_delaminator/antinoblium_shard/pickup(mob/living/user)
	. = ..()
	if(!iscarbon(user))
		return FALSE
	var/mob/ded = user
	user.visible_message("<span class='danger'>[ded] reaches out and tries to pick up [src]. [ded.p_their()] body starts to glow and bursts into flames before flashing into dust!</span>",\
			"<span class='userdanger'>You reach for [src] with your hands. That was dumb.</span>",\
			"<span class='italics'>Everything suddenly goes silent.</span>")
	radiation_pulse(user, 500, 2)
	playsound(get_turf(user), 'sound/effects/supermatter.ogg', 50, 1)
	ded.dust()

/obj/item/antinoblium_container
	name = "antinoblium bin"
	desc = "A small cube that houses a stable antinoblium shard  to be safely stored."
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "antinoblium_container_sealed"
	///Store the shard object
	var/obj/item/supermatter_delaminator/antinoblium_shard/shard
	///Check if the container is sealed
	var/sealed = TRUE

/obj/item/antinoblium_container/Initialize()
	. = ..()
	shard = new /obj/item/supermatter_delaminator/antinoblium_shard

/obj/item/antinoblium_container/Destroy()
	QDEL_NULL(shard)
	return ..()

/obj/item/antinoblium_container/proc/load(obj/item/antinoblium/T, mob/user)
	if(!istype(T) || !T.shard || shard || sealed)
		return FALSE
	T.shard.forceMove(src)
	shard = T.shard
	T.shard = null
	T.update_icon()
	update_icon()
	to_chat(user, "<span class='warning'>Container is resealing...</span>")
	addtimer(CALLBACK(src, .proc/seal), 50)
	return TRUE

/obj/item/antinoblium_container/proc/unload(obj/item/antinoblium/T, mob/user)
	if(!istype(T) || T.shard || !istype(shard) || sealed)
		return FALSE
	shard.forceMove(T)
	T.shard = shard
	shard = null
	T.update_icon()
	update_icon()
	visible_message("<span class='warning'>[user] gingerly takes out the antinoblium shard with the tongs...</span>")
	return TRUE

/obj/item/antinoblium_container/proc/seal()
	if(sealed || !istype(shard))
		return
	STOP_PROCESSING(SSobj, shard)
	playsound(src, 'sound/items/deconstruct.ogg', 60, 1)
	sealed = TRUE
	update_icon()
	say("Hermetic locks re-engaged; [shard] is safely recontained.")

/obj/item/antinoblium_container/proc/unseal()
	if(!sealed)
		return
	sealed = FALSE
	update_icon()
	say("Hermetic locks disengaged; [shard] is available for use.")

/obj/item/antinoblium_container/attackby(obj/item/antinoblium/tongs, mob/user)
	if(istype(tongs))
		if(!tongs.shard)
			unload(tongs, user)
			return TRUE
		else
			load(tongs, user)
			return TRUE
	else
		return ..()

/obj/item/antinoblium_container/attack_self(mob/user)
	if(!shard)
		return
	if(sealed)
		unseal()
		to_chat(user, "<span class='warning'>[user] opens the [src] revealing the [shard] contained inside!</span>")
	else
		seal()
		to_chat(user, "<span class='warning'>[user] seals the [src].</span>")

/obj/item/antinoblium_container/update_icon()
	if(sealed)
		icon_state = "antinoblium_container_sealed"
	else if (shard)
		icon_state = "antinoblium_container_loaded"
	else
		icon_state = "antinoblium_container_empty"


/obj/item/antinoblium
	name = "antinoblium extraction tongs"
	desc = "A pair of tongs made from condensed hyper-noblium gas, searingly cold to the touch, that can safely grip an antinoblium shard."
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "antinoblium_tongs"
	toolspeed = 0.75
	damtype = "fire"
	///Store the shard object
	var/obj/item/supermatter_delaminator/antinoblium_shard/shard

/obj/item/antinoblium/Destroy()
	QDEL_NULL(shard)
	return ..()

/obj/item/antinoblium/update_icon()
	if(shard)
		icon_state = "antinoblium_tongs_loaded"
	else
		icon_state = "antinoblium_tongs"

/obj/item/antinoblium/afterattack(atom/O, mob/user, proximity)
	. = ..()
	if(!shard)
		return
	if(proximity && ismovable(O) && O != shard  && !istype(O, /obj/item/antinoblium_container) && !istype(O, /obj/machinery/power/supermatter_crystal))
		Consume(O, user)

/obj/item/antinoblium/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum) // no instakill supermatter javelins
	if(shard)
		shard.forceMove(loc)
		visible_message("<span class='notice'>\The [shard] falls out of \the [src] as it hits the ground.</span>")
		shard = null
		update_icon()
	return ..()

/obj/item/antinoblium/proc/Consume(atom/movable/AM, mob/user)
	if(ismob(AM))
		var/mob/victim = AM
		message_admins("[src] has consumed [key_name_admin(victim)] [ADMIN_JMP(src)].")
		message_admins("[ADMIN_LOOKUPFLW(user)] has used an antinoblium shard to commit dual suicide with [ADMIN_LOOKUPFLW(victim)] at [ADMIN_VERBOSEJMP(src)].")
		investigate_log("has consumed [key_name(victim)].", "supermatter")
		investigate_log("[key_name(user)] has used an antinoblium shard to commit dual suicide with [key_name(victim)].", "supermatter")
		victim.dust()
	else
		investigate_log("has consumed [AM].", "supermatter")
		qdel(AM)
	if (user)
		user.visible_message("<span class='danger'>As [user] touches [AM] with \the [src], both flash into dust and silence fills the room...</span>",\
			"<span class='userdanger'>You touch [AM] with [src], and everything suddenly goes silent.\n[AM] and [shard] flash into dust, and soon as you can register this, you do as well.</span>",\
			"<span class='italics'>Everything suddenly goes silent.</span>")
		message_admins("[src] has consumed [key_name_admin(user)] [ADMIN_JMP(src)].")
		investigate_log("has consumed [key_name(user)].", "supermatter")
		user.dust()
	radiation_pulse(src, 500, 2)
	empulse(src, 5, 10)
	playsound(src, 'sound/effects/supermatter.ogg', 50, 1)
	QDEL_NULL(shard)
	update_icon()

/obj/item/supermatter_corruptor
	name = "supermatter data corruptor bug"
	desc = "A small magnetic object that transfers viral payloads into the control structure it is attached to."
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "corruptor"
