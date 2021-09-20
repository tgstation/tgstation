/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

// Webpack asset modules.
// Should match extensions used in webpack config.
declare module '*.png' {
  const content: string;
  export default content;
}

declare module '*.jpg' {
  const content: string;
  export default content;
}

declare module '*.svg' {
  const content: string;
  export default content;
}

type ByondType = {
  /**
   * True if javascript is running in BYOND.
   */
  IS_BYOND: boolean;

  /**
   * True if browser is IE8 or lower.
   */
  IS_LTE_IE8: boolean;

  /**
   * True if browser is IE9 or lower.
   */
  IS_LTE_IE9: boolean;

  /**
   * True if browser is IE10 or lower.
   */
  IS_LTE_IE10: boolean;

  /**
   * True if browser is IE11 or lower.
   */
  IS_LTE_IE11: boolean;

  /**
   * Makes a BYOND call.
   *
   * If path is empty, this will trigger a Topic call.
   * You can reference a specific object by setting the "src" parameter.
   *
   * See: https://secure.byond.com/docs/ref/skinparams.html
   */
  call(path: string, params: object): void;

  /**
   * Makes an asynchronous BYOND call. Returns a promise.
   */
  callAsync(path: string, params: object): Promise<any>;

  /**
   * Makes a Topic call.
   *
   * You can reference a specific object by setting the "src" parameter.
   */
  topic(params: object): void;

  /**
   * Runs a command or a verb.
   */
  command(command: string): void;

  /**
   * Retrieves all properties of the BYOND skin element.
   *
   * Returns a promise with a key-value object containing all properties.
   */
  winget(id: string): Promise<object>;

  /**
   * Retrieves all properties of the BYOND skin element.
   *
   * Returns a promise with a key-value object containing all properties.
   */
  winget(id: string, propName: '*'): Promise<object>;

  /**
   * Retrieves an exactly one property of the BYOND skin element,
   * as defined in `propName`.
   *
   * Returns a promise with the value of that property.
   */
  winget(id: string, propName: string): Promise<any>;

  /**
   * Retrieves multiple properties of the BYOND skin element,
   * as defined in the `propNames` array.
   *
   * Returns a promise with a key-value object containing listed properties.
   */
  winget(id: string, propNames: string[]): Promise<object>;

  /**
   * Assigns properties to BYOND skin elements.
   */
  winset(props: object): void;

  /**
   * Assigns properties to the BYOND skin element.
   */
  winset(id: string, props: object): void;

  /**
   * Sets a property on the BYOND skin element to a certain value.
   */
  winset(id: string, propName: string, propValue: any): void;

  /**
   * Parses BYOND JSON.
   *
   * Uses a special encoding to preverse Infinity and NaN.
   */
  parseJson(text: string): any;

  /**
   * Loads a stylesheet into the document.
   */
  loadCss(url: string): void;

  /**
   * Loads a script into the document.
   */
  loadJs(url: string): void;
};

/**
 * Object that provides access to Byond Skin API and is available in
 * any tgui application.
 */
const Byond: ByondType;

interface Window {
  /**
   * ID of the Byond window this script is running on.
   * Should be used as a parameter to winget/winset.
   */
  __windowId__: string;
  __updateQueue__: unknown[];
  update: (msg: unknown) => unknown;
  Byond: ByondType;
}
