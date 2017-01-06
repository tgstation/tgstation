////////////////////
//Clusterbang
////////////////////
/obj/item/weapon/grenade/clusterbuster
	desc = "Use of this weapon may constiute a war crime in your area, consult your local captain."
	name = "clusterbang"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "clusterbang"
	var/payload = /obj/item/weapon/grenade/flashbang/cluster

/obj/item/weapon/grenade/clusterbuster/prime()
	update_mob()
	var/numspawned = rand(4,8)
	var/again = 0

	for(var/more = numspawned,more > 0,more--)
		if(prob(35))
			again++
			numspawned--

	for(var/loop = again ,loop > 0, loop--)
		new /obj/item/weapon/grenade/clusterbuster/segment(loc, payload)//Creates 'segments' that launches a few more payloads

	new /obj/effect/payload_spawner(loc, payload, numspawned)//Launches payload

	playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)

	qdel(src)


//////////////////////
//Clusterbang segment
//////////////////////
/obj/item/weapon/grenade/clusterbuster/segment
	desc = "A smaller segment of a clusterbang. Better run."
	name = "clusterbang segment"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "clusterbang_segment"

/obj/item/weapon/grenade/clusterbuster/segment/New(var/loc, var/payload_type = /obj/item/weapon/grenade/flashbang/cluster)
	..()
	icon_state = "clusterbang_segment_active"
	payload = payload_type
	active = 1
	walk_away(src,loc,rand(1,4))
	addtimer(CALLBACK(src, .proc/prime), rand(15,60))

/obj/item/weapon/grenade/clusterbuster/segment/prime()

	new /obj/effect/payload_spawner(loc, payload, rand(4,8))

	playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)

	qdel(src)

//////////////////////////////////
//The payload spawner effect
/////////////////////////////////
/obj/effect/payload_spawner/New(var/turf/newloc,var/type, var/numspawned as num)

	for(var/loop = numspawned ,loop > 0, loop--)
		var/obj/item/weapon/grenade/P = new type(loc)
		P.active = 1
		walk_away(P,loc,rand(1,4))

		spawn(rand(15,60))
			if(P && !qdeleted(P))
				P.prime()
			qdel(src)


//////////////////////////////////
//Custom payload clusterbusters
/////////////////////////////////
/obj/item/weapon/grenade/flashbang/cluster
	icon_state = "flashbang_active"

/obj/item/weapon/grenade/clusterbuster/emp
	name = "Electromagnetic Storm"
	payload = /obj/item/weapon/grenade/empgrenade

/obj/item/weapon/grenade/clusterbuster/smoke
	name = "Ninja Vanish"
	payload = /obj/item/weapon/grenade/smokebomb

/obj/item/weapon/grenade/clusterbuster/metalfoam
	name = "Instant Concrete"
	payload = /obj/item/weapon/grenade/chem_grenade/metalfoam

/obj/item/weapon/grenade/clusterbuster/inferno
	name = "Inferno"
	payload = /obj/item/weapon/grenade/chem_grenade/incendiary

/obj/item/weapon/grenade/clusterbuster/antiweed
	name = "RoundDown"
	payload = /obj/item/weapon/grenade/chem_grenade/antiweed

/obj/item/weapon/grenade/clusterbuster/cleaner
	name = "Mr. Proper"
	payload = /obj/item/weapon/grenade/chem_grenade/cleaner

/obj/item/weapon/grenade/clusterbuster/teargas
	name = "Oignon Grenade"
	payload = /obj/item/weapon/grenade/chem_grenade/teargas

/obj/item/weapon/grenade/clusterbuster/facid
	name = "Aciding Rain"
	payload = /obj/item/weapon/grenade/chem_grenade/facid

/obj/item/weapon/grenade/clusterbuster/syndieminibomb
	name = "SyndiWrath"
	payload = /obj/item/weapon/grenade/syndieminibomb

/obj/item/weapon/grenade/clusterbuster/spawner_manhacks
	name = "iViscerator"
	payload = /obj/item/weapon/grenade/spawnergrenade/manhacks

/obj/item/weapon/grenade/clusterbuster/spawner_spesscarp
	name = "Invasion of the Space Carps"
	payload = /obj/item/weapon/grenade/spawnergrenade/spesscarp

/obj/item/weapon/grenade/clusterbuster/soap
	name = "Slipocalypse"
	payload = /obj/item/weapon/grenade/spawnergrenade/syndiesoap

/obj/item/weapon/grenade/clusterbuster/clf3
	name = "WELCOME TO HELL"
	payload = /obj/item/weapon/grenade/chem_grenade/clf3


//random clusterbuster spawner
/obj/item/weapon/grenade/clusterbuster/random/New()
	var/real_type = pick(subtypesof(/obj/item/weapon/grenade/clusterbuster))
	new real_type(loc)
	qdel(src)
