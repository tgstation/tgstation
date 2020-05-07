/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { Flex } from './Flex';

export const LabeledControls = props => {
  const {
    children,
    ...rest
  } = props;
  return (
    <Flex
      mx={-0.5}
      align="stretch"
      justify="space-between"
      {...rest}>
      {children}
    </Flex>
  );
};

const LabeledControlsItem = props => {
  const {
    label,
    children,
    ...rest
  } = props;
  return (
    <Flex.Item mx={1}>
      <Flex
        minWidth="52px"
        height="100%"
        direction="column"
        align="center"
        textAlign="center"
        justify="space-between"
        {...rest}>
        <Flex.Item />
        <Flex.Item>
          {children}
        </Flex.Item>
        <Flex.Item color="label">
          {label}
        </Flex.Item>
      </Flex>
    </Flex.Item>
  );
};

LabeledControls.Item = LabeledControlsItem;
