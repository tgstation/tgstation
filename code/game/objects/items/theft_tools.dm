//Items for nuke theft, supermatter theft traitor objective


// STEALING THE NUKE

//the nuke core - objective item
/obj/item/nuke_core
	name = "plutonium core"
	desc = "Extremely radioactive. Wear goggles."
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "plutonium_core"
	inhand_icon_state = "plutoniumcore"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/pulse = 0
	var/cooldown = 0
	var/pulseicon = "plutonium_core_pulse"

/obj/item/nuke_core/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/nuke_core/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/nuke_core/attackby(obj/item/nuke_core_container/container, mob/user)
	if(istype(container))
		container.load(src, user)
	else
		return ..()

/obj/item/nuke_core/process()
	if(cooldown < world.time - 60)
		cooldown = world.time
		flick(pulseicon, src)
		radiation_pulse(src, max_range = 2, threshold = RAD_EXTREME_INSULATION)

/obj/item/nuke_core/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is rubbing [src] against [user.p_them()]self! It looks like [user.p_theyre()] trying to commit suicide!"))
	return TOXLOSS

//nuke core box, for carrying the core
/obj/item/nuke_core_container
	name = "nuke core container"
	desc = "Solid container for radioactive objects."
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "core_container_empty"
	inhand_icon_state = "tile"
	lefthand_file = 'icons/mob/inhands/items/tiles_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/tiles_righthand.dmi'
	var/obj/item/nuke_core/core

/obj/item/nuke_core_container/Destroy()
	QDEL_NULL(core)
	return ..()

/obj/item/nuke_core_container/proc/load(obj/item/nuke_core/ncore, mob/user)
	if(core || !istype(ncore))
		return FALSE
	ncore.forceMove(src)
	core = ncore
	icon_state = "core_container_loaded"
	to_chat(user, span_warning("Container is sealing..."))
	addtimer(CALLBACK(src, PROC_REF(seal)), 50)
	return TRUE

/obj/item/nuke_core_container/proc/seal()
	if(istype(core))
		STOP_PROCESSING(SSobj, core)
		icon_state = "core_container_sealed"
		playsound(src, 'sound/items/deconstruct.ogg', 60, TRUE)
		if(ismob(loc))
			to_chat(loc, span_warning("[src] is permanently sealed, [core]'s radiation is contained."))

/obj/item/nuke_core_container/attackby(obj/item/nuke_core/core, mob/user)
	if(istype(core))
		if(!user.temporarilyRemoveItemFromInventory(core))
			to_chat(user, span_warning("The [core] is stuck to your hand!"))
			return
		else
			load(core, user)
	else
		return ..()

//snowflake screwdriver, works as a key to start nuke theft, traitor only
/obj/item/screwdriver/nuke
	name = "screwdriver"
	desc = "A screwdriver with an ultra thin tip that's carefully designed to boost screwing speed."
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "screwdriver_nuke"
	inhand_icon_state = "screwdriver_nuke"
	toolspeed = 0.5
	random_color = FALSE
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null

/obj/item/screwdriver/nuke/get_belt_overlay()
	return mutable_appearance('icons/obj/clothing/belt_overlays.dmi', "screwdriver_nuke")

/obj/item/paper/guides/antag/nuke_instructions
	default_raw_text = "How to break into a Nanotrasen self-destruct terminal and remove its plutonium core:<br>\
	<ul>\
	<li>Use a screwdriver with a very thin tip (provided) to unscrew the terminal's front panel</li>\
	<li>Dislodge and remove the front panel with a crowbar</li>\
	<li>Cut the inner metal plate with a welding tool</li>\
	<li>Pry off the inner plate with a crowbar to expose the radioactive core</li>\
	<li>Use the core container to remove the plutonium core; the container will take some time to seal</li>\
	<li>???</li>\
	</ul>"

/obj/item/paper/guides/antag/hdd_extraction
	default_raw_text = "<h1>Source Code Theft & You - The Idiot's Guide to Crippling Nanotrasen Research & Development</h1><br>\
	Rumour has it that Nanotrasen are using their R&D Servers to create something awful! They've codenamed it Project Goon, whatever that means.<br>\
	This cannot be allowed to stand. Below is all our intel for stealing their source code and crippling their research efforts:<br>\
	<ul>\
	<li>Locate the physical R&D Server mainframes. Intel suggests these are stored in specially cooled rooms deep within their Science department.</li>\
	<li>Nanotrasen is a corporation not known for subtlety in design. You should be able to identify the master server by any distinctive markings.</li>\
	<li>Tools are on-site procurement. Screwdriver, crowbar and wirecutters should be all you need to do the job.<li>\
	<li>The front panel screws are hidden in recesses behind stickers. Easily removed once you know they're there.</li>\
	<li>You'll probably find the hard drive in secure housing. You may need to pry it loose with a crowbar, shouldn't do too much damage.</li>\
	<li>Finally, carefully cut all of the hard drive's connecting wires. Don't rush this, snipping the wrong wire could wipe all data!</li>\
	</ul>\
	Removing this drive is guaranteed to cripple research efforts regardless of what data is contained on it.<br>\
	The thing's probably hardwired. No putting it back once you've extracted it. The crew are likely to be as mad as bees if they find out!<br>\
	Survive the shift and extract the hard drive safely.<br>\
	Succeed and you will receive a coveted green highlight on your record for this assignment. Fail us and red's the last colour you'll ever see.<br>\
	Do not disappoint us.<br>"

