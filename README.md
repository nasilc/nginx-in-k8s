# Custom Nginx Web App (HAI Tech Task)

## 📝 Purpose

This project utilises Terraform to deploys a custom nginx web app to a kubernetes cluster. The application consists of: namespace, deployment (2 pods), configmap, service, ingress.

## 🛠️ Deployment

### Prerequisites

The environment that runs the terraform provisioning script requires:

- ```docker```, ```terraform``` installed and on path.
- Internet connectivity to dockerhub.
- Kubernetes cluster running locally and kubeconfig saved in the working directory at ```./kubeconfig/kubeconfig.yaml```

If you don't have terraform installed on the path you can run ```make tf-shell``` which will spin up a docker container with terraform installed and run the deployment steps from there.

### Deployment Steps

1.  Clone this repository.
2. ```cd``` into the cloned repository's root.
3. If you already have both cluster and kubeconfig file set up and located properly, skip to step 4. Otherwise, the below command will set up the cluster and place the kubeconfig file in the appropriate directory:

    ```make kube```

    

3. Run the below command:
    
    ```terraform init```.

4. Run the below command, replacing ${k8sHost} with the host address of your local kubernetes cluster.

    ```terraform apply --auto-approve -var="k8sHost=${k8sHost}"``` 
    
    e.g. ```terraform apply --auto-approve -var="k8sHost=https://127.0.0.1:6443"```

### Outcome

Visit the k8sHost IP address that you have set using http (e.g. If the k8sHost=https://127.0.0.1:6443, visit http://127.0.0.1) to visit your nginx app.

## ➡️ Some Next Steps

- Improve folder structure and modularise terraform files.
- Variabilise other parameters aside from hostname e.g. namespace, other resource names, index/configuration file, number of replicas.
- Script to run this in an isolated container rather than local environment.

## 📚 Resources

- Terraform Fundamentals
  - Medium - *Why we use Terraform and not Chef, Puppet, Ansible, Pulumi, or CloudFormation* (https://medium.com/gruntwork/why-we-use-terraform-and-not-chef-puppet-ansible-saltstack-or-cloudformation-7989dad2865c)
  - YouTube - *Terraform explained in 15 mins | Terraform Tutorial for Beginners* (https://www.youtube.com/watch?v=l5k1ai_GBDE)
  - YouTube - *Terraform Course - Automate your AWS cloud infrastructure* (https://www.youtube.com/watch?v=SLB_c_ayRMo&t=5339s)
- Terraform Best Practices
  - https://www.terraform-best-practices.com/examples
- Terraform for Kubernetes
  - Terraform - *Terraform Kubernetes Provider Documentation* (https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
  - YouTube - *Deploying on Kubernetes by using Terraform* (https://www.youtube.com/watch?v=eCHwm2l-GR8&t=188s)
  - Medium - *Manage Kubernetes Resources via Terraform* (https://medium.com/avmconsulting-blog/manage-kubernetes-resources-via-terraform-d57e6fae92c7)
- Nginx Docker Container
  - Nginx Documentation - *Serving Static Content* (https://docs.nginx.com/nginx/admin-guide/web-server/serving-static-content/)
  - Tinkink - *How to Use Nginx to Host a Static File Server* (https://tutorials.tinkink.net/en/nginx/nginx-static-file-server.html#configure-nginx)
  - https://stackoverflow.com/questions/64178370/custom-nginx-conf-from-configmap-in-kubernetes
- Other Miscellaneous Reads
  - https://github.com/hashicorp/terraform-provider-kubernetes/issues/1386
