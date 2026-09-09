# Vulnerability #1 — SSH Exposed to Internet

## Description

The EC2 instance allows inbound SSH traffic (TCP/22) from any IPv4 address.

```text
Protocol: TCP
Port: 22
Source: 0.0.0.0/0
```

## Why This Is Vulnerable

`0.0.0.0/0` represents every IPv4 address on the internet.

Because the EC2 instance has a public IPv4 address, the SSH service is directly reachable from the internet.

## Evidence

EC2 public IP:

```text
16.16.202.220
```

SSH connection was successfully established from CloudShell:

```bash
ssh -i ~/.ssh/cloudbreach-lab ec2-user@16.16.202.220
```

Successful login:

```text
ec2-user@ip-10-0-1-241.eu-north-1.compute.internal
```

## Security Impact

An internet-exposed SSH service increases the attack surface and can be targeted by:

* Automated SSH scanning
* Brute-force/password attacks
* Credential attacks
* Exploitation of SSH-related vulnerabilities

## Root Cause

The Security Group intentionally allows:

```text
TCP/22 → 0.0.0.0/0
```

## Intended Lab Vulnerability

This configuration is deliberately insecure for the CloudBreach Lab and will be hardened later.

## Detection — VPC Flow Logs

VPC Flow Logs were enabled for the lab VPC and configured to send traffic records to CloudWatch Logs.

The SSH connection generated an accepted TCP/22 flow:

```text
Source:      13.48.85.149
Destination: 10.0.1.241
Source Port: 39530
Destination Port: 22
Protocol:    TCP (6)
Action:      ACCEPT
```

A reverse flow was also observed:

```text
Source:      10.0.1.241
Destination: 13.48.85.149
Source Port: 22
Destination Port: 39530
Protocol:    TCP (6)
Action:      ACCEPT
```

Additional rejected connection attempts from unrelated internet addresses were also observed, demonstrating that the publicly reachable EC2 instance is receiving unsolicited internet traffic.

### Detection Conclusion

VPC Flow Logs successfully captured the network-level evidence of the exposed SSH service and confirmed that TCP/22 traffic was being accepted by the EC2 instance.


## Status

* [x] Vulnerability created
* [x] SSH connectivity verified
* [x] Detection
* [x] Hardening

## Vulnerability #2 — Over-Privileged IAM User

### Vulnerability

The IAM user `cloudbreach-attacker` was initially granted the AWS managed policy `AdministratorAccess`.

This violated the principle of least privilege and gave the attacker broad access to AWS resources.

### Attack

Using the attacker's access keys:

```bash
aws sts get-caller-identity --profile cloudbreach-attacker
aws s3 ls --profile cloudbreach-attacker
aws s3 ls s3://<bucket-name> --profile cloudbreach-attacker
aws s3 cp s3://<bucket-name>/customer-data.txt ./customer-data.txt --profile cloudbreach-attacker
```

The attacker successfully enumerated S3 resources and downloaded the fake sensitive data.

### Detection

CloudTrail Event History recorded the S3 API activity performed by `cloudbreach-attacker`.

Relevant activity included:

* S3 bucket enumeration
* S3 object listing
* `GetObject`

### Security Impact

An attacker who obtains the IAM user's credentials could access AWS resources beyond what is required for the user's intended purpose.

Potential impact includes:

* Unauthorized data access
* Data exfiltration
* Resource modification
* Further AWS account compromise

### Root Cause

The IAM user was granted:

```text
AdministratorAccess
```

instead of only the permissions required for its intended task.

### Remediation

Removed `AdministratorAccess` from `cloudbreach-attacker`.

The attacker was left without S3 permissions.

### Validation

The same S3 commands were executed again after removing the excessive permissions.

The requests failed with:

```text
AccessDenied
```

This confirmed that the excessive IAM privileges were successfully removed.

### Security Principle

**Principle of Least Privilege**

IAM identities should receive only the permissions required to perform their intended tasks.

## Status

* [x] Vulnerability created
* [x] Excessive permissions assigned
* [x] S3 access verified
* [x] CloudTrail detection
* [x] Permissions hardened
* [x] Attack re-tested and blocked

