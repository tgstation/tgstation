/// <reference types="node" />
import EventEmitter from 'events';
import { Parameter } from './parameter';
import { ExecutionContext, Target } from './target';
export declare type RunnerConfig = {
    targets?: Target[];
    default?: Target;
    parameters?: Parameter[];
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
    readonly dependsOn: Target[];
    dependencies: Set<Target>;
    generator?: AsyncGenerator;
    emitter: EventEmitter;
    hasFailed: boolean;
    constructor(target: Target, context: ExecutionContext, dependsOn: Target[]);
    resolveDependency(target: Target): void;
    rejectDependency(target: Target): void;
    start(): void;
    onFinish(fn: () => void): void;
    onFail(fn: () => void): void;
    private debugLog;
    private process;
}
export {};
