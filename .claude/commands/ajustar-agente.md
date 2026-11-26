---
description: "Modifica un solo subagente (bayesian-theorist | mcmc-coder | bayesian-auditor | latex-reporter) sin regenerar la arquitectura. Uso: /ajustar-agente <nombre> <cambio deseado>"
argument-hint: "<nombre-agente> <cambio deseado>"
allowed-tools: Read, Edit, Grep, Glob, Bash
---

Solicitud: $ARGUMENTS

1. Toma la primera palabra como nombre del agente. Debe ser uno de: `bayesian-theorist`, `mcmc-coder`, `bayesian-auditor`, `latex-reporter`. Si no coincide, lista las opciones y detente.
2. Lee **solo** `.claude/agents/<nombre>.md`. No abras los demás agentes, salvo que el cambio afecte la frontera entre agentes; en ese caso lee solo el `description` de los otros (`Grep "^description:"`) para evitar solapamientos.
3. Aplica el cambio con `Edit` (cambio mínimo; no reescribas el archivo entero). Conserva las reglas críticas: sin git, sin uso de las imágenes originales para inferencia y sin re-derivar `teoria.tex`.
4. Valida el frontmatter: delimitado por `---`; `name` igual al nombre del archivo, en minúsculas y con guiones; `description` no vacía y específica; `tools` solo con herramientas válidas (Read, Write, Edit, Grep, Glob, Bash, WebFetch, WebSearch, Agent); `model` ∈ {opus, sonnet, haiku, inherit}. Si hay Python con PyYAML disponible, ejecuta además `python .refs/claude-agent-builder/agent-builder/scripts/validate_agents.py .claude/agents/<nombre>.md`.
5. Si el cambio afecta la tabla de agentes de `CLAUDE.md`, actualiza solo esa fila.
6. Muestra un diff resumido (antes → después) y recuerda que los autores deben revisarlo y hacer el commit manualmente. No ejecutes git.
