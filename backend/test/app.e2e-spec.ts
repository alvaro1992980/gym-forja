import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import type { App } from 'supertest/types';
import { createTestApp } from './support/app';

describe('App foundation (e2e)', () => {
  let app: INestApplication<App>;

  beforeAll(async () => {
    app = await createTestApp();
  });

  afterAll(async () => {
    await app.close();
  });

  describe('GET /api/v1/health', () => {
    it('returns status ok and db ok', async () => {
      const res = await request(app.getHttpServer()).get('/api/v1/health').expect(200);
      expect(res.body).toEqual({ status: 'ok', db: 'ok' });
    });

    it('adds a generated X-Request-Id header', async () => {
      const res = await request(app.getHttpServer()).get('/api/v1/health').expect(200);
      expect(res.headers['x-request-id']).toMatch(/^[0-9a-f-]{36}$/);
    });

    it('echoes a well-formed incoming X-Request-Id', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/v1/health')
        .set('X-Request-Id', 'abc-123')
        .expect(200);
      expect(res.headers['x-request-id']).toBe('abc-123');
    });

    it('sends helmet security headers', async () => {
      const res = await request(app.getHttpServer()).get('/api/v1/health').expect(200);
      expect(res.headers['x-content-type-options']).toBe('nosniff');
      expect(res.headers['x-powered-by']).toBeUndefined();
    });

    it('is only served under the /api/v1 prefix', async () => {
      await request(app.getHttpServer()).get('/health').expect(404);
    });
  });

  describe('error format', () => {
    it('unknown routes return { statusCode, code, message }', async () => {
      const res = await request(app.getHttpServer()).get('/api/v1/does-not-exist').expect(404);
      expect(res.body).toEqual({
        statusCode: 404,
        code: 'NOT_FOUND',
        message: expect.any(String) as unknown,
      });
    });
  });

  describe('Swagger', () => {
    it('serves the UI at /api/docs', async () => {
      const res = await request(app.getHttpServer()).get('/api/docs').expect(200);
      expect(res.text).toContain('swagger-ui');
    });

    it('serves the OpenAPI document including the health endpoint', async () => {
      const res = await request(app.getHttpServer()).get('/api/docs-json').expect(200);
      const body = res.body as { openapi: string; paths: Record<string, unknown> };
      expect(body.openapi).toMatch(/^3\./);
      expect(Object.keys(body.paths)).toContain('/api/v1/health');
    });
  });
});
