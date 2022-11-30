multibranchPipelineJob('GitHubTerraform') {
    branchSources {
        git {
            id('1')
            remote('git@github.com:KeepCodingCloudDevops6/cicd-carlosfeu.git')
            credentialsId('ssh-github-key')
        }
    }
}
multibranchPipelineJob('CheckStorageSize') {
    branchSources {
        git {
            id('2')
            remote('git@github.com:KeepCodingCloudDevops6/cicd-carlosfeu.git')
            credentialsId('ssh-github-key')
        }
    }
    factory {
        workflowBranchProjectFactory {
            scriptPath('check_storage_size/Jenkinsfile.storage')
        }
    }
}
