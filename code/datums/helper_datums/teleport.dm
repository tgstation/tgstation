//wrapper
/proc/do_teleport(ateleatom, adestination, aprecision=0, afteleport=1, aeffectin=null, aeffectout=null, asoundin=null, asoundout=null)
	new /datum/teleport/instant/science(arglist(args))
	return

/datum/teleport
	var/atom/movable/teleatom //atom to teleport
	var/atom/destination //destination to teleport to
	var/precision = 0 //teleport precision
	var/datum/effect/effect/system/effectin //effect to show right before teleportation
	var/datum/effect/effect/system/effectout //effect to show right after teleportation
	var/soundin //soundfile to play before teleportation
	var/soundout //soundfile to play after teleportation
	var/force_teleport = 1 //if false, teleport will use Move() proc (dense objects will prevent teleportation)


	New(ateleatom, adestination, aprecision=0, afteleport=1, aeffectin=null, aeffectout=null, asoundin=null, asoundout=null)
		..()
		if(!Init(arglist(args)))
			return 0
		return 1

	proc/Init(ateleatom,adestination,aprecision,afteleport,aeffectin,aeffectout,asoundin,asoundout)
		if(!setTeleatom(ateleatom))
			return 0
		if(!setDestination(adestination))
			return 0
		if(!setPrecision(aprecision))
			return 0
		setEffects(aeffectin,aeffectout)
		setForceTeleport(afteleport)
		setSounds(asoundin,asoundout)
		return 1

	//must succeed
	proc/setPrecision(aprecision)
		if(isnum(aprecision))
			precision = aprecision
			return 1
		return 0

	//must succeed
	proc/setDestination(atom/adestination)
		if(istype(adestination))
			destination = adestination
			return 1
		return 0

	//must succeed in most cases
	proc/setTeleatom(atom/movable/ateleatom)
		if(istype(ateleatom, /obj/effect) && !istype(ateleatom, /obj/effect/dummy/chameleon))
			del(ateleatom)
			return 0
		if(istype(ateleatom))
			teleatom = ateleatom
			return 1
		return 0

	//custom effects must be properly set up first for instant-type teleports
	//optional
	proc/setEffects(datum/effect/effect/system/aeffectin=null,datum/effect/effect/system/aeffectout=null)
		effectin = istype(aeffectin) ? aeffectin : null
		effectout = istype(aeffectout) ? aeffectout : null
		return 1

	//optional
	proc/setForceTeleport(afteleport)
		force_teleport = afteleport
		return 1

	//optional
	proc/setSounds(asoundin=null,asoundout=null)
		soundin = isfile(asoundin) ? asoundin : null
		soundout = isfile(asoundout) ? asoundout : null
		return 1

	//placeholder
	proc/teleportChecks()
		return 1

	proc/playSpecials(atom/location,datum/effect/effect/system/effect,sound)
		if(location)
			if(effect)
				spawn(-1)
					src = null
					effect.attach(location)
					effect.start()
			if(sound)
				spawn(-1)
					src = null
					playsound(location,sound,60,1)
		return

	//do the monkey dance
	proc/doTeleport()

		var/turf/destturf
		var/turf/curturf = get_turf(teleatom)
		var/area/destarea = get_area(destination)
		if(precision)
			var/list/posturfs = circlerangeturfs(destination,precision)
			destturf = safepick(posturfs)
		else
			destturf = get_turf(destination)

		if(!destturf || !curturf)
			return 0

		playSpecials(curturf,effectin,soundin)

		if(force_teleport)
			teleatom.forceMove(destturf)
			playSpecials(destturf,effectout,soundout)
		else
			if(teleatom.Move(destturf))
				playSpecials(destturf,effectout,soundout)

		destarea.Entered(teleatom)

		return 1

	proc/teleport()
		if(teleportChecks())
			return doTeleport()
		return 0

/datum/teleport/instant //teleports when datum is created

	New(ateleatom, adestination, aprecision=0, afteleport=1, aeffectin=null, aeffectout=null, asoundin=null, asoundout=null)
		if(..())
			teleport()
		return


/datum/teleport/instant/science

	setEffects(datum/effect/effect/system/aeffectin,datum/effect/effect/system/aeffectout)
		if(!aeffectin || !aeffectout)
			var/datum/effect/effect/system/spark_spread/aeffect = new
			aeffect.set_up(5, 1, teleatom)
			effectin = effectin || aeffect
			effectout = effectout || aeffect
			return 1
		else
			return ..()

	setPrecision(aprecision)
		..()
		if(istype(teleatom, /obj/item/weapon/storage/backpack/holding))
			precision = rand(1,100)

		var/list/bagholding = teleatom.search_contents_for(/obj/item/weapon/storage/backpack/holding)
		if(bagholding.len)
			precision = max(rand(1,100)*bagholding.len,100)
			if(istype(teleatom, /mob/living))
				var/mob/living/MM = teleatom
				MM << "\red The Bluespace interface on your Bag of Holding interferes with the teleport!"
		return 1

	teleportChecks()
		if(istype(teleatom, /obj/item/weapon/disk/nuclear)) // Don't let nuke disks get teleported --NeoFite
			teleatom.visible_message("\red <B>The [teleatom] bounces off of the portal!</B>")
			return 0
		if(!isemptylist(teleatom.search_contents_for(/obj/item/weapon/disk/nuclear)))
			if(istype(teleatom, /mob/living))
				var/mob/living/MM = teleatom
				MM.visible_message("\red <B>The [MM] bounces off of the portal!</B>","\red Something you are carrying seems to be unable to pass through the portal. Better drop it if you want to go through.")
			else
				teleatom.visible_message("\red <B>The [teleatom] bounces off of the portal!</B>")
			return 0
		if(destination.z > 7)
			return 0
		return 1