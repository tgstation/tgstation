var/global/automation_types=typesof(/datum/automation) - /datum/automation

#define AUTOM_RT_NULL    0
#define AUTOM_RT_NUM     1
#define AUTOM_RT_STRING  2
/datum/automation
	// Name of the Automation
	var/name="Base Automation"

	// For labelling what shit does on the AAC.
	var/label="Unnamed Script"
	var/desc ="No Description."

	var/obj/machinery/computer/general_air_control/atmos_automation/parent
	var/list/valid_child_returntypes=list()
	var/list/datum/automation/children=list()

	var/returntype=null

/datum/automation/New(var/obj/machinery/computer/general_air_control/atmos_automation/aa)
	parent=aa

/datum/automation/proc/GetText()
	return "[type] doesn't override GetText()!"

/datum/automation/proc/OnReset()
	return

/datum/automation/proc/OnRemove()
	return

/datum/automation/proc/process()
	return

/datum/automation/proc/Evaluate()
	return 0

/datum/automation/proc/fmtString(var/str)
	if(str==null || str == "")
		return "-----"
	return str

/datum/automation/Topic(href,href_list)
	if(href_list["add"])
		var/new_child=selectValidChildFor(usr)
		if(!new_child) return 1
		children += new_child
		parent.updateUsrDialog()
		return 1
	if(href_list["remove"])
		if(href_list["remove"]=="*")
			var/confirm=input("Are you sure you want to remove ALL automations?","Automations","No") in list("Yes","No")
			if(confirm == "No") return 0
			for(var/datum/automation/A in children)
				A.OnRemove()
				children.Remove(A)
		else
			var/datum/automation/A=locate(href_list["remove"])
			if(!A) return 1
			var/confirm=input("Are you sure you want to remove this automation?","Automations","No") in list("Yes","No")
			if(confirm == "No") return 0
			A.OnRemove()
			children.Remove(A)
		parent.updateUsrDialog()
		return 1
	if(href_list["reset"])
		if(href_list["remove"]=="*")
			for(var/datum/automation/A in children)
				A.OnReset()
		else
			var/datum/automation/A=locate(href_list["remove"])
			if(!A) return 1
			A.OnReset()
		parent.updateUsrDialog()
		return 1
	return 0 // 1 if handled

/datum/automation/proc/selectValidChildFor(var/mob/user, var/list/returntypes=valid_child_returntypes)
	parent.selectValidChildFor(src, user, returntypes)

