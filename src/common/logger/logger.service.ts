import { Injectable, LoggerService as NestLoggerService } from '@nestjs/common';

export enum LogLevel {
  ERROR = 'error',
  WARN = 'warn',
  INFO = 'info',
  DEBUG = 'debug',
}

@Injectable()
export class LoggerService implements NestLoggerService {
  private readonly context: string;

  constructor(context?: string) {
    this.context = context || 'Application';
  }

  log(message: string, context?: string) {
    this.print(LogLevel.INFO, message, context);
  }

  error(message: string, trace?: string, context?: string) {
    this.print(LogLevel.ERROR, message, context, trace);
  }

  warn(message: string, context?: string) {
    this.print(LogLevel.WARN, message, context);
  }

  debug(message: string, context?: string) {
    if (process.env.NODE_ENV !== 'production') {
      this.print(LogLevel.DEBUG, message, context);
    }
  }

  verbose(message: string, context?: string) {
    if (process.env.NODE_ENV !== 'production') {
      this.print(LogLevel.DEBUG, message, context);
    }
  }

  private print(level: LogLevel, message: string, context?: string, trace?: string) {
    const timestamp = new Date().toISOString();
    const ctx = context || this.context;
    const logMessage = `[${timestamp}] [${level.toUpperCase()}] [${ctx}] ${message}`;

    switch (level) {
      case LogLevel.ERROR:
        console.error(logMessage);
        if (trace) console.error(trace);
        break;
      case LogLevel.WARN:
        console.warn(logMessage);
        break;
      case LogLevel.INFO:
        console.info(logMessage);
        break;
      case LogLevel.DEBUG:
        console.log(logMessage);
        break;
    }
  }
}
