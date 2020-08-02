/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { Component, createRef } from 'inferno';
import { computeBoxClassName, computeBoxProps } from '../components/Box';
import { focusNodeOnMouseOver } from '../focus';

export const Layout = props => {
  const {
    className,
    theme = 'nanotrasen',
    children,
    ...rest
  } = props;
  return (
    <div className={'theme-' + theme}>
      <div
        className={classes([
          'Layout',
          className,
          ...computeBoxClassName(rest),
        ])}
        {...computeBoxProps(rest)}>
        {children}
      </div>
    </div>
  );
};

class LayoutContent extends Component {
  constructor() {
    super();
    this.ref = createRef();
  }

  componentDidMount() {
    this.unsubscribe = focusNodeOnMouseOver(this.ref.current);
  }

  componentWillUnmount() {
    this.unsubscribe();
  }

  render() {
    const {
      className,
      scrollable,
      children,
      ...rest
    } = this.props;
    return (
      <div
        ref={this.ref}
        className={classes([
          'Layout__content',
          scrollable && 'Layout__content--scrollable',
          className,
          ...computeBoxClassName(rest),
        ])}
        {...computeBoxProps(rest)}>
        {children}
      </div>
    );
  }
}

Layout.Content = LayoutContent;
