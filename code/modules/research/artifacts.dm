//Part of ISaidNo's public release around July 2011(ish), multiple changes
//many thanks

/obj/machinery/artifact
	name = "alien artifact"
	desc = "A large alien device."
	icon = 'anomaly.dmi'
	icon_state = "ano0"
	anchored = 0
	density = 1
	var/origin = null          // Used in the randomisation/research of the artifact.
	var/activated = 0          // Whether or not the artifact has been unlocked.
	var/charged = 1            // Whether the artifact is ready to have it's effect.
	var/chargetime = 0         // How much time until the artifact is charged.
	var/recharge = 5           // How long does it take this artifact to recharge?
	var/display_id = ""        // Artifact ID to display once successfully scanned
	var/datum/artifact_effect/my_effect = null
	var/being_used = 0

/obj/machinery/artifact/New()
	..()
	// Origin and appearance randomisation
	// cael - need some more icons

	my_effect = new()

	src.origin = pick("ancient","martian","wizard","eldritch","precursor")
	switch(src.origin)
		if("ancient") src.icon_state = pick("ano2")
		if("martian") src.icon_state = pick("ano4")
		if("wizard") src.icon_state = pick("ano0","ano1")
		if("eldritch") src.icon_state = pick("ano3")
		if("precursor") src.icon_state = pick("ano5")

	// Low-ish random chance to not look like it's origin
	if(prob(20)) src.icon_state = pick("ano0","ano1","ano2","ano3","ano4","ano5")

	// Power randomisation
	my_effect.trigger = pick("force","energy","chemical","heat","touch")
	if (my_effect.trigger == "chemical") my_effect.triggerX = pick("hydrogen","corrosive","volatile","toxic")

	// Ancient Artifacts focus on robotic/technological effects
	// Martian Artifacts focus on biological effects
	// Wizard Artifacts focus on weird shit
	// Eldritch Artifacts are 100% bad news
	// Precursor Artifacts do everything
	switch(src.origin)
		if("ancient") my_effect.effecttype = pick("roboheal","robohurt","cellcharge","celldrain")
		if("martian") my_effect.effecttype = pick("healing","injure","stun","planthelper")
		if("wizard") my_effect.effecttype = pick("stun","forcefield","teleport")
		if("eldritch") my_effect.effecttype = pick("injure","stun","robohurt","celldrain")
		if("precursor") my_effect.effecttype = pick("healing","injure","stun","roboheal","robohurt","cellcharge","celldrain","planthelper","forcefield","teleport")

	// Select range based on the power
	var/canworldpulse = 1
	switch(my_effect.effecttype)
		if("healing") my_effect.effectmode = pick("aura","pulse","contact")
		if("injure") my_effect.effectmode = pick("aura","pulse","contact")
		if("stun") my_effect.effectmode = pick("aura","pulse","contact")
		if("roboheal") my_effect.effectmode = pick("aura","pulse","contact")
		if("robohurt") my_effect.effectmode = pick("aura","pulse","contact")
		if("cellcharge") my_effect.effectmode = pick("aura","pulse")
		if("celldrain") my_effect.effectmode = pick("aura","pulse")
		if("planthelper")
			my_effect.effectmode = pick("aura","pulse")
			canworldpulse = 0
		if("forcefield")
			my_effect.effectmode = "contact"
			canworldpulse = 0
		if("teleport") my_effect.effectmode = pick("pulse","contact")

	// Recharge timer & range setup
	if (my_effect.effectmode == "aura")
		my_effect.aurarange = rand(1,4)
	if (my_effect.effectmode == "contact")
		src.recharge = rand(5,15)
	if (my_effect.effectmode == "pulse")
		my_effect.aurarange = rand(2,14)
		src.recharge = rand(5,20)
	if (canworldpulse == 1 && prob(1))
		my_effect.effectmode = "worldpulse"
		src.recharge = rand(40,120)

	display_id += pick("kappa","sigma","antaeres","beta","lorard","omicron","iota","upsilon","omega","gamma","delta")
	display_id += "-"
	display_id += num2text(rand(100,999))

/obj/machinery/artifact/attack_hand(var/mob/user as mob)
	if (istype(user, /mob/living/silicon/ai) || istype(user, /mob/dead/)) return
	if (istype(user, /mob/living/silicon/robot))
		if (get_dist(user, src) > 1)
			user << "\red You can't reach [src] from here."
			return
	if(istype(user:gloves,/obj/item/clothing/gloves))
		return ..()
	for(var/mob/O in viewers(src, null))
		O.show_message(text("<b>[]</b> touches [].", user, src), 1)
	src.add_fingerprint(user)
	src.Artifact_Contact(user)

