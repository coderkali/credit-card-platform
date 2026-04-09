# Network Flow: Customer Request → RDS

Complete sequence diagram showing a credit card purchase request travelling from the public internet through all AWS network layers to the RDS database and back.

```mermaid
sequenceDiagram
    autonumber

    participant C   as 🌐 Customer<br/>(203.0.113.5)
    participant IGW as 🔀 Internet Gateway
    participant RPU as 📋 Route Table<br/>(Public Subnet)
    participant LB  as ⚖️ Load Balancer<br/>(54.12.34.56)
    participant SGL as 🛡️ SG: Load Balancer
    participant RPR as 📋 Route Table<br/>(Private Subnet)
    participant SGP as 🛡️ SG: EKS Pod
    participant POD as 📦 EKS Pod<br/>(10.0.12.5)
    participant RDB as 📋 Route Table<br/>(DB Subnet)
    participant SGR as 🛡️ SG: RDS
    participant RDS as 🗄️ RDS PostgreSQL<br/>(10.0.21.10)

    %% ─────────────────────────────────────────────
    %% PHASE 1 — PUBLIC ZONE (Internet → Load Balancer)
    %% ─────────────────────────────────────────────
    rect rgb(173, 216, 230)
        Note over C,LB: 🔵 PUBLIC ZONE — Internet → Load Balancer

        C->>IGW: HTTPS POST /purchase<br/>src=203.0.113.5:54321 → dst=54.12.34.56:443

        Note over IGW: ✅ Security Check 1<br/>Is destination VPC registered with this IGW?<br/>→ YES (VPC vpc-0abc123 registered)<br/>⏱ <1ms

        IGW->>RPU: Forward packet into VPC<br/>dst=54.12.34.56 (maps to Load Balancer)

        Note over RPU: ✅ Route Table Lookup<br/>dst=54.12.34.56 → matches 0.0.0.0/0 → IGW<br/>Traffic already inside VPC, forward to LB<br/>⏱ <1ms

        RPU->>SGL: Packet arrives at LB Security Group<br/>src=203.0.113.5, dst port=443

        Note over SGL: ✅ Security Check 2<br/>Inbound Rule: Allow TCP 443 from 0.0.0.0/0?<br/>→ YES — ALLOW<br/>⏱ <1ms

        SGL->>LB: Request admitted to Load Balancer
        Note over LB: Load Balancer Actions:<br/>• Terminates TLS (HTTPS → HTTP internally)<br/>• Health checks EKS pods<br/>• Selects target: 10.0.12.5 (round-robin)<br/>⏱ 2–5ms
    end

    %% ─────────────────────────────────────────────
    %% PHASE 2 — PRIVATE ZONE (Load Balancer → EKS Pod)
    %% ─────────────────────────────────────────────
    rect rgb(255, 179, 128)
        Note over LB,POD: 🟠 PRIVATE ZONE — Load Balancer → EKS Pod

        LB->>RPR: Forward request to EKS Pod<br/>src=10.0.1.10 → dst=10.0.12.5:8080

        Note over RPR: ✅ Route Table Lookup<br/>dst=10.0.12.5 → matches 10.0.0.0/16 → local<br/>→ Traffic stays inside VPC (no NAT needed)<br/>⏱ <1ms

        RPR->>SGP: Packet arrives at Pod Security Group<br/>src=10.0.1.10 (LB), dst port=8080

        Note over SGP: ✅ Security Check 3<br/>Inbound Rule: Allow TCP 8080<br/>from sg-loadbalancer (LB Security Group)?<br/>→ YES — ALLOW (source is SG, not CIDR)<br/>⏱ <1ms

        SGP->>POD: Request delivered to EKS Pod
        Note over POD: Pod Business Logic:<br/>• Validates JWT token<br/>• Parses purchase payload<br/>• Fetches customer_id = 123<br/>• Prepares SQL query<br/>⏱ 5–50ms
    end

    %% ─────────────────────────────────────────────
    %% PHASE 3 — DATABASE ZONE (EKS Pod → RDS)
    %% ─────────────────────────────────────────────
    rect rgb(255, 120, 120)
        Note over POD,RDS: 🔴 DATABASE ZONE — EKS Pod → RDS (AZ-2)

        POD->>RDB: SQL query to RDS<br/>src=10.0.12.5 → dst=10.0.21.10:5432<br/>Protocol: PostgreSQL TCP

        Note over RDB: ✅ Route Table Lookup<br/>dst=10.0.21.10 → matches 10.0.0.0/16 → local<br/>→ Same VPC, route locally (different AZ, same VPC)<br/>⏱ <1ms

        RDB->>SGR: Packet arrives at RDS Security Group<br/>src=10.0.12.5 (Pod), dst port=5432

        Note over SGR: ✅ Security Check 4<br/>Inbound Rule: Allow TCP 5432<br/>from sg-ekspod (Pod Security Group)?<br/>→ YES — ALLOW<br/>⏱ <1ms

        SGR->>RDS: Connection admitted to RDS
        Note over RDS: RDS Executes Query:<br/>SELECT balance, credit_limit<br/>FROM accounts<br/>WHERE customer_id = 123<br/>⏱ 10–100ms
    end

    %% ─────────────────────────────────────────────
    %% PHASE 4 — RETURN PATH (RDS → Customer)
    %% ─────────────────────────────────────────────
    rect rgb(200, 230, 200)
        Note over C,RDS: 🟢 RETURN PATH — Response travels back

        RDS-->>POD: Query result: {balance: 4500, limit: 10000}<br/>⏱ <1ms (stateful SG — no re-check needed)

        Note over POD: Pod finalises response:<br/>• Validates sufficient credit<br/>• Approves transaction<br/>• Formats JSON response<br/>⏱ 2–10ms

        POD-->>LB: HTTP 200 {status: "approved", auth_code: "XK72"}<br/>src=10.0.12.5:8080 → dst=10.0.1.10<br/>⏱ <1ms (stateful — no SG re-check)

        Note over LB: Load Balancer:<br/>• Re-encrypts response (HTTP → HTTPS)<br/>• Returns to original client connection<br/>⏱ 1–2ms

        LB-->>IGW: HTTPS response<br/>src=54.12.34.56:443 → dst=203.0.113.5:54321

        IGW-->>C: Response delivered to customer<br/>⏱ <1ms

        Note over C: ✅ Purchase Approved!<br/>Customer sees: "Transaction Approved"<br/>Auth Code: XK72
    end

    %% ─────────────────────────────────────────────
    %% TOTAL LATENCY SUMMARY
    %% ─────────────────────────────────────────────
    Note over C,RDS: ⏱ Total Latency Breakdown<br/>IGW check: <1ms | Route lookups: <4ms | SG checks: <4ms<br/>LB processing: 2–5ms | EKS logic: 5–50ms | RDS query: 10–100ms<br/>Return path: <5ms<br/>━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━<br/>Total end-to-end: ~50–250ms
```

