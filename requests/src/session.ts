import {GetRequestConfig, Headers, PostRequestConfig, RequestConfig, RequestData, SessionConfig} from "./types";
import {defaultSessionConfig} from "./defaults";
import {startsWith} from "./utils";
import {dispatch} from "./dispatch";
import {Response} from "./response";
import createHeaders from "./headers";
import {urlEncode} from "./urlencode";

export class Session {
    config: SessionConfig;

    constructor(config?: SessionConfig) {
        config ??= {};

        this.config = {
            ...defaultSessionConfig,
            ...config
        }
        this.config.headers = defaultSessionConfig.headers ?? createHeaders();

        if (config.headers) {
            for (let [key, val] of pairs(config.headers)) {
                this.config.headers[key] = val;
            }
        }
    }

    request(config: RequestConfig): Promise<Response> {
        let finalConfig: RequestConfig = {
            method: config.method.lower() as RequestConfig["method"],
            headers: createHeaders({
                "content-type": "text/plain",
                ...this.config.headers, ...config.headers
            }),

            params: {
                ...this.config.params, ...config.params
            },
            paramsArrayFormat: config.paramsArrayFormat ?? this.config.paramsArrayFormat,

            timeout: config.timeout ?? this.config.timeout,
            ratelimit: config.ratelimit ?? this.config.ratelimit,

            body: config.body
        }


        // processing

        let url = config.url ?? "";

        // first handle baseURLs
        if (!(startsWith(url, "http://") || startsWith(url, "https://"))) {
            if (this.config.baseURL || config.baseURL) {
                url = (this.config.baseURL || config.baseURL) + url;
            } else {
                throw `${config.url} is not an absolute URL and no baseURL was specified`;
            }
        }

        // next handle query string parameters
        if (config.params || this.config.params) {
            const transformParams = config.paramsSerializer ?? this.config.paramsSerializer;
            if (!transformParams) {
                throw "URL parameters were passed but no paramsSerializer was found";
            }

            const queryString = transformParams(
                {...this.config.params, ...config.params},
                finalConfig  // current config state is passed so transformer knows array format
            );

            // append if URL already included a query string
            url += (url.find("%?")[0] ? "&" : "?") + queryString;
        }
        finalConfig.url = url;

        // transform passed data
        if (config.data) {
            if (config.transformData) {
                finalConfig.body = config.transformData(config.data, finalConfig);
            } else if (this.config.transformData) {
                finalConfig.body = this.config.transformData(config.data, finalConfig);
            } else {
                throw "Data passed but data transformer is undefined"
            }
        }

        // handle cookies
        let cookies = {
            ...this.config.cookies,
            ...config.cookies
        }
        let serialCookies = [];
        for (let [name, value] of pairs(cookies)) {
            if (typeIs(value, "string")) {
                serialCookies.push(`${urlEncode(name)}=${urlEncode(value)}`)
            } else {
                serialCookies.push(`${urlEncode(name)}=${urlEncode(value.value)}`)
            }
        }

        finalConfig.headers ??= createHeaders();
        if (serialCookies.size() > 0) finalConfig.headers["cookie"] = serialCookies.join("; ");

        // create promise that dispatches request
        let requestPromise: Promise<Response> = new Promise((resolve, reject) => {
            // dispatch request
            let [success, responseOrRejection]: [boolean, Response | unknown] = dispatch(finalConfig).await();

            if (!success) {
                return reject(responseOrRejection);
            }

            const response = responseOrRejection as Response;

            if (config.throwForStatus && !response.ok) {
                return reject({
                    message: response.body,
                    response: response
                });
            }

            return resolve(response);
        });

        if (finalConfig.timeout) {
            requestPromise = requestPromise.timeout(finalConfig.timeout);
        }

        return requestPromise;
    }

    updateHeaders(headers: Headers) {
        this.config.headers ??= {};

        for (let [key, val] of pairs(headers)) {
            this.config.headers[key] = val;
        }
    }

    // shortcut functions

    get(url: string, config?: GetRequestConfig): Promise<Response> {
        return this.request({
            ...config,
            method: "get",
            url: url
        });
    }

    post(url: string, data?: RequestData, config?: PostRequestConfig): Promise<Response> {
        return this.request({
            ...config,
            method: "post",
            url: url,
            data: data
        })
    }

    put(url: string, data?: RequestData, config?: PostRequestConfig): Promise<Response> {
        return this.request({
            ...config,
            method: "put",
            url: url,
            data: data
        })
    }

    patch(url: string, data?: RequestData, config?: PostRequestConfig): Promise<Response> {
        return this.request({
            ...config,
            method: "patch",
            url: url,
            data: data
        })
    }

    delete(url: string, config?: GetRequestConfig): Promise<Response> {
        return this.request({
            ...config,
            method: "delete",
            url: url
        });
    }

    head(url: string, config?: GetRequestConfig): Promise<Response> {
        return this.request({
            ...config,
            method: "head",
            url: url
        });
    }

    options(url: string, config?: GetRequestConfig): Promise<Response> {
        return this.request({
            ...config,
            method: "options",
            url: url
        });
    }
}