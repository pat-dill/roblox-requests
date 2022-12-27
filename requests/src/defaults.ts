import {Params, SessionConfig} from "./types";
import createHeaders from "./headers";
import {urlEncode} from "./urlencode";
import serializeParams from "./params";
import transformData from "./data";
const HttpService = game.GetService("HttpService");

export const defaultSessionConfig: SessionConfig = {
    headers: createHeaders({}),
    paramsArrayFormat: "repeat",
    paramsSerializer: serializeParams,

    transformData: transformData,

    cookies: {},

    throwForStatus: true,
    contentTypeWarning: true
}