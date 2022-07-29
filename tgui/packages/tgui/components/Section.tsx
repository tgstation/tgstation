/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { canRender, classes } from 'common/react';
import { Component, createRef, InfernoNode, RefObject } from 'inferno';
import { addScrollableNode, removeScrollableNode } from '../events';
import { BoxProps, computeBoxClassName, computeBoxProps } from './Box';

type SectionProps = BoxProps & {
  className?: string;
  title?: InfernoNode;
  buttons?: InfernoNode;
  fill?: boolean;
  fitted?: boolean;
  scrollable?: boolean;
  scrollableHorizontal?: boolean;
  /** @deprecated This property no longer works, please remove it. */
  level?: boolean;
  /** @deprecated Please use `scrollable` property */
  overflowY?: any;
};

export class Section extends Component<SectionProps> {
  scrollableRef: RefObject<HTMLDivElement>;
  scrollable: boolean;
  scrollableHorizontal: boolean;

  constructor(props) {
    super(props);
    this.scrollableRef = createRef();
    this.scrollable = props.scrollable;
    this.scrollableHorizontal = props.scrollableHorizontal;
  }

  componentDidMount() {
    if (this.scrollable || this.scrollableHorizontal) {
      addScrollableNode(this.scrollableRef.current);
    }
  }

  componentWillUnmount() {
    if (this.scrollable || this.scrollableHorizontal) {
      removeScrollableNode(this.scrollableRef.current);
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
          <div ref={this.scrollableRef} className="Section__content">
            {children}
          </div>
        </div>
      </div>
    );
  }
}
