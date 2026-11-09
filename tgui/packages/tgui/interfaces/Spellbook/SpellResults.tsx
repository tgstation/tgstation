import { useAtom } from 'jotai';
import { Box, Button, Section, Stack } from 'tgui-core/components';
import { heightSection, tabAtom, widthSection } from '.';
import { CategoryDisplay } from './CategoryDisplay';
import { TAB2NAME } from './constants';

export function SpellResults() {
  const [tabIndex, setTabIndex] = useAtom(tabAtom);

  const activeCat = TAB2NAME[tabIndex - 1];
  const activeNextCat = TAB2NAME[tabIndex];

  return (
    <>
      <Stack.Item grow>
        <Section
          scrollable={activeCat.scrollable}
          textAlign="center"
          width={widthSection}
          height={heightSection}
          fill
          title={activeCat.title}
          buttons={
            <>
              <Button
                mr={57}
                disabled={tabIndex === 1}
                icon="arrow-left"
                onClick={() => setTabIndex(tabIndex - 2)}
              >
                Previous Page
              </Button>
              <Box textAlign="right" bold mt={-3.3} mr={1}>
                {tabIndex}
              </Box>
            </>
          }
        >
          <CategoryDisplay activeCat={activeCat} />
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          scrollable={activeNextCat.scrollable}
          textAlign="center"
          width={widthSection}
          height={heightSection}
          fill
          title={activeNextCat.title}
          buttons={
            <>
              <Button
                mr={0}
                icon="arrow-right"
                disabled={tabIndex === 11}
                onClick={() => setTabIndex(tabIndex + 2)}
              >
                Next Page
              </Button>
              <Box textAlign="left" bold mt={-3.3} ml={-59.8}>
                {tabIndex + 1}
              </Box>
            </>
          }
        >
          <CategoryDisplay activeCat={activeNextCat} />
        </Section>
      </Stack.Item>
    </>
  );
}
