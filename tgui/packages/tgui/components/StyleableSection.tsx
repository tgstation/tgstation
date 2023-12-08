import { PropsWithChildren, ReactNode } from 'react';
import { Box } from './Box';

type Props = Partial<{
  style: Record<string, any>;
  titleStyle: Record<string, any>;
  textStyle: Record<string, any>;
  title: ReactNode;
  titleSubtext: string;
}> &
  PropsWithChildren;

// The cost of flexibility and prettiness.
export const StyleableSection = (props: Props) => {
  return (
    <Box style={props.style}>
      {/* Yes, this box (line above) is missing the "Section" class. This is very intentional, as the layout looks *ugly* with it.*/}
      <Box className="Section__title" style={props.titleStyle}>
        <Box className="Section__titleText" style={props.textStyle}>
          {props.title}
        </Box>
        <div className="Section__buttons">{props.titleSubtext}</div>
      </Box>
      <Box className="Section__rest">
        <Box className="Section__content">{props.children}</Box>
      </Box>
    </Box>
  );
};
