/obj/item/weapon/chisel
	name = "chisel"
	desc = "A tool for engraving"

	icon = 'icons/obj/items.dmi'
	icon_state = "chisel"

	m_amt = 120

	flags = FPRINT | TABLEPASS| CONDUCT

	var/use_name

/obj/item/weapon/chisel/attack_self(mob/user as mob)
	use_name = !use_name
	if(use_name)
		user << "You will now sign your work."
	else
		user << "You will no longer sign your work."

/obj/item/weapon/chisel/attack(mob/M as mob, mob/user as mob)
	if(istype(M, /mob/living/simple_animal/sculpture))
		var/engraving = sanitize(input(usr, "What do you want to write on the [M.real_name]?"))
		var/turf/ST = user.loc

		sleep( 10 + length(engraving) * 10)

		if( !(user.loc == ST && user.get_active_hand() == src) ) return
		if( !istype(M, /mob/living/simple_animal/sculpture) || !user || !src || !M ) return

		M.desc += engraving

/obj/item/weapon/chisel/afterattack(atom/target, mob/user as mob, proximity)
	if(!proximity) return
	if(istype(target,/turf/simulated/wall))
		var/turf/simulated/wall/W = target
		W.add_fingerprint(user)
		if(!W.engraving)
			var/engraving_name = sanitize(input(usr, "Depicted on the wall is an image of ...","Engraving"))
			var/engraving = sanitize(input(usr, "Enter the details of your engraving.","Engraving"))

			user.visible_message("\blue [user.name] starts engraving something on the [W.name].", "\blue You start engraving an image of [engraving_name] on the [W.name].")
			var/turf/T = user.loc
			sleep(60)
			if( !(user.loc == T && user.get_active_hand() == src) ) return
			if( !istype(W, /turf/simulated/wall) || !user || !src || !W ) return
			if( W.rotting )
				user.visible_message("\red The [W.name] crumbles under [user.name]'s touch!", "\red The [W.name] crumbles under your touch!")
				W.dismantle_wall()
				return

			var/quality = rand(1,10)
			if(blessed) quality = rand(8,10)
			switch(quality)
				if(1 to 4)
					W.engraving_quality = "an" //depicted on the wall is [quality] image of ...
				if(5 to 7)
					W.engraving_quality = "a finely-designed"
				if(8 to 9)
					W.engraving_quality = "an exceptionally designed"
				if(10)
					W.engraving_quality = "a masterfully designed"
					user << "\red It's a masterpiece!"

			engraving = {"Depicted on the wall is [W.engraving_quality] image of [engraving_name][(use_name ? " by [user.real_name]" : "")]. [engraving]"}

			var/icon/overlay_type = pick("amyjon","face","matt","revolution","engie","guy","end","dwarf","uboa")
			var/icon/engraving_overlay = new/icon('icons/effects/crayondecal.dmi',"[overlay_type]",2.1)

			W.overlays += engraving_overlay
			W.engraving = engraving
			user.visible_message("\blue [user.name] finishes engraving [W.engraving_quality] image of [engraving_name].", "\blue You finish engraving on the [W.name].")