import sys
import time
import boto3
import argparse


def execute_autoupdater_on_instances(instances: list):
    """Execute autoupdater into the given list of EC2 instances IDs"""
    ssm_client = boto3.client('ssm')
    try:
        ssm_response = ssm_client.send_command(
            InstanceIds=[*instances],
            DocumentName='AWS-RunShellScript',
            Parameters={'commands': ['/usr/local/bin/testapp-autoupdater']}
        )

        command_id = ssm_response['Command']['CommandId']
        time.sleep(2)
        for instance_id in instances:
            output = ssm_client.get_command_invocation(
                CommandId=command_id,
                InstanceId=instance_id
            )
            print(f'EC2 instance "{instance_id}"')
            print(f'\tStatus: {output["Status"]}')
            print(f'\tstdout: {output["StandardOutputContent"]}')
            print(f'\tstderr: {output["StandardErrorContent"]}')
            print('='*30, '\n')
    except BaseException as err:
        print(f"Unexpected Error[{type(err)}]: {err}")
        raise


def retrieve_instances_from_autoscaling_group(autoscaling_group_name: str):
    """Given an Autoscaling Group name returns an IDs list of its EC2 instances."""
    asg_client = boto3.client('autoscaling')
    asg_response = asg_client.describe_auto_scaling_groups(
        AutoScalingGroupNames=[autoscaling_group_name]
    )
    if len(asg_response['AutoScalingGroups']) > 0:
        return [instance['InstanceId'] for instance in asg_response['AutoScalingGroups'][0]['Instances']]
    else:
        print(f'No AutoScalingGroups found with name "{autoscaling_group_name}".')
        sys.exit(1)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Executing CodeDeploy actions.')
    requiredNamed = parser.add_argument_group('required named arguments')
    requiredNamed.add_argument('--autoscaling-group-name', help='Autoscaling Group Name', required=True)
    args = parser.parse_args()
    instances_list = retrieve_instances_from_autoscaling_group(args.autoscaling_group_name)
    execute_autoupdater_on_instances(instances_list)
