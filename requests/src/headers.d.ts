// this is a case-insensitive table for use with HTTP headers. ex:
// assert headers["Content-Type"] === headers["content-type"];

declare function createHeaders(headers?: {[key: string]: string}): {[key: string]: string};
export default createHeaders;