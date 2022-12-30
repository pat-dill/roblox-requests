import {Session} from "./session";
import {GetRequestConfig, PostRequestConfig, RequestConfig, RequestData, SessionConfig} from "./types";
import {File, Form, FormFields} from "./form";

const defaultSession = new Session();

// default config for editing
export const config = defaultSession.config;

// creates new session
export const session = (config?: SessionConfig) => new Session(config);

// creates file
export const file = (nameOrContent?: string, content?: string, contentType?: string) => {
    return new File(nameOrContent, content, contentType);
}

// creates form
export const form = (fields?: FormFields) => new Form(fields);

// sends request
export const request = (config: RequestConfig) => defaultSession.request(config);

// shortcuts
export const get = (url: string, config?: GetRequestConfig) => defaultSession.get(url, config);
export const delete_ = (url: string, config?: GetRequestConfig) => defaultSession.delete(url, config);
export const head = (url: string, config?: GetRequestConfig) => defaultSession.head(url, config);
export const options = (url: string, config?: GetRequestConfig) => defaultSession.options(url, config);

export const post = (url: string, data?: RequestData | Form | File, config?: PostRequestConfig) => defaultSession.post(
    url, data, config
);
export const put = (url: string, data?: RequestData, config?: PostRequestConfig) => defaultSession.put(
    url, data, config
);
export const patch = (url: string, data?: RequestData, config?: PostRequestConfig) => defaultSession.patch(
    url, data, config
);