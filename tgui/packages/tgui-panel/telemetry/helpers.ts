export type ConnectionRecord = {
  ckey: string;
  address: string;
  computer_id: string;
};

export function connectionsMatch(
  a: ConnectionRecord,
  b: ConnectionRecord,
): boolean {
  return (
    a.ckey === b.ckey &&
    a.address === b.address &&
    a.computer_id === b.computer_id
  );
}
