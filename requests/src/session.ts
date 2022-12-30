import {GetRequestConfig, Headers, Params, PostRequestConfig, RequestConfig, RequestData, SessionConfig} from "./types";
import {defaultSessionConfig} from "./defaults";
import {startsWith} from "./utils";
import {dispatch} from "./dispatch";
import {Response} from "./response";
import createHeaders from "./headers";
import {urlEncode} from "./urlencode";
import {File, Form, FormFields} from "./form";

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
            for (const [key, val] of pairs(config.headers)) {
                this.config.headers[key] = val;
            }
        }
    }

    prepareRequest(config: RequestConfig): RequestConfig {
        // prepares final request data based on session and request configs

        const finalConfig: RequestConfig = {
            method: config.method.lower() as RequestConfig["method"],
            headers: createHeaders({
                ...this.config.headers, ...config.headers
            }),

            params: {
                ...this.config.params, ...config.params
            },
            paramsArrayFormat: config.paramsArrayFormat ?? this.config.paramsArrayFormat,

            timeout: config.timeout ?? this.config.timeout,

            body: config.body
        }

        // handle baseURLs

        let url = config.url ?? "";

        if (!(startsWith(url, "http://") || startsWith(url, "https://"))) {
            if (config.baseURL || this.config.baseURL) {
                url = (config.baseURL || this.config.baseURL) + url;
            } else {
                throw `${config.url} is not an absolute URL and no baseURL was set`;
            }
        }

        // next handle query string parameters
        if (config.params || this.config.params) {
            const transformParams = config.paramsSerializer ?? this.config.paramsSerializer;
            if (!transformParams) {
                throw "URL parameters were passed but no paramsSerializer was found";
            }

            const queryString = transformParams(
                finalConfig.params as Params,
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

        // handle forms

        // first convert normal tables to form
        if (config.form !== undefined) {
            if (!config.form._isForm) {
                config.form = new Form(config.form as FormFields);
            }
        }
        //  add any directly passed files to form
        if (config.file) {
            config.files ??= [];
            config.files.push(config.file);
        }
        if (config.files) {
            config.form ??= new Form();

            for (let [i, file] of ipairs(config.files)) {
                if (!file._isFile) {
                    throw "Object passed in file argument is not a File";
                }

                const name = (config.files.size() === 1) ? "file" : `files[${i - 1}]`;

                // cannot use (config.form as Form).set() because it compiles to
                // (config.form):set(), which is considered ambiguous by lua and causes an error
                let _form = config.form as Form;
                _form.set(name, file);
            }
        }

        // then build form
        if (config.form) {
            if (finalConfig.body) {
                warn("Request body is being overridden by form data. You may be passing multiple" +
                    " types of data, such as JSON and a form. Only the form will be sent")
            }

            if (!config.form._isForm) {
                // convert table to form
                config.form = new Form(config.form as FormFields);
            }

            const [body, contentType] = (config.form as Form).build();

            finalConfig.headers ??= createHeaders();
            finalConfig.headers["Content-Type"] = contentType;

            finalConfig.body = body;
        }

        // handle cookies
        const cookies = {
            ...this.config.cookies,
            ...config.cookies
        }
        const serialCookies = [];
        for (const [name, value] of pairs(cookies)) {
            if (typeIs(value, "string")) {
                // serialCookies.push(`${urlEncode(name, false)}=${urlEncode(value, false)}`)
                serialCookies.push(`"${name}"="${value}"`)
            } else {
                if (value.shouldSend(finalConfig)) {
                    // serialCookies.push(`${urlEncode(name, false)}=${urlEncode(value.value, false)}`)
                    serialCookies.push(`"${name}"="${value.value}"`)
                }
            }
        }

        finalConfig.headers ??= createHeaders();
        if (serialCookies.size() > 0) finalConfig.headers["cookie"] = serialCookies.join("; ");

        return finalConfig;
    }

    /**
     * Returns a Promise that sends an HTTP request based on the passed configuration.
     *
     * @param config - Config used to send request
     */
    request(config: RequestConfig): Promise<Response> {
        const preparedRequest = this.prepareRequest(config);

        // create promise that dispatches request
        let requestPromise: Promise<Response> = new Promise((resolve, reject) => {
            // dispatch request
            let [success, responseOrRejection]: [boolean, [RequestAsyncResponse, number] | unknown] = dispatch(preparedRequest).await();

            if (!success) {
                return reject(responseOrRejection);
            }

            const dispatchResponse = responseOrRejection as [RequestAsyncResponse, number];

            const [rawResponse, secs] = dispatchResponse;
            const response = new Response(config, rawResponse, secs, this);

            if (config.throwForStatus && !response.ok) {
                return reject({
                    message: response.content,
                    response: response
                });
            }

            return resolve(response);
        });

        if (preparedRequest.timeout !== undefined) {
            requestPromise = requestPromise.timeout(preparedRequest.timeout);
        }

        return requestPromise;
    }

    updateHeaders(headers: Headers) {
        this.config.headers ??= {};

        for (const [key, val] of pairs(headers)) {
            this.config.headers[key] = val;
        }
    }

    // shortcut functions

    /**
     * Returns a Promise that sends a GET request.
     *
     * @param url - URL to send request to
     * @param config - Partial request config
     */
    get(url: string, config?: GetRequestConfig): Promise<Response> {
        return this.request({
            ...config,
            method: "get",
            url: url
        });
    }

    // _shortcutPrepareConfig(url: string, data?: RequestData | Form | File, config?: PostRequestConfig) {
    //
    // }

    post(url: string, data?: RequestData | Form | File, config?: PostRequestConfig): Promise<Response> {
        let newConfig: RequestConfig = {
            ...config,
            method: "post",
            url: url,
        }

        if (!data) {
            newConfig.data = undefined;
        } else if ((data as Form)._isForm) {
            // data is form
            newConfig.form = data as Form;
        } else if ((data as File)._isFile) {
            // add file to form
            newConfig.form = new Form({
                file: data as File
            });
        } else {
            newConfig.data = data as RequestData;
        }

        return this.request(newConfig)
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