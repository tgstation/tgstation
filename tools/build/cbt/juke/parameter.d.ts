export declare type ParameterType = (string | string[] | number | number[] | boolean | boolean[]);
export declare type ParameterStringType = ('string' | 'string[]' | 'number' | 'number[]' | 'boolean' | 'boolean[]');
declare type ParameterTypeByString<T extends ParameterStringType> = (T extends 'string' ? string : T extends 'string[]' ? string[] : T extends 'number' ? number : T extends 'number[]' ? number[] : T extends 'boolean' ? boolean : T extends 'boolean[]' ? boolean[] : never);
export declare type ParameterMap = Map<Parameter, unknown[]>;
declare type ParameterOptions<T extends ParameterStringType> = {
    /**
     * Parameter name, in "camelCase".
     */
    readonly name: string;
    /**
     * Parameter type, one of:
     * - `string`
     * - `string[]`
     * - `number`
     * - `number[]`
     * - `boolean`
     * - `boolean[]`
     */
    readonly type: T;
    /**
     * Short flag for use in CLI, can only be a single character.
     */
    readonly alias?: string;
};
export declare const createParameter: <T extends ParameterStringType>(options: ParameterOptions<T>) => Parameter<ParameterTypeByString<T>>;
export declare class Parameter<T extends ParameterType = any> {
    readonly name: string;
    readonly type: ParameterStringType;
    readonly alias?: string | undefined;
    constructor(name: string, type: ParameterStringType, alias?: string | undefined);
    isString(): T extends string | string[] ? true : false;
    isNumber(): T extends number | number[] ? true : false;
    isBoolean(): T extends boolean | boolean[] ? true : false;
    isArray(): T extends Array<unknown> ? true : false;
    toKebabCase(): string;
    toConstCase(): string;
    toCamelCase(): string;
}
export {};
