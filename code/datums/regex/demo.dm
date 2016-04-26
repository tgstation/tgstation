mob/verb/Search(t as text,p as text)
	if(!t || !p) return
	var/regex/rp = new(p)
	if(rp.error)
		to_chat(src, "[rp.error]")
		return
	var/i=rp.Find(t)
	if(i)
		to_chat(src, "Pattern found at ([rp.match],[rp.index]): \c")
		to_chat(src, copytext(t,rp.match,rp.index))
	else
		to_chat(src, "Pattern not found.")
	rp = null

mob/verb/Replace(t as text,p as text)
	if(!t || !p) return
	var/regex/rp = new(p)
	if(rp.error)
		to_chat(src, "[rp.error]")
		return
	var/i=rp.Replace(t)
	if(i)
		to_chat(src, "Replaced: [i]")
	else to_chat(src, "Pattern not found.")
	rp=null

mob/verb/Pattern(p as text)
	if(!p) return
	var/regex/rp = new(p)
	if(rp.error)
		to_chat(src, "[rp.error]")
		return
	var/list/stack=new
	var/depth=""
	var/regex{O=rp;P}
	while(O)
		for(,O,O=O.option)
			for(P=O,P,P=P.next)
				while(P.child)
					to_chat(usr, "[depth]( )")
					if(P.next) {stack+=P.next}
					depth+="  "
					O=P.child;P=O
				to_chat(usr, "[depth][P.TrueBlock()]")
			if(O.option) to_chat(usr, "[depth]|")
		if(stack.len)
			O=stack[stack.len]
			stack.len--
			depth=copytext(depth,3)
	to_chat(usr, "(done)")

mob/verb/Split(t as text,p as text)
	if(!t || !p) return
	var/regex/rp = new(p)
	if(rp.error)
		to_chat(src, "[rp.error]")
		return
	var/list/L = rp.Split(t)
	for(var/s in L)
		to_chat(usr, "\"[s]\" \...")
	to_chat(usr, "")

proc/double(n)
	return text2num(n)*2

proc/sum(a,b)
	to_chat(world, "sum(\"[a]\",\"[b]\")")
	return text2num(a)+text2num(b)
