import { SpawnOptionsWithoutStdio } from 'child_process';
export declare class ExitError extends Error {
    code: number | null;
}
export declare const exec: (executable: string, args?: string[], options?: SpawnOptionsWithoutStdio) => Promise<unknown>;
