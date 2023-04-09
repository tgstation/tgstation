#define RABBIT_CD_TIME (30 SECONDS)

/obj/item/clothing/head/hats/tophat
	name = "top-hat"
	desc = "It's an amish looking hat."
	icon_state = "tophat"
	inhand_icon_state = "that"
	dog_fashion = /datum/dog_fashion/head
	throwforce = 1
	/// Cooldown for how often we can pull rabbits out of here
	COOLDOWN_DECLARE(rabbit_cooldown)

/obj/item/clothing/head/hats/tophat/attackby(obj/item/hitby_item, mob/user, params)
	. = ..()
	if(istype(hitby_item, /obj/item/gun/magic/wand))
		abracadabra(hitby_item, user)

/obj/item/clothing/head/hats/tophat/proc/abracadabra(obj/item/hitby_wand, mob/magician)
	if(!COOLDOWN_FINISHED(src, rabbit_cooldown))
		to_chat(magician, span_warning("You can't find another rabbit in [src]! Seems another hasn't gotten lost in there yet..."))
		return

	COOLDOWN_START(src, rabbit_cooldown, RABBIT_CD_TIME)
	playsound(get_turf(src), 'sound/weapons/emitter.ogg', 70)
	do_smoke(amount = DIAMOND_AREA(1), holder = src, location = src, smoke_type=/obj/effect/particle_effect/fluid/smoke/quick)

	if(prob(10))
		magician.visible_message(span_danger("[magician] taps [src] with [hitby_wand], then reaches in and pulls out a bu- wait, those are bees!"), span_danger("You tap [src] with your [hitby_wand.name] and pull out... <b>BEES!</b>"))
		var/wait_how_many_bees_did_that_guy_pull_out_of_his_hat = rand(4, 8)
		for(var/b in 1 to wait_how_many_bees_did_that_guy_pull_out_of_his_hat)
			var/mob/living/simple_animal/hostile/bee/barry = new(get_turf(magician))
			barry.GiveTarget(magician)
			if(prob(20))
				barry.say(pick("BUZZ BUZZ", "PULLING A RABBIT OUT OF A HAT IS A TIRED TROPE", "I DIDN'T ASK TO BEE HERE"), forced = "bee hat")
	else
		magician.visible_message(span_notice("[magician] taps [src] with [hitby_wand], then reaches in and pulls out a bunny! Cute!"), span_notice("You tap [src] with your [hitby_wand.name] and pull out a cute bunny!"))
		var/mob/living/basic/rabbit/bunbun = new(get_turf(magician))
		bunbun.mob_try_pickup(magician, instant=TRUE)

#undef RABBIT_CD_TIME
