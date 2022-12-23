const charToHex = (c: string) => string.format("%%%02X", string.byte(c)[0]);
const hexToChar = (hex: string) => string.char(tonumber(hex, 16) as number);

export const urlEncode = (rawUrl: any) => {
    let url = tostring(rawUrl) as string;
    url = url.gsub("([^%w ])", charToHex)[0];
    url = url.gsub(" ", "+")[0];

    return url;
}

export const urlDecode = (encodedUrl: string) => {
    let url = encodedUrl.gsub("%%(%x%x)", hexToChar)[0];
    return url.gsub("+", " ")[0]
}