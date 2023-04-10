from diagrams import Diagram, Cluster
from diagrams.aws.compute import EC2 , EC2ElasticIpAddress
from diagrams.aws.database import RDS
from diagrams.aws.network import VPC, Route53 , PrivateSubnet , PublicSubnet
from diagrams.aws.storage import S3
from diagrams.onprem.client import User

# Create the diagram
with Diagram("AWS Infrastructure", show=False):
    # Define the AWS account and region
    usr = User("User")
    aws = Cluster("AWS Account")
    with aws:
        with Cluster("ap-south-1"):
        # Create the VPC with 3 subnets
            with Cluster("Default VPC"):
                    eip = EC2ElasticIpAddress("EIP")
                    ec2 = EC2("TFE")
            # Create the Route53 record
    usr >> eip >> ec2