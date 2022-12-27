import {RequestConfig} from "./types";
import {Response} from "./response";
import {Session} from "./session";

const HttpService = game.GetService("HttpService");

const RequestAsync = Promise.promisify((options: RequestAsyncRequest) => {
    return HttpService.RequestAsync(options);
})

export function dispatch(request: RequestConfig, session: Session): Promise<Response> {
    return new Promise((resolve, reject) => {
        const st = tick();

        RequestAsync({
            Url: request.url as string,
            Method: request.method.upper() as "GET" | "POST" | "PUT" | "DELETE" | "HEAD" | "PATCH",
            Body: request.body,
            Headers: request.headers
        })
            .andThen((rawResponse) => {
                const secs = tick() - st;

                return resolve(new Response(request, rawResponse, secs, session));
            })
            .catch(reject);
    })

}