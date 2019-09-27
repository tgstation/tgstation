import { computeBoxProps } from './Box';

export const computeFlexProps = props => {
  const {
    direction,
    wrap,
    align,
    ...rest
  } = props;
  return {
    style: {
      ...rest.style,
      'display': 'flex',
      'flex-direction': direction,
      'flex-wrap': wrap,
      'align-items': align,
    },
    ...rest,
  };
};

export const Flex = props => (
  <div {...computeBoxProps(computeFlexProps(props))} />
);

export const computeFlexItemProps = props => {
  const {
    grow,
    order,
    align,
    ...rest
  } = props;
  return {
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
  <div {...computeBoxProps(computeFlexItemProps(props))} />
);

Flex.Item = FlexItem;
