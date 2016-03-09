export function upperCaseFirst (str) {
  return str[0].toUpperCase() + str.slice(1).toLowerCase()
}

export function titleCase (str) {
  return str.replace(/\w\S*/g, upperCaseFirst)
}
