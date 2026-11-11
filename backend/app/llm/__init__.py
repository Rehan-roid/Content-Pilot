"""Provider-agnostic LLM access: prompts, structured output, guardrails.

Owner: Member 4. The only package allowed to talk to a model provider. Callers
pass a provider-neutral request and receive a structured response; no key ever
leaves the server and no other package imports a provider SDK.
"""
