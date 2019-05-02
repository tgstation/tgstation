// ----------------------------------------------------------------------------
// Index page tree browsing

document.addEventListener("DOMContentLoaded", function() {
    var items = document.getElementsByClassName("index-tree");
    console.log(items.length);
    for (var i = 0; i < items.length; ++i) {
        var node = items[i];
        var parent = node.parentElement;
        if (!parent || parent.tagName.toLowerCase() != "li") {
            continue;
        }
        node.hidden = true;
        parent.style.listStyle = "none";
        var expander = document.createElement("span");
        expander.className = "expander";
        expander.textContent = "\u2795";
        expander.addEventListener("click", function(node) {
            return function(event) {
                if (event.target.tagName.toLowerCase() == "a") {
                    return;
                }
                event.preventDefault();
                event.stopPropagation(true);
                node.hidden = !node.hidden;
                this.textContent = node.hidden ? "\u2795" : "\u2796";
            };
        }(node));
        parent.insertBefore(expander, parent.firstChild);
    }
});
