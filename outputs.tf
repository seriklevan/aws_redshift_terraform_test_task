/*output "prod_vpc_id" {
  value = data.aws_vpcs.my_vpcs.id
}
*/
output "test_vpc_id" {
  value = aws_vpc.test_vpc.id
}

output "data_aws_availability_zones" {
  value = data.aws_availability_zones.working.names
}

output "data_aws_region_name" {
  value = data.aws_region.current.name
}

output "aws_subnet_test_publicsubnet_1_id" {
  value = aws_subnet.test_publicsubnet_1.id
}

output "aws_redshift_cluster_db_name" {
  value = aws_redshift_cluster.test-cluster.database_name
}

output "aws_redshift_cluster_dns_name" {
  value = aws_redshift_cluster.test-cluster.dns_name
}

output "aws_redshift_cluster_subnet_group_name" {
  value = aws_redshift_cluster.test-cluster.cluster_subnet_group_name
}
