import {Session} from "./session";
import {GetRequestConfig, PostRequestConfig, RequestConfig, RequestData} from "./types";
import {File, Form, FormFields} from "./form";

const defaultSession = new Session();
export const config = defaultSession.config;

export const file = (nameOrContent?: string, content?: string, contentType?: string) => {
    return new File(nameOrContent, content, contentType);
}

export const form = (fields?: FormFields) => new Form(fields);

export const request = (config: RequestConfig) => defaultSession.request(config);

export const get = (url: string, config?: GetRequestConfig) => defaultSession.get(url, config);
export const delete_ = (url: string, config?: GetRequestConfig) => defaultSession.delete(url, config);
export const head = (url: string, config?: GetRequestConfig) => defaultSession.head(url, config);
export const options = (url: string, config?: GetRequestConfig) => defaultSession.options(url, config);

export const post = (url: string, data?: RequestData, config?: PostRequestConfig) => defaultSession.post(
    url, data, config
);
export const put = (url: string, data?: RequestData, config?: PostRequestConfig) => defaultSession.put(
    url, data, config
);
export const patch = (url: string, data?: RequestData, config?: PostRequestConfig) => defaultSession.patch(
    url, data, config
);