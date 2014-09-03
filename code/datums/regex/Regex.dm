/*
	BYOND Regex library
	by Lummox JR

	The goal of this library is to provide a nearly complete implementation of
	regular expressions. A few things like look-ahead and look-ahead assertions
	are not implemented, but much more is.

	Things you can search/replace:
	- Literal strings
	- Octal characters \0### or hex \x##
	- Character classes with [a-z] or [^a-z]
	- Any character .
	- *, +, ?, {n}, {n,}, and {n,m}
	- Non-greedy matching flag ?
	- Beginning of line ^ or \A
	- End of line $ or \Z
	- Grouping with ()
	- Special classes like \d, \w, \s and their opposites (uppercase)
	- Word break or non-break assertions \b or \B
	- Back-references like \1, \2, etc. (multiple digits allowed)

	Replacements:
	- Group vars like $1, $2, etc.

	Every pattern should be delimited by a character like / on either end,
	with optional following flags including:

		i	- case-insensitive matching
		s	- treat as single line
		g	- global replace


	Creating and using a regex:

		var/regex/R = new("/text/i")
		if(R.Find(search_text))
			usr << "Pattern found: [copytext(R.match, R.index)]"

	Procs you may need:

		Find(text, start=1)
			Find this pattern. If found, match is the index where a match
			was found, and index is just past the end of the match. I.e.,
			copytext(match,index) is the result.

		FindNext(text)
			Find the next match starting at the current value of index.

		Replace(text, start=1)
			Returns null if the pattern is not found, or the modified
			text if a replacement is made. If this is a global replacement,
			all occurrances are replaced.

		ReplaceNext(text)
			Replaces the next match. Returns null if no more replacements
			are made, or the modified text if anything changes.

		GroupText(group_number)
			After a search of this text when a match is found, this will
			return the text that belonged to that particular () group.
			I.e., this is the equivalent of $1 or $2 in Perl.


	Named vars:

	You can create named vars like $thing which may be set in the
	regex.namedvars[] associative list.


	Known issues:
		Text search uses findtext() which is fast but unreliable for high ASCII.
		Rebuilding expressions from compiled form is not complete. A re-escaper is also needed.
		A quicker class search for simple classes would be desirable.

 */

#ifdef REGEX_DEBUGGING
#define REGEX_DEBUG(x) world.log<<"(Line [__LINE__]): [x]"
#else
#define REGEX_DEBUG(x) ;
#endif

var/list
	regex_special=list(36,40,41,42,43,46,91,92,93,94,123,124,126)
	regex_classes=list(100,108,115,117,119)
	regex_classtrans=list("0-9","a-z","\\x1- ","A-Z","0-9A-Za-z")
	regex_classinv=list("\\x1-/:-\\xFF","\\x1-`{-\\xFF","!-\\xFF","\\x1-@\[\\xFF","\\x1-/:-@\[-`{-\\xFF")

