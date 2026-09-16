# Terraform Notes

## What Is Terraform?

Terraform is an IaC (Infrastructure as Code) tool, used primarily by DevOps teams to automate various infrastructure tasks. The provisioning of cloud resources, for instance, is one of the main use cases of Terraform. It's a cloud-agnostic, open-source provisioning tool written in the Go language and created by HashiCorp.

Terraform allows you to describe your complete infrastructure in the form of code. Even if your servers come from different providers such as AWS or Azure, Terraform helps you build and manage these resources in parallel across providers. Think of Terraform as connective tissue and a common language that you can utilize to manage your entire IT stack.

---

## Benefits of Infrastructure-as-Code (IaC)

IaC replaces standard operating procedures and manual effort required for IT resource management with lines of code. Instead of manually configuring cloud nodes or physical hardware, IaC automates the process of infrastructure management through source code.

Here are several of the major key benefits of using an IaC solution like Terraform:

- **Speed and Simplicity** — IaC eliminates manual processes, thereby accelerating the delivery and management lifecycles. IaC makes it possible to spin up an entire infrastructure architecture by simply running a script.
- **Team Collaboration** — Various team members can collaborate on IaC software in the same way they would with regular application code through tools like GitHub. Code can be easily linked to issue tracking systems for future use and reference.
- **Error Reduction** — IaC minimizes the probability of errors or deviations when provisioning your infrastructure. The code completely standardizes your setup, allowing applications to run smoothly and error-free without the constant need for admin oversight.
- **Disaster Recovery** — With IaC you can actually recover from disasters more rapidly. Manually constructed infrastructure needs to be manually rebuilt, but with IaC, you can usually just re-run scripts and have the exact same software provisioned again.
- **Enhanced Security** — IaC relies on automation that removes many security risks associated with human error. When an IaC-based solution is installed correctly, the overall security of your computing architecture and associated data improves massively.

---

## Basic Terraform Folder Structure

```
projectname/
    |
    |-- provider.tf
    |-- version.tf
    |-- backend.tf
    |-- main.tf
    |-- variables.tf
    |-- terraform.tfvars
    |-- outputs.tf
```

### Give Terraform Files Logical Names

Terraform tutorials online often demonstrate a directory structure consisting of three files:

| File | Contains |
|---|---|
| `main.tf` | All providers, resources, and data sources |
| `variables.tf` | All defined variables |
| `output.tf` | All output resources |

The issue with this structure is that most logic is stored in the single `main.tf` file, which therefore becomes pretty complex and long. Terraform, however, does not mandate this structure — it only requires a directory of Terraform files. Since the filenames do not matter to Terraform, I propose a structure that enables users to quickly understand the code. Personally I prefer the following structure:

| File | Contains |
|---|---|
| `provider.tf` | The terraform block and provider block |
| `data.tf` | All data sources |
| `variables.tf` | All defined variables |
| `locals.tf` | All local variables |
| `output.tf` | All output resources |

---

## Important Terraform Commands

### Version

| Command | Description |
|---|---|
| `terraform –version` | Shows terraform version installed |

### Initialize Infrastructure

| Command | Description |
|---|---|
| `terraform init` | Initialize a working directory |
| `terraform init -input=true` | Ask for input if necessary |
| `terraform init -lock=false` | Disable locking of state files during state-related operations |
| `terraform plan` | Creates an execution plan (dry run) |
| `terraform apply` | Executes changes to the actual environment |
| `terraform apply –auto-approve` | Apply changes without being prompted to enter "yes" |
| `terraform destroy –auto-approve` | Destroy/cleanup without being prompted to enter "yes" |

### Terraform Workspaces

| Command | Description |
|---|---|
| `terraform workspace new` | Create a new workspace and select it |
| `terraform workspace select` | Select an existing workspace |
| `terraform workspace list` | List the existing workspaces |
| `terraform workspace show` | Show the name of the current workspace |
| `terraform workspace delete` | Delete an empty workspace |

### Terraform Import

