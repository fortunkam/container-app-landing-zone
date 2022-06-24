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
- [x] Container App Environment
- [x] Log Analytics Workspace
- [x] App Insights
- [ ] Azure Container Registry
- [ ] Container App User Assigned Managed Identity
- [x] Firewall
- [ ] VPN
- [ ] APIM
- [ ] Key Vault
- [ ] SQL Server
- [ ] Storage Account
- [ ] GitHub Self Host Runner

Run the following command to deploy everything:

```
az deployment sub create --template-file base-infrastructure.bicep --location "westeurope"
```

Current outstanding questions:

- On deploy Containers Apps seems to need *.blob.core.windows.net to be added to the firewall, not in the docs? (https://docs.microsoft.com/en-us/azure/container-apps/firewall-integration)
- On deploy Containers Apps seems to need motd.ubuntu.com to be added to the firewall, not in the docs?
- On deploy Containers Apps seems to need *.blob.storage.azure.net to be added to the firewall, not in the docs?