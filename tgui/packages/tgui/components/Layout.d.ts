import { Component } from 'inferno';

declare interface LayoutProps {
  /**
   * Makes window resizable.
   */
  resizable: boolean,
  /**
   * Theme applied to the window
   */
  theme: string = 'nanotrasen',
  children: any,
};

export declare class Layout
  extends Component<LayoutProps, any> {};

declare interface LayoutContentProps {
  /**
   * Makes content scrollable.
   */
  scrollable: boolean,
  children: any,
};

export declare class LayoutContent
  extends Component<LayoutContentProps, any> { };
