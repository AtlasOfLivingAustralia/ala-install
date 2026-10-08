# Ansible Role: java-security-properties

Writes a per-service JVM security properties file and exposes `java_security_opts` plus the
matching `-Djava.security.properties=...` flag as `service_java_security_opts`. It's imported by
`exec-jar`, `exec-war` and `tomcat`.

The JVM only honours one `-Djava.security.properties` file, so every JVM security override
belongs here rather than in its own file. If a service ends up with no properties, no file is
written and no flag is added, so the JVM runs with the JDK defaults.

What it covers:

- **Java 8 legacy TLS:** on openjdk8, re-enables TLSv1/TLSv1.1 (ala-install#481). This replaced the
  old `/etc/java-8-openjdk/security/enableLegacyTLS.security` file.
- **DNS caching (opt-in):** app roles that need to follow DNS changes quickly, e.g. an RDS
  blue/green switchover, set `jvm_dns_cache_override: true` to get short TTLs
  (`networkaddress.cache.ttl=5`, `networkaddress.cache.negative.ttl=5`). Other services keep
  the JDK defaults (30s / 10s).
- **Anything else** an app role or the inventory asks for.

## Merge order (later wins)

1. `java_legacy_tls_properties`, only on JDKs where `common/tasks/setfacts.yml` sets `java_legacy_tls: true` (openjdk8)
2. `java_security_properties_defaults`
3. `jvm_dns_cache_properties`, only when `jvm_dns_cache_override`
4. `java_security_properties`: set by an app role in its `exec-jar`/`exec-war` vars
5. `java_security_properties_overrides[service_name]`: inventory, per service (`tomcat` for Tomcat)

A property with a `null` or empty value is dropped. The layers are defined in `vars/main.yml`.

## Variables

| Variable | Default | Description |
| --- | --- | --- |
| `java_security_properties_enabled` | `true` | Turn the feature off globally (inventory) or per app (role vars). |
| `java_security_properties_defaults` | `{}` | Base properties for all services. |
| `jvm_dns_cache_override` | `false` | Set by an app role to request the DNS TTLs below. |
| `jvm_dns_cache_ttl` | `5` | `networkaddress.cache.ttl`, when requested. |
| `jvm_dns_cache_negative_ttl` | `5` | `networkaddress.cache.negative.ttl`, when requested. |
| `jvm_dns_cache_properties` | the two TTLs above | Properties applied when DNS caching is requested. |
| `java_security_properties` | `{}` | Per-app properties, passed by the app role. |
| `java_security_properties_overrides` | `{}` | Per-service properties from inventory, keyed by `service_name`. |
| `java_legacy_tls_properties` | see defaults | Re-enables TLSv1/TLSv1.1 on openjdk8 via `jdk.tls.disabledAlgorithms`. This replaces the JDK's whole list, so algorithms disabled by later JDK updates are not included. Set to `{}` to turn legacy TLS off everywhere. |
| `java_security_properties_file` | `/opt/atlas/{{ service_name }}/security.properties` | Location of the generated file. Tomcat uses `/etc/{{ tomcat }}/security.properties`. |
| `java_security_properties_owner` / `_group` | the service user | File ownership. |

Services that request DNS caching today: `apikey`, `cas`, `cas-management`, `userdetails`.

## Examples

App role, request short DNS caching and/or add other properties:

```yaml
- include_role:
    name: exec-jar
  vars:
    service_name: "myapp"
    jvm_dns_cache_override: true
    java_security_properties:
      jdk.tls.ephemeralDHKeySize: 2048
```

Inventory, tune or disable for specific services:

```yaml
java_security_properties_overrides:
  cas:
    networkaddress.cache.ttl: 30
  userdetails:                 # undo the app's DNS request
    networkaddress.cache.ttl: ~
    networkaddress.cache.negative.ttl: ~
  apikey:                      # openjdk8 app that no longer needs TLSv1/1.1
    jdk.tls.disabledAlgorithms: ~
```
