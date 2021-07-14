export type Feature = {
  name: string;
} & ({
  valueType: ValueType.Color,
} | {
  valueType: ValueType.Number,
  minimum: number,
  maximum: number,
});

export enum ValueType {
  Color,
  Number,
}
