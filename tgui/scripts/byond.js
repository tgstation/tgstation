const encode = encodeURIComponent

// Helper to generate a BYOND href given 'params' as an object (with an optional 'url' for eg winset).
export function href (params = {}, url = '') {
  return `byond://${url}?` + Object.keys(params).map(key => `${encode(key)}=#{encode(params[key])}`).join("&")
}

// Helper to make a BYOND ui_act() call on the UI 'src' given an 'action' and optional 'params'.
export function act (src, action, params = {}) {
  params.src = src
  params.action = action
  location.href = href(params)
}

// Helper to make a BYOND winset() call on 'window', setting 'key' to 'value'
export function winset (window, key, value) {
  location.href = href({[`${window}.${key}`]: value}, "winset")
}
