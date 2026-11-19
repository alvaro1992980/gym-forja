import {
  ArgumentsHost,
  BadRequestException,
  HttpStatus,
  NotFoundException,
  ValidationError,
} from '@nestjs/common';
import { ThrottlerException } from '@nestjs/throttler';
import { createValidationPipe, flattenValidationErrors } from '../validation/validation.pipe';
import { AllExceptionsFilter } from './all-exceptions.filter';
import { AppException } from './app.exception';
import { DEFAULT_ERROR_MESSAGES, ErrorCode } from './error-codes';

function mockHost() {
  const json = jest.fn();
  const status = jest.fn().mockReturnValue({ json });
  const host = {
    switchToHttp: () => ({ getResponse: () => ({ status }) }),
  } as unknown as ArgumentsHost;
  return { host, status, json };
}

describe('AllExceptionsFilter', () => {
  const filter = new AllExceptionsFilter();

  it('returns AppException bodies as they are, with code and details', () => {
    const { host, status, json } = mockHost();
    filter.catch(
      new AppException(HttpStatus.CONFLICT, ErrorCode.PHONE_ALREADY_EXISTS, undefined, {
        phone: '+59170000000',
      }),
      host,
    );
    expect(status).toHaveBeenCalledWith(409);
    expect(json).toHaveBeenCalledWith({
      statusCode: 409,
      code: 'PHONE_ALREADY_EXISTS',
      message: DEFAULT_ERROR_MESSAGES.PHONE_ALREADY_EXISTS,
      details: { phone: '+59170000000' },
    });
  });

  it('maps plain HttpExceptions to a code by status, with a Spanish message', () => {
    expect(filter.toBody(new NotFoundException('Cannot GET /x'))).toEqual({
      statusCode: 404,
      code: 'NOT_FOUND',
      message: DEFAULT_ERROR_MESSAGES.NOT_FOUND,
    });
    expect(filter.toBody(new BadRequestException()).code).toBe('BAD_REQUEST');
    expect(filter.toBody(new ThrottlerException()).code).toBe('TOO_MANY_REQUESTS');
  });

  it('hides unknown errors behind 500 INTERNAL_ERROR', () => {
    const { host, status, json } = mockHost();
    jest.spyOn(filter['logger'], 'error').mockImplementation(() => undefined);
    filter.catch(new Error('secret db detail'), host);
    expect(status).toHaveBeenCalledWith(500);
    expect(json).toHaveBeenCalledWith({
      statusCode: 500,
      code: 'INTERNAL_ERROR',
      message: DEFAULT_ERROR_MESSAGES.INTERNAL_ERROR,
    });
  });

  it('every error code has a default message', () => {
    for (const code of Object.values(ErrorCode)) {
      expect(DEFAULT_ERROR_MESSAGES[code]).toEqual(expect.any(String));
    }
  });
});

function ve(e: Partial<ValidationError>): ValidationError {
  return { children: [], ...e } as ValidationError;
}

describe('validation pipe', () => {
  const child = ve({
    property: 'title',
    constraints: { isNotEmpty: 'title should not be empty' },
    children: [],
  });
  const errors = [
    ve({
      property: 'phone',
      constraints: { isString: 'phone must be a string' },
      children: [],
    }),
    ve({
      property: 'days',
      children: [ve({ property: '0', children: [child] })],
    }),
  ];

  it('flattens nested errors into field paths', () => {
    expect(flattenValidationErrors(errors)).toEqual([
      { field: 'phone', constraints: { isString: 'phone must be a string' } },
      { field: 'days.0.title', constraints: { isNotEmpty: 'title should not be empty' } },
    ]);
  });

  it('produces a 400 VALIDATION_ERROR with field details', () => {
    const pipe = createValidationPipe();
    const factory = (pipe as unknown as { exceptionFactory: (e: ValidationError[]) => unknown })
      .exceptionFactory;
    const exception = factory(errors) as AppException;
    expect(exception.getStatus()).toBe(400);
    expect(exception.toBody()).toMatchObject({
      statusCode: 400,
      code: 'VALIDATION_ERROR',
      details: { fields: expect.any(Array) as unknown },
    });
  });
});
