import { Component, InfernoNode } from "inferno";
import { resolveAsset } from "../../assets";
import { ServerData } from "./data";

// Cache response so it's only sent once
let fetchServerData: Promise<ServerData> | undefined;

export class ServerPreferencesFetcher extends Component<{
  render: (serverData: ServerData | undefined) => InfernoNode,
}, {
  serverData?: ServerData;
}> {
  constructor() {
    super();

    this.state = {
      serverData: undefined,
    };
  }

  componentDidMount() {
    this.populateServerData();
  }

  async populateServerData() {
    if (!fetchServerData) {
      fetchServerData = fetch(
        resolveAsset("preferences.json")
      ).then(response => {
        return response.json();
      });
    }

    const preferencesData: ServerData
      = await fetchServerData;

    this.setState({
      serverData: preferencesData,
    });
  }

  render() {
    return this.props.render(this.state.serverData);
  }
}
