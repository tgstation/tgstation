import fs from "node:fs";
import https from "node:https";
import Juke from "../juke/index.js";

export function downloadFile(url: string, file: string): Promise<string> {
  return new Promise((resolve, reject) => {
    const file_stream = fs.createWriteStream(file);
    https
      .get(url, function (response) {
        if (response.statusCode === 302 && response.headers.location) {
          file_stream.close();
          downloadFile(response.headers.location, file).then(() =>
            resolve("ok"),
          );
          return;
        }
        if (response.statusCode !== 200) {
          Juke.logger.error(
            `Failed to download ${url}: Status ${response.statusCode}`,
          );
          file_stream.close();
          reject();
          return;
        }
        response.pipe(file_stream);

        // after download completed close filestream
        file_stream.on("finish", () => {
          file_stream.close();
          resolve("ok");
        });
      })
      .on("error", (err) => {
        file_stream.close();
        Juke.logger.error(`Failed to download ${url}: ${err.message}`);
        reject();
      });
  });
}
