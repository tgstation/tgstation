import { Box, Section } from 'tgui-core/components';

export function ScrollableSection(props) {
  const { contents, header } = props;

  return (
    <Section fill scrollable>
      <Box fontSize="20px" textAlign="center">
        {header}
      </Box>
      <Box position="relative" top="10px">
        {contents}
      </Box>
    </Section>
  );
}