```
terraform import aws_instance.example i-abcd1234(instance id)
# import an AWS instance with ID i-abcd1234 into aws_instance resource named "foo"
```

---

## State File

### What Is State and Why Is It Important in Terraform?

> "Terraform must store state about your managed infrastructure and configuration. This state is used by Terraform to map real world resources to your configuration, keep track of metadata, and to improve performance for large infrastructures. This state file is extremely important; it maps various resource metadata to actual resource IDs so that Terraform knows what it is managing. This file must be saved and distributed to anyone who might run Terraform."

### Remote State

> "By default, Terraform stores state locally in a file named `terraform.tfstate`. When working with Terraform in a team, use of a local file makes Terraform usage complicated because each user must make sure they always have the latest state data before running Terraform and make sure that nobody else runs Terraform at the same time."

> "With remote state, Terraform writes the state data to a remote data store, which can then be shared between all members of a team."

### State Lock

> "If supported by your backend, Terraform will lock your state for all operations that could write state. This prevents others from acquiring the lock and potentially corrupting your state."

> "State locking happens automatically on all operations that could write state. You won't see any message that it is happening. If state locking fails, Terraform will not continue. You can disable state locking for most commands with the `-lock` flag but it is not recommended."

### Setting Up Our S3 Backend

Create a new file in your working directory labeled `backend.tf`.

Copy and paste this configuration in your source code editor in your `backend.tf` file:

```hcl
terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "sample"
    dynamodb_table = "terraform-state-lock-dynamo"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}
```

> Before that, we have to create the S3 and DynamoDB resources — those resources will be called in `backend.tf`.

### Creating Our DynamoDB Table

Create a new file in your working directory labeled `dynamo.tf`.

Copy and paste this configuration in your source code editor in your `main.tf` file:

```hcl
# S3
resource "aws_s3_bucket" "example" {
  bucket = sample
}

# DynamoDB
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name           = "terraform-state-lock-dynamo"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }
}
```

---

## Data Source

### What Is a Data Source?

A data source in Terraform relates to resources, but it only gives information about an object rather than creating one. It provides dynamic information about the entities we define outside of Terraform.

Data sources allow fetching data about the infrastructure components' configuration. They allow fetching data from the cloud provider APIs using Terraform scripts.

When we refer to a resource using a data source, it won't create the resource. Instead, it gets information about that resource so that we can use it in further configuration if required.

### How to Use a Data Source

For example, we will create an EC2 instance using a VPC and subnet, both of which are created on the AWS console — external to the Terraform configuration.

**Step 1:** Create a Terraform directory and create a file named `provider.tf` in it. The code below represents the details of the AWS provider we're using, like its region, access key, and secret key.

```hcl
provider "aws" {
  region     = "us-east-1"
  access_key = "your_access_key"
  secret_key = "your_secret_key" # keys don't need to be configured here, it will pull from .aws folder locally
}
```

**Step 2:** In that directory, create another file named `demo_datasource.tf` and use the code given below.

```hcl
data "aws_vpc" "vpc" {
  id = vpc_id
}

data "aws_subnet" "subnet" {
  id = subnet_id
}

# Here we are creating a security group by calling the existing VPC,
# so we use a data source block
resource "aws_security_group" "sg" {
  name   = "sg"
  vpc_id = data.aws_vpc.vpc.id

  ingress = [
    {
      cidr_blocks     = ["0.0.0.0/0"]
      description     = ""
      from_port       = 22
      protocol        = "tcp"
      security_groups = []
      self            = false
      to_port         = 22
    }
  ]

  egress = [
    {
      cidr_blocks     = ["0.0.0.0/0"]
      description     = ""
      from_port       = 0
      protocol        = "-1"
      security_groups = []
      self            = false
      to_port         = 0
    }
  ]
}

resource "aws_instance" "dev" {
  ami             = data.aws_ami.amzlinux.id
  instance_type   = "t2.micro"
  subnet_id       = data.aws_subnet.dev.id
  security_groups = [data.aws_security_group.dev.id]

  tags = {
    Name = "DataSource-Instance"
  }
}
```

