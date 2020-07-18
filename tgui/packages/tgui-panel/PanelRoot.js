import { toFixed } from 'common/math';
import { Component, createRef } from 'inferno';
import { chat } from 'tgchat';
import { Button, Flex, Input, LabeledList, NumberInput, Section } from 'tgui/components';
import { Pane } from 'tgui/layouts';
import { logger } from 'tgui/logging';

export class PanelRoot extends Component {
  constructor() {
    super();
    this.chatRef = createRef();
    this.state = {
      lineHeight: 1.5,
      fontSize: 12,
    };
    this.setLineHeight = lineHeight => this.setState({ lineHeight });
    this.setFontSize = fontSize => this.setState({ fontSize });
  }

  componentDidMount() {
    logger.log('panel mounted');
    if (chat.rootElement) {
      this.chatRef.current.append(chat.rootElement);
    }
    else {
      chat.rootElement = this.chatRef.current;
    }
  }

  render() {
    const {
      fontSize,
      lineHeight,
    } = this.state;
    return (
      <Pane fontSize={fontSize + 'pt'}>
        <Pane.Content>
          <Flex
            direction="column"
            height="100%">
            <Flex.Item>
              <Section title="Settings">
                <LabeledList>
                  <LabeledList.Item label="Font size">
                    <NumberInput
                      width="4em"
                      step={1}
                      stepPixelSize={10}
                      minValue={8}
                      maxValue={36}
                      value={fontSize}
                      unit="pt"
                      format={value => toFixed(value)}
                      onDrag={(e, value) => this.setFontSize(value)} />
                  </LabeledList.Item>
                  <LabeledList.Item label="Line height">
                    <NumberInput
                      width="4em"
                      step={0.01}
                      stepPixelSize={2}
                      minValue={1}
                      maxValue={4}
                      value={lineHeight}
                      format={value => toFixed(value, 2)}
                      onDrag={(e, value) => this.setLineHeight(value)} />
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Flex.Item>
            <Flex.Item
              mt={1}
              position="relative"
              grow={1}
              basis={0}>
              <Section fill overflowY="scroll">
                <div
                  ref={this.chatRef}
                  style={{
                    'line-height': lineHeight,
                  }} />
              </Section>
              <Button
                position="absolute"
                top={1}
                right={2}
                style={{
                  'box-shadow': '0 0 16px #000',
                }}
                icon="cog" />
            </Flex.Item>
            <Flex.Item mt={1}>
              <Input
                fluid
                placeholder="Message..." />
            </Flex.Item>
          </Flex>
        </Pane.Content>
      </Pane>
    );
  }
}
