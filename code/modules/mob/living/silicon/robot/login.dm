/mob/living/silicon/robot/Login()
	..()
	regenerate_icons()
	if(isMoMMI(src))
		src << "<span style=\"font-size:3;font-weight;color:red\">MoMMIs are not standard cyborgs, and have different laws.  Review your laws carefully.</span>"
		src << "<b>For newer players, a simple FAQ is <a href=\"http://ss13.nexisonline.net/wiki/MoMMI\">here</a>.  Further questions should be directed to adminhelps (F1).</b>"
	show_laws(0)
	if(mind)	ticker.mode.remove_revolutionary(mind)
	return