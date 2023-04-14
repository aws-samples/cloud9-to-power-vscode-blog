## Use AWS Cloud9 to Power your Visual Studio Code IDE

The following repository contains the artifacts used in the blog post [Use AWS Cloud9 to Power your Visual Studio Code IDE](https://aws.amazon.com/blogs/architecture/field-notes-use-aws-cloud9-to-power-your-visual-studio-code-ide/).

## Prerequisites

Before using the [CloudFormation template](templates/cloud9instance.yml) provided in this solution, you **may** need to create an AWS Systems Manager [service-linked](https://docs.aws.amazon.com/cloud9/latest/user-guide/using-service-linked-roles.html#service-linked-role-permissions) role and / or [service role and instance profile](https://docs.aws.amazon.com/cloud9/latest/user-guide/ec2-ssm.html#service-role-ssm). The service-linked role is necessary to allow AWS Cloud9 to call other AWS services on your behalf. The service role and instance profile are needed to allow access to the AWS Cloud9 using AWS Systems Manager.

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.
