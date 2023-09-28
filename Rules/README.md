```yaml
groups:
  - name: host_hardware_rules
    interval: 10s
    rules:
      # Existing alerting rules...

      # Recording rule for available memory percentage
      - record: instance:node_memory_MemAvailable:percent_used
        expr: (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100
```

