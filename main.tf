locals {
  // return the list of yaml files in the files directory.
  group_files = fileset(path.module, "./projects/*.yaml")

  // write out the contents of all of the files in the group_files local variable.
  raw_inputs = [for v in local.group_files : yamldecode(file(v))]

	// check our yaml files for empty keys and fall back to default variables as needed
	processed_inputs = { for project in local.raw_inputs: project.project_name => {
			project_name                     = project.project_name
			github_create_repo               = project.create_repo
			github_repository_name           = project.github_repository_name
			github_project_privacy           = try(project.github_project_privacy, var.github_project_privacy)
			github_repository_description    = try(project.github_repository_description, var.github_repository_description)
			github_repository_visibility     = try(project.github_repository_visibility, var.github_repository_visibility)
			github_template_repository_owner = try(project.github_template_repository_owner, var.github_template_repository_owner)
			github_template_repository_name  = try(project.github_template_repository_name, var.github_template_repository_name)
			github_team_members              = try(project.github_team_members, var.github_team_members)
			github_connection_name           = try(project.github_connection_name, var.github_connection_name)
			terraform_organization           = try(project.terraform_organization, var.terraform_organization)
			terraform_workspace_name         = try(project.terraform_workspace_name, project.project_name)
		}
	}
}

module "project_onboarding" {
  for_each = local.processed_inputs
  source  = "app.terraform.io/se-apj-demos/project-onboarding/tfe"
  version = "~> 0.0"

  project_name                     = each.value.project_name

  github_create_repo               = each.value.github_create_repo
  github_project_privacy           = each.value.github_project_privacy
  github_repository_name           = each.value.github_repository_name
  github_repository_description    = each.value.github_repository_description
  github_repository_visibility     = each.value.github_repository_visibility
  github_template_repository_owner = each.value.github_template_repository_owner
  github_template_repository_name  = each.value.github_template_repository_name
  github_team_members              = each.value.github_team_members
	github_connection_name           = each.value.github_connection_name

	tfe_org_name                     = each.value.terraform_organization
	tfe_workspace_name               = each.value.terraform_workspace_name

}

# resource "aws_security_group" "allow_ssh" {
#   name        = "allow_ssh"
#   description = "Allow ssh inbound traffic"
#   vpc_id      = module.vpc.vpc_id
# }

# resource "aws_security_group_rule" "ssh_inbound" {
# 	cidr_blocks = [ "0.0.0.0/0" ]
# 	security_group_id = aws_security_group.allow_ssh.id
# 	protocol = "tcp"
# 	from_port = 22
# 	to_port = 22
# 	type = "ingress"
# }