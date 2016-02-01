export function filter (displays, filter) {
  for (let display of displays) { // First check if the display includes the search term in the first place.
    if (display.textContent.toLowerCase().includes(filter)) {
      display.style.display = ''
      const items = display.queryAll('section')
      const titleMatch = display.query('header').textContent.toLowerCase().includes(filter)
      for (let item of items) { // Check if the item or its displays title contains the search term.
        if (titleMatch || item.textContent.toLowerCase().includes(filter)) {
          item.style.display = ''
        } else {
          item.style.display = 'none'
        }
      }
    } else {
      display.style.display = 'none'
    }
  }
}