In the above block of code, we are using a VPC and a subnet that were already created on AWS using its console. Then, using the `data` block (which refers to data sources — a VPC and a subnet), we retrieve information about the VPC and subnet that are created outside of the Terraform configuration. We then create a security group that uses the `vpc_id` fetched using the data block, and further create the EC2 instance using the `subnet_id` also fetched using the data block.

So in this example, a data source is used to get data about a VPC and subnet that were not created using a Terraform script, and this data is used further for creating an EC2 instance.

**Case 2 — Fetching an AMI ID via a data source block:**

```hcl
data "aws_ami" "amzlinux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
```

---

## Terraform Import

### Why Terraform Import?

Terraform is a relatively new technology, and adopting it to manage an organisation's cloud resources might take some time and effort. The lack of human resources and the steep learning curve involved in using Terraform effectively causes teams to start using cloud infrastructure directly via their respective web consoles.

Any kind of IaC method (CloudFormation, Azure ARM templates, Pulumi, etc.) requires training and real-time scenario handling experience. Things get especially complicated when dealing with concepts like state and remote backends. In a worst-case scenario, you can lose the `terraform.tfstate` file — luckily, you can use the import functionality to rebuild it.

Getting pre-existing cloud resources under Terraform management is facilitated by Terraform import. `import` is a Terraform CLI command used to read real-world infrastructure and update the state, so that future updates to the same set of infrastructure can be applied via IaC.

The import functionality helps update the state locally — it does **not** create the corresponding configuration automatically. However, the Terraform team is working hard to improve this function in upcoming releases.

### Simple Import — Step-by-Step

With an understanding of why we need to import cloud resources, let's begin by importing a simple resource — an EC2 instance in AWS. This assumes the Terraform installation and AWS CLI credential configuration are already done locally.

#### 1. Prepare the EC2 Instance

For the sake of this tutorial, we will create an EC2 resource manually to be imported (optional if you already have a target resource).

**Example EC2 instance details:**

- Name: `MyVM`
- Instance ID: `i-0b9be609418aa0609`
- Type: `t2.micro`
- VPC ID: `vpc-1827ff72`

#### 2. Create `main.tf` and Set Provider Configuration

The aim of this step is to import this EC2 instance into our Terraform configuration. In your desired path, create `main.tf` and configure the AWS provider:

```hcl
// Provider configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

Run `terraform init` to initialize the Terraform modules. Below is the output of a successful initialization:

```
Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 3.0"...
- Installing hashicorp/aws v3.51.0...
- Installed hashicorp/aws v3.51.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

#### 3. Write Config for the Resource To Be Imported

Terraform import does not generate configuration files by itself, so you need to create the corresponding configuration for the EC2 instance manually. This doesn't need many arguments, since we'll add/modify them when we import the EC2 instance into our state file.

You could add all the arguments you know upfront, but this isn't foolproof — usually the infrastructure you import wasn't created by you, so it's best to skip a few arguments anyway.

For now, append `main.tf` with the EC2 config below. Only `ami` and `instance_type` are included since they are the required arguments for the `aws_instance` resource block:

```hcl
resource "aws_instance" "myvm" {
  ami           = "unknown" # we need to add this from the state file reference
  instance_type = "unknown" # we need to add this from the state file reference
}
```

#### 4. Import

Think of it as if the cloud resource (EC2 instance) and its corresponding configuration were already available in our files — all that's left is to map the two into our state file. We do that by running the import command:

```
terraform import aws_instance.myvm <Instance ID>
```

A successful output should look like this:

```
aws_instance.myvm: Importing from ID "i-0b9be609418aa0609"...
aws_instance.myvm: Import prepared!
  Prepared aws_instance for import
aws_instance.myvm: Refreshing state... [id=i-0b9be609418aa0609]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```

The above command maps the `aws_instance.myvm` configuration to the EC2 instance using its ID. The state file now "knows" the existence of the EC2 instance with the given ID, along with information about each of its attributes, fetched via the import command.

#### 5. Observe State Files and Plan Output

