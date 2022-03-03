---
authSecret:
  create: true
  github_token: ${github_registration_pat}
githubWebhookServer:
  enabled: true
  secret:
    create: true
    github_webhook_secret_token: ${webhook_shared_secret}
  service:
    type: LoadBalancer
    ports:
      - port: 80
        targetPort: http
        protocol: TCP
        name: http

