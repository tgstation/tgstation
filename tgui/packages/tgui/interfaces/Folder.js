import { useBackend } from "../backend";
import { Box, Button, Flex, Section } from "../components";
import { Window } from "../layouts";

export const Folder = (props, context) => {
  const { act, data } = useBackend(context);
  const { folder_name, bg_color, contents, contents_ref } = data;
  return (
    <Window title={folder_name || "Folder"} width={400} height={500}>
      <Window.Content backgroundColor={bg_color || "#7f7f7f"} scrollable>
        {contents.length > 0 && (
            {contents.map((item, index) => (
              <>
                <Flex
                  color="black"
                  backgroundColor="white"
                  style={{ padding: "2px 2px 0 2px" }}
                >
                  <Flex.Item align="center" grow={1}>
                    <Box align="center">{item}</Box>
                  </Flex.Item>
                  <Flex.Item>
                    {
                      <Button
                        icon="search"
                        onClick={() =>
                          act("examine", { ref: contents_ref[index] })
                        }
                      />
                    }
                    <Button
                      icon="eject"
                      onClick={() =>
                        act("remove", { ref: contents_ref[index] })
                      }
                    />
                  </Flex.Item>
                </Flex>
                <Box style={{ height: "0.25em" }} />
              </>
            ))}
            :{

              <Section>
                <Box color="grey" align="center">
                  This folder is empty!
                </Box>
              </Section>
            }
        )}
      </Window.Content>
    </Window>
  );
};
