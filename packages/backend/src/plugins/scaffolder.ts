import { createBackendModule } from '@backstage/backend-plugin-api';
import { scaffolderActionsExtensionPoint } from '@backstage/plugin-scaffolder-backend/alpha';
import { createPublishBitbucketCloudAction } from '@backstage/plugin-scaffolder-backend-module-bitbucket-cloud';
import { ScmIntegrations } from '@backstage/integration';

/**
 * @public
 * The Bitbucket Cloud Module for the Scaffolder Backend
 */
export const scaffolderModuleBitbucketCloud = createBackendModule({
  pluginId: 'scaffolder',
  moduleId: 'bitbucket-cloud',
  register(reg) {
    reg.registerInit({
      deps: {
        scaffolderActions: scaffolderActionsExtensionPoint,
        integrations: ScmIntegrations.factory,
      },
      async init({ scaffolderActions, integrations }) {
        scaffolderActions.addActions(
          createPublishBitbucketCloudAction({ integrations }),
        );
      },
    });
  },
});
