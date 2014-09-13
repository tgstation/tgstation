/client/var/timed_alert/timed_alert

/client/proc/timed_alert(question as text, title as text, default as text, time = 300, \
        				 choice1 as text, choice2 as text, choice3 as text)

	if(timed_alert) del(timed_alert)
	var/timed_alert/ref_alert = new
	timed_alert = ref_alert

	var/ref_result

	ref_result = ref_alert.timed_alert(src, question, title, time, choice1, choice2, choice3)
	if (!ref_result) ref_result = default

	if (ref_alert) del(ref_alert)

	return ref_result


/mob/proc/timed_alert(question as text, title as text, default as text, time as num, \
					 choice1 as text, choice2 as text, choice3 as text)

	if (client) client.timed_alert(question, title, default, time, choice1, choice2, choice3)
	return



/timed_alert/proc/timed_alert(client/ref_client, question, title, time, choice1, choice2, choice3)
        if (!ref_client) return
        spawn (time) del src // When src is deleted, the proc ends immediately. The alert itself closes.

        var/ref_answer
        ref_answer = alert(ref_client, question, title, choice1, choice2, choice3)

        if(!ref_client || !ref_answer) return
        else return ref_answer

