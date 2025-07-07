import { ComponentProps, ReactNode, useRef } from 'react';
import { Button, Flex, Section, Stack } from 'tgui-core/components';

type TabbedMenuProps = {
  categoryEntries: [string, ReactNode][];
  contentProps?: ComponentProps<typeof Flex>;
};

export function TabbedMenu(props: TabbedMenuProps) {
  const sectionRef = useRef<HTMLDivElement>(null);
  const categoryRefs = useRef<Record<string, HTMLDivElement | null>>({});

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Stack fill px={5}>
          {props.categoryEntries.map(([category]) => (
            <Stack.Item key={category} grow basis="content">
              <Button
                align="center"
                fontSize="1.2em"
                fluid
                onClick={() => {
                  const offsetTop = categoryRefs.current[category]?.offsetTop;
                  if (offsetTop === undefined) {
                    return;
                  }

                  const currentSection = sectionRef.current;
                  if (!currentSection) {
                    return;
                  }

                  currentSection.scrollTop = offsetTop;
                }}
              >
                {category}
              </Button>
            </Stack.Item>
          ))}
        </Stack>
      </Stack.Item>

      <Stack.Item
        grow
        ref={sectionRef}
        position="relative"
        overflowY="scroll"
        {...props.contentProps}
      >
        <Stack vertical fill px={2}>
          {props.categoryEntries.map(([category, children]) => (
            <div
              key={category}
              ref={(ref) => {
                categoryRefs.current[category] = ref;
              }}
            >
              <Section fill title={category}>
                {children}
              </Section>
            </div>
          ))}
        </Stack>
      </Stack.Item>
    </Stack>
  );
}
