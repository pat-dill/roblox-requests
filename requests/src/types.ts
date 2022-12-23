import {RequestCookies} from "./cookies";

export type Headers = {[key: string]: string}

export type ParamValue = string | number
export type Params = Record<string, ParamValue | ParamValue[]>

type DataValue = string | number
export type RequestData = DataValue | Array<DataValue> | Record<string, DataValue>

export interface SessionConfig {
    baseURL?: string,
    headers?: Headers,

    // url query string parameters
    params?: Params,
    // function to convert parameters to string. should not include prepending '?'
    paramsSerializer?: (params: Params, config: RequestConfig) => string,
    paramsArrayFormat?: "repeat" | "comma",

    // transform data to string body
    transformData?: (data: RequestData, config: RequestConfig) => string,

    // cookies
    cookies?: RequestCookies,

    // timeout in seconds. 0 = no timeout created
    timeout?: number,

    // whether to follow ratelimit
    // if true old are queued and only sent 500/min
    ratelimit?: boolean,

    // whether to throw error if !(200 <= status < 300)
    throwForStatus?: boolean,

    // whether to warn when calling .json() on non-JSON content type
    contentTypeWarning?: boolean
}


export type RequestConfig = SessionConfig & {
    url?: string,
    method: "get" | "post" | "put" | "delete" | "head" | "patch" | "options",

    // request body
    data?: RequestData,
    body?: string,

    queryString?: string
}

export type GetRequestConfig = Omit<RequestConfig, "method" | "url">;
export type PostRequestConfig = Omit<RequestConfig, "method" | "url" | "data">;