/obj/machinery/artifact/attackby(obj/item/weapon/W as obj, mob/living/user as mob)
	/*if (istype(W, /obj/item/weapon/cargotele))
		W:cargoteleport(src, user)
		return*/
	if (my_effect.trigger == "chemical" && istype(W, /obj/item/weapon/reagent_containers/))
		switch(my_effect.triggerX)
			if("hydrogen")
				if (W.reagents.has_reagent("hydrogen", 1) || W.reagents.has_reagent("water", 1))
					src.Artifact_Activate()
					return
			if("corrosive")
				if (W.reagents.has_reagent("acid", 1) || W.reagents.has_reagent("pacid", 1) || W.reagents.has_reagent("diethylamine", 1))
					src.Artifact_Activate()
					return
			if("volatile")
				if (W.reagents.has_reagent("plasma", 1) || W.reagents.has_reagent("thermite", 1))
					src.Artifact_Activate()
					return
			if("toxic")
				if (W.reagents.has_reagent("toxin", 1) || W.reagents.has_reagent("cyanide", 1) || W.reagents.has_reagent("amanitin", 1) || W.reagents.has_reagent("neurotoxin", 1))
					src.Artifact_Activate()
					return
	..()
	if (my_effect.trigger == "force" && W.force >= 10 && !src.activated) src.Artifact_Activate()
	if (my_effect.trigger == "energy")
		if (istype(W,/obj/item/weapon/melee/baton) && W:status) src.Artifact_Activate()
		if (istype(W,/obj/item/weapon/melee/energy)) src.Artifact_Activate()
		if (istype(W,/obj/item/weapon/melee/cultblade)) src.Artifact_Activate()
		if (istype(W,/obj/item/weapon/gun/energy/)) src.Artifact_Activate()
		if (istype(W,/obj/item/device/multitool)) src.Artifact_Activate()
		if (istype(W,/obj/item/weapon/card/emag)) src.Artifact_Activate()
	if (my_effect.trigger == "heat")
		if (istype(W,/obj/item/weapon/match) && W:lit) src.Artifact_Activate()
		if (istype(W, /obj/item/weapon/weldingtool) && W:welding) src.Artifact_Activate()
		if (istype(W, /obj/item/weapon/lighter) && W:lit) src.Artifact_Activate()

	//Bump(atom/A)

/obj/machinery/artifact/Bumped(M as mob|obj)
	if (istype(M,/obj/item/weapon/) && my_effect.trigger == "force" && M:throwforce >= 10) src.Artifact_Activate()

/obj/machinery/artifact/bullet_act(var/obj/item/projectile/P)
	if (my_effect.trigger == "force")
		if(istype(P,/obj/item/projectile/bullet)) src.Artifact_Activate()
		else if(istype(P,/obj/item/projectile/hivebotbullet)) src.Artifact_Activate()
	if (my_effect.trigger == "energy")
		if(istype(P,/obj/item/projectile/beam)) src.Artifact_Activate()
		else if(istype(P,/obj/item/projectile/ion)) src.Artifact_Activate()
		else if(istype(P,/obj/item/projectile/energy)) src.Artifact_Activate()
		else if(istype(P,/obj/item/projectile/bluetag)) src.Artifact_Activate()
		else if(istype(P,/obj/item/projectile/redtag)) src.Artifact_Activate()
	if (my_effect.trigger == "heat")
		if(istype(P,/obj/item/projectile/temp)) src.Artifact_Activate()

/obj/machinery/artifact/ex_act(severity)
	switch(severity)
		if(1.0) del src
		if(2.0)
			if (prob(50)) del src
			if (my_effect.trigger == "force") src.Artifact_Activate()
			if (my_effect.trigger == "heat") src.Artifact_Activate()
		if(3.0)
			if (my_effect.trigger == "force") src.Artifact_Activate()
			if (my_effect.trigger == "heat") src.Artifact_Activate()
	return

/obj/machinery/artifact/temperature_expose(null, temp, volume)
	if (my_effect.trigger == "heat") src.Artifact_Activate()

/obj/machinery/artifact/process()
	if (!src.activated)
		return
	if (chargetime > 0)
		chargetime -= 1
	else
		src.charged = 1
		my_effect.HaltEffect(src.loc)

	my_effect.UpdateEffect(src.loc)

	//activate
	if(src.charged && my_effect.DoEffect(src))
		src.charged = 0
		src.chargetime = src.recharge

/obj/machinery/artifact/proc/Artifact_Activate()
	src.activated = !src.activated
	var/display_msg = ""
	if(activated)
		switch(rand(4))
			if(0)
				display_msg = "momentarily glows brightly!"
			if(1)
				display_msg = "distorts slightly for a moment!"
			if(2)
				display_msg = "makes a slightly clicking noise!"
			if(3)
				display_msg = "flickers slightly!"
			if(4)
				display_msg = "vibrates!"
	else
		switch(rand(2))
			if(0)
				display_msg = "grows dull!"
			if(1)
				display_msg = "fades in intensity!"
			if(2)
				display_msg = "suddenly becomes very quiet!"

	for(var/mob/O in viewers(src, null))
		O.show_message(text("<b>[]</b> [display_msg]", src), 1)

/obj/machinery/artifact/proc/Artifact_Contact(var/mob/user as mob)
	// Trigger Code
	if (istype (user,/mob/living/carbon/) && my_effect.trigger == "touch" && !src.activated) src.Artifact_Activate()
	else if (my_effect.trigger != "touch" && !src.activated) user << "Nothing happens."

	if (my_effect.effectmode == "contact" && src.activated && src.charged)
		my_effect.DoEffect(src)
		src.charged = 0
		src.chargetime = src.recharge

// this was used in QM for a time but it fell into disuse and wasn't removed, the purpose being to check if an artifact
// was benevolent or malicious, to determine whether QMs would be paid or punished for shipping it

/proc/artifact_checkgood(var/datum/artifact_effect/A)
	switch(A.effecttype)
		if("healing") return 1
		if("injure") return 0
		if("stun") return 0
		if("roboheal") return 1
		if("robohurt") return 0
		if("cellcharge") return 1
		if("celldrain") return 1
		if("planthelper") return 1
		if("forcefield") return 1
		if("teleport") return 0