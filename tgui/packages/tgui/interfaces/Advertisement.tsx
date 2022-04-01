import { useBackend } from "../backend";
import { Pane } from "../layouts";
import { recallWindowGeometry, getScreenSize } from "../drag";
import { Box, Section, Stack } from "../components";

export const Advertisement = (props, context) => {
  const { act, data } = useBackend<any>(context);
  return (
    <Pane
      onComponentDidMount={() => {
        recallWindowGeometry({ size: getScreenSize() });
      }}
      theme="abductor">
      <Box
        height="100%"
        textAlign="center"
        fontSize="32px">
        <Stack
          vertical
          fill>
          <Stack.Item>
            <Section title="Advertisement (20 Seconds...)">
              Hello, {data.customer}!<br />
              {"You're"} <blink>TOO POOR</blink> to open this door at the price of
              {" "}<span className="rainbow-text">{data.price} Credits</span>
              <br />
              so {"we're"} giving you a SPECIAL OFFER to get this door open!
              It might be slow, but at least {"it's"} free!
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill title="SPACE COLA">
              <marquee
                scrolldelay="40"
                truespeed
              >
                <span className="rainbow-text">
                  Enjoy a refreshing SPACE COLA beverage today, from the nearest
                  Space Cola Vendor!
                </span>

              </marquee>
              <br />
              <img
                className="Advertisement"
                width="10%"
                src="https://file.house/xwgu.png" />
            </Section>
          </Stack.Item>
        </Stack>
      </Box>
    </Pane>
  );
};
