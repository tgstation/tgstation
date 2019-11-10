import { Box } from './Box';

export const ColorBox = props => {
  const { color, ...rest } = props;
  return (
    <Box
      inline
      width={2}
      height={2}
      lineHeight={2}
      color={color}
      backgroundColor={color}
      content="."
      {...rest} />
  );
};
