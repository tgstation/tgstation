function changeText(tagID, newText, linkTagID){
	var tag = document.getElementById(tagID);
	tag.innerHTML = newText;
	var linkTag = document.getElementById(linkTagID);
	linkTag.removeAttribute("href");
	linkTag.removeAttribute("onclick");
}
