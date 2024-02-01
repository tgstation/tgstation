import { Component, createRef, ReactNode, RefObject } from 'react';

import { Button, Section, Stack } from '../../components';
import { FlexProps } from '../../components/Flex';

type TabbedMenuProps = {
  categoryEntries: [string, ReactNode][];
  contentProps?: FlexProps;
};

export class TabbedMenu extends Component<TabbedMenuProps> {
  categoryRefs: Record<string, RefObject<HTMLDivElement>> = {};
  sectionRef: RefObject<HTMLDivElement> = createRef();

  getCategoryRef(category: string): RefObject<HTMLDivElement> {
    if (!this.categoryRefs[category]) {
      this.categoryRefs[category] = createRef();
    }

    return this.categoryRefs[category];
  }

  render() {
    return (
      <Stack vertical fill>
        <Stack.Item>
          <Stack fill px={5}>
            {this.props.categoryEntries.map(([category]) => {
              return (
                <Stack.Item key={category} grow basis="content">
                  <Button
                    align="center"
                    fontSize="1.2em"
                    fluid
                    onClick={() => {
                      const offsetTop =
                        this.categoryRefs[category].current?.offsetTop;

                      if (offsetTop === undefined) {
                        return;
                      }

                      const currentSection = this.sectionRef.current;

                      if (!currentSection) {
                        return;
                      }

                      currentSection.scrollTop = offsetTop;
                    }}
                  >
                    {category}
                  </Button>
                </Stack.Item>
              );
            })}
          </Stack>
        </Stack.Item>

        <Stack.Item
          grow
          innerRef={this.sectionRef}
          position="relative"
          overflowY="scroll"
          {...{
            ...this.props.contentProps,

            // Otherwise, TypeScript complains about invalid prop
            className: undefined,
          }}
        >
          <Stack vertical fill px={2}>
            {this.props.categoryEntries.map(([category, children]) => {
              return (
                <Stack.Item
                  key={category}
                  innerRef={this.getCategoryRef(category)}
                >
                  <Section fill title={category}>
                    {children}
                  </Section>
                </Stack.Item>
              );
            })}
          </Stack>
        </Stack.Item>
      </Stack>
    );
  }
}
