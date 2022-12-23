import mimes from "./mimes";
import {startsWith} from "./utils";
import * as base64 from "./base64";

export class File {
    content: string;
    name: string;
    contentType: string | undefined;

    constructor(content: string);
    constructor(name: string, content: string, contentType: string);

    constructor(arg0: string, arg1?: string, arg2?: string) {
        this.content = arg1 ?? arg0;
        this.name = arg1 ? arg0 : "file";
        this.contentType = arg2;

        if (!this.contentType && this.name.find(".")) {
            let segments = this.name.split(".");
            let extension = segments[segments.size() - 1];
            this.contentType = mimes[extension];
        }
    }

    isText() {
        return !!(this.contentType && startsWith(this.contentType, "text/"));
    }

    encode() {
        // encode to Base64
        return base64.encode(this.content);
    }
}