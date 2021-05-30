import { Parameter } from './parameter';
declare type BuildFn = (...args: any) => unknown;
export declare type Target = {
    name: string;
    dependsOn: Target[];
    executes: BuildFn[];
    inputs: string[];
    outputs: string[];
    parameters: Parameter[];
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
    dependsOn?: Target[];
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
    executes?: BuildFn | BuildFn[];
    /**
     * Files that are consumed by this target.
     */
    inputs?: string[];
    /**
     * Files that are produced by this target. Additionally, they are also
     * touched every time target finishes executing in order to stop
     * this target from re-running.
     */
    outputs?: string[];
    /**
     * Parameters that are local to this task. Can be retrieved via `get`
     * in the executor function.
     */
    parameters?: Parameter[];
};
export declare const createTarget: (target: TargetConfig) => Target;
export {};
