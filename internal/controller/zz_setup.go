/*
Copyright 2021 Upbound Inc.
*/

package controller

import (
	ctrl "sigs.k8s.io/controller-runtime"

	"github.com/upbound/upjet/pkg/controller"

	providerconfig "github.com/fire-ant/provider-waypoint/internal/controller/providerconfig"
	methodoidc "github.com/fire-ant/provider-waypoint/internal/controller/waypoint/methodoidc"
	profile "github.com/fire-ant/provider-waypoint/internal/controller/waypoint/profile"
	project "github.com/fire-ant/provider-waypoint/internal/controller/waypoint/project"
)

// Setup creates all controllers with the supplied logger and adds them to
// the supplied manager.
func Setup(mgr ctrl.Manager, o controller.Options) error {
	for _, setup := range []func(ctrl.Manager, controller.Options) error{
		providerconfig.Setup,
		methodoidc.Setup,
		profile.Setup,
		project.Setup,
	} {
		if err := setup(mgr, o); err != nil {
			return err
		}
	}
	return nil
}
