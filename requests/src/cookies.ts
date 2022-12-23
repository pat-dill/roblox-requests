import {RequestConfig} from "./types";
import {endsWith, startsWith} from "./utils";
import {urlEncode} from "./urlencode";

export class Cookie {
    name: string;
    value: string;
    domain?: string;
    path?: string;

    constructor(name: string, value: string, domain?: string, path?: string) {
        this.name = name;
        this.value = value;
        this.domain = domain;
    }

    shouldSend(config: RequestConfig & { url: string }) {
        if (!(this.domain || this.path)) return true;

        const urlSplit = config.url.split("://");
        const segments = urlSplit[urlSplit.size() - 1].split("/");
        const host = segments[0]
        segments.remove(0);
        let path = "/" + segments.join("/");
        path = path.split("?")[0].split("#")[0];

        if (this.domain) {
            let matchDomain = this.domain;
            if (matchDomain.sub(1, 1) === ".") matchDomain = matchDomain.sub(2);

            if (!endsWith(host, matchDomain)) return false;
        }

        if (this.path) {
            if (!startsWith(path, this.path)) return false;
        }

        return true;
    }

    toString() {
        return `${urlEncode(this.name)}=${urlEncode(this.value)}`
    }
}

export type CookieJar = {
    [key: string]: Cookie
}

export type RequestCookies = {
    [key: string]: string | Cookie
}