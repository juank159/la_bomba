import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from "@nestjs/common";
import { Observable } from "rxjs";

@Injectable()
export class DebugInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();

    if (
      request.method === "PATCH" &&
      request.url.includes("/products/by-id/")
    ) {
      console.log(
        "🚨 DEBUG INTERCEPTOR - RAW REQUEST BODY:",
        JSON.stringify(request.body, null, 2)
      );
      console.log("🚨 DEBUG INTERCEPTOR - BODY TYPE:", typeof request.body);
      console.log(
        "🚨 DEBUG INTERCEPTOR - BODY CONSTRUCTOR:",
        request.body?.constructor?.name
      );
    }

    return next.handle();
  }
}