---

## Security Checkpoints Summary

| # | Component | Check | Rule | Result |
|---|-----------|-------|------|--------|
| 1 | Internet Gateway | VPC registered? | VPC must be attached to IGW | ✅ Allow |
| 2 | SG: Load Balancer | Port 443 open? | Allow TCP 443 from `0.0.0.0/0` | ✅ Allow |
| 3 | SG: EKS Pod | From LB only? | Allow TCP 8080 from `sg-loadbalancer` | ✅ Allow |
| 4 | SG: RDS | From Pod only? | Allow TCP 5432 from `sg-ekspod` | ✅ Allow |

> **Key insight:** Security Groups 3 and 4 reference *other security groups* as the source, not IP ranges. This means even if an attacker somehow got an IP inside the VPC, they still can't reach the pod or the database — the source must be a resource that actually belongs to the LB/Pod security group.

---

## Route Table Summary

| Route Table | Destination | Target | Meaning |
|-------------|-------------|--------|---------|
| Public Subnet | `0.0.0.0/0` | IGW | All internet traffic via IGW |
| Public Subnet | `10.0.0.0/16` | local | VPC-internal traffic stays local |
| Private Subnet | `10.0.0.0/16` | local | Pod ↔ RDS stays inside VPC |
| Private Subnet | `0.0.0.0/0` | NAT GW | Outbound-only internet (e.g. OS patches) |

---

## Why Traffic Never Touches the Internet Unnecessarily

```
Customer → IGW → Load Balancer (public IP stops here)
                      ↓
              EKS Pod (private IP 10.x.x.x — never exposed)
                      ↓
              RDS     (private IP 10.x.x.x — never exposed)
```

Once the request crosses the Load Balancer, **all traffic uses private RFC-1918 addresses** (`10.0.0.0/16`) and is routed locally within the VPC. The RDS instance has no public IP and cannot be reached from the internet under any circumstances.
