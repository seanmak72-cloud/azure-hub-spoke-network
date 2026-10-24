Azure Hub-and-Spoke Network with Terraform :



Project Overview :



Demonstrates an Azure hub-and-spoke network architecture provisioned and managed using Terraform.



Goal :



To separate shared management infrastructure from development and test workloads, helping to organize network resources and apply security controls consistently





\----------------------------------------------------------------------------------------------------------------------------------------------------



Architecture :



Infrastructure deployed includes :



* Hub VNet: vnet-hub-sea — 10.0.0.0/16
* Development Spoke: vnet-spoke-dev — 10.1.0.0/16
* Test Spoke: vnet-spoke-test — 10.2.0.0/16
* Hub Management Subnet: 10.0.1.0/24
* Development Workload Subnet: 10.1.1.0/24
* Test Workload Subnet: 10.2.1.0/24



The hub is peered with both spokes using bidirectional virtual network peering





\-------------------------------------------------------------------------------------------------------------------------------------------------



Azure Resources :



* Terraform ( IAC )
* Azure Resource Group
* Three Virtual Networks
* Three Subnets
* Four Virtual Network Peerings
* Two Network Security Groups (NSGs)
* Four explicit inbound deny rules for SSH and RDP from the Internet
* Two Route Tables
* Subnet associations for NSGs and Route Tables





\--------------------------------------------------------------------------------------------------------



Security Factors :



* The development and test subnets have Network Security Groups associated with them.
* Explicit inbound deny rules block:
* SSH traffic on TCP port 22 from the Internet
* RDP traffic on TCP port 3389 from the Internet



These rules provide additional explicit restrictions. Azure NSGs also apply their default security rules





\--------------------------------------------------------------------------------------------------------------------------------------------------





Technologies Used : 





* Microsoft Azure
* Terraform
* Azure CLI
* Git and GitHub
* PowerShell





\------------------------------------------------------------------------------------------------------------------------------------------------





Deployment Prerequisites :







* An Azure subscription
* Azure CLI installed and authenticated
* Terraform installed
* Git installed





\-----------------------------------------------------------------------------------------------------------------------------------------------





Steps:





Clone this repository:



1. git clone https://github.com/seanmak72-cloud/azure-hub-spoke-network.git



* cd azure-hub-spoke-network



2\. Sign in to Azure:



* Az login



3\. Create a local terraform.tfvars file containing your Azure subscription ID:



* Subscription\_id = "YOUR-AZURE-SUBSCRIPTION-ID"



Keep this file local. Do not commit subscription-specific configuration or sensitive values to GitHub.



4\. Initialize Terraform:



* terraform init



5\. Validate the configuration:



* terraform validate



6\. Review the proposed changes:



* terraform plan



7\. Apply the configuration only after reviewing the plan:



* terraform apply





\---------------------------------------------------------------------------------------------------------------------------------------





Validation:





The following checks were completed during development:



* terraform validate succeeded.
* terraform plan reported no changes.
* Hub-to-development and hub-to-test peerings reported Connected.
* NSG rules for inbound SSH and RDP were checked.
* Route table associations were verified





\----------------------------------------------------------------------------------------------------------------------------------------------





Network Limitations:





* VNet peering does not automatically enable direct communication between the two spokes.
* VNet peering alone does not provide hub-based transit routing.
* The route tables are associated with the spoke subnets but do not currently contain custom routes.
* No virtual network gateway, Azure Firewall, or network appliance is deployed in this project





\-----------------------------------------------------------------------------------------------------------------------------------------------







Cost Considerations:





Azure resources may incur charges depending on the services used, region, data transfer, and subscription pricing







\------------------------------------------------------------------------------------------------------------------------------------------------



Learning points from this project :



* Implemented a hub-and-spoke network layout in Azure.
* Provisioned network resources using Terraform.
* Configured bidirectional VNet peering.
* Applied NSG security rules to workload subnets.
* Associated route tables with subnets.
* Used Terraform validation, planning, and Git version control

