import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import type { FastifyReply, FastifyRequest } from 'fastify';

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(HttpExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const context = host.switchToHttp();

    const response = context.getResponse<FastifyReply>();
    const request = context.getRequest<FastifyRequest>();

    const isHttpException = exception instanceof HttpException;

    const statusCode = isHttpException
      ? exception.getStatus()
      : HttpStatus.INTERNAL_SERVER_ERROR;

    const exceptionResponse = isHttpException ? exception.getResponse() : null;

    const error =
      typeof exceptionResponse === 'object' &&
      exceptionResponse !== null &&
      'error' in exceptionResponse &&
      typeof exceptionResponse.error === 'string'
        ? exceptionResponse.error
        : (HttpStatus[statusCode] ?? 'Internal Server Error');

    const rawMessage =
      typeof exceptionResponse === 'string'
        ? exceptionResponse
        : typeof exceptionResponse === 'object' &&
            exceptionResponse !== null &&
            'message' in exceptionResponse
          ? exceptionResponse.message
          : null;

    const message =
      statusCode >= 500
        ? 'Internal server error'
        : typeof rawMessage === 'string' ||
            (Array.isArray(rawMessage) &&
              rawMessage.every((item) => typeof item === 'string'))
          ? rawMessage
          : 'Request failed';

    if (statusCode >= 500) {
      const stack = exception instanceof Error ? exception.stack : undefined;

      const requestPath = request.url.split('?')[0];

      this.logger.error(
        `[${request.id}] ${request.method} ${requestPath} - ${statusCode}`,
        stack,
      );
    }

    response.status(statusCode).send({
      statusCode,
      error,
      message,
      path: request.url,
      timestamp: new Date().toISOString(),
      requestId: request.id,
    });
  }
}
