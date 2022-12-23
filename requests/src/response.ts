import {Headers, RequestConfig} from "./types";
import {endsWith} from "./utils";
import createHeaders from "./headers";
const HttpService = game.GetService("HttpService");

export class Response {
    readonly isResponse: true;

    readonly request: RequestConfig;
    readonly url: string;
    readonly method: RequestConfig["method"];
    readonly code: number;
    readonly message: string;
    readonly ok: boolean;
    readonly time: number;
    readonly headers: Headers;
    readonly body: string;
    readonly contentType: string;

    constructor(request: RequestConfig, rawResponse: RequestAsyncResponse, time: number) {
        this.isResponse = true;

        this.request = request;
        this.url = request.url as string;
        this.method = request.method;

        this.code = rawResponse.StatusCode;
        this.message = rawResponse.StatusMessage;
        this.ok = this.code >= 200 && this.code < 300;

        this.time = time;

        this.headers = createHeaders(rawResponse.Headers);
        this.contentType = this.headers["content-type"] ?? ""

        this.body = rawResponse.Body
    }

    json(ignoreWarning?: boolean) {
        ignoreWarning ??= !(this.request.contentTypeWarning);

        if (!ignoreWarning && !endsWith(this.contentType, "/json")) {
            warn("You are calling json() on a response whose content type doesn't specify JSON");
        }

        return HttpService.JSONDecode(this.body);
    }
}