/obj/item/computer_disk/hdd_theft
	name = "r&d server hard disk drive"
	desc = "For some reason, people really seem to want to steal this. The source code on this drive is probably used for something awful!"
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "something_awful"
	max_capacity = 512
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

// STEALING SUPERMATTER

/obj/item/paper/guides/antag/supermatter_sliver
	default_raw_text = "How to safely extract a supermatter sliver:<br>\
	<ul>\
	<li>You must have active magnetic anchoring at all times near an active supermatter crystal.</li>\
	<li>Approach an active supermatter crystal with radiation shielded personal protective equipment. DO NOT MAKE PHYSICAL CONTACT.</li>\
	<li>Use a supermatter scalpel (provided) to slice off a sliver of the crystal.</li>\
	<li>Use supermatter extraction tongs (also provided) to safely pick up the sliver you sliced off.</li>\
	<li>Physical contact of any object with the sliver will dust the object, as well as yourself.</li>\
	<li>Use the tongs to place the sliver into the provided container, which will take some time to seal.</li>\
	<li>Get the hell out before the crystal delaminates.</li>\
	<li>???</li>\
	</ul>"

/obj/item/nuke_core/supermatter_sliver
	name = "supermatter sliver"
	desc = "A tiny, highly volatile sliver of a supermatter crystal. Do not handle without protection!"
	icon_state = "supermatter_sliver"
	inhand_icon_state = null //touching it dusts you, so no need for an inhand icon.
	pulseicon = "supermatter_sliver_pulse"
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE_UPPER


/obj/item/nuke_core/supermatter_sliver/attack_tk(mob/user) // no TK dusting memes
	return


/obj/item/nuke_core/supermatter_sliver/can_be_pulled(user) // no drag memes
	return FALSE

/obj/item/nuke_core/supermatter_sliver/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/hemostat/supermatter))
		var/obj/item/hemostat/supermatter/tongs = W
		if (tongs.sliver)
			to_chat(user, span_warning("\The [tongs] is already holding a supermatter sliver!"))
			return FALSE
		forceMove(tongs)
		tongs.sliver = src
		tongs.update_appearance()
		to_chat(user, span_notice("You carefully pick up [src] with [tongs]."))
	else if(istype(W, /obj/item/scalpel/supermatter) || istype(W, /obj/item/nuke_core_container/supermatter/)) // we don't want it to dust
		return
	else
		to_chat(user, span_notice("As it touches \the [src], both \the [src] and \the [W] burst into dust!"))
		radiation_pulse(user, max_range = 2, threshold = RAD_EXTREME_INSULATION, chance = 40)
		playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
		qdel(W)
		qdel(src)

/obj/item/nuke_core/supermatter_sliver/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!isliving(hit_atom))
		return ..()
	var/mob/living/victim = hit_atom
	if(victim.incorporeal_move || victim.status_flags & GODMODE) //try to keep this in sync with supermatter's consume fail conditions
		return ..()
	if(throwingdatum?.thrower)
		var/mob/user = throwingdatum.thrower
		log_combat(throwingdatum?.thrower, hit_atom, "consumed", src)
		message_admins("[src] has consumed [key_name_admin(victim)] [ADMIN_JMP(src)], thrown by [key_name_admin(user)].")
		investigate_log("has consumed [key_name(victim)], thrown by [key_name(user)]", INVESTIGATE_ENGINE)
	else
		message_admins("[src] has consumed [key_name_admin(victim)] [ADMIN_JMP(src)] via throw impact.")
		investigate_log("has consumed [key_name(victim)] via throw impact.", INVESTIGATE_ENGINE)
	victim.visible_message(span_danger("As [victim] is hit by [src], both flash into dust and silence fills the room..."),\
		span_userdanger("You're hit by [src] and everything suddenly goes silent.\n[src] flashes into dust, and soon as you can register this, you do as well."),\
		span_hear("Everything suddenly goes silent."))
	victim.investigate_log("has been dusted by [src].", INVESTIGATE_DEATHS)
	victim.dust()
	radiation_pulse(src, max_range = 2, threshold = RAD_EXTREME_INSULATION, chance = 40)
	playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
	qdel(src)

/obj/item/nuke_core/supermatter_sliver/pickup(mob/living/user)
	..()
	if(!isliving(user) || user.status_flags & GODMODE) //try to keep this in sync with supermatter's consume fail conditions
		return FALSE
	user.visible_message(span_danger("[user] reaches out and tries to pick up [src]. [user.p_their()] body starts to glow and bursts into flames before flashing into dust!"),\
			span_userdanger("You reach for [src] with your hands. That was dumb."),\
			span_hear("Everything suddenly goes silent."))
	radiation_pulse(user, max_range = 2, threshold = RAD_EXTREME_INSULATION, chance = 40)
	playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
	user.investigate_log("has been dusted by [src].", INVESTIGATE_DEATHS)
	user.dust()

