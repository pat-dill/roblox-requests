import {Params, RequestConfig} from "./types";
import {urlEncode} from "./urlencode";

export default function serializeParams(params: Params, config: RequestConfig) {
    let serials: string[] = [];

    for (let [key, val] of pairs(params)) {
        if (typeIs(val, "string") || typeIs(val, "number")) {
            val = urlEncode(val);
            serials.push(`${key}=${val}`);
        } else {
            switch (config?.paramsArrayFormat) {
                case "comma":
                    let combined = val.map(urlEncode).join(",");
                    serials.push(`${key}=${combined}`);

                    break;

                case "repeat":
                default:
                    for (let [_, subval] of ipairs(val)) {
                        subval = urlEncode(subval);
                        serials.push(`${key}=${subval}`);
                    }
                    break;
            }
        }
    }
    return serials.join("&");
}