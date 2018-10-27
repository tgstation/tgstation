function toggle_checkboxes(source) {
  checkboxes = document.getElementsByName(source.name);
  for(var i=0, n=checkboxes.length;i<n;i++) {
    checkboxes[i].checked = source.checked;
  }
}