/obj/item/nuke_core_container/supermatter
	name = "supermatter bin"
	desc = "A tiny receptacle that releases an inert hyper-noblium mix upon sealing, allowing a sliver of a supermatter crystal to be safely stored."
	var/obj/item/nuke_core/supermatter_sliver/sliver

/obj/item/nuke_core_container/supermatter/Destroy()
	QDEL_NULL(sliver)
	return ..()

/obj/item/nuke_core_container/supermatter/load(obj/item/hemostat/supermatter/T, mob/user)
	if(!istype(T) || !T.sliver)
		return FALSE
	T.sliver.forceMove(src)
	sliver = T.sliver
	T.sliver = null
	T.icon_state = "supermatter_tongs"
	icon_state = "core_container_loaded"
	to_chat(user, span_warning("Container is sealing..."))
	addtimer(CALLBACK(src, PROC_REF(seal)), 50)
	return TRUE

/obj/item/nuke_core_container/supermatter/seal()
	if(istype(sliver))
		STOP_PROCESSING(SSobj, sliver)
		icon_state = "core_container_sealed"
		playsound(src, 'sound/items/Deconstruct.ogg', 60, TRUE)
		if(ismob(loc))
			to_chat(loc, span_warning("[src] is permanently sealed, [sliver] is safely contained."))

/obj/item/nuke_core_container/supermatter/attackby(obj/item/hemostat/supermatter/tongs, mob/user)
	if(istype(tongs))
		//try to load shard into core
		load(tongs, user)
	else
		return ..()

/obj/item/scalpel/supermatter
	name = "supermatter scalpel"
	desc = "A scalpel with a fragile tip of condensed hyper-noblium gas, searingly cold to the touch, that can safely shave a sliver off a supermatter crystal."
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "supermatter_scalpel"
	toolspeed = 0.5
	damtype = BURN
	usesound = 'sound/weapons/bladeslice.ogg'
	var/usesLeft

/obj/item/scalpel/supermatter/Initialize(mapload)
	. = ..()
	usesLeft = rand(2, 4)

/obj/item/hemostat/supermatter
	name = "supermatter extraction tongs"
	desc = "A pair of tongs made from condensed hyper-noblium gas, searingly cold to the touch, that can safely grip a supermatter sliver."
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "supermatter_tongs"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	inhand_icon_state = "supermatter_tongs"
	toolspeed = 0.75
	damtype = BURN
	var/obj/item/nuke_core/supermatter_sliver/sliver

/obj/item/hemostat/supermatter/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/hemostat/supermatter/Destroy()
	QDEL_NULL(sliver)
	return ..()

/obj/item/hemostat/supermatter/update_icon_state()
	icon_state = "supermatter_tongs[sliver ? "_loaded" : null]"
	inhand_icon_state = "supermatter_tongs[sliver ? "_loaded" : null]"
	return ..()

/obj/item/hemostat/supermatter/afterattack(atom/O, mob/user, proximity)
	. = ..()
	if(!sliver)
		return
	if (!proximity)
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	if(ismovable(O) && O != sliver)
		Consume(O, user)
	return .

/obj/item/hemostat/supermatter/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum) // no instakill supermatter javelins
	if(sliver)
		sliver.forceMove(loc)
		visible_message(span_notice("\The [sliver] falls out of \the [src] as it hits the ground."))
		sliver = null
		update_appearance()
	return ..()

/obj/item/hemostat/supermatter/proc/Consume(atom/movable/AM, mob/living/user)
	if(ismob(AM))
		if(!isliving(AM))
			return
		var/mob/living/victim = AM
		if(victim.incorporeal_move || victim.status_flags & GODMODE) //try to keep this in sync with supermatter's consume fail conditions
			return
		victim.investigate_log("has been dusted by [src].", INVESTIGATE_DEATHS)
		victim.dust()
		message_admins("[src] has consumed [key_name_admin(victim)] [ADMIN_JMP(src)].")
		investigate_log("has consumed [key_name(victim)].", INVESTIGATE_ENGINE)
	else if(istype(AM, /obj/singularity))
		return
	else
		investigate_log("has consumed [AM].", INVESTIGATE_ENGINE)
		qdel(AM)
	if (user)
		log_combat(user, AM, "consumed", sliver, "via [src]")
		user.visible_message(span_danger("As [user] touches [AM] with \the [src], both flash into dust and silence fills the room..."),\
			span_userdanger("You touch [AM] with [src], and everything suddenly goes silent.\n[AM] and [sliver] flash into dust, and soon as you can register this, you do as well."),\
			span_hear("Everything suddenly goes silent."))
		user.investigate_log("has been dusted by [src].", INVESTIGATE_DEATHS)
		user.dust()
	radiation_pulse(src, max_range = 2, threshold = RAD_EXTREME_INSULATION, chance = 40)
	playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
	QDEL_NULL(sliver)
	update_appearance()
