import {Headers, RequestConfig} from "./types";
import {endsWith} from "./utils";
import createHeaders from "./headers";
import {CookieJar, parseSetCookie} from "./cookies";
import {Session} from "./session";
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
    readonly content: string;
    readonly contentType: string;
    readonly cookies: CookieJar;
    private _session: Session;

    constructor(request: RequestConfig, rawResponse: RequestAsyncResponse, time: number, session: Session) {
        this.isResponse = true;
        this._session = session

        this.request = request;
        this.url = request.url as string;
        this.method = request.method;

        this.code = rawResponse.StatusCode;
        this.message = rawResponse.StatusMessage;
        this.ok = this.code >= 200 && this.code < 300;

        this.time = time;

        this.headers = createHeaders(rawResponse.Headers);
        this.contentType = this.headers["content-type"] ?? ""

        this.content = rawResponse.Body

        if (this.headers["set-cookie"]) {
            this.cookies = parseSetCookie(this.headers["set-cookie"])
        } else {
            this.cookies = {}
        }

        this._session.config.cookies ??= {};
        for (const [name, cookie] of pairs(this.cookies)) {
            this._session.config.cookies[name] = cookie;
        }
    }

    json(ignoreWarning?: boolean) {
        ignoreWarning ??= !(this.request.contentTypeWarning);

        if (!ignoreWarning && !endsWith(this.contentType, "/json")) {
            warn("You are calling json() on a response whose content type doesn't specify JSON." +
                " You can disable this warning by setting http.config.contentTypeWarning = false");
        }

        return HttpService.JSONDecode(this.content);
    }
}