package waypoint

import "github.com/upbound/upjet/pkg/config"

// Configure configures individual resources by adding custom ResourceConfigurators.
func Configure(p *config.Provider) {
	p.AddResourceConfigurator("waypoint_auth_method_oidc", func(r *config.Resource) {
		r.ExternalName = config.NameAsIdentifier
		r.ShortGroup = "waypoint"
	})
	p.AddResourceConfigurator("waypoint_project", func(r *config.Resource) {
		r.ExternalName = config.NameAsIdentifier
		r.ShortGroup = "waypoint"
		r.ExternalName.SetIdentifierArgumentFn = func(base map[string]any, externalName string) {
			base["project_name"] = externalName
		}
		r.ExternalName.OmittedFields = []string{
			"project_name",
		}
	})
	p.AddResourceConfigurator("waypoint_runner_profile", func(r *config.Resource) {
		r.ShortGroup = "waypoint"
		r.ExternalName = config.NameAsIdentifier
		r.ExternalName.SetIdentifierArgumentFn = func(base map[string]any, externalName string) {
			base["profile_name"] = externalName
		}
		r.ExternalName.OmittedFields = []string{
			"profile_name",
		}
	})
}
