/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { Flex } from './Flex';

export const LabeledControls = (props) => {
  const { children, wrap, ...rest } = props;
  return (
    <Flex
      mx={-0.5}
      wrap={wrap}
      align="stretch"
      justify="space-between"
      {...rest}>
      {children}
    </Flex>
  );
};

const LabeledControlsItem = (props) => {
  const { label, children, mx = 1, ...rest } = props;
  return (
    <Flex.Item mx={mx}>
      <Flex
        height="100%"
        direction="column"
        align="center"
        textAlign="center"
        justify="space-between"
        {...rest}>
        <Flex.Item />
        <Flex.Item>{children}</Flex.Item>
        <Flex.Item color="label">{label}</Flex.Item>
      </Flex>
    </Flex.Item>
  );
};

LabeledControls.Item = LabeledControlsItem;
