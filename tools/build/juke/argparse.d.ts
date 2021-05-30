import { Parameter, ParameterMap } from './parameter';
declare type TaskArgs = [
    /** Task name */
    string,
    /** Task arguments */
    ...string[]
];
/**
 * Returns global flags and tasks, which is an array of this format:
 * `[[taskName, ...taskArgs], ...]`
 * @param args List of command line arguments
 */
export declare const prepareArgs: (args: string[]) => {
    globalFlags: string[];
    taskArgs: TaskArgs[];
};
export declare const parseArgs: (args: string[], parameters: Parameter[]) => ParameterMap;
export {};
