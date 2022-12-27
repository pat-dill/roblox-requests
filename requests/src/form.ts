import mimes from "./mimes";
import * as base64 from "./base64";
import serializeParams from "./params";
import {startsWith} from "./utils";

// function randomString(l)
// 	local s = ""
//
// 	for _=1, l do
// 		s = s .. string.char(math.random(97, 122))
// 	end
//
// 	return s
// end

const randomString = (length: number) => {
    let s = "";

    for (let i=1; i<=length; i++) {
        s += string.char(math.random(97, 122));
    }

    return s;
}

export class File {
    isFile: true;
    name?: string;
    content: string;
    contentType: string;

    constructor(content: string);
    constructor(name: string | undefined, content?: string, contentType?: string);

    constructor(nameOrContent: string, content?: string, contentType?: string) {
        this.isFile = true;

        this.name = undefined;
        if (content !== undefined) {
            this.name = nameOrContent;
            this.content = content;
        } else {
            this.content = nameOrContent || "";
        }

        // if no contentType specified, try to guess from file extension
        if (contentType !== undefined) {
            this.contentType = contentType || "text/plain";
        } else if (this.name?.find("%.")[0]) {
            const segments = this.name.split(".");
            const extension = segments[segments.size()-1];

            this.contentType = mimes[extension] || "text/plain";
        } else {
            this.contentType = "text/plain"
        }
    }

    /*
    Encodes file in Base64.
     */
    encode() {
        return base64.encode(this.content);
    }
}

type FormValue = string | number | string[] | File
export type FormFields = {[key: string]: FormValue};

export class Form {
    isForm: true;
    fields: FormFields;

    constructor(fields?: FormFields) {
        this.isForm = true;
        this.fields = fields ?? {};
    }

    set(name: string, value: FormValue): void;
    set(fields: FormFields): void;

    set(fieldsOrName: string | FormFields, value?: FormValue) {
        if (value) {
            if (!typeIs(fieldsOrName, "string")) throw "Field name must be string";
            this.fields[fieldsOrName] = value;
        } else {
            if (!typeIs(fieldsOrName, "table")) throw "Invalid arguments. Fields must be in a table";
            for (const [k, v] of pairs(fieldsOrName)) {
                this.fields[k] = v;
            }
        }
    }

    private hasFile() {
        for (const [k, v] of pairs(this.fields)) {
            if (typeIs(v, "table") && (v as File).isFile) {
                return true;
            }
        }

        return false;
    }

    // Builds URL encoded form
    buildURL(): LuaTuple<[string, string]> {
        if (this.hasFile()) throw "URL encoded forms cannot have files";

        return [
            serializeParams(this.fields as {[key: string]: string | number | string[]}),
            "application/x-www-form-urlencoded"
        ] as LuaTuple<[string, string]>;
    }

    // Buids multipart encoded form
    buildMultipart(): LuaTuple<[string, string]> {
        const boundary = "--FormBoundary-" + randomString(28);
        let body = "";

        for (let [k, v] of pairs(this.fields)) {
            body += `--${boundary}\r\nContent-Disposition: form-data; name="${k}"`;

            if (typeIs(v, "table") && (v as File).isFile) {
                // value is file
                v = v as File;

                body += `; filename="${v.name || k}"`;
                body += `\r\nContent-Type: ${v.contentType}`;

                // get raw content
                // encode non-text files
                if (startsWith(v.contentType, "text/")) {
                    v = v.content;
                } else {
                    v = v.encode();
                    body += `\r\nContent-Transfer-Encoding: base64`
                }
            }

            body += `\r\n\r\n${v}\r\n`;
        }
        body += `--${boundary}`

        return [body, `multipart/form-data; boundary="${boundary}"`] as LuaTuple<[string, string]>
    }

    /*
    Builds form into HTTP body - either mulipart form or URL encoded.
    If content type isn't specified, it will be URL encoded unless a file is present.
     */
    build(contentType?: "multipart" | "url"): LuaTuple<[string, string]> {
        contentType ??= this.hasFile() ? "multipart" : "url";

        if (contentType === "url") {
            return this.buildURL() as LuaTuple<[string, string]>;
        } else {
            return this.buildMultipart() as LuaTuple<[string, string]>;
        }
    }
}