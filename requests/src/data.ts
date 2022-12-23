import {RequestConfig, RequestData} from "./types";

const HttpService = game.GetService("HttpService");

export default function transformData(data: RequestData, config: RequestConfig) {
    if (typeIs(data, "string")) {
        return data as string;
    } else {
        if (typeIs(data, "table")) {
            config.headers ??= {};
            config.headers["Content-Type"] = "application/json";
        }

        return HttpService.JSONEncode(data);
    }
}