Notice the directory now also contains a `terraform.tfstate` file, generated after the import command ran successfully. Take a moment to go through its contents.

Right now, our configuration does not reflect all the attributes. Any attempt to plan/apply this configuration will fail, since we haven't adjusted the attribute values. To close the gap between the configuration and state files, run `terraform plan` and observe the output:

```
.
.
.
          } -> (known after apply)
          ~ throughput            = 0 -> (known after apply)
          ~ volume_id             = "vol-0fa93084426be508a" -> (known after apply)
          ~ volume_size           = 8 -> (known after apply)
          ~ volume_type           = "gp2" -> (known after apply)
        }

      - timeouts {}
    }

Plan: 1 to add, 0 to change, 1 to destroy.

───────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.
```

The plan indicates it would attempt to **replace** the EC2 instance — which goes completely against our purpose. We could still proceed by ignoring the existing resource and creating new resources via configuration, but that's not the goal here.

The good news: Terraform has taken note of the existing EC2 instance associated with its state.

#### 6. Improve Config To Avoid Replacement

The `terraform.tfstate` file is a vital reference for Terraform — all future operations consider this state file. You need to investigate the state file and update your configuration so there is a **minimum** difference between them.

Right now, focus on not replacing the EC2 instance, but rather aligning the configuration so replacement is avoided. Eventually, you'd reach a state of zero difference.

Observe the plan output and find the attributes causing replacement — the plan output highlights these. In our example, the only attribute causing replacement is the AMI ID. Closing this gap should avoid replacing the EC2 instance.

Change the value of `ami` from `"unknown"` to what's shown in the plan output, then run `terraform plan` again:

```
Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.myvm will be updated in-place
  ~ resource "aws_instance" "myvm" {
        id                                   = "i-0b9be609418aa0609"
      ~ instance_type                        = "t2.micro" -> "unknown"
      ~ tags                                 = {
          - "Name" = "MyVM" -> null
        }
      ~ tags_all                             = {
          - "Name" = "MyVM"
        } -> (known after apply)
        # (27 unchanged attributes hidden)
        # (6 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

This time, the plan does not indicate replacement of the EC2 instance. If you get the same output, you've successfully partially imported the cloud resource — you're now in a state of lowered risk: applying the configuration would change a few attributes, but won't replace the resource.

#### 7. Improve Config To Avoid Changes

To reach a state of zero difference, align your resource block further. The plan output highlights attribute changes with a `~` sign, along with the value differences — e.g., the change in `instance_type` from `"t2.micro"` to `"unknown"`.

In other words, if `instance_type` had been `"t2.micro"`, Terraform wouldn't have asked for a change. Similarly, there are changes to the `tags`. Let's close these gaps. The final `aws_instance` resource block should look like this:

```hcl
resource "aws_instance" "myvm" {
  ami           = "ami-00f22f6155d6d92c5"
  instance_type = "t2.micro"

  tags = {
    "Name" = "MyVM"
  }
}
```

Run `terraform plan` again and observe the output:

```
aws_instance.myvm: Refreshing state... [id=i-0b9be609418aa0609]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and
found no differences, so no changes are needed.
```

If you get the same output, congratulations — you've successfully imported a cloud resource into your Terraform config. It can now be managed via Terraform directly, without surprises.

---

## Meta-Arguments

Meta-arguments in Terraform are special arguments used with resource blocks and modules to control their behavior or influence the infrastructure provisioning process. They provide additional configuration options beyond regular resource-specific arguments.

| Meta-Argument | Description |
|---|---|
| `depends_on` | Specifies dependencies between resources. Ensures one resource is created/updated before another. |
| `count` | Controls resource instantiation by setting the number of instances created based on a given condition or variable. |
| `for_each` | Allows creating multiple instances of a resource based on a map or set of strings. Each instance is created with its unique key-value pair. |
| `lifecycle` | Defines lifecycle rules for managing resource updates, replacements, and deletions. |
| `provider` | Specifies the provider configuration for a resource — allows selecting a specific provider or version. |
| `provisioner` | Specifies actions to be taken on a resource after creation, such as running scripts or commands. |
| `connection` | Defines the connection details to a resource, enabling remote execution or file transfers. |
| `variable` | Declares input variables that can be provided during Terraform execution. |
| `output` | Declares output values that can be displayed after Terraform execution. |
| `locals` | Defines local values that can be used within the configuration files. |

### `depends_on`

Terraform has a feature for identifying resource dependencies. This means Terraform internally knows the sequence in which dependent resources need to be created, while independent resources are created in parallel.

But in some scenarios, dependencies exist that cannot be automatically inferred by Terraform — a resource relies on another resource's behavior, but doesn't access any of that resource's data in its arguments. For those cases, we use `depends_on` to explicitly define the dependency.

`depends_on` must be a list of references to other resources in the same calling resource. It's specified in resources as well as modules (Terraform version 0.13+).

**Example 1:**

```hcl
provider "aws" {
}

