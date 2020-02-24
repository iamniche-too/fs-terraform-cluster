# fs-terraform-cluster

## To provision the infrastructure using Terraform, following these steps:

Preliminary steps:
i) Add Kubernetes Engine Admin and Editor roles to the GCP Service Account that will be used in the script
i) Enable IAM API, Kubernetes Engine API via GCP console

Then:

a) Install gcloud: (Ubuntu) $> sudo snap install google-cloud-sdk --classic

b) Initialise gcloud: 

Note - please use a @focussensors.co.uk email address... 

```
$> gcloud init
```
Note - For a new configuration choose option [2] and then authenticate your email address in a web browser.

Note - this initial authentication is not “headless” but subsequent authentications will use the JSON credentials file as downloaded from the Service Account.

The credentials file should be stored in ~/.gcp/ 

c) Ensure Compute API is enabled (in GCP console)

d) Run script $> cd gcp && ./provision.sh 

