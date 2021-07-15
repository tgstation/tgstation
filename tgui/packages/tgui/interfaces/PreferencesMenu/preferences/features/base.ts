export type Feature = {
  name: string;
} & ({
  valueType: ValueType.Choiced,

  // Map of preference value (to send to server) and text representation
  choices: Record<string, string>,
} | {
  valueType: ValueType.Color,
} | {
  valueType: ValueType.Number,
  minimum: number,
  maximum: number,
});

export enum ValueType {
  Choiced,
  Color,
  Number,
}
