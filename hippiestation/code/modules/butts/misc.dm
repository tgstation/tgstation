/mob/living/carbon/proc/regeneratebutt()
	if(!getorganslot("butt"))
		if(ishuman(src) || ismonkey(src))
			var/obj/item/organ/butt/B = new()
			B.Insert(src)
		if(isalien(src))
			var/obj/item/organ/butt/xeno/X = new()
			X.Insert(src)

/obj/effect/immovablerod/butt
	name = "enormous ass"
	desc = "godDAMN that ass is well rounded"
	icon = 'hippiestation/icons/obj/butts.dmi'
	icon_state = "butt"

/obj/effect/immovablerod/butt/Initialize()
	. = ..()
	SpinAnimation(24,-1)

/obj/item/clothing/proc/checkbuttuniform(mob/user)
	var/obj/item/organ/butt/B = user.getorgan(/obj/item/organ/butt)
	if(B)
		var/obj/item/weapon/storage/internal/pocket/butt/pocket = B.inv
		if(pocket)
			pocket.close_all()