resource "aws_s3_bucket" "example" {
  bucket = "qwertyuiopasdfg"
}

resource "aws_instance" "dev" {
  ami           = "ami-0440d3b780d96b29d"
  instance_type = "t2.micro"
  depends_on    = [aws_s3_bucket.example]
  # here depends_on ensures the EC2 instance is only created after the S3 bucket;
  # if S3 creation fails, the EC2 instance will not be created
}
```

**Example 2:**

```hcl
### Create IAM policy
resource "aws_iam_policy" "example_policy" {
  name        = "example_policy"
  description = "Permissions for EC2"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "ec2:*",
        Effect : "Allow",
        Resource : "*"
      }
    ]
  })
}

### Create IAM role
resource "aws_iam_role" "example_role" {
  name = "example_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "examplerole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

### Attach IAM policy to IAM role
resource "aws_iam_policy_attachment" "policy_attach" {
  name       = "example_policy_attachment"
  roles      = [aws_iam_role.example_role.name]
  policy_arn = aws_iam_policy.example_policy.arn
}

### Create instance profile using role
resource "aws_iam_instance_profile" "example_profile" {
  name = "example_profile"
  role = aws_iam_role.example_role.name
}

### Create EC2 instance and attach IAM role
resource "aws_instance" "example_instance" {
  instance_type        = var.ec2_instance_type
  ami                  = var.image_id
  iam_instance_profile = aws_iam_instance_profile.example_profile.name
  depends_on           = [aws_iam_role.example_role]
  # here, only after creating the IAM role will the EC2 instance be created
  # and the role attached to it
}
```

### `count`

In Terraform, a resource block by default configures only one infrastructure object. If we want multiple resources with the same configuration, we can use the `count` meta-argument, reducing the overhead of duplicating the resource block.

`count` requires a whole number and creates that resource that many times. To identify each instance, we use `count.index` (ranging from `0` to `count - 1`).

Specified in resources as well as modules (Terraform version 0.13+). Note: `count` cannot be used together with `for_each`.

**Example 1:**

```hcl
resource "aws_instance" "myec2" {
  ami           = "ami-0230bd60aa48260c6"
  instance_type = "t2.micro"
  count         = 2

  tags = {
    Name = "webec2-${count.index}"
  }
}
```

**Example 2:**

```hcl
variable "ami" {
  type    = string
  default = "ami-0440d3b780d96b29d"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "sandboxes" {
  type    = list(string)
  default = ["sandbox_server_two", "sandbox_server_three"]
}

# main.tf
resource "aws_instance" "sandbox" {
  ami           = var.ami
  instance_type = var.instance_type
  count         = length(var.sandboxes)

  tags = {
    Name = var.sandboxes[count.index]
  }
}
```

### `for_each`

As noted with `count`, the default behavior of a resource is to create a single infrastructure object, which can be overridden using `count`. A more flexible way to do the same is the `for_each` meta-argument.

`for_each` accepts a map or set of strings. Terraform creates one instance of the resource for each member of that map/set. Two objects identify each member:

- `each.key` — the map key or set member.
- `each.value` — the map value corresponding to each member.

Specified in resources (Terraform version 0.12.6) as well as modules (Terraform version 0.13+).

**Example:**

```hcl
# variables.tf
variable "ami" {
  type    = string
  default = "ami-0078ef784b6fa1ba4"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "sandboxes" {
  type    = set(string)
  default = ["sandbox_one", "sandbox_two", "sandbox_three"]
}

# main.tf
resource "aws_instance" "sandbox" {
  ami           = var.ami
  instance_type = var.instance_type
  for_each      = var.sandboxes

  tags = {
    Name = each.value # for a set, each.value and each.key are the same
  }
}
```

### Multi Provider

The `provider` meta-argument specifies which provider to use for a resource. This is useful when using multiple providers — typically for multi-region resources. To differentiate between providers, use an `alias` field. The resource then references the provider's alias as `provider.alias`.

**Example:**

```hcl
# Provider 1 for ap-south-1 (default provider)
provider "aws" {
  region = "ap-south-1"
}

# Another provider alias
provider "aws" {
  region = "us-east-1"
  alias  = "america"
}

resource "aws_s3_bucket" "test" {
  bucket = "del-hyd-naresh-it"
}

resource "aws_s3_bucket" "test2" {
  bucket   = "del-hyd-naresh-it-test2"
  provider = aws.america
}
```

### `lifecycle`

The Terraform `lifecycle` block is a nested configuration block within a resource block, used to specify how Terraform should handle the creation, modification, and destruction of resources.

**Example:**

```hcl
resource "aws_instance" "test" {
  ami               = "ami-0440d3b780d96b29d"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1b"

  tags = {
    Name = "test"
  }

  lifecycle {
    create_before_destroy = true # creates the new object first, then destroys the old one
  }

  # lifecycle {
  #   prevent_destroy = true  # Terraform will error when attempting to destroy this resource
  # }

  # lifecycle {
  #   ignore_changes = [tags,] # Terraform will never update the object, but can still create/destroy it
  # }
}
```

**Managing the Resource Lifecycle**

Controlling the flow of Terraform operations is possible using the `lifecycle` meta-argument — useful when you need to protect items from being changed or destroyed. A common scenario: the Terraform provider doesn't handle a change correctly, so it can be safely ignored rather than having the provider attempt an unnecessary update. As provider versions are updated, these "bugs" get ironed out, and the lifecycle meta-argument can eventually be removed.

Available attributes:

**`create_before_destroy`**

When Terraform needs to destroy and recreate an object, the default behavior creates the new object *after* destroying the old one. This attribute creates the new object first, then destroys the old one — reducing downtime. Some resources have restrictions that may cause issues with this setting (objects that can't exist concurrently), so check resource constraints before using it.

```hcl
lifecycle {
  create_before_destroy = true
}
```

**`prevent_destroy`**

Prevents Terraform from accidentally removing critical resources — useful to avoid downtime when a change would destroy and recreate a resource. Use sparingly, as it makes certain configuration changes impossible.

```hcl
lifecycle {
  prevent_destroy = true
}
```

Terraform will error when it attempts to destroy a resource with this set to `true`:

```
Error: Instance cannot be destroyed
resource details...
Resource [resource_name] has lifecycle.prevent_destroy set, but the plan calls
for this resource to be destroyed. To avoid this error and continue with the
plan, either disable lifecycle.prevent_destroy or reduce the scope of the plan
using the -target flag.
```

**`ignore_changes`**

Useful when attributes of a resource are updated outside of Terraform — for example, when an Azure Policy automatically applies tags. When Terraform detects changes applied by the policy, it will ignore them rather than attempting to modify the tag. Specific attributes can be listed:

```hcl
lifecycle {
  ignore_changes = [
    tags["department"]
  ]
}
```

If all attributes should be ignored, use the `all` keyword. Terraform will never update the object, but can still create or destroy it:

```hcl
lifecycle {
  ignore_changes = [
    all
  ]
}
```

### `locals`

A local value assigns a name to an expression so you can reuse the name multiple times within a module. It helps avoid repeating the same values/expressions throughout a configuration — though overuse can make a configuration hard to read. Local values are not set by user input or values in Terraform files; instead, they're set "locally" within the configuration.

**Example:**

```hcl
locals {
  bucket-name = "${var.layer}-${var.env}-bucket-hydnaresh"
}

resource "aws_s3_bucket" "demo" {
  # bucket = "web-dev-bucket"
  # bucket = "${var.layer}-${var.env}-bucket-hyd"
  bucket = local.bucket-name

  tags = {
    # Name = "${var.layer}-${var.env}-bucket-hyd"
    Name        = local.bucket-name
    Environment = var.env
  }
}
```

---

## Provisioners

Terraform includes the concept of provisioners as a measure of pragmatism, knowing that there will always be certain behaviors that can't be directly represented in Terraform's declarative model.

Provisioners can be used to model specific actions on the local machine or a remote machine, in order to prepare servers or other infrastructure objects for service.

### File Provisioner

Used to copy files or directories from the machine executing `terraform apply` to the newly created resource. It can connect to the resource using either SSH or WinRM connections, and can upload a complete directory to the remote machine.

```hcl
resource "aws_instance" "web" {
  # ...

  # Copies the myapp.conf file to /etc/myapp.conf
  provisioner "file" {
    source      = "conf/myapp.conf"
    destination = "/etc/myapp.conf"
  }
}
```

### `local-exec` Provisioner

Invokes a local executable after a resource is created. This runs a process on the machine running Terraform, **not** on the resource itself. It's used when you want to perform tasks on your local machine — never used for tasks on the remote machine.

```hcl
resource "aws_instance" "web" {
  # ...

  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> private_ips.txt"
  }
}
```

### `remote-exec` Provisioner

Always works on the remote machine — lets you specify shell script commands to execute there. It invokes a script on a remote resource after creation, useful for running configuration management tools, bootstrapping into a cluster, etc. Requires a `connection` block and supports both SSH and WinRM.

```hcl
resource "aws_instance" "web" {
  # ...

  # Establishes connection used by all generic remote provisioners (file/remote-exec)
  connection {
    type = "ssh"
    user = "ubuntu" # Replace with the appropriate username for your EC2 instance
    # private_key = file("C:/Users/veerababu/.ssh/id_rsa")
    private_key = file("~/.ssh/id_rsa") # private key path
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "touch file200",
      "echo hello from aws >> file200",
    ]
  }
}
```

It can be used inside the Terraform resource object (invoked once the resource is created) or inside a `null_resource` — the preferred approach, since it separates this non-Terraform behavior from real Terraform behavior.

---

## Modules

### What Is a Module?

Terraform modules are reusable and encapsulated collections of Terraform configurations. They simplify managing resources, making your Terraform code more manageable and scalable. Modules make defining, configuring, and organizing resources modular and consistent, while abstracting away complexity to make Terraform code more scalable and maintainable.

### Benefits of Using Terraform Modules

- **Reusability** — Organize infrastructure resources and configurations into containers you can repurpose across projects and environments, saving effort and reducing errors significantly.
- **Abstraction** — Simplifies resource creation and configuration for Terraform configuration files, making them more concise and understandable.
- **Encapsulation** — Isolates resources and their dependencies, making it easier to manage or modify individual pieces of infrastructure without impacting others — improving modularity.
- **Versioning** — Terraform modules can be versioned, making it easier to track changes and update dependencies in an orderly manner, ensuring changes don't cause unintended problems.
- **Collaboration** — Allows your team and the wider community to work more collaboratively by sharing modules via the Terraform Registry or private module repositories, encouraging best practices and standardizing infrastructure configurations.

### Terraform Module Examples

#### Example 1: AWS VPC Module

Creating an AWS VPC is fundamental for many infrastructure deployments. Instead of defining the VPC configuration repeatedly, we can create a Terraform module for it.

**Module directory structure:**

```
modules/
  vpc/
    main.tf
    variables.tf
```

**VPC module code (`modules/vpc/main.tf`):**

```hcl
resource "aws_vpc" "example" {
  cidr_block = var.cidr_block
  tags       = { Name = var.name }
}
```

In this module, we define an AWS VPC resource and allow customization of the CIDR block and name via input variables.

**Input variables (`modules/vpc/variables.tf`):**

```hcl
variable "cidr_block" {
  description = "The CIDR block for the VPC."
}

variable "name" {
  description = "The name of the VPC."
}
```

**Using the VPC module (`main.tf`):**

```hcl
module "my_vpc" {
  source     = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
  name       = "my-vpc"
}
```

In the main Terraform configuration, we use the `module` block to include the VPC module — specifying the module's source directory and providing values for the input variables. Now you can easily create multiple VPCs with different configurations by reusing this module.

#### Example 2: AWS EC2 Instance Module

Creating EC2 instances is another common task in AWS. Let's create a Terraform module for it.

**Module directory structure:**

```
modules/
  ec2/
    main.tf
    variables.tf
```

**EC2 instance module code (`modules/ec2/main.tf`):**

```hcl
resource "aws_instance" "example" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name

  tags = {
    Name = var.name
  }
}
```

**Input variables (`modules/ec2/variables.tf`):**

```hcl
variable "ami" {
  description = "The AMI ID for the EC2 instance."
}

