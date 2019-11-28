import { Box } from './Box';

export const Dimmer = props => {
  const { style, ...rest } = props;
  return (
    <Box
      style={{
        position: 'absolute',
        top: 0,
        bottom: 0,
        left: 0,
        right: 0,
        'background-color': 'rgba(0, 0, 0, 0.75)',
        'z-index': 1,
        ...style,
      }}
      {...rest} />
  );
};
