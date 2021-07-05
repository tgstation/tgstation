import { Parameter, ParameterType } from './parameter';
export declare type ExecutionContext = {
    /** Get parameter value. */
    get: <T extends ParameterType>(parameter: Parameter<T>) => (T extends Array<unknown> ? T : T | null);
};
declare type BooleanLike = boolean | null | undefined;
declare type WithExecutionContext<R> = (context: ExecutionContext) => R | Promise<R>;
declare type WithOptionalExecutionContext<R> = R | WithExecutionContext<R>;
declare type DependsOn = WithOptionalExecutionContext<(Target | BooleanLike)[]>;
declare type ExecutesFn = WithExecutionContext<unknown>;
declare type OnlyWhenFn = WithExecutionContext<BooleanLike>;
export declare type FileIo = WithOptionalExecutionContext<(string | BooleanLike)[]>;
export declare type Target = {
    name: string;
    dependsOn: DependsOn;
    executes?: ExecutesFn;
    inputs: FileIo;
    outputs: FileIo;
    parameters: Parameter[];
    onlyWhen?: OnlyWhenFn;
};
declare type TargetConfig = {
    /**
     * Target name. This parameter is required.
     */
    name: string;
    /**
     * Dependencies for this target. They will be ran before executing this
     * target, and may run in parallel.
     */
    dependsOn?: DependsOn;
    /**
     * Function that is delegated to the execution engine for building this
     * target. It is normally an async function, which accepts a single
     * argument - execution context (contains `get` for interacting with
     * parameters).
     *
     * @example
     * executes: async ({ get }) => {
     *   console.log(get(Parameter));
     * },
     */
    executes?: ExecutesFn;
    /**
     * Files that are consumed by this target.
     */
    inputs?: FileIo;
    /**
     * Files that are produced by this target. Additionally, they are also
     * touched every time target finishes executing in order to stop
     * this target from re-running.
     */
    outputs?: FileIo;
    /**
     * Parameters that are local to this task. Can be retrieved via `get`
     * in the executor function.
     */
    parameters?: Parameter[];
    /**
     * Target will run only when this function returns true. It accepts a
     * single argument - execution context.
     */
    onlyWhen?: OnlyWhenFn;
};
export declare const createTarget: (target: TargetConfig) => Target;
export {};
