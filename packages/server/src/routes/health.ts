import Router from '@koa/router'
import * as ctrl from '../controllers/health'

export const healthRoutes = new Router()

healthRoutes.get('/health', ctrl.healthCheck)

healthRoutes.post('/api/connection/test-upstream', async (ctx: any) => {
  const { url, apiKey } = ctx.request.body || {}
  if (!url) {
    ctx.status = 400
    ctx.body = { ok: false, error: 'url is required' }
    return
  }
  const upstream = url.replace(/\/+$/, '')
  // Use server env API key as fallback (matches handleApiRun behavior)
  const effectiveApiKey = apiKey || process.env.VITE_HERMES_GATEWAY_API_KEY || undefined
  const headers: Record<string, string> = { 'Content-Type': 'application/json' }
  if (effectiveApiKey) headers['Authorization'] = `Bearer ${effectiveApiKey}`
  try {
    const res = await fetch(`${upstream}/v1/responses`, {
      method: 'POST',
      headers,
      body: JSON.stringify({ input: 'test', stream: false, max_output_tokens: 1 }),
      signal: AbortSignal.timeout(10000),
    })
    if (res.ok) {
      ctx.body = { ok: true, status: res.status }
    } else {
      const text = await res.text().catch(() => '')
      ctx.body = { ok: false, status: res.status, error: text || res.statusText }
    }
  } catch (err: any) {
    ctx.body = { ok: false, error: err.message || String(err) }
  }
})

export { startVersionCheck } from '../controllers/health'
