const doomMessages = [
  'BUY GOLD!',
  'BUY LOW, SELL HIGH!',
  'INVEST IN CRYPTO!',
  'SELL EVERYTHING!',
  'THE ECONOMY IS COLLAPSING!',
  'THE ECONOMY IS RUINED!',
  'THE MARKET IS CRASHING!',
  'THE STATION IS GOING BANKRUPT!',
];

// Used when the economy is crashing to get a random funny message.
export function getRandomDoomMessage(): string {
  return doomMessages[Math.floor(Math.random() * doomMessages.length)];
}
