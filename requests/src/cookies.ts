import {RequestConfig} from "./types";
import {endsWith, startsWith} from "./utils";
import {urlDecode, urlEncode} from "./urlencode";

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

    shouldSend(config: RequestConfig) {
        if (!(this.domain || this.path)) return true;
        if (!config.url) return false;

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
        return urlEncode(this.value, false);
    }

    static parse(setCookie: string): Cookie {
        const attrs = setCookie.split("; ");

        let cookieName = attrs[0].split("=")[0];
        if (startsWith(cookieName, '"')) {
            // noinspection TypeScriptValidateJSTypes
            cookieName = cookieName.sub(2, cookieName.size() - 1);
        }
        cookieName = urlDecode(cookieName);

        let cookieVal = attrs[0].split("=")[1];
        if (startsWith(cookieVal, '"')) {
            // noinspection TypeScriptValidateJSTypes
            cookieVal = cookieVal.sub(2, cookieName.size() - 1);
        }
        cookieVal = urlDecode(cookieVal);

        const cookie = new Cookie(cookieName, cookieVal);

        attrs.remove(0);

        return cookie
    }
}

export type CookieJar = {
    [key: string]: Cookie
}

export type RequestCookies = {
    [key: string]: string | Cookie
}

export const parseSetCookie = (setCookie: string | string[]): CookieJar => {
    if (typeIs(setCookie, "string")) {
        const cookie = Cookie.parse(setCookie);
        return {
            [cookie.name]: cookie
        }
    } else {
        const cookies: CookieJar = {};

        for (const [_, cookieStr] of ipairs(setCookie)) {
            const cookie = Cookie.parse(cookieStr);
            cookies[cookie.name] = cookie
        }

        return cookies
    }
}