///////////////////////////////////////////
// AND
///////////////////////////////////////////
/datum/automation/and
	name = "AND statement"
	returntype=AUTOM_RT_NUM
	valid_child_returntypes=list(AUTOM_RT_NUM)

	Evaluate()
		if(children.len==0) return 0
		for(var/datum/automation/stmt in children)
			if(!stmt.Evaluate())
				return 0
		return 1

	GetText()
		var/out="AND (<a href=\"?src=\ref[src];add=1\">Add</a>) {"
		if(children.len>0)
			out += "<ul>"
			for(var/datum/automation/stmt in children)
				out += {"<li>
							\[<a href="?src=\ref[src];reset=\ref[stmt]">Reset</a> |
							<a href="?src=\ref[src];remove=\ref[stmt]">&times;</a>\]
							[stmt.GetText()]
						</li>"}
			out += "</ul>"
		return out + "}"

///////////////////////////////////////////
// OR
///////////////////////////////////////////

/datum/automation/or
	name = "OR statement"
	returntype=AUTOM_RT_NUM
	valid_child_returntypes=list(AUTOM_RT_NUM)

	Evaluate()
		if(children.len==0) return 0
		for(var/datum/automation/stmt in children)
			if(stmt.Evaluate())
				return 1
		return 0

	GetText()
		var/out="OR (<a href=\"?src=\ref[src];add=1\">Add</a>) {"
		if(children.len>0)
			out += "<ul>"
			for(var/datum/automation/stmt in children)
				out += {"<li>
							\[<a href="?src=\ref[src];reset=\ref[stmt]">Reset</a> |
							<a href="?src=\ref[src];remove=\ref[stmt]">&times;</a>\]
							[stmt.GetText()]
						</li>"}
			out += "</ul>"
		return out + "}"

///////////////////////////////////////////
// if .. then
///////////////////////////////////////////

/datum/automation/if_statement
	name = "IF statement"
	var/datum/automation/condition=null
	valid_child_returntypes=list(AUTOM_RT_NULL)
	var/list/valid_conditions=list(AUTOM_RT_NUM)

	GetText()
		var/out="<b>IF</b> (<a href=\"?src=\ref[src];set_condition=1\">SET</a>):<blockquote>"
		if(condition)
			out += condition.GetText()
		out += "</blockquote><b>THEN:</b> (<a href=\"?src=\ref[src];add=1\">Add</a>) <ul>"
		for(var/datum/automation/stmt in children)
			out += {"<li>
						\[<a href="?src=\ref[src];reset=\ref[stmt]">Reset</a> |
						<a href="?src=\ref[src];remove=\ref[stmt]">&times;</a>\]
						[stmt.GetText()]
					</li>"}
		return "[out]</ul>"

	Topic(href,href_list)
		if(href_list["set_condition"])
			var/new_condition = selectValidChildFor(usr,valid_conditions)
			if(!new_condition)
				return 1
			condition = new_condition
			parent.updateUsrDialog()
			return 1

	process()
		if(condition && condition.Evaluate())
			for(var/datum/automation/stmt in children)
				stmt.process()

///////////////////////////////////////////
// compare
///////////////////////////////////////////

/datum/automation/compare
	name = "comparison"
	var/comparator="Greater Than"
	returntype=AUTOM_RT_NUM
	valid_child_returntypes=list(AUTOM_RT_NUM)

	New(var/obj/machinery/computer/general_air_control/atmos_automation/aa)
		..(aa)
		children=list(null,null)

	Evaluate()
		if(children.len<2)
			return 0
		var/datum/automation/d_left =children[1]
		var/datum/automation/d_right=children[2]
		if(!d_left || !d_right)
			return 0
		var/left=d_left.Evaluate()
		var/right=d_right.Evaluate()
		switch(comparator)
			if("Greater Than")
				return left>right
			if("Greater Than or Equal to")
				return left>=right
			if("Less Than")
				return left<right
			if("Less Than or Equal to")
				return left<=right
			if("Equal to")
				return left==right
			if("NOT Equal To")
				return left!=right
			else
				return 0

	GetText()
		var/datum/automation/left =children[1]
		var/datum/automation/right=children[2]

		var/out = "<a href=\"?src=\ref[src];set_field=1\">(Set Left)</a> ("
		if(left==null)
			out += "-----"
		else
			out += left.GetText()

		out += ")  is <a href=\"?src=\ref[src];set_comparator=left\">[comparator]</a>: <a href=\"?src=\ref[src];set_field=2\">(Set Right)</a> ("

		if(right==null)
			out += "-----"
		else
			out += right.GetText()
		out +=")"
		return out

	Topic(href,href_list)
		if(href_list["set_comparator"])
			comparator = input("Select a comparison operator:", "Compare", "Greater Than") in list("Greater Than","Greater Than or Equal to","Less Than","Less Than or Equal to","Equal to","NOT Equal To")
			parent.updateUsrDialog()
			return 1
		if(href_list["set_field"])
			var/idx = text2num(href_list["set_field"])
			var/new_child = selectValidChildFor(usr)
			if(!new_child)
				return 1
			children[idx] = new_child
			parent.updateUsrDialog()
			return 1

///////////////////////////////////////////
// static value
///////////////////////////////////////////

/datum/automation/static_value
	var/value=0

	returntype=AUTOM_RT_NUM

	Evaluate()
		return value

	GetText()
		return "<a href=\"?src=\ref[src];set_value=1\">[value]</a>"

	Topic(href,href_list)
		if(href_list["set_value"])
			value = input("Set a value:", "Static Value", value) as num
			parent.updateUsrDialog()
			return 1