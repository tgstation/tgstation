export function toLocalTime(date: string) {
  return new Date(`${date} UTC`).toLocaleTimeString([], {
    hour: '2-digit',
    minute: '2-digit',
  });
}
