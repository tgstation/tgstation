import { Component, InfernoNode } from "inferno";
import { resolveAsset } from "../../assets";

// Cache response so it's only sent once
let fetchServerData: Promise<Record<string, unknown>> | undefined;

export class ServerPreferencesFetcher extends Component<{
  render: (serverData: Record<string, unknown> | undefined) => InfernoNode,
}, {
  serverData?: Record<string, unknown>;
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

    const preferencesData: Record<string, unknown>
      = await fetchServerData;

    this.setState({
      serverData: preferencesData,
    });
  }

  render() {
    return this.props.render(this.state.serverData);
  }
}
