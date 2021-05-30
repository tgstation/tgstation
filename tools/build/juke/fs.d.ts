/// <reference types="node" />
import fs from 'fs';
export declare class File {
    readonly path: string;
    private _stat?;
    constructor(path: string);
    get stat(): fs.Stats | null;
    exists(): boolean;
    get mtime(): Date | null;
    touch(): void;
}
export declare class Glob {
    readonly path: string;
    constructor(path: string);
    toFiles(): File[];
}
/**
 * If true, source is newer than target.
 */
export declare const compareFiles: (sources: File[], targets: File[]) => string | false;
/**
 * Returns file stats for the provided path, or null if file is
 * not accessible.
 */
export declare const stat: (path: string) => fs.Stats | null;
/**
 * Resolves a glob pattern and returns files that are safe
 * to call `stat` on.
 */
export declare const resolveGlob: (globPath: string) => string[];
