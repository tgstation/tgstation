///Spawns a big, amped up fat anomaly
/obj/effect/spawner/random/big_anomaly
	name = "big anomaly spawner"
	icon_state = "big_anomaly"
	loot = list(
		/obj/effect/anomaly/pyro/big,
		/obj/effect/anomaly/flux/big,
		/obj/effect/anomaly/bluespace/big,
		/obj/effect/anomaly/grav/high/big
	)

///Spawns a stable anomally that doesnt drop cores and doesn't destroy or alter the environment
/obj/effect/spawner/random/environmentally_safe_anomaly
	name = "safe anomaly spawner"
	icon_state = "anomaly"
	loot = list(
		/obj/effect/anomaly/flux,
		/obj/effect/anomaly/bluespace,
		/obj/effect/anomaly/hallucination,
		/obj/effect/anomaly/bioscrambler/docile
	)

	///Do we anchor the anomaly? Set to true if you don't want anomalies drifting away (like if theyre in space or something)
	var/anchor_anomaly = FALSE

/obj/effect/spawner/random/environmentally_safe_anomaly/make_item(spawn_loc, type_path_to_make)
	. = ..()

	var/obj/effect/anomaly/anomaly = .
	anomaly.stabilize(anchor = anchor_anomaly, has_core = FALSE)

/obj/effect/spawner/random/environmentally_safe_anomaly/immobile
	name = "stationary safe anomaly spawner"
	icon_state = "anomaly_stationary"
	anchor_anomaly = TRUE

/obj/item/paper/fluff/ruins/anomaly_research/intro
	name = "revelation"
	default_raw_text = {"ANOMALIES?!??!?!? They're all too busy making armor, weapons and pointless toys with anomalies,
	<br> NONE OF THEM ARE TRYING TO FIGURE OUT THEIR TRUE NATURE! No one wonders why anomalies respond to radio signals and drop perfectly neat wrapped anomaly packages?
	<br> Some anomalies represent fundamental aspects of our universe: bluespace, gravity, flux, pyro, but what the fuck is a delimber anomaly supposed to be?
	<br> A fucking hallucination anomaly? Ghost anomaly??? Some of these don't make any sense at all. What are they hiding from us???????
	<br>
	<br> I took 20 of their anomaly cores, they weren't going to use them anyway. I law 2'd a cyborg to make me a space lab, my perfect empire. The poor borg.
	<br> I, DR ANNA MOLLY, WILL REVEAL THE TRUTH!!
	"}

/obj/item/paper/fluff/ruins/anomaly_research/stabilizer
	name = "stabilizer"
	default_raw_text = {"It's so sad anomalies aren't around much, usually leaving in a few minutes (barring some).
	<br> But it makes sense, if the anomalies are from different layers of reality,
	<br> and they're simply rubberbanding around, eventually being pulled back to where they belong. Unless they're cored.
	<br> BUT I DID IT!!! It was extremely difficult to obtain, but the null-fluid was the last component of the stabilizer.
	<br> Now that I can perform long-term studies of active anomalies, there's no limit to what I can achieve!!
	"}

/obj/item/paper/fluff/ruins/anomaly_research/mega_anomally
	name = "mega anomally"
	default_raw_text = {"It only took every single one of my anomalies and nearly my entire supply of stabilizers, but I did it.
	<br> I CREATED THE ULTIMATE SUPER ANOMALY!! I modified a modsuit with the nullfluid, which should allow me to enter it!
	<br> I dropped off Moffie at my mom's, in case I can't get back. If you're reading this, SUCK IT I'M IN THE ANOMALY UNIVERSE (or dead) HAHAHAHHA!!
	<br> Dr Anna Molly, signing out.
	"}

/area/misc/anomaly_research
	name = "Anomaly Research Facility"
	icon = 'icons/area/areas_ruins.dmi'
	icon_state = "anomaly_research"
	requires_power = FALSE
	area_flags = HIDDEN_AREA | UNIQUE_AREA
	has_gravity = TRUE

/obj/item/reagent_containers/cup/bottle/wittel
	name = "wittel bottle"
	list_reagents = list(/datum/reagent/wittel = 5)