variable "instance_type" {
  description = "The instance type for the EC2 instance."
}

variable "subnet_id" {
  description = "The subnet ID for the EC2 instance."
}

variable "key_name" {
  description = "Key pair to associate with the EC2 instance."
}

variable "name" {
  description = "The name of the EC2 instance."
}
```

**Using the EC2 instance module (`main.tf`):**

```hcl
module "my_ec2" {
  source        = "./modules/ec2"
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  subnet_id     = "subnet-01234567"
  key_name      = "my-key-pair"
  name          = "my-ec2-instance"
}
```

In the main Terraform configuration, we use the `module` block to include the EC2 instance module — specifying the module's source directory and input variable values. With this module, you can easily create EC2 instances with different configurations across your infrastructure.

These examples demonstrate how Terraform modules promote code reuse, abstraction, and encapsulation. Following similar patterns, you can create modules for various infrastructure components, including databases, load balancers, and networking resources.

**If the module source is GitHub:**

```
github.com/CloudTechDevOps/Terraform/root_modules  # my github reference — here root_module is the source reference
```

---

## Connection Block

You can create one or more `connection` blocks that describe how to access the remote resource. One use case for multiple connections: have an initial provisioner connect as the root user to set up user accounts, then have subsequent provisioners connect as a user with more limited permissions.

Connection blocks don't take a block label and can be nested within either a resource or a provisioner. A connection block nested directly within a resource affects all of that resource's provisioners.

**Example:**

```hcl
connection {
  type = "ssh"
  user = "ubuntu" # Replace with the appropriate username for your EC2 instance
  # private_key = file("C:/Users/veerababu/.ssh/id_rsa")
  private_key = file("~/.ssh/id_rsa") # private key path
  host        = self.public_ip
}
```

---

## Output Values

Output values make information about your infrastructure available on the command line, and can expose information for other Terraform configurations to use.

**Example:**

```hcl
output "instance_public_ip" {
  value     = aws_instance.test.public_ip
  sensitive = true
}

output "instance_id" {
  value = aws_instance.test.id
}

output "instance_public_dns" {
  value = aws_instance.test.public_dns
}

output "instance_arn" {
  value = aws_instance.test.arn
}
```

---

## Condition / Validation Meta-Argument

```hcl
variable "aws_region" {
  description = "The region in which to create the infrastructure"
  type        = string
  nullable    = false
  default     = "change me" # here we need to define either us-west-1 or eu-west-2; any other region will error

  validation {
    condition     = var.aws_region == "us-west-2" || var.aws_region == "eu-west-1"
    error_message = "The variable 'aws_region' must be one of the following regions: us-west-2, eu-west-1"
  }
}

provider "aws" {
  region = var.aws_region
}
```