regex
	/*
		This single-linked list format means that when the parent expression
		is no longer referenced, its linked datums will also be deleted.
		No fuss, no muss!
	 */
	var/regex/next		// next sequential subpattern
	var/regex/nextup	// next sequential subpattern from parent group (or higher)
	var/regex/child		// child subpattern
	var/regex/option	// after compiling this will point to another optional subpattern
	var/regex/replace	// replacement pattern
	/*
		Overall structure (excluding nextup)

		FIRST -> next -> next
		| |
		| OPTION -> next
		| |
		| OPTION -> next -> next
		|           |
		|           CHILD -> next
		|           |
		|           OPTION
		|
		REPLACEMENT -> next ->next
	 */

	// vars used by first node only
	var/lastgroup=0		// last group index
	var/list/groups		// associative list of subpattern=end index of match
	var/list/namedvars	// named vars (plaintext) for search/replace
	var/error

	var/tmp/replacing	// parsing replacement pattern
	var/tmp/patternchar	// char marking beginning and end of pattern

	var/flags=0		// search flags
					// 1=case-insensitive
					// 2=line-insensitive
					// 4=global
					// 8=allow procs in replacement pattern

	// vars used by any subpattern or node
	// un uncompiled subpattern is copytext(pattern,start,end) and includes modifiers
	var/pattern
	var/start		// start index of subpattern match or uncompiled pattern
	var/end			// 0, or 1 past end of subpattern match or uncompiled subpattern

	var/ptype=0		// pattern type
	/*	Types:
		0	<uncompiled>
		1	text
		2	charclass
		3	!charclass
		4	group
		5	proc (replacement)
		8	any character
		10	word break
		11	!word break
		12	var (replacement)
		13	backref
		14	var (named)
		16	bol
		17	eol
		18	bos
		19	eos
	 */
	var/n=1,m=1,greedy=1	// find n to m times; m<0 means no upper limit

	var/tmp/premodend=0	// end of subpattern before modifiers; 0 to use end instead

	var/tmp/match	// beginning of match
	var/tmp/index	// parsing index or end of match

	New(regex/p,s=1,regex/first,regex/last)
		var/endchar=0
		start=s
		if(!first)
			pattern=p; end=length(pattern)+1; first=src
		else
			pattern=first.pattern
			if(istype(p))
				++first.lastgroup
				endchar=(text2ascii(pattern,p.start)==91)?93:41			// end on ] or )
				end=p.end
			else if(!last)
				end=first.replacing
			if(last)
				end=last.end
				last.end=start

		var/i,ch,ch2

		/*
			modify flag
			0 means keep parsing
			1 means expect modifiers or else start a new subexpression
			2 means a modifier has been supplied; look for non-greedy ? flag
		 */
		var/modify=0

		// blank slate!
		// find a delimiter and read flags
		if(start==1)
			patternchar=text2ascii(pattern)
			if(patternchar==92)
				return MarkError(first,2,"Illegal pattern delimiter: ",ch)
			++start
			var/bogusflag
			while(end>=start)
				ch=text2ascii(pattern,--end)
				if(ch==patternchar)
					if(bogusflag) return MarkError(first,bogusflag,"Illegal pattern flag: ",ch)
					break
				switch(ch)
					if(73,105) first.flags |= 1		// case-insensitive
					if(83,115) first.flags |= 2		// treat as single line
					if(71,103) first.flags |= 4		// global (for searches)
					if(69,101) first.flags |= 8		// expression (allow proc calls with [proc(arg1,arg2,...)]
					else bogusflag=end+1
				#ifdef REGEX_DEBUGGING
				if(!bogusflag)
					REGEX_DEBUG("Flag: [ascii2text(ch|32)]")
				#endif
			if(end<start)
				--start
				patternchar=0
				end=length(pattern)+1

		// parsing loop
		index=start
		while(index<end && !first.error)
			ch=text2ascii(pattern,index++)

			// end of pattern; replacement pattern if any may start here
			if(ch==first.patternchar)
				if(!first.replacing)
					first.replacing=end
					first.replace=new(pattern,index,first)
				else if((first.flags&8) && endchar==41) continue
				end=--index
				break

			// end of group; return to parent pattern and keep parsing it for modifiers
			if(ch==endchar)
				if(index<=start+1)
					if(!last) return MarkError(first,index,"Unexpected char:",ch)
					if(last.start==start-1 && text2ascii(pattern,last.start)==124)
						return MarkError(first,index,"Unexpected char:",ch)
				p.index=index; end=index-1; return	// done with subexpression!

			switch(ch)
				/*
					The almighty backslash must parse:

					Literal characters that must be escaped
					Special escapes including \t and \n
					Literal ASCII characters as \0nnn (octal) or \xnn (hex)
					Special character classes like \s or \d (treated as literal until compiled)
					\b or \B (treated as literal until compiled)
					\A or \Z
					Backreferences

					Because it's not known if this is literal text, find out later
					when compiling. Until then, separate this from previous text.
				 */
				if(92)	// backslash
					if(modify || index>start+1) return BreakOff(p,first)
					ch2=Advance()
					if(!ch2) return MarkError(first,index,"Unexpected char:",ch)
					if(ch2==48)
						NumAdvance()
					else if(ch2>=49 && ch2<=57)	// \0 is not a backref
						if(first.replacing) return MarkError(first,index,"Unexpected char:",ch)
						NumAdvance()
						i=text2num(copytext(pattern,start+1,index))
						if(i<=0 || i>first.lastgroup) return MarkError(first,index,"Illegal backref: \\[i]")
					else if(ch2==120 || ch2==88)	// \x or \X
						if(!NumAdvance(16))
							return MarkError(first,index,"Unexpected char:",ch2)
					else
						if(first.replacing) continue
						if(ch2==97 || ch2==65)		// \a or \A
							if(modify || index>start+2) MarkError(first,index,"Unexpected char:",ch2)
							goto done
						if(ch2==122 || ch2==90)		// \z or \Z
							if(index<end) MarkError(first,index,"Unexpected char:",ch2)
							goto done
						if(ch2==98 || ch2==66)		// \b or \B
							goto done
					modify=1

				// beginning of line
				if(94)	// ^
					if(first.replacing) continue
					if(modify || index>start+1) return MarkError(first,index,"Unexpected char:",ch)
					goto done

				/*
					The $ character must parse:

					End of line
					Replacement vars $n
					Named vars $name
				 */
				if(36)	// $
					if(first.replacing && index>=end) continue
					if(modify || index>start+1) return BreakOff(p,first)
					if(index>=end) goto done		// eol--done!
					ch2=Advance()
					if(ch2>=48 && ch2<=57)
						if(!first.replacing) return MarkError(first,index,"Unexpected char:",ch)
						NumAdvance()
					else if((ch2>=65 && ch2<=90) || (ch2>=97 && ch2<=122) || ch2==95)
						do ch2=Advance(); while(ch2>=48 && (ch2<=57 || (ch2>=65 && ch2<=90) || ch2==95 || ch2>=97) && ch2<=122)
						if(index<end) --index
					else return MarkError(first,index-1,"Unexpected char:",36)
					goto done

				// any character
				if(46)	// .
					if(first.replacing) continue
					if(index>start+1) return BreakOff(p,first)
					modify=1

				// Simple modifiers * + ? and the non-greedy ? flag
				if(42,43,63)	// * or + or ?
					if(first.replacing) continue
					// multi-char sequence; cut off last char as a new group
					if(!modify && index>start+2)
						--index; return BreakOff(p,first)
					if((modify>1 && ch!=63) || index<=start+1)
						// this should always have an expression currently parsing
						return MarkError(first,index,"Unexpected char:",ch)
					if(!premodend) premodend=index-1
					// after a ? no further modify flags are allowed
					if(ch==63)
						if(modify>1)
							greedy=0; goto done
						//goto done
						n=0;m=1
					else
						n=ch-42;m=-1
					modify=2

				// {n} and {n,m} modifiers
				// in {n,m} form, defaults for omitted values are n=0 and m=infinite
				if(123)	// {
					if(first.replacing) continue
					// multi-char sequence; cut off last char as a new group
					if(!modify && index>start+2)
						--index; return BreakOff(p,first)
					if(modify>1) return BreakOff(p,first)
					if(index<=start+1) return MarkError(first,index,"Unexpected char:",ch)
					premodend=index-1
					i=index
					NumAdvance()
					if(index>i)
						n=text2num(copytext(pattern,i,index))
						ch2=Advance()
					else
						// no number found; demand a comma!
						ch2=Advance()
						if(!ch2) return MarkError(first,index,"Unexpected char:",ch)
						if(ch2!=44) return MarkError(first,index,"Expected number or ,")
						n=0
					m=n
					if(ch2==44)
						i=index
						NumAdvance()
						if(index>i)
							m=text2num(copytext(pattern,i,index))
							if(m<n) {i=n;n=m;m=i}
						else m=-1
						ch2=Advance()
					if(ch2!=125)		// }
						return MarkError(first,index,"Unexpected char:",ch2)
					modify=2

				// groups and classes
				if(40)		// (
					if(first.replacing)
						// with e flag set, this may be part of [proc(arg1,arg2,...)] replacement pattern
						// if not, treat ( as a literal char in replacements
						if(!(first.flags&8) || endchar!=93) continue
						if(index>start+1) return BreakOff(p,first)
						child=new(src,index,first)
						ch2=LookAhead()
						if(LookAhead()!=endchar)
							return MarkError(first,(ch2?(index+1):index),"Expected",endchar)
						goto done
					if(modify || index>start+1) return BreakOff(p,first)
					child=new(src,index,first)
					modify=1
				if(91)		// [
					if(first.replacing)
						// with e flag set, allow [proc(arg1,arg2,...)] in replacement
						// otherwise, treat [ as a literal char in replacements
						if(!(first.flags&8)) continue
						if(index>start+1) return BreakOff(p,first)
						ch2=LookAhead()
						if(!ch2)
							return MarkError(first,index,"Unexpected char:",ch)
						if(ch2<65 || (ch2>90 && ch2<97 && ch2!=95) || ch2>122)
							return MarkError(first,index+1,"Unexpected char in proc name:",ch2)
						for(i=index+2,i<end,)
							ch2=text2ascii(pattern,i)
							if(ch2==40 || ch2==93) break
							++i
							if(ch2<48 || (ch2>57 && ch2<65) || (ch2>90 && ch2<97 && ch2!=95) || ch2>122)
								return MarkError(first,i,"Unexpected char in proc name:",ch2)
						ch2="/proc/[copytext(pattern,index,i)]"
						if(!text2path(ch2))
							return MarkError(first,i,"[ch2] does not exist")
						child=new(src,index,first)
						goto done
					if(modify || index>start+1) return BreakOff(p,first)
					if(ParseCharClass(first)) return		// returns src on failure
					modify=1

				// alternative matches (options)
				if(124)		// |
					if(first.replacing) continue
					if(modify || index>start+1) return BreakOff(p,first)
					if(!last) return MarkError(first,index,"Unexpected char:",ch)
					goto done

				// ,
				// only has special meaning in replacement expression [proc(arg1,arg2,...)]
				if(44)
					if(first.replacing)
						if(first.flags&8)
							if(endchar==93) return MarkError(first,index,"Unexpected char:",ch)
							if(endchar==41)
								if(index>start+1) return BreakOff(p,first)
								goto done
						continue
					if(modify) return BreakOff(p,first)

				// illegal chars; if legal they are caught sooner
				if(41,93)	// ) or ]
					if(first.replacing) continue
					// these are not encountered here; if endchar doesn't catch them, they're wrong
					return MarkError(first,index,"Unexpected char:",ch)

				// literal text
				else
					if(modify) return BreakOff(p,first)
		done:
		if(first.error) return
		if(index<end)
			++index; BreakOff(p,first)
		// endchar not encountered
		else if(endchar)
			return MarkError(first,index,"Expected",endchar)
		if(first==src) CompileBlocks()

	// return src on failure; null for success
	proc/ParseCharClass(regex/first)
		var/i,ch,ch2
		var/lastch=0,rangechar=0
		var/s=index
		while(index<end && !first.error)
			i=index
			ch=text2ascii(pattern,index++)
			if(ch==93)	// ]
				// it is legal to end here if rangechar is set, because a final - means \-
				// it'll all come out in compiling!
				if(index<=s+1)
					return MarkError(first,index,"Unexpected char:",ch)
				return	// done with subexpression!
			switch(ch)
				if(94)		// ^
					if(index>s+1) return MarkError(first,index,"Unexpected char:",ch)
				if(92)		// backslash
					ch2=Advance()
					if(!ch2) return MarkError(first,index,"Unexpected char:",ch)
					if(ch2==120 || ch2==88)		// \x## or \X##
						if(!NumAdvance(16))
							return MarkError(first,index,"Unexpected char:",LookAhead())
						if(ch2) --index
						ch2=48
					else if(NumAdvance()) ch2=48
					else if(!((ch2|32) in regex_classes))
						if(rangechar) rangechar=index-1
						else lastch=i
					else
						if(rangechar) return MarkError(first,index,"Invalid chracter range: [copytext(pattern,rangechar,index)]")
				if(45)		// -
					if(!lastch) return MarkError(first,index,"Unexpected char:",ch)
					rangechar=lastch
				else
					if(rangechar) rangechar=0
					else lastch=i
		// ] not encountered
		return MarkError(first,index,"Expected ",93)

	proc/BreakOff(p,regex/first)
		next=new(p,--index,first,src)
		if(!first.error && first==src) CompileBlocks()
		return src		// this proc is used to escape New() with a return

	proc/Advance()
		if(index>=end) return 0
		return text2ascii(pattern,index++)

	proc/LookAhead()
		if(index>=end) return 0
		return text2ascii(pattern,index)

	proc/NumAdvance(radix=10)
		var/chn=LookAhead()
		if(!chn) return 0
		while((chn>=48 && chn<=57) || (chn>=65 && chn<=54+radix) || (chn>=97 && chn<=86+radix))
			.=1; if(++index>=end) break
			chn=text2ascii(pattern,index)

	proc/MarkError(regex/first,i,msg,ch)
		first.error=copytext(pattern,1,i)+"  <-- [msg]"
		if(!isnull(ch))
			if(!ch) first.error+=" [copytext(pattern,length(pattern))]"
			else first.error+=" [ascii2text(ch)]"
		return src		// this proc is used to escape New() with a return

	proc/BlockType(rep)
		var/ch
		if(ptype) return ptype
		if(rep)
			switch(text2ascii(pattern,start))
				if(36)
					if(end-start<=1) return 1
					ch=text2ascii(pattern,start+1)
					return (ch>=48 && ch<=57)?12:14
				if(44)
					return (end-start==1)?0:1
			if(child)
				return (text2ascii(pattern,start)==91)?5:4
			return 1
		switch(text2ascii(pattern,start))
			if(92)
				ch=text2ascii(pattern,start+1)
				if((ch|32) in regex_classes)
					return (ch&32)?2:3
				if((ch|32)==98)		// \b or \B
					return (ch&32)?10:11
				if((ch|32)==97)		// \a or \A
					return 18
				if((ch|32)==122)	// \z or \Z
					return 19
				if(ch>=49 && ch<=57) return 13	// backref
				return 1
			if(91)
				if(text2ascii(pattern,start+1)==94) return 3
				return 2
			if(40) return 4
			if(46) return 8
			if(94) return 16
			if(36)
				if(end-start<=1) return 17
				ch=text2ascii(pattern,start+1)
				return (ch>=48 && ch<=57)?12:14
		return 0

	// flags needed for case-sensitivity
	proc/CompileClass(f)
		var/list/L=list(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
		var/ch,ch2,lastch=0
		index=1;end=length(pattern)+1
		while(index<end)
			ch=text2ascii(pattern,index++)
			if(ch==45 && index<end) continue
			if(ch==92)	// backslash
				ch2=Advance()
				var/i=regex_classes.Find(ch2|32)
				if(i)
					if(ch2&32)
						pattern=copytext(pattern,1,index-2)+regex_classtrans[i]+copytext(pattern,index)
					else
						pattern=copytext(pattern,1,index-2)+regex_classinv[i]+copytext(pattern,index)
					index-=2
					end=length(pattern)+1
					continue
				if(ch2==110) ch=10
				else if(ch2==116) ch=9
				else if(ch2==120 || ch2==88)	// \x or \X
					ch=0; ch2=0
					do
						ch=ch*16+ch2
						ch2=Advance()
						if(!ch2) break
						if(ch2>=48 && ch2<=57) ch2-=48
						else
							ch2|=32
							if(ch2>=97 && ch2<=102) ch2-=87
							else
								--index;break
					while(index<=end)
				else if(ch2==48)	// \0xxx
					ch=0; ch2=48
					do
						ch=ch*8+ch2
						ch2=Advance()
						if(!ch2) break
						// allow 8 and 9 as digits, because parsing for them is a pain
						if(ch2>=48 && ch2<=57) ch2-=48
						else
							--index; break
					while(index<=end)
				else ch=ch2
			if(lastch)
				if(lastch>ch)
					ch2=ch;ch=lastch;lastch=ch2
				ch+=15;lastch+=15
				if((lastch>>4)<(ch>>4))
					L[lastch>>4]|=-(1<<(lastch&15))
					lastch=(lastch+16)&240
				while(lastch+16<=ch)
					L[lastch>>4]|=65535
					lastch+=16
				L[ch>>4]|=(1<<(ch&15))-(1<<(lastch&15))
				lastch=0
			else
				if(LookAhead()==45)
					lastch=ch;++index
				ch+=15
			L[ch>>4]|=(1<<(ch&15))
		if(f&1)
			L[5]|=L[7];L[7]|=L[5]
			L[6]|=L[8]&0x3FF;L[8]|=L[6]&0x3FF
			L[12]|=L[14]&0x8000;L[14]|=L[12]&0x8000
			L[13]|=L[15];L[15]|=L[13]
			L[14]|=L[16]&0xFFBF;L[16]|=L[14]&0xFFBF
		pattern=L

	// call this after CompileOptions()
	proc/CompileBlocks(regex/follow,regex/first,rep,regex/parent)
		var/regex{o;p}
		var/ch,ch2
		if(!first)
			if(ptype) return		// already compiled
			first=src
			if(replace) replace.CompileBlocks(null,src,1)
		var/optchar=rep?((parent && parent.ptype==4)?44:0):124
		for(o=src,o,o=o.option)
			// compile options first
			// otherwise next||follow may be incorrect when compiled
			for(p=o, p, p=p.next)
				p.ptype=p.BlockType(rep)
				if(!p.ptype)
					if(text2ascii(p.pattern,p.start)==optchar)
						o.option=p.next; del(p); break
					if(!p) break
					p.ptype=1		// force non-special blocks to be text
			for(p=o, p, p=p.next)
				p.nextup=follow
				if(p.child)
					if(!rep)
						if(!first.groups) first.groups=new
						first.groups+=p
					p.child.CompileBlocks(p.next||follow,first,rep,p)
				var/e=(p.premodend||p.end)
				switch(p.ptype)
					if(1)
						if(text2ascii(p.pattern,p.start)==92)
							ch=text2ascii(p.pattern,++p.start)
							if(ch==110) ch=10
							else if(ch==116) ch=9
							else if(ch==48)				// octal digit
								ch=0; ch2=48
								do
									ch=ch*8+(ch2-48)
									ch2=(p.start<e)?text2ascii(p.pattern,++p.start):0
									// allow 8 and 9 as digits, because parsing for them is a pain
								while(ch2>=48 && ch2<=57)
							else if(ch==120 || ch==88)	// \x or \X
								ch=0; ch2=0
								do
									ch=ch*16+ch2
									ch2=(p.start<e)?text2ascii(p.pattern,++p.start):0
									if(ch2>=48 && ch2<=57) ch2-=48
									else
										ch2|=32
										if(ch2>=97 && ch2<=102) ch2-=87
										else break
								while(p.start<=e)
							p.pattern=ascii2text(ch)
							continue
						p.pattern=copytext(p.pattern,p.start,e)
					if(5)
						p.pattern=copytext(p.pattern,p.start,e)
					if(2,3)
						if(text2ascii(p.pattern,p.start)==92)
							ch=regex_classes.Find(text2ascii(p.pattern,p.start+1)|32)
							if(!ch) p.pattern=lowertext(copytext(p.pattern,p.start,e))
							else p.pattern=regex_classtrans[ch]
						else
							p.pattern=copytext(p.pattern,p.start+(p.ptype-1),e-1)
						p.CompileClass(first.flags)
					if(12,13)
						p.pattern=text2num(copytext(p.pattern,p.start+1,e))
					if(14)
						p.pattern=copytext(p.pattern,p.start+1,e)
						if(!first.namedvars) first.namedvars=new
						first.namedvars[p.pattern]=null
					else
						p.pattern=null
			// combine compiled literal text
			for(p=o, p, p=p.next)
				if(p.ptype!=1 || p.n!=1 || p.m!=1) continue
				while(p.next && p.next.ptype==1 && p.next.n==1 && p.next.m==1)
					p.pattern+=p.next.pattern
					var/q=p.next
					p.next=p.next.next
					del(q)

	proc/TrueBlock()
		if(!ptype) return pattern
		switch(ptype)
			// eventually re-escape text
			if(1) .=pattern
			// return these two later to a text form
			if(2) .="\[[pattern]\]"
			if(3) .="\[^[pattern]\]"
			if(4)
				.="("
				var/regex/p
				for(p=child,p,p=p.next) .+="[p.TrueBlock()]"
				.+=")"
			if(8) .="."
			if(10) .="\\b"
			if(11) .="\\B"
			if(12,14) .="$[pattern]"
			if(13) .="\\[pattern]"
			if(16) return "^"
			if(17) return "$"
			if(18) return "\\A"
			if(19) return "\\Z"
		if(n==1 && m==1) return .
		if(m==-1)
			if(!n) .+="*"
			else if(n==1) .+="+"
			else .+="{[n],}"
		else if(n==0 && m==1) .+="?"
		else .+="{[n],[m]}"
		if(!greedy) .+="?"

	// searching
	/*
		Internal vars:
		first:		First datum in pattern
		stop:		Don't find a match starting after this point (0=don't care)
		anyline:	In default line mode, allow pattern to begin on any line
	 */
	proc/Find(txt,start=1,regex/first,stop,anyline)
		var/i,e,ee
		var/isfirst
		if(!first)
			first=src
			match=0;index=0
			isfirst=1
			if(!(first.flags&2)) anyline=1
			for(i in groups) groups[i]=null
		ee=length(txt)+1
		e=(start>=ee || (first.flags&2) || anyline)?(ee):(findtextEx(txt,"\n",start)||ee)
		REGEX_DEBUG("Find([TrueBlock()]) ([start],[e]/[ee]) ([ptype])")
		sleep()
		i=FirstPossible(txt,start,first,stop,anyline)
		while(i && i<=e)
			if(FindHere(txt,i,first)) break
			i=FirstPossible(txt,i+1,first,stop,anyline)
		if(i && isfirst)
			first.match=i
			first.index=src.FoundTo()
		return i

	// find the last possible case of a pattern, with stop as the last possible choice
	proc/FindLast(txt,start=1,regex/first,stop,anyline)
		var/i,e,ee
		var/isfirst
		if(!first)
			first=src
			match=0;index=0
			isfirst=1
			if(!(first.flags&2)) anyline=1
			for(i in groups) groups[i]=null
		ee=length(txt)+1
		e=(start>=ee || (first.flags&2) || anyline)?(ee):(findtextEx(txt,"\n",start)||ee)
		REGEX_DEBUG("FindLast([TrueBlock()]) ([start],[e]/[ee]) ([ptype])")
		sleep()
		var/list/stack=new
		i=FirstPossible(txt,start,first,stop,anyline)
		while(i && i<=e)
			stack+=i
			i=FirstPossible(txt,i+1,first,stop,anyline)
		while(stack.len)
			i=stack[stack.len]
			stack.Cut(stack.len)
			if(FindHere(txt,i,first)) break
			i=0
		if(i && isfirst)
			first.match=i
			first.index=src.FoundTo()
		return i

	proc/FindHere(txt,start=1,regex/first,nonzero)
		if(!first) first=src
		var/i,j,k,ch,ch2,times,maxtimes
		i=start
		var/regex/o=option
		var/ee=length(txt)+1
		var/e=(start>=ee || (first.flags&2))?(ee):(findtextEx(txt,"\n",start)||ee)
		var/regex/after
		while(src)
			REGEX_DEBUG("FindHere([TrueBlock()]) ([start],[e]/[ee]) ([ptype])")
			sleep()
			times=0
			after=(next||nextup)
			src.start=i; end=e
			switch(ptype)
				if(1,13,14)	// string
					var/str=pattern
					if(ptype>1)
						switch(ptype)
							if(13)
								if(pattern<1 || pattern>first.groups.len) goto done
								str=first.groups[first.groups[pattern]]
								if(isnull(str)) goto done
							if(14)
								if(!(pattern in first.namedvars)) goto done
								str=(first.namedvars[pattern]||"")
					k=i
					var/l=length(str)
					stringmatch:
						do
							if(i+l>ee) break
							if(first.flags&1)
								for(j=1,j<=l,++j)
									ch=text2ascii(txt,k++)
									ch2=text2ascii(str,j)
									// this currently will cause some inconsistent behavior
									// until findtext() is replaced with a routine sensitive to upper ASCII
									if(ch==ch2) continue
									ch|=32
									if(ch!=(ch2|32)) break stringmatch
									if(ch<97 || (ch>122 && (ch<224 || ch==243))) break stringmatch
							else
								for(j=1,j<=l,++j)
									if(text2ascii(txt,k++)!=text2ascii(str,j)) break stringmatch
							i=k
							if(++times>=n && !greedy && !after) break stringmatch
						while(times<m || m<0)
					if(greedy || !after || times<=n)
						if(!greedy && !after && times>n)
							times=n; i=src.start+n*l
						// update e because a literal string may cross a line break
						if(times>=n && !(first.flags&2)) e=(findtextEx(txt,"\n",i)||ee)
						goto done
					// non-greedy, and another subpattern must follow this
					// if any early match may be found, take it!
					maxtimes=times
					times=n
					for(i=src.start+n*l,times<maxtimes,i+=l)
						if(after.FindHere(txt,i,first))
							end=i; return src.start
						++times
					// times>=maxtimes, so fall through

				if(2)
					if(i+n>e)
						times=-1
						goto done
					times=Span(txt,i,i+n)-i
					if(times<n) goto done
					if(n==m) {i+=n;goto done}
					maxtimes=(m<0)?(e-i):min(m,e-i)
					times=Span(txt,i+n,i+maxtimes)-i
					maxtimes=times
					goto classmatch
				if(3)
					if(i+n>e)
						times=-1
						goto done
					times=NonSpan(txt,i,i+n)-i
					if(times<n) goto done
					if(n==m) {i+=n;goto done}
					maxtimes=(m<0)?(e-i):min(m,e-i)
					times=NonSpan(txt,i+n,i+maxtimes)-i
					maxtimes=times
					goto classmatch

				if(4)	// group
					if(child)
						do
							if(!child.FindHere(txt,i,first)) break
							i=child.FoundTo()
						while(++times<n)
						if(times>=n)
							if(greedy)
								while(times<m || m<0)
									if(!child.FindHere(txt,i,first,(m<0))) break
									i=child.FoundTo()
									++times
							first.groups[src]=copytext(txt,start,i)

				if(8)	// any char
					if(i+n>e)
						times=-1
						goto done
					if(n==m)
						i+=n; times=n
						goto done
					maxtimes=(m<0)?(e-i):min(m,e-i)
					goto classmatch

				if(10,11)
					ch=(i>1)?text2ascii(txt,i-1):0
					ch=(ch<48 || ch>122 || (ch>57 && ch<65) || (ch>90 && ch<95) || ch==96)?0:1
					ch2=(i<e)?text2ascii(txt,i):0
					ch2=(ch2<48 || ch2>122 || (ch2>57 && ch2<65) || (ch2>90 && ch2<95) || ch2==96)?0:1
					times += (ch^ch2)^(ptype&1)

				if(16,18)	// bol, bos
					if(i<=1) ++times
					else if(!(ptype&first.flags&2) && text2ascii(txt,i-1)==10) ++times
				if(17,19)	// eol, eos
					if(i>=ee) ++times
					else if(!(ptype&first.flags&2) && text2ascii(txt,i)==10) ++times

				if(0)
					if(first.error) world.log << "Regex [first.pattern] did not compile:\n[first.error]"

				else
					world.log << "Block type [ptype] not handled yet"
			done:
			if(times<n || (nonzero && start==i))
				src.start=0;end=0
				if(o)
					src=o;o=option;i=start
					if(first.flags&2) e=(findtextEx(txt,"\n",i)||ee)
					continue
				return 0
			end=i
			REGEX_DEBUG("FoundHere: [.||src.start],[i]")
			if(!.) .=src.start
			if(!next) return .
			src=next;start=i
			continue
			// common code used in [] or [^] or . matching
			classmatch:
			if(!greedy)
				if(after)
					if(after.Find(txt,i+n,first,i+maxtimes))
						end=after.start; return i
					else times=-1
				else
					i+=n;times=n
			else if(!after)
				i+=maxtimes;times=maxtimes
			else
				j=after.FindLast(txt,i+n,first,i+maxtimes)
				times=j-i;i=j
			goto done

	proc/FirstPossible(txt,start=1,regex/first,stop,anyline)
		var/i,j,k,ch,ch2
		var/ee=length(txt)+1
		var/e=(start>=ee || (first.flags&2))?(ee):(findtextEx(txt,"\n",start)||ee)
		if(!stop) stop=ee
		var/regex/after
		.=0
		for(var/regex/p=src,p,p=p.option)
			i=start
			REGEX_DEBUG("FirstPossible([TrueBlock()]) ([start],[e]/[ee]) ([ptype])")
			sleep()
			switch(p.ptype)
				if(1,13,14)
					var/str=p.pattern
					if(p.ptype>1)
						switch(p.ptype)
							if(13)
								if(p.pattern<1 || p.pattern>first.groups.len) {i=0;goto found}
								str=first.groups[first.groups[p.pattern]]
								if(isnull(str))	// nothing actually found for sure yet
									goto found	// so start here

							if(14)
								if(!(p.pattern in first.namedvars)) {i=0;goto found}
								str=(first.namedvars[p.pattern]||"")
					if(anyline) e=ee
					i=(first.flags&1)?findtext(txt,str,i):findtextEx(txt,str,i)
					if(!i || i>stop || i>e) i=0

				if(2)
					while(i+p.n<=ee)
						while(i+p.n<=e)
							i=p.NonSpan(txt,i,e-p.n+1)
							if(i>stop) {i=0; goto found}
							if(i+p.n>e) continue
							j=p.Span(txt,i+1,i+p.n)
							if(j>=i+p.n) goto found
							i=j+1
						if(anyline)
							i=++e;e=(findtextEx(txt,"\n",e)||ee)
					i=0
				if(3)
					while(i+p.n<=ee)
						while(i+p.n<=e)
							i=p.Span(txt,i,e-p.n+1)
							if(i>stop) {i=0; goto found}
							if(i+p.n>e) continue
							j=p.NonSpan(txt,i+1,i+p.n)
							if(j>=i+p.n) goto found
							i=j+1
						if(anyline)
							i=++e;e=(findtextEx(txt,"\n",e)||ee)
					i=0

				if(4)
					i=(p.child)?p.child.FirstPossible(txt,start,first,stop,anyline):0

				if(8)
					after=(p.next||p.nextup)
					while(i && i+p.n<=ee)
						if(anyline)
							while(i+p.n>e && e<ee)
								i=++e;e=(findtextEx(txt,"\n",e)||ee)
						if(i+p.n>e) {i=0; break}
						if(!after) break
						k=(p.m<0)?(e):min(e,i+p.m)
						j=after.Find(txt,i+p.n,first,k)
						if(!j) {i=++e;e=(findtextEx(txt,"\n",e)||ee)}
						else {if(p.m>0) i=max(i,j-p.m);break}
					if(i+p.n>ee) i=0

				if(10,11)
					if(anyline) e=ee
					ch=(i>1)?text2ascii(txt,i-1):0
					ch=(ch<48 || ch>122 || (ch>57 && ch<65) || (ch>90 && ch<95) || ch==96)?0:1
					j=p.ptype&1
					// start==end is legal for \b
					while(i<=e)
						ch2=(i<e)?text2ascii(txt,i):0
						ch2=(ch2<48 || ch2>122 || (ch2>57 && ch2<65) || (ch2>90 && ch2<95) || ch2==96)?0:1
						if(ch^ch2^j) goto found
						++i;ch=ch2
					i=0

				if(16,18)
					if(i>1)
						if(p.ptype&first.flags&2) i=0
						else
							i=findtextEx(txt,"\n",i-1)
							if(i) ++i

				if(17,19)
					if(i<ee)
						if(p.ptype&first.flags&2) i=ee
						else i=(findtextEx(txt,"\n",i)||ee)

				if(0)
					if(first.error) world.log << "Regex [first.pattern] did not compile:\n[first.error]"

				else
					world.log << "Block type [p.ptype] not handled yet"
			found:
			if(i) .=(.)?min(i,(.)):i

	proc/Replace(txt,start=1)
		var/times,rtxt
		index=start
		for(times=((flags&4)?length(txt):1),(times>0 && index<=length(txt)+1),--times)
			if(!Find(txt,index)) return
			// ignore empty matches
			if(index==match)
				++index; ++times; continue
			rtxt=ReplacementText(txt)
			txt=copytext(txt,1,match)+rtxt+copytext(txt,index)
			index=match+length(rtxt)
			.=txt

	proc/GroupText(g)
		if(g<1 || g>groups.len) return
		return groups[groups[g]]

	proc/ReplacementText(txt,regex/first)
		.=""
		if(!first) first=src
		var/regex/p
		for(p=(replace||src),p,p=p.next)
			switch(p.ptype)
				if(1)
					.+=p.pattern
				if(5)
					if(!p.child) continue
					// procname is always a literal text block
					// if any arguments are present, they will be in p.child.next
					var/procname=p.child.pattern
					if(p.child.next && p.child.next.child)
						var/list/procargs=new
						for(var/regex/q=p.child.next.child,q,q=q.option)
							procargs += q.ReplacementText(txt,first)
						.+="[call(text2path("/proc/[procname]"))(arglist(procargs))]"
					else
						.+="[call(text2path("/proc/[procname]"))()]"
				if(12)
					.+=first.GroupText(p.pattern)
				if(14)
					if(!first.namedvars[p.pattern]) continue
					.+=first.namedvars[p.pattern]
				else
					world.log << "Replacement block type [p.ptype] not handled yet"

	proc/Span(txt,s,e)
		var/ch
		for(.=s,(.)<e,++.)
			ch=text2ascii(txt,.)+15
			if(!(pattern[ch>>4]&(1<<(ch&15)))) return
	proc/NonSpan(txt,s,e)
		var/ch
		for(.=s,(.)<e,++.)
			ch=text2ascii(txt,.)+15
			if(pattern[ch>>4]&(1<<(ch&15))) return

	// call after Find() to find end of matched text
	proc/FoundTo()
		while(!start && option) src=option
		if(!start) return 0
		var/regex/p
		for(p=src,p,p=p.next)
			end=p.end
		return end

	proc/FindNext(txt)
		if(!match) index=1
		return Find(txt,index)

	proc/ReplaceNext(txt)
		if(!match) index=1
		if(Find(txt,index))
			var/rtxt=ReplacementText(txt)
			txt=copytext(txt,1,match)+rtxt+copytext(txt,index)
			index=match+length(rtxt)
			.=txt

	proc/Split(txt,inclusive)
		.=list()
		var/lastindex=1
		if(Find(txt))
			do
				. += copytext(txt,lastindex,match)
				if(inclusive) . += copytext(txt,match,index)
				lastindex=index
				if(match==index) ++index
			while(FindNext(txt))
		. += copytext(txt,lastindex)
