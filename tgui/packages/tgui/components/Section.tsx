/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { BoxProps, computeBoxClassName, computeBoxProps } from './Box';
import { Component, InfernoNode, RefObject, createRef } from 'inferno';
import { addScrollableNode, removeScrollableNode } from '../events';
import { canRender, classes } from 'common/react';

export type SectionProps = BoxProps & {
  className?: string;
  title?: InfernoNode;
  buttons?: InfernoNode;
  fill?: boolean;
  fitted?: boolean;
  scrollable?: boolean;
  scrollableHorizontal?: boolean;
  /** @deprecated This property no longer works, please remove it. */
  level?: never;
  /** @deprecated Please use `scrollable` property */
  overflowY?: never;
  /** @member Allows external control of scrolling. */
  scrollableRef?: RefObject<HTMLDivElement>;
  /** @member Callback function for the `scroll` event */
  onScroll?: (this: GlobalEventHandlers, ev: Event) => any;
};

export class Section extends Component<SectionProps> {
  scrollableRef: RefObject<HTMLDivElement>;
  scrollable: boolean;
  onScroll?: (this: GlobalEventHandlers, ev: Event) => any;
  scrollableHorizontal: boolean;

  constructor(props) {
    super(props);
    this.scrollableRef = props.scrollableRef || createRef();
    this.scrollable = props.scrollable;
    this.onScroll = props.onScroll;
    this.scrollableHorizontal = props.scrollableHorizontal;
  }

  componentDidMount() {
    if (this.scrollable || this.scrollableHorizontal) {
      addScrollableNode(this.scrollableRef.current as HTMLElement);
      if (this.onScroll && this.scrollableRef.current) {
        this.scrollableRef.current.onscroll = this.onScroll;
      }
    }
  }

  componentWillUnmount() {
    if (this.scrollable || this.scrollableHorizontal) {
      removeScrollableNode(this.scrollableRef.current as HTMLElement);
    }
  }

  render() {
    const {
      className,
      title,
      buttons,
      fill,
      fitted,
      scrollable,
      scrollableHorizontal,
      children,
      onScroll,
      ...rest
    } = this.props;
    const hasTitle = canRender(title) || canRender(buttons);
    return (
      <div
        className={classes([
          'Section',
          Byond.IS_LTE_IE8 && 'Section--iefix',
          fill && 'Section--fill',
          fitted && 'Section--fitted',
          scrollable && 'Section--scrollable',
          scrollableHorizontal && 'Section--scrollableHorizontal',
          className,
          computeBoxClassName(rest),
        ])}
        {...computeBoxProps(rest)}>
        {hasTitle && (
          <div className="Section__title">
            <span className="Section__titleText">{title}</span>
            <div className="Section__buttons">{buttons}</div>
          </div>
        )}
        <div className="Section__rest">
          <div
            ref={this.scrollableRef}
            onScroll={onScroll}
            className="Section__content">
            {children}
          </div>
        </div>
      </div>
    );
  }
}
