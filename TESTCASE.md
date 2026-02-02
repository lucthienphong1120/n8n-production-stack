## Verification Checklist

Perform these tests after any configuration update or architecture change to ensure system integrity:

- [ ] **Workflow Execution (Queue Mode)**: Trigger a workflow manually and verify it is picked up by a `worker` node (check worker logs) rather than executing on the main node.
- [ ] **Webhook Endpoints**: Send a request to `https://n8n-gw.domain.local/webhook/...` and verify 200 OK status. Ensure traffic hits the `webhook` container.
- [ ] **Editor & Sessions**: Login to the UI, verify session persistence, and ensure "Previewing" workflows works correctly (uses specialized internal routing).
- [ ] **External Runners**: Run a workflow with a **Code Node** (Python/JS). Check `runner` logs to confirm code execution happens in the isolated sandbox.
- [ ] **Storage (S3/MinIO)**: Use a `Read/Write Binary File` node. Verify files are correctly written to the MinIO bucket (browse MinIO UI to confirm).
- [ ] **Exclusions**: Verify that excluded nodes or commands (if configured) are strictly blocked in their respective environments.
