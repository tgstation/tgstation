/obj/machinery/deep_synthesizer
	name = "deep synthesizer"
	desc = "Harnesses the power of a fluescent anomaly for creating massive amounts of chemicals."

	icon = 'icons/obj/machines/fat_sucker.dmi'
	icon_state = "fat"

	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	active_power_usage = 1000
	power_channel = EQUIP

	density = TRUE

	var/obj/item/assembly/signaler/anomaly/fluid/anomaly

	var/volume = 1000
	var/speed = 100


/obj/machinery/deep_synthesizer/Initialize()
	. = ..()

	create_reagents(volume)
	AddComponent(/datum/component/plumbing/simple_supply, anchored)

/obj/machinery/deep_synthesizer/process()
	if(anomaly && reagents.total_volume < reagents.volume)
		use_power(active_power_usage)
		reagents.add_reagent(anomaly.reagent_type, speed)
		playsound(src, "empulse", 100, TRUE)

/obj/machinery/deep_synthesizer/attackby(obj/item/I, mob/living/user, params)
	. = ..()

	if(istype(I, obj/item/assembly/signaler/anomaly/fluid) && user.dropItemToGround(I))
		I.forceMove(src)
		anomaly = I
		playsound(loc, 'sound/machines/click.ogg', 15, TRUE







