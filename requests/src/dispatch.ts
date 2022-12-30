import {RequestConfig} from "./types";
import {Response} from "./response";
import {Session} from "./session";

const HttpService = game.GetService("HttpService");

const RequestAsync = Promise.promisify((options: RequestAsyncRequest) => {
    return HttpService.RequestAsync(options);
})

export function dispatch(request: RequestConfig,): Promise<[RequestAsyncResponse, number]> {
    return new Promise((resolve, reject) => {
        const st = tick();

        RequestAsync({
            Url: request.url as string,
            Method: request.method.upper() as RequestAsyncRequest["Method"],
            Body: request.body,
            Headers: request.headers
        })
            .andThen((rawResponse) => {
                const secs = tick() - st;

                return resolve([rawResponse, secs]);
            })
            .catch(reject);
    })

}