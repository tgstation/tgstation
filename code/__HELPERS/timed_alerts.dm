/client/var/timed_alert/timed_alert

/client/proc/timed_alert(time = 300,target,message,title,button1,button2,button3)
	if(timed_alert) return ""

	timed_alert = new(target,message,title,button1,button2,button3)
	sleep(time)
	del(timed_alert)

/mob/proc/timed_alert(time,message,title,button1,button2,button3)
	var/selected_button = ""

	if(client)
		selected_button = client.timed_alert(time,src,message,title,button1,button2,button3)

	return selected_button

/timed_alert/New(mob/target = usr,message,title,button1,button2,button3)
	spawn() alert(target,message,title,button1,button2,button3)
