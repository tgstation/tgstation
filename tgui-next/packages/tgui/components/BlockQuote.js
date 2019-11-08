import { Box } from './Box';

export const BlockQuote = props => {
  const { style, ...rest } = props;
  return (
    <Box
      style={{
        'color': 'rgba(255, 255, 255, 0.5)',
        'border-left': '2px solid rgba(255, 255, 255, 0.5)',
        'padding-left': '6px',
        ...style,
      }}
      {...rest} />
  );
};
