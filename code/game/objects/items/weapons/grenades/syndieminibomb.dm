/obj/item/weapon/grenade/syndieminibomb
	desc = "A syndicate manufactured explosive used to sow destruction and chaos"
	name = "syndicate minibomb"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "syndicate"
	item_state = "flashbang"
	origin_tech = "materials=3;magnets=4;syndicate=4"

/obj/item/weapon/grenade/syndieminibomb/prime()
	update_mob()
	explosion(src.loc,1,2,4,flame_range = 2)
	qdel(src)

/obj/item/weapon/grenade/syndieminibomb/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] activates the [src.name] and holds it above \his head! It looks like \he's going out with a bang!</span>")
	var/message_say = "FOR NO RAISIN!"
	if(user.mind)
		if(user.mind.special_role)
			var/role = lowertext(user.mind.special_role)
			if(role == "traitor" || role == "syndicate")
				message_say = "FOR THE SYNDICATE!"
			else if(role == "changeling")
				message_say = "FOR THE HIVE!"
			else if(role == "cultist")
				message_say = "FOR NAR-SIE!"
			else if(role == "revolutionary" || role == "head revolutionary")
				message_say = "VIVA LA REVOLUTION!"
			else if(user.mind.gang_datum)
				message_say = "[uppertext(user.mind.gang_datum.name)] RULES!"
	user.say(message_say)
	prime()
	message_admins("[key_name_admin(user)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</A>) suicided with [src.name] at ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
	message_admins("[key_name(user)] suicided with [src.name] at ([x],[y],[z])")