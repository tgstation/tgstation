/// <reference types="node" />
import EventEmitter from 'events';
import { Parameter, ParameterType } from './parameter';
import { Target } from './target';
export declare type RunnerConfig = {
    targets?: Target[];
    default?: Target;
    parameters?: Parameter[];
};
export declare type ExecutionContext = {
    /** Get parameter value. */
    get: <T extends ParameterType>(parameter: Parameter<T>) => (T extends Array<unknown> ? T : T | null);
};
export declare const runner: {
    defaultTarget?: Target | undefined;
    targets: Target[];
    parameters: Parameter[];
    workers: Worker[];
    configure(config: RunnerConfig): void;
    start(): Promise<number>;
};
declare class Worker {
    readonly target: Target;
    readonly context: ExecutionContext;
    dependencies: Set<Target>;
    generator?: AsyncGenerator;
    emitter: EventEmitter;
    hasFailed: boolean;
    constructor(target: Target, context: ExecutionContext);
    resolveDependency(target: Target): void;
    rejectDependency(target: Target): void;
    start(): void;
    onFinish(fn: () => void): void;
    onFail(fn: () => void): void;
    private debugLog;
    private process;
}
export {};
