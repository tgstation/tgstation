import { classes, pureComponentHooks } from 'common/react';
import { Box } from './Box';

export const computeFlexProps = props => {
  const {
    className,
    direction,
    wrap,
    align,
    justify,
    spacing = 0,
    ...rest
  } = props;
  return {
    className: classes([
      'Flex',
      spacing > 0 && 'Flex--spacing--' + spacing,
      className,
    ]),
    style: {
      ...rest.style,
      'flex-direction': direction,
      'flex-wrap': wrap,
      'align-items': align,
      'justify-content': justify,
    },
    ...rest,
  };
};

export const Flex = props => (
  <Box {...computeFlexProps(props)} />
);

Flex.defaultHooks = pureComponentHooks;

export const computeFlexItemProps = props => {
  const {
    className,
    grow,
    order,
    align,
    ...rest
  } = props;
  return {
    className: classes([
      'Flex__item',
      className,
    ]),
    style: {
      ...rest.style,
      'flex-grow': grow,
      'order': order,
      'align-self': align,
    },
    ...rest,
  };
};

export const FlexItem = props => (
  <Box {...computeFlexItemProps(props)} />
);

FlexItem.defaultHooks = pureComponentHooks;

Flex.Item = FlexItem;
