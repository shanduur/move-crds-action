# move-crds-action

A GitHub Action for moving Custom Resource Definitions (CRDs) between repositories. This action handles copying CRD files from a source location to a target repository and can create or update pull requests to manage these changes.

## Usage

This GitHub Action can be included in your workflow YAML file to automate the movement of CRD files between repositories.

### Inputs

- **`targetRepository`** (`required`): The target repository where the CRD files should be moved. Specify the repository in the format `"owner/repo"` (e.g., `"myuser/myrepo"`).

- **`apiToken`** (`optional`, defaults to `GITHUB_TOKEN`): The GitHub API token used for authentication and API access. If not provided, the action uses the `GITHUB_TOKEN` secret provided by the GitHub workflow context.

- **`files`** (`required`): A glob pattern that specifies the CRD files to be moved. The pattern should match the files to be copied from the source location to the target repository.

- **`title`** (`optional`, defaults to `'chore(crds): copying CRDs'`): The title for the pull request when copying CRDs to the target repository. This title will be used for the creation or update process of the pull request.

### Workflow Example

Here's an example of how you might use the `move-crds-action` in a GitHub Actions workflow:

```yaml
name: 'Move CRDs'

on:
  push:
    branches:
      - main

jobs:
  move-crds:
    runs-on: ubuntu-latest

    steps:
    - name: 'Checkout code'
      uses: actions/checkout@v3

    - name: 'Set up Python'
      uses: actions/setup-python@v4
      with:
        python-version: '3.12'

    - name: 'Move CRDs'
      uses: your-github-username/move-crds-action@v1
      with:
        targetRepository: 'owner/repo'
        files: 'config/crd/bases/*'
        title: 'chore(crds): copying CRDs'
        apiToken: ${{ secrets.GITHUB_TOKEN }}
```

### Outputs

This action does not provide any explicit outputs. It will either create a new pull request in the target repository or update an existing one, depending on the provided inputs.

### License

This project is released under [The Unlicense](LICENSE).
