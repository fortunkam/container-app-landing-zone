# Deployment Instructions

The project is deployed using Bicep.  
It will create the following resources:
- [x] Hub Resource Group
- [x] Spoke Resource Group
- [x] Hub VNET (/21)
    - [x] Firewall Subnet (/24)
    - [x] VPN Subnet (/24)
    - [x] APIM Subnet (/24)
- [x] Spoke VNET (/21)
    - [x] Container Apps Infrastructure Subnet (/23)
    - [x] Container Apps Runtime Subnet (/23)
- [x] VNET Pairing (for Hub and Spoke)
- [ ] Container App Environment
- [x] Firewall
- [ ] VPN
- [ ] APIM
- [ ] Key Vault
- [ ] SQL Server
- [ ] Storage Account
- [ ] GitHub Self Host Runner

Run the following command to deploy the base infrastructure:

```
az deployment sub create --template-file base-infrastructure.bicep --location "westeurope"
```