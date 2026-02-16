# AWS Account Automation

[![Terraform](https://github.com/hammadhaqqani/aws-account-automation/actions/workflows/terraform.yml/badge.svg)](https://github.com/hammadhaqqani/aws-account-automation/actions/workflows/terraform.yml)
[![GitHub Pages](https://github.com/hammadhaqqani/aws-account-automation/actions/workflows/pages.yml/badge.svg)](https://hammadhaqqani.github.io/aws-account-automation/)
[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-ffdd00?style=flat&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/hammadhaqqani)

Automate end-to-end creation of new AWS accounts, including VPC provisioning, IAM roles/users, and Azure AD SSO integration.

## Features

- Automated AWS account creation via Organizations
- VPC provisioning with public/private subnets
- IAM role and user creation
- Azure AD SSO setup via SAML metadata
- CloudFormation templates for IAM, Config Rules, and admin users

## Project Structure

```
.
├── organization-new-acc.sh         # Main automation script
├── CF-ADMINUSER.json               # CloudFormation: Admin user
├── CF-ConfigRules.json             # CloudFormation: Config Rules
├── CF-IAM-AD.json                  # CloudFormation: IAM for Azure AD
├── CF-IAM-ConfigRule.json          # CloudFormation: IAM for Config Rules
├── CF-USER.json                    # CloudFormation: Standard user
├── samplemetada.xml                # Sample SAML metadata for SSO
├── Jenkinsfile                     # Jenkins pipeline definition
└── .github/workflows/
    ├── terraform.yml               # CI: JSON/template validation
    └── pages.yml                   # GitHub Pages deployment
```

## Usage

```bash
./organization-new-acc.sh \
  --account_name "my-new-account" \
  --account_email "account@example.com" \
  --newProfile "my-profile" \
  --ou_name "Production" \
  --region "us-east-1" \
  --VPCCidrBlock "10.0.0.0/16" \
  --PublicSubnetCIDR1 "10.0.1.0/24" \
  --PublicSubnetCIDR2 "10.0.2.0/24" \
  --PrivateSubnetCIDR1 "10.0.3.0/24" \
  --PrivateSubnetCIDR2 "10.0.4.0/24" \
  --MetadataSamlfile "samplemetada.xml"
```

## Prerequisites

- AWS CLI configured with Organization admin credentials
- `jq` for JSON processing
- Access to AWS Organizations

## CI/CD

Every push triggers automated validation via GitHub Actions to ensure all CloudFormation templates and JSON files are syntactically valid.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

[MIT](LICENSE)

## Author

**Hammad Haqqani** — DevOps Architect & Cloud Engineer

- Website: [hammadhaqqani.com](https://hammadhaqqani.com)
- LinkedIn: [linkedin.com/in/haqqani](https://www.linkedin.com/in/haqqani)
- Email: phaqqani@gmail.com

---

## Support

If you find this useful, consider buying me a coffee!

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/hammadhaqqani)
