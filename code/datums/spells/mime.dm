/obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall
	name = "Invisible wall"
	desc = "The mime's performance transmutates into physical reality."
	school = "mime"
	panel = "Mime"
	summon_type = list(/obj/effect/forcefield/mime)
	invocation_type = "emote"
	invocation_emote_self = "<span class='notice'>You form a wall in front of yourself.</span>"
	summon_lifespan = 300
	charge_max = 300
	clothes_req = 0
	range = 0
	cast_sound = null


/obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall/Click()
	if(usr)
		invocation = "<B>[usr.real_name]</B> looks as if a wall is in front of them."
	else
		invocation_type ="none"
	..()


/obj/effect/proc_holder/spell/targeted/mime/speak
	name = "Speech"
	desc = "Make or break a vow of silence."
	school = "mime"
	panel = "Mime"
	clothes_req = 0
	human_req = 1
	charge_max = 3000
	range = -1
	include_user = 1

/obj/effect/proc_holder/spell/targeted/mime/speak/Click()
	if(!usr)
		return
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/H = usr
	if(H.mind.miming)
		still_recharging_msg = "<span class='notice'>You can't break your vow of silence that fast!</span>"
	else
		still_recharging_msg = "<span class='notice'>You'll have to wait before you can give your vow of silence again.</span>"
	..()

/obj/effect/proc_holder/spell/targeted/mime/speak/cast(list/targets)
	for(var/mob/living/carbon/human/H in targets)
		H.mind.miming=!H.mind.miming
		if(H.mind.miming)
			H << "<span class='notice'>You make a vow of silence.</span>"
		else
			H << "<span class='notice'>You break your vow of silence.</span>"